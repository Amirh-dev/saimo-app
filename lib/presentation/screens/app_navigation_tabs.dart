import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/screens/goals/index.dart';
import 'package:simo_learn/presentation/screens/statistics/index.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/app_bottom_navigation_bar.dart';
import 'package:simo_learn/presentation/screens/profile/index.dart';
import 'package:simo_learn/presentation/screens/tasks/index.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/extentions.dart';
import 'package:simo_learn/utils/helpers.dart';

class TrophiesScreen extends StatelessWidget {
  const TrophiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBottomNavigationScaffold(
      currentIndex: 1,
      onTap: (index) {
        if (index == 1) return;
        _navigateToIndex(context, index);
      },
      body: SafeArea(
        child: const Column(
          children: [
            Center(
              child: ReText(
                'جوایز',
                color: AppColors.black1,
                fontSize: 20,
                fontWeight: 1000,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Center(
                child: ReText(
                  'صفحه جوایز و دستاوردها در اینجا نمایش داده می‌شود.',
                  textAlign: TextAlign.center,
                  color: AppColors.black1,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ).tMargin(22),
      ),
    );
  }

  void _navigateToIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.toOff(const GoalScreen());
        break;
      case 2:
        context.toOff(const TasksScreen());
        break;
      case 3:
        context.toOff(const StatisticsScreen());
        break;
      case 4:
        context.toOff(const ProfileScreen());
        break;
    }
  }
}

