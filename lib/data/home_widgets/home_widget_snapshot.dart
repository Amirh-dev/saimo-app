import 'package:simo_learn/features/dashboard/dashboard_repository.dart';

/// What the app's live timer holds, as the home-screen widgets need it.
class WidgetTimerState {
  const WidgetTimerState({
    this.activeTaskId,
    this.sessionStartedAt,
    this.solidSeconds = 0,
    this.isCompleted = false,
  });

  final String? activeTaskId;

  /// Null while the timer is paused.
  final DateTime? sessionStartedAt;

  /// Seconds committed before the running session.
  final int solidSeconds;
  final bool isCompleted;

  bool get hasActiveTask => activeTaskId != null;
}

/// Today's tasks as the Android home-screen widgets draw them.
///
/// A running task carries the moment it started counting instead of a
/// second count, so the widget counts on by itself while the app is closed,
/// and the snapshot only changes when a task really changes (not every
/// tick), which keeps writes to the widget rare.
///
/// [streak] is the multiplier as the server last counted it; the widget
/// takes off what a running timer has added since [DashboardConsistency.fetchedAt].
/// [dateLabel] is today in the app's own words, «شنبه ۱۶ آبان».
Map<String, Object?> homeWidgetSnapshot({
  required List<DashboardTaskItem> tasks,
  required WidgetTimerState timer,
  required DateTime now,
  DashboardConsistency? streak,
  String dateLabel = '',
}) {
  return {
    'v': 1,
    'day': _dayKey(now),
    'date': dateLabel,
    'tasks': [for (final task in tasks) _task(task, timer)],
    'streak': streak == null
        ? null
        : {
            'level': streak.level,
            'countedToday': streak.countedToday,
            'hasPlan': streak.hasPlan,
            'remainingSec': streak.remainingSeconds,
            'fetchedAtMs': (streak.fetchedAt ?? now).millisecondsSinceEpoch,
          },
  };
}

Map<String, Object?> _task(DashboardTaskItem task, WidgetTimerState timer) {
  final planned = task.maxDuration * 60;
  var worked = task.progressSeconds;
  DateTime? runningSince;
  var done = task.isDone;

  if (timer.activeTaskId == task.id) {
    // The app's own timer decides for the task it holds, as on the home tab.
    done = task.isDone || timer.isCompleted;
    worked = done ? planned : timer.solidSeconds;
    runningSince = done ? null : timer.sessionStartedAt;
  } else if (task.isRunning && !timer.hasActiveTask) {
    // Running on the server (started before the app last closed).
    worked = task.elapsedSeconds;
    runningSince = task.timerStartedAt;
  }
  // A task the server saw running while another one holds the timer now was
  // paused: its progress so far stands, as liveTodayTasks counts it.

  return {
    'id': task.id,
    'title': task.title,
    'plannedSec': planned,
    'workedSec': worked.clamp(0, planned),
    'runningSinceMs': runningSince?.millisecondsSinceEpoch,
    'done': done,
  };
}

String _dayKey(DateTime time) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${time.year}-${two(time.month)}-${two(time.day)}';
}

/// Where a tap on a home-screen widget leads: `saimo://widget/home`,
/// `saimo://widget/task?id=…` or `saimo://widget/add`.
class HomeWidgetLink {
  const HomeWidgetLink({this.taskId, this.addTask = false});

  /// The task row that was tapped; null for the widget as a whole.
  final String? taskId;

  /// The «+» button: open the new-task form.
  final bool addTask;

  static HomeWidgetLink? fromLink(Uri link) {
    if (link.scheme != 'saimo' || link.host != 'widget') return null;
    if (link.path == '/add') return const HomeWidgetLink(addTask: true);
    final id = link.queryParameters['id']?.trim() ?? '';
    final isTask = link.path == '/task' && id.isNotEmpty;
    return HomeWidgetLink(taskId: isTask ? id : null);
  }
}
