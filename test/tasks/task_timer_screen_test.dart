import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/simo_guard.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_screen.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';

import 'support/app_fonts.dart';

/// Records the timer calls instead of sending them.
class _FakeTimerRepository extends TaskTimerRepository {
  _FakeTimerRepository(super.graphQLRepository);

  final calls = <String>[];

  @override
  Future<dynamic> startTimedTask(String id) async => calls.add('start $id');

  @override
  Future<dynamic> pauseTimedTask(String id) async => calls.add('pause $id');

  @override
  Future<dynamic> completeTimedTask(String id) async =>
      calls.add('complete $id');
}

void main() {
  setUpAll(loadAppFonts);
  final timer = TaskTimerService.instance;
  tearDown(timer.clear);

  Map<String, dynamic> task({int elapsed = 0, String status = 'pending'}) => {
        'id': 't1',
        'title': 'فیزیک، فصل سوم',
        'subtitle': 'حل تمرین‌های آخر فصل',
        'note': 'تمرین‌های ۱۲ تا ۲۰ را با زمان بزنم.',
        'durationSeconds': 2700,
        'elapsedSeconds': elapsed,
        'status': status,
      };

  Future<_FakeTimerRepository> open(
    WidgetTester tester,
    Map<String, dynamic> task,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final graphQL = GraphQLRepository(
      Client(
        link: Link.function(
          (request, [forward]) => const Stream<Response>.empty(),
        ),
      ),
      tokenStorage: await TokenStorage.create(),
      logger: GraphQLConsoleLogger(endpoint: 'https://example.invalid/graphql'),
    );
    await tester.pumpWidget(RepositoryProvider<GraphQLRepository>.value(
      value: graphQL,
      child: MaterialApp(home: TaskTimerScreen(task: task, onPop: () {})),
    ));
    // The screen binds the real repository in initState; swap it out.
    final fake = _FakeTimerRepository(graphQL);
    timer.bindRepository(fake);
    await tester.pumpAndSettle();
    return fake;
  }

  Finder byKey(String key) => find.byKey(ValueKey(key));

  String status(WidgetTester tester) => tester
      .widget<Text>(find.descendant(
          of: byKey('timer-status'), matching: find.byType(Text)))
      .data!;

  testWidgets('a new task is ready to start', (tester) async {
    await open(tester, task());

    expect(status(tester), 'آماده‌ی شروع');
    expect(find.text('شروع'), findsOneWidget);
    expect(find.text('۴۵:۰۰'), findsOneWidget);
  });

  testWidgets('starting shows the running state, pausing the paused one',
      (tester) async {
    final repository = await open(tester, task(elapsed: 600));
    expect(status(tester), 'متوقف شده');
    expect(find.text('ادامه'), findsOneWidget);

    await tester.tap(byKey('timer-toggle'));
    await tester.pump();
    expect(status(tester), 'در حال مطالعه');
    expect(find.text('توقف'), findsOneWidget);
    expect(find.text('این دور'), findsOneWidget);

    await tester.tap(byKey('timer-toggle'));
    await tester.pumpAndSettle();
    expect(status(tester), 'متوقف شده');
    expect(repository.calls, ['start t1', 'pause t1']);
  });


  testWidgets('a timed task cannot be finished early', (tester) async {
    await open(tester, task(elapsed: 1200));

    expect(find.text('پایان تسک'), findsNothing);
    expect(byKey('timer-toggle'), findsOneWidget);
  });

  testWidgets('a done task shows its result and a way back', (tester) async {
    await open(tester, task(elapsed: 2700, status: 'done'));

    expect(status(tester), 'انجام شد');
    expect(byKey('timer-toggle'), findsNothing);
    expect(byKey('timer-done-back'), findsOneWidget);
  });

  testWidgets('SimoGuard is off by default and turns on from its sheet',
      (tester) async {
    addTearDown(() => SimoGuard.instance.setEnabled(false));
    await open(tester, task());
    expect(SimoGuard.instance.enabled, isFalse);

    await tester.tap(byKey('timer-guard'));
    await tester.pumpAndSettle();
    expect(find.text('سایموگارد خاموش است'), findsOneWidget);

    await tester.tap(byKey('simo-guard-switch'));
    await tester.pumpAndSettle();
    expect(find.text('سایموگارد روشن است'), findsOneWidget);
    expect(SimoGuard.instance.enabled, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('simo_guard_enabled'), isTrue);

    await tester.tap(byKey('simo-guard-switch'));
    await tester.pumpAndSettle();
    expect(find.text('سایموگارد خاموش است'), findsOneWidget);
    expect(prefs.getBool('simo_guard_enabled'), isFalse);
  });

  testWidgets('the back arrow leaves without stopping the timer',
      (tester) async {
    await open(tester, task());
    await tester.tap(byKey('timer-toggle'));
    await tester.pump();

    await tester.tap(byKey('timer-back'));
    await tester.pumpAndSettle();
    expect(timer.isRunning, isTrue);

    await timer.pause();
  });
}
