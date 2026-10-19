import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/features/dashboard/dashboard_repository.dart';
import 'package:simo_learn/features/dashboard/home_layout.dart';
import 'package:simo_learn/features/goals/pinned_goal_store.dart';

import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(
    this._repository, {
    PinnedGoalStore pinnedStore = const PinnedGoalStore(),
  })  : _pinnedStore = pinnedStore,
        super(const DashboardState());

  final DashboardRepository _repository;
  final PinnedGoalStore _pinnedStore;

  bool _cacheRestored = false;
  Future<void>? _loading;

  /// Bumped by [reset]; a load started before it is not shown.
  int _session = 0;

  /// Brings every section up to date. Sections already on screen stay while
  /// they refresh; only a section with nothing to show yet shows a skeleton.
  /// Calls made while a load runs share it.
  Future<void> load() {
    final running = _loading;
    if (running != null) return running;
    final session = _session;
    late final Future<void> loading;
    loading = _load(session).whenComplete(() {
      if (identical(_loading, loading)) _loading = null;
    });
    return _loading = loading;
  }

  /// Retries the sections that failed with nothing to show.
  Future<void> retry() {
    if (!isClosed) emit(state.copyWith(failed: const {}));
    return load();
  }

  /// Forgets everything, as on logout, so the next account starts clean.
  Future<void> reset() async {
    _session++;
    _loading = null;
    _cacheRestored = false;
    if (!isClosed) emit(const DashboardState());
    try {
      await _repository.clearCache();
    } catch (error) {
      debugPrint('Dashboard cache not cleared: $error');
    }
  }

  bool _isStale(int session) => isClosed || session != _session;

  Future<void> _load(int session) async {
    if (!_cacheRestored) {
      _cacheRestored = true;
      await _restoreCache(session);
    }
    await Future.wait([
      _refresh(
        session,
        DashboardSection.profile,
        hasData: () => state.profile != null,
        fetch: () async {
          final profile = await _repository.getProfile();
          return state.copyWith(profile: profile);
        },
      ),
      _refresh(
        session,
        DashboardSection.goals,
        hasData: () => state.goals != null,
        fetch: () async {
          final goals = await _repository.getGoals();
          final pinned = await _pinnedStore.read();
          return state.copyWith(
            goals: _homeGoals(goals, pinned),
            pinnedGoalId: pinned,
            clearPinnedGoal: pinned == null,
          );
        },
      ),
      _refresh(
        session,
        DashboardSection.tasks,
        hasData: () => state.tasks != null,
        fetch: () async {
          final tasks = await _repository.getTasks();
          return state.copyWith(tasks: _todayTasks(tasks));
        },
      ),
      _refresh(
        session,
        DashboardSection.consistency,
        hasData: () => state.consistency != null,
        fetch: () async {
          final consistency = await _repository.getConsistency();
          return state.copyWith(consistency: consistency);
        },
      ),
    ]);
  }

  /// Fills sections the screen has nothing for yet from the last session.
  Future<void> _restoreCache(int session) async {
    final (cache, pinned) =
        await (_repository.readCache(), _pinnedStore.read()).wait;
    if (_isStale(session)) return;
    final cachedGoals = cache.goals;
    final cachedTasks = cache.tasks;
    emit(
      DashboardState(
        profile: state.profile ?? cache.profile,
        goals: state.goals ??
            (cachedGoals == null ? null : _homeGoals(cachedGoals, pinned)),
        tasks: state.tasks ??
            (cachedTasks == null ? null : _todayTasks(cachedTasks)),
        consistency: state.consistency ?? cache.consistency,
        pinnedGoalId: state.pinnedGoalId ?? pinned,
        failed: state.failed,
      ),
    );
  }

  /// Fetches one section. A failure only shows when the section has nothing
  /// else to show; otherwise the data on screen stays as it was.
  Future<void> _refresh(
    int session,
    DashboardSection section, {
    required bool Function() hasData,
    required Future<DashboardState> Function() fetch,
  }) async {
    try {
      final next = await fetch();
      if (_isStale(session)) return;
      emit(next.copyWith(failed: {...state.failed}..remove(section)));
    } catch (error) {
      debugPrint('Dashboard $section failed: $error');
      if (_isStale(session) || hasData()) return;
      emit(state.copyWith(failed: {...state.failed, section}));
    }
  }

  List<DashboardGoal> _homeGoals(List<DashboardGoal> goals, String? pinned) =>
      orderHomeGoals(
        goals
            .where((goal) => goal.title.trim().isNotEmpty && goal.isRunning)
            .toList(growable: false),
        pinnedId: pinned,
      );

  /// Today's timed tasks in the order they were planned.
  List<DashboardTaskItem> _todayTasks(List<DashboardTask> all) {
    final today = _dateOnly(DateTime.now());
    final tasks = all.where((task) {
      final date = task.date?.toLocal();
      return date != null &&
          _isSameDate(date, today) &&
          task.type == 'TIMED' &&
          task.status != 'CANCELED';
    }).toList()
      ..sort((a, b) {
        final byDate = a.date!.compareTo(b.date!);
        if (byDate != 0) return byDate;
        final epoch = DateTime.fromMillisecondsSinceEpoch(0);
        return (a.createdAt ?? epoch).compareTo(b.createdAt ?? epoch);
      });
    return tasks.map(_toDashboardTask).toList(growable: false);
  }

  DashboardTaskItem _toDashboardTask(DashboardTask task) {
    final isDone = task.status == 'COMPLETED' || task.completedAt != null;

    final maxDuration = task.durationM > 0 ? task.durationM : 0;
    final maxSeconds = maxDuration * 60;
    var elapsedSeconds = task.elapsedSeconds.clamp(0, maxSeconds);

    // If the timer is currently running, include the current running
    // interval.
    final isRunning = !isDone && task.timerStartedAt != null;
    if (isRunning) {
      final runningSeconds =
          DateTime.now().difference(task.timerStartedAt!.toLocal()).inSeconds;
      elapsedSeconds = (elapsedSeconds + runningSeconds).clamp(0, maxSeconds);
    }

    // Completed timed task = 100%.
    if (isDone) elapsedSeconds = maxSeconds;

    // From the live value above: includes a running interval, and a finished
    // task is 100% even if it was completed early.
    final percentage =
        maxSeconds > 0 ? (elapsedSeconds / maxSeconds) * 100 : 0.0;

    return DashboardTaskItem(
      title: task.title,
      id: task.id,
      percentage: percentage,
      elapsedSeconds: task.elapsedSeconds.clamp(0, maxSeconds),
      isDone: isDone,
      isRunning: isRunning,
      doneDuration: (elapsedSeconds / 60).floor(),
      maxDuration: maxDuration,
      durationText: maxDuration > 0 ? '$maxDuration' : '--',
    );
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
