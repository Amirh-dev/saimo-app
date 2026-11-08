import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/features/goals/cubit/goals_cubit.dart';
import 'package:simo_learn/features/onboarding/onboarding_store.dart';
import 'package:simo_learn/presentation/screens/onboarding/onboarding_widgets.dart';
import 'package:simo_learn/presentation/screens/onboarding/welcome_screen.dart';

import '../goals/support/goals.dart';
import '../tasks/support/app_fonts.dart';

Finder _key(String value) => find.byKey(ValueKey(value));

void main() {
  setUpAll(loadAppFonts);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('OnboardingStore', () {
    test('starts only at registration, then walks through the steps', () {
      final store = OnboardingStore.forTest();
      expect(store.showWelcome, isFalse);
      expect(store.showChecklist, isFalse);

      // Steps done before registration count for nothing.
      store.markPlanned();
      expect(store.planned, isFalse);

      store.start();
      expect(store.showWelcome, isTrue);
      expect(store.showTaskHint, isTrue);
      expect(store.showChecklist, isTrue);
      expect(store.doneCount, 0);

      store.markWelcomeSeen();
      expect(store.showWelcome, isFalse);

      store.markPlanned();
      expect(store.showTaskHint, isFalse);
      expect(store.doneCount, 1);

      store.markStudied();
      store.markGoalSet();
      expect(store.isComplete, isTrue);
      expect(store.showChecklist, isFalse);
    });

    test('a finished task also counts as a plan', () {
      final store = OnboardingStore.forTest()..start();
      store.markStudied();
      expect(store.planned, isTrue);
      expect(store.doneCount, 2);
    });

    test('the counselor offer is made once', () {
      final store = OnboardingStore.forTest()..start();
      expect(store.shouldOfferCounselor, isTrue);
      store.markOfferShown();
      expect(store.shouldOfferCounselor, isFalse);
    });

    test('progress survives a restart', () async {
      final first = OnboardingStore.forTest()..start();
      first.markWelcomeSeen();
      first.markPlanned();
      await first.saved;

      final second = OnboardingStore.forTest();
      await second.load();
      expect(second.isActive, isTrue);
      expect(second.showWelcome, isFalse);
      expect(second.planned, isTrue);
      expect(second.studied, isFalse);
    });

    test('signing out ends it', () async {
      final store = OnboardingStore.forTest()..start();
      store.reset();
      expect(store.showChecklist, isFalse);
      await store.saved;

      final next = OnboardingStore.forTest();
      await next.load();
      expect(next.isActive, isFalse);
    });

    test('an old account never sees it', () async {
      final store = OnboardingStore.forTest();
      await store.load();
      expect(store.showWelcome, isFalse);
      expect(store.showTaskHint, isFalse);
      expect(store.showChecklist, isFalse);
    });
  });

  test('making a goal ticks off the goal step', () async {
    final onboarding = OnboardingStore.instance;
    addTearDown(onboarding.reset);
    onboarding.start();
    final cubit = GoalsCubit(
      FakeGoalsRepository(const []),
      pinnedStore: MemoryPinnedStore(),
    );
    addTearDown(cubit.close);

    expect(await cubit.createGoal(title: 'کنکور ۱۴۰۶'), isTrue);
    expect(onboarding.goalSet, isTrue);
  });

  group('welcome page', () {
    Future<List<bool?>> pumpWelcome(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final results = <bool?>[];
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => results.add(await Navigator.of(context)
                .push<bool>(MaterialPageRoute(
                    builder: (_) => const OnboardingWelcomeScreen()))),
            child: const Text('open'),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return results;
    }

    testWidgets('explains the steps and adds nothing', (tester) async {
      await pumpWelcome(tester);
      expect(find.text('اولین تسک زمان‌دار امروز رو بساز'), findsOneWidget);
      expect(find.text('نمونه'), findsOneWidget);
      for (final step in OnboardingWelcomeScreen.steps) {
        expect(find.text(step), findsOneWidget);
      }
    });

    testWidgets('«ساختن برنامه» says to build the plan', (tester) async {
      final results = await pumpWelcome(tester);
      await tester.tap(_key('onboarding-welcome-start'));
      await tester.pumpAndSettle();
      expect(results, [true]);
    });

    testWidgets('«بعداً» just closes it', (tester) async {
      final results = await pumpWelcome(tester);
      await tester.tap(_key('onboarding-welcome-later'));
      await tester.pumpAndSettle();
      expect(results, [false]);
    });
  });

  group('home checklist', () {
    testWidgets('shows progress and a button on the next step',
        (tester) async {
      final store = OnboardingStore.forTest()..start();
      store.markPlanned();
      final taps = <String>[];
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: StartChecklistCard(
              store: store,
              onPlan: () => taps.add('plan'),
              onStudy: () => taps.add('study'),
              onGoal: () => taps.add('goal'),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('شروع با سایمو'), findsOneWidget);
      expect(find.text('۱ از ۳ انجام شد'), findsOneWidget);
      // Only the next step has a button.
      expect(find.text('تسک‌ها'), findsOneWidget);
      expect(find.text('ساختن'), findsNothing);
      expect(find.text('هدف خودتو مشخص کن'), findsOneWidget);
      expect(find.text('با مشاورها آشنا شو'), findsNothing);

      await tester.tap(_key('onboarding-step-study'));
      await tester.tap(_key('onboarding-step-goal'));
      // A done step does nothing.
      await tester.tap(_key('onboarding-step-plan'));
      await tester.pumpAndSettle();
      expect(taps, ['study', 'goal']);
    });
  });

  group('first finished task', () {
    Future<List<bool>> pumpSheet(WidgetTester tester) async {
      final results = <bool>[];
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => results.add(await showFirstTaskDoneSheet(
                context,
                title: 'زیست',
                minutes: 45)),
            child: const Text('open'),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return results;
    }

    testWidgets('says well done and offers the counselors', (tester) async {
      final results = await pumpSheet(tester);
      expect(find.text('اولین تسک انجام شد'), findsOneWidget);
      expect(find.text('۴۵ دقیقه زیست'), findsOneWidget);
      expect(find.text('برنامه‌ریزی با مشاور'), findsOneWidget);

      await tester.tap(_key('onboarding-see-counselors'));
      await tester.pumpAndSettle();
      expect(results, [true]);
    });

    testWidgets('«ادامه» just closes it', (tester) async {
      final results = await pumpSheet(tester);
      await tester.tap(_key('onboarding-first-task-continue'));
      await tester.pumpAndSettle();
      expect(results, [false]);
    });
  });
}
