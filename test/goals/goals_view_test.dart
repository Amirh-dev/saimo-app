import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/features/goals/cubit/goals_cubit.dart';
import 'package:simo_learn/features/goals/goal_timing.dart';
import 'package:simo_learn/features/goals/goals_repository.dart';
import 'package:simo_learn/presentation/screens/app_tabs_shell.dart';
import 'package:simo_learn/presentation/screens/goals/index.dart';

import '../tasks/support/app_fonts.dart';
import 'support/goals.dart';

Future<GoalsCubit> pumpGoals(WidgetTester tester, List<Goal> goals) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final cubit = GoalsCubit(
    FakeGoalsRepository(goals),
    pinnedStore: MemoryPinnedStore(),
  );
  await tester.pumpWidget(
    BlocProvider.value(
      value: cubit,
      child: const MaterialApp(
        home: AppTabsShell(
          titles: null,
          tabs: [Scaffold(body: GoalsView())],
        ),
      ),
    ),
  );
  await cubit.loadGoals();
  await tester.pumpAndSettle();
  return cubit;
}

void main() {
  setUpAll(loadAppFonts);
  final today = goalToday();

  testWidgets('the nearest goal is set large; a late one asks if reached',
      (tester) async {
    await pumpGoals(tester, [
      goal('near', title: 'تراز ۷۵۰۰', created: today.addDays(-10),
          target: today.addDays(9)),
      goal('far', title: 'قبولی پزشکی', created: today.addDays(-5),
          target: today.addDays(200)),
      goal('late', title: 'فیزیک گاج', created: today.addDays(-30),
          target: today.addDays(-2)),
    ]);

    expect(find.text('نزدیک‌ترین هدف'), findsOneWidget);
    expect(find.text('تراز ۷۵۰۰'), findsOneWidget);
    expect(find.text('۹'), findsOneWidget);
    expect(find.text('روز مانده'), findsOneWidget);
    expect(find.text('موعدش ۲ روز پیش بود'), findsOneWidget);
    expect(find.text('به این هدف رسیدی؟'), findsOneWidget);
    expect(find.text('۲۰۰'), findsOneWidget);
  });

  testWidgets('reaching a goal celebrates and files it away', (tester) async {
    final cubit = await pumpGoals(tester, [
      goal('near', title: 'تراز ۷۵۰۰', created: today.addDays(-10),
          target: today.addDays(9)),
      goal('late', title: 'فیزیک گاج', created: today.addDays(-30),
          target: today.addDays(-2)),
    ]);

    await tester.tap(find.text('رسیدم'));
    await tester.pumpAndSettle();
    expect(find.text('تبریک! به هدفت رسیدی'), findsOneWidget);
    expect(find.text('۲ روز بعد از موعد'), findsOneWidget);

    await tester.tap(find.text('ادامه'));
    await tester.pumpAndSettle();
    expect(find.text('تبریک! به هدفت رسیدی'), findsNothing);
    expect(find.text('اهداف محقق‌شده'), findsOneWidget);
    expect(find.text('به این هدف رسیدی؟'), findsNothing);
    expect(cubit.state.goals.where(GoalsBoard.isRunning), hasLength(1));
  });

  testWidgets('a goal opens to its countdown and actions', (tester) async {
    await pumpGoals(tester, [
      goal('far', title: 'قبولی پزشکی', note: 'رتبه‌ی زیر ۵۰۰',
          created: today.addDays(-5), target: today.addDays(200)),
    ]);

    await tester.tap(find.text('قبولی پزشکی'));
    await tester.pumpAndSettle();
    expect(find.text('رتبه‌ی زیر ۵۰۰'), findsOneWidget);
    expect(find.text('به این هدف رسیدم'), findsOneWidget);
    expect(find.text('ویرایش'), findsOneWidget);
  });

  testWidgets('no goals: says what the tab is for', (tester) async {
    await pumpGoals(tester, []);
    expect(find.text('هنوز هدفی نگذاشتی'), findsOneWidget);
    expect(find.text('اولین هدفت را بگذار'), findsOneWidget);

    await tester.tap(find.text('قبولی در کنکور سراسری'));
    await tester.pumpAndSettle();
    expect(find.text('هدف جدید'), findsOneWidget);
    expect(find.text('قبولی در کنکور سراسری'), findsWidgets);
  });
}
