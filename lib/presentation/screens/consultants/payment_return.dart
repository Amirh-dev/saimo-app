import 'package:simo_learn/presentation/screens/consultants/counseling_checkout.dart';
import 'package:simo_learn/presentation/widgets/re_toast.dart';

const String kPaymentReturnSucceededMessage =
    'پرداخت شما تایید شد و مشاور برای شما فعال است.';

/// The student came back from the payment result page ("بازگشت به
/// اپلیکیشن"): on Android through `saimo://payment-result`, on the web
/// through the web app's address with the page's query fields.
class PaymentReturn {
  const PaymentReturn({this.attemptID});

  /// The attempt the page reported on, when the link carries it. Its status
  /// is read from the server; the link's own `paymentStatus` is never
  /// trusted.
  final String? attemptID;

  /// Null when [link] is not a return from the result page.
  static PaymentReturn? fromLink(Uri link) {
    final query = link.queryParameters;
    final fromApp = link.scheme == 'saimo' && link.host == 'payment-result';
    final fromWeb = (link.scheme == 'https' || link.scheme == 'http') &&
        (query.containsKey('paymentStatus') || query.containsKey('attemptID'));
    if (!fromApp && !fromWeb) return null;
    final attemptID = query['attemptID']?.trim() ?? '';
    return PaymentReturn(attemptID: attemptID.isEmpty ? null : attemptID);
  }
}

/// What to tell the student about an attempt in [attemptStatus] when they
/// come back from the result page; null when there is nothing to say.
({String message, ReToastType type})? paymentReturnNotice(
  String attemptStatus,
) {
  return switch (attemptStatus) {
    'SUCCEEDED' => (
        message: kPaymentReturnSucceededMessage,
        type: ReToastType.success,
      ),
    'PENDING' => (message: kCheckoutPendingMessage, type: ReToastType.info),
    'FAILED' => (message: kCheckoutFailedMessage, type: ReToastType.error),
    'EXPIRED' => (message: kCheckoutExpiredMessage, type: ReToastType.info),
    _ => null,
  };
}
