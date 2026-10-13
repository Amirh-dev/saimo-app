import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:simo_learn/features/auth/cubit/auth_cubit.dart';
import 'package:simo_learn/presentation/screens/authentication/widgets/auth_header.dart';
import 'package:simo_learn/presentation/widgets/re_button.dart';
import 'package:simo_learn/presentation/widgets/re_text_field.dart';
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

  /// Counts down the server's wait between codes; the resend button opens
  /// when it reaches zero.
  Timer? _ticker;
  Duration _resendWait = Duration.zero;

  /// True from a resend tap until its answer, so only that answer is shown.
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    _ticker?.cancel();
    _resendWait = context.read<AuthCubit>().otpResendWait;
    if (_resendWait == Duration.zero) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final wait = context.read<AuthCubit>().otpResendWait;
      setState(() => _resendWait = wait);
      if (wait == Duration.zero) _ticker?.cancel();
    });
  }

  void _resendCode() {
    if (_resendWait > Duration.zero || _resending) return;
    _resending = true;
    context.read<AuthCubit>().sendOtp(widget.phoneNumber);
  }

  void _onAuthState(BuildContext context, AuthState state) {
    if (!_isCurrentRoute(context)) return;

    if (_resending && state is OtpSent) {
      _resending = false;
      codeController.clear();
      _focusNode.requestFocus();
      _startResendCountdown();
      showReToast(context, 'کد جدید ارسال شد', ReToastType.success);
      return;
    }
    if (state is AuthFailure &&
        (state.action == AuthAction.login ||
            state.action == AuthAction.verifyOtp ||
            (_resending && state.action == AuthAction.sendOtp))) {
      _resending = false;
      showReToast(context, state.message, ReToastType.failed);
    }
  }

  /// "ارسال مجدد کد"، and while waiting the time left, e.g. "(۰:۴۵)".
  String get _resendLabel {
    if (_resendWait == Duration.zero) return 'ارسال مجدد کد';
    // Rounded up, so it never shows 0:00 while still waiting.
    final seconds = (_resendWait.inMilliseconds + 999) ~/ 1000;
    final clock =
        '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    return 'ارسال مجدد کد (${convertToPersianNumbers(clock)})';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: _onAuthState,
      builder: (context, state) {
        final isLoading = state is AuthLoading &&
            (state.action == AuthAction.login ||
                state.action == AuthAction.verifyOtp);
        final isResending =
            state is AuthLoading && state.action == AuthAction.sendOtp;

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
                              backButton: true,
                              onBack: () {
                                context.read<AuthCubit>().logout();
                              },
                            ).tMargin(130),
                            Container(
                              height: 230,
                              margin: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(40)),
                              child: Column(
                                children: [
                                  Pinput.builder(
                                    controller: codeController,
                                    length: 5,
                                    autofocus: true,
                                    keyboardType: TextInputType.number,
                                    // Only filter here: rewriting the typed
                                    // digit (e.g. to Persian) pushes a changed
                                    // value back to the IME, which makes some
                                    // Android keyboards close after the first
                                    // digit. Persian digits are display-only.
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9۰-۹٠-٩]'),
                                      ),
                                    ],
                                    enabled: !isLoading,
                                    focusNode: _focusNode,
                                    onChanged: (_) => setState(() {}),
                                    onCompleted: (_) => _submitCode(),
                                    builder: (context, pin) =>
                                        _buildPinItem(pin),
                                  ).sizedBox(height: 52),
                                  ReButton(
                                    isLoading: isLoading,
                                    isEnabled: codeController.text.length == 5,
                                    onPressed: _submitCode,
                                    // A new number goes on to the register
                                    // form, so it is not a log-in yet.
                                    text: widget.isRegistered ? 'ورود' : 'تایید',
                                  ).tMargin(24),
                                  ReButton(
                                    key: const ValueKey('otp-resend'),
                                    isOutlined: true,
                                    color: AppColors.gray2,
                                    // Grey while counting down: not tappable yet.
                                    textColor: _resendWait > Duration.zero
                                        ? AppColors.gray
                                        : AppColors.black1,
                                    background: AppColors.white,
                                    isLoading: isResending,
                                    isEnabled: _resendWait == Duration.zero &&
                                        !isLoading,
                                    onPressed: _resendCode,
                                    text: _resendLabel,
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

  Widget _buildPinItem(PinItemState pin) {
    final isFocused = pin.type == PinItemStateType.focused;
    final size = isFocused ? 55.0 : 50.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(12),
        border: isFocused
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(color: const Color(0xFFd0d0d0)),
        boxShadow: isFocused ? kFocusedFieldShadow : null,
      ),
      child: pin.value.isEmpty
          ? (isFocused
              ? const VerticalDivider(color: Colors.black).vMargin(15)
              : null)
          : Text(
              convertToPersianNumbers(pin.value),
              style: TextStyle(
                fontFamily: AppFonts.iranSansVar,
                fontSize: 18,
                fontVariations: AppFonts.fontVariations(
                  isFocused ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
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
