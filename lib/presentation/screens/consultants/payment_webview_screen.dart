// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// How a [PaymentWebViewScreen] session ended.
///
/// [completed] means the bank redirected back to the backend payment callback,
/// so the caller should verify the attempt. [cancelled] means the user closed
/// the gateway before it returned; the caller may still verify (the attempt
/// stays pending) but should treat it as "not completed".
enum PaymentWebViewResult { completed, cancelled }

/// Substring that identifies the backend payment callback URL. The bank
/// redirects here after the user finishes (or aborts) the transaction. It is
/// distinct from the Mellat checkout launcher (`/checkout/`) which is the
/// redirect URL itself, so matching the callback path is unambiguous.
const String _kCallbackPathMarker = '/payments/counseling/callback/';

/// Full-screen in-app browser for the counseling online-payment flow. Loads the
/// gateway [redirectURL] and pops [PaymentWebViewResult.completed] the moment
/// navigation reaches the backend callback; a manual close pops
/// [PaymentWebViewResult.cancelled].
class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen({super.key, required this.redirectURL});

  final String redirectURL;

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  // Guards against popping twice when both onNavigationRequest and
  // onPageStarted observe the callback URL.
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (_isCallbackUrl(request.url)) {
              _complete();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            if (_isCallbackUrl(url)) {
              _complete();
              return;
            }
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (url) {
            if (mounted && !_finished) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectURL));
  }

  bool _isCallbackUrl(String url) => url.contains(_kCallbackPathMarker);

  void _complete() {
    if (_finished) return;
    _finished = true;
    if (mounted) Navigator.of(context).pop(PaymentWebViewResult.completed);
  }

  void _cancel() {
    if (_finished) return;
    _finished = true;
    if (mounted) Navigator.of(context).pop(PaymentWebViewResult.cancelled);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _cancel();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Stack(
                  children: [
                    WebViewWidget(controller: _controller),
                    if (_loading)
                      const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: _cancel,
            icon: const Icon(
              Icons.close_rounded,
              size: 22,
              color: AppColors.black1,
            ),
          ),
          const Spacer(),
          const ReText(
            'پرداخت آنلاین',
            color: AppColors.black1,
            fontSize: 16,
            fontWeight: 1000,
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
}
