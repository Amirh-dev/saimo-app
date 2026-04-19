import 'package:flutter/material.dart';
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

  static const double _barHeight = 70;
  static const double _circleDiameter = 30;

  @override
  Widget build(BuildContext context) {
    const activeIconSize = 24.0;
    const inactiveIconSize = 20.0;
    final inactiveColor = AppColors.black1.withOpacity(0.55);
    const activeColor = AppColors.white;

    Widget buildNavIcon({
      required IconData activeIcon,
      required IconData inactiveIcon,
      required int index,
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
          child: Icon(
            isActive ? activeIcon : inactiveIcon,
            size: isActive ? activeIconSize : inactiveIconSize,
            color: isActive ? activeColor : inactiveColor,
          ),
        ),
      );
    }

    return SafeArea(
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
                        activeIcon: SolarIconsBold.alarm,
                        inactiveIcon: SolarIconsOutline.alarm,
                        index: 3,
                      ),
                      buildNavIcon(
                        activeIcon: SolarIconsBold.checklistMinimalistic,
                        inactiveIcon: SolarIconsOutline.checklistMinimalistic,
                        index: 2,
                      ),
                      buildNavIcon(
                        activeIcon: SolarIconsBold.cupFirst,
                        inactiveIcon: SolarIconsOutline.cupFirst,
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
    );
  }
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
