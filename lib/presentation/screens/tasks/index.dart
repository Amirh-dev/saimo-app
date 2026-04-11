import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/widgets/re_header.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:solar_icons/solar_icons.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray1,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  color: AppColors.white),
              child: Column(
                children: [
                  reAppHeader(
                    'تسک ها',
                    suffixIcon: const Icon(
                      SolarIconsOutline.history,
                    ),
                    prefixIcon: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.gray2),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          const Icon(
                            SolarIconsOutline.bell,
                            size: 20,
                          ).vMargin(10).hMargin(10),
                          Container(
                            margin: const EdgeInsets.only(top: 5, right: 5),
                            alignment: Alignment.topRight,
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: AppColors.errorColor),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 60,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColors.gray2),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
