import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:simo_learn/features/dashboard/cubit/dashboard_state.dart';
import 'package:simo_learn/features/dashboard/dashboard_repository.dart';
import 'package:simo_learn/features/goals/pinned_goal_store.dart';
import 'package:simo_learn/features/profile/profile_repository.dart';

const _profile = ProfileUser(
  id: 'user-1',
  username: 'ali',
  simoCoins: 0,
  score: 2,
  isPremium: false,
);

const _consistency = DashboardConsistency(
  level: 3,
  maxLevel: 5,
  countedToday: false,
  plannedSeconds: 345 * 60,
  progressSeconds: 215 * 60,
  studiedSeconds: 215 * 60,
  minStudySeconds: 90 * 60,
  targetPercentage: 70,
  remainingSeconds: 1590,
  fraction: 0.89,
);

DashboardGoal _goal(String title, {DateTime? targetDate}) =>
    DashboardGoal(id: title, title: title, targetDate: targetDate);

DashboardTask _task(
  String title, {
  required DateTime date,
  String status = 'PENDING',
  int durationM = 60,
  int elapsedSeconds = 0,
  DateTime? timerStartedAt,
}) =>
    DashboardTask(
      id: title,
      title: title,
      type: 'TIMED',
      status: status,
      createdAt: date,
      completedAt: status == 'COMPLETED' ? date : null,
      date: date,
      durationM: durationM,
      elapsedSeconds: elapsedSeconds,
      timerStartedAt: timerStartedAt,
    );

class _FakePinnedStore implements PinnedGoalStore {
  _FakePinnedStore([this.id]);

  String? id;

  @override
  Future<String?> read() async => id;

  @override
  Future<void> write(String? id) async => this.id = id;
}

DashboardCubit _cubit(
  _FakeRepository repository, {
  String? pinned,
  Duration settle = Duration.zero,
}) =>
    DashboardCubit(
      repository,
      pinnedStore: _FakePinnedStore(pinned),
      settle: settle,
    );

class _FakeRepository implements DashboardRepository {
  DashboardCache cache = const DashboardCache();
  Completer<ProfileUser> profile = Completer();
  Completer<List<DashboardGoal>> goals = Completer();
  Completer<List<DashboardTask>> tasks = Completer();
  Completer<DashboardConsistency> consistency = Completer();
  int fetches = 0;
  int goalFetches = 0;
  int taskFetches = 0;
  int consistencyFetches = 0;
  bool cleared = false;
  final changes = StreamController<String>.broadcast();

  @override
  Stream<String> get serverChanges => changes.stream;

  @override
  Future<DashboardCache> readCache() async => cache;

  @override
  Future<void> clearCache() async => cleared = true;

  @override
  Future<ProfileUser> getProfile() {
    fetches++;
    return profile.future;
  }

  @override
  Future<List<DashboardGoal>> getGoals() {
    goalFetches++;
    return goals.future;
  }

  @override
  Future<List<DashboardTask>> getTasks() {
    taskFetches++;
    return tasks.future;
  }

  @override
  Future<DashboardConsistency> getConsistency() {
    consistencyFetches++;
    return consistency.future;
  }

  void answerAll() {
    profile.complete(_profile);
    goals.complete([_goal('fresh')]);
    tasks.complete(const []);
    consistency.complete(_consistency);
  }

  void renew() {
    profile = Completer();
    goals = Completer();
    tasks = Completer();
    consistency = Completer();
  }
}

void main() {
  test('shows the cached sections before the network answers', () async {
    final repository = _FakeRepository()
      ..cache = DashboardCache(goals: [_goal('cached')]);
    final cubit = _cubit(repository);
    addTearDown(cubit.close);

    final load = cubit.load();
    await pumpEventQueue();

    expect(cubit.state.goals!.single.title, 'cached');
    // Nothing cached for these yet: they show their own skeletons.
    expect(cubit.state.profile, isNull);
    expect(cubit.state.tasks, isNull);

    repository.answerAll();
    await load;
    expect(cubit.state.goals!.single.title, 'fresh');
    expect(cubit.state.profile, _profile);
    expect(cubit.state.tasks, isEmpty);
  });

  test('a return to the screen refreshes without dropping what it shows',
      () async {
    final repository = _FakeRepository();
    final cubit = _cubit(repository);
    addTearDown(cubit.close);
    repository.answerAll();
    await cubit.load();

    repository.renew();
    final states = <DashboardState>[];
    final subscription = cubit.stream.listen(states.add);
    addTearDown(subscription.cancel);

    final refresh = cubit.load();
    await pumpEventQueue();
    expect(cubit.state.profile, _profile);
    expect(cubit.state.goals, isNotNull);

    repository.answerAll();
    await refresh;
    expect(
      states.every((s) => s.profile != null && s.goals != null),
      isTrue,
    );
  });

  test('loads made together share one fetch', () async {
    final repository = _FakeRepository();
    final cubit = _cubit(repository);
    addTearDown(cubit.close);

    final first = cubit.load();
    final second = cubit.load();
    repository.answerAll();
    await Future.wait([first, second]);

    expect(repository.fetches, 1);
  });

  test('a failed refresh keeps the data on screen', () async {
    final repository = _FakeRepository()
      ..cache = DashboardCache(goals: [_goal('cached')]);
    final cubit = _cubit(repository);
    addTearDown(cubit.close);

    final load = cubit.load();
    await pumpEventQueue();
    repository.profile.completeError(Exception('offline'));
    repository.goals.completeError(Exception('offline'));
    repository.tasks.complete(const []);
    repository.consistency.completeError(Exception('offline'));
    await load;

    expect(cubit.state.goals!.single.title, 'cached');
    expect(cubit.state.hasFailed(DashboardSection.goals), isFalse);
    // The profile had nothing to fall back on.
    expect(cubit.state.hasFailed(DashboardSection.profile), isTrue);
    // A server without the multiplier yet leaves the rest of the home alone.
    expect(cubit.state.hasFailed(DashboardSection.consistency), isTrue);
    expect(cubit.state.tasks, isEmpty);

    repository.renew();
    final retry = cubit.retry();
    expect(cubit.state.hasFailed(DashboardSection.profile), isFalse);
    repository.answerAll();
    await retry;
    expect(cubit.state.profile, _profile);
  });

  test('reset forgets the sections and the cache', () async {
    final repository = _FakeRepository();
    final cubit = _cubit(repository);
    addTearDown(cubit.close);
    repository.answerAll();
    await cubit.load();

    await cubit.reset();

    expect(cubit.state, const DashboardState());
    expect(repository.cleared, isTrue);
  });

  test('a load running at logout does not bring the old data back',
      () async {
    final repository = _FakeRepository();
    final cubit = _cubit(repository);
    addTearDown(cubit.close);

    final load = cubit.load();
    await pumpEventQueue();
    await cubit.reset();
    repository.answerAll();
    await load;

    expect(cubit.state, const DashboardState());
  });

  test('loads the multiplier, and shows today\'s cached one at once',
      () async {
    final repository = _FakeRepository()
      ..cache = const DashboardCache(consistency: _consistency);
    final cubit = _cubit(repository);
    addTearDown(cubit.close);

    final load = cubit.load();
    await pumpEventQueue();
    expect(cubit.state.consistency, same(_consistency));

    repository.answerAll();
    await load;
    expect(cubit.state.consistency!.level, 3);
    expect(cubit.state.hasFailed(DashboardSection.consistency), isFalse);
  });

  test('keeps every task of the day, in planned order, and knows the running '
      'one', () async {
    final repository = _FakeRepository();
    final cubit = _cubit(repository);
    addTearDown(cubit.close);
    final today = DateTime.now();
    DateTime at(int hour) =>
        DateTime(today.year, today.month, today.day, hour);

    repository.profile.complete(_profile);
    repository.goals.complete(const []);
    repository.consistency.complete(_consistency);
    repository.tasks.complete([
      for (var hour = 16; hour >= 8; hour--) _task('h$hour', date: at(hour)),
      _task(
        'running',
        date: at(7),
        elapsedSeconds: 600,
        timerStartedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      _task('yesterday', date: at(9).subtract(const Duration(days: 1))),
    ]);
    await cubit.load();

    final tasks = cubit.state.tasks!;
    expect(tasks, hasLength(10));
    expect(tasks.first.title, 'running');
    expect(tasks[1].title, 'h8');
    expect(tasks.last.title, 'h16');
    expect(tasks.first.isRunning, isTrue);
    expect(tasks.first.doneDuration, 15);
    expect(tasks[1].isRunning, isFalse);
  });

  test('puts the pinned goal first and remembers which it is', () async {
    final repository = _FakeRepository();
    final cubit = _cubit(repository, pinned: 'far');
    addTearDown(cubit.close);
    final now = DateTime.now();

    repository.profile.complete(_profile);
    repository.tasks.complete(const []);
    repository.consistency.complete(_consistency);
    repository.goals.complete([
      _goal('near', targetDate: now.add(const Duration(days: 10))),
      _goal('far', targetDate: now.add(const Duration(days: 200))),
      _goal('none'),
    ]);
    await cubit.load();

    expect(cubit.state.goals!.map((goal) => goal.title),
        ['far', 'near', 'none']);
    expect(cubit.state.pinnedGoalId, 'far');
  });

  test('a task written anywhere refreshes today and the multiplier, once',
      () async {
    final repository = _FakeRepository();
    final cubit = _cubit(repository, settle: const Duration(milliseconds: 20));
    addTearDown(cubit.close);
    repository.answerAll();
    await cubit.load();
    expect(repository.taskFetches, 1);

    repository.renew();
    repository.answerAll();
    // Switching timers is two writes: pausing one task and starting another.
    repository.changes
      ..add('PauseTimedTask')
      ..add('StartTimedTask');
    await Future<void>.delayed(const Duration(milliseconds: 60));

    expect(repository.taskFetches, 2);
    expect(repository.consistencyFetches, 2);
    expect(repository.goalFetches, 1);
    expect(repository.fetches, 1);
    expect(cubit.state.tasksFetchedAt, isNotNull);
  });

  test('a goal write refreshes the goals; others leave the home alone',
      () async {
    final repository = _FakeRepository();
    final cubit = _cubit(repository);
    addTearDown(cubit.close);
    repository.answerAll();
    await cubit.load();
    repository.renew();
    repository.answerAll();

    repository.changes
      ..add('UpdateGoal')
      ..add('SendMessage');
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(repository.goalFetches, 2);
    expect(repository.taskFetches, 1);
    expect(repository.consistencyFetches, 1);
  });

  test('which sections a write touches, by its name', () {
    expect(DashboardCubit.sectionsChangedBy('CompleteTimedTask'),
        {DashboardSection.tasks, DashboardSection.consistency});
    expect(DashboardCubit.sectionsChangedBy('SaveTaskReport'),
        {DashboardSection.tasks, DashboardSection.consistency});
    expect(DashboardCubit.sectionsChangedBy('DeleteGoal'),
        {DashboardSection.goals});
    expect(DashboardCubit.sectionsChangedBy('UpdateProfile'),
        {DashboardSection.profile});
    expect(DashboardCubit.sectionsChangedBy('RefreshToken'), isEmpty);
  });
}
