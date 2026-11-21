import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:vibration/vibration.dart';

import '../../presentation/screens/tasks/task_timer_service.dart';
import '../../utils/colors.dart';
import 'notification_service.dart';
import 'timer_end_platform.dart';
import 'timer_end_web.dart';

export 'timer_end_platform.dart';

/// Payload `type` of the timer-end notice; a tap opens the tasks tab.
const String kPushTypeTimerEnd = 'TIMER_END';

const String _channelId = 'timer_end_channel';
const String _channelName = 'پایان تایمر';
const String _channelDescription = 'یه صدای کوتاه وقتی تایمر تسک تموم می‌شه';

/// `res/raw/timer_end.wav`, the same tune the app plays while open.
const _sound = RawResourceAndroidNotificationSound('timer_end');

/// One notice at a time, so one fixed id. Negative: task alarms use
/// non-negative ids.
const int _noticeId = -7301;

/// A time-up noticed later than this already rang as a notification.
const Duration _chimeWindow = Duration(seconds: 3);

/// Tells the student a timed task's timer ran out.
///
/// While the app is open, the timer page already shows it: only the chime
/// plays. When the app goes to the background with a timer running, a
/// notification is scheduled for the end time (the app may be asleep or
/// gone by then) and taken back when the app comes forward again.
class TimerEndNotice with WidgetsBindingObserver {
  @visibleForTesting
  TimerEndNotice(this._timer, this._platform);

  static final TimerEndNotice instance = TimerEndNotice(
    TaskTimerService.instance,
    kIsWeb ? createWebTimerEndPlatform() : _PluginTimerEndPlatform(),
  );

  final TaskTimerService _timer;
  final TimerEndPlatform _platform;

  bool _attached = false;
  bool _foreground = true;
  bool _wasRunning = false;
  StreamSubscription<Duration>? _timeUp;

  /// The notice now on the phone: which task, ringing when.
  ({String taskId, DateTime at})? _scheduled;

  /// Platform calls run in order, so a quick leave-and-return never ends
  /// with the cancel overtaken by the schedule.
  Future<void> _queue = Future<void>.value();

  void attach() {
    if (_attached) return;
    _attached = true;
    WidgetsBinding.instance.addObserver(this);
    final state = WidgetsBinding.instance.lifecycleState;
    _foreground = state == null || state == AppLifecycleState.resumed;
    _timer.addListener(_update);
    _timeUp = _timer.timeUp.listen(_onTimeUp);
    _update();
  }

  @visibleForTesting
  void detach() {
    if (!_attached) return;
    _attached = false;
    WidgetsBinding.instance.removeObserver(this);
    _timer.removeListener(_update);
    unawaited(_timeUp?.cancel());
    _timeUp = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        setForeground(true);
      case AppLifecycleState.paused ||
            AppLifecycleState.hidden ||
            AppLifecycleState.detached:
        setForeground(false);
      case AppLifecycleState.inactive:
        // A pulled-down shade or the app switcher: still looking at the app.
        break;
    }
  }

  @visibleForTesting
  void setForeground(bool foreground) {
    if (_foreground == foreground) return;
    _foreground = foreground;
    _update();
  }

  /// Called on every timer change (each second while it runs), so it only
  /// reaches the phone when the wanted notice differs from the one there.
  void _update() {
    // Starting is a tap: the moment a browser lets the page ask to notify.
    if (_timer.isRunning && !_wasRunning) _platform.prepare();
    _wasRunning = _timer.isRunning;

    final wanted = _wanted();
    if (wanted == _scheduled) return;
    if (wanted == null) {
      final scheduled = _scheduled;
      if (scheduled == null) return;
      // The timer ran out in the background: the notice stays, it may not
      // have shown yet. Coming forward takes it back.
      if (!_foreground &&
          _timer.isCompleted &&
          _timer.activeTaskId == scheduled.taskId) {
        return;
      }
      _scheduled = null;
      _run(_platform.cancel);
      return;
    }
    _scheduled = wanted;
    final body = timerEndBody(
      minutes: (_timer.totalSeconds / 60).round(),
      taskTitle: _timer.taskTitle,
    );
    _run(() => _platform.schedule(wanted.at, timerEndTitle, body));
  }

  ({String taskId, DateTime at})? _wanted() {
    if (_foreground) return null;
    final taskId = _timer.activeTaskId;
    final at = _timer.endsAt;
    if (taskId == null || at == null || !_timer.isRunning) return null;
    return (taskId: taskId, at: at);
  }

  void _onTimeUp(Duration late) {
    if (!_foreground || late > _chimeWindow) return;
    _run(_platform.chime);
  }

  void _run(Future<void> Function() action) {
    _queue = _queue.then((_) => action()).catchError((Object error) {
      debugPrint('TimerEndNotice: $error');
    });
  }
}

const String timerEndTitle = 'تسکت رو به پایان رسوندی ✅';

/// «۴۵ دقیقه · ریاضی – فصل ۳»; minutes first so its digits never touch
/// digits at the end of the title.
String timerEndBody({required int minutes, required String taskTitle}) {
  final time = '${_persianDigits('$minutes')} دقیقه';
  final title = taskTitle.trim();
  return title.isEmpty ? time : '$time · $title';
}

String _persianDigits(String text) {
  const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  return text.replaceAllMapped(
    RegExp('[0-9]'),
    (match) => persian[int.parse(match[0]!)],
  );
}

class _PluginTimerEndPlatform implements TimerEndPlatform {
  @override
  void prepare() {}

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const _chimeChannel = MethodChannel('app.ravi.saimo/chime');
  Future<bool>? _ready;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  Future<bool> _ensureReady() => _ready ??= _init();

  Future<bool> _init() async {
    if (kIsWeb) return false;
    // The plugin is shared with chat; initializing it again here would
    // replace the tap handler.
    if (!await NotificationService.instance.ensureLocalNotificationsReady()) {
      return false;
    }
    await _android?.createNotificationChannel(
      AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        sound: _sound,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 250, 150, 250]),
      ),
    );
    return true;
  }

  @override
  Future<void> schedule(DateTime at, String title, String body) async {
    if (!await _ensureReady()) return;
    final exact = await _android?.canScheduleExactNotifications() ?? true;
    await _plugin.zonedSchedule(
      _noticeId,
      title,
      body,
      tz.TZDateTime.from(at, tz.UTC),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          sound: _sound,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 250, 150, 250]),
          icon: '@drawable/ic_stat_notification',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
          color: AppColors.primary,
          autoCancel: true,
        ),
        iOS: const DarwinNotificationDetails(presentSound: true),
      ),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode({'type': kPushTypeTimerEnd}),
    );
  }

  @override
  Future<void> cancel() async {
    if (!await _ensureReady()) return;
    await _plugin.cancel(_noticeId);
  }

  @override
  Future<void> chime() async {
    if (kIsWeb) return;
    try {
      await _chimeChannel.invokeMethod<void>('play');
    } on MissingPluginException {
      // Not built for this platform (iOS): the vibration alone.
    }
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(pattern: [0, 250, 150, 250]);
    }
  }
}
