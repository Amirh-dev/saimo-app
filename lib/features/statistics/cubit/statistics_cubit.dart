import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'package:simo_learn/features/statistics/statistics_repository.dart';

import 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit(this._repository)
      : super(
          StatisticsState(
            range: StatisticsRange.forPeriod(StatisticsPeriod.week),
          ),
        );

  final StatisticsRepository _repository;

  /// Bumped by every fetch; an answer for an older one is dropped, so quick
  /// taps through the weeks never end on the wrong week's numbers.
  int _request = 0;

  /// First open of the screen. Numbers already on screen are only refreshed.
  Future<void> load() =>
      state.hasData ? refresh(quiet: true) : _fetch(state.range);

  Future<void> selectPeriod(StatisticsPeriod period) =>
      _show(StatisticsRange.forPeriod(period));

  Future<void> selectDateRange(Jalali start, Jalali end) =>
      _show(StatisticsRange.custom(start, end));

  /// One day, week, month or custom length back (-1) or forward (1).
  Future<void> shift(int direction) {
    if (direction > 0 && !state.range.canGoNext) return Future.value();
    return _show(state.range.shift(direction), direction: direction.sign);
  }

  /// Back to the running day, week or month.
  Future<void> goToCurrent() {
    final period = state.range.period == StatisticsPeriod.custom
        ? StatisticsPeriod.week
        : state.range.period;
    return _show(StatisticsRange.forPeriod(period), direction: 1);
  }

  /// Fetches the shown range again after it failed to load.
  Future<void> retry() => _fetch(state.range);

  /// Re-fetches the shown range, keeping it on screen meanwhile. [quiet]
  /// also keeps it when the fetch fails, for a refresh nobody asked for.
  Future<void> refresh({bool quiet = false}) async {
    if (isClosed) return;
    // Nothing shown yet, or a load already on its way: a quiet refresh has
    // nothing to keep fresh.
    if (quiet && (!state.hasData || state.isLoading)) return;
    await _fetch(state.range, quiet: quiet);
  }

  Future<void> _show(StatisticsRange range, {int direction = 0}) {
    if (isClosed) return Future.value();
    if (range == state.range && state.hasData && !state.isStale) {
      return Future.value();
    }
    emit(state.copyWith(range: range, direction: direction));
    return _fetch(range);
  }

  Future<void> _fetch(StatisticsRange range, {bool quiet = false}) async {
    if (isClosed) return;
    final request = ++_request;
    emit(state.copyWith(status: StatisticsStatus.loading, clearError: true));

    try {
      final chartRange = range.chartRange;
      final results = await Future.wait([
        _fetchWithRetry(range),
        // A single day is charted within its week, which needs its own ask.
        if (chartRange != range) _fetchWithRetry(chartRange),
      ]);
      if (isClosed || request != _request) return;

      emit(
        state.copyWith(
          status: StatisticsStatus.success,
          dashboard: results.first,
          chartDashboard: results.last,
          loadedRange: range,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      if (isClosed || request != _request) return;

      debugPrint('[StatisticsCubit] fetch failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (quiet && state.hasData) {
        emit(state.copyWith(status: StatisticsStatus.success));
        return;
      }
      emit(
        state.copyWith(
          status: StatisticsStatus.failure,
          errorMessage: _friendlyError(error),
        ),
      );
    }
  }

  Future<StatisticsDashboard> _fetchWithRetry(StatisticsRange range) async {
    Future<StatisticsDashboard> fetch() => _repository.fetchDashboard(
          start: range.start,
          end: range.end,
          previousStart: range.previousStart,
          previousEnd: range.previousEnd,
        );
    try {
      return await fetch();
    } catch (error) {
      // "internal system error" is a server-side GraphQL error; one retry
      // covers a transient backend failure. Never retry indefinitely.
      if (!_isRetryableServerError(error)) rethrow;
      debugPrint('[StatisticsCubit] transient server error, retrying once...');
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return fetch();
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
}
