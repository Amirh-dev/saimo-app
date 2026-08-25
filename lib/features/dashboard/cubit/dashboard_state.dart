import 'package:equatable/equatable.dart';
import 'package:simo_learn/features/dashboard/dashboard_repository.dart';
import 'package:simo_learn/features/profile/profile_repository.dart';

enum DashboardStatus {
  initial,
  loading,
  success,
  failure,
}

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.profile,
    this.goals = const [],
    this.tasks = const [],
    this.errorMessage,
  });

  final DashboardStatus status;
  final ProfileUser? profile;
  final List<DashboardGoal> goals;
  final List<DashboardTaskItem> tasks;
  final String? errorMessage;

  bool get isLoading => status == DashboardStatus.loading;

  bool get isSuccess => status == DashboardStatus.success;

  DashboardState copyWith({
    DashboardStatus? status,
    ProfileUser? profile,
    List<DashboardGoal>? goals,
    List<DashboardTaskItem>? tasks,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      goals: goals ?? this.goals,
      tasks: tasks ?? this.tasks,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    goals,
    tasks,
    errorMessage,
  ];
}