import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/screens/tasks/task_report_popup.dart';
import 'package:simo_learn/presentation/screens/tasks/tasks_api.dart';

import 'support/app_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  Future<Future<TaskReport?>> open(
    WidgetTester tester, {
    TaskReport? initial,
    Future<void> Function(TaskReport)? onSubmit,
    List<TaskReport>? submitted,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late Future<TaskReport?> result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () {
                result = showTaskReportPopup(
                  context,
                  initial: initial,
                  onSubmit:
                      onSubmit ?? (report) async => submitted?.add(report),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return Future.value(result);
  }

  Finder byKey(String key) => find.byKey(ValueKey(key));

  testWidgets('asks for a rating before saving', (tester) async {
    final submitted = <TaskReport>[];
    await open(tester, submitted: submitted);

    await tester.tap(byKey('task-report-submit'));
    await tester.pumpAndSettle();

    expect(submitted, isEmpty);
    expect(byKey('task-report-error'), findsOneWidget);
    expect(byKey('task-report-popup'), findsOneWidget);
  });

  testWidgets('saves a rating without a test', (tester) async {
    final submitted = <TaskReport>[];
    final result = await open(tester, submitted: submitted);

    await tester.tap(byKey('task-report-rating-4'));
    await tester.pump();
    await tester.tap(byKey('task-report-submit'));
    await tester.pumpAndSettle();

    expect(submitted.single.rating, 4);
    expect(submitted.single.tookTest, isFalse);
    expect(submitted.single.toInput(),
        {'performanceRating': 4, 'tookTest': false});
    expect((await result)?.rating, 4);
    expect(byKey('task-report-popup'), findsNothing);
  });

  testWidgets('saves test counts typed in Persian digits', (tester) async {
    final submitted = <TaskReport>[];
    await open(tester, submitted: submitted);

    await tester.tap(byKey('task-report-rating-2'));
    await tester.tap(byKey('task-report-took-test'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.descendant(
            of: byKey('task-report-total'),
            matching: find.byType(EditableText)),
        '۵۰');
    await tester.enterText(
        find.descendant(
            of: byKey('task-report-correct'),
            matching: find.byType(EditableText)),
        '42');
    await tester.tap(byKey('task-report-submit'));
    await tester.pumpAndSettle();

    expect(submitted.single.toInput(), {
      'performanceRating': 2,
      'tookTest': true,
      'totalQuestions': 50,
      'correctAnswers': 42,
    });
  });

  testWidgets('shows the accuracy as the counts are typed', (tester) async {
    await open(tester,
        initial: const TaskReport(
            rating: 3, totalQuestions: 50, correctAnswers: 42));
    expect(find.text('۸۴٪'), findsOneWidget);

    await tester.enterText(
        find.descendant(
            of: byKey('task-report-correct'),
            matching: find.byType(EditableText)),
        '60');
    await tester.pumpAndSettle();
    // More correct than asked: no percentage until it makes sense.
    expect(byKey('task-report-accuracy'), findsNothing);
  });

  testWidgets('rejects more correct answers than questions', (tester) async {
    final submitted = <TaskReport>[];
    await open(tester,
        submitted: submitted,
        initial:
            const TaskReport(rating: 3, totalQuestions: 10, correctAnswers: 5));

    await tester.enterText(
        find.descendant(
            of: byKey('task-report-correct'),
            matching: find.byType(EditableText)),
        '11');
    await tester.tap(byKey('task-report-submit'));
    await tester.pumpAndSettle();

    expect(submitted, isEmpty);
    expect(find.text('پاسخ صحیح نمی‌تواند از تعداد کل سوالات بیشتر باشد.'),
        findsOneWidget);
  });

  testWidgets('stays open with the error when saving fails', (tester) async {
    await open(tester,
        initial: const TaskReport(rating: 5),
        onSubmit: (_) async =>
            throw const TaskActionException('ثبت گزارش ناموفق بود.'));

    await tester.tap(byKey('task-report-submit'));
    await tester.pumpAndSettle();

    expect(byKey('task-report-popup'), findsOneWidget);
    expect(find.text('ثبت گزارش ناموفق بود.'), findsOneWidget);
  });

  testWidgets('a note is optional and saved trimmed', (tester) async {
    final submitted = <TaskReport>[];
    await open(tester, submitted: submitted);
    expect(byKey('task-report-note'), findsNothing);

    await tester.tap(byKey('task-report-rating-3'));
    await tester.tap(byKey('task-report-add-note'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.descendant(
            of: byKey('task-report-note'), matching: find.byType(EditableText)),
        '  فصل ۳ سخت بود  ');
    await tester.tap(byKey('task-report-submit'));
    await tester.pumpAndSettle();

    expect(submitted.single.toInput(), {
      'performanceRating': 3,
      'tookTest': false,
      'note': 'فصل ۳ سخت بود',
    });
  });

  testWidgets('an earlier note opens expanded', (tester) async {
    await open(tester,
        initial: const TaskReport(rating: 2, note: 'دفعه بعد زودتر شروع کنم'));
    expect(find.text('دفعه بعد زودتر شروع کنم'), findsOneWidget);
  });

  testWidgets('skipping saves nothing', (tester) async {
    final submitted = <TaskReport>[];
    final result = await open(tester, submitted: submitted);

    await tester.tap(byKey('task-report-skip'));
    await tester.pumpAndSettle();

    expect(submitted, isEmpty);
    expect(await result, isNull);
  });

  test('maps a completion report from the API', () {
    final task = plannedTaskFromApi({
      'id': 't1',
      'type': 'NORMAL',
      'status': 'COMPLETED',
      'completionReport': {
        'performanceRating': 3,
        'tookTest': true,
        'totalQuestions': 20,
        'correctAnswers': 18,
      },
    });
    final report = task['report'] as TaskReport;
    expect(report.rating, 3);
    expect(report.totalQuestions, 20);
    expect(report.correctAnswers, 18);
    expect(plannedTaskFromApi({'id': 't2'})['report'], isNull);
  });
}
