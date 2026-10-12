import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/data/notifications/task_reminder_service.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';

/// A failure whose [message] can be shown to the user as is.
class TaskActionException implements Exception {
  const TaskActionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// What the quick-add sheet creates: a one-off task with a title and,
/// optionally, a duration (a timed task) and a subject.
class QuickTaskDraft {
  const QuickTaskDraft({
    required this.title,
    required this.day,
    this.timedMinutes,
    this.subject,
  });

  final String title;
  final Jalali day;
  final int? timedMinutes;
  final String? subject;

  bool get isTimed => timedMinutes != null;
}

/// Task operations the planning views need, as screen-ready task maps.
abstract class TasksApi {
  /// Tasks dated in `[start, end)`, without canceled occurrences.
  Future<List<Map<String, dynamic>>> fetchSchedule({
    required Jalali start,
    required Jalali end,
  });

  /// Moves the task to [day] at the same time of day. For a recurring task
  /// only this occurrence moves.
  Future<void> moveTask(Map<String, dynamic> task, Jalali day);

  Future<Map<String, dynamic>> createQuickTask(QuickTaskDraft draft);

  /// Marks the task done, or back to do when [done] is false.
  Future<void> setTaskDone(Map<String, dynamic> task, {required bool done});
}

class GraphQLTasksApi implements TasksApi {
  GraphQLTasksApi(this._repository);

  final GraphQLRepository _repository;

  TaskReminderService get _reminders => TaskReminderService.instance;

  static const int _schedulePageSize = 500;

  static const String _scheduleQuery = '''
query WeekSchedule(\$input: TaskScheduleInput!) {
  taskSchedule(input: \$input) {
$kTaskFields
  }
}
''';

  static const String _updateMutation = r'''
mutation PlanUpdateTask($id: ID!, $input: UpdateTaskInput!) {
  updateTask(id: $id, input: $input) { id }
}
''';

  static const String _createMutation = '''
mutation QuickCreateTask(\$input: CreateTaskInput!) {
  createTask(input: \$input) {
$kTaskFields
  }
}
''';

  @override
  Future<List<Map<String, dynamic>>> fetchSchedule({
    required Jalali start,
    required Jalali end,
  }) async {
    final tasks = <Map<String, dynamic>>[];
    for (var offset = 0;; offset += _schedulePageSize) {
      final data = await _repository.rawRequest(
        query: _scheduleQuery,
        variables: {
          'input': {
            'start': rfc3339Local(start.toDateTime()),
            'end': rfc3339Local(end.toDateTime()),
            'limit': _schedulePageSize,
            'offset': offset,
          },
        },
      );

      final page = (data['taskSchedule'] as List?) ?? const [];
      for (final task in page.whereType<Map<String, dynamic>>()) {
        final id = task['id'] as String?;
        // Safety net: a finished task must never keep a pending reminder.
        if (id != null && task['status'] == 'COMPLETED') {
          unawaited(_reminders.cancel(id));
        }
        if (task['status'] == 'CANCELED') continue;
        tasks.add(plannedTaskFromApi(task));
      }
      if (page.length < _schedulePageSize) return tasks;
    }
  }

  @override
  Future<void> moveTask(Map<String, dynamic> task, Jalali day) async {
    final taskId = _requireId(task);
    final target = _onDay(day, task['dateTime'] as DateTime?);

    // A one-off reminder follows its task; a recurring task's weekly
    // reminder belongs to the recurrence and stays as it is.
    final reminder = task['reminderTime'] as DateTime?;
    final movedReminder = task['recurrenceId'] == null &&
            task['reminder'] == true &&
            reminder != null
        ? _onDay(day, reminder)
        : null;

    try {
      await _updateTask(taskId, {
        'date': rfc3339Local(target),
        if (movedReminder != null) 'reminderTime': rfc3339Local(movedReminder),
      });
    } catch (error) {
      debugPrint('GraphQLTasksApi.moveTask: $error');
      throw TaskActionException(
        error.toString().contains('already has an occurrence')
            ? 'این تسک تکرارشونده برای آن روز هم برنامه‌ریزی شده است.'
            : 'جابه‌جایی تسک ناموفق بود. دوباره تلاش کنید.',
      );
    }

    if (movedReminder != null) {
      await _reminders.cancel(taskId);
      await _reminders.scheduleOnce(
        taskId: taskId,
        title: task['title'] as String? ?? '',
        when: movedReminder,
      );
    }
  }

  @override
  Future<void> setTaskDone(Map<String, dynamic> task, {required bool done}) async {
    final taskId = _requireId(task);
    try {
      await _updateTask(taskId, {'status': done ? 'COMPLETED' : 'TODO'});
    } catch (error) {
      debugPrint('GraphQLTasksApi.setTaskDone: $error');
      throw TaskActionException(
        done
            ? 'ثبت انجام تسک ناموفق بود. دوباره تلاش کنید.'
            : 'برگرداندن تسک ناموفق بود. دوباره تلاش کنید.',
      );
    }
    // A finished task must never keep a pending reminder.
    if (done) await _reminders.cancel(taskId);
  }

  @override
  Future<Map<String, dynamic>> createQuickTask(QuickTaskDraft draft) async {
    final data = await _repository.rawRequest(
      query: _createMutation,
      variables: {
        'input': {
          'title': draft.title,
          'type': draft.isTimed ? 'TIMED' : 'NORMAL',
          'date': rfc3339Local(_onDay(draft.day, null)),
          if (draft.isTimed) 'durationM': draft.timedMinutes,
          'hasReminder': false,
          // The server infers the subject from its tag, as with the full form.
          if (draft.subject != null) 'tagNames': [draft.subject],
        },
      },
    );

    final created = data['createTask'];
    if (created is! Map<String, dynamic>) {
      throw const TaskActionException('افزودن تسک ناموفق بود. دوباره تلاش کنید.');
    }
    return plannedTaskFromApi(created);
  }

  Future<void> _updateTask(String taskId, Map<String, dynamic> input) async {
    final data = await _repository.rawRequest(
      query: _updateMutation,
      variables: {'id': taskId, 'input': input},
    );
    if (data['updateTask'] == null) {
      throw const TaskActionException('updateTask returned no task');
    }
  }

  String _requireId(Map<String, dynamic> task) {
    final taskId = task['id'] as String?;
    if (taskId == null || taskId.isEmpty) {
      throw const TaskActionException('شناسه تسک پیدا نشد');
    }
    return taskId;
  }

  /// [day] at [time]'s time of day, or at its start without one.
  static DateTime _onDay(Jalali day, DateTime? time) {
    final date = day.toDateTime();
    return DateTime(date.year, date.month, date.day, time?.hour ?? 0, time?.minute ?? 0);
  }
}
