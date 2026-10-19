import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simo_learn/features/goals/goal_timing.dart';
import 'package:simo_learn/features/goals/goals_repository.dart';
import 'package:simo_learn/presentation/screens/goals/goal_widgets.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';

/// The goal is reached: a tick, a little confetti that falls once, and how
/// early it came. True when the user wants to set the next goal.
Future<bool> showGoalCelebration(
  BuildContext context,
  Goal goal, {
  required GoalTiming timing,
}) async {
  HapticFeedback.mediumImpact();
  final next = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'بستن',
    barrierColor: GoalColors.ink.withAlpha(110),
    transitionDuration: reduceMotion(context)
        ? Duration.zero
        : const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) => _Celebration(goal: goal, timing: timing),
    transitionBuilder: (context, animation, _, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.94, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
  return next ?? false;
}

class _Celebration extends StatefulWidget {
  const _Celebration({required this.goal, required this.timing});

  final Goal goal;
  final GoalTiming timing;

  @override
  State<_Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends State<_Celebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _controller.value = 1;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.timing.daysLeft;
    final String? when = days == null
        ? null
        : days > 0
            ? '$days روز زودتر از موعد'
            : days == 0
                ? 'درست سر موعد'
                : '${-days} روز بعد از موعد';
    final tick = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.45, curve: Curves.elasticOut),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 330,
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: RepaintBoundary(
                      child: CustomPaint(painter: _Confetti(_controller)),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: tick,
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: GoalColors.reached.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: const BoxDecoration(
                              color: GoalColors.reached,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_rounded,
                                size: 34, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const ReText('تبریک! به هدفت رسیدی',
                        fontSize: 19,
                        fontWeight: 1000,
                        color: GoalColors.ink,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    ReText(widget.goal.title,
                        fontSize: 13,
                        fontWeight: 700,
                        color: GoalColors.muted,
                        textAlign: TextAlign.center,
                        maxLines: 2),
                    if (when != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: (days! >= 0
                                  ? GoalColors.reached
                                  : GoalColors.muted)
                              .withAlpha(26),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              days >= 0
                                  ? Icons.bolt_rounded
                                  : Icons.schedule_rounded,
                              size: 14,
                              color: days >= 0
                                  ? GoalColors.reached
                                  : GoalColors.muted,
                            ),
                            const SizedBox(width: 4),
                            ReText(when,
                                fontSize: 11.5,
                                fontWeight: 800,
                                color: days >= 0
                                    ? GoalColors.reached
                                    : GoalColors.muted),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    Pressable(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: GoalColors.ink,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const ReText('ادامه',
                            fontSize: 14,
                            fontWeight: 800,
                            color: Colors.white,
                            textAlign: TextAlign.center),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Pressable(
                      onTap: () => Navigator.of(context).pop(true),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: ReText('هدف بعدی‌ات را بگذار',
                            fontSize: 12.5,
                            fontWeight: 800,
                            color: GoalColors.accent,
                            textAlign: TextAlign.center),
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
  }
}

/// A handful of paper bits thrown up from behind the tick, falling once
/// and fading. Painted from one animation; nothing rebuilds.
class _Confetti extends CustomPainter {
  _Confetti(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  static const _colors = [
    AppColors.done,
    AppColors.primary,
    AppColors.secondary,
    AppColors.simoCoin,
  ];

  static final List<_Bit> _bits = () {
    final random = math.Random(11);
    return [
      for (var i = 0; i < 34; i++)
        _Bit(
          angle: -math.pi / 2 + (random.nextDouble() - 0.5) * math.pi * 1.2,
          speed: 150 + random.nextDouble() * 120,
          spin: (random.nextDouble() - 0.5) * 12,
          color: _colors[i % _colors.length],
          wide: random.nextBool(),
        ),
    ];
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    if (t <= 0 || t >= 1) return;
    // From the middle of the tick, kept around it and above the words.
    final origin = Offset(size.width / 2, 42);
    final paint = Paint();
    for (final bit in _bits) {
      // Thrown up and out, then pulled down.
      final dx = math.cos(bit.angle) * bit.speed * t;
      final dy = math.sin(bit.angle) * bit.speed * t + 220 * t * t;
      final fade = t < 0.5 ? 1.0 : (1 - (t - 0.5) / 0.5);
      paint.color = bit.color.withValues(alpha: 0.9 * fade);
      canvas.save();
      canvas.translate(origin.dx + dx, origin.dy + dy);
      canvas.rotate(bit.spin * t);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: bit.wide ? 8 : 5,
            height: bit.wide ? 4 : 9,
          ),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_Confetti oldDelegate) => false;
}

class _Bit {
  const _Bit({
    required this.angle,
    required this.speed,
    required this.spin,
    required this.color,
    required this.wide,
  });

  final double angle;
  final double speed;
  final double spin;
  final Color color;
  final bool wide;
}
