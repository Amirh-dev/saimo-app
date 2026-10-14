import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/screens/consultants/payment_tab.dart';
import 'package:simo_learn/presentation/screens/consultants/payment_tab_screen.dart';
import 'package:simo_learn/presentation/screens/consultants/payment_webview_screen.dart';

import '../tasks/support/app_fonts.dart';

class _FakeTab implements PaymentTab {
  final List<String> visited = [];
  bool closed = false;

  @override
  bool get isClosed => closed;

  @override
  void navigate(String url) => visited.add(url);

  @override
  void close() => closed = true;
}

const _url = 'https://simo.raa-vi.ir/payments/counseling/checkout/mellat/a1';

void main() {
  setUpAll(loadAppFonts);

  Future<Future<PaymentWebViewResult?>> open(
    WidgetTester tester, {
    required Future<String> Function() checkStatus,
    PaymentTab? tab,
    PaymentTab? Function([String url])? openTab,
  }) async {
    late Future<PaymentWebViewResult?> result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  result = Navigator.of(context).push<PaymentWebViewResult>(
                MaterialPageRoute(
                  builder: (_) => PaymentTabScreen(
                    redirectURL: _url,
                    tab: tab,
                    checkStatus: checkStatus,
                    openTab: openTab ?? ([String url = '']) => null,
                    pollInterval: const Duration(seconds: 1),
                  ),
                ),
              ),
              child: const Text('pay'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('pay'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    return result;
  }

  testWidgets('sends the pre-opened tab to the gateway and waits for the bank',
      (tester) async {
    final tab = _FakeTab();
    var status = 'PENDING';
    final result =
        await open(tester, tab: tab, checkStatus: () async => status);

    expect(tab.visited, [_url]);
    expect(find.text('در انتظار پرداخت…'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    expect(find.text('پرداخت در صفحه جدید'), findsOneWidget);

    status = 'SUCCEEDED';
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(await result, PaymentWebViewResult.completed);
    expect(tab.closed, isTrue);
  });

  testWidgets('offers a button when the browser blocked the tab',
      (tester) async {
    final opened = <String>[];
    final tab = _FakeTab();
    var blocked = true;
    await open(
      tester,
      checkStatus: () async => 'PENDING',
      openTab: ([String url = '']) {
        opened.add(url);
        return blocked ? null : tab;
      },
    );

    expect(find.text('صفحه پرداخت باز نشد'), findsOneWidget);

    blocked = false;
    await tester.tap(find.text('رفتن به درگاه پرداخت'));
    await tester.pump();

    expect(opened, [_url, _url]);
    expect(find.text('پرداخت در صفحه جدید'), findsOneWidget);
  });

  testWidgets('cancelling closes the bank tab', (tester) async {
    final tab = _FakeTab();
    final result = await open(
      tester,
      tab: tab,
      checkStatus: () async => 'PENDING',
    );

    await tester.tap(find.text('انصراف از پرداخت'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(await result, PaymentWebViewResult.cancelled);
    expect(tab.closed, isTrue);
  });

  testWidgets('keeps polling through network errors', (tester) async {
    var calls = 0;
    final result = await open(
      tester,
      tab: _FakeTab(),
      checkStatus: () async {
        if (++calls < 3) throw Exception('offline');
        return 'FAILED';
      },
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(await result, PaymentWebViewResult.completed);
  });
}
