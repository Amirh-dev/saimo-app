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
    this.reviews = const [],
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
  final List<Map<String, dynamic>> reviews;

  /// Variables of every reviews request, in order.
  final List<Map<String, dynamic>> reviewRequests = [];

  @override
  Future<Map<String, dynamic>> rawRequest({
    required String query,
    Map<String, dynamic> variables = const {},
    bool requiresAuth = true,
  }) async {
    final failure = error;
    if (failure != null) throw failure;
    if (query.contains('counselorReviews(')) {
      reviewRequests.add(variables);
      final min = variables['minScore'] as int? ?? 1;
      final max = variables['maxScore'] as int? ?? 5;
      return {
        'counselorReviews': [
          for (final review in reviews)
            if ((review['score'] as int) >= min &&
                (review['score'] as int) <= max)
              review,
        ],
      };
    }
    if (query.contains('counselorRatingDistribution')) {
      return {
        'counselorRatingDistribution': [
          for (var score = 5; score >= 1; score--)
            {
              'score': score,
              'count': reviews.where((r) => r['score'] == score).length,
            },
        ],
      };
    }
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
  List<Map<String, dynamic>> reviews = const [],
}) async {
  SharedPreferences.setMockInitialValues({});
  final graphql = _CounselorsGraphQLRepository(
    await TokenStorage.create(),
    error: error,
    answer: answer,
    major: major,
    reviews: reviews,
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

    expect(
      find.textContaining('مشاور جدید', findRichText: true),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.star_rounded), findsNothing);
    // Nothing to read yet, so no reviews button.
    expect(find.text('نظرات'), findsNothing);
  });

  testWidgets('the card highlights the first résumé item and lists the rest',
      (tester) async {
    await _pumpList(tester, answer: [_ratedCounselor()]);

    expect(find.text('رتبه ۱۲۰ کنکور ریاضی'), findsOneWidget);
    expect(find.text('شش سال سابقه مشاوره تحصیلی'), findsOneWidget);
    expect(
      find.textContaining('(۳۲ نظر)', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('رزومه مشاور'), findsNothing);
  });

  testWidgets('«نظرات» opens the reviews sheet, filters by score',
      (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final long = 'برنامه‌ریزی دقیق و پیگیری منظم داشتند. ' * 6;
    final graphql = await _pumpList(
      tester,
      answer: [_ratedCounselor()],
      reviews: [
        _review('r1', 'سارا ر.', 5, 'خیلی دقیق بودند.'),
        _review('r2', 'امیر ح.', 3, long),
        _review('r3', 'نگار ص.', 4, null),
      ],
    );

    await tester.tap(find.text('نظرات'));
    await tester.pumpAndSettle();

    expect(find.text('نظرات دانش‌آموزان'), findsOneWidget);
    expect(find.text('از ۳۲ نظر'), findsOneWidget);
    expect(find.text('سارا ر.'), findsOneWidget);
    expect(find.text('نگار ص.'), findsOneWidget);
    expect(find.text('ادامه'), findsOneWidget);
    expect(graphql.reviewRequests.single['counselorProfileID'], 'profile-1');

    await tester.ensureVisible(find.text('۳ ستاره و کمتر'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('۳ ستاره و کمتر'));
    await tester.pumpAndSettle();
    expect(graphql.reviewRequests.last['maxScore'], 3);
    expect(graphql.reviewRequests.last.containsKey('minScore'), isFalse);
    expect(find.text('امیر ح.'), findsOneWidget);
    expect(find.text('سارا ر.'), findsNothing);

    await tester.tap(find.text('ادامه'));
    await tester.pumpAndSettle();
    expect(find.text('بستن'), findsOneWidget);

    await tester.ensureVisible(find.text('۵ ستاره'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('۵ ستاره'));
    await tester.pumpAndSettle();
    expect(graphql.reviewRequests.last['minScore'], 5);
    expect(find.text('سارا ر.'), findsOneWidget);
  });

  testWidgets('a filter with no reviews says so', (tester) async {
    await _pumpList(
      tester,
      answer: [_ratedCounselor()],
      reviews: [_review('r1', 'سارا ر.', 5, 'عالی')],
    );
    await tester.tap(find.text('نظرات'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('۴ ستاره'));
    await tester.pumpAndSettle();
    expect(find.text('نظری با این امتیاز ثبت نشده است'), findsOneWidget);
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

Map<String, dynamic> _ratedCounselor() => {
      'id': 'profile-1',
      'title': 'مشاور کنکور ریاضی',
      'ratingAverage': 4.8,
      'ratingCount': 32,
      'resumeItems': [
        'رتبه ۱۲۰ کنکور ریاضی',
        'شش سال سابقه مشاوره تحصیلی',
        'دانشجوی مهندسی برق دانشگاه شریف',
      ],
      'user': {
        'fullName': 'سارا احمدی',
        'major': 'MATHEMATICS',
        'bio': 'برنامه‌ریزی را با توان واقعی شما شروع می‌کنم.',
      },
    };

Map<String, dynamic> _review(
  String id,
  String author,
  int score,
  String? comment,
) =>
    {
      'id': id,
      'authorName': author,
      'createdAt': '2026-11-03T09:00:00Z',
      'score': score,
      'comment': comment,
    };
