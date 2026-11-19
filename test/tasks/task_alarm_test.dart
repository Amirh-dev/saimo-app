import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/data/notifications/push_destination.dart';
import 'package:simo_learn/data/notifications/task_reminder_service.dart';
import 'package:simo_learn/presentation/screens/tasks/task_alarm_screen.dart';

void main() {
  final now = DateTime(2026, 11, 19, 12);

  Map<String, dynamic> row({
    String status = 'TODO',
    bool hasReminder = true,
    String? reminderTime = '2026-11-19T16:30:00+03:30',
    String type = 'TIMED',
  }) =>
      {
        'id': 't1',
        'title': 'تست زیست',
        'type': type,
        'durationM': 45,
        'status': status,
        'date': '2026-11-19T00:00:00+03:30',
        'hasReminder': hasReminder,
        'reminderTime': reminderTime,
        'tags': [
          {'name': 'زیست‌شناسی'}
        ],
      };

  group('TaskAlarm.fromTask', () {
    test('a future reminder rings with the task details', () {
      final alarm = TaskAlarm.fromTask(row(), now)!;
      expect(alarm.taskId, 't1');
      expect(alarm.at, DateTime.parse('2026-11-19T16:30:00+03:30').toLocal());
      expect(alarm.tagName, 'زیست‌شناسی');
      expect(alarm.minutes, 45);
      expect(alarm.timed, isTrue);
    });

    test('no reminder, finished, running or past tasks do not ring', () {
      expect(TaskAlarm.fromTask(row(hasReminder: false), now), isNull);
      expect(TaskAlarm.fromTask(row(status: 'COMPLETED'), now), isNull);
      expect(TaskAlarm.fromTask(row(status: 'CANCELED'), now), isNull);
      expect(TaskAlarm.fromTask(row(status: 'IN_PROGRESS'), now), isNull);
      expect(
          TaskAlarm.fromTask(
              row(reminderTime: '2026-11-19T08:00:00+03:30'), now),
          isNull);
    });

    test('a reminder saved without a time rings at 9 on its day', () {
      final alarm = TaskAlarm.fromTask(
          row(reminderTime: null), DateTime(2026, 11, 18, 20))!;
      final day = DateTime.parse('2026-11-19T00:00:00+03:30').toLocal();
      expect(alarm.at, DateTime(day.year, day.month, day.day, 9));
    });
  });

  test('payload data round-trips and routes to the alarm page', () {
    final alarm = TaskAlarm.fromTask(row(type: 'NORMAL'), now)!;
    final data = alarm.toData();
    expect(pushDestination(data), PushDestination.taskAlarm);
    final back = TaskAlarm.fromData(data)!;
    expect(back.taskId, alarm.taskId);
    expect(back.title, alarm.title);
    expect(back.at, alarm.at);
    expect(back.timed, isFalse);
    expect(TaskAlarm.fromData({'type': 'NEW_MESSAGE'}), isNull);
  });

  test('night runs from 19:00 to 06:00', () {
    expect(TaskAlarmScreen.isNight(DateTime(2026, 1, 1, 19)), isTrue);
    expect(TaskAlarmScreen.isNight(DateTime(2026, 1, 1, 5, 59)), isTrue);
    expect(TaskAlarmScreen.isNight(DateTime(2026, 1, 1, 6)), isFalse);
    expect(TaskAlarmScreen.isNight(DateTime(2026, 1, 1, 18, 59)), isFalse);
  });

  group('alarm page', () {
    late List<String> calls;

    Future<void> pump(WidgetTester tester, {bool night = false}) async {
      calls = [];
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: TaskAlarmScreen(
          title: 'تست زیست',
          at: DateTime(2026, 11, 19, 16, 30),
          minutes: 45,
          night: night,
          animate: false,
          onStart: () => calls.add('start'),
          onSnooze: () => calls.add('snooze'),
          onDismiss: () => calls.add('dismiss'),
        ),
      ));
    }

    testWidgets('snooze and close call back', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('task-alarm-snooze')));
      await tester.tap(find.byKey(const ValueKey('task-alarm-dismiss')));
      expect(calls, ['snooze', 'dismiss']);
    });

    testWidgets('a short slide springs back, a full one starts',
        (tester) async {
      await pump(tester, night: true);
      final knob = find.byKey(const ValueKey('task-alarm-knob'));
      await tester.drag(knob, const Offset(-60, 0));
      await tester.pumpAndSettle();
      expect(calls, isEmpty);

      await tester.drag(knob, const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(calls, ['start']);
    });
  });
}
