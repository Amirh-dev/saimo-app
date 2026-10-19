// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/screens/consultants/payment_tab.dart';
import 'package:simo_learn/presentation/screens/consultants/payment_webview_screen.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

/// Web counterpart of [PaymentWebViewScreen]. The bank gateway runs in its
/// own browser tab (bank pages refuse to be framed); the bank's return goes
/// straight from that tab to the backend callback, which verifies and
/// settles the payment. This screen waits meanwhile, polling the attempt's
/// stored status, and pops [PaymentWebViewResult.completed] once the server
/// has settled it, or [PaymentWebViewResult.cancelled] if the student gives
/// up.
class PaymentTabScreen extends StatefulWidget {
  const PaymentTabScreen({
    super.key,
    required this.redirectURL,
    required this.checkStatus,
    this.tab,
    this.openTab = openPaymentTab,
    this.pollInterval = const Duration(seconds: 3),
  });

  final String redirectURL;

  /// Returns the attempt's stored status (PENDING until the bank returns).
  final Future<String> Function() checkStatus;

  /// A tab opened inside the confirm tap (so the browser did not block it)
  /// and already sent to the gateway by the caller. When null, the screen
  /// opens one itself.
  final PaymentTab? tab;

  final PaymentTab? Function([String url]) openTab;
  final Duration pollInterval;

  @override
  State<PaymentTabScreen> createState() => _PaymentTabScreenState();
}

class _PaymentTabScreenState extends State<PaymentTabScreen> {
  PaymentTab? _tab;
  bool _blocked = false;
  Timer? _timer;
  AppLifecycleListener? _lifecycle;
  bool _checking = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    // The caller already sent a given tab to the gateway. Sending it again
    // would reload the bank page, and Mellat refuses a RefId posted twice.
    _tab = widget.tab;
    if (_tab == null) {
      // Outside a tap the browser usually blocks this; the button below then
      // opens it with a fresh tap.
      _tab = widget.openTab(widget.redirectURL);
      _blocked = _tab == null;
    }
    _timer = Timer.periodic(widget.pollInterval, (_) => _poll());
    // Coming back to this tab after paying: check right away.
    _lifecycle = AppLifecycleListener(onResume: _poll);
    unawaited(_poll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycle?.dispose();
    super.dispose();
  }

  Future<void> _poll() async {
    if (_checking || _finished) return;
    _checking = true;
    try {
      final status = await widget.checkStatus();
      if (status != 'PENDING') _finish(PaymentWebViewResult.completed);
    } catch (_) {
      // Network hiccup: the next tick tries again.
    } finally {
      _checking = false;
    }
  }

  void _openGateway() {
    final tab = _tab;
    if (tab != null && !tab.isClosed) {
      tab.navigate(widget.redirectURL);
    } else {
      _tab = widget.openTab(widget.redirectURL);
    }
    setState(() => _blocked = _tab == null);
  }

  void _finish(PaymentWebViewResult result) {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    _tab?.close();
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _finish(PaymentWebViewResult.cancelled);
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.gray1,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          SolarIconsOutline.card,
                          size: 28,
                          color: AppColors.black1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ReText(
                        _blocked
                            ? 'صفحه پرداخت باز نشد'
                            : 'پرداخت در صفحه جدید',
                        color: AppColors.black1,
                        fontSize: 17,
                        fontWeight: 1000,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ReText(
                        _blocked
                            ? 'مرورگر باز شدن صفحه پرداخت را متوقف کرد. برای رفتن به درگاه بانک، روی دکمه زیر بزنید.'
                            : 'درگاه بانک در یک زبانه جدید باز شد. پس از پایان پرداخت به همین صفحه برگردید؛ نتیجه به‌طور خودکار بررسی می‌شود.',
                        color: AppColors.gray,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.center,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 24),
                      if (!_blocked) ...[
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.black1,
                              ),
                            ),
                            SizedBox(width: 8),
                            ReText(
                              'در انتظار پرداخت…',
                              color: AppColors.black1,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                      ReButton(
                        text: _blocked
                            ? 'رفتن به درگاه پرداخت'
                            : 'باز کردن دوباره درگاه',
                        icon: Icons.open_in_new_rounded,
                        reverseIconPosition: true,
                        background:
                            _blocked ? AppColors.primary : AppColors.black1,
                        borderRadius: 40,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        onPressed: _openGateway,
                      ),
                      const SizedBox(height: 8),
                      ReButton(
                        text: 'انصراف از پرداخت',
                        isOutlined: true,
                        color: AppColors.gray2,
                        textColor: AppColors.black1,
                        borderRadius: 40,
                        fontSize: 15,
                        onPressed: () =>
                            _finish(PaymentWebViewResult.cancelled),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
