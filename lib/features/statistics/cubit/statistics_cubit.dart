import 'dart:async';

import 'package:ferry/ferry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:simo_learn/features/statistics/statistics_repository.dart';
import 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit(this._repository)
      : super(StatisticsState(
    range: StatisticsRange.forPeriod(StatisticsPeriod.week),
  ));

  final StatisticsRepository _repository;
  StreamSubscription<StatisticsDashboard>? _subscription;
  StreamSubscription<StatisticsDashboard>? _weeklySubscription;

  Future<void> load() {
    debugPrint("🔵 CUBIT: load() called");
    _subscribeWeekly(); // Start the permanent weekly listener for charts
    return _subscribe(
      state.period,
      state.range,
      clearDashboard: true,
    );
  }

  Future<void> changePeriod(StatisticsPeriod period) {
    debugPrint("🔵 CUBIT: changePeriod() called with period: ${period.name}");
    try {
      final newRange = StatisticsRange.forPeriod(period);
      return _subscribe(
        period,
        newRange,
        fetchPolicy: FetchPolicy.NetworkOnly,
        clearDashboard: true,
      );
    } catch (e, stack) {
      debugPrint("🔴 CUBIT CRASH: $e");
      return Future.value();
    }
  }

  Future<void> selectDay(Jalali day) {
    return _subscribe(
      state.period,
      StatisticsRange.forPeriod(state.period, anchor: day),
      fetchPolicy: FetchPolicy.NetworkOnly,
      clearDashboard: true,
    );
  }

  Future<void> refresh() {
    debugPrint("🔵 CUBIT: refresh() called (Pull-to-refresh)");
    _subscribeWeekly(fetchPolicy: FetchPolicy.NetworkOnly); // Refresh chart data too
    return _subscribe(
      state.period,
      state.range,
      fetchPolicy: FetchPolicy.NetworkOnly,
    );
  }

  Future<void> selectDateRange(Jalali start, Jalali end) {
    try {
      final customRange = StatisticsRange.custom(start, end);
      return _subscribe(
        state.period,
        customRange,
        fetchPolicy: FetchPolicy.NetworkOnly,
        clearDashboard: true,
      );
    } catch (e, stack) {
      debugPrint("🔴 CUBIT CRASH: $e");
      return Future.value();
    }
  }

  /// Dedicated subscription specifically for the charts (Always "This Week")
  void _subscribeWeekly({FetchPolicy fetchPolicy = FetchPolicy.CacheAndNetwork}) {
    _weeklySubscription?.cancel();
    final weekRange = StatisticsRange.forPeriod(StatisticsPeriod.week);

    _weeklySubscription = _repository
        .watchDashboard(
      start: weekRange.start,
      end: weekRange.end,
      previousStart: weekRange.previousStart,
      previousEnd: weekRange.previousEnd,
      fetchPolicy: fetchPolicy,
    )
        .listen(
          (dashboard) {
        debugPrint("🟢 API SUCCESS: Weekly chart data updated.");
        emit(state.copyWith(weeklyDashboard: dashboard));
      },
      onError: (Object error) {
        debugPrint("🔴 API ERROR from Weekly Repository: $error");
      },
    );
  }

  Future<void> _subscribe(
      StatisticsPeriod period,
      StatisticsRange range, {
        FetchPolicy fetchPolicy = FetchPolicy.CacheAndNetwork,
        bool clearDashboard = false,
      }) async {
    _subscription?.cancel();

    emit(state.copyWith(
      status: StatisticsStatus.loading,
      period: period,
      range: range,
      clearError: true,
      clearDashboard: clearDashboard,
    ));

    try {
      _subscription = _repository
          .watchDashboard(
        start: range.start,
        end: range.end,
        previousStart: range.previousStart,
        previousEnd: range.previousEnd,
        fetchPolicy: fetchPolicy,
      )
          .listen(
            (dashboard) {
          debugPrint("🟢 API SUCCESS: Dynamic Grid data updated.");
          emit(state.copyWith(
            status: StatisticsStatus.success,
            dashboard: dashboard,
          ));
        },
        onError: (Object error) {
          debugPrint("🔴 API ERROR from Repository: $error");
          emit(state.copyWith(
            status: StatisticsStatus.failure,
            errorMessage: error.toString(),
          ));
        },
      );
    } catch (e) {
      debugPrint("🔴 CUBIT CRASH: $e");
      emit(state.copyWith(
        status: StatisticsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _weeklySubscription?.cancel();
    return super.close();
  }
}