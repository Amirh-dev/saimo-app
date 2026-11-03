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
  _CounselorsGraphQLRepository(
    TokenStorage storage, {
    this.error,
    this.answer,
    this.major,
  }) : super(
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
  final String? major;

  @override
  Future<Map<String, dynamic>> rawRequest({
    required String query,
    Map<String, dynamic> variables = const {},
    bool requiresAuth = true,
  }) async {
    final failure = error;
    if (failure != null) throw failure;
    return {
      'counselors': answer ?? const [],
      'getMe': {'major': major},
    };
  }
}

Future<_CounselorsGraphQLRepository> _pumpList(
  WidgetTester tester, {
  Object? error,
  List<Map<String, dynamic>>? answer,
  String? major,
}) async {
  SharedPreferences.setMockInitialValues({});
  final graphql = _CounselorsGraphQLRepository(
    await TokenStorage.create(),
    error: error,
    answer: answer,
    major: major,
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

  testWidgets('a list of the student\'s major names that major',
      (tester) async {
    await _pumpList(tester, major: 'MATHEMATICS', answer: [
      _counselor('MATHEMATICS'),
    ]);

    expect(find.text('مشاوران رشته ریاضی'), findsOneWidget);
    expect(find.text('انتخاب مشاور'), findsOneWidget);
  });

  testWidgets('a major with no counselors says so over the full list',
      (tester) async {
    await _pumpList(tester, major: 'ART', answer: [_counselor('SCIENCE')]);

    expect(find.text('همه مشاوران'), findsOneWidget);
    expect(find.text('فعلاً مشاوری برای رشته هنر نداریم.'), findsOneWidget);
    expect(find.text('تجربی'), findsOneWidget);
  });

  testWidgets('a student without a major is asked to set one', (tester) async {
    await _pumpList(tester, answer: [_counselor('SCIENCE')]);

    expect(
      find.text('برای دیدن مشاوران رشته خود، رشته‌تان را در پروفایل ثبت کنید.'),
      findsOneWidget,
    );
  });

  testWidgets('an unrated counselor is marked new, not rated zero',
      (tester) async {
    await _pumpList(tester, answer: [_counselor('SCIENCE')]);

    expect(find.text('مشاور جدید'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNothing);
  });
}

Map<String, dynamic> _counselor(String major) => {
      'id': 'profile-1',
      'title': 'مشاور تحصیلی',
      'ratingAverage': 0,
      'ratingCount': 0,
      'resumeItems': ['ده سال سابقه'],
      'user': {'fullName': 'سارا احمدی', 'major': major},
    };
