import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/profile/user_major.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_models.dart';
import 'package:simo_learn/utils/helpers.dart';

typedef RawGraphQLRequest = Future<Map<String, dynamic>> Function({
  required String query,
  Map<String, dynamic> variables,
  bool requiresAuth,
});

/// Talks to the counselor GraphQL API (raw requests, no Ferry codegen).
class ConsultantRepository {
  ConsultantRepository(GraphQLRepository graphql)
      : _rawRequest = graphql.rawRequest;

  /// Test seam: injects a stand-in for [GraphQLRepository.rawRequest].
  ConsultantRepository.withRawRequest(this._rawRequest);

  final RawGraphQLRequest _rawRequest;

  static const String _sampleAvatar = 'Assets.profilePlaceholder';

  static const String _counselorsQuery = r'''
    query Counselors($limit: Int, $offset: Int) {
      counselors(limit: $limit, offset: $offset) {
        id
        title
        ratingAverage
        ratingCount
        resumeItems
        intro
        experienceYears
        personalityTraits
        educationItems { title detail }
        skillItems { title description }
        studentCard { url status }
        user {
          fullName
          username
          avatarURL
          major
          bio
        }
      }
    }
  ''';

  static const String _reviewsQuery = r'''
    query CounselorReviews($counselorProfileID: ID!, $limit: Int, $offset: Int, $minScore: Int, $maxScore: Int) {
      counselorReviews(counselorProfileID: $counselorProfileID, limit: $limit, offset: $offset, minScore: $minScore, maxScore: $maxScore) {
        id
        authorName
        authorAvatarURL
        createdAt
        score
        comment
      }
    }
  ''';

  static const String _studentCountQuery = r'''
    query CounselorStudentCount($counselorProfileID: ID!) {
      counselorStudentCount(counselorProfileID: $counselorProfileID)
    }
  ''';

  static const String _ratingDistributionQuery = r'''
    query CounselorRatingDistribution($counselorProfileID: ID!) {
      counselorRatingDistribution(counselorProfileID: $counselorProfileID) {
        score
        count
      }
    }
  ''';

  static const String _myMajorQuery = r'''
    query MyMajor {
      getMe {
        major
      }
    }
  ''';

  static const String _myActiveCounselorQuery = r'''
    query MyActiveCounselor {
      myActiveCounselor {
        status
        endDate
        counselor {
          id
          userID
          title
          user {
            fullName
            username
            avatarURL
          }
        }
      }
    }
  ''';

  static const String _counselingOffersQuery = r'''
    query CounselingOffers($counselorProfileID: ID!) {
      counselingOffers(counselorProfileID: $counselorProfileID) {
        planType
        durationMonths
        discountPercent
        currency
        monthlyBasePrice
        displayMonthlyPrice
        totalPrice
      }
    }
  ''';

  static const String _previewDiscountQuery = r'''
    query PreviewCounselingDiscount($input: PreviewCounselingDiscountInput!) {
      previewCounselingDiscount(input: $input) {
        status
        code
        listPrice
        discountAmount
        finalPrice
        percentOff
      }
    }
  ''';

  static const String _requestCounselingMutation = r'''
    mutation RequestCounseling($input: RequestCounselingInput!) {
      requestCounseling(input: $input) {
        id
        cost
        status
        planType
        durationMonths
      }
    }
  ''';

  static const String _beginCounselingPaymentMutation = r'''
    mutation BeginCounselingPayment($input: BeginCounselingPaymentInput!) {
      beginCounselingPayment(input: $input) {
        redirectURL
        attempt {
          id
          status
          amount
        }
      }
    }
  ''';

  static const String _cancelPendingSubscriptionMutation = r'''
    mutation CancelPendingCounselingSubscription($subscriptionID: ID!) {
      cancelPendingCounselingSubscription(subscriptionID: $subscriptionID) {
        id
        status
      }
    }
  ''';

  static const String _verifyCounselingPaymentMutation = r'''
    mutation VerifyCounselingPayment($attemptID: ID!) {
      verifyCounselingPayment(attemptID: $attemptID) {
        attempt {
          id
          status
          failureCode
          failureMessage
        }
        subscription {
          id
          status
        }
      }
    }
  ''';

  static const String _pendingSubscriptionQuery = r'''
    query MyPendingCounselingSubscription {
      myCounselingSubscriptions(status: PENDING, limit: 1) {
        id
        counselorID
        planType
        durationMonths
        pendingExpiresAt
        discountCode
      }
    }
  ''';

  static const String _paymentAttemptsQuery = r'''
    query MyCounselingPaymentAttempts($subscriptionID: ID!) {
      myCounselingPaymentAttempts(subscriptionID: $subscriptionID) {
        id
        status
        redirectURL
        expiresAt
      }
    }
  ''';

  static const String _paymentAttemptStatusQuery = r'''
    query MyCounselingPaymentAttempt($id: ID!) {
      myCounselingPaymentAttempt(id: $id) {
        id
        status
      }
    }
  ''';

  /// Fetches published counselors and maps them to [Consultant] view models.
  Future<List<Consultant>> fetchCounselors(
      {int limit = 20, int offset = 0}) async {
    final data = await _rawRequest(
      query: _counselorsQuery,
      variables: {'limit': limit, 'offset': offset},
    );

    final raw = data['counselors'];
    if (raw is! List) return const [];

    return raw.whereType<Map<String, dynamic>>().map(_mapCounselor).toList();
  }

  /// One page of a counselor's reviews, newest first, optionally limited to
  /// [filter]'s score range.
  Future<List<CounselorReview>> fetchReviews(
    String counselorProfileID, {
    ReviewScoreFilter filter = ReviewScoreFilter.all,
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _rawRequest(
      query: _reviewsQuery,
      variables: {
        'counselorProfileID': counselorProfileID,
        'limit': limit,
        'offset': offset,
        if (filter.minScore != null) 'minScore': filter.minScore,
        if (filter.maxScore != null) 'maxScore': filter.maxScore,
      },
    );
    final raw = data['counselorReviews'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(CounselorReview.fromJson)
        .toList();
  }

  /// How many distinct students have paid for counseling with the counselor.
  Future<int> fetchStudentCount(String counselorProfileID) async {
    final data = await _rawRequest(
      query: _studentCountQuery,
      variables: {'counselorProfileID': counselorProfileID},
    );
    return (data['counselorStudentCount'] as num?)?.toInt() ?? 0;
  }

  /// How many reviews gave each score, keyed 5 down to 1 (missing scores are 0).
  Future<Map<int, int>> fetchRatingDistribution(
      String counselorProfileID) async {
    final data = await _rawRequest(
      query: _ratingDistributionQuery,
      variables: {'counselorProfileID': counselorProfileID},
    );
    final counts = {for (var score = 5; score >= 1; score--) score: 0};
    final raw = data['counselorRatingDistribution'];
    if (raw is List) {
      for (final bucket in raw.whereType<Map<String, dynamic>>()) {
        final score = (bucket['score'] as num?)?.toInt();
        if (score != null && counts.containsKey(score)) {
          counts[score] = (bucket['count'] as num?)?.toInt() ?? 0;
        }
      }
    }
    return counts;
  }

  /// The signed-in student's major, or null when none is set. The server does
  /// the matching; this only labels the list, so a failure just drops the label.
  Future<UserMajor?> fetchMyMajor() async {
    try {
      final data = await _rawRequest(
        query: _myMajorQuery,
        variables: const {},
      );
      final me = data['getMe'];
      return me is Map<String, dynamic> ? UserMajor.fromApi(me['major']) : null;
    } catch (_) {
      return null;
    }
  }

  /// Returns the student's current counselor, or null when there is none.
  ///
  /// Only a paid (ACTIVE, not yet ended) subscription counts: a PENDING one is
  /// created before payment and must never grant a counselor.
  Future<ActiveCounselor?> fetchMyActiveCounselor() async {
    final data = await _rawRequest(
      query: _myActiveCounselorQuery,
      variables: const {},
    );

    final subscription = data['myActiveCounselor'];
    if (subscription is! Map<String, dynamic>) return null;
    if (subscription['status'] != 'ACTIVE') return null;
    final endDate = DateTime.tryParse(subscription['endDate'] as String? ?? '');
    if (endDate != null && endDate.isBefore(DateTime.now())) return null;
    final counselor = subscription['counselor'];
    if (counselor is! Map<String, dynamic>) return null;

    final userID = counselor['userID'];
    if (userID is! String || userID.isEmpty) return null;

    final user = counselor['user'];
    final userMap = user is Map<String, dynamic> ? user : const {};
    final name = (userMap['fullName'] as String?)?.trim();
    final username = (userMap['username'] as String?)?.trim();
    final avatarUrl = (userMap['avatarURL'] as String?)?.trim();
    final title = (counselor['title'] as String?)?.trim();

    return ActiveCounselor(
      userID: userID,
      name: (name != null && name.isNotEmpty) ? name : username,
      username: username,
      avatar: (avatarUrl != null && avatarUrl.isNotEmpty)
          ? avatarUrl
          : _sampleAvatar,
      title: (title != null && title.isNotEmpty) ? title : null,
      endDate: endDate,
    );
  }

  /// Fetches the counselor's published price offers, keyed by plan type and
  /// duration. Returns an empty list when the counselor has no offers.
  Future<List<CounselingOffer>> fetchOffers(String counselorProfileID) async {
    final data = await _rawRequest(
      query: _counselingOffersQuery,
      variables: {'counselorProfileID': counselorProfileID},
    );

    final raw = data['counselingOffers'];
    if (raw is! List) return const [];

    return raw
        .whereType<Map<String, dynamic>>()
        .map(CounselingOffer.fromJson)
        .toList();
  }

  /// Asks what [code] would take off the selected offer. Reserves nothing; the
  /// server checks the code again when the request is made.
  Future<DiscountPreview> previewDiscount({
    required String code,
    required String planType,
    required int durationMonths,
  }) async {
    final data = await _rawRequest(
      query: _previewDiscountQuery,
      variables: {
        'input': {
          'code': code,
          'planType': planType,
          'durationMonths': durationMonths,
        },
      },
    );

    final raw = data['previewCounselingDiscount'];
    if (raw is! Map<String, dynamic>) {
      throw const GraphQLRawException('بررسی کد تخفیف ناموفق بود');
    }
    return DiscountPreview.fromJson(raw);
  }

  /// Sends a counseling request, creating a PENDING subscription. Returns its
  /// id and the authoritative server-side cost, after [discountCode] if any.
  Future<CounselingRequest> requestCounseling({
    required String counselorProfileID,
    required int durationMonths,
    required String planType,
    String? discountCode,
  }) async {
    final data = await _rawRequest(
      query: _requestCounselingMutation,
      variables: {
        'input': {
          'counselorProfileID': counselorProfileID,
          'durationMonths': durationMonths,
          'planType': planType,
          if (discountCode != null) 'discountCode': discountCode,
        },
      },
    );

    final sub = data['requestCounseling'];
    if (sub is Map<String, dynamic> && sub['id'] is String) {
      return CounselingRequest(
        subscriptionID: sub['id'] as String,
        cost: (sub['cost'] as num?)?.toInt() ?? 0,
        status: (sub['status'] as String?) ?? 'PENDING',
      );
    }
    throw const GraphQLRawException('ثبت درخواست مشاوره ناموفق بود');
  }

  /// Initiates online payment for a pending subscription. Returns the durable
  /// attempt id and the bank gateway redirect URL to open in the WebView.
  ///
  /// [idempotencyKey] must be stable for a given subscription so retries resume
  /// the same attempt instead of failing with "payment already pending".
  Future<PaymentInitiation> beginPayment({
    required String subscriptionID,
    required String idempotencyKey,
  }) async {
    final data = await _rawRequest(
      query: _beginCounselingPaymentMutation,
      variables: {
        'input': {
          'subscriptionID': subscriptionID,
          'idempotencyKey': idempotencyKey,
        },
      },
    );

    final payload = data['beginCounselingPayment'];
    if (payload is! Map<String, dynamic>) {
      throw const GraphQLRawException('شروع پرداخت ناموفق بود');
    }
    final redirectURL = (payload['redirectURL'] as String?)?.trim() ?? '';
    final attempt = payload['attempt'];
    final attemptMap = attempt is Map<String, dynamic> ? attempt : const {};
    final attemptID = attemptMap['id'] as String?;
    final status = attemptMap['status'] as String? ?? 'PENDING';
    // A resumed attempt that has meanwhile expired or failed comes back
    // without a URL, and the caller opens a fresh one. An open attempt
    // without a gateway URL is a broken response.
    if (attemptID == null ||
        attemptID.isEmpty ||
        (status == 'PENDING' && redirectURL.isEmpty)) {
      throw const GraphQLRawException('اطلاعات درگاه پرداخت نامعتبر بود');
    }

    return PaymentInitiation(
      subscriptionID: subscriptionID,
      attemptID: attemptID,
      redirectURL: redirectURL,
      status: status,
    );
  }

  /// Verifies a payment attempt with the provider and activates the
  /// subscription on success. Safe to call again on the same attempt.
  Future<PaymentVerification> verifyPayment(String attemptID) async {
    final data = await _rawRequest(
      query: _verifyCounselingPaymentMutation,
      variables: {'attemptID': attemptID},
    );

    final payload = data['verifyCounselingPayment'];
    if (payload is! Map<String, dynamic>) {
      throw const GraphQLRawException('تأیید پرداخت ناموفق بود');
    }
    final attempt = payload['attempt'];
    final subscription = payload['subscription'];
    final attemptMap = attempt is Map<String, dynamic> ? attempt : const {};
    final subscriptionMap =
        subscription is Map<String, dynamic> ? subscription : const {};

    return PaymentVerification(
      attemptStatus: (attemptMap['status'] as String?) ?? 'PENDING',
      subscriptionStatus: (subscriptionMap['status'] as String?) ?? '',
      failureCode: (attemptMap['failureCode'] as String?)?.trim(),
      failureMessage: (attemptMap['failureMessage'] as String?)?.trim(),
    );
  }

  /// Returns the student's unpaid (PENDING) counseling purchase, if any. Only
  /// one can exist at a time, and it blocks [requestCounseling] until it is
  /// paid, cancelled or expired.
  Future<PendingCounselingSubscription?> fetchPendingSubscription() async {
    final data = await _rawRequest(
      query: _pendingSubscriptionQuery,
      variables: const {},
    );

    final raw = data['myCounselingSubscriptions'];
    if (raw is! List) return null;
    for (final item in raw.whereType<Map<String, dynamic>>()) {
      final id = item['id'];
      if (id is! String || id.isEmpty) continue;
      return PendingCounselingSubscription(
        id: id,
        counselorProfileID: (item['counselorID'] as String?) ?? '',
        planType: (item['planType'] as String?) ?? '',
        durationMonths: (item['durationMonths'] as num?)?.toInt() ?? 0,
        expiresAt: DateTime.tryParse(item['pendingExpiresAt'] as String? ?? ''),
        discountCode: item['discountCode'] as String?,
      );
    }
    return null;
  }

  /// Reads an attempt's stored status without contacting the bank, so it is
  /// safe to poll while the student is still on the gateway (verifying an
  /// unpaid ZarinPal checkout would close it as failed). The server marks an
  /// attempt EXPIRED here once its deadline passes.
  Future<String> fetchPaymentAttemptStatus(String attemptID) async {
    final data = await _rawRequest(
      query: _paymentAttemptStatusQuery,
      variables: {'id': attemptID},
    );

    final attempt = data['myCounselingPaymentAttempt'];
    final status =
        attempt is Map<String, dynamic> ? attempt['status'] as String? : null;
    if (status == null || status.isEmpty) {
      throw const GraphQLRawException('وضعیت پرداخت دریافت نشد');
    }
    return status;
  }

  /// Lists the payment attempts of [subscriptionID], newest first.
  Future<List<CounselingPaymentAttemptInfo>> fetchPaymentAttempts(
    String subscriptionID,
  ) async {
    final data = await _rawRequest(
      query: _paymentAttemptsQuery,
      variables: {'subscriptionID': subscriptionID},
    );

    final raw = data['myCounselingPaymentAttempts'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .where((item) => item['id'] is String)
        .map(
          (item) => CounselingPaymentAttemptInfo(
            id: item['id'] as String,
            status: (item['status'] as String?) ?? '',
            redirectURL: (item['redirectURL'] as String?)?.trim() ?? '',
            expiresAt: DateTime.tryParse(item['expiresAt'] as String? ?? ''),
          ),
        )
        .toList();
  }

  /// Cancels a subscription whose payment definitively failed, so an unpaid
  /// request never lingers on the account.
  Future<void> cancelPendingSubscription(String subscriptionID) async {
    await _rawRequest(
      query: _cancelPendingSubscriptionMutation,
      variables: {'subscriptionID': subscriptionID},
    );
  }

  Consultant _mapCounselor(Map<String, dynamic> json) {
    final user = json['user'];
    final userMap = user is Map<String, dynamic> ? user : const {};

    final name = (userMap['fullName'] as String?)?.trim();
    final username = (userMap['username'] as String?)?.trim();
    final avatarUrl = (userMap['avatarURL'] as String?)?.trim();

    final ratingAverage = json['ratingAverage'];
    final ratingText = ratingAverage is num
        ? convertToPersianNumbers(
            ratingAverage == ratingAverage.roundToDouble()
                ? ratingAverage.toStringAsFixed(0)
                : ratingAverage.toStringAsFixed(1),
          )
        : '۰';

    final resumeRaw = json['resumeItems'];
    final resume = resumeRaw is List
        ? resumeRaw
            .whereType<String>()
            .map((item) => ConsultantResumeItem(title: item))
            .toList()
        : <ConsultantResumeItem>[];

    return Consultant(
      id: (json['id'] as String?) ?? '',
      name: (name != null && name.isNotEmpty)
          ? name
          : (username != null && username.isNotEmpty ? username : 'مشاور'),
      specialty: (json['title'] as String?) ?? '',
      rating: ratingText,
      maxRating: '۵',
      avatar: (avatarUrl != null && avatarUrl.isNotEmpty)
          ? avatarUrl
          : _sampleAvatar,
      resume: resume,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      major: UserMajor.fromApi(userMap['major']),
      bio: (userMap['bio'] as String?)?.trim() ?? '',
      intro: (json['intro'] as String?)?.trim() ?? '',
      experienceYears: (json['experienceYears'] as num?)?.toInt(),
      education: _maps(json['educationItems'])
          .map((e) => CounselorEducation(
                title: _text(e['title']),
                detail: _text(e['detail']),
              ))
          .where((e) => e.title.isNotEmpty)
          .toList(),
      skills: _maps(json['skillItems'])
          .map((k) => CounselorSkill(
                title: _text(k['title']),
                description: _text(k['description']),
              ))
          .where((k) => k.title.isNotEmpty)
          .toList(),
      traits: _strings(json['personalityTraits']),
      studentCardUrl: _verifiedCardUrl(json['studentCard']),
    );
  }

  static Iterable<Map<String, dynamic>> _maps(Object? raw) =>
      raw is List ? raw.whereType<Map<String, dynamic>>() : const [];

  static List<String> _strings(Object? raw) => raw is List
      ? raw
          .whereType<String>()
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList()
      : const [];

  static String _text(Object? raw) => raw is String ? raw.trim() : '';

  /// The server only sends students a verified card; the status check keeps
  /// the badge honest if that ever changes.
  static String? _verifiedCardUrl(Object? raw) {
    if (raw is! Map<String, dynamic> || raw['status'] != 'VERIFIED') {
      return null;
    }
    final url = _text(raw['url']);
    return url.isEmpty ? null : url;
  }
}

/// The counselor the signed-in student is currently subscribed to.
class ActiveCounselor {
  const ActiveCounselor({
    required this.userID,
    required this.avatar,
    this.name,
    this.username,
    this.title,
    this.endDate,
  });

  final String userID;
  final String avatar;
  final String? name;
  final String? username;

  /// The counselor's professional title, e.g. "مشاور تحصیلی کنکور".
  final String? title;

  /// When the student's subscription to this counselor ends.
  final DateTime? endDate;
}

/// A published price offer for one (planType, durationMonths) combination.
/// Prices are integers in the offer's [currency] (e.g. TOMAN).
class CounselingOffer {
  const CounselingOffer({
    required this.planType,
    required this.durationMonths,
    required this.discountPercent,
    required this.currency,
    required this.monthlyBasePrice,
    required this.displayMonthlyPrice,
    required this.totalPrice,
  });

  final String planType;
  final int durationMonths;
  final int discountPercent;
  final String currency;
  final int monthlyBasePrice;
  final int displayMonthlyPrice;
  final int totalPrice;

  /// Undiscounted total for the full duration; used as the strike-through price.
  int get baseTotalPrice => monthlyBasePrice * durationMonths;

  factory CounselingOffer.fromJson(Map<String, dynamic> json) {
    return CounselingOffer(
      planType: (json['planType'] as String?) ?? '',
      durationMonths: (json['durationMonths'] as num?)?.toInt() ?? 0,
      discountPercent: (json['discountPercent'] as num?)?.toInt() ?? 0,
      currency: (json['currency'] as String?) ?? 'TOMAN',
      monthlyBasePrice: (json['monthlyBasePrice'] as num?)?.toInt() ?? 0,
      displayMonthlyPrice: (json['displayMonthlyPrice'] as num?)?.toInt() ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Result of [ConsultantRepository.requestCounseling]: the created pending
/// subscription and its authoritative server-side cost.
class CounselingRequest {
  const CounselingRequest({
    required this.subscriptionID,
    required this.cost,
    required this.status,
  });

  final String subscriptionID;
  final int cost;
  final String status;
}

/// Result of [ConsultantRepository.beginPayment]: the durable attempt id and
/// the bank gateway URL to open.
class PaymentInitiation {
  const PaymentInitiation({
    required this.subscriptionID,
    required this.attemptID,
    required this.redirectURL,
    required this.status,
  });

  final String subscriptionID;
  final String attemptID;
  final String redirectURL;
  final String status;

  /// Still payable: the gateway can be opened with [redirectURL].
  bool get isOpen => status == 'PENDING' && redirectURL.isNotEmpty;
}

/// The student's unpaid counseling purchase (see
/// [ConsultantRepository.fetchPendingSubscription]).
class PendingCounselingSubscription {
  const PendingCounselingSubscription({
    required this.id,
    required this.counselorProfileID,
    required this.planType,
    required this.durationMonths,
    this.expiresAt,
    this.discountCode,
  });

  final String id;
  final String counselorProfileID;
  final String planType;
  final int durationMonths;

  /// When the server cancels it for non-payment.
  final DateTime? expiresAt;

  /// The code its price was discounted with, as the server normalized it.
  final String? discountCode;

  bool isExpiredAt(DateTime now) =>
      expiresAt != null && !expiresAt!.isAfter(now);

  /// Same counselor, plan and code: its reserved price is the one the
  /// student is about to pay.
  bool matches({
    required String counselorProfileID,
    required int durationMonths,
    required String planType,
    String? discountCode,
  }) =>
      this.counselorProfileID == counselorProfileID &&
      this.durationMonths == durationMonths &&
      this.planType == planType &&
      (this.discountCode ?? '') == (discountCode ?? '');
}

/// What a discount code takes off one offer
/// ([ConsultantRepository.previewDiscount]). Amounts are toman and stay 0
/// unless [isValid].
class DiscountPreview {
  const DiscountPreview({
    required this.status,
    required this.code,
    required this.listPrice,
    required this.discountAmount,
    required this.finalPrice,
    this.percentOff,
  });

  /// VALID, or why the code cannot be used (see [discountStatusMessage]).
  final String status;

  /// The code as the server normalized it, e.g. "SAIMO20".
  final String code;
  final int listPrice;
  final int discountAmount;
  final int finalPrice;
  final int? percentOff;

  bool get isValid => status == 'VALID' && discountAmount > 0;

  factory DiscountPreview.fromJson(Map<String, dynamic> json) {
    return DiscountPreview(
      status: (json['status'] as String?) ?? 'NOT_FOUND',
      code: (json['code'] as String?) ?? '',
      listPrice: (json['listPrice'] as num?)?.toInt() ?? 0,
      discountAmount: (json['discountAmount'] as num?)?.toInt() ?? 0,
      finalPrice: (json['finalPrice'] as num?)?.toInt() ?? 0,
      percentOff: (json['percentOff'] as num?)?.toInt(),
    );
  }
}

/// One row of [ConsultantRepository.fetchPaymentAttempts].
class CounselingPaymentAttemptInfo {
  const CounselingPaymentAttemptInfo({
    required this.id,
    required this.status,
    required this.redirectURL,
    this.expiresAt,
  });

  final String id;
  final String status;
  final String redirectURL;
  final DateTime? expiresAt;

  bool get isPending => status == 'PENDING';

  /// Pending with a gateway URL that has not expired yet.
  bool isOpenAt(DateTime now) =>
      isPending &&
      redirectURL.isNotEmpty &&
      (expiresAt == null || expiresAt!.isAfter(now));
}

/// Result of [ConsultantRepository.verifyPayment].
class PaymentVerification {
  const PaymentVerification({
    required this.attemptStatus,
    required this.subscriptionStatus,
    this.failureCode,
    this.failureMessage,
  });

  final String attemptStatus;
  final String subscriptionStatus;

  /// Machine-readable reason, e.g. `MELLAT_CALLBACK_17` (cancelled on the
  /// bank page). [failureMessage] is the provider's English text, so the UI
  /// must not show it.
  final String? failureCode;
  final String? failureMessage;

  /// Paid AND the subscription was activated. Only this grants a counselor.
  bool get succeeded =>
      attemptStatus == 'SUCCEEDED' && subscriptionStatus == 'ACTIVE';
  bool get failed => attemptStatus == 'FAILED' || attemptStatus == 'EXPIRED';

  /// Not settled yet: the user closed the gateway before completing, the bank
  /// is still confirming, or the payment went through but the subscription is
  /// not active yet. Never treat as success.
  bool get pending => !succeeded && !failed;
}
