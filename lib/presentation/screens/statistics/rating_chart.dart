import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/graphql/queries/__generated__/statistics_dashboard.data.gql.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';

/// How the student rated their own work: the period's average, each day's
/// average (as in the test chart, oldest on the left) and each subject's.
/// Ratings come from task reports, so days and subjects without one are
/// shown empty rather than as zero.
class RatingChart extends StatelessWidget {
  const RatingChart({
    super.key,
    required this.dailyBuckets,
    required this.subjectBuckets,
  });

  final List<GStatisticsDashboardData_statisticsDashboard_dailyBuckets>
      dailyBuckets;
  final List<GStatisticsDashboardData_statisticsDashboard_subjectBuckets>
      subjectBuckets;

  static const double _barMaxHeight = 96;

  /// "۳٫۸": one decimal, dropped when whole.
  static String formatRating(double value) {
    final rounded = (value * 10).round() / 10;
    final text = rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toStringAsFixed(1).replaceAll('.', '٫');
    return convertToPersianNumbers(text);
  }

  @override
  Widget build(BuildContext context) {
    final rated = [
      for (final bucket in dailyBuckets)
        if (bucket.averagePerformanceRating != null)
          bucket.averagePerformanceRating!,
    ];
    final subjects = [
      for (final bucket in subjectBuckets)
        if (bucket.averagePerformanceRating != null) bucket,
    ]..sort((a, b) =>
        b.averagePerformanceRating!.compareTo(a.averagePerformanceRating!));
    final average =
        rated.isEmpty ? null : rated.reduce((a, b) => a + b) / rated.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        key: const ValueKey('rating-chart'),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(blurRadius: 10, color: AppColors.black1.withAlpha(15)),
          ],
        ),
        child: average == null
            ? const _EmptyRatings()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AverageHeader(average: average),
                  const SizedBox(height: 18),
                  _buildDays(),
                  if (subjects.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.gray2),
                    const SizedBox(height: 14),
                    for (final subject in subjects) ...[
                      _SubjectRow(
                        name: subject.tagName,
                        rating: subject.averagePerformanceRating!,
                      ),
                      if (subject != subjects.last) const SizedBox(height: 10),
                    ],
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildDays() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final bucket in dailyBuckets)
            Expanded(child: _DayColumn(bucket: bucket)),
        ],
      ),
    );
  }
}

class _AverageHeader extends StatelessWidget {
  const _AverageHeader({required this.average});

  final double average;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.simoCoin.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.star_rounded,
              size: 22, color: AppColors.simoCoin),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: ReText(
            'میانگین امتیاز به خودت',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.gray,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 12),
        ReText(
          RatingChart.formatRating(average),
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: AppColors.black1,
        ),
        const SizedBox(width: 4),
        const ReText(
          'از ۵',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.gray,
        ),
      ],
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({required this.bucket});

  final GStatisticsDashboardData_statisticsDashboard_dailyBuckets bucket;

  @override
  Widget build(BuildContext context) {
    final rating = bucket.averagePerformanceRating;
    final day = Jalali.fromDateTime(DateTime.parse(bucket.start.value));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 16,
          child: rating == null
              ? null
              : ReText(
                  RatingChart.formatRating(rating),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black1,
                ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: RatingChart._barMaxHeight,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: rating == null
                ? Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.gray2,
                      shape: BoxShape.circle,
                    ),
                  )
                : TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: (rating / 5).clamp(0.0, 1.0)),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (context, share, _) => Container(
                      width: 12,
                      height: RatingChart._barMaxHeight * share,
                      decoration: BoxDecoration(
                        color: AppColors.simoCoin,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        ReText(
          convertToPersianNumbers('${day.day}'),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.black1,
        ),
      ],
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.name, required this.rating});

  final String name;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: ReText(
            name,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.black1,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: (rating / 5).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.gray2,
              valueColor: const AlwaysStoppedAnimation(AppColors.simoCoin),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 28,
          child: ReText(
            RatingChart.formatRating(rating),
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
            color: AppColors.black1,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}

class _EmptyRatings extends StatelessWidget {
  const _EmptyRatings();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Icon(Icons.star_outline_rounded, size: 28, color: AppColors.gray),
          SizedBox(height: 8),
          ReText(
            'هنوز گزارشی ثبت نکرده‌ای.',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.black1,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          ReText(
            'بعد از انجام هر تسک به خودت امتیاز بده تا روندت اینجا دیده شود.',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.gray,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
