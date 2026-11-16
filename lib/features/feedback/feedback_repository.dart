import 'package:simo_learn/data/graphql/graphql_repository.dart';

/// A complaint or a suggestion. Values match the backend's UserFeedbackKind.
enum FeedbackKind { complaint, suggestion }

/// Values match the backend's UserFeedbackStatus.
enum FeedbackStatus { open, inReview, resolved }

class SentFeedback {
  const SentFeedback({
    required this.id,
    required this.createdAt,
    required this.kind,
    required this.status,
    required this.body,
    this.counselorName,
  });

  final String id;
  final DateTime createdAt;
  final FeedbackKind kind;
  final FeedbackStatus status;
  final String body;
  final String? counselorName;

  factory SentFeedback.fromJson(Map<String, dynamic> json) => SentFeedback(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        kind: json['kind'] == 'COMPLAINT'
            ? FeedbackKind.complaint
            : FeedbackKind.suggestion,
        status: switch (json['status']) {
          'RESOLVED' => FeedbackStatus.resolved,
          'IN_REVIEW' => FeedbackStatus.inReview,
          _ => FeedbackStatus.open,
        },
        body: json['body'] as String? ?? '',
        counselorName: json['counselorName'] as String?,
      );
}

/// A counselor the student has had, so a complaint can name them.
class FeedbackCounselor {
  const FeedbackCounselor({required this.userId, required this.name});
  final String userId;
  final String name;
}

/// Sends complaints and suggestions to the senior counselor panel. Uses
/// rawRequest because lib/graphql/schema.graphql is stale. An older backend
/// without these operations makes the calls fail; the screen shows an error.
class FeedbackRepository {
  FeedbackRepository(this._graphql);

  final GraphQLRepository _graphql;

  static const minLength = 5;
  static const maxLength = 2000;

  static const _fields = 'id createdAt kind status body counselorName';

  Future<List<SentFeedback>> myFeedback() async {
    final data = await _graphql.rawRequest(query: '''
query MyFeedback {
  myFeedback { $_fields }
}
''');
    final raw = data['myFeedback'];
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is Map<String, dynamic>) SentFeedback.fromJson(item),
    ];
  }

  /// Counselors from started subscriptions, newest first, each once.
  Future<List<FeedbackCounselor>> myCounselors() async {
    final data = await _graphql.rawRequest(query: r'''
query FeedbackCounselors {
  myCounselingSubscriptions(limit: 20) {
    startDate
    counselor { userID user { fullName username } }
  }
}
''');
    final raw = data['myCounselingSubscriptions'];
    if (raw is! List) return const [];
    final seen = <String>{};
    final result = <FeedbackCounselor>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic> || item['startDate'] == null) continue;
      final counselor = item['counselor'];
      if (counselor is! Map<String, dynamic>) continue;
      final id = counselor['userID'] as String?;
      if (id == null || !seen.add(id)) continue;
      final user = counselor['user'] as Map<String, dynamic>?;
      final fullName = (user?['fullName'] as String?)?.trim() ?? '';
      result.add(FeedbackCounselor(
        userId: id,
        name: fullName.isNotEmpty ? fullName : (user?['username'] as String? ?? 'مشاور'),
      ));
    }
    return result;
  }

  Future<SentFeedback> submit({
    required FeedbackKind kind,
    required String body,
    String? counselorUserId,
  }) async {
    final data = await _graphql.rawRequest(
      query: '''
mutation SubmitFeedback(\$input: SubmitFeedbackInput!) {
  submitFeedback(input: \$input) { $_fields }
}
''',
      variables: {
        'input': {
          'kind': kind == FeedbackKind.complaint ? 'COMPLAINT' : 'SUGGESTION',
          'body': body.trim(),
          if (counselorUserId != null) 'counselorUserID': counselorUserId,
        },
      },
    );
    return SentFeedback.fromJson(data['submitFeedback'] as Map<String, dynamic>);
  }
}
