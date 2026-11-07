import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/data/home_widgets/home_widget_snapshot.dart';
import 'package:simo_learn/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:simo_learn/features/dashboard/cubit/dashboard_state.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';
import 'package:simo_learn/utils/jalali_text.dart';

/// Keeps the Android home-screen widgets («امروز» and «کارهای امروز») in
/// step with today's tasks and the live timer.
///
/// The widgets are drawn natively from the last snapshot handed over here;
/// they never call the server themselves.
class HomeWidgets {
  HomeWidgets._();

  static final HomeWidgets instance = HomeWidgets._();

  static const _channel = MethodChannel('app.ravi.saimo/widgets');

  StreamSubscription<DashboardState>? _subscription;
  DashboardCubit? _cubit;
  String? _sent;

  static bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Starts sending a new snapshot whenever today's tasks or the timer
  /// change. Safe to call more than once.
  void attach(DashboardCubit cubit) {
    if (!_supported || identical(_cubit, cubit)) return;
    _subscription?.cancel();
    _cubit = cubit;
    _subscription = cubit.stream.listen((_) => _sync());
    TaskTimerService.instance
      ..removeListener(_sync)
      ..addListener(_sync);
    _sync();
  }

  /// Empties the widgets, as on logout, so they never show the last
  /// account's tasks.
  Future<void> clear() async {
    if (!_supported) return;
    _sent = null;
    try {
      await _channel.invokeMethod<void>('clear');
    } catch (error) {
      debugPrint('Home widgets not cleared: $error');
    }
  }

  void _sync() {
    // Null until loaded, and again right after logout: nothing to show yet,
    // and the last snapshot stays rather than flashing an empty day.
    final tasks = _cubit?.state.tasks;
    if (tasks == null) return;
    final timer = TaskTimerService.instance;
    final now = DateTime.now();
    final snapshot = jsonEncode(homeWidgetSnapshot(
      tasks: tasks,
      timer: WidgetTimerState(
        activeTaskId: timer.activeTaskId,
        sessionStartedAt: timer.sessionStartedAt,
        solidSeconds: timer.solidSeconds,
        isCompleted: timer.isCompleted,
      ),
      now: now,
      streak: _cubit?.state.consistency,
      dateLabel: JalaliText.fullDay(Jalali.fromDateTime(now)),
    ));
    // The timer notifies every second; only a real change is sent.
    if (snapshot == _sent) return;
    _sent = snapshot;
    unawaited(_send(snapshot));
  }

  Future<void> _send(String snapshot) async {
    try {
      await _channel.invokeMethod<void>('update', snapshot);
    } catch (error) {
      _sent = null;
      debugPrint('Home widgets not updated: $error');
    }
  }
}
