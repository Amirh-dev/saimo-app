import 'dart:math' as math;

import 'package:simo_learn/features/dashboard/dashboard_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';

/// Today's tasks as they stand this second, not when they were fetched.
///
/// The app's one live timer decides for the task it holds, as on the tasks
/// tab: started, paused or finished from any screen, the home shows it at
/// once. A task the server last saw running counts on from its start time,
/// unless another task holds the timer now, which means it was paused.
List<DashboardTaskItem> liveTodayTasks(
  List<DashboardTaskItem> tasks,
  TaskTimerService timer, {
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  return [
    for (final task in tasks)
      if (timer.isActive(task.id))
        task.withProgress(
          seconds: timer.elapsedSeconds,
          running: timer.isRunning,
          done: task.isDone || timer.isCompleted,
        )
      else if (task.isRunning && timer.hasActiveTask)
        task.withProgress(
          seconds: task.progressSeconds,
          running: false,
          done: false,
        )
      else if (task.isRunning && task.timerStartedAt != null)
        task.withProgress(
          seconds: task.elapsedSeconds +
              math.max(0, clock.difference(task.timerStartedAt!).inSeconds),
          running: true,
          done: false,
        )
      else
        task,
  ];
}

/// Today's study as the server counted it, plus what the running timer
/// added since the server answered.
int liveStudiedSeconds(
  DashboardConsistency consistency,
  TaskTimerService timer, {
  DateTime? now,
}) {
  if (!timer.isRunning) return consistency.studiedSeconds;
  final fetchedAt = consistency.fetchedAt;
  final sinceFetch = fetchedAt == null
      ? 0
      : math.max(0, (now ?? DateTime.now()).difference(fetchedAt).inSeconds);
  return consistency.studiedSeconds +
      math.min(timer.currentSessionSeconds, sinceFetch);
}
