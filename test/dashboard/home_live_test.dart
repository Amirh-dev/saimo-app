import 'dart:async';

import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
// gql_exec is a transitive test fixture API exposed through Ferry's link stack.
// ignore: depend_on_referenced_packages
import 'package:gql_exec/gql_exec.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:simo_learn/features/dashboard/dashboard_repository.dart';
import 'package:simo_learn/features/onboarding/onboarding_store.dart';
import 'package:simo_learn/features/profile/profile_repository.dart';
import 'package:simo_learn/presentation/screens/app_tabs_shell.dart';
import 'package:simo_learn/presentation/screens/consultants/active_counselor_store.dart';
import 'package:simo_learn/presentation/screens/dashboard/index.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';

import '../tasks/support/app_fonts.dart';

class _Repository implements DashboardRepository {
  _Repository(this.tasks);

  List<DashboardTask> tasks;
  int taskFetches = 0;
  final changes = StreamController<String>.broadcast();

  @override
  Stream<String> get serverChanges => changes.stream;

  @override
  Future<DashboardCache> readCache() async => const DashboardCache();

  @override
  Future<void> clearCache() async {}

  @override
  Future<ProfileUser> getProfile() async => const ProfileUser(
        id: 'u',
        username: 'ali',
        fullName: 'علی رضایی',
        simoCoins: 0,
        score: 0,
        isPremium: false,
      );

  @override
  Future<List<DashboardGoal>> getGoals() async => const [];

  @override
  Future<List<DashboardTask>> getTasks() async {
    taskFetches++;
    return tasks;
  }

  @override
  Future<DashboardConsistency> getConsistency() async =>
      const DashboardConsistency(
        level: 1,
        maxLevel: 5,
        countedToday: false,
        plannedSeconds: 6300,
        progressSeconds: 1500,
        studiedSeconds: 1500,
        minStudySeconds: 5400,
        targetPercentage: 85.7,
        remainingSeconds: 3900,
        fraction: 0.28,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DashboardTask _task(String id, String title, int minutes, {int elapsed = 0}) {
  final now = DateTime.now();
  return DashboardTask(
    id: id,
    title: title,
    type: 'TIMED',
    status: 'PENDING',
    createdAt: now,
    completedAt: null,
    date: now,
    durationM: minutes,
    elapsedSeconds: elapsed,
    timerStartedAt: null,
  );
}

Future<DashboardCubit> _pumpHome(
    WidgetTester tester, List<DashboardTask> tasks) async {
  tester.view.physicalSize = const Size(390 * 3, 1000 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  ActiveCounselorStore.instance.debugReset();
  ActiveCounselorStore.instance.set(null);
  final cubit = DashboardCubit(_Repository(tasks), settle: Duration.zero);
  final graphql = GraphQLRepository(
    Client(
      link:
          Link.function((request, [forward]) => const Stream<Response>.empty()),
    ),
    tokenStorage: await TokenStorage.create(),
    logger: GraphQLConsoleLogger(endpoint: 'https://example.invalid/graphql'),
  );
  await tester.pumpWidget(
    RepositoryProvider.value(
      value: graphql,
      child: BlocProvider.value(
        value: cubit,
        child: const MaterialApp(
          home: AppTabsShell(
            titles: ['خوش اومدی'],
            tabs: [DashboardScreen()],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
  return cubit;
}

Future<void> _closeHome(WidgetTester tester, DashboardCubit cubit) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(minutes: 5));
  await tester.runAsync(cubit.close);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('a new student is welcomed once, then guided from the home',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final onboarding = OnboardingStore.instance;
    addTearDown(onboarding.reset);
    onboarding.start();

    final cubit = await _pumpHome(tester, const []);
    await tester.pumpAndSettle();
    expect(find.text('اولین تسک زمان‌دار امروز رو بساز'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('onboarding-welcome-later')));
    await tester.pumpAndSettle();
    expect(onboarding.showWelcome, isFalse);
    expect(find.byKey(const ValueKey('onboarding-checklist')), findsOneWidget);
    expect(find.text('برنامه‌ی امروزتو بچین'), findsOneWidget);
    expect(find.text('۰ از ۳ انجام شد'), findsOneWidget);

    await _closeHome(tester, cubit);
  });

  testWidgets('tasks already on the server tick off the plan step',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final onboarding = OnboardingStore.instance;
    addTearDown(onboarding.reset);
    onboarding.start();
    onboarding.markWelcomeSeen();

    final cubit = await _pumpHome(tester, [_task('bio', 'زیست', 45)]);
    await tester.pump();
    expect(onboarding.planned, isTrue);
    expect(find.text('۱ از ۳ انجام شد'), findsOneWidget);

    await _closeHome(tester, cubit);
  });

  testWidgets('an old account sees no checklist', (tester) async {
    SharedPreferences.setMockInitialValues({});
    OnboardingStore.instance.reset();
    final cubit = await _pumpHome(tester, const []);
    expect(find.byKey(const ValueKey('onboarding-checklist')), findsNothing);
    await _closeHome(tester, cubit);
  });

  testWidgets(
      'a timer started anywhere shows on the home at once and keeps counting',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1000 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    ActiveCounselorStore.instance.debugReset();
    ActiveCounselorStore.instance.set(null);

    final repository = _Repository([
      _task('physics', 'فیزیک', 60, elapsed: 25 * 60),
      _task('chemistry', 'شیمی', 45),
    ]);
    final cubit = DashboardCubit(repository, settle: Duration.zero);
    final graphql = GraphQLRepository(
      Client(
        link: Link.function(
            (request, [forward]) => const Stream<Response>.empty()),
      ),
      tokenStorage: await TokenStorage.create(),
      logger: GraphQLConsoleLogger(endpoint: 'https://example.invalid/graphql'),
    );
    await tester.pumpWidget(
      RepositoryProvider.value(
        value: graphql,
        child: BlocProvider.value(
          value: cubit,
          child: const MaterialApp(
            home: AppTabsShell(
              titles: ['خوش اومدی'],
              tabs: [DashboardScreen()],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    // The paused task is the one to go on with.
    expect(find.text('ادامه'), findsOneWidget);

    // Chemistry is started from somewhere else: the tasks tab, the banner.
    final timer = TaskTimerService.instance;
    timer.load(taskId: 'chemistry', totalSeconds: 45 * 60, elapsedSeconds: 0);
    await timer.start();
    await tester.pump();

    expect(find.text('تایمر'), findsOneWidget);
    expect(find.text('در حال اجرا، ۴۵ دقیقه مانده'), findsOneWidget);

    // The server took the write: the home asks for today's tasks again.
    final fetchesBefore = repository.taskFetches;
    repository.changes.add('StartTimedTask');
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump();
    expect(repository.taskFetches, fetchesBefore + 1);

    // Pausing it hands the strip back to the task closest to done.
    await timer.pause();
    await tester.pump();
    expect(find.text('ادامه'), findsOneWidget);

    timer.clear();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 5));
    await tester.runAsync(cubit.close);
  });
}
