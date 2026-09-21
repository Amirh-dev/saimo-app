import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

const String _channelId = 'task_reminders_channel';
const String _channelName = 'یادآوری تسک‌ها';
const String _channelDescription = 'یادآوری زمان انجام تسک‌ها';

/// Time of day used when a task has no explicit time (timed tasks).
const TimeOfDay kDefaultReminderTime = TimeOfDay(hour: 9, minute: 0);

/// Weekday codes used by the API mapped to [DateTime.weekday] values.
const Map<String, int> _weekdayNumbers = {
  'MON': DateTime.monday,
  'TUE': DateTime.tuesday,
  'WED': DateTime.wednesday,
  'THU': DateTime.thursday,
  'FRI': DateTime.friday,
  'SAT': DateTime.saturday,
  'SUN': DateTime.sunday,
};

/// Schedules and cancels local task reminders. Independent from the FCM
/// [NotificationService] so reminders work without Firebase.
///
/// Every task owns a block of 8 notification ids derived from its id: slot 0
/// for a one-off (date) reminder and slots 1..7 for weekly reminders, so
/// [cancel] can remove everything belonging to a task without bookkeeping.
class TaskReminderService {
  TaskReminderService._();

  static final TaskReminderService instance = TaskReminderService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  Future<bool>? _ready;

  Future<bool> _ensureReady() => _ready ??= _init();

  Future<bool> _init() async {
    if (kIsWeb) return false;
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(_deviceLocation());

      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/launcher_icon'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: _channelDescription,
              importance: Importance.high,
            ),
          );
      return true;
    } catch (error) {
      _log('init failed: $error');
      return false;
    }
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

  Future<bool> requestPermission() async {
    if (!await _ensureReady()) return false;
    final android = await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    final ios = await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return android ?? ios ?? true;
  }

  int _baseId(String taskId) => (taskId.hashCode & 0x0fffffff) * 8;

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_stat_notification',
        ),
        iOS: DarwinNotificationDetails(),
      );

  /// Schedules a one-off reminder at [when] (device local time). Past times
  /// are ignored.
  Future<void> scheduleOnce({
    required String taskId,
    required String title,
    required DateTime when,
  }) async {
    await cancel(taskId);
    if (!when.isAfter(DateTime.now())) return;
    if (!await requestPermission()) return;

    await _plugin.zonedSchedule(
      _baseId(taskId),
      'یادآوری تسک',
      title,
      tz.TZDateTime.from(when, tz.local),
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: taskId,
    );
  }

  /// Schedules a reminder repeating every week on each of [weekdays]
  /// (`MON`..`SUN`) at [time].
  Future<void> scheduleWeekly({
    required String taskId,
    required String title,
    required Iterable<String> weekdays,
    TimeOfDay time = kDefaultReminderTime,
  }) async {
    await cancel(taskId);
    if (!await requestPermission()) return;

    final base = _baseId(taskId);
    var slot = 1;
    for (final code in weekdays) {
      final weekday = _weekdayNumbers[code];
      if (weekday == null || slot > 7) continue;

      await _plugin.zonedSchedule(
        base + slot++,
        'یادآوری تسک',
        title,
        _nextWeekday(weekday, time),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: taskId,
      );
    }
  }

  tz.TZDateTime _nextWeekday(int weekday, TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var date = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    while (date.weekday != weekday || !date.isAfter(now)) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  /// Removes every pending reminder that belongs to [taskId]. Call when the
  /// task is completed or deleted.
  Future<void> cancel(String taskId) async {
    if (!await _ensureReady()) return;
    final base = _baseId(taskId);
    for (var slot = 0; slot < 8; slot++) {
      await _plugin.cancel(base + slot);
    }
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[TaskReminders] $message');
  }
}
