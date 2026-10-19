import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/features/goals/cubit/goals_cubit.dart';
import 'package:simo_learn/features/goals/goal_timing.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';

import 'support/goals.dart';

void main() {
  final today = goalToday();

  test('remembers the pinned goal across loads', () async {
    final store = MemoryPinnedStore('a');
    final cubit = GoalsCubit(
      FakeGoalsRepository([goal('a', created: today)]),
      pinnedStore: store,
    );
    await cubit.loadGoals();
    expect(cubit.state.pinnedId, 'a');

    await cubit.setPinned(null);
    expect(cubit.state.pinnedId, isNull);
    expect(store.value, isNull);
  });

  test('a goal reached is marked at once and loses its pin', () async {
    final store = MemoryPinnedStore('a');
    final repository = FakeGoalsRepository([
      goal('a', created: today, target: today.addDays(3)),
      goal('b', created: today, target: today.addDays(9)),
    ]);
    final cubit = GoalsCubit(repository, pinnedStore: store);
    await cubit.loadGoals();

    expect(await cubit.complete('a'), isTrue);
    expect(
      cubit.state.goals.firstWhere((g) => g.id == 'a').status,
      GGoalStatus.COMPLETED,
    );
    expect(cubit.state.pinnedId, isNull);
    expect(store.value, isNull);

    expect(await cubit.reopen('a'), isTrue);
    expect(
      cubit.state.goals.firstWhere((g) => g.id == 'a').status,
      GGoalStatus.IN_PROGRESS,
    );
  });

  test('a new goal can be made the main one', () async {
    final store = MemoryPinnedStore();
    final repository = FakeGoalsRepository([]);
    final cubit = GoalsCubit(repository, pinnedStore: store);
    await cubit.loadGoals();

    expect(
      await cubit.createGoal(
        title: 'قبولی',
        targetDate: DateTime.now().add(const Duration(days: 90)),
        pin: true,
      ),
      isTrue,
    );
    expect(cubit.state.goals, hasLength(1));
    expect(cubit.state.pinnedId, cubit.state.goals.single.id);
    expect(store.value, cubit.state.pinnedId);
  });

  test('deleting the main goal drops the pin', () async {
    final store = MemoryPinnedStore('a');
    final cubit = GoalsCubit(
      FakeGoalsRepository([goal('a', created: today)]),
      pinnedStore: store,
    );
    await cubit.loadGoals();
    expect(await cubit.deleteGoal('a'), isTrue);
    expect(cubit.state.pinnedId, isNull);
    expect(cubit.state.goals, isEmpty);
  });
}
