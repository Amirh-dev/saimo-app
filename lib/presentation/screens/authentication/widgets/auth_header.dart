import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/widgets/re_image.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/enums.dart';
import 'package:simo_learn/utils/extentions.dart';

Row authHeaderWidget(BuildContext context, {required Enum authType}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ReImage(
        authType == AuthMode.register
            ? 'assets/images/register.png'
            : authType == AuthMode.login
                ? 'assets/images/login.png'
                : 'assets/images/login.png',
        width: authType == AuthMode.login || authType == AuthMode.otpCode
            ? 160
            : 170,
        height: 160,
        fit: BoxFit.fitWidth,
      ),
      const Spacer(),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              context.back();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16, top: 24),
              decoration: BoxDecoration(
                  border: Border.all(color: const Color(0x23232b1a)),
                  borderRadius: BorderRadius.circular(100)),
              child: const Icon(
                Icons.arrow_forward,
                size: 18,
                color: AppColors.gray,
              ).hMargin(15).vMargin(15),
            ),
          ),
          ReText(
            authType == AuthMode.register
                ? 'ثبت نام'
                : authType == AuthMode.login
                    ? 'ورود به حساب'
                    : 'کد تایید',
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
          ReText(
            authType == AuthMode.register
                ? 'یک حساب ایجاد کنید.'
                : authType == AuthMode.login
                    ? 'به حساب کاربری خود وارد شوید.'
                    : 'کد تایید ارسال شده را وارد کنید.',
            fontSize: 13,
            color: AppColors.gray,
            fontWeight: FontWeight.w600,
          ).tMargin(2)
        ],
      ),
    ],
  );
}
