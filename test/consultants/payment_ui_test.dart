import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_repository.dart';
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
      required Future<String> Function(DiscountPreview? discount) onConfirm,
      Future<DiscountPreview> Function(String code)? checkDiscount,
      String? notice,
    }) async {
      // Wide like the default test view (the test font is wider than
      // IRANSans), tall enough for the code breakdown.
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
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
                  checkDiscount: checkDiscount,
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
      final result = await openSheet(tester, onConfirm: (_) => gate.future);

      await tester.tap(find.text('تأیید و پرداخت'));
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
        onConfirm: (_) async {
          if (tries++ == 0) {
            throw const GraphQLRawException(
              'counseling payment gateway is unavailable: timeout',
            );
          }
          return 'gateway';
        },
      );

      await tester.tap(find.text('تأیید و پرداخت'));
      await tester.pumpAndSettle();

      expect(find.text('صورتحساب'), findsOneWidget);
      expect(find.textContaining('درگاه پرداخت فعلاً'), findsOneWidget);
      expect(find.textContaining('unavailable'), findsNothing);

      await tester.tap(find.text('تأیید و پرداخت'));
      await tester.pumpAndSettle();

      expect(await result, 'gateway');
    });

    testWidgets('explains the previous try when reopened', (tester) async {
      await openSheet(
        tester,
        notice: kCheckoutCancelledMessage,
        onConfirm: (_) async => 'gateway',
      );

      expect(find.text(kCheckoutCancelledMessage), findsOneWidget);
      expect(find.text('پرداخت دوباره'), findsOneWidget);
    });

    const valid = DiscountPreview(
      status: 'VALID',
      code: 'SAIMO20',
      listPrice: 19880000,
      discountAmount: 3976000,
      finalPrice: 15904000,
      percentOff: 20,
    );

    Future<void> enterCode(WidgetTester tester, String code) async {
      await tester.tap(find.text('کد تخفیف داری؟'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('discount-code-field')), code);
      await tester.pump();
      await tester.tap(find.text('اعمال'));
      await tester.pumpAndSettle();
    }

    testWidgets('hides the code entry when no checker is given',
        (tester) async {
      await openSheet(tester, onConfirm: (_) async => 'gateway');
      expect(find.text('کد تخفیف داری؟'), findsNothing);
    });

    testWidgets('applies a code, shows the breakdown and pays with it',
        (tester) async {
      final checked = <String>[];
      DiscountPreview? paidWith;
      final result = await openSheet(
        tester,
        checkDiscount: (code) async {
          checked.add(code);
          return valid;
        },
        onConfirm: (discount) async {
          paidWith = discount;
          return 'gateway';
        },
      );

      await enterCode(tester, 'saimo۲۰');

      expect(checked, ['SAIMO20']);
      expect(find.text('اعمال شد'), findsOneWidget);
      expect(find.text('مبلغ قابل پرداخت'), findsOneWidget);
      expect(find.text('۳,۹۷۶,۰۰۰-'), findsOneWidget);
      expect(find.text('قیمت پلن'), findsNWidgets(2));

      await tester.tap(find.text('تأیید و پرداخت'));
      await tester.pumpAndSettle();
      expect(await result, 'gateway');
      expect(paidWith?.code, 'SAIMO20');
    });

    testWidgets('explains a rejected code and pays without one',
        (tester) async {
      DiscountPreview? paidWith = valid;
      await openSheet(
        tester,
        checkDiscount: (code) async => const DiscountPreview(
          status: 'EXPIRED',
          code: 'OLD',
          listPrice: 19880000,
          discountAmount: 0,
          finalPrice: 19880000,
        ),
        onConfirm: (discount) async {
          paidWith = discount;
          return 'gateway';
        },
      );

      await enterCode(tester, 'old');

      expect(find.text('مهلت این کد تخفیف تموم شده.'),
          findsOneWidget);
      expect(find.text('اعمال شد'), findsNothing);

      await tester.tap(find.text('تأیید و پرداخت'));
      await tester.pumpAndSettle();
      expect(paidWith, isNull);
    });

    testWidgets('removing the code goes back to the full price',
        (tester) async {
      DiscountPreview? paidWith = valid;
      await openSheet(
        tester,
        checkDiscount: (_) async => valid,
        onConfirm: (discount) async {
          paidWith = discount;
          return 'gateway';
        },
      );
      await enterCode(tester, 'SAIMO20');

      await tester.tap(find.text('حذف'));
      await tester.pumpAndSettle();
      expect(find.text('کد تخفیف داری؟'), findsOneWidget);
      expect(find.text('مبلغ قابل پرداخت'), findsNothing);

      await tester.tap(find.text('تأیید و پرداخت'));
      await tester.pumpAndSettle();
      expect(paidWith, isNull);
    });

    testWidgets('drops a code the server refuses at payment', (tester) async {
      var tries = 0;
      final codes = <String?>[];
      final result = await openSheet(
        tester,
        checkDiscount: (_) async => valid,
        onConfirm: (discount) async {
          codes.add(discount?.code);
          if (tries++ == 0) {
            throw const GraphQLRawException(
              'discount code is not applicable: USAGE_LIMIT_REACHED',
            );
          }
          return 'gateway';
        },
      );
      await enterCode(tester, 'SAIMO20');

      await tester.tap(find.text('تأیید و پرداخت'));
      await tester.pumpAndSettle();
      expect(find.text('ظرفیت این کد تخفیف پر شده.'),
          findsOneWidget);
      expect(find.text('اعمال شد'), findsNothing);
      expect(find.textContaining('not applicable'), findsNothing);

      await tester.tap(find.text('تأیید و پرداخت'));
      await tester.pumpAndSettle();
      expect(await result, 'gateway');
      expect(codes, ['SAIMO20', null]);
    });
  });

  group('discount codes', () {
    test('normalizes typed codes like the server', () {
      expect(DiscountCodeFormatter.normalize(' saimo-۲۰_x! '), 'SAIMO-20_X');
      expect(DiscountCodeFormatter.normalize('کد١٢'), '12');
      expect(DiscountCodeFormatter.normalize('A' * 40).length, 32);
    });

    test('maps server refusals to Persian', () {
      expect(
        discountRejectionMessage(const GraphQLRawException(
            'discount code is not applicable: ALREADY_USED')),
        'قبلاً از این کد تخفیف استفاده کردی.',
      );
      expect(discountRejectionMessage(Exception('something else')), isNull);
      expect(discountStatusMessage('DURATION_NOT_ELIGIBLE'),
          'این کد تخفیف برای این مدت اشتراک قابل استفاده نیست.');
      expect(discountStatusMessage('UNKNOWN_STATUS'), 'این کد تخفیف معتبر نیست.');
      expect(
        discountCheckErrorMessage(
            const GraphQLRawException('too many requests: please try again later')),
        contains('تعداد تلاش‌ها زیاد بود'),
      );
    });
  });
}
