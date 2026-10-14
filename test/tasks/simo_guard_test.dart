import 'package:ferry/ferry.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/simo_guard.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';

/// Records the timer calls instead of sending them.
class _FakeTimerRepository extends TaskTimerRepository {
  _FakeTimerRepository(super.graphQLRepository);

  final calls = <String>[];

  @override
  Future<dynamic> startTimedTask(String id) async => calls.add('start $id');

  @override
  Future<dynamic> pauseTimedTask(String id) async => calls.add('pause $id');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final timer = TaskTimerService.instance;
  late _FakeTimerRepository repository;
  late SimoGuard guard;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = _FakeTimerRepository(GraphQLRepository(
      Client(
        link: Link.function(
          (request, [forward]) => const Stream<Response>.empty(),
        ),
      ),
      tokenStorage: await TokenStorage.create(),
      logger: GraphQLConsoleLogger(endpoint: 'https://example.invalid/graphql'),
    ));
    timer.bindRepository(repository);
    timer.load(taskId: 't1', totalSeconds: 2700, elapsedSeconds: 0);
    guard = SimoGuard.test(timer);
  });

  tearDown(() {
    timer.clear();
    guard.dispose();
  });

  test('is off by default', () async {
    await guard.attach();
    expect(guard.enabled, isFalse);
  });

  test('restores the saved choice', () async {
    SharedPreferences.setMockInitialValues({'simo_guard_enabled': true});
    await guard.attach();
    expect(guard.enabled, isTrue);
  });

  test('while off, leaving the app keeps the timer running', () async {
    await timer.start();
    guard.didChangeAppLifecycleState(AppLifecycleState.paused);
    await pumpEventQueue();
    expect(timer.isRunning, isTrue);
  });

  test('while on, leaving the app pauses the timer and says so on return',
      () async {
    await guard.setEnabled(true);
    final notices = <void>[];
    final subscription = guard.pausedWhileAway.listen(notices.add);
    addTearDown(subscription.cancel);

    await timer.start();
    // A pulled-down notification shade is not leaving the app.
    guard.didChangeAppLifecycleState(AppLifecycleState.inactive);
    expect(timer.isRunning, isTrue);

    guard.didChangeAppLifecycleState(AppLifecycleState.paused);
    await pumpEventQueue();
    expect(timer.isRunning, isFalse);
    expect(repository.calls, ['start t1', 'pause t1']);
    expect(notices, isEmpty);

    guard.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);
    expect(notices, hasLength(1));
  });

  test('while on, a paused timer is left alone', () async {
    await guard.setEnabled(true);
    final notices = <void>[];
    final subscription = guard.pausedWhileAway.listen(notices.add);
    addTearDown(subscription.cancel);

    guard.didChangeAppLifecycleState(AppLifecycleState.paused);
    guard.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);
    expect(repository.calls, isEmpty);
    expect(notices, isEmpty);
  });

  Future<List<void>> watchNotices(SimoGuard guard) async {
    final notices = <void>[];
    final subscription = guard.pausedWhileAway.listen(notices.add);
    addTearDown(subscription.cancel);
    return notices;
  }

  test('locking the phone in the app keeps the timer running', () async {
    guard.dispose();
    guard = SimoGuard.test(timer, isScreenOn: () async => false);
    await guard.setEnabled(true);
    final notices = await watchNotices(guard);

    await timer.start();
    guard.didChangeAppLifecycleState(AppLifecycleState.paused);
    await pumpEventQueue();
    expect(timer.isRunning, isTrue);

    guard.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await pumpEventQueue();
    expect(notices, isEmpty);
    expect(repository.calls, ['start t1']);
  });

  test('where the screen state is unknown, the timer keeps running',
      () async {
    guard.dispose();
    guard = SimoGuard.test(timer, isScreenOn: () async => null);
    await guard.setEnabled(true);

    await timer.start();
    guard.didChangeAppLifecycleState(AppLifecycleState.paused);
    await pumpEventQueue();
    expect(timer.isRunning, isTrue);
  });

  test('closing the app pauses the timer', () async {
    await guard.setEnabled(true);

    await timer.start();
    guard.didChangeAppLifecycleState(AppLifecycleState.detached);
    await pumpEventQueue();
    expect(timer.isRunning, isFalse);
    expect(repository.calls, ['start t1', 'pause t1']);
  });

  test('while off, closing the app keeps the timer running', () async {
    await timer.start();
    guard.didChangeAppLifecycleState(AppLifecycleState.detached);
    await pumpEventQueue();
    expect(timer.isRunning, isTrue);
  });
}
