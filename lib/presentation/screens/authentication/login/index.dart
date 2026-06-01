import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/features/auth/cubit/auth_cubit.dart';
import 'package:simo_learn/presentation/screens/authentication/otp_code/index.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';

import '../widgets/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is OtpSent) {
          context.to(
            OTPCodeScreen(
              phoneNumber: state.phoneNumber,
              isRegistered: state.isRegistered,
            ),
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

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
                                    fontWeight: FontWeight.w600,
                                    borderRadius: 100,
                                    onChanged: (p0) {
                                      setState(() {});
                                    },
                                    controller: phoneController,
                                    placeholderAlign: TextAlign.right,
                                    backgroundColor: AppColors.gray1,
                                    placeholder: 'شماره تماس',
                                    fontSize: 13,
                                    maxLength: 11,
                                    keyboardType: TextInputType.number,
                                    suffixIcon: const Padding(
                                      padding: EdgeInsets.only(left: 15),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: 1,
                                        child: ReText(
                                          '98+',
                                          isPersian: true,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.black1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ReButton(
                                    isEnabled:
                                        phoneController.text.length == 11,
                                    isLoading: isLoading,
                                    onPressed: () {
                                      context.read<AuthCubit>().sendOtp(
                                            _normalizeDigits(
                                              phoneController.text,
                                            ),
                                          );
                                    },
                                    fontSize: 16,
                                    text: 'ورود',
                                  ).tMargin(16),
                                  ReButton(
                                    isOutlined: true,
                                    color: AppColors.gray2,
                                    textColor: AppColors.black1,
                                    background: AppColors.white,
                                    isEnabled:
                                        phoneController.text.length == 11,
                                    onPressed: () {
                                      context.read<AuthCubit>().sendOtp(
                                            _normalizeDigits(
                                              phoneController.text,
                                            ),
                                          );
                                    },
                                    fontSize: 16,
                                    text: 'ثبت نام',
                                  ).tMargin(8),
                                ],
                              ).hMargin(16).vMargin(18),
                            )
                          ],
                        ).tMargin(130),
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
      },
    );
  }

  String _normalizeDigits(String value) {
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    var result = value;
    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(persian[i], '$i').replaceAll(arabic[i], '$i');
    }
    return result;
  }
}
