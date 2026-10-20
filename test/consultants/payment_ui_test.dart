import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/counseling_checkout.dart';
import 'package:simo_learn/presentation/screens/consultants/invoice_sheet.dart';
import 'package:simo_learn/presentation/screens/consultants/payment_webview_screen.dart';
import 'package:simo_learn/presentation/screens/consultants/plans_sheet.dart';

void main() {
  group('classifyPaymentUrl', () {
    test('recognises the backend callback, GET or POST', () {
      expect(
        classifyPaymentUrl(
            'https://simo.raa-vi.ir/payments/counseling/callback/mellat'),
        PaymentPageKind.serverReturn,
      );
      expect(
        classifyPaymentUrl(
          'https://simo.raa-vi.ir/payments/counseling/callback/zarinpal?Authority=A1&Status=OK',
        ),
        PaymentPageKind.serverReturn,
      );
    });

    test('recognises the configured result page', () {
      expect(
        classifyPaymentUrl(
            'https://simo.example/payment-result?paymentStatus=SUCCEEDED'),
        PaymentPageKind.serverReturn,
      );
    });

    test('recognises the result page link back into the app', () {
      expect(
        classifyPaymentUrl('saimo://payment-result?attemptID=a1'),
        PaymentPageKind.appReturn,
      );
      expect(
        classifyPaymentUrl(
          'intent://payment-result#Intent;scheme=saimo;package=app.ravi.saimo;end',
        ),
        PaymentPageKind.appReturn,
      );
      expect(
        classifyPaymentUrl('intent://pay#Intent;scheme=otherbank;end'),
        PaymentPageKind.gateway,
      );
    });

    test('tells the Mellat launcher apart from the bank page', () {
      expect(
        classifyPaymentUrl(
          'https://simo.raa-vi.ir/payments/counseling/checkout/mellat/0b5c',
        ),
        PaymentPageKind.checkoutLauncher,
      );
      expect(
        classifyPaymentUrl(
            'https://bpm.shaparak.ir/pgwchannel/startpay.mellat'),
        PaymentPageKind.gateway,
      );
    });
  });

  group('invoice sheet', () {
    Future<Future<String?>> openSheet(
      WidgetTester tester, {
      required Future<String> Function() onConfirm,
      String? notice,
    }) async {
      late Future<String?> result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => result = showInvoiceSheet<String>(
                  context,
                  choice: ConsultationChoice(
                    plan: kPlans[1],
                    price: kPlans[1].prices[12]!,
                  ),
                  notice: notice,
                  onConfirm: onConfirm,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('stays open while preparing, then returns the result',
        (tester) async {
      final gate = Completer<String>();
      final result = await openSheet(tester, onConfirm: () => gate.future);

      await tester.tap(find.text('تایید و پرداخت'));
      await tester.pump();
      expect(find.text('صورتحساب'), findsOneWidget);

      gate.complete('gateway');
      await tester.pumpAndSettle();

      expect(await result, 'gateway');
      expect(find.text('صورتحساب'), findsNothing);
    });

    testWidgets('shows a failure inline and lets the student retry',
        (tester) async {
      var tries = 0;
      final result = await openSheet(
        tester,
        onConfirm: () async {
          if (tries++ == 0) {
            throw const GraphQLRawException(
              'counseling payment gateway is unavailable: timeout',
            );
          }
          return 'gateway';
        },
      );

      await tester.tap(find.text('تایید و پرداخت'));
      await tester.pumpAndSettle();

      expect(find.text('صورتحساب'), findsOneWidget);
      expect(find.textContaining('درگاه پرداخت در حال حاضر'), findsOneWidget);
      expect(find.textContaining('unavailable'), findsNothing);

      await tester.tap(find.text('تایید و پرداخت'));
      await tester.pumpAndSettle();

      expect(await result, 'gateway');
    });

    testWidgets('explains the previous try when reopened', (tester) async {
      await openSheet(
        tester,
        notice: kCheckoutCancelledMessage,
        onConfirm: () async => 'gateway',
      );

      expect(find.text(kCheckoutCancelledMessage), findsOneWidget);
      expect(find.text('پرداخت دوباره'), findsOneWidget);
    });
  });
}
