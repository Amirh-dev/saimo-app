import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_header.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/extentions.dart';
import 'package:simo_learn/utils/helpers.dart';
import 'package:solar_icons/solar_icons.dart';

class GoalScreen extends StatelessWidget {
  const GoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray1,
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) => navigateToIndex(context, index),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: Column(
                children: [
                  reAppHeader(
                    'اهداف',
                    prefixIcon: GestureDetector(
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          SolarIconsOutline.history,
                          size: 24,
                        ),
                      ),
                    ),
                    suffixIcon: GestureDetector(
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          SolarIconsOutline.bell,
                          size: 24,
                        ),
                      ),
                    ),
                  ).bMargin(24)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
