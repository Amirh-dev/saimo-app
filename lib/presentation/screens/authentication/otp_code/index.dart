import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:simo_learn/presentation/screens/app_navigation_tabs.dart';
import 'package:simo_learn/presentation/screens/authentication/widgets/auth_header.dart';
import 'package:simo_learn/presentation/screens/goals/index.dart';
import 'package:simo_learn/presentation/screens/profile/index.dart';
import 'package:simo_learn/presentation/widgets/re_button.dart';
import 'package:simo_learn/utils/_utils.dart';
import '../../../widgets/re_text.dart';

class OTPCodeScreen extends StatelessWidget {
  OTPCodeScreen({super.key});
  final TextEditingController codeController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray1,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        authHeaderWidget(context, authType: AuthMode.otpCode)
                            .tMargin(130),
                        Container(
                          height: 230,
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(40)),
                          child: Column(
                            children: [
                              Pinput(
                                controller: codeController,
                                length: 5,
                                autofocus: true,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9۰-۹٠-٩]'),
                                  ),
                                  const PersianDigitsInputFormatter(),
                                ],
                                enabled: true,
                                focusNode: _focusNode,
                                onCompleted: (otp) => (value) {
                                  context.to(const ProfileScreen());
                                },
                                cursor: const VerticalDivider(
                                  color: Colors.black,
                                ).vMargin(15),
                                defaultPinTheme: PinTheme(
                                  height: 50,
                                  width: 50,
                                  textStyle: TextStyle(
                                    fontFamily: AppFonts.iranSansVar,
                                    fontSize: 18,
                                    fontVariations: AppFonts.fontVariations(
                                      FontWeight.w600,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF6F6F6),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(
                                          0xFFd0d0d0), // light gray border
                                    ),
                                  ),
                                ),
                                focusedPinTheme: PinTheme(
                                  height: 55,
                                  width: 55,
                                  textStyle: TextStyle(
                                    fontFamily: AppFonts.iranSansVar,
                                    fontSize: 18,
                                    fontVariations: AppFonts.fontVariations(
                                      FontWeight.w800,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF6F6F6),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ).sizedBox(height: 52),
                              ReButton(
                                onPressed: () {
                                  context.to(const GoalScreen());
                                },
                                text: 'ورود',
                              ).tMargin(24),
                              ReButton(
                                isOutlined: true,
                                color: AppColors.gray2,
                                textColor: AppColors.black1,
                                background: AppColors.white,
                                onPressed: () {},
                                text: 'ارسل مجدد کد',
                              ).tMargin(8),
                            ],
                          ).hMargin(16).vMargin(18),
                        )
                      ],
                    ),
                    const ReText(
                      'سایمو لرن',
                      color: AppColors.black1,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ).bMargin(10)
                  ],
                ).hMargin(30),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
