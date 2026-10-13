import 'dart:async';

import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/screens/tasks/tasks_api.dart';

/// Monday 20 Mehr 1405 (2026-10-12); its week runs Sat 18 .. Fri 24 Mehr.
final Jalali testToday = Jalali(1405, 7, 20);

int _taskCounter = 0;

/// A task exactly as the screens receive it: an API payload run through the
/// real mapping, then placed on [day], at [hour]:[minute] when given.
Map<String, dynamic> buildTask(
  Jalali day, {
  String? id,
  String? title,
  int? timedMinutes,
  int elapsedMinutes = 0,
  bool done = false,
  String? subject,
  String? recurrenceId,
  int? hour,
  int minute = 0,
}) {
  _taskCounter += 1;
  final taskId = id ?? 'task-$_taskCounter';
  return plannedTaskFromApi({
    'id': taskId,
    'title': title ?? 'تسک $_taskCounter',
    'shortDescription': null,
    'note': null,
    'type': timedMinutes == null ? 'NORMAL' : 'TIMED',
    'date': day
        .toDateTime()
        .add(Duration(hours: hour ?? 0, minutes: hour == null ? 0 : minute))
        .toUtc()
        .toIso8601String(),
    'durationM': timedMinutes,
    'hasReminder': false,
    'reminderTime': null,
    'recurringDays': null,
    'recurrenceID': recurrenceId,
    'elapsedSeconds': elapsedMinutes * 60,
    'timerStartedAt': null,
    'status': done ? 'COMPLETED' : 'TODO',
    'goal': null,
    'tags': const [],
    'subjectTag':
        subject == null ? null : {'id': 's-$subject', 'name': subject},
  });
}

List<int> ymd(Jalali date) => [date.year, date.month, date.day];

/// In-memory stand-in for the server. By default schedule requests answer at
/// once from [schedule]; with [holdSchedules] each request waits on its own
/// completer so tests control when, and in which order, responses arrive.
class FakeTasksApi implements TasksApi {
  FakeTasksApi({this.schedule = const [], this.holdSchedules = false});

  List<Map<String, dynamic>> schedule;
  final bool holdSchedules;

  final List<({Jalali start, Jalali end})> scheduleRequests = [];
  final List<Completer<List<Map<String, dynamic>>>> pendingSchedules = [];
  final List<(String, Jalali)> moves = [];
  final List<QuickTaskDraft> created = [];
  Object? moveError;

  @override
  Future<List<Map<String, dynamic>>> fetchSchedule({
    required Jalali start,
    required Jalali end,
  }) {
    scheduleRequests.add((start: start, end: end));
    if (!holdSchedules) return Future.value(schedule);
    final completer = Completer<List<Map<String, dynamic>>>();
    pendingSchedules.add(completer);
    return completer.future;
  }

  void respond(List<Map<String, dynamic>> tasks, {int request = 0}) {
    pendingSchedules[request].complete(tasks);
  }

  @override
  Future<void> moveTask(Map<String, dynamic> task, Jalali day) async {
    if (moveError != null) throw moveError!;
    moves.add((task['id'] as String, day));
  }

  final List<(String, bool)> doneChanges = [];
  Object? doneError;

  @override
  Future<void> setTaskDone(Map<String, dynamic> task,
      {required bool done}) async {
    if (doneError != null) throw doneError!;
    doneChanges.add((task['id'] as String, done));
  }

  final List<(String, TaskReport)> reports = [];
  Object? reportError;

  @override
  Future<void> saveReport(Map<String, dynamic> task, TaskReport report) async {
    if (reportError != null) throw reportError!;
    reports.add((task['id'] as String, report));
  }

  @override
  Future<Map<String, dynamic>> createQuickTask(QuickTaskDraft draft) async {
    created.add(draft);
    return buildTask(draft.day,
        title: draft.title, timedMinutes: draft.timedMinutes);
  }
}
