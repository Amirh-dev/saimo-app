import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/screens/authentication/register/index.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_text_field.dart';
import 'package:simo_learn/utils/_utils.dart';

import '../widgets/auth_header.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray1,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              authHeaderWidget(context, authType: AuthMode.login),
              Container(
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(40)),
                child: Column(
                  children: [
                    ReTextField(
                      backgroundColor: AppColors.gray1,
                      placeholder: 'شماره تماس',
                      maxLength: 11,
                      keyboardType: TextInputType.number,
                      suffixIcon: Container(
                          margin: const EdgeInsets.only(top: 15, left: 15),
                          child: const ReText(
                            '98+',
                            color: AppColors.black1,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                    ReButton(
                      onPressed: () {
                        context.to(const RegisterScreen());
                      },
                      text: 'ورود',
                    ).tMargin(24),
                    ReButton(
                      isOutlined: true,
                      color: AppColors.gray2,
                      textColor: AppColors.black1,
                      background: AppColors.white,
                      onPressed: () {
                        context.to(const RegisterScreen());
                      },
                      text: 'ثبت نام',
                    ).tMargin(8),
                  ],
                ).hMargin(16).vMargin(18),
              )
            ],
          ).tMargin(160),
          const ReText(
            'سایمو لرن',
            color: AppColors.black1,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ).bMargin(32)
        ],
      ).hMargin(45),
    );
  }
}
