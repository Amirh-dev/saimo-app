import 'package:equatable/equatable.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:simo_learn/features/statistics/statistics_repository.dart';

enum StatisticsPeriod { today, week, month }
enum StatisticsStatus { initial, loading, success, failure }

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
        return StatisticsRange._of(today, today.addDays(1), today.addDays(-1), today);
      case StatisticsPeriod.week:
        final start = today.addDays(-(today.weekDay - 1));
        return StatisticsRange._of(
            start, start.addDays(7), start.addDays(-7), start);
      case StatisticsPeriod.month:
        final start = Jalali(today.year, today.month, 1);
        return StatisticsRange._of(
            start, start.addMonths(1), start.addMonths(-1), start);
    }
  }

  factory StatisticsRange.custom(Jalali start, Jalali end) {
    final startMidnight = _midnight(start);
    final endMidnight = _midnight(end.addDays(1));
    final duration = endMidnight.difference(startMidnight);

    return StatisticsRange(
      start: startMidnight,
      end: endMidnight,
      previousStart: startMidnight.subtract(duration),
      previousEnd: startMidnight,
    );
  }

  factory StatisticsRange._of(Jalali s, Jalali e, Jalali ps, Jalali pe) =>
      StatisticsRange(
        start: _midnight(s),
        end: _midnight(e),
        previousStart: _midnight(ps),
        previousEnd: _midnight(pe),
      );

  static DateTime _midnight(Jalali jalali) {
    final g = jalali.toGregorian();
    return DateTime(g.year, g.month, g.day);
  }

  @override
  List<Object?> get props => [start, end, previousStart, previousEnd];
}

class StatisticsState extends Equatable {
  const StatisticsState({
    required this.range,
    this.status = StatisticsStatus.initial,
    this.period = StatisticsPeriod.week,
    this.dashboard,
    this.weeklyDashboard, // NEW: Dedicated variable for the charts
    this.errorMessage,
  });

  final StatisticsStatus status;
  final StatisticsPeriod period;
  final StatisticsRange range;
  final StatisticsDashboard? dashboard; // Used by _StatsGrid
  final StatisticsDashboard? weeklyDashboard; // Used by Charts
  final String? errorMessage;

  bool get isFirstLoad =>
      status == StatisticsStatus.loading && dashboard == null;

  String get comparisonLabel => switch (period) {
    StatisticsPeriod.today => 'از دیروز',
    StatisticsPeriod.week => 'از هفته قبل',
    StatisticsPeriod.month => 'از ماه قبل',
  };

  StatisticsState copyWith({
    StatisticsStatus? status,
    StatisticsPeriod? period,
    StatisticsRange? range,
    StatisticsDashboard? dashboard,
    StatisticsDashboard? weeklyDashboard,
    String? errorMessage,
    bool clearError = false,
    bool clearDashboard = false,
  }) =>
      StatisticsState(
        status: status ?? this.status,
        period: period ?? this.period,
        range: range ?? this.range,
        dashboard: clearDashboard ? null : (dashboard ?? this.dashboard),
        weeklyDashboard: weeklyDashboard ?? this.weeklyDashboard,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [status, period, range, dashboard, weeklyDashboard, errorMessage];
}