import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:simo_learn/features/statistics/cubit/statistics_state.dart';
import 'package:simo_learn/features/statistics/statistics_overview.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_format.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';

/// The numbers under the study card, each with a picture that fits it:
/// accuracy as a correct/wrong ring, commitment as a bar, active days as a
/// row of days, and the test count across the bottom.
class SummaryBento extends StatelessWidget {
  const SummaryBento({
    super.key,
    required this.overview,
    required this.range,
    required this.days,
  });

  final StatisticsOverview overview;
  final StatisticsRange range;

  /// The charted days: the range's own, or a single day's week.
  final List<StatisticsDay> days;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _AccuracyCard(overview: overview)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _CommitmentCard(overview: overview, range: range),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _ActiveDaysCard(
                        overview: overview,
                        range: range,
                        days: days,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _TestsRow(overview: overview, range: range),
      ],
    );
  }
}

/// Grey for a zero: in Persian it is only a dot, and grey reads as "nothing
/// yet" rather than a stray mark.
Color _valueColor(num value) => value == 0 ? StatColors.muted : StatColors.ink;

class _AccuracyCard extends StatelessWidget {
  const _AccuracyCard({required this.overview});

  final StatisticsOverview overview;

  @override
  Widget build(BuildContext context) {
    final o = overview;
    final accuracy = o.accuracy;
    final total = o.totalQuestions;
    return StatCard(
      padding: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Words on the right, the icon on the left, in every card here.
          Row(
            children: [
              ChangeChip.percent(o.accuracyChange, fromNothing: accuracy != null),
              const Spacer(),
              const TintIcon(
                IconsaxPlusBold.clipboard_tick,
                StatColors.blue,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Right-aligned: ReText's default «end» is the left in RTL, and
          // these lines are stretched across the card.
          const ReText(
            'دقت پاسخ‌ها',
            fontSize: 13,
            fontWeight: 800,
            color: StatColors.ink,
            textAlign: TextAlign.right,
          ),
          ReText(
            total == 0 ? 'تستی ثبت نشده' : 'از $total تست',
            fontSize: 10.5,
            fontWeight: 600,
            color: StatColors.muted,
            textAlign: TextAlign.right,
          ),
          // The ring sits in the middle of whatever room the card has.
          const SizedBox(height: 12),
          const Spacer(),
          Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration:
                    StatMotion.of(context, const Duration(milliseconds: 1000)),
                curve: StatMotion.curve,
                builder: (context, t, child) => CustomPaint(
                  painter: _AnswersRing(
                    correct: total == 0 ? 0 : o.correctAnswers / total * t,
                    wrong: total == 0
                        ? 0
                        : (total - o.correctAnswers) / total * t,
                  ),
                  child: child,
                ),
                child: Center(
                  child: accuracy == null
                      ? const _Dash()
                      : CountUp(
                          value: accuracy,
                          builder: (context, value) => ReText(
                            '${value.round()}٪',
                            fontSize: 22,
                            fontWeight: 1000,
                            color: _valueColor(accuracy.round()),
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Count(
                  color: StatColors.correct,
                  label: 'صحیح',
                  value: o.correctAnswers,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _Count(
                  color: StatColors.wrong,
                  label: 'غلط',
                  value: total - o.correctAnswers,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// «● صحیح ۱۱۲» on a soft tile.
class _Count extends StatelessWidget {
  const _Count({required this.color, required this.label, required this.value});

  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: StatColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CountUp(
            value: value.toDouble(),
            builder: (context, v) => ReText(
              '${v.round()}',
              fontSize: 14,
              fontWeight: 1000,
              color: _valueColor(value),
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              ReText(
                label,
                fontSize: 10.5,
                fontWeight: 700,
                color: StatColors.muted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The correct share in green, then the wrong share in soft red.
class _AnswersRing extends CustomPainter {
  _AnswersRing({required this.correct, required this.wrong});

  final double correct;
  final double wrong;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 9.0;
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
    canvas.drawArc(rect, 0, math.pi * 2, false, arc(StatColors.surface));
    const start = -math.pi / 2;
    // A small gap between the two, when both are there.
    final gap = correct > 0 && wrong > 0 ? 0.12 : 0.0;
    if (wrong > 0) {
      canvas.drawArc(
        rect,
        start + math.pi * 2 * correct + gap,
        math.max(0, math.pi * 2 * wrong - gap * 2),
        false,
        arc(StatColors.wrong),
      );
    }
    if (correct > 0) {
      canvas.drawArc(
        rect,
        start,
        math.pi * 2 * correct,
        false,
        arc(StatColors.correct),
      );
    }
  }

  @override
  bool shouldRepaint(_AnswersRing oldDelegate) =>
      oldDelegate.correct != correct || oldDelegate.wrong != wrong;
}

class _CommitmentCard extends StatelessWidget {
  const _CommitmentCard({required this.overview, required this.range});

  final StatisticsOverview overview;
  final StatisticsRange range;

  @override
  Widget build(BuildContext context) {
    final o = overview;
    return StatCard(
      padding: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ChangeChip.percent(o.adherenceChange, fromNothing: o.adherence > 0),
              const Spacer(),
              const TintIcon(
                IconsaxPlusBold.medal_star,
                StatColors.yellow,
                size: 30,
              ),
            ],
          ),
          const SizedBox(height: 10),
          CountUp(
            value: o.adherence,
            builder: (context, value) => ReText(
              '${value.round()}٪',
              fontSize: 20,
              fontWeight: 1000,
              color: _valueColor(o.adherence.round()),
              textAlign: TextAlign.right,
            ),
          ),
          const ReText(
            'تعهد به برنامه',
            fontSize: 12,
            fontWeight: 800,
            color: StatColors.ink,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          _Bar(share: o.adherence / 100, color: StatColors.yellow),
          const SizedBox(height: 6),
          ReText(
            range.period == StatisticsPeriod.today
                ? '${o.completedTasks} تسک امروز انجام شد'
                : '${o.completedTasks} تسک انجام شد',
            fontSize: 10.5,
            fontWeight: 600,
            color: StatColors.muted,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

class _ActiveDaysCard extends StatelessWidget {
  const _ActiveDaysCard({
    required this.overview,
    required this.range,
    required this.days,
  });

  final StatisticsOverview overview;
  final StatisticsRange range;
  final List<StatisticsDay> days;

  @override
  Widget build(BuildContext context) {
    final isDay = range.period == StatisticsPeriod.today;
    final grouped = days.any((day) => day.isGroup);
    // A single day counts its week; otherwise the range's own numbers.
    final elapsed = grouped
        ? overview.elapsedDays
        : days.where((day) => !day.isFuture).length;
    final active = grouped
        ? overview.activeDays
        : days.where((day) => !day.isFuture && day.studySeconds > 0).length;

    return StatCard(
      padding: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              ReText(
                '$active',
                fontSize: 18,
                fontWeight: 1000,
                color: _valueColor(active),
              ),
              const SizedBox(width: 3),
              ReText(
                'از $elapsed',
                fontSize: 11,
                fontWeight: 700,
                color: StatColors.muted,
              ),
              const Spacer(),
              const TintIcon(
                Icons.local_fire_department_rounded,
                StatColors.orange,
                size: 30,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ReText(
            isDay ? 'روزهای فعال این هفته' : 'روزهای فعال',
            fontSize: 12,
            fontWeight: 800,
            color: StatColors.ink,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
          const Spacer(),
          const SizedBox(height: 12),
          if (grouped)
            _Bar(
              share: elapsed == 0 ? 0 : active / elapsed,
              color: StatColors.orange,
            )
          else if (days.length <= 7)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < days.length; i++)
                  _DayDot(day: days[i], order: i, labelled: true),
              ],
            )
          else
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                for (var i = 0; i < days.length; i++)
                  _DayDot(day: days[i], order: i, labelled: false),
              ],
            ),
        ],
      ),
    );
  }
}

/// A day of the active-days card: orange with a tick when studied, grey
/// when missed, an outline still ahead; today waits with an orange ring.
class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.day,
    required this.order,
    required this.labelled,
  });

  final StatisticsDay day;
  final int order;
  final bool labelled;

  @override
  Widget build(BuildContext context) {
    final active = !day.isFuture && day.studySeconds > 0;
    final waiting = day.isToday && !active;
    final size = labelled ? 17.0 : 10.0;
    final dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? StatColors.orange
            : day.isFuture || waiting
                ? Colors.transparent
                : StatColors.line,
        border: active || !(day.isFuture || waiting)
            ? null
            : Border.all(
                color: waiting
                    ? StatColors.orange.withAlpha(150)
                    : StatColors.line,
                width: 1.5,
              ),
      ),
      child: active && labelled
          ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
          : null,
    );
    // Each pops in a little after the one before, once.
    final popping = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: StatMotion.of(
        context,
        Duration(milliseconds: 380 + order * (labelled ? 70 : 18)),
      ),
      curve: Curves.easeOutBack,
      builder: (context, t, child) =>
          Transform.scale(scale: t.clamp(0.0, 1.2), child: child),
      child: dot,
    );
    if (!labelled) return popping;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        popping,
        const SizedBox(height: 4),
        ReText(
          StatsFormat.weekdayInitial(day.first),
          fontSize: 10,
          fontWeight: day.isToday ? 1000 : 700,
          color: day.isFuture ? StatColors.muted.withAlpha(140) : StatColors.ink,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _TestsRow extends StatelessWidget {
  const _TestsRow({required this.overview, required this.range});

  final StatisticsOverview overview;
  final StatisticsRange range;

  @override
  Widget build(BuildContext context) {
    final o = overview;
    final total = o.totalQuestions;
    return StatCard(
      padding: 14,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    CountUp(
                      value: total.toDouble(),
                      builder: (context, value) => ReText(
                        '${value.round()}',
                        fontSize: 17,
                        fontWeight: 1000,
                        color: _valueColor(total),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const ReText(
                      'تست زده‌شده',
                      fontSize: 13,
                      fontWeight: 800,
                      color: StatColors.ink,
                    ),
                  ],
                ),
                ReText(
                  total == 0
                      ? 'تستی ثبت نشده'
                      : o.elapsedDays > 1
                          ? 'میانگین ${(total / o.elapsedDays).round()} تست در روز'
                          : range.isCurrent
                              ? 'تا این لحظه'
                              : 'در این روز',
                  fontSize: 10.5,
                  fontWeight: 600,
                  color: StatColors.muted,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          ChangeChip.percent(o.questionsChange, fromNothing: total > 0),
          const SizedBox(width: 12),
          const TintIcon(IconsaxPlusBold.edit_2, StatColors.green, size: 38),
        ],
      ),
    );
  }
}

/// A thin bar that fills to [share] once.
class _Bar extends StatelessWidget {
  const _Bar({required this.share, required this.color});

  final double share;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: StatColors.surface,
        borderRadius: BorderRadius.circular(100),
      ),
      alignment: AlignmentDirectional.centerStart,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: share.clamp(0.0, 1.0)),
        duration: StatMotion.of(context, const Duration(milliseconds: 900)),
        curve: StatMotion.curve,
        builder: (context, value, _) => FractionallySizedBox(
          widthFactor: value,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
    );
  }
}

/// Stands in for a number there is none of yet.
class _Dash extends StatelessWidget {
  const _Dash();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const ReText(
          '0',
          fontSize: 22,
          fontWeight: 1000,
          color: Colors.transparent,
        ),
        Container(
          width: 18,
          height: 4,
          decoration: BoxDecoration(
            color: StatColors.muted.withAlpha(110),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ],
    );
  }
}
