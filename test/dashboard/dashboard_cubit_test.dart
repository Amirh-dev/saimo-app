import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:simo_learn/features/dashboard/cubit/dashboard_state.dart';
import 'package:simo_learn/features/dashboard/dashboard_repository.dart';
import 'package:simo_learn/features/profile/profile_repository.dart';

const _profile = ProfileUser(
  id: 'user-1',
  username: 'ali',
  simoCoins: 0,
  score: 2,
  isPremium: false,
);

DashboardGoal _goal(String title) => DashboardGoal(id: title, title: title);

class _FakeRepository implements DashboardRepository {
  DashboardCache cache = const DashboardCache();
  Completer<ProfileUser> profile = Completer();
  Completer<List<DashboardGoal>> goals = Completer();
  Completer<List<DashboardTask>> tasks = Completer();
  int fetches = 0;
  bool cleared = false;

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
  Future<List<DashboardGoal>> getGoals() => goals.future;

  @override
  Future<List<DashboardTask>> getTasks() => tasks.future;

  void answerAll() {
    profile.complete(_profile);
    goals.complete([_goal('fresh')]);
    tasks.complete(const []);
  }

  void renew() {
    profile = Completer();
    goals = Completer();
    tasks = Completer();
  }
}

void main() {
  test('shows the cached sections before the network answers', () async {
    final repository = _FakeRepository()
      ..cache = DashboardCache(goals: [_goal('cached')]);
    final cubit = DashboardCubit(repository);
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
    final cubit = DashboardCubit(repository);
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
    final cubit = DashboardCubit(repository);
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
    final cubit = DashboardCubit(repository);
    addTearDown(cubit.close);

    final load = cubit.load();
    repository.profile.completeError(Exception('offline'));
    repository.goals.completeError(Exception('offline'));
    repository.tasks.complete(const []);
    await load;

    expect(cubit.state.goals!.single.title, 'cached');
    expect(cubit.state.hasFailed(DashboardSection.goals), isFalse);
    // The profile had nothing to fall back on.
    expect(cubit.state.hasFailed(DashboardSection.profile), isTrue);

    repository.renew();
    final retry = cubit.retry();
    expect(cubit.state.hasFailed(DashboardSection.profile), isFalse);
    repository.answerAll();
    await retry;
    expect(cubit.state.profile, _profile);
  });

  test('reset forgets the sections and the cache', () async {
    final repository = _FakeRepository();
    final cubit = DashboardCubit(repository);
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
    final cubit = DashboardCubit(repository);
    addTearDown(cubit.close);

    final load = cubit.load();
    await pumpEventQueue();
    await cubit.reset();
    repository.answerAll();
    await load;

    expect(cubit.state, const DashboardState());
  });
}
