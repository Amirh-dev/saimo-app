import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:solar_icons/solar_icons.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// True while a bottom navigation bar is on the top-most route. Floating
  /// overlays (e.g. the task timer banner) use it to clear the bar.
  static final ValueNotifier<bool> isVisible = ValueNotifier<bool>(false);

  /// Every screen's bar shares this hero tag: while screens change the bar
  /// stays where it is and its circle glides over to the new tab.
  static const String _heroTag = 'app-bottom-navigation-bar';

  @override
  Widget build(BuildContext context) {
    return _BottomNavPresence(
      child: Hero(
        tag: _heroTag,
        flightShuttleBuilder: _flight,
        child: _NavBar(
          position: _slotOf(currentIndex).toDouble(),
          onTap: onTap,
        ),
      ),
    );
  }

  static Widget _flight(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final from = ((fromHeroContext.widget as Hero).child as _NavBar).position;
    final to = ((toHeroContext.widget as Hero).child as _NavBar).position;
    if (reduceMotion(flightContext)) return _NavBar(position: to);

    // A pop runs the route animation from 1 back to 0.
    final (start, end) =
        direction == HeroFlightDirection.push ? (from, to) : (to, from);
    final distance = (end - start).abs().clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        return _NavBar(
          position: lerpDouble(start, end, t)!,
          // Drawn out into a short pill mid-glide, then round again.
          stretch: math.sin(math.pi * t) * distance,
        );
      },
    );
  }
}

class _NavItemSpec {
  const _NavItemSpec({
    required this.index,
    required this.label,
    this.activeIcon,
    this.inactiveIcon,
    this.activeSvg,
    this.inactiveSvg,
  });

  final int index;
  final String label;
  final IconData? activeIcon;
  final IconData? inactiveIcon;
  final String? activeSvg;
  final String? inactiveSvg;
}

/// The tabs from left to right; the bar reads right to left, home first.
final List<_NavItemSpec> _items = [
  const _NavItemSpec(
    index: 4,
    label: 'پروفایل',
    activeIcon: SolarIconsBold.user,
    inactiveIcon: SolarIconsOutline.user,
  ),
  const _NavItemSpec(
    index: 3,
    label: 'آمار',
    activeIcon: SolarIconsBold.chart_2,
    inactiveIcon: SolarIconsOutline.chart_2,
  ),
  const _NavItemSpec(
    index: 2,
    label: 'اهداف',
    activeSvg: 'assets/icons/target.svg',
    inactiveSvg: 'assets/icons/target_out.svg',
  ),
  const _NavItemSpec(
    index: 1,
    label: 'تسک‌ها',
    activeIcon: SolarIconsBold.checklistMinimalistic,
    inactiveIcon: SolarIconsOutline.checklistMinimalistic,
  ),
  const _NavItemSpec(
    index: 0,
    label: 'خانه',
    activeIcon: SolarIconsBold.home,
    inactiveIcon: SolarIconsOutline.home,
  ),
];

/// Slot of a tab from the left, or -1 for a screen that is not a tab.
int _slotOf(int index) => _items.indexWhere((item) => item.index == index);

class _NavBar extends StatelessWidget {
  const _NavBar({required this.position, this.stretch = 0, this.onTap});

  /// Where the active circle sits, in slots from the left; between two
  /// slots while it glides. Negative when no tab is active.
  final double position;

  /// 0..1, how far the circle is drawn out into a pill.
  final double stretch;

  /// Null while the bar is flying between screens.
  final ValueChanged<int>? onTap;

  static const double _barHeight = 70;
  static const double _circleDiameter = 30;
  static const double _itemSize = 52;
  static const double _maxStretch = 18;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          height: _barHeight + _circleDiameter / 2,
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: _barHeight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final step = (constraints.maxWidth - _itemSize) / (_items.length - 1);
                  const top = (_barHeight - _itemSize) / 2;
                  final width = _itemSize + _maxStretch * stretch;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (position >= 0)
                        Positioned(
                          key: const ValueKey('nav-indicator'),
                          left: position * step + (_itemSize - width) / 2,
                          top: top,
                          width: width,
                          height: _itemSize,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.all(Radius.circular(100)),
                            ),
                          ),
                        ),
                      for (var slot = 0; slot < _items.length; slot++)
                        Positioned(
                          left: slot * step,
                          top: top,
                          width: _itemSize,
                          height: _itemSize,
                          child: _NavItem(
                            spec: _items[slot],
                            activeness: position < 0
                                ? 0
                                : (1 - (position - slot).abs()).clamp(0.0, 1.0),
                            onTap: onTap,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.spec,
    required this.activeness,
    required this.onTap,
  });

  final _NavItemSpec spec;

  /// 1 when the circle sits on this tab, 0 when it is elsewhere.
  final double activeness;
  final ValueChanged<int>? onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    final onTap = widget.onTap;
    return Semantics(
      button: true,
      selected: widget.activeness == 1,
      label: widget.spec.label,
      child: GestureDetector(
        key: ValueKey('nav-item-${widget.spec.index}'),
        behavior: HitTestBehavior.opaque,
        onTapDown: onTap == null ? null : (_) => _setPressed(true),
        onTapUp: onTap == null ? null : (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap(widget.spec.index);
              },
        child: AnimatedScale(
          scale: _pressed ? 0.86 : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: Center(child: _buildIcon(widget.activeness)),
        ),
      ),
    );
  }

  Widget _buildIcon(double activeness) {
    if (activeness >= 1) return _icon(active: true, size: 24);
    if (activeness <= 0) return _icon(active: false, size: 20);

    // Mid-glide: the outline fades out as the circle arrives, or back in as
    // it leaves.
    final size = lerpDouble(20, 24, activeness)!;
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: 1 - activeness, child: _icon(active: false, size: size)),
        Opacity(opacity: activeness, child: _icon(active: true, size: size)),
      ],
    );
  }

  Widget _icon({required bool active, required double size}) {
    final spec = widget.spec;
    if (spec.activeSvg != null) {
      return SizedBox.square(
        dimension: 52,
        child: Padding(
          padding: EdgeInsets.all(active ? 15 : 16),
          child: SvgPicture.asset(active ? spec.activeSvg! : spec.inactiveSvg!),
        ),
      );
    }
    return Icon(
      active ? spec.activeIcon : spec.inactiveIcon,
      size: size,
      color: active ? AppColors.white : AppColors.black1,
    );
  }
}

/// Reports to [AppBottomNavigationBar.isVisible] whether this bar's route is
/// the current one.
class _BottomNavPresence extends StatefulWidget {
  const _BottomNavPresence({required this.child});

  final Widget child;

  @override
  State<_BottomNavPresence> createState() => _BottomNavPresenceState();
}

class _BottomNavPresenceState extends State<_BottomNavPresence> {
  static final Set<_BottomNavPresenceState> _visible = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.isCurrentOf(context) ?? true) {
      _visible.add(this);
    } else {
      _visible.remove(this);
    }
    _sync();
  }

  @override
  void dispose() {
    _visible.remove(this);
    _sync();
    super.dispose();
  }

  // Deferred: listeners rebuild outside this subtree, which isn't allowed
  // mid-build.
  static void _sync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppBottomNavigationBar.isVisible.value = _visible.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class AppBottomNavigationScaffold extends StatelessWidget {
  const AppBottomNavigationScaffold({
    super.key,
    required this.currentIndex,
    required this.body,
    required this.onTap,
  });

  final int currentIndex;
  final Widget body;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray1,
      body: body,
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
      ),
    );
  }
}
