import 'package:equatable/equatable.dart';
import 'package:simo_learn/features/goals/goals_repository.dart';

enum GoalsStatus {
  initial,
  loading,
  success,
  failure,
}

class GoalsState extends Equatable {
  const GoalsState({
    this.status = GoalsStatus.initial,
    this.goals = const [],
    this.errorMessage,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  final GoalsStatus status;
  final List<Goal> goals;
  final String? errorMessage;

  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  bool get isLoading => status == GoalsStatus.loading;

  bool get isEmpty =>
      status == GoalsStatus.success && goals.isEmpty;

  bool get isMutating =>
      isCreating || isUpdating || isDeleting;

  GoalsState copyWith({
    GoalsStatus? status,
    List<Goal>? goals,
    String? errorMessage,
    bool clearError = false,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
  }) {
    return GoalsState(
      status: status ?? this.status,
      goals: goals ?? this.goals,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  @override
  List<Object?> get props => [
    status,
    goals,
    errorMessage,
    isCreating,
    isUpdating,
    isDeleting,
  ];
}