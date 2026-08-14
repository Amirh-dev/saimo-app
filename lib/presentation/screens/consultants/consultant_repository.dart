import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_models.dart';
import 'package:simo_learn/utils/helpers.dart';

/// Talks to the counselor GraphQL API (raw requests, no Ferry codegen).
class ConsultantRepository {
  ConsultantRepository(this._graphql);

  final GraphQLRepository _graphql;

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

  /// Fetches published counselors and maps them to [Consultant] view models.
  Future<List<Consultant>> fetchCounselors(
      {int limit = 20, int offset = 0}) async {
    final data = await _graphql.rawRequest(
      query: _counselorsQuery,
      variables: {'limit': limit, 'offset': offset},
    );

    final raw = data['counselors'];
    if (raw is! List) return const [];

    return raw.whereType<Map<String, dynamic>>().map(_mapCounselor).toList();
  }

  /// Sends a counseling request. Returns the created subscription id.
  Future<String> requestCounseling({
    required String counselorProfileID,
    required int durationMonths,
    required String planType,
  }) async {
    final data = await _graphql.rawRequest(
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
      return sub['id'] as String;
    }
    throw const GraphQLRawException('ثبت درخواست مشاوره ناموفق بود');
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
