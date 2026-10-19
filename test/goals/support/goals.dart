import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/features/goals/goals_repository.dart';
import 'package:simo_learn/features/goals/pinned_goal_store.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/create_goal.data.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/update_goal.data.gql.dart';

/// Noon on [day], as the app stores deadlines.
String noonOf(Jalali day) {
  final g = day.toGregorian();
  return DateTime(g.year, g.month, g.day, 12).toUtc().toIso8601String();
}

Goal goal(
  String id, {
  required Jalali created,
  Jalali? target,
  String? title,
  String? note,
  GGoalStatus status = GGoalStatus.IN_PROGRESS,
  Jalali? updated,
}) =>
    Goal((b) => b
      ..id = id
      ..createdAt.value = noonOf(created)
      ..updatedAt.value = noonOf(updated ?? created)
      ..title = title ?? 'هدف $id'
      ..note = note
      ..targetDate = target == null ? null : (GTimeBuilder()..value = noonOf(target))
      ..status = status
      ..userID = 'u');

/// Keeps goals in memory and answers like the server.
class FakeGoalsRepository implements GoalsRepository {
  FakeGoalsRepository(this.goals);

  List<Goal> goals;
  bool fail = false;
  int _next = 100;

  @override
  Future<List<Goal>> getGoals() async {
    if (fail) throw const GoalsFailure('boom');
    return List.of(goals);
  }

  @override
  Future<GCreateGoalData_createGoal> createGoal({
    required String title,
    String? note,
    DateTime? targetDate,
  }) async {
    final id = '${_next++}';
    final now = DateTime.now().toUtc().toIso8601String();
    goals = [
      ...goals,
      Goal((b) => b
        ..id = id
        ..createdAt.value = now
        ..updatedAt.value = now
        ..title = title
        ..note = note
        ..targetDate = targetDate == null
            ? null
            : (GTimeBuilder()..value = targetDate.toUtc().toIso8601String())
        ..status = GGoalStatus.IN_PROGRESS
        ..userID = 'u'),
    ];
    return GCreateGoalData_createGoal((b) => b
      ..id = id
      ..createdAt.value = now
      ..updatedAt.value = now
      ..title = title
      ..status = GGoalStatus.IN_PROGRESS
      ..userID = 'u');
  }

  @override
  Future<GUpdateGoalData_updateGoal> updateStatus({
    required String id,
    required GGoalStatus status,
  }) async {
    if (fail) throw const GoalsFailure('boom');
    final now = DateTime.now().toUtc().toIso8601String();
    goals = [
      for (final g in goals)
        g.id == id
            ? g.rebuild((b) => b
              ..status = status
              ..updatedAt.value = now)
            : g,
    ];
    final g = goals.firstWhere((g) => g.id == id);
    return GUpdateGoalData_updateGoal((b) => b
      ..id = id
      ..createdAt.value = g.createdAt.value
      ..updatedAt.value = now
      ..title = g.title
      ..status = status
      ..userID = 'u');
  }

  @override
  Future<bool> deleteGoal(String id) async {
    goals = [for (final g in goals) if (g.id != id) g];
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Remembers the pin in memory.
class MemoryPinnedStore implements PinnedGoalStore {
  MemoryPinnedStore([this.value]);

  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String? id) async => value = id;
}
