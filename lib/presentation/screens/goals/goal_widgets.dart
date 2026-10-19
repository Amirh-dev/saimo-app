import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:simo_learn/features/goals/goal_timing.dart';
import 'package:simo_learn/features/goals/goals_repository.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/jalali_text.dart';

/// The goals tab's colors: neutral, with orange only for the main action
/// and a deadline drawing near, red only for one that has passed.
class GoalColors {
  const GoalColors._();

  static const ink = AppColors.black1;
  static const muted = AppColors.gray;
  static const line = AppColors.gray2;
  static const surface = AppColors.gray1;
  static const accent = AppColors.primary;
  static const overdue = AppColors.errorColor;
  static const reached = AppColors.done;
}

/// Sinks a little while pressed, with a light tick, and springs back.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool down) {
    if (widget.onTap == null || _down == down) return;
    setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _down ? 0.96 : 1,
        duration: StatMotion.of(context, const Duration(milliseconds: 120)),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Fades a row in and lifts it a little the first time it is built.
class EnterOnce extends StatelessWidget {
  const EnterOnce({super.key, required this.order, required this.child});

  final int order;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: StatMotion.of(
        context,
        Duration(milliseconds: 380 + order * 70),
      ),
      curve: StatMotion.curve,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 10 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}

/// A thin bar that fills to [share] once.
class GoalBar extends StatelessWidget {
  const GoalBar({super.key, required this.share, this.color = GoalColors.ink});

  final double share;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      decoration: BoxDecoration(
        color: GoalColors.line,
        borderRadius: BorderRadius.circular(100),
      ),
      alignment: AlignmentDirectional.centerStart,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: share.clamp(0.0, 1.0)),
        duration: StatMotion.of(context, const Duration(milliseconds: 1000)),
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

/// The orange «+ هدف جدید» pill: the tab's main action.
class AddGoalButton extends StatelessWidget {
  const AddGoalButton({super.key, required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: GoalColors.accent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 17, color: Colors.white),
            SizedBox(width: 3),
            ReText('هدف جدید',
                fontSize: 12.5, fontWeight: 800, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

/// «● نزدیک موعد»: the only color a goal a week away gets.
class SoonMark extends StatelessWidget {
  const SoonMark({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 7, color: GoalColors.accent),
        SizedBox(width: 4),
        ReText('نزدیک موعد',
            fontSize: 11, fontWeight: 800, color: GoalColors.accent),
      ],
    );
  }
}

/// The deadline in words, for a row: «پنج‌شنبه ۶ آبان», or how long ago
/// it passed.
String goalDeadlineText(GoalTiming timing) {
  final target = timing.target;
  final days = timing.daysLeft;
  if (target == null || days == null) return 'بدون موعد';
  if (days == 0) return 'موعدش امروز است';
  if (days == -1) return 'موعدش دیروز بود';
  if (days < 0) return 'موعدش ${-days} روز پیش بود';
  return target.year == timing.today.year
      ? JalaliText.fullDay(target)
      : JalaliText.fullDate(target);
}

/// The main goal, set large: its days left, and how much of its time has
/// passed.
class GoalsHero extends StatelessWidget {
  const GoalsHero({
    super.key,
    required this.goal,
    required this.pinned,
    required this.onTap,
  });

  final Goal goal;
  final bool pinned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final timing = GoalTiming.of(goal);
    final target = timing.target;
    final since = timing.daysSinceCreated;
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _HeroTag(pinned: pinned),
                const Spacer(),
                if (target != null)
                  ReText(JalaliText.fullDate(target),
                      fontSize: 11.5,
                      fontWeight: 700,
                      color: GoalColors.muted),
              ],
            ),
            const SizedBox(height: 8),
            ReText(
              goal.title,
              fontSize: 17,
              fontWeight: 1000,
              color: GoalColors.ink,
              maxLines: 2,
              lineHeight: 1.5,
              textAlign: TextAlign.right,
            ),
            _HeroCount(timing: timing),
            if (target != null) ...[
              GoalBar(share: timing.elapsed),
              const SizedBox(height: 7),
              Row(
                children: [
                  ReText('${(timing.elapsed * 100).round()}٪ از زمان گذشته',
                      fontSize: 11, fontWeight: 700, color: GoalColors.muted),
                  const Spacer(),
                  ReText(
                      since == 0 ? 'امروز شروع شد' : '$since روز پیش شروع شد',
                      fontSize: 11,
                      fontWeight: 700,
                      color: GoalColors.muted),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.pinned});

  final bool pinned;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            pinned ? Icons.push_pin_rounded : IconsaxPlusBold.flag,
            size: 12,
            color: GoalColors.ink,
          ),
          const SizedBox(width: 4),
          ReText(pinned ? 'هدف اصلی' : 'نزدیک‌ترین هدف',
              fontSize: 11, fontWeight: 800, color: GoalColors.ink),
        ],
      ),
    );
  }
}

class _HeroCount extends StatelessWidget {
  const _HeroCount({required this.timing});

  final GoalTiming timing;

  @override
  Widget build(BuildContext context) {
    final days = timing.daysLeft;
    Widget unit(String text) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ReText(text,
              fontSize: 16, fontWeight: 800, color: GoalColors.muted),
        );
    if (days == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: ReText('بدون موعد',
            fontSize: 28, fontWeight: 1000, color: GoalColors.muted),
      );
    }
    if (days == 0) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          const ReText('امروز',
              fontSize: 56,
              fontWeight: 1000,
              color: GoalColors.accent,
              lineHeight: 1.4),
          unit('موعد است'),
        ],
      );
    }
    final overdue = days < 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        CountUp(
          value: days.abs().toDouble(),
          builder: (context, value) => ReText(
            '${value.round()}',
            fontSize: 84,
            fontWeight: 1000,
            color: overdue ? GoalColors.overdue : GoalColors.ink,
            lineHeight: 1.15,
          ),
        ),
        unit(overdue ? 'روز گذشته' : 'روز مانده'),
      ],
    );
  }
}

/// The running goals other than the main one, by deadline, in one card.
class GoalsListCard extends StatelessWidget {
  const GoalsListCard({
    super.key,
    required this.goals,
    required this.busy,
    required this.onOpen,
    required this.onComplete,
    required this.onExtend,
  });

  final List<Goal> goals;
  final bool busy;
  final ValueChanged<Goal> onOpen;
  final ValueChanged<Goal> onComplete;
  final ValueChanged<Goal> onExtend;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: StatMotion.of(context, const Duration(milliseconds: 280)),
      curve: StatMotion.curve,
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          children: [
            for (var i = 0; i < goals.length; i++)
              EnterOnce(
                key: ValueKey(goals[i].id),
                order: i,
                child: _GoalRow(
                  goal: goals[i],
                  last: i == goals.length - 1,
                  busy: busy,
                  onOpen: () => onOpen(goals[i]),
                  onComplete: () => onComplete(goals[i]),
                  onExtend: () => onExtend(goals[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.goal,
    required this.last,
    required this.busy,
    required this.onOpen,
    required this.onComplete,
    required this.onExtend,
  });

  final Goal goal;
  final bool last;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onComplete;
  final VoidCallback onExtend;

  @override
  Widget build(BuildContext context) {
    final timing = GoalTiming.of(goal);
    final days = timing.daysLeft;
    final Widget trailing;
    if (days == null) {
      trailing = const Icon(Icons.all_inclusive_rounded,
          size: 22, color: GoalColors.muted);
    } else if (days < 0) {
      trailing = const Icon(Icons.error_outline_rounded,
          size: 28, color: GoalColors.overdue);
    } else if (days == 0) {
      trailing = const ReText('امروز',
          fontSize: 19, fontWeight: 1000, color: GoalColors.accent);
    } else {
      trailing = Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          ReText('$days',
              fontSize: 30, fontWeight: 1000, color: GoalColors.ink),
          const SizedBox(width: 3),
          const ReText('روز',
              fontSize: 11, fontWeight: 700, color: GoalColors.muted),
        ],
      );
    }

    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReText(
                        goal.title,
                        fontSize: 14,
                        fontWeight: 900,
                        color: GoalColors.ink,
                        maxLines: 1,
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Flexible(
                            child: ReText(
                              goalDeadlineText(timing),
                              fontSize: 11,
                              fontWeight: 600,
                              color: timing.isOverdue
                                  ? GoalColors.overdue
                                  : GoalColors.muted,
                              maxLines: 1,
                            ),
                          ),
                          if (timing.isSoon) ...[
                            const SizedBox(width: 8),
                            const SoonMark(),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                trailing,
              ],
            ),
          ),
        ),
        if (timing.isOverdue)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClosurePrompt(
              busy: busy,
              onComplete: onComplete,
              onExtend: onExtend,
            ),
          ),
        if (!last) Container(height: 1, color: GoalColors.line),
      ],
    );
  }
}

/// «به این هدف رسیدی؟» once a deadline has passed: reached, or more time.
class ClosurePrompt extends StatelessWidget {
  const ClosurePrompt({
    super.key,
    required this.busy,
    required this.onComplete,
    required this.onExtend,
  });

  final bool busy;
  final VoidCallback onComplete;
  final VoidCallback onExtend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: GoalColors.surface,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          const Expanded(
            child: ReText('به این هدف رسیدی؟',
                fontSize: 12,
                fontWeight: 800,
                color: GoalColors.ink,
                textAlign: TextAlign.right),
          ),
          Pressable(
            onTap: busy ? null : onComplete,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: GoalColors.ink,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_rounded, size: 14, color: Colors.white),
                  SizedBox(width: 3),
                  ReText('رسیدم',
                      fontSize: 11.5, fontWeight: 800, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Pressable(
            onTap: busy ? null : onExtend,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: GoalColors.line),
              ),
              child: const ReText('تمدید موعد',
                  fontSize: 11.5, fontWeight: 800, color: GoalColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// The goals already reached, folded away until opened.
class AchievedSection extends StatefulWidget {
  const AchievedSection({
    super.key,
    required this.goals,
    required this.onOpen,
  });

  final List<Goal> goals;
  final ValueChanged<Goal> onOpen;

  @override
  State<AchievedSection> createState() => _AchievedSectionState();
}

class _AchievedSectionState extends State<AchievedSection> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final duration = StatMotion.of(context, const Duration(milliseconds: 280));
    return AnimatedContainer(
      duration: duration,
      curve: StatMotion.curve,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_open ? 24 : 100),
      ),
      child: AnimatedSize(
        duration: duration,
        curve: StatMotion.curve,
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _open = !_open);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded,
                        size: 19, color: GoalColors.reached),
                    const SizedBox(width: 8),
                    const ReText('اهداف محقق‌شده',
                        fontSize: 13, fontWeight: 800, color: GoalColors.ink),
                    const SizedBox(width: 6),
                    ReText('${widget.goals.length}',
                        fontSize: 13,
                        fontWeight: 900,
                        color: GoalColors.muted),
                    const Spacer(),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: duration,
                      curve: StatMotion.curve,
                      child: const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 22, color: GoalColors.muted),
                    ),
                  ],
                ),
              ),
            ),
            if (_open)
              for (final goal in widget.goals) ...[
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: GoalColors.line,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.onOpen(goal),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 18, color: GoalColors.reached),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ReText(goal.title,
                              fontSize: 13,
                              fontWeight: 800,
                              color: GoalColors.ink,
                              maxLines: 1,
                              textAlign: TextAlign.right),
                        ),
                        const SizedBox(width: 8),
                        ReText(_reachedOn(goal),
                            fontSize: 11,
                            fontWeight: 600,
                            color: GoalColors.muted),
                      ],
                    ),
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }

  static String _reachedOn(Goal goal) {
    final day = goalDateOf(goal.updatedAt.value);
    return day == null ? '' : JalaliText.dayMonth(day);
  }
}

/// No goals at all: what this tab is for, and a way in.
class GoalsEmpty extends StatelessWidget {
  const GoalsEmpty({
    super.key,
    required this.onAdd,
    required this.onSuggestion,
  });

  final VoidCallback onAdd;
  final ValueChanged<String> onSuggestion;

  static const suggestions = [
    'قبولی در کنکور سراسری',
    'تراز ۷۰۰۰ در آزمون آزمایشی',
    'تمام کردن کتاب ',
    'رتبه‌ی زیر ۱۰۰۰',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 36),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(IconsaxPlusBold.flag,
                size: 32, color: GoalColors.ink),
          ),
          const SizedBox(height: 16),
          const ReText('هنوز هدفی نگذاشتی',
              fontSize: 16,
              fontWeight: 1000,
              color: GoalColors.ink,
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          const ReText(
            'یک هدف با تاریخ مشخص بگذار؛ اینجا روزهای مانده تا آن را می‌شماریم.',
            fontSize: 12.5,
            fontWeight: 600,
            color: GoalColors.muted,
            textAlign: TextAlign.center,
            maxLines: 2,
            lineHeight: 1.7,
          ),
          const SizedBox(height: 20),
          Pressable(
            onTap: onAdd,
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: GoalColors.accent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const ReText('اولین هدفت را بگذار',
                  fontSize: 14,
                  fontWeight: 800,
                  color: Colors.white,
                  textAlign: TextAlign.center),
            ),
          ),
          const SizedBox(height: 18),
          const ReText('یا یکی از این‌ها را شروع کن:',
              fontSize: 11.5,
              fontWeight: 700,
              color: GoalColors.muted,
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final text in suggestions)
                SuggestionChip(text: text, onTap: () => onSuggestion(text)),
            ],
          ),
        ],
      ),
    );
  }
}

/// A ready-made goal title, with a tiny orange spark.
class SuggestionChip extends StatelessWidget {
  const SuggestionChip({super.key, required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: GoalColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded,
                size: 12, color: GoalColors.accent),
            const SizedBox(width: 4),
            // A title left open («تمام کردن کتاب ») shows where to go on.
            ReText(text.endsWith(' ') ? '$text…' : text,
                fontSize: 11.5, fontWeight: 700, color: GoalColors.ink),
          ],
        ),
      ),
    );
  }
}

/// The tab's shape while the goals load.
class GoalsSkeleton extends StatelessWidget {
  const GoalsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget row() => const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone(width: 170, height: 14),
                    SizedBox(height: 8),
                    Bone(width: 100, height: 10),
                  ],
                ),
              ),
              Bone(width: 42, height: 28),
            ],
          ),
        );
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone(width: 100, height: 22, radius: 100),
                SizedBox(height: 12),
                Bone(width: 220, height: 18),
                SizedBox(height: 14),
                Bone(width: 170, height: 72),
                SizedBox(height: 14),
                Bone(height: 5, radius: 100),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Row(
            children: [
              Bone(width: 90, height: 16),
              Spacer(),
              Bone(width: 100, height: 34, radius: 100),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(children: [row(), row(), row()]),
          ),
        ],
      ),
    );
  }
}
