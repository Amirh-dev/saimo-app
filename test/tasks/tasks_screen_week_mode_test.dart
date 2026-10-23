import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
// gql_exec is exposed by Ferry for the in-memory test link.
// ignore: depend_on_referenced_packages
import 'package:gql_exec/gql_exec.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/add_task/index.dart';
import 'package:simo_learn/presentation/screens/tasks/index.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/week_header.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/week_plan.dart';

import 'support/app_fonts.dart';
import 'support/task_fixtures.dart' show ymd;

Finder _key(String value) => find.byKey(ValueKey(value));

/// A task in the shape the API returns it.
Map<String, dynamic> _apiTask(String id, String title, Jalali day) => {
      'id': id,
      'title': title,
      'shortDescription': null,
      'note': null,
      'type': 'NORMAL',
      'date': day.toDateTime().toUtc().toIso8601String(),
      'durationM': null,
      'hasReminder': false,
      'reminderTime': null,
      'recurringDays': null,
      'recurrenceID': null,
      'elapsedSeconds': 0,
      'timerStartedAt': null,
      'status': 'TODO',
      'goal': null,
      'tags': const [],
    };

/// Answers the tasks screen's raw queries from memory.
class _TasksRepository extends GraphQLRepository {
  _TasksRepository(TokenStorage storage, {required this.schedule})
      : super(
          Client(
            link: Link.function(
              (request, [forward]) => const Stream<Response>.empty(),
            ),
          ),
          tokenStorage: storage,
          logger:
              GraphQLConsoleLogger(endpoint: 'https://example.invalid/graphql'),
        );

  final List<Map<String, dynamic>> schedule;
  final List<Map<String, dynamic>> createdInputs = [];
  final List<Map<String, dynamic>> created = [];
  final List<Map<String, dynamic>> updates = [];
  final List<Map<String, dynamic>> reports = [];

  @override
  Future<Map<String, dynamic>> rawRequest({
    required String query,
    Map<String, dynamic> variables = const {},
    bool requiresAuth = true,
  }) async {
    if (query.contains('taskSchedule')) return {'taskSchedule': schedule};
    // The screen keeps only the tasks of the day it asked for.
    if (query.contains('getTasks')) return {'getTasks': schedule};
    if (query.contains('updateTask')) {
      updates.add({'id': variables['id'], ...variables['input'] as Map});
      return {
        'updateTask': {'id': variables['id']},
      };
    }
    if (query.contains('saveTaskCompletionReport')) {
      reports.add({
        'taskID': variables['taskID'],
        ...variables['input'] as Map<String, dynamic>,
      });
      return {
        'saveTaskCompletionReport': {'id': 'r-${reports.length}'},
      };
    }
    if (query.contains('createTask')) {
      final input = Map<String, dynamic>.from(variables['input'] as Map);
      createdInputs.add(input);
      final created = {
        ..._apiTask(
            'created-${createdInputs.length}',
            input['title'] as String,
            Jalali.fromDateTime(
                DateTime.parse(input['date'] as String).toLocal())),
        'type': input['type'],
        'durationM': input['durationM'],
      };
      schedule.add(created);
      this.created.add(created);
      return {'createTask': created};
    }
    return const {};
  }
}

Future<_TasksRepository> _pumpTasksScreen(
  WidgetTester tester, {
  Map<String, Object> preferences = const {},
  List<Map<String, dynamic>>? schedule,
  bool weekly = false,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  SharedPreferences.setMockInitialValues(preferences);
  final storage = await TokenStorage.create();
  final repository = _TasksRepository(storage, schedule: schedule ?? []);

  await tester.pumpWidget(
    RepositoryProvider<GraphQLRepository>.value(
      value: repository,
      child: const MaterialApp(home: TasksScreen()),
    ),
  );
  await tester.pumpAndSettle();
  if (weekly) {
    await tester.tap(find.text('هفتگی'));
    await tester.pumpAndSettle();
  }
  return repository;
}

void main() {
  final today = Jalali.now();
  final todayIndex = today.weekDay - 1;

  setUpAll(loadAppFonts);

  testWidgets('the screen always opens in daily mode', (tester) async {
    // Even for someone who planned by the week last time.
    await _pumpTasksScreen(tester, preferences: {'tasks_view_mode': 'week'});

    expect(_key('weekly-plan-view'), findsNothing);
    expect(_key('day-checklists'), findsOneWidget);
  });

  testWidgets('switching to weekly shows the week', (tester) async {
    await _pumpTasksScreen(
      tester,
      schedule: [_apiTask('t1', 'برنامه امروز', today)],
    );
    expect(_key('weekly-plan-view'), findsNothing);

    await tester.tap(find.text('هفتگی'));
    await tester.pumpAndSettle();

    expect(_key('weekly-plan-view'), findsOneWidget);
    // A checklist waits behind its day's pill.
    await tester.tap(_key('week-checklists-$todayIndex'));
    await tester.pumpAndSettle();
    expect(find.text('برنامه امروز'), findsOneWidget);
  });

  testWidgets('a pulled-to week opens on its first day, this week on today',
      (tester) async {
    await _pumpTasksScreen(tester);
    await tester.tap(find.text('هفتگی'));
    await tester.pumpAndSettle();

    Jalali selected() =>
        tester.widget<WeekHeader>(find.byType(WeekHeader)).selectedDate;
    Future<void> pull(double dx) async {
      final columns = find.byWidgetPredicate((widget) =>
          widget.key is ValueKey<String> &&
          (widget.key! as ValueKey<String>).value.startsWith('week-columns-'));
      final gesture = await tester.startGesture(tester.getCenter(columns));
      for (var step = 0; step < 12; step++) {
        await gesture.moveBy(Offset(dx / 12, 0));
        await tester.pump();
      }
      await gesture.up();
      await tester.pumpAndSettle();
    }

    // Past Friday: next week, opening on its Saturday.
    await pull(1400);
    final nextSaturday = weekStartOf(today).addDays(7);
    expect(ymd(selected()), ymd(nextSaturday));

    // Back past Saturday: this week again, on today.
    await pull(-1400);
    expect(ymd(selected()), ymd(today));
  });

  testWidgets('the week stays in week mode; a time box opens its details',
      (tester) async {
    await _pumpTasksScreen(
      tester,
      weekly: true,
      schedule: [
        {
          ..._apiTask('t1', 'تست ریاضی', today),
          'type': 'TIMED',
          'durationM': 45
        },
      ],
    );

    await tester.tap(_key('week-day-header-$todayIndex'));
    await tester.pumpAndSettle();
    expect(_key('weekly-plan-view'), findsOneWidget);

    await tester.tap(_key('week-task-t1'));
    await tester.pumpAndSettle();
    expect(_key('task-sheet-move'), findsOneWidget);
    // A timed task ends only through its timer, so an unfinished one
    // offers no report (which would finish it).
    expect(_key('task-sheet-report'), findsNothing);
    expect(_key('weekly-plan-view'), findsOneWidget);
  });

  testWidgets('a checklist is checked off from the week', (tester) async {
    final repository = await _pumpTasksScreen(
      tester,
      weekly: true,
      schedule: [_apiTask('t1', 'برنامه امروز', today)],
    );

    await tester.tap(_key('week-checklists-$todayIndex'));
    await tester.pumpAndSettle();
    await tester.tap(_key('week-checklist-t1'));
    await tester.pumpAndSettle();

    expect(repository.updates, [
      {'id': 't1', 'status': 'COMPLETED'},
    ]);
    expect(
      tester.widget<Text>(find.text('برنامه امروز')).style?.decoration,
      TextDecoration.lineThrough,
    );
  });

  testWidgets('quick add creates the task through the API', (tester) async {
    final repository = await _pumpTasksScreen(tester);

    await tester.tap(_key('tasks-add-button'));
    await tester.pumpAndSettle();
    await tester.enterText(_key('quick-add-title'), 'تسک سریع');
    await tester.pump();
    await tester.tap(_key('quick-add-submit'));
    await tester.pumpAndSettle();

    final input = repository.createdInputs.single;
    expect(input['title'], 'تسک سریع');
    expect(input['type'], 'TIMED');
    expect(input['durationM'], 45);
    final day =
        Jalali.fromDateTime(DateTime.parse(input['date'] as String).toLocal());
    expect(
        [day.year, day.month, day.day], [today.year, today.month, today.day]);

    Navigator.of(tester.element(_key('quick-add-sheet'))).pop();
    await tester.pumpAndSettle();
    expect(find.text('تسک سریع'), findsOneWidget);
  });

  testWidgets('daily mode picks its day from the same week strip',
      (tester) async {
    await _pumpTasksScreen(tester);
    expect(_key('week-strip'), findsOneWidget);
    expect(find.text('امروز،'), findsOneWidget);

    // Another day of this week: yesterday, or tomorrow on a Saturday.
    final other = todayIndex == 0 ? 1 : todayIndex - 1;
    await tester.tap(_key('week-capsule-$other'));
    await tester.pumpAndSettle();

    expect(find.text(other < todayIndex ? 'دیروز،' : 'فردا،'), findsOneWidget);
    expect(find.textContaining('تسک‌های '), findsNothing);
  });

  testWidgets('a day\'s add button in the week opens quick add for that day',
      (tester) async {
    final repository = await _pumpTasksScreen(tester, weekly: true);

    await tester.tap(_key('week-add-$todayIndex'));
    await tester.pumpAndSettle();
    await tester.enterText(_key('quick-add-title'), 'از هفته');
    await tester.pump();
    await tester.tap(_key('quick-add-submit'));
    await tester.pumpAndSettle();

    final day = Jalali.fromDateTime(
      DateTime.parse(repository.createdInputs.single['date'] as String)
          .toLocal(),
    );
    expect(
        [day.year, day.month, day.day], [today.year, today.month, today.day]);
  });

  testWidgets('in daily mode, adding starts a time box', (tester) async {
    await _pumpTasksScreen(tester);

    await tester.tap(_key('tasks-add-button'));
    await tester.pumpAndSettle();
    expect(_key('quick-add-sheet'), findsOneWidget);
    expect(_key('quick-add-minutes-45'), findsOneWidget);

    await tester.enterText(_key('quick-add-title'), 'تمرین تستی');
    await tester.pump();
    await tester.tap(_key('quick-add-more'));
    await tester.pumpAndSettle();

    expect(find.byType(AddTimedTaskScreen), findsOneWidget);
    expect(find.text('تمرین تستی'), findsOneWidget);
    // The form picks tags as quick add does: with a title there is no hint,
    // only the tags (none suggested here) and the chip to add one.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(_key('task-form-tags-hint'), findsNothing);
    expect(_key('task-form-tag-new'), findsOneWidget);
  });

  testWidgets('daily mode shows checklists in the pill and checks them off',
      (tester) async {
    final repository = await _pumpTasksScreen(
      tester,
      schedule: [
        _apiTask('t1', 'برنامه امروز', today),
        {
          ..._apiTask('t2', 'تست ریاضی', today),
          'type': 'TIMED',
          'durationM': 45
        },
      ],
    );

    expect(find.text('تست ریاضی'), findsOneWidget);
    expect(find.text('برنامه امروز'), findsNothing);
    expect(
      find.descendant(of: _key('day-checklists'), matching: find.text('۱')),
      findsOneWidget,
    );

    await tester.tap(_key('day-checklists'));
    await tester.pumpAndSettle();
    await tester.tap(_key('week-checklist-t1'));
    await tester.pumpAndSettle();
    expect(repository.updates, [
      {'id': 't1', 'status': 'COMPLETED'},
    ]);
    expect(
      tester.widget<Text>(find.text('برنامه امروز')).style?.decoration,
      TextDecoration.lineThrough,
    );
  });

  testWidgets('a done task reopens its report, prefilled, and saves edits',
      (tester) async {
    final repository = await _pumpTasksScreen(
      tester,
      schedule: [
        {
          ..._apiTask('t1', 'برنامه امروز', today),
          'status': 'COMPLETED',
          'completionReport': {
            'performanceRating': 2,
            'tookTest': true,
            'totalQuestions': 50,
            'correctAnswers': 42,
          },
        },
      ],
    );

    await tester.tap(_key('day-checklists'));
    await tester.pumpAndSettle();
    await tester.tap(_key('week-checklist-more-t1'));
    await tester.pumpAndSettle();
    await tester.tap(_key('task-sheet-report'));
    await tester.pumpAndSettle();
    expect(find.text('تسک با موفقیت به پایان رسید.'), findsOneWidget);
    expect(find.text('۵۰'), findsOneWidget);

    await tester.tap(_key('task-report-rating-4'));
    await tester.tap(_key('task-report-submit'));
    await tester.pumpAndSettle();

    // Already done: nothing to complete, only the report is saved.
    expect(repository.updates, isEmpty);
    expect(repository.reports, [
      {
        'taskID': 't1',
        'performanceRating': 4,
        'tookTest': true,
        'totalQuestions': 50,
        'correctAnswers': 42,
      },
    ]);
    expect(_key('task-report-popup'), findsNothing);
  });

  testWidgets('the mode switch sits under the header in both modes',
      (tester) async {
    await _pumpTasksScreen(tester);
    expect(_key('tasks-view-mode-toggle'), findsOneWidget);
    expect(find.text('انتخاب تاریخ'), findsOneWidget);

    await tester.tap(find.text('هفتگی'));
    await tester.pumpAndSettle();
    expect(_key('weekly-plan-view'), findsOneWidget);
    expect(_key('tasks-view-mode-toggle'), findsOneWidget);
    // Each day has its own add button, so the toolbar's turns the week.
    expect(_key('tasks-add-button'), findsNothing);
    expect(_key('week-nav'), findsOneWidget);

    await tester.tap(find.text('روزانه'));
    await tester.pumpAndSettle();
    expect(_key('weekly-plan-view'), findsNothing);
    expect(_key('tasks-add-button'), findsOneWidget);
    expect(_key('week-nav'), findsNothing);
  });

  testWidgets('in weekly mode the strip folds into a row of rings',
      (tester) async {
    await _pumpTasksScreen(tester);
    final dailyHeight = tester.getSize(_key('week-tray')).height;

    await tester.tap(find.text('هفتگی'));
    await tester.pumpAndSettle();
    expect(tester.getSize(_key('week-tray')).height, lessThan(dailyHeight));
    // The selection shrinks to a dot on today's ring.
    expect(tester.getSize(_key('week-selection')).width, lessThan(40));

    await tester.tap(find.text('روزانه'));
    await tester.pumpAndSettle();
    expect(tester.getSize(_key('week-tray')).height, dailyHeight);
  });

  testWidgets('the strip folds and follows the board without rebuilding',
      (tester) async {
    await _pumpTasksScreen(tester);
    Widget strip() => tester.element(_key('week-strip')).widget;

    await tester.tap(find.text('هفتگی'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    final folding = strip();
    for (var frame = 0; frame < 20; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(identical(strip(), folding), isTrue, reason: 'frame $frame');
    }
    await tester.pumpAndSettle();

    // Scrolling the board moves the window behind the rings by repaint.
    final settled = strip();
    final columns = find.byWidgetPredicate((widget) =>
        widget.key is ValueKey<String> &&
        (widget.key! as ValueKey<String>).value.startsWith('week-columns-'));
    final gesture = await tester.startGesture(tester.getCenter(columns));
    for (var step = 0; step < 8; step++) {
      await gesture.moveBy(const Offset(12, 0));
      await tester.pump();
      expect(identical(strip(), settled), isTrue);
    }
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('the week switcher turns the week', (tester) async {
    await _pumpTasksScreen(tester, weekly: true);
    final thisWeek = weekStartOf(today);
    Jalali selected() =>
        tester.widget<WeekHeader>(find.byType(WeekHeader)).selectedDate;

    // Days run right to left: the previous week lies to the right.
    expect(
      tester.getCenter(_key('week-nav-previous')).dx,
      greaterThan(tester.getCenter(_key('week-nav-next')).dx),
    );
    Icon iconOf(String key) => tester.widget<Icon>(
        find.descendant(of: _key(key), matching: find.byType(Icon)));
    expect(iconOf('week-nav-previous').icon, Icons.chevron_right_rounded);
    expect(iconOf('week-nav-previous').textDirection, TextDirection.ltr);

    await tester.tap(_key('week-nav-next'));
    await tester.pumpAndSettle();
    expect(ymd(selected()), ymd(thisWeek.addDays(7)));

    await tester.tap(_key('week-nav-previous'));
    await tester.pumpAndSettle();
    expect(ymd(selected()), ymd(today));
  });
}
