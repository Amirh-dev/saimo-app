import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/features/goals/goals_repository.dart';
import 'package:simo_learn/features/goals/pinned_goal_store.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';

import 'goals_state.dart';

class GoalsCubit extends Cubit<GoalsState> {
  GoalsCubit(
    this._repository, {
    PinnedGoalStore pinnedStore = const PinnedGoalStore(),
  })  : _pinnedStore = pinnedStore,
        super(const GoalsState());

  final GoalsRepository _repository;
  final PinnedGoalStore _pinnedStore;
  bool _pinRead = false;

  Future<void> loadGoals() async {
    emit(
      state.copyWith(
        status: GoalsStatus.loading,
        clearError: true,
        isCreating: false,
        isUpdating: false,
        isDeleting: false,
      ),
    );

    try {
      if (!_pinRead) {
        _pinRead = true;
        final pinned = await _pinnedStore.read();
        if (!isClosed && pinned != null) {
          emit(state.copyWith(pinnedId: pinned));
        }
      }

      final goals = await _repository.getGoals();
      if (isClosed) return;

      emit(
        state.copyWith(
          status: GoalsStatus.success,
          goals: goals,
          isCreating: false,
          isUpdating: false,
          isDeleting: false,
          clearError: true,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: GoalsStatus.failure,
          errorMessage: error.toString(),
          isCreating: false,
          isUpdating: false,
          isDeleting: false,
        ),
      );
    }
  }

  /// [pin] makes the new goal the main one.
  Future<bool> createGoal({
    required String title,
    String? note,
    DateTime? targetDate,
    bool pin = false,
  }) async {
    if (state.isMutating) return false;

    emit(
      state.copyWith(
        isCreating: true,
        clearError: true,
      ),
    );

    try {
      final created = await _repository.createGoal(
        title: title,
        note: note,
        targetDate: targetDate,
      );
      if (pin) await setPinned(created.id);

      final goals = await _repository.getGoals();

      emit(
        state.copyWith(
          status: GoalsStatus.success,
          goals: goals,
          isCreating: false,
          clearError: true,
        ),
      );

      return true;
    } catch (error) {
      emit(
        state.copyWith(
          status: GoalsStatus.failure,
          errorMessage: error.toString(),
          isCreating: false,
        ),
      );

      return false;
    }
  }

  /// [pin] true makes it the main goal, false stops it being the main one,
  /// null leaves that as it is.
  Future<bool> updateGoal({
    required String id,
    required String title,
    String? note,
    DateTime? targetDate,
    bool? pin,
  }) async {
    if (state.isMutating) return false;

    emit(
      state.copyWith(
        isUpdating: true,
        clearError: true,
      ),
    );

    try {
      await _repository.updateGoal(
        id: id,
        title: title,
        note: note,
        targetDate: targetDate,
      );
      if (pin == true) await setPinned(id);
      if (pin == false && state.pinnedId == id) await setPinned(null);

      final goals = await _repository.getGoals();

      emit(
        state.copyWith(
          status: GoalsStatus.success,
          goals: goals,
          isUpdating: false,
          clearError: true,
        ),
      );

      return true;
    } catch (error) {
      emit(
        state.copyWith(
          status: GoalsStatus.failure,
          errorMessage: error.toString(),
          isUpdating: false,
        ),
      );

      return false;
    }
  }

  /// Marks the goal reached.
  Future<bool> complete(String id) =>
      _setStatus(id, GGoalStatus.COMPLETED);

  /// Puts a reached goal back among the running ones.
  Future<bool> reopen(String id) => _setStatus(id, GGoalStatus.IN_PROGRESS);

  Future<bool> _setStatus(String id, GGoalStatus status) async {
    if (state.isMutating) return false;

    emit(state.copyWith(isUpdating: true, clearError: true));

    try {
      final updated = await _repository.updateStatus(id: id, status: status);
      // Shown at once; the list is not fetched again for one field.
      final goals = [
        for (final goal in state.goals)
          goal.id == id ? goal.rebuild((b) => b
            ..status = updated.status
            ..updatedAt.value = updated.updatedAt.value) : goal,
      ];
      if (status == GGoalStatus.COMPLETED && state.pinnedId == id) {
        await setPinned(null);
      }
      emit(
        state.copyWith(
          status: GoalsStatus.success,
          goals: goals,
          isUpdating: false,
          clearError: true,
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          status: GoalsStatus.failure,
          errorMessage: error.toString(),
          isUpdating: false,
        ),
      );
      return false;
    }
  }

  /// Makes [id] the main goal; null makes none the main goal.
  Future<void> setPinned(String? id) async {
    emit(id == null
        ? state.copyWith(clearPinned: true)
        : state.copyWith(pinnedId: id));
    await _pinnedStore.write(id);
  }

  Future<bool> deleteGoal(String id) async {
    if (state.isMutating) return false;

    emit(
      state.copyWith(
        isDeleting: true,
        clearError: true,
      ),
    );

    try {
      final deleted = await _repository.deleteGoal(id);

      if (!deleted) {
        throw const GoalsFailure('حذف هدف انجام نشد.');
      }
      if (state.pinnedId == id) await setPinned(null);

      final goals = await _repository.getGoals();

      emit(
        state.copyWith(
          status: GoalsStatus.success,
          goals: goals,
          isDeleting: false,
          clearError: true,
        ),
      );

      return true;
    } catch (error) {
      emit(
        state.copyWith(
          status: GoalsStatus.failure,
          errorMessage: error.toString(),
          isDeleting: false,
        ),
      );

      return false;
    }
  }

  Future<void> refresh() async {
    await loadGoals();
  }
}
