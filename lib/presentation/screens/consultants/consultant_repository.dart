import 'package:simo_learn/data/graphql/graphql_repository.dart';
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
        user {
          fullName
          username
          avatarURL
        }
      }
    }
  ''';

  static const String _myActiveCounselorQuery = r'''
    query MyActiveCounselor {
      myActiveCounselor {
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

  static const String _verifyCounselingPaymentMutation = r'''
    mutation VerifyCounselingPayment($attemptID: ID!) {
      verifyCounselingPayment(attemptID: $attemptID) {
        attempt {
          id
          status
          failureMessage
        }
        subscription {
          id
          status
        }
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

  /// Returns the student's current counselor, or null when there is none.
  Future<ActiveCounselor?> fetchMyActiveCounselor() async {
    final data = await _rawRequest(
      query: _myActiveCounselorQuery,
      variables: const {},
    );

    final subscription = data['myActiveCounselor'];
    if (subscription is! Map<String, dynamic>) return null;
    final counselor = subscription['counselor'];
    if (counselor is! Map<String, dynamic>) return null;

    final userID = counselor['userID'];
    if (userID is! String || userID.isEmpty) return null;

    final user = counselor['user'];
    final userMap = user is Map<String, dynamic> ? user : const {};
    final name = (userMap['fullName'] as String?)?.trim();
    final username = (userMap['username'] as String?)?.trim();
    final avatarUrl = (userMap['avatarURL'] as String?)?.trim();

    return ActiveCounselor(
      userID: userID,
      name: (name != null && name.isNotEmpty) ? name : username,
      username: username,
      avatar: (avatarUrl != null && avatarUrl.isNotEmpty)
          ? avatarUrl
          : _sampleAvatar,
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

  /// Sends a counseling request, creating a PENDING subscription. Returns its
  /// id and the authoritative server-side cost.
  Future<CounselingRequest> requestCounseling({
    required String counselorProfileID,
    required int durationMonths,
    required String planType,
  }) async {
    final data = await _rawRequest(
      query: _requestCounselingMutation,
      variables: {
        'input': {
          'counselorProfileID': counselorProfileID,
          'durationMonths': durationMonths,
          'planType': planType,
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
    final redirectURL = (payload['redirectURL'] as String?)?.trim();
    final attempt = payload['attempt'];
    final attemptID =
        attempt is Map<String, dynamic> ? attempt['id'] as String? : null;
    if (redirectURL == null ||
        redirectURL.isEmpty ||
        attemptID == null ||
        attemptID.isEmpty) {
      throw const GraphQLRawException('اطلاعات درگاه پرداخت نامعتبر بود');
    }

    return PaymentInitiation(
      attemptID: attemptID,
      redirectURL: redirectURL,
      status: (attempt as Map<String, dynamic>)['status'] as String? ??
          'PENDING',
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
      throw const GraphQLRawException('تایید پرداخت ناموفق بود');
    }
    final attempt = payload['attempt'];
    final subscription = payload['subscription'];
    final attemptMap = attempt is Map<String, dynamic> ? attempt : const {};
    final subscriptionMap =
        subscription is Map<String, dynamic> ? subscription : const {};

    return PaymentVerification(
      attemptStatus: (attemptMap['status'] as String?) ?? 'PENDING',
      subscriptionStatus: (subscriptionMap['status'] as String?) ?? '',
      failureMessage: (attemptMap['failureMessage'] as String?)?.trim(),
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
    );
  }
}

/// The counselor the signed-in student is currently subscribed to.
class ActiveCounselor {
  const ActiveCounselor({
    required this.userID,
    required this.avatar,
    this.name,
    this.username,
  });

  final String userID;
  final String avatar;
  final String? name;
  final String? username;
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
    required this.attemptID,
    required this.redirectURL,
    required this.status,
  });

  final String attemptID;
  final String redirectURL;
  final String status;
}

/// Result of [ConsultantRepository.verifyPayment].
class PaymentVerification {
  const PaymentVerification({
    required this.attemptStatus,
    required this.subscriptionStatus,
    this.failureMessage,
  });

  final String attemptStatus;
  final String subscriptionStatus;
  final String? failureMessage;

  bool get succeeded => attemptStatus == 'SUCCEEDED';
  bool get failed => attemptStatus == 'FAILED' || attemptStatus == 'EXPIRED';

  /// Still pending (e.g. user closed the gateway before completing) — the
  /// caller may let the user retry.
  bool get pending => !succeeded && !failed;
}
