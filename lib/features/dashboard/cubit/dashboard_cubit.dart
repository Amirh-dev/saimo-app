import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/features/dashboard/dashboard_repository.dart';

import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository)
      : super(const DashboardState());

  final DashboardRepository _repository;

  Future<void> load() async {
    emit(
      state.copyWith(
        status: DashboardStatus.loading,
        clearError: true,
      ),
    );

    try {
      final payload = await _repository.load();

      final today = _dateOnly(DateTime.now());

      final goals = payload.goals
          .where(
            (goal) => goal.title.trim().isNotEmpty,
      )
          .toList(growable: false);

      final dashboardTasks = payload.tasks
          .where(
            (task) =>
        _isCreatedToday(task, today) ||
            _isDoneToday(task, today),
      )
          .toList()
        ..sort(
              (a, b) => _taskSortDate(b)
              .compareTo(_taskSortDate(a)),
        );

      final tasks = dashboardTasks
          .take(7)
          .map(_toDashboardTask)
          .toList(growable: false);

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          profile: payload.profile,
          goals: goals,
          tasks: tasks,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  bool _isCreatedToday(
      DashboardTask task,
      DateTime today,
      ) {
    final createdAt = task.createdAt;

    return createdAt != null &&
        _isSameDate(
          createdAt.toLocal(),
          today,
        );
  }

  bool _isDoneToday(
      DashboardTask task,
      DateTime today,
      ) {
    final completedAt = task.completedAt;

    return completedAt != null &&
        _isSameDate(
          completedAt.toLocal(),
          today,
        );
  }

  DateTime _taskSortDate(DashboardTask task) {
    final completed = task.completedAt?.toLocal();
    final created = task.createdAt?.toLocal();

    return completed ??
        created ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  DashboardTaskItem _toDashboardTask(
      DashboardTask task,
      ) {
    final isDone =
        task.status == 'COMPLETED' ||
            task.completedAt != null;

    final isTimed = task.type == 'TIMED';

    // NORMAL TASK
    if (!isTimed) {
      return DashboardTaskItem(
        title: task.title,
        percentage: isDone ? 100 : 0,
        doneDuration: 0,
        maxDuration: 0,
        durationText: '--',
      );
    }

    // TIMED TASK
    final maxDuration =
    task.durationM > 0 ? task.durationM : 0;

    final maxSeconds = maxDuration * 60;

    var elapsedSeconds =
    task.elapsedSeconds.clamp(
      0,
      maxSeconds,
    );

    // If the timer is currently running,
    // include the current running interval.
    if (!isDone && task.timerStartedAt != null) {
      final runningSeconds = DateTime.now()
          .difference(
        task.timerStartedAt!.toLocal(),
      )
          .inSeconds;

      elapsedSeconds = (
          elapsedSeconds + runningSeconds
      ).clamp(
        0,
        maxSeconds,
      );
    }

    // Completed timed task = 100%.
    if (isDone) {
      elapsedSeconds = maxSeconds;
    }

    final percentage = maxSeconds == 0
        ? 0.0
        : (
        (elapsedSeconds / maxSeconds) * 100
    ).clamp(
      0.0,
      100.0,
    );

    return DashboardTaskItem(
      title: task.title,
      percentage: percentage,
      doneDuration:
      (elapsedSeconds / 60).floor(),
      maxDuration: maxDuration,
      durationText:
      maxDuration > 0
          ? '$maxDuration'
          : '--',
    );
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  bool _isSameDate(
      DateTime a,
      DateTime b,
      ) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }
}