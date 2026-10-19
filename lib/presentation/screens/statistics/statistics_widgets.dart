import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';

/// The statistics screen's colors: neutral cards, one accent per chart
/// (study blue, tests green and red, ratings gold), and the old screen's
/// four card colors as soft tints.
class StatColors {
  const StatColors._();

  static const ink = AppColors.black1;
  static const muted = AppColors.gray;
  static const line = AppColors.gray2;
  static const surface = AppColors.gray1;

  static const study = Color(0xFF4263EB);
  static const studySoft = Color(0xFFB4C1F7);
  static const correct = AppColors.success;
  static const wrong = Color(0xFFF58A8A);
  static const rating = AppColors.simoCoin;

  static const yellow = Color(0xFFF5B031);
  static const orange = Color(0xFFFF573D);
  static const green = AppColors.success;
  static const blue = study;
}

/// Durations of the screen's motion, all short so nothing feels busy.
class StatMotion {
  const StatMotion._();

  static const grow = Duration(milliseconds: 750);
  static const count = Duration(milliseconds: 800);
  static const reveal = Duration(milliseconds: 650);
  static const quick = Duration(milliseconds: 220);
  static const curve = Curves.easeOutCubic;

  static Duration of(BuildContext context, Duration duration) =>
      reduceMotion(context) ? Duration.zero : duration;
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.child, this.padding = 18});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: StatColors.ink.withAlpha(12)),
        ],
      ),
      child: child,
    );
  }
}

class StatSectionTitle extends StatelessWidget {
  const StatSectionTitle(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          ReText(title, fontSize: 16, fontWeight: 900, color: StatColors.ink),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// A soft tinted circle with the icon in its color.
class TintIcon extends StatelessWidget {
  const TintIcon(this.icon, this.color, {super.key, this.size = 36});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha(30),
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}

/// «↑ ۱۲٪»: green when up, red when down; a faded gray tag when level or
/// when there is nothing to compare, so no card has a hole where it goes.
class ChangeChip extends StatelessWidget {
  const ChangeChip(this.text, {super.key, required this.change});

  const ChangeChip.neutral(this.text, {super.key}) : change = 0;

  final String text;
  final num change;

  @override
  Widget build(BuildContext context) {
    if (change == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: StatColors.surface,
          borderRadius: BorderRadius.circular(100),
        ),
        child: ReText(
          text,
          fontSize: 11.5,
          fontWeight: 800,
          color: StatColors.muted.withAlpha(150),
        ),
      );
    }
    final color = change > 0 ? StatColors.green : AppColors.errorColor;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 3, 6, 3),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            change > 0
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 2),
          ReText(text, fontSize: 11.5, fontWeight: 800, color: color),
        ],
      ),
    );
  }

  /// A change in percent. With nothing before to compare with it is a faded
  /// «۰٪», or «جدید» when there is something now ([fromNothing]).
  static Widget percent(double? change, {bool fromNothing = false}) {
    if (change == null) {
      return fromNothing
          ? const ChangeChip('جدید', change: 1)
          : const ChangeChip.neutral('0٪');
    }
    final rounded = change.round();
    return rounded == 0
        ? const ChangeChip.neutral('0٪')
        : ChangeChip('${rounded.abs()}٪', change: rounded);
  }
}

class LegendDot extends StatelessWidget {
  const LegendDot(this.color, this.label, {super.key});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        ReText(label, fontSize: 11.5, fontWeight: 600, color: StatColors.muted),
      ],
    );
  }
}

/// A number that counts up to [value] the first time, and from its old
/// value to a new one after that.
class CountUp extends StatelessWidget {
  const CountUp({super.key, required this.value, required this.builder});

  final double value;
  final Widget Function(BuildContext context, double value) builder;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: StatMotion.of(context, StatMotion.count),
      curve: StatMotion.curve,
      builder: (context, value, _) => builder(context, value),
    );
  }
}

/// Fades a section in and lifts it a little, after the ones above it.
class Reveal extends StatelessWidget {
  const Reveal({
    super.key,
    required this.animation,
    required this.index,
    required this.child,
  });

  final Animation<double> animation;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.1).clamp(0.0, 0.6);
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(start, start + 0.4, curve: StatMotion.curve),
    );
    return FadeTransition(
      opacity: curved,
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, 14 * (1 - curved.value)),
          child: child,
        ),
        child: child,
      ),
    );
  }
}

/// A chart with nothing in it yet: faint bars in the chart's color that rise
/// once, its icon on top, and a line on what fills it.
class GhostChartEmpty extends StatelessWidget {
  const GhostChartEmpty({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.body,
    this.heights = const [0.45, 0.7, 0.5, 0, 0.6, 0.3, 0.65],
    this.round = false,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String body;

  /// Each faint bar's height, as a share of the tallest; the middle one sits
  /// under the icon, so it is best left at zero.
  final List<double> heights;

  /// Fully rounded bars, like the rating chart's.
  final bool round;

  static const _height = 76.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _height + 8,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < heights.length; i++)
                      Expanded(
                        child: Center(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: heights[i]),
                            duration: StatMotion.of(
                              context,
                              Duration(milliseconds: 700 + i * 60),
                            ),
                            curve: StatMotion.curve,
                            builder: (context, share, _) => Container(
                              width: round ? 12 : 14,
                              height: _height * share,
                              decoration: BoxDecoration(
                                borderRadius: round
                                    ? BorderRadius.circular(100)
                                    : const BorderRadius.vertical(
                                        top: Radius.circular(7),
                                        bottom: Radius.circular(2),
                                      ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [color.withAlpha(12), color.withAlpha(48)],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withAlpha(36)),
                  boxShadow: [
                    BoxShadow(color: color.withAlpha(28), blurRadius: 14),
                  ],
                ),
                child: TintIcon(icon, color, size: 46),
              ),
            ],
          ),
        ),
        Container(
          height: 1.5,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: StatColors.line,
        ),
        const SizedBox(height: 16),
        ReText(
          title,
          fontSize: 14,
          fontWeight: 900,
          color: StatColors.ink,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        ReText(
          body,
          fontSize: 12,
          fontWeight: 600,
          color: StatColors.muted,
          textAlign: TextAlign.center,
          maxLines: 2,
          lineHeight: 1.7,
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

/// Drives the shimmer of every [Bone] below it with one ticker.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  static Animation<double>? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_ShimmerScope>()
      ?.animation;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ShimmerScope(animation: _controller, child: widget.child);
  }
}

class _ShimmerScope extends InheritedWidget {
  const _ShimmerScope({required this.animation, required super.child});

  final Animation<double> animation;

  @override
  bool updateShouldNotify(_ShimmerScope oldWidget) =>
      animation != oldWidget.animation;
}

/// A gray placeholder block with a soft light passing over it. It repaints
/// itself; nothing around it rebuilds.
class Bone extends StatelessWidget {
  const Bone({
    super.key,
    this.width,
    required this.height,
    this.radius = 10,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final animation = Shimmer.of(context);
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _BonePainter(animation, radius),
      ),
    );
  }
}

class _BonePainter extends CustomPainter {
  _BonePainter(this.animation, this.radius) : super(repaint: animation);

  final Animation<double>? animation;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final t = animation?.value ?? 0;
    // The light travels across a band three widths wide, so it enters and
    // leaves softly instead of popping in.
    final dx = (t * 3 - 1.5) * size.width;
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          StatColors.surface,
          Color(0xFFFBFBFD),
          StatColors.surface,
        ],
        stops: [0.35, 0.5, 0.65],
      ).createShader(rect.shift(Offset(dx, 0)));
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BonePainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.animation != animation;
}
