import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/data/activity/app_activity_reporter.dart';
import 'package:simo_learn/data/activity/error_reporting.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';

class _Call {
  _Call(this.query, this.variables);
  final String query;
  final Map<String, dynamic> variables;
}

void main() {
  late List<_Call> calls;
  late DateTime now;
  late Object? failWith;

  AppActivityReporter build() => AppActivityReporter(
        send: (query, variables) async {
          if (failWith != null) throw failWith!;
          calls.add(_Call(query, variables));
        },
        loadBuildInfo: () async => const AppBuildInfo(
          appVersion: '1.0.43',
          buildNumber: '43',
          platform: 'ANDROID',
        ),
        clock: () => now,
        flushInterval: const Duration(hours: 1),
        errorDelay: const Duration(hours: 1),
      );

  setUp(() {
    calls = [];
    now = DateTime(2026, 11, 10, 9);
    failWith = null;
  });

  Map<String, dynamic> input(_Call call) =>
      call.variables['input'] as Map<String, dynamic>;

  Iterable<_Call> activityCalls() =>
      calls.where((c) => c.query.contains('ReportAppActivity'));

  int total(String field) =>
      activityCalls().fold(0, (sum, c) => sum + (input(c)[field] as int));

  Map<String, int> views() {
    final result = <String, int>{};
    for (final call in activityCalls()) {
      for (final item in input(call)['screenViews'] as List) {
        final view = item as Map<String, dynamic>;
        result.update(
            view['screen'] as String, (value) => value + (view['views'] as int),
            ifAbsent: () => view['views'] as int);
      }
    }
    return result;
  }

  test('sends nothing before sign-in, then the launch and its time', () async {
    final reporter = build();
    reporter.currentScreen = () => 'home';
    reporter.appShown();
    await reporter.flush();
    expect(calls, isEmpty);

    await reporter.setSignedIn(true);
    now = now.add(const Duration(seconds: 90));
    reporter.screenViewed('statistics');
    reporter.appHidden();
    await pumpEventQueue();

    expect(calls.first.query, contains('mutation ReportAppActivity'));
    expect(total('opens'), 1);
    expect(total('foregroundSeconds'), 90);
    expect(input(calls.first)['appVersion'], '1.0.43');
    expect(views(), {'home': 1, 'statistics': 1});
  });

  test('a return from the background is another open and view', () async {
    final reporter = build();
    reporter.currentScreen = () => 'tasks';
    await reporter.setSignedIn(true);
    reporter.appShown();
    reporter.appHidden();
    await pumpEventQueue();
    calls.clear();

    reporter.appShown();
    reporter.appShown(); // already visible: not counted twice
    now = now.add(const Duration(seconds: 30));
    reporter.appHidden();
    await pumpEventQueue();

    expect(total('opens'), 1);
    expect(total('foregroundSeconds'), 30);
    expect(views(), {'tasks': 1});
  });

  test('a failed send keeps the counts for the next one', () async {
    final reporter = build();
    await reporter.setSignedIn(true);
    reporter.appShown();
    failWith = Exception('offline');
    reporter.appHidden();
    await pumpEventQueue();
    expect(calls, isEmpty);
    expect(reporter.pendingOpens, 1);

    failWith = null;
    reporter.appShown();
    reporter.appHidden();
    await pumpEventQueue();
    expect(total('opens'), 2);
  });

  test('an older server without the mutation turns reporting off', () async {
    final reporter = build();
    await reporter.setSignedIn(true);
    reporter.appShown();
    failWith = const GraphQLRawException(
        'Cannot query field "reportAppActivity" on type "Mutation".');
    reporter.appHidden();
    await pumpEventQueue();

    failWith = null;
    reporter.appShown();
    reporter.recordError(StateError('boom'), StackTrace.current);
    reporter.appHidden();
    await pumpEventQueue();
    expect(calls, isEmpty);
    expect(reporter.pendingOpens, 0);
  });

  test('repeated errors are folded and sent with the build', () async {
    final reporter = build();
    await reporter.setSignedIn(true);
    final stack = StackTrace.fromString('#0 main (file.dart:1)\n#1 other');
    reporter.recordError(StateError('bad state'), stack);
    reporter.recordError(StateError('bad state'), stack);
    reporter.recordError(ArgumentError('other'), null);
    await reporter.flush();

    final errorCall =
        calls.singleWhere((c) => c.query.contains('ReportClientErrors'));
    final errors = errorCall.variables['errors'] as List;
    expect(errors, hasLength(2));
    final first = errors.first as Map<String, dynamic>;
    expect(first['message'], 'Bad state: bad state');
    expect(first['count'], 2);
    expect(first['stack'], startsWith('#0 main'));
    expect(first['appVersion'], '1.0.43');
    expect(reporter.pendingErrorCount, 0);
  });

  test('connectivity failures are not reported', () async {
    final reporter = build();
    await reporter.setSignedIn(true);
    reporter.recordError(
      Exception("ServerException(originalException: ClientException with "
          "SocketException: Failed host lookup: 'api.saimo.app' "
          "(OS Error: No address associated with hostname, errno = 7))"),
      StackTrace.current,
    );
    reporter.recordError(
        Exception('HandshakeException: Connection terminated'), null);
    expect(reporter.pendingErrorCount, 0);

    reporter.recordError(StateError('real bug'), null);
    expect(reporter.pendingErrorCount, 1);
  });

  test('signing out sends what is pending and forgets the rest', () async {
    final reporter = build();
    await reporter.setSignedIn(true);
    reporter.appShown();
    now = now.add(const Duration(seconds: 10));
    await reporter.setSignedIn(false);
    expect(total('foregroundSeconds'), 10);

    calls.clear();
    reporter.screenViewed('home'); // ignored while signed out
    reporter.appHidden();
    await pumpEventQueue();
    expect(calls, isEmpty);
  });

  test('operation names never trigger task, goal or profile reloads', () {
    for (final query in [
      AppActivityReporter.reportActivityMutation,
      AppActivityReporter.reportErrorsMutation,
    ]) {
      final name = GraphQLRepository.mutationNameOf(query)!;
      expect(name, isNot(contains('Task')));
      expect(name, isNot(contains('Goal')));
      expect(name, isNot(contains('Profile')));
    }
  });

  test('image download failures and silent errors are not reported', () {
    expect(
      shouldReportFlutterError(FlutterErrorDetails(
        exception: Exception('404'),
        library: 'image resource service',
      )),
      isFalse,
    );
    expect(
      shouldReportFlutterError(
          FlutterErrorDetails(exception: Exception('x'), silent: true)),
      isFalse,
    );
    expect(
      shouldReportFlutterError(FlutterErrorDetails(
          exception: Exception('x'), library: 'widgets library')),
      isTrue,
    );
  });
}
