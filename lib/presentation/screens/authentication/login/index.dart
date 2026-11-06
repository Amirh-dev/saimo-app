import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:simo_learn/features/auth/cubit/auth_cubit.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  String _version = '0.0.0';

  @override
  void initState() {
    _loadVersion();
    super.initState();
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (!mounted) return;

    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure && state.action == AuthAction.sendOtp) {
          showReToast(context, state.message, ReToastType.failed);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is AuthLoading && state.action == AuthAction.sendOtp;

        return Scaffold(
          backgroundColor: AppColors.gray1,
          body: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      // Tall phones keep the small-phone spacing, so the
                      // version and credit stay close under the form.
                      constraints: BoxConstraints(
                        minHeight: math.min(constraints.maxHeight, 667),
                      ),
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
                                        // Keep the suffix a constant size so the
                                        // field height never changes; only fade
                                        // the sample hint out once typing starts.
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(left: 15),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: 1,
                                            child: Opacity(
                                              opacity:
                                                  phoneController.text.isEmpty
                                                      ? 1
                                                      : 0,
                                              child: const ReText(
                                                '******* 0912',
                                                isPersian: true,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.gray,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      ReButton(
                                        isEnabled:
                                            phoneController.text.length == 11,
                                        isLoading: isLoading,
                                        onPressed: _sendOtp,
                                        fontSize: 16,
                                        text: 'ورود / ثبت نام',
                                      ).tMargin(16),
                                      const LoginTermsNotice().tMargin(14),
                                      // ReButton(
                                      //   isOutlined: true,
                                      //   color: AppColors.gray2,
                                      //   textColor: AppColors.black1,
                                      //   background: AppColors.white,
                                      //   isEnabled: !isLoading,
                                      //   onPressed: _startRegistration,
                                      //   fontSize: 16,
                                      //   text: 'ثبت نام',
                                      // ).tMargin(8),
                                    ],
                                  ).hMargin(16).vMargin(18),
                                )
                              ],
                            ).tMargin(130),
                            Column(
                              children: [
                                ReText(
                                  'نسخه $_version',
                                  color: AppColors.gray,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                const SizedBox(height: 2),
                                const MadeByCredit(),
                              ],
                            ).bMargin(6)
                          ],
                        ).hMargin(30),
                      ),
                    ),
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

  void _sendOtp() {
    debugPrint(_normalizeDigits(phoneController.text));
    context.read<AuthCubit>().sendOtp(
          _normalizeDigits(phoneController.text),
        );
  }

}

const String kTermsUrl = 'https://saimo.app/privacy';

/// Signing in counts as accepting the terms; the link opens them in the
/// browser.
class LoginTermsNotice extends StatefulWidget {
  const LoginTermsNotice({super.key});

  @override
  State<LoginTermsNotice> createState() => _LoginTermsNoticeState();
}

class _LoginTermsNoticeState extends State<LoginTermsNotice> {
  late final TapGestureRecognizer _openTerms = TapGestureRecognizer()
    ..onTap = _launchTerms;

  @override
  void dispose() {
    _openTerms.dispose();
    super.dispose();
  }

  Future<void> _launchTerms() async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(kTermsUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) {
      showReToast(context, 'باز کردن قوانین و مقررات ممکن نشد',
          ReToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: AppFonts.iranSansVar,
      fontSize: 12,
      height: 1.8,
      color: AppColors.gray,
      fontVariations: AppFonts.fontVariations(FontWeight.w500),
    );
    return Text.rich(
      key: const ValueKey('login-terms'),
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      TextSpan(
        style: style,
        children: [
          const TextSpan(text: 'ورود شما به معنای موافقت با '),
          TextSpan(
            text: 'قوانین و مقررات سایمو',
            recognizer: _openTerms,
            mouseCursor: SystemMouseCursors.click,
            style: style.copyWith(
              color: AppColors.black1,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.black1,
              fontVariations: AppFonts.fontVariations(FontWeight.w700),
            ),
          ),
          const TextSpan(text: ' است.'),
        ],
      ),
    );
  }
}
