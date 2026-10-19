import 'package:flutter_test/flutter_test.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/features/goals/goal_timing.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';

import 'support/goals.dart';

void main() {
  final today = Jalali(1405, 7, 27);

  test('counts the days to the deadline, and past it', () {
    final soon = GoalTiming.of(
      goal('a', created: today.addDays(-10), target: today.addDays(5)),
      today: today,
    );
    expect(soon.daysLeft, 5);
    expect(soon.isSoon, isTrue);
    expect(soon.isOverdue, isFalse);
    expect(soon.daysSinceCreated, 10);
    expect(soon.elapsed, closeTo(10 / 15, 0.001));

    final late = GoalTiming.of(
      goal('b', created: today.addDays(-30), target: today.addDays(-2)),
      today: today,
    );
    expect(late.daysLeft, -2);
    expect(late.isOverdue, isTrue);
    expect(late.elapsed, 1);

    final due = GoalTiming.of(
      goal('c', created: today, target: today),
      today: today,
    );
    expect(due.isDueToday, isTrue);
    expect(due.elapsed, 1, reason: 'no time in between: never divides by 0');

    final open = GoalTiming.of(goal('d', created: today), today: today);
    expect(open.hasDeadline, isFalse);
    expect(open.daysLeft, isNull);
    expect(open.elapsed, 0);
  });

  test('the main goal is the pinned one, else the nearest still ahead', () {
    final goals = [
      goal('far', created: today, target: today.addDays(200)),
      goal('late', created: today.addDays(-20), target: today.addDays(-1)),
      goal('near', created: today, target: today.addDays(9)),
      goal('open', created: today),
      goal('done',
          created: today.addDays(-40),
          target: today.addDays(-5),
          status: GGoalStatus.COMPLETED),
      goal('gone', created: today, status: GGoalStatus.ARCHIVED),
    ];

    final nearest = GoalsBoard.of(goals, today: today);
    expect(nearest.hero!.id, 'near');
    expect(nearest.heroIsPinned, isFalse);
    // By deadline: overdue first, a goal without one last.
    expect(nearest.others.map((g) => g.id), ['late', 'far', 'open']);
    expect(nearest.achieved.map((g) => g.id), ['done']);

    final pinned = GoalsBoard.of(goals, pinnedId: 'far', today: today);
    expect(pinned.hero!.id, 'far');
    expect(pinned.heroIsPinned, isTrue);
    expect(pinned.others.map((g) => g.id), ['late', 'near', 'open']);

    // A pin on a reached goal does not count.
    expect(GoalsBoard.of(goals, pinnedId: 'done', today: today).hero!.id,
        'near');
  });

  test('no goal ahead: no main goal', () {
    final board = GoalsBoard.of([
      goal('late', created: today.addDays(-20), target: today.addDays(-1)),
    ], today: today);
    expect(board.hero, isNull);
    expect(board.others, hasLength(1));
    expect(GoalsBoard.of(const [], today: today).isEmpty, isTrue);
  });
}
