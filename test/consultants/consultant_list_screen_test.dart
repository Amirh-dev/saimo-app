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
import 'package:simo_learn/presentation/screens/consultants/details_screen.dart';
import 'package:simo_learn/presentation/screens/consultants/list_screen.dart';
import 'package:simo_learn/presentation/screens/consultants/reviews_sheet.dart';

/// Answers the counselors query with [answer], or throws [error].
class _CounselorsGraphQLRepository extends GraphQLRepository {
  _CounselorsGraphQLRepository(
    TokenStorage storage, {
    this.error,
    this.answer,
    this.major,
    this.reviews = const [],
    this.studentCount = 0,
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
  final int studentCount;

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
    if (query.contains('counselorStudentCount(')) {
      return {'counselorStudentCount': studentCount};
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
  int studentCount = 0,
  ValueChanged<Consultant>? onSelect,
}) async {
  SharedPreferences.setMockInitialValues({});
  final graphql = _CounselorsGraphQLRepository(
    await TokenStorage.create(),
    error: error,
    answer: answer,
    major: major,
    reviews: reviews,
    studentCount: studentCount,
  );
  await tester.pumpWidget(
    RepositoryProvider<GraphQLRepository>.value(
      value: graphql,
      child: MaterialApp(home: ConsultantListScreen(onSelect: onSelect)),
    ),
  );
  await tester.pumpAndSettle();
  return graphql;
}

/// Opens the first card's details page.
Future<void> _openDetails(WidgetTester tester) async {
  await tester.tap(find.text('جزئیات'));
  await tester.pumpAndSettle();
}

/// From the list, through the details page, to the reviews sheet.
Future<void> _openReviewsSheet(WidgetTester tester) async {
  await _openDetails(tester);
  final all = find.textContaining('دیدن همه');
  await tester.ensureVisible(all);
  await tester.pumpAndSettle();
  await tester.tap(all);
  await tester.pumpAndSettle();
}

/// [finder] inside the reviews sheet, not on the page below it.
Finder _inSheet(Finder finder) =>
    find.descendant(of: find.byType(CounselorReviewsSheet), matching: finder);

void tallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
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
    // Every counselor has a details page, rated or not.
    expect(find.text('جزئیات'), findsOneWidget);
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

  testWidgets('the details page opens the reviews sheet, filtered by score',
      (tester) async {
    tallView(tester);
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

    await _openReviewsSheet(tester);

    expect(_inSheet(find.text('نظرات دانش‌آموزان')), findsOneWidget);
    expect(_inSheet(find.text('از ۳۲ نظر')), findsOneWidget);
    expect(_inSheet(find.text('سارا ر.')), findsOneWidget);
    expect(_inSheet(find.text('نگار ص.')), findsOneWidget);
    expect(_inSheet(find.text('ادامه')), findsOneWidget);
    // The details page previews two, the sheet loads its own first page.
    expect(graphql.reviewRequests.first['limit'], 2);
    expect(graphql.reviewRequests.last['counselorProfileID'], 'profile-1');

    await tester.ensureVisible(find.text('۳ ستاره و کمتر'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('۳ ستاره و کمتر'));
    await tester.pumpAndSettle();
    expect(graphql.reviewRequests.last['maxScore'], 3);
    expect(graphql.reviewRequests.last.containsKey('minScore'), isFalse);
    expect(_inSheet(find.text('امیر ح.')), findsOneWidget);
    expect(_inSheet(find.text('سارا ر.')), findsNothing);

    await tester.tap(_inSheet(find.text('ادامه')));
    await tester.pumpAndSettle();
    expect(_inSheet(find.text('بستن')), findsOneWidget);

    await tester.ensureVisible(find.text('۵ ستاره'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('۵ ستاره'));
    await tester.pumpAndSettle();
    expect(graphql.reviewRequests.last['minScore'], 5);
    expect(_inSheet(find.text('سارا ر.')), findsOneWidget);
  });

  testWidgets('a review an admin gave a photo shows it, others the initial',
      (tester) async {
    await _pumpList(
      tester,
      answer: [_ratedCounselor()],
      reviews: [
        {
          ..._review('r1', 'نگار ص.', 5, 'عالی'),
          'authorAvatarURL': 'https://api.saimo.app/uploads/avatars/r1/p.jpg',
        },
        _review('r2', 'سارا ر.', 4, 'خوب'),
      ],
    );
    await _openReviewsSheet(tester);

    final photo = _inSheet(find.byKey(const ValueKey('review-author-photo')));
    expect(photo, findsOneWidget);
    final image = tester.widget<Image>(photo).image;
    expect(
      (image is ResizeImage ? image.imageProvider : image) as NetworkImage,
      isA<NetworkImage>().having((p) => p.url, 'url',
          'https://api.saimo.app/uploads/avatars/r1/p.jpg'),
    );
    // The review without a photo keeps the first letter of the name.
    expect(_inSheet(find.text('س')), findsOneWidget);
  });

  test('a review photo must be a web address', () {
    final review = CounselorReview.fromJson({
      ..._review('r1', 'نگار ص.', 5, null),
      'authorAvatarURL': 'file:///etc/passwd',
    });
    expect(review.authorAvatarUrl, isNull);
  });

  testWidgets('a filter with no reviews says so', (tester) async {
    await _pumpList(
      tester,
      answer: [_ratedCounselor()],
      reviews: [_review('r1', 'سارا ر.', 5, 'عالی')],
    );
    await _openReviewsSheet(tester);

    await tester.tap(find.text('۴ ستاره'));
    await tester.pumpAndSettle();
    expect(find.text('نظری با این امتیاز ثبت نشده است'), findsOneWidget);
  });

  testWidgets('«جزئیات» shows every filled section of the details page',
      (tester) async {
    tallView(tester);
    await _pumpList(
      tester,
      answer: [_detailedCounselor()],
      studentCount: 45,
      reviews: [_review('r1', 'سارا ر.', 5, 'خیلی دقیق بودند.')],
    );
    await _openDetails(tester);

    expect(find.byType(ConsultantDetailsScreen), findsOneWidget);
    expect(find.text('جزئیات مشاور'), findsOneWidget);
    expect(find.text('رتبه ۱۲۰ کنکور ریاضی'), findsOneWidget);
    expect(find.text('۳ سال'), findsOneWidget);
    expect(find.text('سابقه مشاوره'), findsOneWidget);
    expect(find.text('۴۵'), findsOneWidget);
    expect(find.text('دانش‌آموز'), findsOneWidget);
    expect(find.text('چرا من مشاور شما هستم'), findsOneWidget);
    expect(find.text('با برنامه‌ای قدم‌به‌قدم همراهتان هستم.'), findsOneWidget);
    expect(find.text('داستان من'), findsOneWidget);
    expect(find.text('سوابق تحصیلی'), findsOneWidget);
    expect(find.text('کارشناسی مهندسی برق، دانشگاه شریف'), findsOneWidget);
    expect(find.text('از ۱۴۰۲ تا اکنون'), findsOneWidget);
    // The academic record replaces the résumé lines in the timeline.
    expect(find.text('شش سال سابقه مشاوره تحصیلی'), findsNothing);
    expect(find.text('در مشاوره با من چه می‌گیرید'), findsOneWidget);
    expect(find.text('برنامه هفتگی و پیگیری روزانه'), findsOneWidget);
    expect(find.text('صبور'), findsOneWidget);
    expect(find.text('دانشجو بودن تأیید شده است'), findsOneWidget);
    expect(find.byKey(const ValueKey('student-card-photo')), findsOneWidget);
    expect(find.text('دیدن همه ۳۲ نظر'), findsOneWidget);
    expect(find.text('سارا ر.'), findsOneWidget);
  });

  testWidgets('empty sections stay hidden and only a verified card shows',
      (tester) async {
    tallView(tester);
    await _pumpList(tester, answer: [
      {
        ..._counselor('SCIENCE'),
        'resumeItems': ['رتبه ۵۰ کنکور تجربی', 'دانشجوی پزشکی'],
        'user': {'fullName': 'سارا احمدی', 'major': 'SCIENCE'},
        'studentCard': {
          'url': 'https://api.saimo.app/uploads/avatars/p/c.jpg',
          'status': 'PENDING',
        },
      },
    ]);
    await _openDetails(tester);

    expect(find.text('دانشجو بودن تأیید شده است'), findsNothing);
    expect(find.text('چرا من مشاور شما هستم'), findsNothing);
    expect(find.text('در مشاوره با من چه می‌گیرید'), findsNothing);
    expect(find.text('ویژگی‌های شخصیتی'), findsNothing);
    expect(find.text('سابقه مشاوره'), findsNothing);
    expect(find.text('دانش‌آموز'), findsNothing);
    expect(find.textContaining('دیدن همه'), findsNothing);
    expect(find.text('مشاور جدید'), findsOneWidget);
    // Older profiles keep their résumé lines as the timeline.
    expect(find.text('سوابق تحصیلی'), findsOneWidget);
    expect(find.text('دانشجوی پزشکی'), findsOneWidget);
  });

  testWidgets('«انتخاب مشاور» on the details page selects that counselor',
      (tester) async {
    tallView(tester);
    Consultant? selected;
    await _pumpList(
      tester,
      answer: [_detailedCounselor()],
      onSelect: (c) => selected = c,
    );
    await _openDetails(tester);

    await tester.tap(find.descendant(
      of: find.byType(ConsultantDetailsScreen),
      matching: find.text('انتخاب مشاور'),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ConsultantDetailsScreen), findsNothing);
    expect(selected?.id, 'profile-1');
  });

  testWidgets('the story under the pitch opens with «داستان من»',
      (tester) async {
    tallView(tester);
    await _pumpList(tester, answer: [_detailedCounselor()]);
    await _openDetails(tester);

    await tester.tap(find.text('داستان من'));
    await tester.pumpAndSettle();
    expect(find.text('بستن'), findsOneWidget);
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

Map<String, dynamic> _detailedCounselor() => {
      ..._ratedCounselor(),
      'intro': 'با برنامه‌ای قدم‌به‌قدم همراهتان هستم.',
      'experienceYears': 3,
      'educationItems': [
        {
          'title': 'کارشناسی مهندسی برق، دانشگاه شریف',
          'detail': 'از ۱۴۰۲ تا اکنون'
        },
        {'title': 'معدل ۱۹.۸۵ دیپلم', 'detail': null},
      ],
      'skillItems': [
        {
          'title': 'برنامه هفتگی و پیگیری روزانه',
          'description': 'برنامه با گزارش هر شب شما تنظیم می‌شود.',
        },
      ],
      'personalityTraits': ['صبور', 'منظم'],
      'studentCard': {
        'url': 'https://api.saimo.app/uploads/avatars/p/card.jpg',
        'status': 'VERIFIED',
      },
    };
