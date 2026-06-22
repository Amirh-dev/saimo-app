import 'package:flutter/material.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

import '_widgets.dart';

class ReSearchPill extends StatelessWidget {
  const ReSearchPill({
    super.key,
    this.placeholder = 'جستجو',
    this.onTap,
    this.height = 48,
    this.horizontalPadding = 18,
    this.backgroundColor = AppColors.gray1,
    this.borderRadius = 100,
    this.icon = SolarIconsOutline.magnifier,
  });

  final String placeholder;
  final VoidCallback? onTap;
  final double height;
  final double horizontalPadding;
  final Color backgroundColor;
  final double borderRadius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ReText(
              placeholder,
              color: AppColors.black1.withOpacity(0.35),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(width: 8),
            Icon(
              icon,
              size: 18,
              color: AppColors.black1.withOpacity(0.45),
            ),
          ],
        ),
      ),
    );
  }
}
