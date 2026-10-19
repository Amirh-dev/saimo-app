import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/features/statistics/statistics_overview.dart';
import 'package:simo_learn/presentation/screens/statistics/rating_chart.dart';

import '../tasks/support/app_fonts.dart';

StatisticsDay day(int index, double? rating) {
  final date = Jalali(1405, 7, 25).addDays(index);
  return StatisticsDay(first: date, last: date, rating: rating);
}

SubjectStatistics subject(String name, double? rating) => SubjectStatistics(
      name: name,
      isMiscellaneous: false,
      studySeconds: 0,
      totalQuestions: 0,
      correctAnswers: 0,
      rating: rating,
    );

Future<void> pump(
  WidgetTester tester, {
  required List<StatisticsDay> days,
  List<SubjectStatistics> subjects = const [],
}) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: RatingChart(days: days, subjects: subjects),
        ),
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
    expect(find.text('هنوز گزارشی ثبت نکرده‌ای'), findsOneWidget);
  });
}
