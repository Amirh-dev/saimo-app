// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// How a [PaymentWebViewScreen] session ended.
///
/// [completed] means the bank sent the student back to the backend payment
/// callback and the server has answered, so the caller should verify the
/// attempt. [cancelled] means the student closed the gateway before that.
enum PaymentWebViewResult { completed, cancelled }

/// What a URL loaded inside the payment WebView is.
enum PaymentPageKind {
  /// Our Mellat launcher page that auto-posts the RefId to the bank.
  checkoutLauncher,

  /// The backend callback (or the result page it redirects to). Reaching it
  /// means the bank has finished with the student.
  serverReturn,

  /// Anything else: the bank's own pages.
  gateway,
}

@visibleForTesting
PaymentPageKind classifyPaymentUrl(String url) {
  final uri = Uri.tryParse(url);
  final path = uri?.path ?? url;
  if (path.contains('/payments/counseling/callback/') ||
      (uri?.queryParameters.containsKey('paymentStatus') ?? false)) {
    return PaymentPageKind.serverReturn;
  }
  if (path.contains('/payments/counseling/checkout/')) {
    return PaymentPageKind.checkoutLauncher;
  }
  return PaymentPageKind.gateway;
}

/// Full-screen in-app browser for the counseling online payment.
///
/// The bank's return to the backend callback must be allowed to load: for
/// Mellat that POST carries the SaleReferenceId the server needs to verify
/// and settle the payment, so blocking it would leave a charged payment
/// unconfirmed. The screen covers the page with a "checking" panel while the
/// server answers, then pops [PaymentWebViewResult.completed].
class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen({super.key, required this.redirectURL});

  final String redirectURL;

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

enum _Phase { loading, ready, returning, error }

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  /// Upper bound on waiting for the server's callback page; the caller
  /// verifies the payment itself afterwards anyway.
  static const Duration _returnTimeout = Duration(seconds: 30);

  late final WebViewController _controller;
  _Phase _phase = _Phase.loading;
  int _progress = 0;
  String _host = '';
  String _errorMessage = '';
  Timer? _returnTimer;

  // Guards against popping twice.
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          // iOS reports the bank's callback POST here; Android does not
          // report POSTs, so onPageStarted covers it there.
          onNavigationRequest: (request) {
            if (request.isMainFrame &&
                classifyPaymentUrl(request.url) ==
                    PaymentPageKind.serverReturn) {
              _beginReturn();
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            if (classifyPaymentUrl(url) == PaymentPageKind.serverReturn) {
              _beginReturn();
              return;
            }
            if (_phase == _Phase.returning || !mounted) return;
            setState(() {
              _host = Uri.tryParse(url)?.host ?? '';
              if (_phase != _Phase.ready) _phase = _Phase.loading;
            });
          },
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onPageFinished: (url) {
            if (_phase == _Phase.returning) {
              _complete();
              return;
            }
            if (!mounted || _phase == _Phase.error) return;
            // The launcher only auto-posts to the bank, so keep the spinner
            // up until the bank page itself has loaded.
            if (classifyPaymentUrl(url) == PaymentPageKind.checkoutLauncher) {
              return;
            }
            setState(() => _phase = _Phase.ready);
          },
          onHttpError: (error) {
            final url = error.request?.uri.toString() ?? '';
            if (_phase == _Phase.returning || url.isEmpty) return;
            // The launcher answers 4xx once the attempt has expired or was
            // already used; the bank page is gone with it.
            if (classifyPaymentUrl(url) == PaymentPageKind.checkoutLauncher) {
              _showError(
                'مهلت این پرداخت به پایان رسیده است. لطفاً این صفحه را ببندید و دوباره پرداخت کنید.',
              );
            }
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == false) return;
            if (_phase == _Phase.returning) {
              // The server may still have processed the callback; the
              // caller verifies.
              _complete();
              return;
            }
            _showError(
              'صفحه پرداخت باز نشد. اتصال اینترنت خود را بررسی کنید و دوباره تلاش کنید.',
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectURL));
  }

  @override
  void dispose() {
    _returnTimer?.cancel();
    super.dispose();
  }

  void _beginReturn() {
    if (_finished || _phase == _Phase.returning) return;
    _returnTimer = Timer(_returnTimeout, _complete);
    if (mounted) setState(() => _phase = _Phase.returning);
  }

  void _showError(String message) {
    if (_finished || !mounted) return;
    setState(() {
      _phase = _Phase.error;
      _errorMessage = message;
    });
  }

  void _retry() {
    setState(() {
      _phase = _Phase.loading;
      _progress = 0;
    });
    _controller.loadRequest(Uri.parse(widget.redirectURL));
  }

  void _complete() {
    if (_finished) return;
    _finished = true;
    _returnTimer?.cancel();
    if (mounted) Navigator.of(context).pop(PaymentWebViewResult.completed);
  }

  void _cancel() {
    if (_finished) return;
    _finished = true;
    _returnTimer?.cancel();
    if (mounted) Navigator.of(context).pop(PaymentWebViewResult.cancelled);
  }

  /// Leaving mid-payment loses what the student typed on the bank page
  /// (card details, the one-time password), so ask first once the bank page
  /// is up. While the server is confirming, leaving is not offered at all.
  Future<void> _requestClose() async {
    if (_phase == _Phase.returning) return;
    if (_phase != _Phase.ready) {
      _cancel();
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => const _LeavePaymentDialog(),
    );
    if (leave == true) _cancel();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _requestClose();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              SizedBox(
                height: 2,
                child: (_phase == _Phase.loading || _phase == _Phase.ready) &&
                        _progress < 100
                    ? LinearProgressIndicator(
                        value: _progress == 0 ? null : _progress / 100,
                        backgroundColor: AppColors.gray2,
                        color: AppColors.primary,
                        minHeight: 2,
                      )
                    : null,
              ),
              Expanded(
                child: Stack(
                  children: [
                    WebViewWidget(controller: _controller),
                    if (_phase == _Phase.loading)
                      const _StatusPanel(
                        title: 'در حال اتصال به درگاه بانک',
                        subtitle: 'چند لحظه صبر کنید…',
                      ),
                    if (_phase == _Phase.returning)
                      const _StatusPanel(
                        title: 'در حال بررسی پرداخت',
                        subtitle: 'لطفاً تا پایان بررسی، برنامه را نبندید.',
                      ),
                    if (_phase == _Phase.error) _buildError(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final showHost = _host.isNotEmpty && _phase != _Phase.returning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.white,
      child: Row(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _phase == _Phase.returning ? 0 : 1,
            child: IconButton(
              tooltip: 'بستن',
              onPressed: _phase == _Phase.returning ? null : _requestClose,
              icon: const Icon(
                Icons.close_rounded,
                size: 22,
                color: AppColors.black1,
              ),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const ReText(
                'پرداخت امن',
                color: AppColors.black1,
                fontSize: 16,
                fontWeight: 1000,
              ),
              if (showHost)
                ReText(
                  _host,
                  color: AppColors.gray,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  textDirection: TextDirection.ltr,
                ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: AppColors.done,
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Positioned.fill(
      child: ColoredBox(
        color: AppColors.white,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.gray1,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    SolarIconsOutline.dangerCircle,
                    size: 26,
                    color: AppColors.black1,
                  ),
                ),
                const SizedBox(height: 16),
                ReText(
                  _errorMessage,
                  maxLines: 4,
                  color: AppColors.black1,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ReButton(
                  text: 'تلاش دوباره',
                  background: AppColors.primary,
                  borderRadius: 40,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  onPressed: _retry,
                ),
                const SizedBox(height: 8),
                ReButton(
                  text: 'بستن',
                  isOutlined: true,
                  color: AppColors.gray2,
                  textColor: AppColors.black1,
                  borderRadius: 40,
                  fontSize: 15,
                  onPressed: _cancel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: AppColors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.black1,
              ),
            ),
            const SizedBox(height: 20),
            ReText(
              title,
              color: AppColors.black1,
              fontSize: 15,
              fontWeight: 900,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            ReText(
              subtitle,
              maxLines: 3,
              color: AppColors.gray,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LeavePaymentDialog extends StatelessWidget {
  const _LeavePaymentDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ReText(
                'از پرداخت خارج می‌شوید؟',
                color: AppColors.black1,
                fontSize: 16,
                fontWeight: 1000,
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 8),
              const ReText(
                'اگر هنوز پرداخت را تکمیل نکرده‌اید، مبلغی از حساب شما کسر نمی‌شود و می‌توانید بعداً دوباره پرداخت کنید.',
                maxLines: 4,
                color: AppColors.gray,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 20),
              ReButton(
                text: 'ادامه پرداخت',
                background: AppColors.primary,
                borderRadius: 40,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                onPressed: () => Navigator.of(context).pop(false),
              ),
              const SizedBox(height: 8),
              ReButton(
                text: 'خروج از پرداخت',
                isOutlined: true,
                color: AppColors.gray2,
                textColor: AppColors.black1,
                borderRadius: 40,
                fontSize: 15,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
