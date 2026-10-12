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

import 'support/app_fonts.dart';

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
      'subjectTag': null,
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

  testWidgets('the mode switch sits under the header in both modes',
      (tester) async {
    await _pumpTasksScreen(tester);
    expect(_key('tasks-view-mode-toggle'), findsOneWidget);
    expect(find.text('انتخاب تاریخ'), findsOneWidget);

    await tester.tap(find.text('هفتگی'));
    await tester.pumpAndSettle();
    expect(_key('weekly-plan-view'), findsOneWidget);
    expect(_key('tasks-view-mode-toggle'), findsOneWidget);
    expect(_key('tasks-add-button'), findsOneWidget);

    await tester.tap(find.text('روزانه'));
    await tester.pumpAndSettle();
    expect(_key('weekly-plan-view'), findsNothing);
  });
}
