import 'package:equatable/equatable.dart';
import 'package:simo_learn/features/dashboard/dashboard_repository.dart';
import 'package:simo_learn/features/profile/profile_repository.dart';

/// The home screen's sections, each loaded on its own.
enum DashboardSection { profile, goals, tasks, consistency }

/// Each section's data is null until it has some, from the disk cache or the
/// network; a section shows its skeleton only then. Data already shown stays
/// while it refreshes, and a failed refresh keeps it.
class DashboardState extends Equatable {
  const DashboardState({
    this.profile,
    this.goals,
    this.tasks,
    this.consistency,
    this.pinnedGoalId,
    this.failed = const {},
  });

  final ProfileUser? profile;

  /// Running goals, the main one first.
  final List<DashboardGoal>? goals;
  final List<DashboardTaskItem>? tasks;
  final DashboardConsistency? consistency;

  /// The goal the user made their main one on the goals tab.
  final String? pinnedGoalId;

  /// Sections whose last load failed while they had nothing to show.
  final Set<DashboardSection> failed;

  bool hasFailed(DashboardSection section) => failed.contains(section);

  DashboardState copyWith({
    ProfileUser? profile,
    List<DashboardGoal>? goals,
    List<DashboardTaskItem>? tasks,
    DashboardConsistency? consistency,
    String? pinnedGoalId,
    bool clearPinnedGoal = false,
    Set<DashboardSection>? failed,
  }) {
    return DashboardState(
      profile: profile ?? this.profile,
      goals: goals ?? this.goals,
      tasks: tasks ?? this.tasks,
      consistency: consistency ?? this.consistency,
      pinnedGoalId:
          clearPinnedGoal ? null : pinnedGoalId ?? this.pinnedGoalId,
      failed: failed ?? this.failed,
    );
  }

  @override
  List<Object?> get props =>
      [profile, goals, tasks, consistency, pinnedGoalId, failed];
}
