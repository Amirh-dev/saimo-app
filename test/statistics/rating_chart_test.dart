import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/graphql/queries/__generated__/statistics_dashboard.data.gql.dart';
import 'package:simo_learn/presentation/screens/statistics/rating_chart.dart';

import '../tasks/support/app_fonts.dart';

GStatisticsDashboardData_statisticsDashboard_dailyBuckets day(
        int index, double? rating) =>
    GStatisticsDashboardData_statisticsDashboard_dailyBuckets((b) => b
      ..start.value = DateTime(2026, 10, 10 + index).toIso8601String()
      ..studySeconds = 0
      ..completedTasks = 0
      ..totalQuestions = 0
      ..correctAnswers = 0
      ..incorrectAnswers = 0
      ..averagePerformanceRating = rating);

GStatisticsDashboardData_statisticsDashboard_subjectBuckets subject(
        String name, double? rating) =>
    GStatisticsDashboardData_statisticsDashboard_subjectBuckets((b) => b
      ..tagName = name
      ..isMiscellaneous = false
      ..studySeconds = 0
      ..completedTasks = 0
      ..totalQuestions = 0
      ..correctAnswers = 0
      ..incorrectAnswers = 0
      ..averagePerformanceRating = rating);

Future<void> pump(
  WidgetTester tester, {
  required List<GStatisticsDashboardData_statisticsDashboard_dailyBuckets> days,
  List<GStatisticsDashboardData_statisticsDashboard_subjectBuckets> subjects =
      const [],
}) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: RatingChart(dailyBuckets: days, subjectBuckets: subjects),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  test('formats ratings with a Persian decimal, dropping .0', () {
    expect(RatingChart.formatRating(4), '۴');
    expect(RatingChart.formatRating(3.75), '۳٫۸');
  });

  testWidgets('averages only the days that were rated', (tester) async {
    await pump(tester, days: [
      day(0, 4),
      day(1, null),
      day(2, 3),
      for (var i = 3; i < 7; i++) day(i, null),
    ], subjects: [
      subject('ریاضی', 2.5),
      subject('فیزیک', 4.5),
      subject('شیمی', null),
    ]);

    expect(find.text('۳٫۵'), findsOneWidget);
    expect(find.text('فیزیک'), findsOneWidget);
    expect(find.text('ریاضی'), findsOneWidget);
    expect(find.text('شیمی'), findsNothing);
    // Best subject first.
    expect(tester.getTopLeft(find.text('فیزیک')).dy,
        lessThan(tester.getTopLeft(find.text('ریاضی')).dy));
  });

  testWidgets('says how to start when nothing was rated', (tester) async {
    await pump(tester, days: [for (var i = 0; i < 7; i++) day(i, null)]);
    expect(find.text('هنوز گزارشی ثبت نکرده‌ای.'), findsOneWidget);
  });
}
