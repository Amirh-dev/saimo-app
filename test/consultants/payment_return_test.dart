import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/screens/consultants/counseling_checkout.dart';
import 'package:simo_learn/presentation/screens/consultants/payment_return.dart';
import 'package:simo_learn/presentation/widgets/re_toast.dart';

void main() {
  group('PaymentReturn.fromLink', () {
    test('reads the Android link with its attempt', () {
      final payment = PaymentReturn.fromLink(Uri.parse(
        'saimo://payment-result?paymentStatus=SUCCEEDED&attemptID=a1&subscriptionID=s1',
      ));
      expect(payment, isNotNull);
      expect(payment!.attemptID, 'a1');
    });

    test('accepts the Android link without an attempt', () {
      final payment =
          PaymentReturn.fromLink(Uri.parse('saimo://payment-result'));
      expect(payment, isNotNull);
      expect(payment!.attemptID, isNull);
    });

    test('reads the web app address the result page points at', () {
      final payment = PaymentReturn.fromLink(Uri.parse(
        'https://web.saimo.app/payment-result?paymentStatus=FAILED&attemptID=a2',
      ));
      expect(payment?.attemptID, 'a2');
      expect(
        PaymentReturn.fromLink(
            Uri.parse('https://web.saimo.app/?paymentStatus=ERROR')),
        isNotNull,
      );
    });

    test('ignores other links', () {
      expect(PaymentReturn.fromLink(Uri.parse('saimo://open')), isNull);
      expect(PaymentReturn.fromLink(Uri.parse('https://web.saimo.app/')),
          isNull);
      expect(
        PaymentReturn.fromLink(
            Uri.parse('other://payment-result?attemptID=a1')),
        isNull,
      );
    });

    test('treats a blank attempt as missing', () {
      final payment = PaymentReturn.fromLink(
          Uri.parse('saimo://payment-result?attemptID=%20'));
      expect(payment!.attemptID, isNull);
    });
  });

  group('paymentReturnNotice', () {
    test('confirms only a succeeded attempt', () {
      expect(paymentReturnNotice('SUCCEEDED'), (
        message: kPaymentReturnSucceededMessage,
        type: ReToastType.success,
      ));
      expect(paymentReturnNotice('PENDING'), (
        message: kCheckoutPendingMessage,
        type: ReToastType.info,
      ));
      expect(paymentReturnNotice('FAILED')?.type, ReToastType.error);
      expect(paymentReturnNotice('EXPIRED')?.message, kCheckoutExpiredMessage);
      expect(paymentReturnNotice('SOMETHING_NEW'), isNull);
    });
  });
}
