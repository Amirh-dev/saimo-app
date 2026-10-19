import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/features/goals/goals_repository.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';

/// Today's date, without the time of day.
Jalali goalToday() {
  final now = Jalali.now();
  return Jalali(now.year, now.month, now.day);
}

/// The calendar date of a server time, as the user's device sees it.
Jalali? goalDateOf(String? time) {
  if (time == null) return null;
  final parsed = DateTime.tryParse(time);
  if (parsed == null) return null;
  final local = Jalali.fromDateTime(parsed.toLocal());
  return Jalali(local.year, local.month, local.day);
}

/// Where a goal stands against its deadline, in whole days.
class GoalTiming {
  GoalTiming._({
    required this.target,
    required this.created,
    required this.today,
  });

  factory GoalTiming.of(Goal goal, {Jalali? today}) => GoalTiming._(
        target: goalDateOf(goal.targetDate?.value),
        created: goalDateOf(goal.createdAt.value) ?? today ?? goalToday(),
        today: today ?? goalToday(),
      );

  /// The deadline; a goal may have none.
  final Jalali? target;
  final Jalali created;
  final Jalali today;

  bool get hasDeadline => target != null;

  /// Days until the deadline: 0 on the day itself, below 0 once past.
  int? get daysLeft => target == null
      ? null
      : target!.julianDayNumber - today.julianDayNumber;

  int get daysSinceCreated =>
      (today.julianDayNumber - created.julianDayNumber).clamp(0, 1 << 30);

  bool get isOverdue => (daysLeft ?? 0) < 0;

  bool get isDueToday => daysLeft == 0;

  /// A week or less to go.
  bool get isSoon => daysLeft != null && daysLeft! > 0 && daysLeft! <= 7;

  /// The share of the time from setting the goal to its deadline that has
  /// passed: time, not work.
  double get elapsed {
    final target = this.target;
    if (target == null) return 0;
    final total = target.julianDayNumber - created.julianDayNumber;
    if (total <= 0) return 1;
    return (daysSinceCreated / total).clamp(0.0, 1.0);
  }
}

/// The goals tab's arrangement: the one goal shown large, the other running
/// goals by deadline, and the goals already reached.
class GoalsBoard {
  const GoalsBoard._({
    required this.hero,
    required this.heroIsPinned,
    required this.others,
    required this.achieved,
  });

  /// The pinned goal, or else the nearest deadline still ahead.
  factory GoalsBoard.of(
    List<Goal> goals, {
    String? pinnedId,
    Jalali? today,
  }) {
    final day = today ?? goalToday();
    final running = [
      for (final goal in goals)
        if (isRunning(goal)) goal,
    ];
    final achieved = [
      for (final goal in goals)
        if (goal.status == GGoalStatus.COMPLETED) goal,
    ]..sort((a, b) => b.updatedAt.value.compareTo(a.updatedAt.value));

    int left(Goal goal) =>
        GoalTiming.of(goal, today: day).daysLeft ?? (1 << 30);
    running.sort((a, b) {
      final byDeadline = left(a).compareTo(left(b));
      return byDeadline != 0
          ? byDeadline
          : a.createdAt.value.compareTo(b.createdAt.value);
    });

    Goal? hero;
    var pinned = false;
    for (final goal in running) {
      if (goal.id == pinnedId) {
        hero = goal;
        pinned = true;
        break;
      }
    }
    hero ??= running.cast<Goal?>().firstWhere(
          (goal) => (GoalTiming.of(goal!, today: day).daysLeft ?? -1) >= 0,
          orElse: () => null,
        );

    return GoalsBoard._(
      hero: hero,
      heroIsPinned: pinned,
      others: [
        for (final goal in running)
          if (goal.id != hero?.id) goal,
      ],
      achieved: achieved,
    );
  }

  final Goal? hero;
  final bool heroIsPinned;
  final List<Goal> others;
  final List<Goal> achieved;

  bool get isEmpty => hero == null && others.isEmpty && achieved.isEmpty;

  /// Still being worked toward: not reached and not archived.
  static bool isRunning(Goal goal) =>
      goal.status != GGoalStatus.COMPLETED &&
      goal.status != GGoalStatus.ARCHIVED;
}
