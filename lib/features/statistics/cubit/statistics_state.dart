import 'package:equatable/equatable.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/features/statistics/statistics_repository.dart';

enum StatisticsPeriod {
  today,
  week,
  month,
  custom,
}

enum StatisticsStatus {
  initial,
  loading,
  success,
  failure,
}

/// Today's date, without the time of day.
Jalali jalaliToday() {
  final now = Jalali.now();
  return Jalali(now.year, now.month, now.day);
}

/// A span of whole days, [first] to [last] inclusive, and what it was picked
/// as. Weeks start on Saturday.
class StatisticsRange extends Equatable {
  const StatisticsRange._(this.period, this.first, this.last);

  /// The day, week or month around [anchor] (today by default).
  factory StatisticsRange.forPeriod(
    StatisticsPeriod period, {
    Jalali? anchor,
  }) {
    final day = _dateOnly(anchor ?? jalaliToday());
    switch (period) {
      case StatisticsPeriod.today:
      case StatisticsPeriod.custom:
        return StatisticsRange._(period, day, day);
      case StatisticsPeriod.week:
        final first = day.addDays(-(day.weekDay - 1));
        return StatisticsRange._(period, first, first.addDays(6));
      case StatisticsPeriod.month:
        final first = Jalali(day.year, day.month, 1);
        return StatisticsRange._(
          period,
          first,
          Jalali(day.year, day.month, first.monthLength),
        );
    }
  }

  /// A range the user picked; the two ends may come in either order.
  factory StatisticsRange.custom(Jalali start, Jalali end) {
    var first = _dateOnly(start);
    var last = _dateOnly(end);
    if (last < first) (first, last) = (last, first);
    return StatisticsRange._(StatisticsPeriod.custom, first, last);
  }

  final StatisticsPeriod period;
  final Jalali first;
  final Jalali last;

  int get dayCount => last.julianDayNumber - first.julianDayNumber + 1;

  List<Jalali> get days => [
        for (var i = 0; i < dayCount; i++) first.addDays(i),
      ];

  bool contains(Jalali day) =>
      day.julianDayNumber >= first.julianDayNumber &&
      day.julianDayNumber <= last.julianDayNumber;

  /// Whether today falls in the range.
  bool get isCurrent => contains(jalaliToday());

  /// Whether the next range has started yet.
  bool get canGoNext =>
      last.julianDayNumber < jalaliToday().julianDayNumber;

  /// The range of the same kind and length, [direction] steps away.
  StatisticsRange shift(int direction) {
    switch (period) {
      case StatisticsPeriod.today:
        final day = first.addDays(direction);
        return StatisticsRange._(period, day, day);
      case StatisticsPeriod.week:
        final first = this.first.addDays(7 * direction);
        return StatisticsRange._(period, first, first.addDays(6));
      case StatisticsPeriod.month:
        return StatisticsRange.forPeriod(
          period,
          anchor: Jalali(first.year, first.month, 1).addMonths(direction),
        );
      case StatisticsPeriod.custom:
        final days = dayCount * direction;
        return StatisticsRange._(
          period,
          first.addDays(days),
          last.addDays(days),
        );
    }
  }

  /// The range the day charts show: a single day is shown within its week.
  StatisticsRange get chartRange => period == StatisticsPeriod.today
      ? StatisticsRange.forPeriod(StatisticsPeriod.week, anchor: first)
      : this;

  /// The last day that has data: today while the range runs.
  Jalali get lastElapsed {
    final today = jalaliToday();
    if (today < first || today > last) return last;
    return today;
  }

  /// Whether some of the range is still ahead.
  bool get isPartial => lastElapsed < last;

  /// The days asked for: up to today while the range runs, so a running
  /// week's numbers are not diluted by days that have not come yet.
  DateTime get start => _midnight(first);

  DateTime get end => _midnight(lastElapsed.addDays(1));

  /// The range before; while this one runs, only as many of its first days
  /// as have passed here, so a running week is set against the same weekdays
  /// of the week before, not all of it.
  DateTime get previousStart => _midnight(shift(-1).first);

  DateTime get previousEnd {
    final before = shift(-1);
    if (!isPartial) return _midnight(before.last.addDays(1));
    final elapsed = lastElapsed.julianDayNumber - first.julianDayNumber + 1;
    final days = elapsed < before.dayCount ? elapsed : before.dayCount;
    return _midnight(before.first.addDays(days));
  }

  static Jalali _dateOnly(Jalali date) =>
      Jalali(date.year, date.month, date.day);

  static DateTime _midnight(Jalali date) {
    final gregorian = date.toGregorian();
    return DateTime(gregorian.year, gregorian.month, gregorian.day);
  }

  @override
  List<Object?> get props => [
        period,
        first.julianDayNumber,
        last.julianDayNumber,
      ];
}

class StatisticsState extends Equatable {
  const StatisticsState({
    required this.range,
    this.status = StatisticsStatus.initial,
    this.dashboard,
    this.chartDashboard,
    this.loadedRange,
    this.errorMessage,
    this.direction = 0,
  });

  final StatisticsStatus status;

  /// The range the user is looking at.
  final StatisticsRange range;

  /// Numbers for [loadedRange]. They stay while another range loads, so the
  /// screen can move from one set of numbers to the next instead of blanking.
  final StatisticsDashboard? dashboard;

  /// Day-by-day data for [loadedRange]'s [StatisticsRange.chartRange].
  final StatisticsDashboard? chartDashboard;

  /// The range [dashboard] belongs to.
  final StatisticsRange? loadedRange;

  final String? errorMessage;

  /// -1 when the user last stepped back in time, 1 forward, 0 otherwise.
  final int direction;

  bool get isLoading => status == StatisticsStatus.loading;

  bool get isFailure => status == StatisticsStatus.failure;

  bool get hasData =>
      dashboard != null && chartDashboard != null && loadedRange != null;

  /// Whether what is shown belongs to another range than the one picked.
  bool get isStale => hasData && loadedRange != range;

  StatisticsState copyWith({
    StatisticsStatus? status,
    StatisticsRange? range,
    StatisticsDashboard? dashboard,
    StatisticsDashboard? chartDashboard,
    StatisticsRange? loadedRange,
    String? errorMessage,
    int? direction,
    bool clearError = false,
  }) {
    return StatisticsState(
      status: status ?? this.status,
      range: range ?? this.range,
      dashboard: dashboard ?? this.dashboard,
      chartDashboard: chartDashboard ?? this.chartDashboard,
      loadedRange: loadedRange ?? this.loadedRange,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      direction: direction ?? this.direction,
    );
  }

  @override
  List<Object?> get props => [
        status,
        range,
        dashboard,
        chartDashboard,
        loadedRange,
        errorMessage,
        direction,
      ];
}
