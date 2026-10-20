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
import 'package:simo_learn/presentation/screens/consultants/consultant_models.dart';
import 'package:simo_learn/presentation/screens/consultants/list_screen.dart';

/// Answers the counselors query with [answer], or throws [error].
class _CounselorsGraphQLRepository extends GraphQLRepository {
  _CounselorsGraphQLRepository(TokenStorage storage, {this.error, this.answer})
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

  Object? error;
  final List<Map<String, dynamic>>? answer;

  @override
  Future<Map<String, dynamic>> rawRequest({
    required String query,
    Map<String, dynamic> variables = const {},
    bool requiresAuth = true,
  }) async {
    final failure = error;
    if (failure != null) throw failure;
    return {'counselors': answer ?? const []};
  }
}

Future<_CounselorsGraphQLRepository> _pumpList(
  WidgetTester tester, {
  Object? error,
  List<Map<String, dynamic>>? answer,
}) async {
  SharedPreferences.setMockInitialValues({});
  final graphql = _CounselorsGraphQLRepository(
    await TokenStorage.create(),
    error: error,
    answer: answer,
  );
  await tester.pumpWidget(
    RepositoryProvider<GraphQLRepository>.value(
      value: graphql,
      child: const MaterialApp(home: ConsultantListScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return graphql;
}

void main() {
  testWidgets('an account the server refuses is told to contact support',
      (tester) async {
    await _pumpList(
      tester,
      error: const GraphQLRawException('forbidden: insufficient permissions'),
    );

    expect(find.text(kCounselingNoAccessTitle), findsOneWidget);
    expect(find.text(kCounselingNoAccessMessage), findsOneWidget);
    expect(find.text('انتخاب مشاور'), findsNothing);
    expect(find.text('تلاش دوباره'), findsNothing);
  });

  testWidgets('a failed request offers a retry instead of sample counselors',
      (tester) async {
    final graphql = await _pumpList(
      tester,
      error: const GraphQLRawException('SocketException: Failed host lookup'),
    );

    expect(find.text('دریافت فهرست مشاوران ممکن نشد'), findsOneWidget);
    expect(find.text('علیرضا یوسفی'), findsNothing);

    graphql.error = null;
    await tester.tap(find.text('تلاش دوباره'));
    await tester.pumpAndSettle();

    expect(find.text('فعلاً مشاوری در دسترس نیست'), findsOneWidget);
  });

  testWidgets('counselors from the server are listed', (tester) async {
    await _pumpList(tester, answer: [
      {
        'id': 'profile-1',
        'title': 'مشاور تحصیلی',
        'ratingAverage': 4.5,
        'resumeItems': ['ده سال سابقه'],
        'user': {'fullName': 'سارا احمدی'},
      },
    ]);

    expect(find.text('سارا احمدی'), findsOneWidget);
    expect(find.text(kCounselingNoAccessTitle), findsNothing);
  });
}
