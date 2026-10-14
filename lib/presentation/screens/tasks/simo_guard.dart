import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';
import 'package:simo_learn/presentation/widgets/re_toast.dart';

/// Whether the screen is on; null when the platform cannot tell.
typedef ScreenCheck = Future<bool?> Function();

/// SimoGuard keeps study time honest: while it is on, leaving the app with a
/// task timer running pauses that timer. Locking the phone is not leaving:
/// the timer keeps going. Off by default; the choice is kept on the device.
class SimoGuard extends ChangeNotifier with WidgetsBindingObserver {
  SimoGuard._(this._timer, this._isScreenOn);

  static final SimoGuard instance =
      SimoGuard._(TaskTimerService.instance, _askPlatform);

  /// A guard of its own, for tests.
  @visibleForTesting
  factory SimoGuard.test(TaskTimerService timer, {ScreenCheck? isScreenOn}) =>
      SimoGuard._(timer, isScreenOn ?? () async => true);

  static const _key = 'simo_guard_enabled';

  static const _screen = MethodChannel('app.ravi.saimo/screen');

  /// Answered natively on Android (see MainActivity); elsewhere unknown.
  static Future<bool?> _askPlatform() async {
    try {
      return await _screen.invokeMethod<bool>('isScreenOn');
    } catch (_) {
      return null;
    }
  }

  final TaskTimerService _timer;
  final ScreenCheck _isScreenOn;
  bool _enabled = false;
  bool _attached = false;

  /// True once the user picked a value, so a late restore cannot undo it.
  bool _chosen = false;

  /// Set when the guard paused the timer, until the user is back.
  bool _pausedTimer = false;

  final StreamController<void> _pauses = StreamController<void>.broadcast();

  bool get enabled => _enabled;

  /// Fires when the user returns to the app after the guard paused the
  /// timer, so they can be told why it stopped.
  Stream<void> get pausedWhileAway => _pauses.stream;

  /// Starts watching the app's lifecycle and restores the saved choice.
  /// Safe to call more than once.
  Future<void> attach() async {
    if (_attached) return;
    _attached = true;
    WidgetsBinding.instance.addObserver(this);
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(_key);
      if (saved == null || _chosen) return;
      _enabled = saved;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setEnabled(bool value) async {
    _chosen = true;
    if (_enabled == value) return;
    _enabled = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, value);
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      // The app went to the background. A pulled-down notification shade
      // only makes it inactive and is let be.
      case AppLifecycleState.paused:
        unawaited(_leftForeground());
      // The app is closing.
      case AppLifecycleState.detached:
        if (!_enabled || !_timer.isRunning) return;
        unawaited(_timer.pause());
      case AppLifecycleState.resumed:
        if (!_pausedTimer) return;
        _pausedTimer = false;
        if (!_pauses.isClosed) _pauses.add(null);
      default:
    }
  }

  Future<void> _leftForeground() async {
    if (!_enabled || !_timer.isRunning) return;
    // A screen that went off means the phone was locked with the app still
    // open, so the user is still studying. Where the platform cannot tell,
    // the timer is left running too: stopping someone who only locked their
    // phone is the worse mistake.
    if (await _isScreenOn() != true) return;
    if (!_enabled || !_timer.isRunning) return;
    _pausedTimer = true;
    await _timer.pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pauses.close();
    super.dispose();
  }
}

/// Starts [SimoGuard] and tells the user, on whatever screen they come back
/// to, that it paused their timer. Lives above every route; draws nothing.
class SimoGuardNotice extends StatefulWidget {
  const SimoGuardNotice({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<SimoGuardNotice> createState() => _SimoGuardNoticeState();
}

class _SimoGuardNoticeState extends State<SimoGuardNotice> {
  StreamSubscription<void>? _subscription;

  @override
  void initState() {
    super.initState();
    unawaited(SimoGuard.instance.attach());
    _subscription = SimoGuard.instance.pausedWhileAway.listen((_) {
      final overlayContext = widget.navigatorKey.currentState?.overlay?.context;
      if (overlayContext == null || !overlayContext.mounted) return;
      showReToast(
        overlayContext,
        'سایموگارد تایمر را متوقف کرد، چون از برنامه خارج شدید.',
        ReToastType.info,
      );
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
