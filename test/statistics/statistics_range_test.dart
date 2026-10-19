import 'package:flutter_test/flutter_test.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/features/statistics/cubit/statistics_state.dart';

DateTime midnight(Jalali day) {
  final g = day.toGregorian();
  return DateTime(g.year, g.month, g.day);
}

void main() {
  // Monday 27 Mehr 1405.
  final monday = Jalali(1405, 7, 27);

  test('a week runs Saturday to Friday', () {
    final week =
        StatisticsRange.forPeriod(StatisticsPeriod.week, anchor: monday);
    expect(week.first, Jalali(1405, 7, 25));
    expect(week.last, Jalali(1405, 8, 1));
    expect(week.dayCount, 7);
  });

  test('a month covers all its days', () {
    final month =
        StatisticsRange.forPeriod(StatisticsPeriod.month, anchor: monday);
    expect(month.first, Jalali(1405, 7, 1));
    expect(month.last, Jalali(1405, 7, 30));
    // Shahrivar has 31 days.
    final before = month.shift(-1);
    expect(before.first, Jalali(1405, 6, 1));
    expect(before.last, Jalali(1405, 6, 31));
  });

  test('ranges step by their own length', () {
    final week =
        StatisticsRange.forPeriod(StatisticsPeriod.week, anchor: monday);
    expect(week.shift(-1).first, Jalali(1405, 7, 18));
    expect(week.shift(1).last, Jalali(1405, 8, 8));

    final custom = StatisticsRange.custom(Jalali(1405, 7, 10), Jalali(1405, 7, 3));
    expect(custom.first, Jalali(1405, 7, 3), reason: 'ends come in any order');
    expect(custom.dayCount, 8);
    expect(custom.shift(-1).first, Jalali(1405, 6, 26));
    expect(custom.shift(-1).last, Jalali(1405, 7, 2));
  });

  test('a past week is asked for whole and set against the week before', () {
    final week = StatisticsRange.forPeriod(
      StatisticsPeriod.week,
      anchor: Jalali(1400, 1, 15),
    );
    expect(week.isCurrent, isFalse);
    expect(week.canGoNext, isTrue);
    expect(week.isPartial, isFalse);
    expect(week.start, midnight(week.first));
    expect(week.end, midnight(week.last.addDays(1)));
    expect(week.previousStart, midnight(week.first.addDays(-7)));
    expect(week.previousEnd, week.start);
  });

  test('a running week stops at today and compares the same weekdays', () {
    final week = StatisticsRange.forPeriod(StatisticsPeriod.week);
    final today = jalaliToday();
    expect(week.isCurrent, isTrue);
    expect(week.canGoNext, isFalse);
    expect(week.end, midnight(today.addDays(1)));
    expect(
      week.previousEnd.difference(week.previousStart),
      week.end.difference(week.start),
    );
    expect(week.previousStart, midnight(week.first.addDays(-7)));
  });

  test('a month is never compared with more days than the month before has',
      () {
    // 31 Shahrivar against Mordad's 31 days, and 30 Mehr against 31.
    final mehr = StatisticsRange.forPeriod(
      StatisticsPeriod.month,
      anchor: Jalali(1400, 7, 10),
    );
    expect(mehr.previousEnd, midnight(Jalali(1400, 7, 1)));
    final esfand = StatisticsRange.forPeriod(
      StatisticsPeriod.month,
      anchor: Jalali(1400, 1, 10),
    );
    expect(esfand.previousEnd, midnight(Jalali(1400, 1, 1)));
  });

  test('a single day is charted within its week', () {
    final day = StatisticsRange.forPeriod(StatisticsPeriod.today, anchor: monday);
    expect(day.chartRange.period, StatisticsPeriod.week);
    expect(day.chartRange.first, Jalali(1405, 7, 25));
    final week = StatisticsRange.forPeriod(StatisticsPeriod.week, anchor: monday);
    expect(week.chartRange, same(week));
  });
}
