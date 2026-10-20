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
  });

  final String id;
  final String name;
  final String specialty;
  final String rating;
  final String maxRating;
  final String avatar;
  final List<ConsultantResumeItem> resume;
}

/// Shown when the server refuses the counseling section to this account
/// (e.g. an admin account, which is not a student).
const String kCounselingNoAccessTitle = 'شما به این بخش دسترسی ندارید';
const String kCounselingNoAccessMessage =
    'برای استفاده از بخش مشاوره، با پشتیبانی تماس بگیرید.';

/// Whether [error] is the server's role check rejecting this account.
bool isCounselingAccessDenied(Object error) =>
    error.toString().toLowerCase().contains('forbidden');
