import 'package:flutter_test/flutter_test.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';

/// A task as `getTasks`/`taskSchedule` return it. Noon UTC keeps the local
/// calendar day the same in any time zone the tests may run in.
Map<String, dynamic> _apiTask({
  String id = 'task-1',
  String type = 'NORMAL',
  String status = 'TODO',
  String? shortDescription,
  String? note,
  List<String> tags = const [],
  String? subject,
  int? durationM,
  int elapsedSeconds = 0,
  String? recurrenceId,
}) {
  return {
    'id': id,
    'title': 'تمرین فصل ۳',
    'shortDescription': shortDescription,
    'note': note,
    'type': type,
    'date': '2026-10-12T12:00:00Z',
    'durationM': durationM,
    'hasReminder': false,
    'reminderTime': null,
    'recurringDays': null,
    'recurrenceID': recurrenceId,
    'elapsedSeconds': elapsedSeconds,
    'timerStartedAt': null,
    'status': status,
    'goal': null,
    'tags': [
      for (final (index, name) in tags.indexed)
        {'id': 'tag-$index', 'name': name},
    ],
    'subjectTag': subject == null ? null : {'id': 'subject-1', 'name': subject},
  };
}

void main() {
  group('taskFromApi', () {
    test('maps API statuses to the screen statuses', () {
      const cases = {
        'COMPLETED': 'done',
        'IN_PROGRESS': 'running',
        'PAUSED': 'paused',
        'TODO': 'pending',
      };
      for (final entry in cases.entries) {
        expect(
          taskFromApi(_apiTask(status: entry.key))['status'],
          entry.value,
          reason: entry.key,
        );
      }
    });

    test('subtitle falls back from description to note to tags', () {
      expect(
        taskFromApi(
            _apiTask(shortDescription: 'خلاصه', note: 'یادداشت'))['subtitle'],
        'خلاصه',
      );
      expect(taskFromApi(_apiTask(note: 'یادداشت'))['subtitle'], 'یادداشت');
      expect(
        taskFromApi(_apiTask(tags: ['ریاضی', 'تست']))['subtitle'],
        'ریاضی، تست',
      );
      expect(taskFromApi(_apiTask())['subtitle'], 'توضیحی ثبت نشده');
    });

    test('places the task on its local Jalali day', () {
      final task = taskFromApi(_apiTask());
      final date = task['date'] as Jalali;
      expect([date.year, date.month, date.day], [1405, 7, 20]);
    });

    test('keeps type, subject and recurrence for planning', () {
      final task = taskFromApi(
        _apiTask(subject: 'ریاضی', recurrenceId: 'rec-1'),
      );
      expect(task['type'], 'NORMAL');
      expect(task['subject'], 'ریاضی');
      expect(task['recurrenceId'], 'rec-1');
      expect(isTimedTask(task), isFalse);
    });
  });

  group('timedTaskFromApi', () {
    test('derives duration and remaining time from the API minutes', () {
      final task = timedTaskFromApi(
        _apiTask(type: 'TIMED', durationM: 30, elapsedSeconds: 600),
      );
      expect(task['durationSeconds'], 1800);
      expect(task['remainingSeconds'], 1200);
      expect(task['label'], '۳۰ دقیقه');
      expect(isTimedTask(task), isTrue);
    });

    test('falls back to 45 minutes when the API has no duration', () {
      final task = timedTaskFromApi(_apiTask(type: 'TIMED'));
      expect(task['durationSeconds'], 45 * 60);
    });
  });

  test('plannedTaskFromApi picks the mapping from the task type', () {
    expect(
      plannedTaskFromApi(
          _apiTask(type: 'TIMED', durationM: 25))['durationSeconds'],
      1500,
    );
    expect(
      plannedTaskFromApi(_apiTask())['durationSeconds'],
      isNull,
    );
  });

  test('rfc3339Local keeps the wall-clock time with the device offset', () {
    final local = DateTime(2026, 10, 12, 9, 5);
    final formatted = rfc3339Local(local);
    expect(formatted, startsWith('2026-10-12T09:05:00'));
    expect(DateTime.parse(formatted).isAtSameMomentAs(local), isTrue);
  });
}
