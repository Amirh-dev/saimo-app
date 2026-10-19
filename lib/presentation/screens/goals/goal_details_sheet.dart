import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/goals/cubit/goals_cubit.dart';
import 'package:simo_learn/features/goals/cubit/goals_state.dart';
import 'package:simo_learn/features/goals/goal_timing.dart';
import 'package:simo_learn/features/goals/goals_repository.dart';
import 'package:simo_learn/features/statistics/statistics_repository.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';
import 'package:simo_learn/presentation/screens/goals/goal_form_sheet.dart';
import 'package:simo_learn/presentation/screens/goals/goal_widgets.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_widgets.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/jalali_text.dart';

/// What the user asked for from a goal's sheet; the tab carries it out.
enum GoalAction { complete, reopen, edit, delete }

Future<GoalAction?> showGoalDetails(BuildContext context, Goal goal) {
  return showReModalBottomSheet<GoalAction>(
    context: context,
    builder: (_) => GoalDetailsSheet(goalId: goal.id),
  );
}

class GoalDetailsSheet extends StatefulWidget {
  const GoalDetailsSheet({super.key, required this.goalId});

  final String goalId;

  @override
  State<GoalDetailsSheet> createState() => _GoalDetailsSheetState();
}

class _GoalDetailsSheetState extends State<GoalDetailsSheet> {
  /// Study time and finished tasks since the goal was set; null while they
  /// load, and the box hides if they cannot.
  (int, int)? _effort;
  bool _effortFailed = false;

  @override
  void initState() {
    super.initState();
    _loadEffort();
  }

  Future<void> _loadEffort() async {
    final goal = _goal(context.read<GoalsCubit>().state);
    final StatisticsRepository repository;
    try {
      repository = StatisticsRepository(context.read<GraphQLRepository>());
    } catch (_) {
      setState(() => _effortFailed = true);
      return;
    }
    if (goal == null) return;
    final timing = GoalTiming.of(goal);
    final last = goal.status == GGoalStatus.COMPLETED
        ? goalDateOf(goal.updatedAt.value) ?? timing.today
        : timing.today;
    DateTime midnight(int julianDay) {
      final g = Jalali.fromJulianDayNumber(julianDay).toGregorian();
      return DateTime(g.year, g.month, g.day);
    }

    // From the day it was set through today, or the day it was reached.
    final first = timing.created.julianDayNumber;
    final start = midnight(first);
    final end = midnight(math.max(last.julianDayNumber, first) + 1);
    try {
      final dashboard = await repository.fetchDashboard(
        start: start,
        end: end,
        previousStart: start.subtract(const Duration(days: 1)),
        previousEnd: start,
      );
      if (!mounted) return;
      setState(() => _effort = (
            dashboard.comparison.current.studySeconds,
            dashboard.dailyBuckets
                .fold<int>(0, (sum, day) => sum + day.completedTasks),
          ));
    } catch (_) {
      if (mounted) setState(() => _effortFailed = true);
    }
  }

  Goal? _goal(GoalsState state) {
    for (final goal in state.goals) {
      if (goal.id == widget.goalId) return goal;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoalsCubit, GoalsState>(
      builder: (context, state) {
        final goal = _goal(state);
        if (goal == null) return const SizedBox.shrink();
        final timing = GoalTiming.of(goal);
        final reached = goal.status == GGoalStatus.COMPLETED;
        final pinned = state.pinnedId == goal.id;
        final target = timing.target;
        final note = goal.note?.trim() ?? '';

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SheetHandle(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (pinned || reached) ...[
                                _Tag(
                                  icon: reached
                                      ? Icons.emoji_events_rounded
                                      : Icons.push_pin_rounded,
                                  text: reached ? 'محقق شد' : 'هدف اصلی',
                                  color: reached
                                      ? GoalColors.reached
                                      : GoalColors.ink,
                                ),
                                const SizedBox(height: 8),
                              ],
                              ReText(
                                goal.title,
                                fontSize: 18,
                                fontWeight: 1000,
                                color: GoalColors.ink,
                                maxLines: 3,
                                lineHeight: 1.5,
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(height: 2),
                              ReText(
                                target == null
                                    ? 'بدون موعد'
                                    : 'موعد: ${JalaliText.fullDate(target)}',
                                fontSize: 12,
                                fontWeight: 700,
                                color: GoalColors.muted,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        const CloseCircle(),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Center(child: _CountdownRing(timing: timing, reached: reached)),
                    if (target != null && !reached) ...[
                      const SizedBox(height: 10),
                      ReText(
                        '${timing.daysSinceCreated} روز گذشته ، '
                        '${(timing.elapsed * 100).round()}٪ از زمان',
                        fontSize: 11.5,
                        fontWeight: 700,
                        color: GoalColors.muted,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: GoalColors.surface,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ReText(
                          note,
                          fontSize: 12.5,
                          fontWeight: 600,
                          color: GoalColors.ink,
                          maxLines: 6,
                          lineHeight: 1.8,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                    if (!_effortFailed) ...[
                      const SizedBox(height: 12),
                      _EffortBox(effort: _effort, reached: reached),
                    ],
                    const SizedBox(height: 22),
                    if (reached)
                      _WideButton(
                        text: 'برگرداندن به اهداف فعال',
                        icon: Icons.replay_rounded,
                        onTap: state.isMutating
                            ? null
                            : () => Navigator.of(context)
                                .pop(GoalAction.reopen),
                      )
                    else
                      _WideButton(
                        text: 'به این هدف رسیدم',
                        icon: Icons.check_rounded,
                        primary: true,
                        onTap: state.isMutating
                            ? null
                            : () => Navigator.of(context)
                                .pop(GoalAction.complete),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _WideButton(
                            text: 'ویرایش',
                            icon: IconsaxPlusLinear.edit_2,
                            onTap: () =>
                                Navigator.of(context).pop(GoalAction.edit),
                          ),
                        ),
                        if (!reached) ...[
                          const SizedBox(width: 10),
                          _RoundButton(
                            icon: Icons.push_pin_rounded,
                            filled: pinned,
                            label: pinned
                                ? 'برداشتن از هدف اصلی'
                                : 'هدف اصلی شود',
                            onTap: () => context
                                .read<GoalsCubit>()
                                .setPinned(pinned ? null : goal.id),
                          ),
                        ],
                        const SizedBox(width: 10),
                        _RoundButton(
                          icon: IconsaxPlusLinear.trash,
                          label: 'حذف هدف',
                          onTap: () =>
                              Navigator.of(context).pop(GoalAction.delete),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CountdownRing extends StatelessWidget {
  const _CountdownRing({required this.timing, required this.reached});

  final GoalTiming timing;
  final bool reached;

  @override
  Widget build(BuildContext context) {
    final days = timing.daysLeft;
    final color = reached
        ? GoalColors.reached
        : timing.isOverdue
            ? GoalColors.overdue
            : GoalColors.ink;
    final Widget center;
    if (reached) {
      center = const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 44, color: GoalColors.reached),
          ReText('محقق شد',
              fontSize: 12,
              fontWeight: 800,
              color: GoalColors.reached,
              textAlign: TextAlign.center),
        ],
      );
    } else if (days == null) {
      center = const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.all_inclusive_rounded, size: 36, color: GoalColors.muted),
          ReText('بدون موعد',
              fontSize: 12,
              fontWeight: 700,
              color: GoalColors.muted,
              textAlign: TextAlign.center),
        ],
      );
    } else if (days == 0) {
      center = const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReText('امروز',
              fontSize: 30,
              fontWeight: 1000,
              color: GoalColors.accent,
              textAlign: TextAlign.center),
          ReText('موعد است',
              fontSize: 12,
              fontWeight: 700,
              color: GoalColors.muted,
              textAlign: TextAlign.center),
        ],
      );
    } else {
      center = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CountUp(
            value: days.abs().toDouble(),
            builder: (context, value) => ReText(
              '${value.round()}',
              fontSize: 40,
              fontWeight: 1000,
              color: days < 0 ? GoalColors.overdue : GoalColors.ink,
              textAlign: TextAlign.center,
              lineHeight: 1.15,
            ),
          ),
          ReText(days < 0 ? 'روز گذشته' : 'روز مانده',
              fontSize: 12,
              fontWeight: 700,
              color: GoalColors.muted,
              textAlign: TextAlign.center),
        ],
      );
    }
    final share = reached ? 1.0 : timing.elapsed;
    return SizedBox(
      width: 150,
      height: 150,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: share),
        duration: StatMotion.of(context, const Duration(milliseconds: 1000)),
        curve: StatMotion.curve,
        builder: (context, value, child) => CustomPaint(
          painter: _RingPainter(value, color),
          child: child,
        ),
        child: Center(child: center),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.share, this.color);

  final double share;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke,
        size.height - stroke);
    Paint arc(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, arc(GoalColors.surface));
    if (share > 0) {
      canvas.drawArc(
          rect, -math.pi / 2, math.pi * 2 * share, false, arc(color));
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.share != share || oldDelegate.color != color;
}

/// «از وقتی این هدف را گذاشتی»: study time and finished tasks since then.
class _EffortBox extends StatelessWidget {
  const _EffortBox({required this.effort, required this.reached});

  final (int, int)? effort;
  final bool reached;

  @override
  Widget build(BuildContext context) {
    final effort = this.effort;
    Widget item(IconData icon, Color color, Widget value, String label) =>
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TintIcon(icon, color, size: 32),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  value,
                  ReText(label,
                      fontSize: 10.5,
                      fontWeight: 700,
                      color: GoalColors.muted),
                ],
              ),
            ],
          ),
        );
    Widget number(int value) => CountUp(
          value: value.toDouble(),
          builder: (context, v) => ReText('${v.round()}',
              fontSize: 17, fontWeight: 1000, color: GoalColors.ink),
        );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GoalColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReText(
            reached ? 'تا رسیدن به این هدف' : 'از وقتی این هدف را گذاشتی',
            fontSize: 12,
            fontWeight: 700,
            color: GoalColors.muted,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 10),
          if (effort == null)
            const Shimmer(
              child: Row(
                children: [
                  Expanded(child: Center(child: Bone(width: 110, height: 32))),
                  Expanded(child: Center(child: Bone(width: 110, height: 32))),
                ],
              ),
            )
          else
            Row(
              children: [
                item(IconsaxPlusBold.clock, AppColors.secondary,
                    number(effort.$1 ~/ 3600), 'ساعت مطالعه'),
                Container(width: 1, height: 34, color: GoalColors.line),
                item(IconsaxPlusBold.tick_circle, GoalColors.reached,
                    number(effort.$2), 'تسک انجام‌شده'),
              ],
            ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: GoalColors.surface,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          ReText(text, fontSize: 11, fontWeight: 800, color: color),
        ],
      ),
    );
  }
}

class _WideButton extends StatelessWidget {
  const _WideButton({
    required this.text,
    required this.icon,
    required this.onTap,
    this.primary = false,
  });

  final String text;
  final IconData icon;
  final VoidCallback? onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final color = primary ? Colors.white : GoalColors.ink;
    return Pressable(
      onTap: onTap,
      child: Container(
        height: primary ? 52 : 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primary ? GoalColors.accent : AppColors.white,
          borderRadius: BorderRadius.circular(100),
          border:
              primary ? null : Border.all(color: GoalColors.line, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: primary ? 20 : 17, color: color),
            const SizedBox(width: 6),
            ReText(text,
                fontSize: primary ? 14.5 : 13.5,
                fontWeight: 800,
                color: color),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: StatMotion.of(context, const Duration(milliseconds: 200)),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? GoalColors.ink : AppColors.white,
            border: filled
                ? null
                : Border.all(color: GoalColors.line, width: 1.5),
          ),
          child: Icon(icon,
              size: 19, color: filled ? Colors.white : GoalColors.ink),
        ),
      ),
    );
  }
}

/// Asks before a goal is deleted for good.
Future<bool> confirmGoalDelete(BuildContext context, Goal goal) async {
  final result = await showReModalBottomSheet<bool>(
    context: context,
    builder: (sheetContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TintIcon(IconsaxPlusBold.trash, GoalColors.overdue,
                  size: 52),
              const SizedBox(height: 12),
              ReText(
                'هدف «${goal.title}» حذف شود؟',
                fontSize: 16,
                fontWeight: 900,
                color: GoalColors.ink,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              const SizedBox(height: 6),
              const ReText(
                'این هدف برای همیشه پاک می‌شود.',
                fontSize: 12.5,
                fontWeight: 600,
                color: GoalColors.muted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Pressable(
                      onTap: () => Navigator.of(sheetContext).pop(false),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: GoalColors.line, width: 1.5),
                        ),
                        child: const ReText('لغو',
                            fontSize: 13.5,
                            fontWeight: 800,
                            color: GoalColors.ink),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Pressable(
                      onTap: () => Navigator.of(sheetContext).pop(true),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: GoalColors.overdue,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const ReText('حذف',
                            fontSize: 13.5,
                            fontWeight: 800,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return result ?? false;
}
