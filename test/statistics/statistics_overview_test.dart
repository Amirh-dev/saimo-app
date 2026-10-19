import 'package:flutter_test/flutter_test.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/features/statistics/cubit/statistics_state.dart';
import 'package:simo_learn/features/statistics/statistics_overview.dart';

import 'support/dashboards.dart';

void main() {
  test('a bucket is on the day the server wrote, not the UTC day before', () {
    // Midnight in Tehran is 20:30 the evening before in UTC.
    expect(
      StatisticsDay.dayOf('2026-10-17T00:00:00+03:30'),
      Jalali(1405, 7, 25),
    );
  });

  test('every day of the range is charted, the missing ones empty', () {
    final week = StatisticsRange.forPeriod(
      StatisticsPeriod.week,
      anchor: Jalali(1405, 7, 27),
    );
    final days = StatisticsDay.listFor(
      week,
      dashboard(days: [
        dayBucket(Jalali(1405, 7, 25), studySeconds: 3600),
        dayBucket(Jalali(1405, 7, 26), studySeconds: 600, rating: 4),
      ]),
      today: Jalali(1405, 7, 27),
      focus: Jalali(1405, 7, 26),
    );
    expect(days, hasLength(7));
    expect(days[0].studySeconds, 3600);
    expect(days[1].rating, 4);
    expect(days[1].isFocused, isTrue);
    expect(days[2].isToday, isTrue);
    expect(days[2].studySeconds, 0);
    expect(days[3].isFuture, isTrue);
    expect(days[2].isFuture, isFalse);
  });

  test('a range longer than a month is charted by week', () {
    final range = StatisticsRange.custom(Jalali(1404, 1, 1), Jalali(1404, 3, 1));
    final days = StatisticsDay.listFor(
      range,
      dashboard(days: [
        dayBucket(Jalali(1404, 1, 1), studySeconds: 60, rating: 2),
        dayBucket(Jalali(1404, 1, 3), studySeconds: 120, rating: 4),
        dayBucket(Jalali(1404, 1, 8), studySeconds: 30),
      ]),
      today: Jalali(1405, 1, 1),
    );
    expect(days.length, (range.dayCount / 7).ceil());
    expect(days.first.isGroup, isTrue);
    expect(days.first.studySeconds, 180);
    expect(days.first.rating, 3);
    expect(days[1].studySeconds, 30);
    expect(days.last.last, Jalali(1404, 3, 1));
  });

  test('the overview sums the range and compares it fairly', () {
    final overview = StatisticsOverview.of(dashboard(
      studySeconds: 7200,
      previousStudySeconds: 5400,
      totalQuestions: 50,
      correctAnswers: 40,
      previousTotalQuestions: 20,
      previousCorrectAnswers: 18,
      plannedSeconds: 1000,
      finishedSeconds: 500,
      progressedSeconds: 750,
      days: [
        dayBucket(Jalali(1405, 7, 25), studySeconds: 7200, completedTasks: 3),
        dayBucket(Jalali(1405, 7, 26), completedTasks: 1),
      ],
    ));
    expect(overview.studyDifference, 1800);
    expect(overview.accuracy, 80);
    expect(overview.accuracyChange, closeTo(-10, 0.001));
    expect(overview.progress, 75);
    expect(overview.completedTasks, 4);
    expect(overview.activeDays, 1);
    expect(overview.elapsedDays, 2);
    expect(overview.isEmpty, isFalse);
    expect(StatisticsOverview.of(dashboard()).isEmpty, isTrue);
  });

  group('the subject insight', () {
    SubjectStatistics subject(String name, int seconds, int total, int correct) =>
        SubjectStatistics(
          name: name,
          isMiscellaneous: false,
          studySeconds: seconds,
          totalQuestions: total,
          correctAnswers: correct,
        );

    test('flags the most studied subject when it is the least accurate', () {
      expect(
        SubjectStatistics.insight([
          subject('ریاضی', 900, 40, 20),
          subject('شیمی', 300, 20, 18),
        ]),
        contains('ریاضی'),
      );
    });

    test('flags a weak subject', () {
      expect(
        SubjectStatistics.insight([
          subject('شیمی', 900, 20, 18),
          subject('فیزیک', 300, 20, 10),
        ]),
        contains('فیزیک'),
      );
    });

    test('says nothing about a handful of questions', () {
      expect(SubjectStatistics.insight([subject('ریاضی', 900, 5, 1)]), isNull);
    });
  });

  test('subjects come most studied first, "other" last, idle ones left out',
      () {
    final subjects = SubjectStatistics.listOf(dashboard(subjects: [
      subjectBucket('متفرقه', studySeconds: 5000, miscellaneous: true),
      subjectBucket('شیمی', studySeconds: 100),
      subjectBucket('ریاضی', studySeconds: 900),
      subjectBucket('زیست'),
    ]));
    expect(subjects.map((s) => s.name), ['ریاضی', 'شیمی', 'متفرقه']);
  });
}
