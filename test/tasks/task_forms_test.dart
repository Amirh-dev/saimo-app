import 'dart:io';

import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
// gql_exec is exposed by Ferry for building test responses.
// ignore: depend_on_referenced_packages
import 'package:gql_exec/gql_exec.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/graphql/mutations/__generated__/create_task.data.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/create_task.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/create_task.var.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/update_task.data.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/update_task.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/update_task.var.gql.dart';
import 'package:simo_learn/presentation/screens/tasks/add_task/index.dart';
import 'package:simo_learn/presentation/screens/tasks/tasks_api.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly_repeat.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'support/app_fonts.dart';

Finder _key(String value) => find.byKey(ValueKey(value));

/// The next Monday from today (today, if it is one). Jalali weeks start on
/// Saturday, so Monday is weekday 3.
Jalali _nextMonday() {
  final today = Jalali.now();
  return today.addDays((3 - today.weekDay) % 7);
}

/// Answers the forms' typed requests: tag suggestions fail quietly, and
/// creating a task gives [onCreate]'s response.
class _FormsRepository extends GraphQLRepository {
  _FormsRepository(TokenStorage storage)
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

  final List<GCreateTaskReq> creates = [];

  /// What a create request gets back.
  OperationResponse<GCreateTaskData, GCreateTaskVars> Function(
      GCreateTaskReq request)? onCreate;

  @override
  Future<OperationResponse<TData, TVars>> requestOnce<TData, TVars>(
    OperationRequest<TData, TVars> request, {
    bool requiresAuth = true,
    bool skipAuthRefresh = false,
  }) async {
    if (request is GCreateTaskReq) {
      final create = request as GCreateTaskReq;
      creates.add(create);
      return onCreate!(create) as OperationResponse<TData, TVars>;
    }
    if (request is GUpdateTaskReq) {
      final update = request as GUpdateTaskReq;
      updates.add(update);
      return OperationResponse<GUpdateTaskData, GUpdateTaskVars>(
        operationRequest: update,
        data: GUpdateTaskData.fromJson({
          '__typename': 'Mutation',
          'updateTask': {
            '__typename': 'Task',
            'id': update.vars.id,
            'createdAt': '2026-10-13T08:00:00Z',
            'updatedAt': '2026-10-13T08:00:00Z',
            'title': update.vars.input.title ?? 'تسک',
            'type': 'NORMAL',
            'date': '2026-10-13T00:00:00Z',
            'elapsedSeconds': 0,
            'hasReminder': update.vars.input.hasReminder ?? false,
            'status': 'TODO',
            'userID': 'me',
          },
        }),
      ) as OperationResponse<TData, TVars>;
    }
    return OperationResponse<TData, TVars>(
      operationRequest: request,
      graphqlErrors: const [GraphQLError(message: 'not in this test')],
    );
  }

  final List<GUpdateTaskReq> updates = [];

  /// Raw requests sent, as their variables.
  final List<Map<String, dynamic>> raws = [];

  @override
  Future<Map<String, dynamic>> rawRequest({
    required String query,
    Map<String, dynamic> variables = const {},
    bool requiresAuth = true,
  }) async {
    raws.add(variables);
    return const {};
  }
}

OperationResponse<GCreateTaskData, GCreateTaskVars> _created(
  GCreateTaskReq request,
) {
  final input = request.vars.input;
  return OperationResponse(
    operationRequest: request,
    data: GCreateTaskData.fromJson({
      '__typename': 'Mutation',
      'createTask': {
        '__typename': 'Task',
        'id': 'new-task',
        'createdAt': '2026-10-13T08:00:00Z',
        'updatedAt': '2026-10-13T08:00:00Z',
        'title': input.title,
        'shortDescription': input.shortDescription,
        'note': input.note,
        'type': input.type?.name ?? 'NORMAL',
        'date': input.date?.value ?? '2026-10-13T00:00:00Z',
        'durationM': input.durationM,
        'elapsedSeconds': 0,
        'timerStartedAt': null,
        'completedAt': null,
        'hasReminder': false,
        'reminderTime': null,
        'recurringDays': null,
        'status': 'TODO',
        'userID': 'me',
        'goalID': null,
      },
    }),
  );
}

Future<_FormsRepository> _pumpForm(
  WidgetTester tester,
  Widget form, {
  List<Object?>? popped,
  Map<String, Object> prefs = const {},
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 1100));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  SharedPreferences.setMockInitialValues(prefs);
  final repository = _FormsRepository(await TokenStorage.create());
  await tester.pumpWidget(
    RepositoryProvider<GraphQLRepository>.value(
      value: repository,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push<Object?>(
                    MaterialPageRoute(builder: (_) => form),
                  );
                  popped?.add(result);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  group('full task forms', () {
    testWidgets('a missing title is shown on the field, nothing is sent',
        (tester) async {
      final repository = await _pumpForm(tester, const AddTaskScreen());

      await tester.tap(_key('task-form-submit'));
      await tester.pumpAndSettle();

      expect(find.text('عنوان تسک رو بنویس.'), findsOneWidget);
      expect(repository.creates, isEmpty);

      // Typing clears it.
      await tester.enterText(_key('task-form-title'), 'خرید کتاب');
      await tester.pumpAndSettle();
      expect(find.text('عنوان تسک رو بنویس.'), findsNothing);
    });

    testWidgets('a refused tag is named in the error box, form stays open',
        (tester) async {
      final repository = await _pumpForm(
        tester,
        const AddTaskScreen(initialTitle: 'تمرین', initialTags: ['ممنوع']),
      );
      repository.onCreate = (request) => OperationResponse(
            operationRequest: request,
            graphqlErrors: const [
              GraphQLError(
                message: 'blocked tags cannot be assigned to tasks: ممنوع',
              ),
            ],
          );

      await tester.tap(_key('task-form-submit'));
      await tester.pumpAndSettle();

      expect(repository.creates, hasLength(1));
      expect(
        find.text('تگ «ممنوع» قابل استفاده نیست؛ برش دار و دوباره ثبت کن.'),
        findsOneWidget,
      );
      expect(find.byType(AddTaskScreen), findsOneWidget);
    });

    testWidgets('no connection says so, and the next try clears it',
        (tester) async {
      final repository = await _pumpForm(
        tester,
        const AddTimedTaskScreen(initialTitle: 'مطالعه', initialMinutes: 60),
      );
      repository.onCreate = (request) => OperationResponse(
            operationRequest: request,
            linkException: const ServerException(
              originalException: SocketException('Failed host lookup'),
            ),
          );

      await tester.tap(_key('task-form-submit'));
      await tester.pumpAndSettle();
      expect(
        find.text('اینترنت وصل نیست؛ اتصالت رو چک کن و دوباره امتحان کن.'),
        findsOneWidget,
      );

      repository.onCreate = _created;
      await tester.tap(_key('task-form-submit'));
      await tester.pumpAndSettle();
      expect(find.byType(AddTimedTaskScreen), findsNothing); // saved, closed
      expect(repository.creates.last.vars.input.durationM, 60);
    });

    testWidgets('a timed task is created with the chosen duration and tags',
        (tester) async {
      final popped = <Object?>[];
      final repository = await _pumpForm(
        tester,
        const AddTimedTaskScreen(
          initialTitle: 'حل تمرین',
          initialTags: ['ریاضی'],
        ),
        popped: popped,
      );
      repository.onCreate = _created;

      await tester.tap(_key('task-form-minutes-90'));
      await tester.pumpAndSettle();
      await tester.tap(_key('task-form-submit'));
      await tester.pumpAndSettle();

      final input = repository.creates.single.vars.input;
      expect(input.title, 'حل تمرین');
      expect(input.durationM, 90);
      expect(input.tagNames!.toList(), ['ریاضی']);
      expect((popped.single as Map)['id'], 'new-task');
    });
  });

  group('weekly repeat', () {
    const tip = 'درس‌هایی که هر هفته داری رو یه بار بساز.';

    testWidgets('the first time, a tip points at «هر هفته» and is remembered',
        (tester) async {
      await _pumpForm(tester, const AddTaskScreen(initialTitle: 'فیزیک'));

      expect(find.text(tip), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(weeklyRepeatTipSeenKey), isTrue);

      await tester.tap(_key('repeat-tip'));
      await tester.pumpAndSettle();
      expect(find.text(tip), findsNothing);
      expect(_key('repeat-day-SAT'), findsNothing); // still one day
    });

    testWidgets('the tip does not come back', (tester) async {
      await _pumpForm(
        tester,
        const AddTaskScreen(initialTitle: 'فیزیک'),
        prefs: {weeklyRepeatTipSeenKey: true},
      );
      expect(find.text(tip), findsNothing);
      expect(_key('repeat-weekly'), findsOneWidget);
    });

    testWidgets('«هر هفته» starts from the picked day and sends the days',
        (tester) async {
      final repository = await _pumpForm(
        tester,
        AddTaskScreen(initialTitle: 'فیزیک', initialDate: _nextMonday()),
      );
      repository.onCreate = _created;

      await tester.tap(_key('repeat-weekly'));
      await tester.pumpAndSettle();
      expect(find.text(tip), findsNothing);
      // The picked date was a Monday: in the header and under the circles.
      expect(find.text('هر دوشنبه'), findsNWidgets(2));
      expect(_key('repeat-first-day'), findsOneWidget);

      for (final day in ['SAT', 'WED']) {
        await tester.tap(_key('repeat-day-$day'));
      }
      await tester.pumpAndSettle();
      expect(find.text('هر شنبه، دوشنبه و چهارشنبه'), findsNWidgets(2));

      await tester.tap(_key('task-form-submit'));
      await tester.pumpAndSettle();
      final input = repository.creates.single.vars.input;
      expect(input.recurrence!.weekdays.toList(), ['SAT', 'MON', 'WED']);
      expect(input.date, isNull);
    });

    testWidgets('«هر روز» picks all seven, and again clears them',
        (tester) async {
      await _pumpForm(
        tester,
        const AddTimedTaskScreen(initialTitle: 'مطالعه', initialMinutes: 60),
      );
      await tester.tap(_key('repeat-weekly'));
      await tester.pumpAndSettle();

      await tester.tap(_key('repeat-every-day'));
      await tester.pumpAndSettle();
      expect(find.text('هر روز'), findsNWidgets(3)); // header, summary, pill

      await tester.tap(_key('repeat-every-day'));
      await tester.pumpAndSettle();
      expect(find.text('روزهای تکرار رو انتخاب کن.'), findsOneWidget);
      expect(_key('repeat-first-day'), findsNothing);

      // Back to one day shows the date again.
      await tester.tap(_key('repeat-one-day'));
      await tester.pumpAndSettle();
      expect(_key('repeat-day-SAT'), findsNothing);
    });

    testWidgets('weekly days from quick add open in weekly mode',
        (tester) async {
      await _pumpForm(
        tester,
        const AddTaskScreen(
          initialTitle: 'فیزیک',
          initialWeekdays: ['SUN', 'TUE'],
        ),
      );
      // In the header and under the day circles.
      expect(find.text('هر یکشنبه و سه‌شنبه'), findsNWidgets(2));
    });

    testWidgets('the timed form folds the note into a chip', (tester) async {
      await _pumpForm(
        tester,
        const AddTimedTaskScreen(initialTitle: 'مطالعه', initialMinutes: 60),
      );
      expect(_key('task-form-note'), findsNothing);

      await tester.tap(_key('task-form-add-note'));
      await tester.pumpAndSettle();
      expect(_key('task-form-note'), findsOneWidget);
      expect(_key('task-form-add-note'), findsNothing);
    });

    testWidgets('on the web the reminder is off and says why', (tester) async {
      debugTaskRemindersSupported = false;
      addTearDown(() => debugTaskRemindersSupported = null);
      await _pumpForm(tester, const AddTaskScreen(initialTitle: 'فیزیک'));

      expect(_key('task-form-reminder-unsupported'), findsOneWidget);
      expect(find.text('یادآوری فقط تو اپ گوشی کار می‌کنه.'), findsOneWidget);
    });

    testWidgets(
        'a weekly reminder sends its time; an old server gets it again '
        'without', (tester) async {
      // The time wheels overflow in the square test font; use the app's.
      await tester.runAsync(loadAppFonts);
      final repository = await _pumpForm(
        tester,
        const AddTaskScreen(initialTitle: 'فیزیک'),
        prefs: {weeklyRepeatTipSeenKey: true},
      );
      repository.onCreate = (request) => request.vars.input.reminderTime != null
          ? OperationResponse(
              operationRequest: request,
              graphqlErrors: const [
                GraphQLError(message: 'reminderTime not allowed'),
              ],
            )
          : _created(request);

      await tester.tap(_key('repeat-weekly'));
      await tester.pumpAndSettle();
      await tester.tap(find.byWidgetPredicate(
          (widget) => widget.runtimeType.toString() == '_ReminderSwitch'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('تنظیم یادآوری'));
      await tester.pumpAndSettle();

      await tester.tap(_key('task-form-submit'));
      await tester.pumpAndSettle();

      expect(repository.creates, hasLength(2));
      expect(repository.creates.first.vars.input.reminderTime, isNotNull);
      expect(repository.creates.last.vars.input.reminderTime, isNull);
      expect(repository.creates.last.vars.input.hasReminder, isTrue);
      expect(find.byType(AddTaskScreen), findsNothing); // saved, closed
    });

    testWidgets(
        'turning off the reminder on one day of a weekly task turns it off '
        'for the series', (tester) async {
      final repository = await _pumpForm(
        tester,
        AddTaskScreen(task: {
          'id': 'occ-1',
          'title': 'مرور فیزیک',
          'date': Jalali.now(),
          'reminder': true,
          'reminderTime': DateTime(2026, 11, 16, 21),
          'recurringDays': 'SAT,TUE',
          'recurrenceId': 'rec-1',
        }),
      );

      await tester.tap(find.byWidgetPredicate(
          (widget) => widget.runtimeType.toString() == '_ReminderSwitch'));
      await tester.pumpAndSettle();
      await tester.tap(_key('task-form-submit'));
      await tester.pumpAndSettle();

      expect(repository.updates.single.vars.input.hasReminder, isFalse);
      expect(repository.raws.single, {
        'id': 'occ-1',
        'input': {
          'hasReminder': false,
          'recurrenceScope': 'FUTURE_OCCURRENCES',
        },
      });
    });

    testWidgets(
        'an edit that leaves the reminder alone does not touch the '
        'series', (tester) async {
      final repository = await _pumpForm(
        tester,
        AddTaskScreen(task: {
          'id': 'occ-1',
          'title': 'مرور فیزیک',
          'date': Jalali.now(),
          'reminder': true,
          'reminderTime': DateTime(2026, 11, 16, 21),
          'recurringDays': 'SAT,TUE',
          'recurrenceId': 'rec-1',
        }),
      );
      await tester.tap(_key('task-form-submit'));
      await tester.pumpAndSettle();

      expect(repository.updates, hasLength(1));
      expect(repository.raws, isEmpty);
    });

    test('the first day is the next picked weekday from today', () {
      final monday = Jalali(1405, 8, 25); // دوشنبه ۲۵ آبان
      Jalali first(Set<String> days) => firstRepeatDay(days, monday)!;

      expect(first({'MON'}), monday);
      expect(firstRepeatDayTag(first({'MON'}), monday), 'امروز');
      expect(first({'TUE', 'SAT'}), Jalali(1405, 8, 26));
      expect(firstRepeatDayTag(first({'TUE'}), monday), 'فردا');
      expect(first({'THU'}), Jalali(1405, 8, 28));
      expect(firstRepeatDayTag(first({'THU'}), monday), isNull);
      // Sunday has passed this week: next week, the first of Azar.
      expect(first({'SUN'}), Jalali(1405, 9, 1));
      expect(firstRepeatDayTag(first({'SUN'}), monday), 'هفته بعد');
      expect(firstRepeatDay({}, monday), isNull);
    });

    test('the summary names the days in week order', () {
      expect(weeklyRepeatSummary({'WED', 'SAT'}), 'هر شنبه و چهارشنبه');
      expect(weeklyRepeatSummary({'FRI'}), 'هر جمعه');
      expect(
        weeklyRepeatSummary({'SAT', 'SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI'}),
        'هر روز',
      );
    });
  });

  group('taskFailureMessage', () {
    test('names what went wrong, or falls back', () {
      expect(
        taskFailureMessage(const SocketException('x'), fallback: 'f'),
        startsWith('اینترنت وصل نیست'),
      );
      expect(
        taskFailureMessage(const UnauthorizedException(), fallback: 'f'),
        startsWith('لطفاً دوباره وارد حسابت شو'),
      );
      expect(
        taskFailureMessage('specified goal not found', fallback: 'f'),
        startsWith('هدف این تسک'),
      );
      expect(taskFailureMessage('something odd', fallback: 'f'), 'f');
    });
  });
}
