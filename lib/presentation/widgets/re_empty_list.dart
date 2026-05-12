import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/widgets/re_image.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/extentions.dart';

class ReEmptyList extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final IconData icon;
  final double imageWidth;

  const ReEmptyList({
    super.key,
    required this.title,
    required this.subtitle,
    this.imagePath = 'assets/images/empty_list_tasks.png',
    this.icon = Icons.add,
    this.imageWidth = 180,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ReImage(
                      imagePath,
                      width: imageWidth,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 20),
                          width: 72,
                          height: 48,
                          // padding: const EdgeInsets.symmetric(
                          //   vertical: 12,
                          //   horizontal: 30,
                          // ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: AppColors.white,
                          ),
                          child: Icon(
                            icon,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ReText(
                              title,
                              fontSize: 16,
                              fontWeight: 1000,
                            ),
                            ReText(
                              subtitle,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray,
                            ),
                          ],
                        ),
                      ],
                    ).tMargin(22),
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
