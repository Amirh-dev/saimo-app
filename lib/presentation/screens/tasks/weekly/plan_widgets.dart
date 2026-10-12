import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/presentation/widgets/re_dots_loader.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/_utils.dart';

/// Building blocks shared by the weekly view and its sheets, in the tasks
/// screen's visual language: pill shapes, gray2 borders, heavy IRANSans.

class PlanPillButton extends StatelessWidget {
  const PlanPillButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.filled = true,
    this.background = AppColors.primary,
    this.foreground = AppColors.white,
    this.height = 50,
    this.fontSize = 14,
    this.isLoading = false,
  });

  /// An outlined button on white, for secondary actions.
  const PlanPillButton.outlined({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.height = 50,
    this.fontSize = 14,
  })  : filled = false,
        background = AppColors.white,
        foreground = AppColors.black1,
        isLoading = false;

  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool filled;
  final Color background;
  final Color foreground;
  final double height;
  final double fontSize;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !isLoading;
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: onTap == null ? 0.45 : 1,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(100),
              border: filled ? null : Border.all(color: AppColors.gray2),
            ),
            alignment: Alignment.center,
            child: isLoading
                ? ReDotsLoader(color: foreground)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: fontSize + 4, color: foreground),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: ReText(
                          text,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w800,
                          color: foreground,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// The white bottom sheet used by the tasks screens: orange handle, a title
/// with an optional subtitle and a round close button.
class PlanSheetFrame extends StatelessWidget {
  const PlanSheetFrame({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: media.size.height * 0.9),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        margin: const EdgeInsets.only(top: 8, bottom: 20),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ReText(
                                title,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.black1,
                                maxLines: 1,
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 4),
                                ReText(
                                  subtitle!,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray,
                                  maxLines: 2,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Semantics(
                          button: true,
                          label: 'بستن',
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.gray2),
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.black1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A rounded dashed outline, for "add or drop here" slots.
class DashedBorder extends StatelessWidget {
  const DashedBorder({
    super.key,
    required this.child,
    this.color = AppColors.dark5Color,
    this.radius = 100,
  });

  final Widget child;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color, radius: radius),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const double _dash = 6;
  static const double _gap = 5;
  static const double _strokeWidth = 1.4;

  @override
  void paint(Canvas canvas, Size size) {
    final corner = math.min(radius, size.shortestSide / 2);
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(_strokeWidth / 2),
      Radius.circular(corner),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += _dash + _gap) {
        canvas.drawPath(
          metric.extractPath(start, math.min(start + _dash, metric.length)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

/// A number whose digits roll in place to a new value, like an odometer:
/// each digit is a column of 0-9 sliding behind its own window.
class RollingNumber extends StatelessWidget {
  const RollingNumber({
    super.key,
    required this.value,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w900,
    this.color = AppColors.black1,
  });

  final int value;
  final double fontSize;
  final Object fontWeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final digits = value.toString().split('').map(int.parse).toList();
    final height = fontSize * 1.4;
    final widths = _widthsOf(fontSize, fontWeight);
    return ExcludeSemantics(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < digits.length; index++)
              // Keyed from the right, so units stay units when the number
              // gains a digit.
              _RollingDigit(
                key: ValueKey('rolling-digit-${digits.length - 1 - index}'),
                digit: digits[index],
                widths: widths,
                height: height,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: color,
              ),
          ],
        ),
      ),
    );
  }
}

/// Widths of the digits 0-9 in a style, measured once and kept.
final Map<(double, Object), List<double>> _digitWidths = {};

List<double> _widthsOf(double fontSize, Object fontWeight) {
  return _digitWidths.putIfAbsent((fontSize, fontWeight), () {
    return [
      for (final digit in '۰۱۲۳۴۵۶۷۸۹'.split(''))
        () {
          final painter = TextPainter(
            text: TextSpan(
              text: digit,
              style: TextStyle(
                fontFamily: AppFonts.iranSansVar,
                fontVariations: AppFonts.fontVariations(fontWeight),
                fontSize: fontSize,
                letterSpacing: -0.5,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          final width = painter.width.ceilToDouble() + 1;
          painter.dispose();
          return width;
        }(),
    ];
  });
}

class _RollingDigit extends StatelessWidget {
  const _RollingDigit({
    super.key,
    required this.digit,
    required this.widths,
    required this.height,
    required this.fontSize,
    required this.fontWeight,
    required this.color,
  });

  final int digit;

  /// Width of each digit 0-9; the window takes the width of the one it
  /// shows, so the number keeps its natural spacing.
  final List<double> widths;
  final double height;
  final double fontSize;
  final Object fontWeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final widest = widths.reduce((a, b) => a > b ? a : b);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 620),
      curve: AppMotion.settle,
      width: widths[digit],
      height: height,
      child: ClipRect(
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: digit.toDouble()),
          duration: const Duration(milliseconds: 620),
          curve: AppMotion.settle,
          builder: (context, value, child) => Transform.translate(
            offset: Offset(0, -value * height),
            child: child,
          ),
          child: OverflowBox(
            alignment: Alignment.topCenter,
            minWidth: widest,
            maxWidth: widest,
            maxHeight: height * 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var d = 0; d < 10; d++)
                  SizedBox(
                    height: height,
                    child: Center(
                      child: ReText(
                        '$d',
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        color: color,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// While a page is swiped aside it sinks back a little and fades, so the
/// pages read as cards on a stack.
class DepthOnSwipe extends StatelessWidget {
  const DepthOnSwipe({
    super.key,
    required this.pages,
    required this.page,
    required this.child,
  });

  final PageController pages;
  final int page;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pages,
      builder: (context, child) {
        var offset = 0.0;
        if (pages.hasClients && pages.position.haveDimensions) {
          offset = ((pages.page ?? page.toDouble()) - page).abs().clamp(0.0, 1.0);
        }
        return Opacity(
          opacity: 1 - 0.5 * offset,
          child: Transform.scale(scale: 1 - 0.08 * offset, child: child),
        );
      },
      child: child,
    );
  }
}

/// Shrinks a touch while pressed, then springs back, with a light tick.
class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _set(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final onTap = widget.onTap;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: onTap == null ? null : (_) => _set(true),
      onTapUp: onTap == null ? null : (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1,
        duration: Duration(milliseconds: _pressed ? 90 : 260),
        curve: _pressed ? Curves.easeOut : Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}
