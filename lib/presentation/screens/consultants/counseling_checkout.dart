import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_repository.dart';

/// A purchase step failed; [message] is ready to show to the student.
class CheckoutException implements Exception {
  const CheckoutException(this.message);

  final String message;

  @override
  String toString() => message;
}

enum CheckoutOutcomeKind {
  /// Paid and the subscription is ACTIVE. Only this grants a counselor.
  succeeded,

  /// The bank declined the payment, or it expired.
  failed,

  /// The student left the gateway (or cancelled on the bank page) without
  /// paying.
  cancelled,

  /// Paid as far as the bank page goes, but not confirmed yet.
  pending,

  /// The server could not be reached, so the result is not known.
  unknown,
}

class CheckoutOutcome {
  const CheckoutOutcome(this.kind, [this.message = '']);

  final CheckoutOutcomeKind kind;

  /// Student-facing explanation; empty for [CheckoutOutcomeKind.succeeded].
  final String message;
}

const String kCheckoutCancelledMessage =
    'پرداخت انجام نشد. هر زمان آماده بودید، می‌توانید دوباره پرداخت کنید.';
const String kCheckoutFailedMessage =
    'پرداخت ناموفق بود. اگر مبلغی از حساب شما کسر شده باشد، حداکثر تا ۷۲ ساعت به حسابتان برمی‌گردد.';
const String kCheckoutPendingMessage =
    'پرداخت شما در حال تایید بانک است. پس از تایید، مشاور برای شما فعال می‌شود.';
const String kCheckoutUnknownMessage =
    'وضعیت پرداخت هنوز مشخص نیست. اگر مبلغی از حساب شما کسر شده باشد، پس از تایید بانک مشاور برای شما فعال می‌شود؛ در غیر این صورت مبلغ حداکثر تا ۷۲ ساعت برمی‌گردد.';
const String kCheckoutExpiredMessage =
    'مهلت پرداخت به پایان رسید. می‌توانید دوباره پرداخت کنید.';
const String kCheckoutPreviousPaymentOpenMessage =
    'پرداخت قبلی شما هنوز در حال بررسی است. لطفاً چند دقیقه دیگر دوباره تلاش کنید.';
const String kCheckoutPreviousSucceededMessage =
    'پرداخت قبلی شما تایید شد و مشاور برای شما فعال است.';

/// Drives one counseling purchase against the API: reserve the request,
/// open (or resume) a payment attempt, and read back the verified result.
///
/// The server allows one PENDING purchase per student for 30 minutes, so an
/// abandoned try would otherwise block every retry with "already has a
/// pending subscription". [start] resumes that purchase when it matches the
/// selection and releases it when it does not.
class CounselingCheckout {
  CounselingCheckout(
    this._repository, {
    DateTime Function()? now,
    this.pollInterval = const Duration(seconds: 2),
    this.maxVerifyTries = 4,
  }) : _now = now ?? DateTime.now;

  final ConsultantRepository _repository;
  final DateTime Function() _now;
  final Duration pollInterval;
  final int maxVerifyTries;

  /// Returns an open gateway for this selection. Throws [CheckoutException].
  Future<PaymentInitiation> start({
    required String counselorProfileID,
    required int durationMonths,
    required String planType,
  }) async {
    try {
      final subscriptionID = await _reserveSubscription(
        counselorProfileID: counselorProfileID,
        durationMonths: durationMonths,
        planType: planType,
      );
      return await _openAttempt(subscriptionID);
    } on CheckoutException {
      rethrow;
    } catch (error) {
      throw CheckoutException(checkoutErrorMessage(error));
    }
  }

  /// Reads the outcome after the gateway closed. [returnedFromGateway] is
  /// true when the bank sent the student back to the server callback; only
  /// then is it worth waiting for a pending confirmation.
  Future<CheckoutOutcome> finish(
    PaymentInitiation initiation, {
    required bool returnedFromGateway,
  }) async {
    final verification = await _verify(
      initiation.attemptID,
      tries: returnedFromGateway ? maxVerifyTries : 1,
      waitWhilePending: returnedFromGateway,
    );

    if (verification == null) {
      return returnedFromGateway
          ? const CheckoutOutcome(
              CheckoutOutcomeKind.unknown, kCheckoutUnknownMessage)
          : const CheckoutOutcome(
              CheckoutOutcomeKind.cancelled, kCheckoutCancelledMessage);
    }
    if (verification.succeeded) {
      return const CheckoutOutcome(CheckoutOutcomeKind.succeeded);
    }
    if (verification.failed) {
      // Frees the student to pick another plan right away; the server would
      // otherwise hold the request until it times out.
      await _releaseQuietly(initiation.subscriptionID);
      if (verification.attemptStatus == 'EXPIRED') {
        return const CheckoutOutcome(
            CheckoutOutcomeKind.cancelled, kCheckoutExpiredMessage);
      }
      // Closing the gateway early also reads as a failure (ZarinPal reports
      // the unpaid checkout as failed), but to the student it is a cancel.
      return !returnedFromGateway ||
              _isCancelledOnBankPage(verification.failureCode)
          ? const CheckoutOutcome(
              CheckoutOutcomeKind.cancelled, kCheckoutCancelledMessage)
          : const CheckoutOutcome(
              CheckoutOutcomeKind.failed, kCheckoutFailedMessage);
    }
    return returnedFromGateway
        ? const CheckoutOutcome(
            CheckoutOutcomeKind.pending, kCheckoutPendingMessage)
        : const CheckoutOutcome(
            CheckoutOutcomeKind.cancelled, kCheckoutCancelledMessage);
  }

  Future<String> _reserveSubscription({
    required String counselorProfileID,
    required int durationMonths,
    required String planType,
  }) async {
    final pending = await _repository.fetchPendingSubscription();
    if (pending != null && !pending.isExpiredAt(_now())) {
      if (pending.matches(
        counselorProfileID: counselorProfileID,
        durationMonths: durationMonths,
        planType: planType,
      )) {
        return pending.id;
      }
      await _releaseForNewSelection(pending.id);
    }

    final request = await _repository.requestCounseling(
      counselorProfileID: counselorProfileID,
      durationMonths: durationMonths,
      planType: planType,
    );
    return request.subscriptionID;
  }

  /// Cancels a leftover purchase for another counselor or plan. The server
  /// refuses while one of its payment attempts is still open, so those are
  /// verified first (an unpaid one is closed as failed).
  Future<void> _releaseForNewSelection(String subscriptionID) async {
    try {
      await _repository.cancelPendingSubscription(subscriptionID);
      return;
    } catch (_) {
      // Most likely an open payment attempt; settle it and retry once.
    }
    await _throwIfAnAttemptSucceeded(
      await _repository.fetchPaymentAttempts(subscriptionID),
    );
    try {
      await _repository.cancelPendingSubscription(subscriptionID);
    } catch (_) {
      throw const CheckoutException(kCheckoutPreviousPaymentOpenMessage);
    }
  }

  /// Opens a new payment attempt with a fresh gateway token.
  ///
  /// A stored gateway link is never handed out again: a Mellat RefId expires
  /// long before the purchase does and cannot be posted to the bank twice,
  /// so reopening one fails at the bank with "transaction timeout". Each tap
  /// therefore takes the next idempotency slot (a double tap still converges
  /// on it), and the server closes the abandoned attempt it replaces. The
  /// only slot reused is that of an attempt whose initiation failed before
  /// any token was issued.
  Future<PaymentInitiation> _openAttempt(String subscriptionID) async {
    for (var round = 0; round < 2; round++) {
      final attempts = await _repository.fetchPaymentAttempts(subscriptionID);
      final latest = attempts.isEmpty ? null : attempts.first;
      final slot = latest != null &&
              latest.isPending &&
              latest.redirectURL.isEmpty
          ? attempts.length
          : attempts.length + 1;
      final PaymentInitiation initiation;
      try {
        initiation = await _repository.beginPayment(
          subscriptionID: subscriptionID,
          idempotencyKey: 'sub_${subscriptionID}_$slot',
        );
      } catch (error) {
        if (!_mentions(error, 'already has a pending payment attempt')) {
          rethrow;
        }
        // The bank has returned from an earlier attempt and the server is
        // still confirming it (older servers also refuse while any attempt
        // is open). It may well have been paid.
        await _throwIfAnAttemptSucceeded(attempts);
        throw const CheckoutException(kCheckoutPreviousPaymentOpenMessage);
      }
      if (initiation.isOpen) return initiation;
      // The slot's attempt had expired meanwhile; the next round moves on.
    }
    throw const CheckoutException(
      'درگاه پرداخت باز نشد. لطفاً دوباره تلاش کنید.',
    );
  }

  Future<void> _throwIfAnAttemptSucceeded(
    List<CounselingPaymentAttemptInfo> attempts,
  ) async {
    for (final attempt in attempts.where((a) => a.isPending)) {
      final verification = await _verify(attempt.id, tries: 1);
      if (verification != null && verification.succeeded) {
        throw const CheckoutException(kCheckoutPreviousSucceededMessage);
      }
    }
  }

  /// Verifies [attemptID], retrying transient errors and, when
  /// [waitWhilePending], a still-confirming payment. Null means the server
  /// never answered.
  Future<PaymentVerification?> _verify(
    String attemptID, {
    required int tries,
    bool waitWhilePending = false,
  }) async {
    PaymentVerification? last;
    for (var i = 0; i < tries; i++) {
      if (i > 0) await Future<void>.delayed(pollInterval);
      try {
        last = await _repository.verifyPayment(attemptID);
        if (!last.pending || !waitWhilePending) return last;
      } catch (_) {
        // Network or provider hiccup: try again.
      }
    }
    return last;
  }

  Future<void> _releaseQuietly(String subscriptionID) async {
    try {
      await _repository.cancelPendingSubscription(subscriptionID);
    } catch (_) {
      // Best effort: the server also expires unpaid requests.
    }
  }

  /// Mellat result code 17 means the student pressed "cancel" on the bank
  /// page; ZarinPal reports a cancelled checkout as NOK.
  static bool _isCancelledOnBankPage(String? failureCode) =>
      failureCode == 'MELLAT_CALLBACK_17' ||
      failureCode == 'ZARINPAL_CALLBACK_NOK';
}

bool _mentions(Object error, String text) =>
    error.toString().toLowerCase().contains(text);

/// Turns an API or network error from the purchase flow into a short Persian
/// message. Server errors arrive as English sentences, which the student
/// should never see.
String checkoutErrorMessage(Object error) {
  if (error is CheckoutException) return error.message;
  if (error is UnauthorizedException) {
    return 'نشست شما به پایان رسیده است. لطفاً دوباره وارد حساب کاربری شوید.';
  }
  if (error is SocketException ||
      error is http.ClientException ||
      error is TimeoutException) {
    return 'اتصال به اینترنت برقرار نیست. لطفاً اتصال خود را بررسی کنید و دوباره تلاش کنید.';
  }
  if (_mentions(error, 'already has an active or pending')) {
    return 'شما در حال حاضر یک مشاور فعال دارید.';
  }
  if (_mentions(error, 'already has a pending payment attempt')) {
    return kCheckoutPreviousPaymentOpenMessage;
  }
  if (_mentions(error, 'gateway is unavailable') ||
      _mentions(error, 'gateway returned an invalid result') ||
      _mentions(error, 'checkout is unavailable')) {
    return 'درگاه پرداخت در حال حاضر در دسترس نیست. لطفاً چند دقیقه دیگر دوباره تلاش کنید.';
  }
  if (_mentions(error, 'counselor is not available')) {
    return 'این مشاور در حال حاضر پذیرش ندارد.';
  }
  if (_mentions(error, 'offer is not available')) {
    return 'این طرح در حال حاضر قابل خرید نیست.';
  }
  if (_mentions(error, 'pending counseling subscription has expired')) {
    return 'مهلت پرداخت به پایان رسید. لطفاً دوباره تلاش کنید.';
  }
  // The repository's own errors are already Persian.
  if (error is GraphQLRawException &&
      RegExp(r'[؀-ۿ]').hasMatch(error.message)) {
    return error.message;
  }
  return 'شروع پرداخت ناموفق بود. لطفاً دوباره تلاش کنید.';
}
