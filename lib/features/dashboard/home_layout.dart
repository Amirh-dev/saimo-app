import 'package:simo_learn/features/dashboard/dashboard_repository.dart';

/// The task the home card puts forward: the one whose timer is on, else the
/// paused one closest to done, else the first not started. Null once every
/// task is done, or when there are none.
int? suggestedTaskIndex(List<DashboardTaskItem> tasks) {
  final running = tasks.indexWhere((task) => task.isRunning);
  if (running >= 0) return running;

  int? paused;
  for (var i = 0; i < tasks.length; i++) {
    if (!tasks[i].isPaused) continue;
    if (paused == null ||
        tasks[i].remainingMinutes < tasks[paused].remainingMinutes) {
      paused = i;
    }
  }
  if (paused != null) return paused;

  final idle = tasks.indexWhere((task) => task.isNotStarted);
  return idle >= 0 ? idle : null;
}

enum TodaySlotKind { task, add, more, ghost, blank }

/// One column of the home's task chart.
class TodaySlot {
  const TodaySlot.task(int this.index)
      : kind = TodaySlotKind.task,
        more = 0;

  const TodaySlot.more(this.more)
      : kind = TodaySlotKind.more,
        index = null;

  const TodaySlot._(this.kind)
      : index = null,
        more = 0;

  static const add = TodaySlot._(TodaySlotKind.add);
  static const ghost = TodaySlot._(TodaySlotKind.ghost);
  static const blank = TodaySlot._(TodaySlotKind.blank);

  final TodaySlotKind kind;

  /// The task's place in the day's list, for a task column.
  final int? index;

  /// How many tasks the «+N» column stands for.
  final int more;
}

/// The chart's [columns] columns. Tasks come in order with an add column
/// after them; a day with more than fit shows a «+N» column last, and the
/// suggested task is never the one left out. An empty day shows one add
/// column and faint ghosts.
List<TodaySlot> todaySlots(
  int taskCount, {
  int? suggested,
  int columns = 7,
}) {
  if (taskCount == 0) {
    return [TodaySlot.add, for (var i = 1; i < columns; i++) TodaySlot.ghost];
  }
  if (taskCount < columns) {
    return [
      for (var i = 0; i < taskCount; i++) TodaySlot.task(i),
      TodaySlot.add,
      for (var i = taskCount + 1; i < columns; i++) TodaySlot.blank,
    ];
  }
  if (taskCount == columns) {
    return [for (var i = 0; i < taskCount; i++) TodaySlot.task(i)];
  }

  final shown = columns - 1;
  final visible = [for (var i = 0; i < shown; i++) i];
  if (suggested != null && suggested >= shown) visible[shown - 1] = suggested;
  return [
    for (final index in visible) TodaySlot.task(index),
    TodaySlot.more(taskCount - shown),
  ];
}

/// The home's goals in carousel order: the main goal first (the pinned one,
/// else the nearest deadline still ahead, as on the goals tab), then the rest
/// by deadline, those without one last.
List<DashboardGoal> orderHomeGoals(
  List<DashboardGoal> goals, {
  String? pinnedId,
  DateTime? today,
}) {
  final day = _dateOnly(today ?? DateTime.now());
  int? daysLeft(DashboardGoal goal) {
    final target = goal.targetDate;
    if (target == null) return null;
    return _dateOnly(target.toLocal()).difference(day).inDays;
  }

  final ordered = [...goals]..sort((a, b) {
      final left = daysLeft(a) ?? (1 << 30);
      final right = daysLeft(b) ?? (1 << 30);
      return left.compareTo(right);
    });

  var main = ordered.indexWhere((goal) => goal.id == pinnedId);
  if (main < 0) main = ordered.indexWhere((goal) => (daysLeft(goal) ?? -1) >= 0);
  if (main > 0) ordered.insert(0, ordered.removeAt(main));
  return ordered;
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
