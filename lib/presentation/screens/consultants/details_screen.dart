// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_models.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/reviews_sheet.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

/// Opens a counselor's details page («جزئیات» on the list card). [onSelect]
/// runs after the page closes, so the purchase flow starts from the list.
Future<void> openConsultantDetails(
  BuildContext context, {
  required Consultant consultant,
  required ConsultantRepository? repository,
  required VoidCallback onSelect,
}) async {
  final selected = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => ConsultantDetailsScreen(
        consultant: consultant,
        repository: repository,
      ),
    ),
  );
  if (selected == true) onSelect();
}

/// Everything a student needs to choose a counselor, top to bottom: who they
/// are and their numbers, why them, academic record, what counseling with
/// them gives, personality, the verified student card and reviews. Every
/// section is left out when the counselor has not filled it in. Pops `true`
/// when the student taps «انتخاب مشاور».
class ConsultantDetailsScreen extends StatefulWidget {
  const ConsultantDetailsScreen({
    super.key,
    required this.consultant,
    required this.repository,
  });

  final Consultant consultant;
  final ConsultantRepository? repository;

  @override
  State<ConsultantDetailsScreen> createState() =>
      _ConsultantDetailsScreenState();
}

class _ConsultantDetailsScreenState extends State<ConsultantDetailsScreen> {
  /// Reviews previewed on the page; the rest open in the reviews sheet.
  static const int _previewReviews = 2;

  final GlobalKey _reviewsKey = GlobalKey();
  int? _studentCount;
  List<CounselorReview> _reviews = const [];
  final Set<String> _openReviews = {};
  bool _storyOpen = false;

  Consultant get _c => widget.consultant;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Both figures are extras: a failure only leaves them out.
  Future<void> _load() async {
    final repository = widget.repository;
    if (repository == null) return;
    try {
      final count = await repository.fetchStudentCount(_c.id);
      if (mounted) setState(() => _studentCount = count);
    } catch (_) {}
    if (_c.ratingCount == 0) return;
    try {
      final reviews =
          await repository.fetchReviews(_c.id, limit: _previewReviews);
      if (mounted) setState(() => _reviews = reviews);
    } catch (_) {}
  }

  void _scrollToReviews() {
    final target = _reviewsKey.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _openAllReviews() {
    final repository = widget.repository;
    if (repository == null) return;
    showCounselorReviewsSheet(context, repository: repository, consultant: _c);
  }

  /// Timeline rows: the academic record, or for older profiles the résumé
  /// lines after the highlight.
  List<CounselorEducation> get _timeline => _c.education.isNotEmpty
      ? _c.education
      : [
          for (final item in _c.resume.skip(1))
            CounselorEducation(title: item.title),
        ];

  @override
  Widget build(BuildContext context) {
    final timeline = _timeline;
    return Scaffold(
      backgroundColor: AppColors.gray1,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              // One scroll view, not a lazy list: the rating pill scrolls to
              // the reviews, which must already be built.
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHero(),
                    if (_c.intro.isNotEmpty || _c.bio.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _buildIntro(),
                    ],
                    if (timeline.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _Section(
                        title: 'سوابق تحصیلی',
                        child: _Timeline(items: timeline),
                      ),
                    ],
                    if (_c.skills.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _Section(
                        title: 'در مشاوره با من چی می‌گیری',
                        child: Column(
                          children: [
                            for (var i = 0; i < _c.skills.length; i++) ...[
                              if (i > 0) const SizedBox(height: 8),
                              _SkillTile(skill: _c.skills[i]),
                            ],
                          ],
                        ),
                      ),
                    ],
                    if (_c.traits.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _Section(
                        title: 'ویژگی‌های شخصیتی',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final trait in _c.traits) _TraitChip(trait),
                          ],
                        ),
                      ),
                    ],
                    if (_c.studentCardUrl != null) ...[
                      const SizedBox(height: 14),
                      _VerifiedCard(url: _c.studentCardUrl!),
                    ],
                    if (_c.ratingCount > 0) ...[
                      const SizedBox(height: 22),
                      _buildReviews(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildSelectBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Spacer(),
            const ReText(
              'جزئیات مشاور',
              color: AppColors.black1,
              fontSize: 16,
              fontWeight: 1000,
            ),
            IconButton(
              tooltip: 'بازگشت',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                SolarIconsOutline.altArrowRight,
                size: 22,
                color: AppColors.black1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    final highlight = _c.resume.isEmpty ? null : _c.resume.first;
    final stats = <(String, String)>[
      if ((_c.experienceYears ?? 0) > 0)
        (
          '${convertToPersianNumbers(_c.experienceYears.toString())} سال',
          'سابقه مشاوره'
        ),
      if ((_studentCount ?? 0) > 0)
        (convertToPersianNumbers(_studentCount.toString()), 'دانش‌آموز'),
    ];
    return _Card(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: _HeroAvatar(path: _c.avatar, verified: _c.isVerified),
          ),
          const SizedBox(height: 12),
          ReText(
            _c.name,
            color: AppColors.black1,
            fontSize: 20,
            fontWeight: 1000,
            textAlign: TextAlign.center,
          ),
          if (_c.specialty.isNotEmpty) ...[
            const SizedBox(height: 4),
            ReText(
              _c.specialty,
              color: AppColors.dark8Color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
          const SizedBox(height: 10),
          Center(child: _buildRatingPill()),
          if (highlight != null) ...[
            const SizedBox(height: 16),
            _HighlightPill(title: highlight.title),
          ],
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < stats.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _StatTile(value: stats[i].$1, label: stats[i].$2),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingPill() {
    final rated = _c.ratingCount > 0;
    final pill = Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (rated) ...[
            const Icon(Icons.star_rounded, size: 16, color: AppColors.simoCoin),
            const SizedBox(width: 4),
            ReText(
              _c.rating,
              color: AppColors.black1,
              fontSize: 12,
              fontWeight: 900,
            ),
            const SizedBox(width: 4),
            ReText(
              'از ${convertToPersianNumbers(_c.ratingCount.toString())} نظر',
              color: AppColors.dark8Color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ] else
            const ReText(
              'مشاور جدید',
              color: AppColors.black1,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
        ],
      ),
    );
    if (!rated) return pill;
    return Semantics(
      button: true,
      label: 'رفتن به نظرات',
      child: GestureDetector(onTap: _scrollToReviews, child: pill),
    );
  }

  Widget _buildIntro() {
    final pitch = _c.intro;
    final story = _c.bio;
    // Without a pitch the story leads, still clamped until opened.
    final storyBody = ReText(
      story,
      color: pitch.isEmpty ? AppColors.black1 : AppColors.dark8Color,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      textAlign: TextAlign.right,
      lineHeight: 1.9,
      maxLines: _storyOpen ? null : 2,
      overflow: _storyOpen ? TextOverflow.visible : TextOverflow.ellipsis,
    );
    return _Section(
      title: 'چرا من مشاورت باشم',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (pitch.isNotEmpty)
            ReText(
              pitch,
              color: AppColors.black1,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.right,
              lineHeight: 1.9,
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
          if (story.isNotEmpty) ...[
            if (pitch.isNotEmpty) const SizedBox(height: 10),
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: storyBody,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: _SoftButton(
                label: _storyOpen ? 'بستن' : 'داستان من',
                onTap: () => setState(() => _storyOpen = !_storyOpen),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviews() {
    final count = convertToPersianNumbers(_c.ratingCount.toString());
    return Column(
      key: _reviewsKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsetsDirectional.only(start: 4, bottom: 12),
          child: ReText(
            'نظرات دانش‌آموزان',
            color: AppColors.black1,
            fontSize: 16,
            fontWeight: 900,
            textAlign: TextAlign.right,
          ),
        ),
        Container(
          height: 60,
          padding: const EdgeInsetsDirectional.only(start: 10, end: 18),
          decoration: BoxDecoration(
            color: kCoinSoft,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            children: [
              const CoinBadge(icon: Icons.star_rounded),
              const SizedBox(width: 12),
              ReText(
                _c.rating,
                color: AppColors.black1,
                fontSize: 22,
                fontWeight: 1000,
              ),
              const SizedBox(width: 8),
              ReText(
                'از $count نظر',
                color: AppColors.dark8Color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ),
        for (final review in _reviews) ...[
          const SizedBox(height: 12),
          CounselorReviewCard(
            review: review,
            expanded: _openReviews.contains(review.id),
            onToggle: () => setState(() {
              if (!_openReviews.remove(review.id)) _openReviews.add(review.id);
            }),
          ),
        ],
        const SizedBox(height: 12),
        Center(
          child: _WhiteButton(
            label: 'دیدن همه $count نظر',
            onTap: _openAllReviews,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: SafeArea(
        top: false,
        child: ReButton(
          text: 'انتخاب مشاور',
          background: AppColors.secondary,
          borderRadius: 40,
          height: 55,
          fontSize: 15,
          fontWeight: FontWeight.w800,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ),
    );
  }
}

/// A white card on the gray page.
class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.whiteSec,
        borderRadius: BorderRadius.circular(32),
        boxShadow: kCounselorCardShadow,
      ),
      child: child,
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReText(
            title,
            color: AppColors.black1,
            fontSize: 16,
            fontWeight: 900,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _HeroAvatar extends StatelessWidget {
  const _HeroAvatar({required this.path, required this.verified});

  final String path;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    const fallback = Icon(SolarIconsBold.user, size: 40, color: AppColors.gray);
    final image = path.startsWith('http')
        ? Image.network(
            path,
            fit: BoxFit.cover,
            cacheWidth: 288,
            errorBuilder: (_, __, ___) => fallback,
          )
        : Image.asset(
            path,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback,
          );
    return Semantics(
      label: verified ? 'دانشجو بودنش تأیید شده' : null,
      child: SizedBox(
        width: 96,
        height: 96,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.gray1,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: image,
            ),
            if (verified)
              PositionedDirectional(
                bottom: 2,
                end: 2,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.whiteSec, width: 3),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: AppColors.whiteSec,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The strongest résumé line, as on the list card.
class _HighlightPill extends StatelessWidget {
  const _HighlightPill({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 18, 10),
      decoration: BoxDecoration(
        color: kCoinSoft,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          const CoinBadge(icon: SolarIconsOutline.cupStar),
          const SizedBox(width: 12),
          Expanded(
            child: ReText(
              title,
              color: AppColors.black1,
              fontSize: 16,
              fontWeight: 900,
              textAlign: TextAlign.right,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          ReText(
            value,
            color: AppColors.black1,
            fontSize: 17,
            fontWeight: 1000,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          ReText(
            label,
            color: AppColors.dark8Color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Dots joined by a line: the first (latest) step filled, the rest hollow.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.items});

  final List<CounselorEducation> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 14,
                  child: Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: i == 0 ? AppColors.black1 : AppColors.whiteSec,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.black1, width: 3),
                        ),
                      ),
                      if (i < items.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.gray2,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: i < items.length - 1 ? 16 : 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ReText(
                          items[i].title,
                          color: AppColors.black1,
                          fontSize: 14,
                          fontWeight: 900,
                          textAlign: TextAlign.right,
                          maxLines: 2,
                        ),
                        if (items[i].detail.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          ReText(
                            items[i].detail,
                            color: AppColors.dark8Color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SkillTile extends StatelessWidget {
  const _SkillTile({required this.skill});

  final CounselorSkill skill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.whiteSec,
              shape: BoxShape.circle,
              boxShadow: kCounselorPillShadow,
            ),
            child: const Icon(
              SolarIconsOutline.checkCircle,
              size: 20,
              color: AppColors.black1,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 2),
                ReText(
                  skill.title,
                  color: AppColors.black1,
                  fontSize: 14,
                  fontWeight: 900,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                ),
                if (skill.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  ReText(
                    skill.description,
                    color: AppColors.dark8Color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.right,
                    lineHeight: 1.8,
                    maxLines: null,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TraitChip extends StatelessWidget {
  const _TraitChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.whiteSec,
        borderRadius: BorderRadius.circular(100),
        boxShadow: kCounselorPillShadow,
      ),
      child: Center(
        widthFactor: 1,
        child: ReText(
          label,
          color: AppColors.black1,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// The administrator-verified student card the counselor uploaded.
class _VerifiedCard extends StatelessWidget {
  const _VerifiedCard({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  SolarIconsOutline.shieldCheck,
                  size: 18,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReText(
                      'دانشجو بودنش تأیید شده',
                      color: AppColors.black1,
                      fontSize: 16,
                      fontWeight: 900,
                      textAlign: TextAlign.right,
                    ),
                    ReText(
                      'سایمو کارت دانشجویی‌ش رو بررسی کرده.',
                      color: AppColors.dark8Color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gray1,
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: Image.network(
                  url,
                  key: const ValueKey('student-card-photo'),
                  fit: BoxFit.contain,
                  cacheWidth: 900,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 120,
                    child: Center(
                      child: Icon(
                        SolarIconsOutline.gallery,
                        color: AppColors.gray,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftButton extends StatelessWidget {
  const _SoftButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.gray1,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            widthFactor: 1,
            child: ReText(
              label,
              color: AppColors.black1,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _WhiteButton extends StatelessWidget {
  const _WhiteButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: AppColors.whiteSec,
            borderRadius: BorderRadius.circular(100),
            boxShadow: kCounselorPillShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReText(
                label,
                color: AppColors.black1,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
              const SizedBox(width: 4),
              const Icon(
                SolarIconsOutline.altArrowLeft,
                size: 16,
                color: AppColors.black1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
