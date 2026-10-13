import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/week_header.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/week_plan.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/weekly_plan_controller.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/weekly_plan_view.dart';
import 'package:simo_learn/utils/_utils.dart';

import 'support/task_fixtures.dart';

/// Records what the week asked its host to do, as readable strings.
class _Calls {
  final List<String> log = [];

  void add(String event) => log.add(event);
}

String _day(Jalali date) => ymd(date).join('-');

Finder _key(String value) => find.byKey(ValueKey(value));

Future<(WeeklyPlanController, _Calls)> _pumpWeek(
  WidgetTester tester, {
  List<Map<String, dynamic>> schedule = const [],
  Jalali? week,
  FakeTasksApi? api,
  Size size = const Size(390, 1800),
  GlobalKey<WeeklyPlanViewState>? viewKey,
  Jalali? selected,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final controller = WeeklyPlanController(
    api ?? FakeTasksApi(schedule: schedule),
    today: () => testToday,
  );
  addTearDown(controller.dispose);
  if (api == null || !api.holdSchedules) {
    await controller.showWeekOf(week ?? testToday);
  } else {
    controller.showWeekOf(week ?? testToday);
  }

  final calls = _Calls();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            WeekHeader(
              controller: controller,
              selectedDate: selected ?? testToday,
              onSelectDay: (day) => calls.add('select:${_day(day)}'),
              onChangeWeek: (delta) => calls.add('week:$delta'),
              onPickDate: () => calls.add('pick'),
              canShowWeek: (start) => isWeekWithinHorizon(start, testToday),
              onBlockedForward: () => calls.add('blocked'),
            ),
            Expanded(
              child: WeeklyPlanView(
                key: viewKey,
                controller: controller,
                onOpenTask: (task) => calls.add('task:${task['id']}'),
                onMoveTasks: (tasks, day) => calls.add(
                  'move:${tasks.map((task) => task['id']).join(',')}:${_day(day)}',
                ),
                onAddToDay: (day, {timed = true}) =>
                    calls.add('add:${_day(day)}${timed ? '' : ':checklist'}'),
                onRefresh: () async => calls.add('refresh'),
                onChangeWeek: (delta) => calls.add('board-week:$delta'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
  return (controller, calls);
}

void main() {
  group('pulling the days past an edge', () {
    // Days run right to left: Saturday sits on the right.
    Finder columns() => find.byKey(const ValueKey('week-columns-1405-7-18'));

    Future<void> pull(WidgetTester tester, double dx,
        {required String hint}) async {
      final gesture = await tester.startGesture(tester.getCenter(columns()));
      // Several steps, as a finger would.
      for (var step = 0; step < 12; step++) {
        await gesture.moveBy(Offset(dx / 12, 0));
        await tester.pump();
      }
      expect(_key(hint), findsOneWidget); // shown while pulling
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_key(hint), findsNothing); // and gone once let go
    }

    testWidgets('past Saturday turns to the previous week', (tester) async {
      final (_, calls) = await _pumpWeek(tester);
      await tester.pumpAndSettle();

      // Toward Saturday and beyond it: the finger moves left.
      await pull(tester, -1400, hint: 'week-pull-previous');
      expect(calls.log, contains('board-week:-1'));
    });

    testWidgets('past Friday turns to the next week', (tester) async {
      final (_, calls) = await _pumpWeek(tester);
      await tester.pumpAndSettle();

      await pull(tester, 1400, hint: 'week-pull-next');
      expect(calls.log, contains('board-week:1'));
    });

    testWidgets('a short pull just springs back', (tester) async {
      final (_, calls) = await _pumpWeek(tester);
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(tester.getCenter(columns()));
      await gesture.moveBy(const Offset(-40, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(calls.log.where((call) => call.startsWith('board-week')), isEmpty);
    });
  });

  group('WeeklyPlanView', () {
    Finder inColumn(String column, String text) =>
        find.descendant(of: _key(column), matching: find.text(text));

    testWidgets('stacks each day\'s time boxes in its column', (tester) async {
      await _pumpWeek(tester, size: const Size(1000, 1200), schedule: [
        buildTask(Jalali(1405, 7, 22), title: 'تست فیزیک', timedMinutes: 45),
      ]);

      for (var index = 0; index < 7; index++) {
        expect(_key('week-day-header-$index'), findsOneWidget);
        expect(_key('week-day-column-$index'), findsOneWidget);
      }
      expect(inColumn('week-day-column-4', 'تست فیزیک'), findsOneWidget);
      expect(inColumn('week-day-column-4', '۴۵ دقیقه'), findsOneWidget);
      // The strip above has the dates; the headers name the days.
      expect(inColumn('week-day-header-4', 'چهارشنبه'), findsOneWidget);
      expect(inColumn('week-day-header-4', '۲۲'), findsNothing);
    });

    testWidgets('a time box grows with the time it was given', (tester) async {
      await _pumpWeek(tester, size: const Size(1000, 1200), schedule: [
        buildTask(Jalali(1405, 7, 20), id: 'short', timedMinutes: 45),
        buildTask(Jalali(1405, 7, 20), id: 'long', timedMinutes: 120),
      ]);
      await tester.pumpAndSettle();

      double height(String id) => tester.getSize(_key('week-task-$id')).height;
      expect(height('long'), greaterThan(height('short')));
      // In the order the server sent them.
      expect(
        tester.getTopLeft(_key('week-task-short')).dy,
        lessThan(tester.getTopLeft(_key('week-task-long')).dy),
      );
    });

    testWidgets('checklists fold into a pill with their count', (tester) async {
      await _pumpWeek(tester, size: const Size(1000, 1200), schedule: [
        buildTask(Jalali(1405, 7, 20), title: 'خواندن زیست'),
        buildTask(Jalali(1405, 7, 20), title: 'لغات', done: true),
        buildTask(Jalali(1405, 7, 20), title: 'تست', timedMinutes: 60),
      ]);
      await tester.pumpAndSettle();

      expect(inColumn('week-checklists-2', '۲'), findsOneWidget);
      expect(find.text('خواندن زیست'), findsNothing);
      expect(_key('week-checklists-3'), findsNothing);
      // Above the day's time boxes.
      expect(
        tester.getTopLeft(_key('week-checklists-2')).dy,
        lessThan(tester.getTopLeft(find.text('تست')).dy),
      );
    });

    testWidgets('the checklists pill opens them in a popup', (tester) async {
      final (_, calls) =
          await _pumpWeek(tester, size: const Size(1000, 1200), schedule: [
        buildTask(Jalali(1405, 7, 20), title: 'خواندن زیست'),
        buildTask(Jalali(1405, 7, 20), title: 'لغات', done: true),
      ]);
      await tester.pumpAndSettle();

      await tester.tap(_key('week-checklists-2'));
      await tester.pumpAndSettle();
      final popup = _key('week-checklists-popup');
      expect(find.descendant(of: popup, matching: find.text('خواندن زیست')),
          findsOneWidget);
      expect(
        find.descendant(
            of: popup, matching: find.text('دوشنبه ۲۰ مهر، ۱ از ۲ انجام شد')),
        findsOneWidget,
      );
      // Checking off stays in the week; there is no jump to the day.
      expect(find.text('باز کردن روز'), findsNothing);

      await tester.tap(_key('week-checklists-add'));
      await tester.pumpAndSettle();
      expect(popup, findsNothing);
      expect(calls.log, ['add:1405-7-20:checklist']);
    });

    testWidgets('a checklist is checked and unchecked in the popup',
        (tester) async {
      final api = FakeTasksApi(schedule: [
        buildTask(Jalali(1405, 7, 20), id: 'bio', title: 'خواندن زیست'),
        buildTask(Jalali(1405, 7, 20), id: 'words', title: 'لغات', done: true),
      ]);
      await _pumpWeek(tester, size: const Size(1000, 1200), api: api);
      await tester.pumpAndSettle();
      await tester.tap(_key('week-checklists-2'));
      await tester.pumpAndSettle();

      TextDecoration? decorationOf(String title) =>
          tester.widget<Text>(find.text(title)).style?.decoration;

      await tester.tap(_key('week-checklist-bio'));
      await tester.pumpAndSettle();
      expect(decorationOf('خواندن زیست'), TextDecoration.lineThrough);
      expect(find.text('دوشنبه ۲۰ مهر، ۲ از ۲ انجام شد'), findsOneWidget);

      await tester.tap(_key('week-checklist-words'));
      await tester.pumpAndSettle();
      expect(decorationOf('لغات'), isNot(TextDecoration.lineThrough));
      expect(api.doneChanges, [('bio', true), ('words', false)]);

      // Behind the popup, the pill's count turns dark once all are done.
      await tester.tap(_key('week-checklist-words'));
      await tester.pumpAndSettle();
      final badge = tester.widget<Text>(find.descendant(
        of: _key('week-checklists-2'),
        matching: find.text('۲'),
      ));
      expect(badge.style?.color, AppColors.white);
    });

    testWidgets('a check that fails to save springs back', (tester) async {
      final api = FakeTasksApi(schedule: [
        buildTask(Jalali(1405, 7, 20), id: 'bio', title: 'خواندن زیست'),
      ])
        ..doneError = Exception('offline');
      await _pumpWeek(tester, size: const Size(1000, 1200), api: api);
      await tester.pumpAndSettle();
      await tester.tap(_key('week-checklists-2'));
      await tester.pumpAndSettle();

      await tester.tap(_key('week-checklist-bio'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.text('خواندن زیست')).style?.decoration,
        isNot(TextDecoration.lineThrough),
      );
      // Lets the error toast go away.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('a checklist\'s «…» opens its details', (tester) async {
      final (_, calls) =
          await _pumpWeek(tester, size: const Size(1000, 1200), schedule: [
        buildTask(Jalali(1405, 7, 20), id: 'bio', title: 'خواندن زیست'),
      ]);
      await tester.pumpAndSettle();

      await tester.tap(_key('week-checklists-2'));
      await tester.pumpAndSettle();
      await tester.tap(_key('week-checklist-more-bio'));
      await tester.pumpAndSettle();
      expect(_key('week-checklists-popup'), findsNothing);
      expect(calls.log, ['task:bio']);
    });

    testWidgets('a past day\'s checklists can be read but not added to',
        (tester) async {
      await _pumpWeek(tester, size: const Size(1000, 1200), schedule: [
        buildTask(Jalali(1405, 7, 18), title: 'مرور شنبه', done: true),
      ]);
      await tester.pumpAndSettle();

      await tester.tap(_key('week-checklists-0'));
      await tester.pumpAndSettle();
      expect(find.text('مرور شنبه'), findsOneWidget);
      expect(_key('week-checklists-add'), findsNothing);
      await tester.tap(_key('week-checklists-close'));
      await tester.pumpAndSettle();
      expect(_key('week-checklists-popup'), findsNothing);
    });

    testWidgets('finished time boxes are struck through', (tester) async {
      await _pumpWeek(tester, size: const Size(1000, 1200), schedule: [
        buildTask(Jalali(1405, 7, 18),
            title: 'مرور شنبه', timedMinutes: 30, done: true),
        buildTask(Jalali(1405, 7, 21), title: 'هنوز مانده', timedMinutes: 60),
      ]);

      TextDecoration? decorationOf(String title) =>
          tester.widget<Text>(find.text(title)).style?.decoration;
      expect(decorationOf('مرور شنبه'), TextDecoration.lineThrough);
      expect(decorationOf('هنوز مانده'), isNot(TextDecoration.lineThrough));
    });

    testWidgets('each day header shows its planned time and work done',
        (tester) async {
      await _pumpWeek(tester, size: const Size(1000, 1200), schedule: [
        // 330 minutes planned: 180 done, 45 of 90 worked, 60 not started.
        buildTask(Jalali(1405, 7, 21), timedMinutes: 180, done: true),
        buildTask(Jalali(1405, 7, 21), timedMinutes: 90, elapsedMinutes: 45),
        buildTask(Jalali(1405, 7, 21), timedMinutes: 60),
        // A checklist counts 20 minutes: one of two ticked is half.
        buildTask(Jalali(1405, 7, 22), done: true),
        buildTask(Jalali(1405, 7, 22)),
        buildTask(Jalali(1405, 7, 23), timedMinutes: 30, done: true),
      ]);
      await tester.pumpAndSettle();

      expect(inColumn('week-day-header-3', '۵:۳۰'), findsOneWidget);
      LinearProgressIndicator barOf(int day) =>
          tester.widget<LinearProgressIndicator>(find.descendant(
            of: _key('week-day-header-$day'),
            matching: find.byType(LinearProgressIndicator),
          ));
      expect(barOf(3).value, closeTo(225 / 330, 0.001));
      expect(barOf(4).value, closeTo(0.5, 0.001));
      expect(barOf(5).value, 1);
      expect(barOf(5).color, AppColors.done); // all done turns it green
      expect(barOf(6).value, 0);
    });

    testWidgets('a time box opens its details; the week stays the week',
        (tester) async {
      final (_, calls) =
          await _pumpWeek(tester, size: const Size(1000, 1200), schedule: [
        buildTask(Jalali(1405, 7, 22), id: 'physics', timedMinutes: 45),
      ]);
      await tester.pumpAndSettle();

      await tester.tap(_key('week-day-header-5'));
      await tester.tap(_key('week-task-physics'));
      await tester.pumpAndSettle();
      expect(calls.log, ['task:physics']);
    });

    testWidgets('today and later days end with an add button', (tester) async {
      final (_, calls) =
          await _pumpWeek(tester, size: const Size(1000, 1200), schedule: [
        buildTask(Jalali(1405, 7, 20), id: 'today', timedMinutes: 45),
      ]);
      await tester.pumpAndSettle();

      expect(_key('week-add-0'), findsNothing);
      expect(_key('week-add-1'), findsNothing);
      for (var index = 2; index < 7; index++) {
        expect(_key('week-add-$index'), findsOneWidget);
      }
      expect(
        tester.getTopLeft(_key('week-add-2')).dy,
        greaterThan(tester.getBottomLeft(_key('week-task-today')).dy),
      );

      await tester.tap(_key('week-add-4'));
      expect(calls.log, ['add:1405-7-22']);
    });

    testWidgets('color marks only an overloaded day, with no summary above',
        (tester) async {
      await _pumpWeek(tester, size: const Size(1000, 1200), schedule: [
        buildTask(Jalali(1405, 7, 21), timedMinutes: 300),
        buildTask(Jalali(1405, 7, 22), timedMinutes: 60),
      ]);

      Color? colorOf(String text) =>
          tester.widget<Text>(find.text(text)).style?.color;
      expect(colorOf('۵:۰۰'), AppColors.primary);
      expect(colorOf('۱:۰۰'), isNot(AppColors.primary));
      expect(_key('week-summary'), findsNothing);
      expect(_key('week-capacity'), findsNothing);
    });

    testWidgets('a held time box moves to the day it is dropped on',
        (tester) async {
      final (controller, calls) =
          await _pumpWeek(tester, size: const Size(1000, 1200), schedule: [
        buildTask(Jalali(1405, 7, 20), id: 'math', timedMinutes: 60),
      ]);
      await tester.pumpAndSettle();

      final gesture =
          await tester.startGesture(tester.getCenter(_key('week-task-math')));
      await tester.pump(const Duration(milliseconds: 400));
      await gesture.moveTo(tester.getCenter(_key('week-day-column-5')));
      await tester.pump();
      expect(_key('week-drop-slot'), findsOneWidget);
      await gesture.up();
      await tester.pumpAndSettle();

      expect(calls.log, ['move:math:1405-7-23']);
      // Already shown on its new day while the move is saved.
      expect(
        find.descendant(
          of: _key('week-day-column-5'),
          matching: _key('week-task-math'),
        ),
        findsOneWidget,
      );
      expect(controller.plan.days[2].tasks, isEmpty);
    });

    testWidgets('a time box cannot be dropped on a past day', (tester) async {
      final (_, calls) =
          await _pumpWeek(tester, size: const Size(1000, 1200), schedule: [
        buildTask(Jalali(1405, 7, 21), id: 'math', timedMinutes: 60),
      ]);
      await tester.pumpAndSettle();

      final gesture =
          await tester.startGesture(tester.getCenter(_key('week-task-math')));
      await tester.pump(const Duration(milliseconds: 400));
      await gesture.moveTo(tester.getCenter(_key('week-day-column-0')));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(calls.log, isEmpty);
    });

    testWidgets('a past day offers to bring its unfinished work to today',
        (tester) async {
      final (_, calls) =
          await _pumpWeek(tester, size: const Size(1000, 1200), schedule: [
        buildTask(Jalali(1405, 7, 18), id: 'a', timedMinutes: 45),
        buildTask(Jalali(1405, 7, 18), id: 'b'),
        buildTask(Jalali(1405, 7, 18), id: 'c', done: true),
        buildTask(Jalali(1405, 7, 19), id: 'd', done: true),
      ]);
      await tester.pumpAndSettle();

      expect(inColumn('week-leftover-0', '۲ کار مانده'), findsOneWidget);
      expect(_key('week-leftover-1'), findsNothing);
      await tester.tap(_key('week-leftover-move'));
      await tester.pumpAndSettle();
      expect(calls.log, ['move:a,b:1405-7-20']);
    });

    testWidgets('an empty week says where to start, on its first day ahead',
        (tester) async {
      await _pumpWeek(tester, size: const Size(1000, 1200));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: _key('week-day-column-2'),
          matching: find.text('اولین زمان‌بندی هفته را بساز'),
        ),
        findsOneWidget,
      );
      expect(find.text('اولین زمان‌بندی هفته را بساز'), findsOneWidget);
    });

    testWidgets('a narrow screen opens the week on today', (tester) async {
      await _pumpWeek(tester, size: const Size(390, 900));
      await tester.pumpAndSettle();

      final start = tester.getTopRight(_key('week-columns')).dx;
      expect(
          tester.getTopRight(_key('week-day-header-2')).dx, closeTo(start, 1));
    });

    testWidgets('scrolls to a day of a week that has just loaded',
        (tester) async {
      final viewKey = GlobalKey<WeeklyPlanViewState>();
      final (controller, _) = await _pumpWeek(
        tester,
        schedule: [
          for (var day = 25; day <= 30; day++)
            buildTask(Jalali(1405, 7, day), title: 'تسک روز $day'),
        ],
        size: const Size(390, 900),
        viewKey: viewKey,
      );

      await controller.showWeekOf(Jalali(1405, 7, 27));
      final scrolling = viewKey.currentState!.scrollToDay(Jalali(1405, 7, 28));
      await tester.pumpAndSettle();
      await scrolling;

      final start = tester.getTopRight(_key('week-columns')).dx;
      expect(
          tester.getTopRight(_key('week-day-header-3')).dx, closeTo(start, 1));
      expect(
          tester.getTopRight(_key('week-day-column-3')).dx, closeTo(start, 1));
    });

    testWidgets('shows a skeleton first and an error with retry on failure',
        (tester) async {
      final api = FakeTasksApi(holdSchedules: true);
      final (controller, _) = await _pumpWeek(tester, api: api);
      expect(_key('week-plan-skeleton'), findsOneWidget);

      api.pendingSchedules.single.completeError(Exception('offline'));
      await tester.pumpAndSettle();
      expect(_key('week-plan-error'), findsOneWidget);

      await tester.tap(_key('week-plan-retry'));
      api.respond(
        [buildTask(Jalali(1405, 7, 21), title: 'بعد از خطا', timedMinutes: 45)],
        request: 1,
      );
      await tester.pumpAndSettle();
      expect(find.text('بعد از خطا'), findsOneWidget);
      expect(controller.hasError, isFalse);
    });
  });

  group('WeekHeader', () {
    testWidgets('shows the selected date and a button for the calendar',
        (tester) async {
      final semantics = tester.ensureSemantics();
      final (_, calls) = await _pumpWeek(tester);

      expect(find.text('تاریخ انتخابی:'), findsNothing);
      expect(find.bySemanticsLabel('امروز، ۲۰ مهر ۱۴۰۵'), findsOneWidget);
      semantics.dispose();
      expect(find.text('انتخاب تاریخ'), findsOneWidget);
      await tester.tap(_key('week-pick-date'));
      expect(calls.log, contains('pick'));
    });

    testWidgets('names tomorrow and yesterday before the date, not other days',
        (tester) async {
      await _pumpWeek(tester, selected: Jalali(1405, 7, 21));
      await tester.pumpAndSettle();
      expect(find.text('فردا،'), findsOneWidget);

      await _pumpWeek(tester, selected: Jalali(1405, 7, 19));
      await tester.pumpAndSettle();
      expect(find.text('دیروز،'), findsOneWidget);

      await _pumpWeek(tester, selected: Jalali(1405, 7, 23));
      await tester.pumpAndSettle();
      for (final prefix in ['امروز،', 'فردا،', 'دیروز،']) {
        expect(find.text(prefix), findsNothing);
      }
    });

    testWidgets('the strip follows a swipe to the next or previous week',
        (tester) async {
      final (_, calls) = await _pumpWeek(tester);

      // Later days sit to the left, so dragging right brings the next week.
      await tester.drag(_key('week-strip'), const Offset(260, 0));
      await tester.pumpAndSettle();
      await tester.drag(_key('week-strip'), const Offset(-260, 0));
      await tester.pumpAndSettle();
      expect(calls.log, ['week:1', 'week:-1']);
    });

    testWidgets('springs back at the planning horizon', (tester) async {
      final last = testToday.addDays(77);
      final (_, calls) = await _pumpWeek(tester, week: last, selected: last);

      await tester.drag(_key('week-strip'), const Offset(260, 0));
      await tester.pumpAndSettle();
      expect(calls.log, ['blocked']);
      // 7 Dey: still the same week.
      expect(
          find.descendant(of: _key('week-capsule-2'), matching: find.text('۷')),
          findsOneWidget);
    });

    testWidgets('the selected day is black and today keeps a dot',
        (tester) async {
      await _pumpWeek(tester);
      expect(_key('week-today-dot'), findsNothing);
      expect(
        tester.getCenter(_key('week-selection')).dx,
        closeTo(tester.getCenter(_key('week-capsule-2')).dx, 1),
      );

      await _pumpWeek(tester, selected: Jalali(1405, 7, 23));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
            of: _key('week-capsule-2'), matching: _key('week-today-dot')),
        findsOneWidget,
      );
      expect(
        tester.getCenter(_key('week-selection')).dx,
        closeTo(tester.getCenter(_key('week-capsule-5')).dx, 1),
      );
    });

    testWidgets('the selection glides to a newly selected day', (tester) async {
      await _pumpWeek(tester);
      final from = tester.getCenter(_key('week-capsule-2')).dx;
      final to = tester.getCenter(_key('week-capsule-5')).dx;

      await _pumpWeek(tester, selected: Jalali(1405, 7, 23));
      await tester.pump(const Duration(milliseconds: 120));
      final midway = tester.getCenter(_key('week-selection')).dx;
      expect(midway, lessThan(from));
      expect(midway, greaterThan(to));

      await tester.pumpAndSettle();
      expect(tester.getCenter(_key('week-selection')).dx, closeTo(to, 1));
    });

    testWidgets('names each day and calls today by name', (tester) async {
      await _pumpWeek(tester);

      expect(
          find.descendant(
              of: _key('week-capsule-2'), matching: find.text('امروز')),
          findsOneWidget);
      expect(
          find.descendant(
              of: _key('week-capsule-0'), matching: find.text('شنبه')),
          findsOneWidget);
      expect(
          find.descendant(
              of: _key('week-capsule-5'), matching: find.text('۲۳')),
          findsOneWidget);
    });

    testWidgets('each day ring shows how much of it is done', (tester) async {
      await _pumpWeek(tester, schedule: [
        buildTask(Jalali(1405, 7, 19), done: true),
        buildTask(Jalali(1405, 7, 21), done: true),
        buildTask(Jalali(1405, 7, 21)),
        buildTask(Jalali(1405, 7, 22)),
      ]);

      double ringOf(int day) => tester
          .widget<CircularProgressIndicator>(find.descendant(
            of: _key('week-capsule-$day'),
            matching: find.byType(CircularProgressIndicator),
          ))
          .value!;

      await tester.pumpAndSettle();
      expect(
          find.descendant(
              of: _key('week-capsule-1'),
              matching: find.byIcon(Icons.check_rounded)),
          findsOneWidget);
      expect(ringOf(3), 0.5);
      expect(ringOf(4), 0);
      expect(ringOf(6), 0);
    });

    testWidgets('a day capsule selects its day', (tester) async {
      final (_, calls) = await _pumpWeek(tester);

      await tester.tap(_key('week-capsule-5'));
      expect(calls.log, contains('select:1405-7-23'));
    });
  });

  testWidgets('the view mode toggle reports the chosen mode', (tester) async {
    TasksViewMode? chosen;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: TasksViewModeToggle(
              mode: TasksViewMode.day,
              onChanged: (mode) => chosen = mode,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('هفتگی'));
    expect(chosen, TasksViewMode.week);
  });
}
