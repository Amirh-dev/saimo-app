import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:simo_learn/features/auth/cubit/auth_cubit.dart';
import 'package:simo_learn/presentation/screens/authentication/register/index.dart';
import 'package:simo_learn/presentation/screens/authentication/widgets/auth_header.dart';
import 'package:simo_learn/presentation/screens/goals/index.dart';
import 'package:simo_learn/presentation/widgets/re_button.dart';
import 'package:simo_learn/presentation/widgets/re_toast.dart';
import 'package:simo_learn/utils/_utils.dart';
import '../../../widgets/re_text.dart';

class OTPCodeScreen extends StatefulWidget {
  const OTPCodeScreen({
    super.key,
    required this.phoneNumber,
    required this.isRegistered,
  });

  final String phoneNumber;
  final bool isRegistered;

  @override
  State<OTPCodeScreen> createState() => _OTPCodeScreenState();
}

class _OTPCodeScreenState extends State<OTPCodeScreen> {
  final TextEditingController codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (!_isCurrentRoute(context)) return;

        if (state is AuthAuthenticated && state.action == AuthAction.login) {
          showReToast(
            context,
            'ورود با موفقیت انجام شد',
            ReToastType.success,
          );
          context.toOffAll(const GoalScreen());
        } else if (state is AuthNeedsRegistration) {
          context.to(
            RegisterScreen(
              phoneNumber: state.phoneNumber,
              code: state.code,
              completeProfileOnly: state.completeProfileOnly,
            ),
          );
        } else if (state is AuthFailure &&
            (state.action == AuthAction.login ||
                state.action == AuthAction.verifyOtp)) {
          showReToast(context, state.message, ReToastType.failed);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading &&
            (state.action == AuthAction.login ||
                state.action == AuthAction.verifyOtp);

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
                            authHeaderWidget(
                              context,
                              authType: AuthMode.otpCode,
                            ).tMargin(130),
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
                                    enabled: !isLoading,
                                    focusNode: _focusNode,
                                    onChanged: (_) => setState(() {}),
                                    onCompleted: (_) => _submitCode(),
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
                                          color: const Color(0xFFd0d0d0),
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
                                    isLoading: isLoading,
                                    isEnabled: codeController.text.length == 5,
                                    onPressed: _submitCode,
                                    text: 'ورود',
                                  ).tMargin(24),
                                  ReButton(
                                    isOutlined: true,
                                    color: AppColors.gray2,
                                    textColor: AppColors.black1,
                                    background: AppColors.white,
                                    onPressed: () {
                                      context
                                          .read<AuthCubit>()
                                          .sendOtp(widget.phoneNumber);
                                    },
                                    text: 'ارسال مجدد کد',
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
      },
    );
  }

  void _submitCode() {
    final state = context.read<AuthCubit>().state;
    if (state is AuthLoading &&
        (state.action == AuthAction.login ||
            state.action == AuthAction.verifyOtp)) {
      return;
    }

    final code = _normalizeDigits(codeController.text);
    if (code.length != 5) return;

    context.read<AuthCubit>().verifyOtpForNextStep(
          phoneNumber: widget.phoneNumber,
          code: code,
          isRegistered: widget.isRegistered,
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

  bool _isCurrentRoute(BuildContext context) {
    return ModalRoute.of(context)?.isCurrent ?? false;
  }
}
