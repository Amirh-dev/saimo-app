import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:simo_learn/features/statistics/cubit/statistics_state.dart';
import 'package:simo_learn/features/statistics/statistics_overview.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_format.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';

/// The range's study time, its change, and how much of the plan got done.
class StudyHeroCard extends StatelessWidget {
  const StudyHeroCard({
    super.key,
    required this.overview,
    required this.range,
  });

  final StatisticsOverview overview;
  final StatisticsRange range;

  @override
  Widget build(BuildContext context) {
    return StatCard(
      padding: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const TintIcon(
                          IconsaxPlusBold.clock,
                          StatColors.study,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: ReText(
                            StatsFormat.studyTitle(range),
                            fontSize: 13,
                            fontWeight: 700,
                            color: StatColors.muted,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    CountUp(
                      value: overview.studySeconds.toDouble(),
                      builder: (context, value) =>
                          _HoursMinutes(seconds: value.round()),
                    ),
                    const SizedBox(height: 6),
                    _StudyChange(overview: overview, range: range),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              PlanRing(overview: overview),
            ],
          ),
          const SizedBox(height: 16),
          _PlanLegend(overview: overview),
        ],
      ),
    );
  }
}

class _HoursMinutes extends StatelessWidget {
  const _HoursMinutes({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;
    Widget number(int value) => ReText(
          '$value',
          fontSize: 38,
          fontWeight: 1000,
          color: StatColors.ink,
          lineHeight: 1.25,
        );
    Widget unit(String text) => ReText(
          text,
          fontSize: 13,
          fontWeight: 700,
          color: StatColors.muted,
        );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (hours > 0) ...[
          number(hours),
          const SizedBox(width: 3),
          unit('ساعت'),
          const SizedBox(width: 8),
        ],
        number(minutes % 60),
        const SizedBox(width: 3),
        unit('دقیقه'),
      ],
    );
  }
}

class _StudyChange extends StatelessWidget {
  const _StudyChange({required this.overview, required this.range});

  final StatisticsOverview overview;
  final StatisticsRange range;

  @override
  Widget build(BuildContext context) {
    final difference = overview.studyDifference;
    if (difference == null) return const SizedBox.shrink();
    final previous = StatsFormat.previousName(range);
    if (overview.previousStudySeconds == 0) {
      return ReText(
        '$previous مطالعه‌ای ثبت نشده بود',
        fontSize: 11.5,
        fontWeight: 600,
        color: StatColors.muted,
      );
    }
    final chip = ChangeChip(
      difference == 0
          ? 'هم‌اندازه‌ی $previous'
          : '${StatsFormat.clock(difference.abs())} '
              '${difference > 0 ? 'بیشتر' : 'کمتر'} از $previous',
      change: difference,
    );
    if (!range.isPartial || range.period == StatisticsPeriod.today) {
      return chip;
    }
    // A running week is set against the same days of the week before.
    final days = range.lastElapsed.julianDayNumber -
        range.first.julianDayNumber +
        1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        chip,
        const SizedBox(height: 4),
        ReText(
          'در مقایسه با $days روز اول $previous',
          fontSize: 10.5,
          fontWeight: 600,
          color: StatColors.muted,
        ),
      ],
    );
  }
}

/// Planned time as a ring: finished tasks, then the timer time of
/// unfinished ones in a lighter blue, then what is left.
class PlanRing extends StatelessWidget {
  const PlanRing({super.key, required this.overview, this.size = 104});

  final StatisticsOverview overview;
  final double size;

  @override
  Widget build(BuildContext context) {
    final planned = overview.plannedSeconds;
    final finished = planned == 0 ? 0.0 : overview.finishedSeconds / planned;
    final progressed =
        planned == 0 ? 0.0 : overview.progressedSeconds / planned;
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: StatMotion.of(context, const Duration(milliseconds: 1000)),
        curve: StatMotion.curve,
        builder: (context, t, child) => CustomPaint(
          painter: _RingPainter(
            finished: finished.clamp(0.0, 1.0) * t,
            progressed: progressed.clamp(0.0, 1.0) * t,
          ),
          child: child,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (planned == 0)
                const ReText(
                  '-',
                  fontSize: 22,
                  fontWeight: 1000,
                  color: StatColors.muted,
                  textAlign: TextAlign.center,
                )
              else
                CountUp(
                  value: overview.progress,
                  builder: (context, value) => ReText(
                    '${value.round()}٪',
                    fontSize: 22,
                    fontWeight: 1000,
                    color: StatColors.ink,
                    textAlign: TextAlign.center,
                  ),
                ),
              ReText(
                planned == 0 ? 'بدون برنامه' : 'پیشرفت برنامه',
                fontSize: 10,
                fontWeight: 700,
                color: StatColors.muted,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.finished, required this.progressed});

  final double finished;
  final double progressed;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    Paint arc(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    const start = -math.pi / 2;
    canvas.drawArc(rect, 0, math.pi * 2, false, arc(StatColors.surface));
    if (progressed > finished) {
      canvas.drawArc(
        rect,
        start,
        math.pi * 2 * progressed,
        false,
        arc(StatColors.studySoft),
      );
    }
    if (finished > 0) {
      canvas.drawArc(
        rect,
        start,
        math.pi * 2 * finished,
        false,
        arc(StatColors.study),
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.finished != finished || oldDelegate.progressed != progressed;
}

class _PlanLegend extends StatelessWidget {
  const _PlanLegend({required this.overview});

  final StatisticsOverview overview;

  @override
  Widget build(BuildContext context) {
    final planned = overview.plannedSeconds;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: StatColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: planned == 0
          ? const Row(
              children: [
                Icon(IconsaxPlusLinear.info_circle,
                    size: 16, color: StatColors.muted),
                SizedBox(width: 6),
                Expanded(
                  child: ReText(
                    'در این بازه تسک زمان‌دار برنامه‌ریزی نشده.',
                    fontSize: 11.5,
                    fontWeight: 600,
                    color: StatColors.muted,
                    maxLines: 1,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LegendDot(
                  StatColors.study,
                  'کامل‌شده ${StatsFormat.clock(overview.finishedSeconds)}',
                ),
                LegendDot(
                  StatColors.studySoft,
                  'نیمه‌کاره ${StatsFormat.clock(overview.progressedSeconds - overview.finishedSeconds)}',
                ),
                LegendDot(
                  StatColors.line,
                  'مانده ${StatsFormat.clock(math.max(0, planned - overview.progressedSeconds))}',
                ),
              ],
            ),
    );
  }
}

