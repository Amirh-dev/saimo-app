import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/features/statistics/cubit/statistics_cubit.dart';
import 'package:simo_learn/features/statistics/statistics_overview.dart';
import 'package:simo_learn/features/statistics/statistics_repository.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_sections.dart';

import 'support/dashboards.dart';

Finder _key(String value) => find.byKey(ValueKey(value));

const _math = SubjectStatistics(
  tagID: 'math',
  name: 'ریاضی',
  isMiscellaneous: false,
  hasChildren: true,
  studySeconds: 6 * 3600,
  totalQuestions: 100,
  correctAnswers: 72,
);

const _literature = SubjectStatistics(
  tagID: 'lit',
  name: 'ادبیات',
  isMiscellaneous: false,
  studySeconds: 3600,
  totalQuestions: 0,
  correctAnswers: 0,
);

Map<String, dynamic> _row(
  String name, {
  int studySeconds = 0,
  int totalQuestions = 0,
  int correctAnswers = 0,
  bool general = false,
}) =>
    {
      'tagID': name,
      'tagName': name,
      'isGeneral': general,
      'studySeconds': studySeconds,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'averagePerformanceRating': null,
    };

Future<void> _pump(
  WidgetTester tester,
  Future<List<SubjectStatistics>> Function(SubjectStatistics) loadParts,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SingleChildScrollView(
            child: SubjectsSection(
              subjects: const [_math, _literature],
              loadParts: loadParts,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  test('parts: most studied first, the subject\'s own tasks last as «عمومی»',
      () {
    final parts = SubjectStatistics.partsOf([
      _row('ریاضی', studySeconds: 9000, general: true),
      _row('هندسه', studySeconds: 600),
      _row('گسسته'), // nothing studied: left out
      _row('حسابان', studySeconds: 3000, totalQuestions: 10, correctAnswers: 8),
    ]);
    expect(parts.map((p) => p.name), ['حسابان', 'هندسه', 'عمومی']);
    expect(parts.first.accuracy, 80);
    expect(parts.last.isGeneral, isTrue);
  });

  testWidgets('a subject with tags under it opens in place, one at a time',
      (tester) async {
    final asked = <String>[];
    await _pump(tester, (subject) async {
      asked.add(subject.tagID!);
      return SubjectStatistics.partsOf([
        _row('حسابان',
            studySeconds: 3 * 3600, totalQuestions: 20, correctAnswers: 10),
        _row('ریاضی', studySeconds: 1800, general: true),
      ]);
    });

    expect(find.text('حسابان'), findsNothing);
    // Only subjects with tags under them open.
    expect(_key('subject-lit'), findsNothing);

    await tester.tap(_key('subject-math'));
    await tester.pumpAndSettle();
    expect(asked, ['math']);
    expect(_key('subject-part-حسابان'), findsOneWidget);
    expect(_key('subject-part-عمومی'), findsOneWidget);
    expect(find.text('۵۰٪'), findsOneWidget); // حسابان's accuracy

    await tester.tap(_key('subject-math'));
    await tester.pumpAndSettle();
    expect(find.text('حسابان'), findsNothing);
  });

  testWidgets('a long tag name gets its own line, whole, above its figures',
      (tester) async {
    const name = 'ریاضیات گسسته دوازدهم';
    await _pump(
        tester,
        (_) async => SubjectStatistics.partsOf([
              _row(name,
                  studySeconds: 7500, totalQuestions: 30, correctAnswers: 16),
            ]));
    await tester.tap(_key('subject-math'));
    await tester.pumpAndSettle();

    final label = find.text(name);
    expect(label, findsOneWidget);
    expect(
        tester.renderObject<RenderParagraph>(label).didExceedMaxLines, isFalse);
    // The figures sit under the name, not beside it.
    expect(tester.getBottomLeft(label).dy,
        lessThanOrEqualTo(tester.getTopLeft(find.text('۵۳٪')).dy));
  });

  testWidgets('a failed load offers a retry that asks again', (tester) async {
    var calls = 0;
    await _pump(tester, (subject) {
      calls++;
      if (calls == 1) return Future.error(const StatisticsFailure('offline'));
      return Future.value(
        SubjectStatistics.partsOf([_row('هندسه', studySeconds: 600)]),
      );
    });

    await tester.tap(_key('subject-math'));
    await tester.pumpAndSettle();
    expect(find.text('دریافت نشد؛ دوباره امتحان کن'), findsOneWidget);

    await tester.tap(find.text('دریافت نشد؛ دوباره امتحان کن'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(_key('subject-part-هندسه'), findsOneWidget);
  });

  testWidgets('the «؟» explains the numbers come from the tasks\' tags',
      (tester) async {
    await _pump(tester, (_) async => const []);

    expect(_key('subjects-help-text'), findsNothing);
    await tester.tap(_key('subjects-help'));
    await tester.pumpAndSettle();
    expect(_key('subjects-help-text'), findsOneWidget);
    expect(
      find.textContaining('از تگ‌های تسک‌هات ساخته می‌شه'),
      findsOneWidget,
    );

    await tester.tap(_key('subjects-help'));
    await tester.pumpAndSettle();
    expect(_key('subjects-help-text'), findsNothing);
  });

  test('the cubit fetches a subject\'s tags once per loaded range', () async {
    final repository = FakeStatisticsRepository((_, __) async => dashboard())
      ..parts = {
        'math': [_row('هندسه', studySeconds: 600)],
      };
    final cubit = StatisticsCubit(repository);
    await cubit.load();

    final first = await cubit.partsOf(_math);
    await cubit.partsOf(_math);
    expect(first.single.name, 'هندسه');
    expect(repository.partRequests, ['math']);

    await cubit.refresh();
    await cubit.partsOf(_math);
    expect(repository.partRequests, ['math', 'math']);

    // A failure is not kept, so the next open tries again.
    await expectLater(
      cubit.partsOf(const SubjectStatistics(
        tagID: 'bio',
        name: 'زیست',
        isMiscellaneous: false,
        hasChildren: true,
        studySeconds: 0,
        totalQuestions: 0,
        correctAnswers: 0,
      )),
      throwsA(isA<StatisticsFailure>()),
    );
    repository.parts['bio'] = [];
    final bio = cubit.partsOf(const SubjectStatistics(
      tagID: 'bio',
      name: 'زیست',
      isMiscellaneous: false,
      hasChildren: true,
      studySeconds: 0,
      totalQuestions: 0,
      correctAnswers: 0,
    ));
    expect(await bio, isEmpty);
    await cubit.close();
  });
}
