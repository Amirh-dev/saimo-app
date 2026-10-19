import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/features/dashboard/dashboard_repository.dart';
import 'package:simo_learn/presentation/screens/dashboard/activity_widget.dart';

import '../tasks/support/app_fonts.dart';

DashboardTaskItem _item(
  String title, {
  int done = 0,
  int max = 60,
  bool isDone = false,
  bool isRunning = false,
}) =>
    DashboardTaskItem(
      id: title,
      title: title,
      percentage: isDone ? 100 : done * 100 / max,
      doneDuration: isDone ? max : done,
      maxDuration: max,
      durationText: '$max',
      elapsedSeconds: done * 60,
      isDone: isDone,
      isRunning: isRunning,
    );

class _Taps {
  final opened = <String>[];
  int added = 0;
  int allTasks = 0;
}

Future<_Taps> _pump(
  WidgetTester tester,
  List<DashboardTaskItem> tasks, {
  DashboardConsistency? consistency,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final taps = _Taps();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: TodayActivityWidget(
            tasks: tasks,
            date: 'یکشنبه ۲۷ مهر',
            consistency: consistency,
            onAllTasksTap: () => taps.allTasks++,
            onAddTap: () => taps.added++,
            onOpenTask: (task) => taps.opened.add(task.id),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return taps;
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('the strip offers to continue the paused task nearest the end',
      (tester) async {
    final taps = await _pump(tester, [
      _item('ریاضی', isDone: true, max: 90),
      _item('فیزیک', done: 25),
      _item('زیست', done: 100, max: 120),
    ]);

    expect(find.text('ادامه'), findsOneWidget);
    expect(find.text('۱۰۰ از ۱۲۰ دقیقه، ۲۰ دقیقه مانده'), findsOneWidget);
    // Minutes under a capsule always say they are minutes.
    expect(find.widgetWithText(OutOfText, '۲۵'), findsOneWidget);
    expect(find.widgetWithText(OutOfText, '۶۰'), findsOneWidget);
    expect(find.text('دقیقه'), findsNWidgets(3));

    await tester.tap(find.text('ادامه'));
    // One tap on any capsule opens its timer; no double tap.
    await tester.tap(find.text('فیزیک'));
    expect(taps.opened, ['زیست', 'فیزیک']);
  });

  testWidgets('a running timer is offered as it is, a fresh task to start',
      (tester) async {
    await _pump(tester, [_item('شیمی'), _item('ادبیات', done: 10, isRunning: true)]);
    expect(find.text('تایمر'), findsOneWidget);
    expect(find.text('در حال اجرا، ۵۰ دقیقه مانده'), findsOneWidget);

    await _pump(tester, [_item('شیمی', max: 45)]);
    expect(find.text('شروع'), findsOneWidget);
    expect(find.text('۴۵ دقیقه'), findsOneWidget);
  });

  testWidgets('an empty day asks for the first task', (tester) async {
    final taps = await _pump(tester, const []);
    expect(find.text('برای امروز تسکی ندارید'), findsOneWidget);
    expect(find.text('پیشرفت امروز'), findsNothing);

    await tester.tap(find.text('افزودن'));
    expect(taps.added, 1);
  });

  testWidgets('a finished day says whether it counted', (tester) async {
    await _pump(
      tester,
      [_item('ریاضی', isDone: true, max: 120)],
      consistency: const DashboardConsistency(
        level: 4,
        maxLevel: 5,
        countedToday: true,
        plannedSeconds: 7200,
        progressSeconds: 7200,
        studiedSeconds: 7200,
        minStudySeconds: 5400,
        targetPercentage: 75,
        remainingSeconds: 0,
        fraction: 1,
      ),
    );
    expect(find.text('همه‌ی تسک‌های امروز انجام شد'), findsOneWidget);
    expect(find.text('امروز حساب شد؛ ضریب امتیاز ۴×'), findsOneWidget);
  });

  testWidgets('a long day sums up the rest in one column', (tester) async {
    final taps = await _pump(tester, [
      for (var i = 0; i < 9; i++) _item('t$i'),
    ]);
    expect(find.text('+۳'), findsOneWidget);
    await tester.tap(find.text('+۳'));
    expect(taps.allTasks, 1);
  });
}
