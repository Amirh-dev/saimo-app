import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/widgets/re_image.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/extentions.dart';

Row authHeaderWidget({required bool userIsRegistering}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ReImage(
        userIsRegistering
            ? 'assets/images/register.png'
            : 'assets/images/login.png',
        width: 170,
        height: 160,
      ),
      const Spacer(),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0x23232b1a)),
                borderRadius: BorderRadius.circular(100)),
            child: const Icon(
              Icons.arrow_forward,
              size: 18,
              color: AppColors.black1,
            ).hMargin(15).vMargin(15),
          ),
          ReText(
            userIsRegistering ? 'ثبت نام' : 'ورود به حساب',
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
          ReText(
            userIsRegistering
                ? 'یک حساب ایجاد کنید.'
                : 'به حساب کاربری خود وارد شوید.',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ).tMargin(2)
        ],
      ),
      
    ],
  );
}
