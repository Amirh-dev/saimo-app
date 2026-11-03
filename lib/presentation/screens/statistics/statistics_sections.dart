import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:simo_learn/features/statistics/cubit/statistics_state.dart';
import 'package:simo_learn/features/statistics/statistics_overview.dart';
import 'package:simo_learn/presentation/screens/statistics/stat_bar_chart.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_format.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_widgets.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';

/// Labels under the bars: weekday and day for a week, every few days for a
/// month, the first day of each week for a longer range.
(String, String) _axisLabels(List<StatisticsDay> days, int index) {
  final day = days[index];
  if (days.length <= 7 && !day.isGroup) {
    return (StatsFormat.weekdayInitial(day.first), '${day.first.day}');
  }
  final every = (days.length / 7).ceil();
  if (index % every != 0) return ('', '');
  return (
    '${day.first.day}',
    index == 0 || days[index - every].first.month != day.first.month
        ? StatsFormat.month(day.first)
        : '',
  );
}

String _dayTitle(StatisticsDay day) => day.isGroup
    ? '${StatsFormat.dayMonth(day.first)} تا ${StatsFormat.dayMonth(day.last)}'
    : StatsFormat.fullDay(day.first);

/// Study time per day, against the range's daily average.
class StudyChartSection extends StatelessWidget {
  const StudyChartSection({
    super.key,
    required this.days,
    this.caption,
  });

  final List<StatisticsDay> days;

  /// Names the days' range when it is not the one picked: a single day is
  /// charted within its week.
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final elapsed = days.where((day) => !day.isFuture).toList();
    final total = elapsed.fold(0, (sum, day) => sum + day.studySeconds);
    final average = elapsed.isEmpty ? 0.0 : total / 60 / elapsed.length;
    // Under a minute it would read «۰:۰۰» and lie on the baseline.
    final showAverage = average >= 1 && elapsed.length > 1;
    final highest =
        days.fold(0.0, (most, day) => math.max(most, day.studySeconds / 60));
    final ticks = niceTicks(
      math.max(highest, average),
      const [
        15,
        30,
        60,
        120,
        180,
        240,
        360,
        480,
        600,
        900,
        1200,
        1800,
        2400,
        3600
      ],
    );
    final compact = days.length <= 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatSectionTitle(
          'نمودار میزان مطالعه',
          trailing: caption == null
              ? null
              : ReText(
                  caption!,
                  fontSize: 11,
                  fontWeight: 700,
                  color: StatColors.muted,
                ),
        ),
        const SizedBox(height: 12),
        StatCard(
          child: Column(
            children: [
              StatBarChart(
                maxValue: ticks.last,
                ticks: ticks,
                tickLabel: (minutes) => minutes == 0
                    ? '0'
                    : minutes < 60
                        ? '${minutes.round()}د'
                        : '${StatsFormat.decimal(minutes / 60)}س',
                reference: showAverage ? average : null,
                referenceLabel: showAverage
                    ? 'میانگین ${StatsFormat.clock((average * 60).round())}'
                    : null,
                bars: [
                  for (var i = 0; i < days.length; i++)
                    () {
                      final day = days[i];
                      final minutes = day.studySeconds / 60;
                      final (label, caption) = _axisLabels(days, i);
                      return ChartBar(
                        segments: [
                          BarSegment(
                            minutes,
                            !showAverage || minutes >= average
                                ? StatColors.study
                                : StatColors.studySoft,
                          ),
                        ],
                        label: label,
                        caption: caption,
                        valueLabel: compact && day.studySeconds >= 60
                            ? StatsFormat.clock(day.studySeconds)
                            : null,
                        isFuture: day.isFuture,
                        isToday: day.isToday,
                        isFocused: day.isFocused,
                        tooltipTitle: _dayTitle(day),
                        tooltipBody: day.studySeconds > 0
                            ? '${StatsFormat.duration(day.studySeconds)} ، '
                                '${day.completedTasks} تسک'
                            : 'مطالعه‌ای ثبت نشده',
                      );
                    }(),
                ],
              ),
              if (showAverage) ...[
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LegendDot(StatColors.study, 'بیشتر از میانگین'),
                    SizedBox(width: 18),
                    LegendDot(StatColors.studySoft, 'کمتر از میانگین'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Questions per day, the correct part green and the wrong part red.
class TestsChartSection extends StatelessWidget {
  const TestsChartSection({
    super.key,
    required this.days,
    this.showAccuracy = true,
    this.isCurrent = true,
  });

  final List<StatisticsDay> days;

  /// Whether the title names the days' overall accuracy.
  final bool showAccuracy;

  /// Whether the days are the running range, for the words when empty.
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final total = days.fold(0, (sum, day) => sum + day.totalQuestions);
    final correct = days.fold(0, (sum, day) => sum + day.correctAnswers);
    final highest =
        days.fold(0, (most, day) => math.max(most, day.totalQuestions));
    final ticks = niceTicks(
      highest.toDouble(),
      const [5, 10, 20, 25, 50, 100, 150, 200, 250, 500, 1000],
    );
    final compact = days.length <= 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatSectionTitle(
          'نمودار تعداد تست',
          trailing: showAccuracy && total > 0
              ? ReText(
                  'دقت ${(correct * 100 / total).round()}٪',
                  fontSize: 13,
                  fontWeight: 900,
                  color: StatColors.correct,
                )
              : null,
        ),
        const SizedBox(height: 12),
        StatCard(
          child: total == 0
              ? _NoTestsYet(isCurrent: isCurrent)
              : Column(
                  children: [
                    StatBarChart(
                      maxValue: ticks.last,
                      ticks: ticks,
                      tickLabel: (value) => '${value.round()}',
                      barWidth: 16,
                      bars: [
                        for (var i = 0; i < days.length; i++)
                          () {
                            final day = days[i];
                            final (label, caption) = _axisLabels(days, i);
                            return ChartBar(
                              segments: [
                                BarSegment(
                                  day.correctAnswers.toDouble(),
                                  StatColors.correct,
                                ),
                                BarSegment(
                                  day.wrongAnswers.toDouble(),
                                  StatColors.wrong,
                                ),
                              ],
                              label: label,
                              caption: caption,
                              valueLabel: compact && day.totalQuestions > 0
                                  ? '${day.totalQuestions}'
                                  : null,
                              isFuture: day.isFuture,
                              isToday: day.isToday,
                              isFocused: day.isFocused,
                              tooltipTitle: _dayTitle(day),
                              tooltipBody: day.totalQuestions > 0
                                  ? '${day.correctAnswers} صحیح ، '
                                      '${day.wrongAnswers} غلط ، دقت '
                                      '${(day.correctAnswers * 100 / day.totalQuestions).round()}٪'
                                  : 'تستی ثبت نشده',
                            );
                          }(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LegendDot(StatColors.correct, 'صحیح'),
                        SizedBox(width: 18),
                        LegendDot(StatColors.wrong, 'غلط'),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// Study time and test accuracy per subject, most studied first. A subject
/// with tags under it opens in place to show them, one at a time.
class SubjectsSection extends StatefulWidget {
  const SubjectsSection({super.key, required this.subjects, this.loadParts});

  final List<SubjectStatistics> subjects;

  /// The tags under a subject; without it no subject opens.
  final Future<List<SubjectStatistics>> Function(SubjectStatistics subject)?
      loadParts;

  @override
  State<SubjectsSection> createState() => _SubjectsSectionState();
}

class _SubjectsSectionState extends State<SubjectsSection> {
  static const _shown = 5;
  bool _expanded = false;
  bool _showHelp = false;
  String? _open;

  bool _opens(SubjectStatistics subject) =>
      widget.loadParts != null && subject.hasChildren && subject.tagID != null;

  @override
  Widget build(BuildContext context) {
    final subjects = widget.subjects;
    final visible = _expanded ? subjects : subjects.take(_shown).toList();
    final most = subjects.fold(0, (most, s) => math.max(most, s.studySeconds));
    final insight = SubjectStatistics.insight(subjects);
    // Rows keep one column of names even when only some can open.
    final anyOpens = subjects.any(_opens);
    final motion = StatMotion.of(context, const Duration(milliseconds: 280));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatSectionTitle(
          'به تفکیک درس',
          help: _HelpButton(
            open: _showHelp,
            onTap: () => setState(() => _showHelp = !_showHelp),
          ),
          trailing: const ReText(
            'زمان ، دقت تست',
            fontSize: 11,
            fontWeight: 700,
            color: StatColors.muted,
          ),
        ),
        AnimatedSize(
          duration: motion,
          curve: StatMotion.curve,
          alignment: Alignment.topCenter,
          child: _showHelp
              ? const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: _SubjectsHelp(),
                )
              : const SizedBox(width: double.infinity),
        ),
        const SizedBox(height: 12),
        StatCard(
          child: AnimatedSize(
            duration: motion,
            curve: StatMotion.curve,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < visible.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _subject(visible[i], i, most, anyOpens),
                ],
                if (subjects.length > _shown) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: _TextButton(
                      label: _expanded
                          ? 'نمایش کمتر'
                          : 'نمایش همه (${subjects.length} درس)',
                      icon: _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      onTap: () => setState(() => _expanded = !_expanded),
                    ),
                  ),
                ],
                if (insight != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: StatColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const TintIcon(
                          IconsaxPlusBold.lamp_on,
                          StatColors.yellow,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ReText(
                            insight,
                            fontSize: 11.5,
                            fontWeight: 700,
                            color: StatColors.ink,
                            maxLines: 3,
                            lineHeight: 1.6,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _subject(
    SubjectStatistics subject,
    int order,
    int most,
    bool anyOpens,
  ) {
    final opens = _opens(subject);
    final isOpen = opens && _open == subject.tagID;
    final row = _SubjectRow(
      subject: subject,
      share: most == 0 ? 0 : subject.studySeconds / most,
      order: order,
      chevron: !anyOpens
          ? null
          : opens
              ? (isOpen ? _Chevron.up : _Chevron.down)
              : _Chevron.none,
    );
    if (!opens) return row;

    // The open surface spreads past the rows, so they stay in line.
    return AnimatedContainer(
      duration: StatMotion.of(context, StatMotion.quick),
      curve: StatMotion.curve,
      padding: EdgeInsets.symmetric(vertical: isOpen ? 10 : 0),
      decoration: BoxDecoration(
        color: isOpen ? StatColors.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (isOpen)
            const BoxShadow(color: StatColors.surface, spreadRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            key: ValueKey('subject-${subject.tagID}'),
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _open = isOpen ? null : subject.tagID),
            child: row,
          ),
          if (isOpen)
            _SubjectParts(
              parent: subject,
              parts: widget.loadParts!(subject),
              onRetry: () => setState(() {}),
            ),
        ],
      ),
    );
  }
}

/// The small «؟» beside the title.
class _HelpButton extends StatelessWidget {
  const _HelpButton({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'این آمار چطور حساب می‌شود؟',
      child: GestureDetector(
        key: const ValueKey('subjects-help'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AnimatedContainer(
            duration: StatMotion.of(context, StatMotion.quick),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: open ? StatColors.ink : StatColors.line,
            ),
            alignment: Alignment.center,
            child: ReText(
              '؟',
              fontSize: 12,
              fontWeight: 900,
              color: open ? Colors.white : StatColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class _SubjectsHelp extends StatelessWidget {
  const _SubjectsHelp();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('subjects-help-text'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(IconsaxPlusLinear.info_circle,
              size: 18, color: StatColors.muted),
          SizedBox(width: 8),
          Expanded(
            child: ReText(
              'این آمار بر اساس تگ‌هایی است که روی تسک‌هایتان می‌زنید. '
              'با لمس هر درس، زمان و دقت زیرمجموعه‌هایش را می‌بینید؛ '
              '«عمومی» تسک‌هایی است که فقط تگ خود درس را دارند و '
              'تسک‌های بدون تگ در «متفرقه» می‌آیند.',
              fontSize: 11.5,
              fontWeight: 600,
              color: StatColors.ink,
              maxLines: 6,
              lineHeight: 1.7,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// The tags under an opened subject, each bar a share of the subject's time.
class _SubjectParts extends StatelessWidget {
  const _SubjectParts({
    required this.parent,
    required this.parts,
    required this.onRetry,
  });

  final SubjectStatistics parent;
  final Future<List<SubjectStatistics>> parts;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SubjectStatistics>>(
      future: parts,
      builder: (context, snapshot) {
        final Widget child;
        if (snapshot.hasError) {
          child = Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: _TextButton(
                label: 'دریافت نشد؛ دوباره تلاش کنید',
                icon: Icons.refresh_rounded,
                onTap: onRetry,
              ),
            ),
          );
        } else if (!snapshot.hasData) {
          child = const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: StatColors.muted,
                ),
              ),
            ),
          );
        } else if (snapshot.data!.isEmpty) {
          child = const Padding(
            padding: EdgeInsets.only(top: 10),
            child: ReText(
              'در این بازه زیرمجموعه‌ای از این درس ثبت نشده.',
              fontSize: 11.5,
              fontWeight: 600,
              color: StatColors.muted,
              textAlign: TextAlign.right,
            ),
          );
        } else {
          final parts = snapshot.data!;
          final total = parent.studySeconds;
          child = Container(
            margin: const EdgeInsetsDirectional.only(start: 7, top: 2),
            padding: const EdgeInsetsDirectional.only(start: 10),
            decoration: const BoxDecoration(
              border: BorderDirectional(
                start: BorderSide(color: StatColors.line, width: 2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < parts.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _SubjectRow(
                      key: ValueKey('subject-part-${parts[i].name}'),
                      subject: parts[i],
                      share: total == 0 ? 0 : parts[i].studySeconds / total,
                      order: i,
                      compact: true,
                    ),
                  ),
              ],
            ),
          );
        }
        return AnimatedSwitcher(
          duration: StatMotion.of(context, StatMotion.quick),
          child: KeyedSubtree(
            key: ValueKey(snapshot.connectionState),
            child: child,
          ),
        );
      },
    );
  }
}

enum _Chevron { none, down, up }

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({
    super.key,
    required this.subject,
    required this.share,
    required this.order,
    this.chevron,
    this.compact = false,
  });

  final SubjectStatistics subject;
  final double share;
  final int order;

  /// Null when no row in the list opens, so no space is kept for it.
  final _Chevron? chevron;

  /// A tag under an opened subject: smaller, with a lighter bar.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accuracy = subject.accuracy;
    final muted = subject.isMiscellaneous || subject.isGeneral;
    final figures = [
      Expanded(
        child: Container(
          height: compact ? 6 : 8,
          decoration: BoxDecoration(
            color: compact ? Colors.white : StatColors.surface,
            borderRadius: BorderRadius.circular(100),
          ),
          alignment: AlignmentDirectional.centerStart,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: share.clamp(0.0, 1.0)),
            // Each row a little after the one above.
            duration: StatMotion.of(
              context,
              Duration(milliseconds: (compact ? 450 : 650) + order * 90),
            ),
            curve: StatMotion.curve,
            builder: (context, value, _) => FractionallySizedBox(
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  color: compact ? StatColors.studySoft : StatColors.study,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      SizedBox(
        width: 36,
        child: ReText(
          StatsFormat.clock(subject.studySeconds),
          fontSize: compact ? 11 : 12,
          fontWeight: compact ? 800 : 900,
          color: StatColors.ink,
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(width: 4),
      SizedBox(
        width: 38,
        child: ReText(
          accuracy == null ? '-' : '${accuracy.round()}٪',
          fontSize: compact ? 11 : 12,
          fontWeight: 800,
          color: accuracy != null && accuracy < 60
              ? AppColors.errorColor
              : StatColors.muted,
          textAlign: TextAlign.left,
        ),
      ),
    ];

    // Tag names run long («ریاضیات گسسته دوازدهم»), so a tag's name gets a
    // line of its own above its figures instead of a narrow column.
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReText(
            subject.name,
            fontSize: 11.5,
            fontWeight: 700,
            color: muted ? StatColors.muted : StatColors.ink,
            textAlign: TextAlign.right,
            maxLines: 2,
            lineHeight: 1.6,
          ),
          const SizedBox(height: 4),
          Row(children: figures),
        ],
      );
    }

    return Row(
      children: [
        if (chevron != null) ...[
          SizedBox(
            width: 16,
            child: chevron == _Chevron.none
                ? null
                : AnimatedRotation(
                    turns: chevron == _Chevron.up ? 0.5 : 0,
                    duration: StatMotion.of(context, StatMotion.quick),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: StatColors.muted,
                    ),
                  ),
          ),
          const SizedBox(width: 2),
        ],
        SizedBox(
          width: 64,
          child: ReText(
            subject.name,
            fontSize: 12.5,
            fontWeight: 800,
            color: muted ? StatColors.muted : StatColors.ink,
            textAlign: TextAlign.right,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        ...figures,
      ],
    );
  }
}

class _TextButton extends StatelessWidget {
  const _TextButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReText(label, fontSize: 12, fontWeight: 800, color: StatColors.ink),
            const SizedBox(width: 2),
            Icon(icon, size: 18, color: StatColors.ink),
          ],
        ),
      ),
    );
  }
}

/// No tests yet: a faint picture of the chart to come, rising once, with
/// what to do to fill it.
class _NoTestsYet extends StatelessWidget {
  const _NoTestsYet({required this.isCurrent});

  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return GhostChartEmpty(
      color: StatColors.green,
      icon: IconsaxPlusBold.edit_2,
      title: isCurrent ? 'هنوز تستی ثبت نکرده‌ای' : 'در این بازه تستی ثبت نشده',
      body: isCurrent
          ? 'بعد از هر تسک، تعداد تست‌ها و جواب‌های درستت را در گزارشش بنویس تا نمودارت اینجا ساخته شود.'
          : 'تست‌هایی که در گزارش تسک‌ها ثبت کنی، اینجا نمودار می‌شوند.',
    );
  }
}

/// Shown instead of the study card when nothing happened in the range.
class EmptyStatsCard extends StatelessWidget {
  const EmptyStatsCard({
    super.key,
    required this.range,
    required this.onStart,
    required this.onCurrent,
  });

  final StatisticsRange range;
  final VoidCallback onStart;
  final VoidCallback onCurrent;

  @override
  Widget build(BuildContext context) {
    final current = range.isCurrent;
    return StatCard(
      padding: 22,
      child: Column(
        children: [
          const _Breathing(
            child:
                TintIcon(IconsaxPlusBold.chart_2, StatColors.study, size: 64),
          ),
          const SizedBox(height: 14),
          ReText(
            current
                ? 'هنوز آماری برای ${StatsFormat.rangeName(range)} نداری'
                : 'در این بازه فعالیتی ثبت نشده',
            fontSize: 15,
            fontWeight: 900,
            color: StatColors.ink,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: 6),
          ReText(
            current
                ? 'تسک‌هایت را با تایمر انجام بده تا زمان مطالعه، تست‌ها و پیشرفتت اینجا ساخته شود.'
                : 'بازه‌ی دیگری را ببین یا به بازه‌ی جاری برگرد.',
            fontSize: 12.5,
            fontWeight: 600,
            color: StatColors.muted,
            maxLines: 3,
            lineHeight: 1.7,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: current ? onStart : onCurrent,
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: current ? AppColors.primary : StatColors.surface,
                borderRadius: BorderRadius.circular(100),
              ),
              child: ReText(
                current ? 'رفتن به برنامه' : StatsFormat.backToCurrent(range),
                fontSize: 14,
                fontWeight: 800,
                color: current ? AppColors.white : StatColors.ink,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A slow, small swell, so an empty state does not feel frozen.
class _Breathing extends StatefulWidget {
  const _Breathing({required this.child});

  final Widget child;

  @override
  State<_Breathing> createState() => _BreathingState();
}

class _BreathingState extends State<_Breathing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.06).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: widget.child,
    );
  }
}

class StatisticsErrorView extends StatelessWidget {
  const StatisticsErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          const TintIcon(
            Icons.cloud_off_rounded,
            AppColors.errorColor,
            size: 64,
          ),
          const SizedBox(height: 14),
          ReText(
            message,
            fontSize: 13,
            fontWeight: 700,
            color: StatColors.ink,
            textAlign: TextAlign.center,
            maxLines: 3,
            lineHeight: 1.7,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: StatColors.line),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(IconsaxPlusLinear.refresh,
                      size: 16, color: StatColors.ink),
                  SizedBox(width: 6),
                  ReText(
                    'تلاش دوباره',
                    fontSize: 12.5,
                    fontWeight: 800,
                    color: StatColors.ink,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The screen's shape while its first numbers load.
class StatisticsSkeleton extends StatelessWidget {
  const StatisticsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget kpi() => const StatCard(
          padding: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Bone(width: 36, height: 36, radius: 18),
              SizedBox(height: 14),
              Bone(width: 56, height: 22),
              SizedBox(height: 8),
              Bone(width: 84, height: 12),
            ],
          ),
        );
    const heights = [0.45, 0.7, 0.3, 0.85, 0.15, 0.55, 0.4];
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StatCard(
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
                          Bone(width: 140, height: 14),
                          SizedBox(height: 14),
                          Bone(width: 170, height: 36),
                          SizedBox(height: 12),
                          Bone(width: 120, height: 20, radius: 100),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    Bone(width: 104, height: 104, radius: 52),
                  ],
                ),
                SizedBox(height: 16),
                Bone(height: 34, radius: 14),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: kpi()),
            const SizedBox(width: 12),
            Expanded(child: kpi()),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: kpi()),
            const SizedBox(width: 12),
            Expanded(child: kpi()),
          ]),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Bone(width: 150, height: 18),
            ),
          ),
          const SizedBox(height: 12),
          StatCard(
            child: SizedBox(
              height: 170,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final h in heights)
                    Expanded(
                      child: Center(
                        child: Bone(width: 14, height: 140 * h, radius: 7),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
