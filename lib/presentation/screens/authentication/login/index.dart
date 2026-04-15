import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/screens/authentication/register/index.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_text_field.dart';
import 'package:simo_learn/utils/_utils.dart';

import '../widgets/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();

  double _rf(double size) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = ((width / 375).clamp(0.85, 1.0)) * 0.92;
    return size * scale;
  }

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
                        authHeaderWidget(context, authType: AuthMode.login),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(40)),
                          child: Column(
                            children: [
                              ReTextField(
                                onChanged: (p0) {
                                  setState(() {});
                                },
                                controller: phoneController,
                                placeholderAlign: TextAlign.right,
                                backgroundColor: AppColors.gray1,
                                placeholder: 'شماره تماس',
                                fontSize: _rf(15),
                                maxLength: 11,
                                keyboardType: TextInputType.number,
                                suffixIcon: Container(
                                    margin: const EdgeInsets.only(
                                        top: 15, left: 15),
                                    child: ReText(
                                      '98+',
                                      color: AppColors.black1,
                                      fontSize: _rf(12),
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                              ReButton(
                                isEnabled: phoneController.text.length == 11,
                                onPressed: () {
                                  context.to(const RegisterScreen());
                                },
                                fontSize: _rf(15),
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
                                fontSize: _rf(15),
                                text: 'ثبت نام',
                              ).tMargin(8),
                            ],
                          ).hMargin(16).vMargin(18),
                        )
                      ],
                    ).tMargin(130),
                    ReText(
                      'سایمو لرن',
                      color: AppColors.black1,
                      fontSize: _rf(12),
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
