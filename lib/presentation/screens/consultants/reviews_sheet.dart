// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_models.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_repository.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:simo_learn/utils/jalali_text.dart';
import 'package:solar_icons/solar_icons.dart';

/// The soft yellow behind rating and achievement pills (coin at ~16%).
const Color kCoinSoft = Color(0xFFFDF4DF);

/// Opens a counselor's reviews in a bottom sheet: the rating summary, score
/// filters and the review list, loaded a page at a time.
Future<void> showCounselorReviewsSheet(
  BuildContext context, {
  required ConsultantRepository repository,
  required Consultant consultant,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CounselorReviewsSheet(
      repository: repository,
      consultant: consultant,
    ),
  );
}

class CounselorReviewsSheet extends StatefulWidget {
  const CounselorReviewsSheet({
    super.key,
    required this.repository,
    required this.consultant,
  });

  final ConsultantRepository repository;
  final Consultant consultant;

  @override
  State<CounselorReviewsSheet> createState() => _CounselorReviewsSheetState();
}

class _CounselorReviewsSheetState extends State<CounselorReviewsSheet> {
  static const int _pageSize = 20;

  Map<int, int>? _distribution;
  List<CounselorReview> _reviews = const [];
  ReviewScoreFilter _filter = ReviewScoreFilter.all;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  bool _failed = false;
  final Set<String> _expanded = {};

  /// Bumped on every filter change so a slow answer for an old filter is
  /// dropped instead of replacing the list.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _loadDistribution();
    _loadFirstPage();
  }

  Future<void> _loadDistribution() async {
    try {
      final counts = await widget.repository
          .fetchRatingDistribution(widget.consultant.id);
      if (mounted) setState(() => _distribution = counts);
    } catch (_) {
      // The summary still shows the average; only the bars are missing.
    }
  }

  Future<void> _loadFirstPage() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final page = await widget.repository.fetchReviews(
        widget.consultant.id,
        filter: _filter,
        limit: _pageSize,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _reviews = page;
        _hasMore = page.length == _pageSize;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    final generation = _generation;
    setState(() => _loadingMore = true);
    try {
      final page = await widget.repository.fetchReviews(
        widget.consultant.id,
        filter: _filter,
        limit: _pageSize,
        offset: _reviews.length,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _reviews = [..._reviews, ...page];
        _hasMore = page.length == _pageSize;
      });
    } catch (_) {
      if (mounted) {
        showReToast(
          context,
          'دریافت نظرات بیشتر ممکن نشد.',
          ReToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _pickFilter(ReviewScoreFilter filter) {
    if (filter == _filter) return;
    _filter = filter;
    _expanded.clear();
    _loadFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // A fixed height, so switching filters never makes the sheet jump.
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCDDE3),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              _buildHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 24),
                  children: [
                    _RatingSummary(
                      rating: widget.consultant.rating,
                      ratingCount: widget.consultant.ratingCount,
                      distribution: _distribution,
                    ),
                    const SizedBox(height: 12),
                    _buildFilters(),
                    const SizedBox(height: 12),
                    ..._buildBody(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final consultant = widget.consultant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ReText(
                  'نظرات دانش‌آموزان',
                  color: AppColors.black1,
                  fontSize: 18,
                  fontWeight: 900,
                  textAlign: TextAlign.right,
                ),
                ReText(
                  consultant.specialty.isEmpty
                      ? consultant.name
                      : '${consultant.name}، ${consultant.specialty}',
                  color: AppColors.gray,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            button: true,
            label: 'بستن',
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.whiteSec,
                  shape: BoxShape.circle,
                  boxShadow: _pillShadow,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: AppColors.black1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final filter in ReviewScoreFilter.values) ...[
            if (filter != ReviewScoreFilter.values.first)
              const SizedBox(width: 8),
            _FilterChip(
              label: filter.label,
              selected: filter == _filter,
              onTap: () => _pickFilter(filter),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildBody() {
    if (_loading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator.adaptive()),
        ),
      ];
    }
    if (_failed) {
      return [
        _Notice(
          title: 'دریافت نظرات ممکن نشد',
          message: 'اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.',
          actionLabel: 'تلاش دوباره',
          onAction: _loadFirstPage,
        ),
      ];
    }
    if (_reviews.isEmpty) {
      return [
        _filter == ReviewScoreFilter.all
            ? const _Notice(
                title: 'هنوز نظری ثبت نشده است',
                message: 'نظر دانش‌آموزان پس از دوره مشاوره اینجا می‌آید.',
              )
            : const _Notice(
                title: 'نظری با این امتیاز ثبت نشده است',
                message: 'فیلتر دیگری را انتخاب کنید.',
              ),
      ];
    }
    return [
      for (final review in _reviews) ...[
        _ReviewCard(
          review: review,
          expanded: _expanded.contains(review.id),
          onToggle: () => setState(() {
            if (!_expanded.remove(review.id)) _expanded.add(review.id);
          }),
        ),
        const SizedBox(height: 12),
      ],
      if (_hasMore)
        Center(
          child: _loadingMore
              ? const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator.adaptive(),
                )
              : _WhitePill(
                  label: 'نمایش نظرات بیشتر',
                  onTap: _loadMore,
                ),
        ),
    ];
  }
}

final List<BoxShadow> _cardShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 24,
    offset: const Offset(0, 10),
  ),
];

final List<BoxShadow> _pillShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.06),
    blurRadius: 15,
    offset: const Offset(0, 8),
  ),
];

/// The coin-colored circle with an ink icon used on rating and achievement
/// pills.
class CoinBadge extends StatelessWidget {
  const CoinBadge({
    super.key,
    required this.icon,
    this.size = 40,
    this.iconSize = 20,
    this.glow = true,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.simoCoin,
        shape: BoxShape.circle,
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AppColors.simoCoin.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Icon(icon, size: iconSize, color: AppColors.black1),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({
    required this.rating,
    required this.ratingCount,
    required this.distribution,
  });

  final String rating;
  final int ratingCount;
  final Map<int, int>? distribution;

  @override
  Widget build(BuildContext context) {
    final counts = distribution;
    final total = counts?.values.fold<int>(0, (sum, n) => sum + n) ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteSec,
        borderRadius: BorderRadius.circular(32),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  rating,
                  color: AppColors.black1,
                  fontSize: 22,
                  fontWeight: 1000,
                ),
                const SizedBox(width: 8),
                ReText(
                  'از ${convertToPersianNumbers(ratingCount.toString())} نظر',
                  color: AppColors.dark8Color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ),
          if (counts != null && total > 0) ...[
            const SizedBox(height: 14),
            for (var score = 5; score >= 1; score--)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                child: _DistributionBar(
                  score: score,
                  count: counts[score] ?? 0,
                  total: total,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _DistributionBar extends StatelessWidget {
  const _DistributionBar({
    required this.score,
    required this.count,
    required this.total,
  });

  final int score;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${convertToPersianNumbers('$count')} نظر با '
          '${convertToPersianNumbers('$score')} ستاره',
      excludeSemantics: true,
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: ReText(
              '$score',
              color: AppColors.black1,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 8,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.gray1,
                borderRadius: BorderRadius.circular(100),
              ),
              child: FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: total == 0 ? 0 : count / total,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.simoCoin,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 22,
            child: ReText(
              '$count',
              color: AppColors.dark8Color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.black1 : AppColors.whiteSec,
            borderRadius: BorderRadius.circular(100),
            boxShadow: selected ? null : _pillShadow,
          ),
          child: ReText(
            label,
            color: selected ? AppColors.whiteSec : AppColors.black1,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.expanded,
    required this.onToggle,
  });

  /// Longer texts are cut to three lines with «ادامه».
  static const int _longText = 140;

  final CounselorReview review;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final comment = review.comment;
    final long = comment != null && comment.length > _longText;
    final date = Jalali.fromDateTime(review.createdAt);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteSec,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _ReviewAuthorAvatar(review: review),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReText(
                      review.authorName,
                      color: AppColors.black1,
                      fontSize: 14,
                      fontWeight: 900,
                      textAlign: TextAlign.right,
                    ),
                    ReText(
                      '${JalaliText.dayMonth(date)} ${date.year}',
                      color: AppColors.gray,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ScorePill(score: review.score),
            ],
          ),
          if (comment != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.gray2)),
              ),
              child: ReText(
                comment,
                color: AppColors.black1,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.right,
                lineHeight: 1.9,
                maxLines: long && !expanded ? 3 : null,
                overflow: long && !expanded
                    ? TextOverflow.ellipsis
                    : TextOverflow.visible,
              ),
            ),
            if (long) ...[
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.gray1,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: ReText(
                      expanded ? 'بستن' : 'ادامه',
                      color: AppColors.black1,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// The photo an admin set for the review, or the name's first letter when
/// there is none or it does not load.
class _ReviewAuthorAvatar extends StatelessWidget {
  const _ReviewAuthorAvatar({required this.review});

  final CounselorReview review;

  @override
  Widget build(BuildContext context) {
    final initial = Center(
      child: ReText(
        review.authorName.characters.first,
        color: AppColors.black1,
        fontSize: 15,
        fontWeight: 900,
      ),
    );
    final url = review.authorAvatarUrl;
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.gray1,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? initial
          : Image.network(
              url,
              key: const ValueKey('review-author-photo'),
              fit: BoxFit.cover,
              width: 44,
              height: 44,
              cacheWidth: 132,
              errorBuilder: (_, __, ___) => initial,
            ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${convertToPersianNumbers('$score')} از ۵',
      excludeSemantics: true,
      child: Container(
        height: 32,
        padding: const EdgeInsetsDirectional.only(start: 4, end: 12),
        decoration: BoxDecoration(
          color: kCoinSoft,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CoinBadge(
              icon: Icons.star_rounded,
              size: 24,
              iconSize: 14,
              glow: false,
            ),
            const SizedBox(width: 6),
            ReText(
              '$score',
              color: AppColors.black1,
              fontSize: 13,
              fontWeight: 900,
            ),
          ],
        ),
      ),
    );
  }
}

class _WhitePill extends StatelessWidget {
  const _WhitePill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.whiteSec,
          borderRadius: BorderRadius.circular(100),
          boxShadow: _pillShadow,
        ),
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

class _Notice extends StatelessWidget {
  const _Notice({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.whiteSec,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _cardShadow,
      ),
      child: Column(
        children: [
          const Icon(
            SolarIconsOutline.chatRoundLine,
            size: 28,
            color: AppColors.gray,
          ),
          const SizedBox(height: 10),
          ReText(
            title,
            color: AppColors.black1,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          ReText(
            message,
            color: AppColors.dark8Color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            _WhitePill(label: actionLabel!, onTap: onAction!),
          ],
        ],
      ),
    );
  }
}
