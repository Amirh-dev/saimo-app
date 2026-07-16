/// Static data model for the consultants flow (screens 1-7).
/// No backend — hardcoded sample data for now.
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

const String _kSampleAvatar = 'assets/images/sample_profile.png';

const List<Consultant> kSampleConsultants = [
  Consultant(
    id: 'c1',
    name: 'علیرضا یوسفی',
    specialty: 'فوق تخصص مشاوره تحصیلی',
    rating: '۴',
    maxRating: '۵',
    avatar: _kSampleAvatar,
    resume: [
      ConsultantResumeItem(title: 'استاد دانشگاه دولتی یزد'),
      ConsultantResumeItem(title: 'تندیس بهترین استاد سال ۱۴۰۳'),
      ConsultantResumeItem(title: '۲۲ سال سابقه مشاوره تحصیلی'),
    ],
  ),
  Consultant(
    id: 'c2',
    name: 'محمد علیزاده',
    specialty: 'فوق تخصص مشاوره تحصیلی',
    rating: '۴',
    maxRating: '۵',
    avatar: _kSampleAvatar,
    resume: [
      ConsultantResumeItem(title: 'استاد دانشگاه دولتی یزد'),
      ConsultantResumeItem(title: 'تندیس بهترین استاد سال ۱۴۰۳'),
      ConsultantResumeItem(title: '۲۲ سال سابقه مشاوره تحصیلی'),
    ],
  ),
  Consultant(
    id: 'c3',
    name: 'علیرضا یوسفی',
    specialty: 'فوق تخصص مشاوره تحصیلی',
    rating: '۴',
    maxRating: '۵',
    avatar: _kSampleAvatar,
    resume: [
      ConsultantResumeItem(title: 'استاد دانشگاه دولتی یزد'),
      ConsultantResumeItem(title: 'تندیس بهترین استاد سال ۱۴۰۳'),
      ConsultantResumeItem(title: '۲۲ سال سابقه مشاوره تحصیلی'),
    ],
  ),
  Consultant(
    id: 'c4',
    name: 'علیرضا یوسفی',
    specialty: 'فوق تخصص مشاوره تحصیلی',
    rating: '۴',
    maxRating: '۵',
    avatar: _kSampleAvatar,
    resume: [
      ConsultantResumeItem(title: 'استاد دانشگاه دولتی یزد'),
      ConsultantResumeItem(title: 'تندیس بهترین استاد سال ۱۴۰۳'),
      ConsultantResumeItem(title: '۲۲ سال سابقه مشاوره تحصیلی'),
    ],
  ),
];
