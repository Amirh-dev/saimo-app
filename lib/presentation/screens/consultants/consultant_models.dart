import 'package:simo_learn/features/profile/user_major.dart';

/// Data model for the consultants flow (screens 1-7).
class ConsultantResumeItem {
  const ConsultantResumeItem({required this.title, this.count = 1});

  final String title;
  final int count;
}

class Consultant {
  const Consultant({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.maxRating,
    required this.avatar,
    required this.resume,
    this.ratingCount = 0,
    this.major,
    this.bio = '',
  });

  final String id;
  final String name;
  final String specialty;
  final String rating;
  final String maxRating;
  final String avatar;
  final List<ConsultantResumeItem> resume;

  /// How many students rated this counselor; 0 means no rating to show yet.
  final int ratingCount;
  final UserMajor? major;
  final String bio;
}

/// Shown when the server refuses the counseling section to this account
/// (e.g. an admin account, which is not a student).
const String kCounselingNoAccessTitle = 'شما به این بخش دسترسی ندارید';
const String kCounselingNoAccessMessage =
    'برای استفاده از بخش مشاوره، با پشتیبانی تماس بگیرید.';

/// Whether [error] is the server's role check rejecting this account.
bool isCounselingAccessDenied(Object error) =>
    error.toString().toLowerCase().contains('forbidden');

/// One student review as the app shows it. The server sends only a display
/// name (first name and last initial, or a name set by an admin), and a photo
/// only for reviews an admin wrote.
class CounselorReview {
  const CounselorReview({
    required this.id,
    required this.authorName,
    required this.score,
    required this.createdAt,
    this.comment,
    this.authorAvatarUrl,
  });

  factory CounselorReview.fromJson(Map<String, dynamic> json) {
    final comment = (json['comment'] as String?)?.trim();
    final author = (json['authorName'] as String?)?.trim();
    final avatar = (json['authorAvatarURL'] as String?)?.trim();
    return CounselorReview(
      id: (json['id'] as String?) ?? '',
      authorName: (author == null || author.isEmpty) ? 'دانش‌آموز سایمو' : author,
      score: ((json['score'] as num?)?.toInt() ?? 0).clamp(1, 5),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
              DateTime.now(),
      comment: (comment == null || comment.isEmpty) ? null : comment,
      authorAvatarUrl:
          (avatar != null && avatar.startsWith('http')) ? avatar : null,
    );
  }

  final String id;
  final String authorName;
  final String? authorAvatarUrl;
  final int score;
  final DateTime createdAt;
  final String? comment;
}

/// The score filters above the review list.
enum ReviewScoreFilter {
  all('همه'),
  five('۵ ستاره', minScore: 5, maxScore: 5),
  four('۴ ستاره', minScore: 4, maxScore: 4),
  low('۳ ستاره و کمتر', maxScore: 3);

  const ReviewScoreFilter(this.label, {this.minScore, this.maxScore});

  final String label;
  final int? minScore;
  final int? maxScore;
}
