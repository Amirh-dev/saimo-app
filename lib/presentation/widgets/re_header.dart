import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/extentions.dart';

Widget reAppHeader(String title, {Widget? secondIcon, Widget? firstIcon}) {
  return Row(
    children: [
      firstIcon ?? const SizedBox(width: 48),
      secondIcon ?? const SizedBox(width: 48),
      Expanded(
        child: ReText(
          title,
          textAlign: TextAlign.start,
          color: AppColors.black1,
          fontSize: 16,
          fontWeight: 1000,
        ),
      ),
    ],
  ).tMargin(20).hMargin(16);
}
