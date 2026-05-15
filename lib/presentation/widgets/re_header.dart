import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/extentions.dart';

Widget reAppHeader(String title, {Widget? suffixIcon, Widget? prefixIcon}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      prefixIcon ?? const SizedBox(width: 48),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Center(
            child: ReText(
              title,
              color: AppColors.black1,
              fontSize: 16,
              fontWeight: 1000,
            ),
          ),
        ),
      ),
      suffixIcon ?? const SizedBox(width: 48),
    ],
  ).tMargin(20).hMargin(32);
}
