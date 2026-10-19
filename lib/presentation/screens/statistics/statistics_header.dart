import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:simo_learn/features/statistics/cubit/statistics_state.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_format.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/fonts.dart';

/// Today / this week / this month, and the calendar for a range of one's
/// own. The white pill slides to the picked period; with a custom range it
/// steps aside and the calendar button turns dark instead.
class PeriodTabs extends StatelessWidget {
  const PeriodTabs({
    super.key,
    required this.period,
    required this.onPeriod,
    required this.onCalendar,
  });

  final StatisticsPeriod period;
  final ValueChanged<StatisticsPeriod> onPeriod;
  final VoidCallback onCalendar;

  static const _labels = ['امروز', 'این هفته', 'این ماه'];
  static const _height = 42.0;

  @override
  Widget build(BuildContext context) {
    final duration = StatMotion.of(context, const Duration(milliseconds: 320));
    final custom = period == StatisticsPeriod.custom;
    final index = custom ? 1 : period.index;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: StatColors.line,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth / _labels.length;
              return SizedBox(
                height: _height,
                child: Stack(
                  children: [
                    AnimatedPositionedDirectional(
                      duration: duration,
                      curve: StatMotion.curve,
                      top: 0,
                      bottom: 0,
                      start: index * width,
                      width: width,
                      child: AnimatedOpacity(
                        duration: duration,
                        opacity: custom ? 0 : 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: StatColors.ink.withAlpha(14),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < _labels.length; i++)
                          Expanded(
                            child: Semantics(
                              button: true,
                              selected: !custom && i == index,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  final picked = StatisticsPeriod.values[i];
                                  if (picked == period) return;
                                  HapticFeedback.selectionClick();
                                  onPeriod(picked);
                                },
                                child: Center(
                                  child: AnimatedDefaultTextStyle(
                                    duration: duration,
                                    curve: StatMotion.curve,
                                    style: _style(!custom && i == index),
                                    child: Text(
                                      _labels[i],
                                      maxLines: 1,
                                      textDirection: TextDirection.rtl,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(width: 6),
          Semantics(
            button: true,
            label: 'انتخاب بازه‌ی دلخواه',
            child: _Pressable(
              onTap: onCalendar,
              child: AnimatedContainer(
                duration: duration,
                curve: StatMotion.curve,
                width: _height,
                height: _height,
                decoration: BoxDecoration(
                  color: custom ? StatColors.ink : AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: StatColors.ink.withAlpha(15),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  IconsaxPlusLinear.calendar,
                  size: 21,
                  color: custom ? AppColors.white : StatColors.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static TextStyle _style(bool selected) => TextStyle(
        fontFamily: AppFonts.iranSansVar,
        fontSize: 13,
        height: 1,
        letterSpacing: -0.5,
        fontVariations: AppFonts.fontVariations(selected ? 800 : 500),
        color: selected ? StatColors.ink : StatColors.ink.withAlpha(170),
      );
}

/// ‹ the range › with a way back to the running one. The range slides in
/// from the side the user stepped toward.
class RangeNavigator extends StatelessWidget {
  const RangeNavigator({
    super.key,
    required this.range,
    required this.direction,
    required this.onShift,
    required this.onCurrent,
  });

  final StatisticsRange range;
  final int direction;
  final ValueChanged<int> onShift;
  final VoidCallback onCurrent;

  @override
  Widget build(BuildContext context) {
    final title = StatsFormat.rangeTitle(range);
    return Row(
      children: [
        NavButton(
          // Mirrored in RTL: it points right, toward the past.
          icon: Icons.chevron_left_rounded,
          label: 'بازه‌ی قبل',
          onTap: () => onShift(-1),
        ),
        Expanded(
          child: Column(
            children: [
              _Sliding(
                value: title,
                direction: direction,
                child: ReText(
                  title,
                  key: ValueKey(title),
                  fontSize: 14,
                  fontWeight: 900,
                  color: StatColors.ink,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedSwitcher(
                duration:
                    StatMotion.of(context, const Duration(milliseconds: 220)),
                child: range.isCurrent
                    ? ReText(
                        StatsFormat.currentCaption(range),
                        key: ValueKey('current-${range.period}'),
                        fontSize: 11,
                        fontWeight: 600,
                        color: StatColors.muted,
                        textAlign: TextAlign.center,
                      )
                    : _Pressable(
                        key: const ValueKey('back'),
                        onTap: onCurrent,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 3, 8, 3),
                          decoration: BoxDecoration(
                            color: StatColors.study.withAlpha(22),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ReText(
                                StatsFormat.backToCurrent(range),
                                fontSize: 11,
                                fontWeight: 800,
                                color: StatColors.study,
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.chevron_left_rounded,
                                size: 16,
                                color: StatColors.study,
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        NavButton(
          icon: Icons.chevron_right_rounded,
          label: 'بازه‌ی بعد',
          onTap: range.canGoNext ? () => onShift(1) : null,
        ),
      ],
    );
  }
}

/// Swaps [child] when [value] changes: the new one slides in from the side
/// the user stepped toward (the past is on the right), the old one fades.
class _Sliding extends StatelessWidget {
  const _Sliding({
    required this.value,
    required this.direction,
    required this.child,
  });

  final String value;
  final int direction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Back in time (-1) comes in from the right.
    final from = direction == 0 ? 0.0 : (direction < 0 ? 0.35 : -0.35);
    return AnimatedSwitcher(
      duration: StatMotion.of(context, const Duration(milliseconds: 300)),
      switchInCurve: StatMotion.curve,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.center,
        children: [...previous, if (current != null) current],
      ),
      transitionBuilder: (child, animation) {
        final incoming = child.key == ValueKey(value);
        if (!incoming) return FadeTransition(opacity: animation, child: child);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: Offset(from, 0), end: Offset.zero)
                .animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class NavButton extends StatelessWidget {
  const NavButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.size = 38,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: _Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: StatMotion.of(context, StatMotion.quick),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: enabled ? StatColors.surface : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: size * 0.6,
            color: enabled ? StatColors.ink : StatColors.muted.withAlpha(90),
          ),
        ),
      ),
    );
  }
}

/// Sinks a little while pressed, with a light tick, and springs back.
class _Pressable extends StatefulWidget {
  const _Pressable({super.key, required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
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
        scale: _down ? 0.9 : 1,
        duration: StatMotion.of(context, const Duration(milliseconds: 120)),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// The range, kept on top once the header has scrolled away.
class StickyRangeBar extends StatelessWidget {
  const StickyRangeBar({
    super.key,
    required this.range,
    required this.onShift,
  });

  final StatisticsRange range;
  final ValueChanged<int> onShift;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.fromLTRB(16, top + 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: StatColors.ink.withAlpha(16),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: StatColors.surface,
              borderRadius: BorderRadius.circular(100),
            ),
            child: ReText(
              StatsFormat.rangeName(range),
              fontSize: 12,
              fontWeight: 800,
              color: StatColors.ink,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ReText(
              StatsFormat.rangeShort(range),
              fontSize: 13,
              fontWeight: 700,
              color: StatColors.muted,
              maxLines: 1,
              textAlign: TextAlign.right,
            ),
          ),
          NavButton(
            icon: Icons.chevron_left_rounded,
            label: 'بازه‌ی قبل',
            size: 32,
            onTap: () => onShift(-1),
          ),
          const SizedBox(width: 4),
          NavButton(
            icon: Icons.chevron_right_rounded,
            label: 'بازه‌ی بعد',
            size: 32,
            onTap: range.canGoNext ? () => onShift(1) : null,
          ),
        ],
      ),
    );
  }
}
