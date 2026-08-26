import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import 'package:simo_learn/features/statistics/statistics_repository.dart';

import 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit(this._repository)
      : super(
    StatisticsState(
      range: StatisticsRange.forPeriod(
        StatisticsPeriod.week,
      ),
    ),
  );

  final StatisticsRepository _repository;

  Future<void> load() async {
    if (isClosed) return;

    debugPrint('[StatisticsCubit] load()');

    final weekRange = StatisticsRange.forPeriod(
      StatisticsPeriod.week,
    );

    emit(
      state.copyWith(
        status: StatisticsStatus.loading,
        period: StatisticsPeriod.week,
        range: weekRange,
        clearDashboard: true,
        clearWeeklyDashboard: true,
        clearError: true,
      ),
    );

    try {
      /*
       * IMPORTANT:
       *
       * Initial screen state is "This Week".
       *
       * Previously we made TWO identical requests here:
       *
       *   _subscribeWeekly()
       *   _subscribe(...)
       *
       * That caused two simultaneous StatisticsDashboard requests.
       *
       * We now make ONE request and use its result for BOTH:
       *
       *   dashboard
       *   weeklyDashboard
       */
      final dashboard = await _repository.fetchDashboard(
        start: weekRange.start,
        end: weekRange.end,
        previousStart: weekRange.previousStart,
        previousEnd: weekRange.previousEnd,
      );

      if (isClosed) return;

      emit(
        state.copyWith(
          status: StatisticsStatus.success,
          dashboard: dashboard,
          weeklyDashboard: dashboard,
          clearError: true,
        ),
      );

      debugPrint(
        '[StatisticsCubit] initial weekly request succeeded',
      );
    } catch (error, stackTrace) {
      if (isClosed) return;

      debugPrint(
        '[StatisticsCubit] initial request failed: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status: StatisticsStatus.failure,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> changePeriod(
      StatisticsPeriod period,
      ) async {
    if (isClosed) return;

    debugPrint(
      '[StatisticsCubit] changePeriod(${period.name})',
    );

    final newRange = StatisticsRange.forPeriod(
      period,
    );

    await _loadDynamicDashboard(
      period: period,
      range: newRange,
    );
  }

  Future<void> selectDay(
      Jalali day,
      ) async {
    if (isClosed) return;

    final range = StatisticsRange.forPeriod(
      state.period,
      anchor: day,
    );

    await _loadDynamicDashboard(
      period: state.period,
      range: range,
    );
  }

  Future<void> selectDateRange(
      Jalali start,
      Jalali end,
      ) async {
    if (isClosed) return;

    try {
      final range = StatisticsRange.custom(
        start,
        end,
      );

      await _loadDynamicDashboard(
        period: state.period,
        range: range,
      );
    } catch (error, stackTrace) {
      if (isClosed) return;

      debugPrint(
        '[StatisticsCubit] selectDateRange failed: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status: StatisticsStatus.failure,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> refresh() async {
    if (isClosed) return;

    debugPrint('[StatisticsCubit] refresh()');

    /*
     * Refresh the current dynamic period.
     *
     * If the current period is "week", this ONE response is also
     * the weekly chart response.
     */
    final currentRange = state.range;

    try {
      emit(
        state.copyWith(
          status: StatisticsStatus.loading,
          clearError: true,
        ),
      );

      final dashboard = await _fetchWithRetry(
        start: currentRange.start,
        end: currentRange.end,
        previousStart: currentRange.previousStart,
        previousEnd: currentRange.previousEnd,
      );

      if (isClosed) return;

      if (state.period == StatisticsPeriod.week) {
        emit(
          state.copyWith(
            status: StatisticsStatus.success,
            dashboard: dashboard,
            weeklyDashboard: dashboard,
            clearError: true,
          ),
        );

        return;
      }

      /*
       * For Today / Month:
       *
       * Dynamic grid = selected period
       * Charts        = this week
       */
      final weekRange = StatisticsRange.forPeriod(
        StatisticsPeriod.week,
      );

      final weeklyDashboard = await _fetchWithRetry(
        start: weekRange.start,
        end: weekRange.end,
        previousStart: weekRange.previousStart,
        previousEnd: weekRange.previousEnd,
      );

      if (isClosed) return;

      emit(
        state.copyWith(
          status: StatisticsStatus.success,
          dashboard: dashboard,
          weeklyDashboard: weeklyDashboard,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      if (isClosed) return;

      debugPrint(
        '[StatisticsCubit] refresh failed: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status: StatisticsStatus.failure,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> _loadDynamicDashboard({
    required StatisticsPeriod period,
    required StatisticsRange range,
  }) async {
    if (isClosed) return;

    emit(
      state.copyWith(
        status: StatisticsStatus.loading,
        period: period,
        range: range,
        clearDashboard: true,
        clearError: true,

        /*
         * IMPORTANT:
         *
         * Do NOT clear weeklyDashboard.
         *
         * The charts always represent the current week.
         */
        clearWeeklyDashboard: false,
      ),
    );

    try {
      final dashboard = await _fetchWithRetry(
        start: range.start,
        end: range.end,
        previousStart: range.previousStart,
        previousEnd: range.previousEnd,
      );

      if (isClosed) return;

      emit(
        state.copyWith(
          status: StatisticsStatus.success,
          dashboard: dashboard,
          clearError: true,
        ),
      );

      debugPrint(
        '[StatisticsCubit] dynamic request succeeded',
      );
    } catch (error, stackTrace) {
      if (isClosed) return;

      debugPrint(
        '[StatisticsCubit] dynamic request failed: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          status: StatisticsStatus.failure,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<StatisticsDashboard> _fetchWithRetry({
    required DateTime start,
    required DateTime end,
    required DateTime previousStart,
    required DateTime previousEnd,
  }) async {
    try {
      return await _repository.fetchDashboard(
        start: start,
        end: end,
        previousStart: previousStart,
        previousEnd: previousEnd,
      );
    } catch (error) {
      /*
       * "internal system error" is a server-side GraphQL error.
       *
       * A single retry is useful for transient backend failures.
       *
       * We deliberately do NOT retry indefinitely.
       */
      if (!_isRetryableServerError(error)) {
        rethrow;
      }

      debugPrint(
        '[StatisticsCubit] transient server error, retrying once...',
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 500),
      );

      return _repository.fetchDashboard(
        start: start,
        end: end,
        previousStart: previousStart,
        previousEnd: previousEnd,
      );
    }
  }

  bool _isRetryableServerError(Object error) {
    final message = error.toString().toLowerCase();

    return message.contains('internal system error') ||
        message.contains('internal server error') ||
        message.contains('temporarily unavailable') ||
        message.contains('timeout') ||
        message.contains('timed out');
  }

  String _friendlyError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('unauthorized') ||
        message.contains('unauthenticated') ||
        message.contains('invalid token') ||
        message.contains('expired token') ||
        message.contains('token expired')) {
      return 'نشست کاربری شما منقضی شده است. لطفاً دوباره وارد شوید.';
    }

    if (message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('connection')) {
      return 'خطا در ارتباط با سرور. اتصال اینترنت را بررسی کنید.';
    }

    if (message.contains('internal system error') ||
        message.contains('internal server error')) {
      return 'سرور در حال حاضر نتوانست اطلاعات آمار را دریافت کند. لطفاً دوباره تلاش کنید.';
    }

    return 'دریافت اطلاعات آمار با مشکل مواجه شد.';
  }

  @override
  Future<void> close() {
    return super.close();
  }
}