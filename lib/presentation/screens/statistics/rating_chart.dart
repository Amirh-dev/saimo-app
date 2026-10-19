import 'package:flutter/material.dart';
import 'package:simo_learn/features/statistics/statistics_overview.dart';
import 'package:simo_learn/presentation/screens/statistics/stat_bar_chart.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_format.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/_utils.dart';

/// How the student rated their own work: the average, each day's average
/// and each subject's. Ratings come from task reports, so days and subjects
/// without one are shown empty rather than as zero.
class RatingChart extends StatelessWidget {
  const RatingChart({
    super.key,
    required this.days,
    required this.subjects,
  });

  final List<StatisticsDay> days;
  final List<SubjectStatistics> subjects;

  /// "۳٫۸": one decimal, dropped when whole.
  static String formatRating(double value) =>
      convertToPersianNumbers(StatsFormat.decimal(value));

  @override
  Widget build(BuildContext context) {
    final rated = [
      for (final day in days)
        if (day.rating != null) day.rating!,
    ];
    final ratedSubjects = [
      for (final subject in subjects)
        if (subject.rating != null) subject,
    ]..sort((a, b) => b.rating!.compareTo(a.rating!));
    final average =
        rated.isEmpty ? null : rated.reduce((a, b) => a + b) / rated.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StatSectionTitle('امتیاز به خودت'),
        const SizedBox(height: 12),
        StatCard(
          key: const ValueKey('rating-chart'),
          child: average == null
              ? const _EmptyRatings()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const TintIcon(Icons.star_rounded, StatColors.rating),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: ReText(
                            'میانگین امتیاز به خودت',
                            fontSize: 13,
                            fontWeight: 700,
                            color: StatColors.muted,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                          ),
                        ),
                        CountUp(
                          value: average,
                          builder: (context, value) => ReText(
                            formatRating(value),
                            fontSize: 22,
                            fontWeight: 1000,
                            color: StatColors.ink,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const ReText(
                          'از ۵',
                          fontSize: 12,
                          fontWeight: 700,
                          color: StatColors.muted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    StatBarChart(
                      maxValue: 5,
                      plotHeight: 64,
                      barWidth: 12,
                      bars: [
                        for (final day in days)
                          ChartBar(
                            segments: [
                              BarSegment(day.rating ?? 0, StatColors.rating),
                            ],
                            label: days.length <= 7
                                ? StatsFormat.weekdayInitial(day.first)
                                : '',
                            caption: days.length <= 7 ? '${day.first.day}' : '',
                            valueLabel: days.length <= 7 && day.rating != null
                                ? StatsFormat.decimal(day.rating!)
                                : null,
                            isFuture: day.isFuture,
                            isToday: day.isToday,
                            isFocused: day.isFocused,
                            tooltipTitle: day.isGroup
                                ? '${StatsFormat.dayMonth(day.first)} تا ${StatsFormat.dayMonth(day.last)}'
                                : StatsFormat.fullDay(day.first),
                            tooltipBody: day.rating == null
                                ? 'امتیازی ثبت نشده'
                                : 'امتیاز ${StatsFormat.decimal(day.rating!)} از ۵',
                          ),
                      ],
                    ),
                    if (ratedSubjects.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      const Divider(height: 1, color: StatColors.line),
                      const SizedBox(height: 14),
                      for (var i = 0; i < ratedSubjects.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        _SubjectRow(
                          name: ratedSubjects[i].name,
                          rating: ratedSubjects[i].rating!,
                          order: i,
                        ),
                      ],
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({
    required this.name,
    required this.rating,
    required this.order,
  });

  final String name;
  final double rating;
  final int order;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: ReText(
            name,
            fontSize: 12.5,
            fontWeight: 700,
            color: StatColors.ink,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: StatColors.surface,
              borderRadius: BorderRadius.circular(100),
            ),
            alignment: AlignmentDirectional.centerStart,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: (rating / 5).clamp(0.0, 1.0)),
              duration: StatMotion.of(
                context,
                Duration(milliseconds: 650 + order * 90),
              ),
              curve: StatMotion.curve,
              builder: (context, value, _) => FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: StatColors.rating,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 28,
          child: ReText(
            RatingChart.formatRating(rating),
            fontSize: 12.5,
            fontWeight: 900,
            color: StatColors.ink,
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
    return const GhostChartEmpty(
      color: StatColors.rating,
      icon: Icons.star_rounded,
      round: true,
      heights: [0.6, 0.8, 0.55, 0, 0.7, 0.5, 0.75],
      title: 'هنوز گزارشی ثبت نکرده‌ای',
      body: 'بعد از تمام کردن هر تسک، در گزارشش به کارت امتیاز بده '
          'تا روندت اینجا دیده شود.',
    );
  }
}
