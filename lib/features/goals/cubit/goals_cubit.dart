import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/features/goals/goals_repository.dart';

import 'goals_state.dart';

class GoalsCubit extends Cubit<GoalsState> {
  GoalsCubit(this._repository) : super(const GoalsState());

  final GoalsRepository _repository;

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
      final goals = await _repository.getGoals();

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

  Future<bool> createGoal({
    required String title,
    String? note,
    DateTime? targetDate,
  }) async {
    if (state.isMutating) return false;

    emit(
      state.copyWith(
        isCreating: true,
        clearError: true,
      ),
    );

    try {
      await _repository.createGoal(
        title: title,
        note: note,
        targetDate: targetDate,
      );

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

  Future<bool> updateGoal({
    required String id,
    required String title,
    String? note,
    DateTime? targetDate,
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