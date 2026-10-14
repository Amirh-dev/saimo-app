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
import 'package:simo_learn/presentation/screens/tasks/add_task/index.dart';
import 'package:simo_learn/presentation/screens/tasks/tasks_api.dart';

Finder _key(String value) => find.byKey(ValueKey(value));

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
    return OperationResponse<TData, TVars>(
      operationRequest: request,
      graphqlErrors: const [GraphQLError(message: 'not in this test')],
    );
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
        'subjectTagID': null,
      },
    }),
  );
}

Future<_FormsRepository> _pumpForm(
  WidgetTester tester,
  Widget form, {
  List<Object?>? popped,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 1100));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  SharedPreferences.setMockInitialValues({});
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

      expect(find.text('عنوان تسک را بنویسید.'), findsOneWidget);
      expect(repository.creates, isEmpty);

      // Typing clears it.
      await tester.enterText(_key('task-form-title'), 'خرید کتاب');
      await tester.pumpAndSettle();
      expect(find.text('عنوان تسک را بنویسید.'), findsNothing);
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
        find.text('تگ «ممنوع» قابل استفاده نیست؛ آن را بردارید و دوباره ثبت کنید.'),
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
        find.text(
            'اتصال به اینترنت برقرار نیست؛ اتصال را بررسی کنید و دوباره تلاش کنید.'),
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

  group('taskFailureMessage', () {
    test('names what went wrong, or falls back', () {
      expect(
        taskFailureMessage(const SocketException('x'), fallback: 'f'),
        startsWith('اتصال به اینترنت'),
      );
      expect(
        taskFailureMessage(const UnauthorizedException(), fallback: 'f'),
        startsWith('نشست شما'),
      );
      expect(
        taskFailureMessage('specified goal not found', fallback: 'f'),
        startsWith('هدف این تسک'),
      );
      expect(taskFailureMessage('something odd', fallback: 'f'), 'f');
    });
  });
}
