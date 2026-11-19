import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../graphql/graphql_repository.dart';
import 'notification_service.dart';

/// Old reminder channel (a plain notification). Kept only so it can be
/// deleted; Android never lets an app change a channel's sound.
const String _legacyChannelId = 'task_reminders_channel';

const String _channelId = 'task_alarms_channel';
const String _channelName = 'آلارم تسک‌ها';
const String _channelDescription = 'زنگ زدن سر ساعت یادآوری تسک‌ها';

/// The ringing tone: the phone's own alarm sound.
const _alarmSound = UriAndroidNotificationSound('content://settings/system/alarm_alert');

/// `Notification.FLAG_INSISTENT`: the sound repeats until the alarm is
/// answered or [_ringFor] runs out.
const int _flagInsistent = 4;

/// How long an unanswered alarm keeps ringing.
const Duration _ringFor = Duration(minutes: 2);

/// Payload `type` of a task alarm; routes a tap to the alarm page.
const String kPushTypeTaskAlarm = 'TASK_ALARM';

/// Notification button ids.
const String kAlarmActionStart = 'alarm_start';
const String kAlarmActionSnooze = 'alarm_snooze';

/// Time of day used when a task has no explicit reminder time.
const TimeOfDay kDefaultReminderTime = TimeOfDay(hour: 9, minute: 0);

/// How far ahead the phone keeps alarms; reopening the app moves it on.
const Duration _horizon = Duration(days: 14);

const Duration snoozeDuration = Duration(minutes: 10);

/// What a ringing alarm is about; travels inside the notification payload.
class TaskAlarm {
  const TaskAlarm({
    required this.taskId,
    required this.title,
    required this.at,
    this.tagName,
    this.minutes,
    this.timed = false,
  });

  final String taskId;
  final String title;
  final DateTime at;
  final String? tagName;
  final int? minutes;
  final bool timed;

  Map<String, String> toData() => {
        'type': kPushTypeTaskAlarm,
        'taskId': taskId,
        'title': title,
        'at': at.toIso8601String(),
        if (tagName != null) 'tag': tagName!,
        if (minutes != null) 'minutes': '$minutes',
        'timed': timed ? '1' : '0',
      };

  static TaskAlarm? fromData(Map<String, String> data) {
    if (data['type'] != kPushTypeTaskAlarm) return null;
    final taskId = data['taskId'];
    if (taskId == null || taskId.isEmpty) return null;
    return TaskAlarm(
      taskId: taskId,
      title: data['title'] ?? '',
      at: DateTime.tryParse(data['at'] ?? '') ?? DateTime.now(),
      tagName: data['tag'],
      minutes: int.tryParse(data['minutes'] ?? ''),
      timed: data['timed'] == '1',
    );
  }

  TaskAlarm movedTo(DateTime when) => TaskAlarm(
        taskId: taskId,
        title: title,
        at: when,
        tagName: tagName,
        minutes: minutes,
        timed: timed,
      );

  /// The alarm described by a `taskSchedule` row, or null when the task
  /// should not ring (no reminder, finished, running or already past).
  static TaskAlarm? fromTask(Map<String, dynamic> task, DateTime now) {
    final id = task['id'] as String?;
    if (id == null || task['hasReminder'] != true) return null;
    final status = task['status'] as String?;
    if (status != 'TODO' && status != 'PAUSED') return null;

    final date = DateTime.tryParse(task['date'] as String? ?? '')?.toLocal();
    var at = DateTime.tryParse(task['reminderTime'] as String? ?? '')?.toLocal();
    if (at == null && date != null) {
      // A rule saved before reminders had a time.
      at = DateTime(date.year, date.month, date.day, kDefaultReminderTime.hour,
          kDefaultReminderTime.minute);
    }
    if (at == null || !at.isAfter(now)) return null;

    final tags = (task['tags'] as List?)?.whereType<Map>() ?? const <Map>[];
    final minutes = task['durationM'] as int?;
    return TaskAlarm(
      taskId: id,
      title: task['title'] as String? ?? '',
      at: at,
      tagName: tags.isEmpty ? null : tags.first['name'] as String?,
      minutes: minutes,
      timed: task['type'] == 'TIMED',
    );
  }
}

/// Rings task reminders like an alarm clock: at the exact minute, with the
/// alarm sound repeating, over the lock screen. Alarms are local, built from
/// the server's schedule by [sync], so tasks a counselor planned and a new
/// phone ring too.
///
/// Every task owns a block of 8 notification ids derived from its id: slot 0
/// rings at the reminder time and slot 1 is a snooze.
class TaskReminderService {
  TaskReminderService._();

  static final TaskReminderService instance = TaskReminderService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  Future<bool>? _ready;
  GraphQLRepository? _repository;
  Future<void>? _syncing;
  bool _syncAgain = false;

  static const _lockChannel = MethodChannel('app.ravi.saimo/alarm');

  Future<bool> _ensureReady() => _ready ??= _init();

  Future<bool> _init() async {
    if (kIsWeb) return false;
    try {
      _initTimeZone();
      // The plugin is shared with chat notifications; initializing it again
      // here would replace the tap handler chat relies on.
      if (!await NotificationService.instance.ensureLocalNotificationsReady()) {
        return false;
      }
      await _createChannel(_plugin);
      return true;
    } catch (error) {
      _log('init failed: $error');
      return false;
    }
  }

  /// Sets where alarms are loaded from; called on login.
  void attach(GraphQLRepository repository) => _repository = repository;

  /// Forgets the account on logout and silences its alarms.
  Future<void> detach() async {
    _repository = null;
    if (!await _ensureReady()) return;
    for (final request in await _plugin.pendingNotificationRequests()) {
      if (_isTaskReminder(request.payload)) await _plugin.cancel(request.id);
    }
  }

  // ---------------------------------------------------------------- permissions

  /// Notification permission only (the prompt every reminder needs).
  Future<bool> requestPermission() async {
    if (!await _ensureReady()) return false;
    final android = await _android?.requestNotificationsPermission();
    final ios = await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return android ?? ios ?? true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  /// Whether alarms ring at the exact minute (Android's «آلارم‌ها و
  /// یادآوری‌ها» access). Without it they still ring, but late.
  Future<bool> canRingOnTime() async {
    if (!await _ensureReady()) return false;
    return await _android?.canScheduleExactNotifications() ?? true;
  }

  /// Opens the system page that grants exact alarms.
  Future<void> requestRingOnTime() async {
    if (!await _ensureReady()) return;
    await _android?.requestExactAlarmsPermission();
  }

  /// Asks for the full-screen page over the lock screen (Android 14+ lets
  /// the user turn it off).
  Future<void> requestFullScreen() async {
    if (!await _ensureReady()) return;
    try {
      await _android?.requestFullScreenIntentPermission();
    } catch (error) {
      _log('full screen permission failed: $error');
    }
  }

  // ------------------------------------------------------------------ syncing

  /// Rebuilds the phone's alarms from the server's next two weeks. Offline,
  /// the alarms already set stay as they are.
  Future<void> sync() {
    final running = _syncing;
    if (running != null) {
      _syncAgain = true;
      return running;
    }
    return _syncing = () async {
      try {
        do {
          _syncAgain = false;
          await _syncOnce();
        } while (_syncAgain);
      } finally {
        _syncing = null;
      }
    }();
  }

  static const String _scheduleQuery = r'''
query TaskAlarms($input: TaskScheduleInput!) {
  taskSchedule(input: $input) {
    id title type durationM status date hasReminder reminderTime
    tags { name }
  }
}
''';

  Future<void> _syncOnce() async {
    final repository = _repository;
    if (repository == null || !await _ensureReady()) return;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final List rows;
    try {
      final data = await repository.rawRequest(
        query: _scheduleQuery,
        variables: {
          'input': {
            'start': _rfc3339(start),
            'end': _rfc3339(start.add(_horizon)),
            'limit': 500,
          },
        },
      );
      rows = (data['taskSchedule'] as List?) ?? const [];
    } catch (error) {
      _log('sync failed: $error');
      return;
    }

    final wanted = <int, TaskAlarm>{};
    for (final row in rows.whereType<Map<String, dynamic>>()) {
      final alarm = TaskAlarm.fromTask(row, now);
      if (alarm != null) wanted[_baseId(alarm.taskId)] = alarm;
    }

    try {
      for (final request in await _plugin.pendingNotificationRequests()) {
        final data = _decode(request.payload);
        final isAlarm = data?['type'] == kPushTypeTaskAlarm;
        final isSnooze = isAlarm && request.id % 8 == 1;
        // Reminders from older builds (bare task id payloads, weekly slots)
        // are replaced by the alarms below.
        if (!isAlarm && _isTaskReminder(request.payload)) {
          await _plugin.cancel(request.id);
        } else if (isAlarm && !isSnooze && !wanted.containsKey(request.id)) {
          await _plugin.cancel(request.id);
        }
      }
      final exact = await canRingOnTime();
      for (final entry in wanted.entries) {
        await _schedule(entry.key, entry.value, exact: exact);
      }
    } catch (error) {
      _log('scheduling failed: $error');
    }
  }

  // ------------------------------------------------------------------ ringing

  int _baseId(String taskId) => (taskId.hashCode & 0x0fffffff) * 8;

  Future<void> _schedule(int id, TaskAlarm alarm, {required bool exact}) =>
      _plugin.zonedSchedule(
        id,
        'وقت ${alarm.timed ? 'تایمر' : 'تسک'}ه!',
        alarm.title,
        tz.TZDateTime.from(alarm.at, tz.local),
        _details,
        androidScheduleMode: exact
            ? AndroidScheduleMode.alarmClock
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: jsonEncode(alarm.toData()),
      );

  /// Rings once at [when], for a task just saved. [sync] later replaces it
  /// with the server's view under the same id.
  Future<void> scheduleOnce({
    required String taskId,
    required String title,
    required DateTime when,
    String? tagName,
    int? minutes,
    bool timed = false,
  }) async {
    await cancel(taskId);
    if (!when.isAfter(DateTime.now())) return;
    if (!await requestPermission()) return;
    try {
      await _schedule(
        _baseId(taskId),
        TaskAlarm(
          taskId: taskId,
          title: title,
          at: when,
          tagName: tagName,
          minutes: minutes,
          timed: timed,
        ),
        exact: await canRingOnTime(),
      );
    } catch (error) {
      _log('scheduleOnce failed: $error');
    }
  }

  /// Rings again [snoozeDuration] from now.
  Future<void> snooze(TaskAlarm alarm) async {
    if (!await _ensureReady()) return;
    await _plugin.cancel(_baseId(alarm.taskId));
    try {
      await _schedule(
        _baseId(alarm.taskId) + 1,
        alarm.movedTo(DateTime.now().add(snoozeDuration)),
        exact: await canRingOnTime(),
      );
    } catch (error) {
      _log('snooze failed: $error');
    }
  }

  /// Stops the ringing of [taskId]'s alarm, keeping any snooze.
  Future<void> silence(String taskId) async {
    if (!await _ensureReady()) return;
    try {
      await _plugin.cancel(_baseId(taskId));
      await _plugin.cancel(_baseId(taskId) + 1);
    } catch (error) {
      _log('silence failed: $error');
    }
  }

  /// Removes every alarm that belongs to [taskId]. Call when the task is
  /// completed or deleted.
  Future<void> cancel(String taskId) async {
    if (!await _ensureReady()) return;
    final base = _baseId(taskId);
    try {
      for (var slot = 0; slot < 8; slot++) {
        await _plugin.cancel(base + slot);
      }
    } catch (error) {
      // Reminders are best-effort; a native failure must never break the
      // task action (complete/delete) that triggered the cancel.
      _log('cancel failed: $error');
    }
  }

  /// The alarm page opened over the lock screen; once it closes the phone
  /// locks again as before.
  Future<void> releaseLockScreen() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _lockChannel.invokeMethod<void>('release');
    } catch (_) {}
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[TaskAlarms] $message');
  }
}

NotificationDetails get _details => NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
        sound: _alarmSound,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 800, 600, 800, 600]),
        additionalFlags: Int32List.fromList([_flagInsistent]),
        ongoing: true,
        autoCancel: false,
        timeoutAfter: _ringFor.inMilliseconds,
        icon: '@drawable/ic_stat_notification',
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            kAlarmActionStart,
            'شروع',
            showsUserInterface: true,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            kAlarmActionSnooze,
            '${snoozeDuration.inMinutes} دقیقه بعد',
            cancelNotification: true,
          ),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );

Future<void> _createChannel(FlutterLocalNotificationsPlugin plugin) async {
  final android = plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await android?.deleteNotificationChannel(_legacyChannelId);
  await android?.createNotificationChannel(
    AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      sound: _alarmSound,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 800, 600, 800, 600]),
    ),
  );
}

bool _tzReady = false;

void _initTimeZone() {
  if (_tzReady) return;
  tzdata.initializeTimeZones();
  tz.setLocalLocation(_deviceLocation());
  _tzReady = true;
}

/// Best-effort device time zone without a native plugin: prefers Tehran,
/// otherwise the first zone whose current offset matches the device's.
tz.Location _deviceLocation() {
  final offset = DateTime.now().timeZoneOffset;
  final now = DateTime.now().millisecondsSinceEpoch;
  final tehran = tz.getLocation('Asia/Tehran');
  if (Duration(milliseconds: tehran.timeZone(now).offset) == offset) return tehran;
  for (final location in tz.timeZoneDatabase.locations.values) {
    if (Duration(milliseconds: location.timeZone(now).offset) == offset) return location;
  }
  return tz.UTC;
}

Map<String, String>? _decode(String? payload) {
  if (payload == null || payload.isEmpty) return null;
  try {
    final data = jsonDecode(payload);
    if (data is! Map) return null;
    return data.map((key, value) => MapEntry('$key', '$value'));
  } catch (_) {
    return null;
  }
}

/// Task reminders are the alarms plus older builds' reminders, whose payload
/// was a bare task id (not JSON).
bool _isTaskReminder(String? payload) {
  final data = _decode(payload);
  if (data != null) return data['type'] == kPushTypeTaskAlarm;
  return payload != null && payload.isNotEmpty;
}

String _rfc3339(DateTime value) {
  final offset = value.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final hours = offset.inHours.abs().toString().padLeft(2, '0');
  final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
  final local = value.toIso8601String().split('.').first;
  return '$local$sign$hours:$minutes';
}

/// A button on the alarm notification pressed while the app was not
/// running: «۱۰ دقیقه بعد» schedules the next ring from here.
@pragma('vm:entry-point')
Future<void> taskAlarmBackgroundResponse(NotificationResponse response) async {
  if (response.actionId != kAlarmActionSnooze) return;
  final data = _decode(response.payload);
  final alarm = data == null ? null : TaskAlarm.fromData(data);
  if (alarm == null) return;
  WidgetsFlutterBinding.ensureInitialized();
  _initTimeZone();
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
    ),
  );
  final base = (alarm.taskId.hashCode & 0x0fffffff) * 8;
  await plugin.cancel(base);
  final exact = await plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.canScheduleExactNotifications() ??
      false;
  await plugin.zonedSchedule(
    base + 1,
    'وقت ${alarm.timed ? 'تایمر' : 'تسک'}ه!',
    alarm.title,
    tz.TZDateTime.from(DateTime.now().add(snoozeDuration), tz.local),
    _details,
    androidScheduleMode:
        exact ? AndroidScheduleMode.alarmClock : AndroidScheduleMode.inexactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    payload: jsonEncode(alarm.movedTo(DateTime.now().add(snoozeDuration)).toData()),
  );
}
