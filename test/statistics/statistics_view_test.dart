import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/features/statistics/cubit/statistics_cubit.dart';
import 'package:simo_learn/features/statistics/cubit/statistics_state.dart';
import 'package:simo_learn/features/statistics/statistics_repository.dart';
import 'package:simo_learn/presentation/screens/app_tabs_shell.dart';
import 'package:simo_learn/presentation/screens/statistics/index.dart';
import 'package:simo_learn/presentation/screens/statistics/stat_bar_chart.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_header.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_sections.dart';
import 'package:simo_learn/presentation/screens/statistics/summary_bento.dart';

import '../tasks/support/app_fonts.dart';
import 'support/dashboards.dart';

/// A week with study on its elapsed days.
StatisticsDashboard busyWeek() {
  final week = StatisticsRange.forPeriod(StatisticsPeriod.week);
  final today = jalaliToday();
  final days = [
    for (final day in week.days)
      if (day.julianDayNumber <= today.julianDayNumber)
        dayBucket(
          day,
          studySeconds: 3600 + day.day * 60,
          completedTasks: 2,
          totalQuestions: 20,
          correctAnswers: 15,
          rating: 4,
        ),
  ];
  return dashboard(
    studySeconds: 12 * 3600 + 20 * 60,
    previousStudySeconds: 10 * 3600,
    adherence: 79,
    totalQuestions: 340,
    correctAnswers: 245,
    previousTotalQuestions: 300,
    previousCorrectAnswers: 225,
    questionsChange: 13,
    plannedSeconds: 940 * 60,
    finishedSeconds: 570 * 60,
    progressedSeconds: 740 * 60,
    days: days,
    subjects: [
      subjectBucket('ریاضی', studySeconds: 15000, totalQuestions: 100, correctAnswers: 60),
      subjectBucket('شیمی', studySeconds: 9000, totalQuestions: 40, correctAnswers: 36),
    ],
  );
}

Future<StatisticsCubit> pumpView(
  WidgetTester tester,
  FakeStatisticsRepository repository,
) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final cubit = StatisticsCubit(repository);
  await tester.pumpWidget(
    BlocProvider.value(
      value: cubit,
      child: const MaterialApp(
        home: AppTabsShell(
          titles: null,
          tabs: [Scaffold(body: StatisticsView())],
        ),
      ),
    ),
  );
  unawaited(cubit.load());
  return cubit;
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('shows a shimmering skeleton, then the week', (tester) async {
    final answer = Completer<StatisticsDashboard>();
    await pumpView(tester, FakeStatisticsRepository((_, __) => answer.future));
    await tester.pump();
    expect(find.byType(StatisticsSkeleton), findsOneWidget);

    answer.complete(busyWeek());
    await tester.pumpAndSettle();
    expect(find.byType(StatisticsSkeleton), findsNothing);
    expect(find.text('زمان مطالعه‌ی این هفته'), findsOneWidget);
    // 12 hours 20 minutes, counted up to.
    expect(find.text("۱۲"), findsWidgets);
    expect(find.text('۲۰'), findsWidgets);
    expect(find.text("۷۹٪"), findsWidgets);
    expect(find.text('۲:۲۰ بیشتر از هفته‌ی قبل'), findsOneWidget);
    expect(find.text('هفته‌ی جاری'), findsOneWidget);
  });

  testWidgets('stepping back dims the week until the one before arrives',
      (tester) async {
    final answers = <Completer<StatisticsDashboard>>[];
    final cubit = await pumpView(
      tester,
      FakeStatisticsRepository((_, __) {
        final answer = Completer<StatisticsDashboard>();
        answers.add(answer);
        return answer.future;
      }),
    );
    await tester.pump();
    answers.first.complete(busyWeek());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(NavButton).first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(cubit.state.isStale, isTrue);
    final dimmed = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: find.byType(SummaryBento),
        matching: find.byType(AnimatedOpacity),
      ).first,
    );
    expect(dimmed.opacity, lessThan(1));
    expect(find.text('برگشت به این هفته'), findsOneWidget);

    answers.last.complete(dashboard(studySeconds: 3600));
    await tester.pumpAndSettle();
    expect(cubit.state.isStale, isFalse);

    await tester.tap(find.text('برگشت به این هفته'));
    await tester.pump();
    expect(cubit.state.range.isCurrent, isTrue);
  });

  testWidgets('an empty week invites to the plan', (tester) async {
    await pumpView(tester, FakeStatisticsRepository((_, __) async => dashboard()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('هنوز آماری برای این هفته نداری'), findsOneWidget);
    expect(find.text('رفتن به برنامه'), findsOneWidget);
    expect(find.byType(StatBarChart), findsNothing);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    var fail = true;
    await pumpView(
      tester,
      FakeStatisticsRepository((_, __) async {
        if (fail) throw const StatisticsFailure('boom');
        return busyWeek();
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text('تلاش دوباره'), findsOneWidget);

    fail = false;
    await tester.tap(find.text('تلاش دوباره'));
    await tester.pumpAndSettle();
    expect(find.text('زمان مطالعه‌ی این هفته'), findsOneWidget);
  });

  testWidgets('a tapped bar shows its day', (tester) async {
    await pumpView(tester, FakeStatisticsRepository((_, __) async => busyWeek()));
    await tester.pumpAndSettle();

    final chart = find.byType(StatBarChart).first;
    await tester.ensureVisible(chart);
    await tester.pumpAndSettle();
    // The first day (Saturday) sits at the right, left of the axis.
    final box = tester.getRect(chart);
    final slot = (box.width - 28) / 7;
    await tester.tapAt(Offset(box.right - 28 - slot / 2, box.top + 120));
    await tester.pumpAndSettle();
    expect(find.textContaining('شنبه'), findsWidgets);
    expect(find.textContaining('۲ تسک'), findsOneWidget);
  });
}

