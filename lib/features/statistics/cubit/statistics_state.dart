import 'package:equatable/equatable.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:simo_learn/features/statistics/statistics_repository.dart';

enum StatisticsPeriod {
  today,
  week,
  month,
}

enum StatisticsStatus {
  initial,
  loading,
  success,
  failure,
}

class StatisticsRange extends Equatable {
  const StatisticsRange({
    required this.start,
    required this.end,
    required this.previousStart,
    required this.previousEnd,
  });

  final DateTime start;
  final DateTime end;
  final DateTime previousStart;
  final DateTime previousEnd;

  factory StatisticsRange.forPeriod(
      StatisticsPeriod period, {
        Jalali? anchor,
      }) {
    final today = anchor ?? Jalali.now();

    switch (period) {
      case StatisticsPeriod.today:
        return StatisticsRange._of(
          today,
          today.addDays(1),
          today.addDays(-1),
          today,
        );

      case StatisticsPeriod.week:
        final start = today.addDays(
          -(today.weekDay - 1),
        );

        return StatisticsRange._of(
          start,
          start.addDays(7),
          start.addDays(-7),
          start,
        );

      case StatisticsPeriod.month:
        final start = Jalali(
          today.year,
          today.month,
          1,
        );

        return StatisticsRange._of(
          start,
          start.addMonths(1),
          start.addMonths(-1),
          start,
        );
    }
  }

  factory StatisticsRange.custom(
      Jalali start,
      Jalali end,
      ) {
    final startDate = _midnight(start);
    final endDate = _midnight(
      end.addDays(1),
    );

    final duration = endDate.difference(startDate);

    return StatisticsRange(
      start: startDate,
      end: endDate,
      previousStart: startDate.subtract(duration),
      previousEnd: startDate,
    );
  }

  factory StatisticsRange._of(
      Jalali start,
      Jalali end,
      Jalali previousStart,
      Jalali previousEnd,
      ) {
    return StatisticsRange(
      start: _midnight(start),
      end: _midnight(end),
      previousStart: _midnight(previousStart),
      previousEnd: _midnight(previousEnd),
    );
  }

  static DateTime _midnight(Jalali date) {
    final gregorian = date.toGregorian();

    return DateTime(
      gregorian.year,
      gregorian.month,
      gregorian.day,
    );
  }

  @override
  List<Object?> get props => [
    start,
    end,
    previousStart,
    previousEnd,
  ];
}

class StatisticsState extends Equatable {
  const StatisticsState({
    required this.range,
    this.status = StatisticsStatus.initial,
    this.period = StatisticsPeriod.week,
    this.dashboard,
    this.weeklyDashboard,
    this.errorMessage,
  });

  final StatisticsStatus status;

  /// Period selected by the user for the statistics grid.
  final StatisticsPeriod period;

  /// Range used by the statistics grid.
  final StatisticsRange range;

  /// Data for the currently selected period.
  final StatisticsDashboard? dashboard;

  /// Data ALWAYS representing the current week.
  ///
  /// The charts use this data regardless of whether the user selects
  /// Today / Week / Month in the grid.
  final StatisticsDashboard? weeklyDashboard;

  final String? errorMessage;

  bool get isLoading =>
      status == StatisticsStatus.loading;

  bool get isFailure =>
      status == StatisticsStatus.failure;

  bool get hasDashboard =>
      dashboard != null;

  bool get hasWeeklyDashboard =>
      weeklyDashboard != null;

  bool get hasData =>
      dashboard != null &&
          weeklyDashboard != null;

  StatisticsState copyWith({
    StatisticsStatus? status,
    StatisticsPeriod? period,
    StatisticsRange? range,
    StatisticsDashboard? dashboard,
    StatisticsDashboard? weeklyDashboard,
    String? errorMessage,
    bool clearDashboard = false,
    bool clearWeeklyDashboard = false,
    bool clearError = false,
  }) {
    return StatisticsState(
      status: status ?? this.status,
      period: period ?? this.period,
      range: range ?? this.range,
      dashboard: clearDashboard
          ? null
          : dashboard ?? this.dashboard,
      weeklyDashboard: clearWeeklyDashboard
          ? null
          : weeklyDashboard ?? this.weeklyDashboard,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    period,
    range,
    dashboard,
    weeklyDashboard,
    errorMessage,
  ];
}