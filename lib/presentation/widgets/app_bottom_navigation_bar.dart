import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  static const double _barHeight = 70;
  static const double _circleDiameter = 30;

  @override
  Widget build(BuildContext context) {
    const activeIconSize = 24.0;
    const inactiveIconSize = 20.0;
    final inactiveColor = AppColors.black1;
    const activeColor = AppColors.white;

    Widget buildNavIcon({
      required int index,
      bool useSvg = false,
      IconData? activeIcon,
      IconData? inactiveIcon,
      String? activeIconSvg,
      String? inactiveIconSvg,
    }) {
      final isActive = index == currentIndex;
      return GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: useSvg
              ? Padding(
                  padding: EdgeInsets.all(isActive ? 15.0 : 16.0),
                  child: SvgPicture.asset(isActive ? activeIconSvg! : inactiveIconSvg!),
                )
              : Icon(
                  isActive ? activeIcon : inactiveIcon,
                  size: isActive ? activeIconSize : inactiveIconSize,
                  color: isActive ? activeColor : inactiveColor,
                ),
        ),
      );
    }

    return _BottomNavPresence(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: SizedBox(
            height: _barHeight + _circleDiameter / 2,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: _barHeight,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildNavIcon(
                          activeIcon: SolarIconsBold.user,
                          inactiveIcon: SolarIconsOutline.user,
                          index: 4,
                        ),
                        buildNavIcon(
                          activeIcon: SolarIconsBold.chart_2,
                          inactiveIcon: SolarIconsOutline.chart_2,
                          index: 3,
                        ),
                        buildNavIcon(
                          useSvg: true,
                          activeIconSvg: 'assets/icons/target.svg',
                          inactiveIconSvg: 'assets/icons/target_out.svg',
                          index: 2,
                        ),
                        buildNavIcon(
                          activeIcon: SolarIconsBold.checklistMinimalistic,
                          inactiveIcon: SolarIconsOutline.checklistMinimalistic,
                          index: 1,
                        ),
                        buildNavIcon(
                          activeIcon: SolarIconsBold.home,
                          inactiveIcon: SolarIconsOutline.home,
                          index: 0,
                        ),
                      ],
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
