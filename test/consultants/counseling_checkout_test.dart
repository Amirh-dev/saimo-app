import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/counseling_checkout.dart';

typedef _Handler = Future<Map<String, dynamic>> Function(
    Map<String, dynamic> variables);

/// Routes raw GraphQL requests by their root field and records the calls.
class _FakeApi {
  _FakeApi(this.handlers);

  final Map<String, _Handler> handlers;
  final List<(String, Map<String, dynamic>)> calls = [];

  static const _fields = [
    'myCounselingSubscriptions',
    'myCounselingPaymentAttempts',
    'requestCounseling',
    'beginCounselingPayment',
    'verifyCounselingPayment',
    'cancelPendingCounselingSubscription',
  ];

  ConsultantRepository get repository => ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) {
        final field = _fields.firstWhere(
          (f) => query.contains('$f('),
          orElse: () => throw StateError('unexpected query: $query'),
        );
        calls.add((field, variables));
        final handler = handlers[field];
        if (handler == null) throw StateError('no handler for $field');
        return handler(variables);
      });

  List<Map<String, dynamic>> callsTo(String field) => [
        for (final c in calls)
          if (c.$1 == field) c.$2
      ];
}

Future<Map<String, dynamic>> _noPending(Map<String, dynamic> _) async =>
    const {'myCounselingSubscriptions': []};

_Handler _pending({
  String id = 'sub-1',
  String planType = 'PROFESSIONAL',
  String pendingExpiresAt = '2026-10-14T10:30:00Z',
}) =>
    (_) async => {
          'myCounselingSubscriptions': [
            {
              'id': id,
              'counselorID': 'counselor-1',
              'planType': planType,
              'durationMonths': 6,
              'pendingExpiresAt': pendingExpiresAt,
            },
          ],
        };

_Handler _requested(String id) => (_) async => {
      'requestCounseling': {'id': id, 'cost': 1, 'status': 'PENDING'},
    };

_Handler _attempts(List<Map<String, dynamic>> attempts) =>
    (_) async => {'myCounselingPaymentAttempts': attempts};

Map<String, dynamic> _begin(String attemptID, {String status = 'PENDING'}) => {
      'beginCounselingPayment': {
        'redirectURL':
            status == 'PENDING' ? 'https://pay.example.com/$attemptID' : '',
        'attempt': {'id': attemptID, 'status': status},
      },
    };

Map<String, dynamic> _verify(
  String attemptStatus, {
  String subscriptionStatus = 'PENDING',
  String? failureCode,
}) =>
    {
      'verifyCounselingPayment': {
        'attempt': {
          'id': 'attempt-1',
          'status': attemptStatus,
          'failureCode': failureCode,
          'failureMessage': 'provider text',
        },
        'subscription': {'id': 'sub-1', 'status': subscriptionStatus},
      },
    };

Future<Map<String, dynamic>> _ok(Map<String, dynamic> _) async => const {};

const _pendingAttemptError = GraphQLRawException(
  'counseling subscription already has a pending payment attempt',
);

final _now = DateTime.utc(2026, 10, 14, 10);

CounselingCheckout _checkout(_FakeApi api) => CounselingCheckout(
      api.repository,
      now: () => _now,
      pollInterval: Duration.zero,
    );

Future<PaymentInitiation> _start(_FakeApi api) => _checkout(api).start(
      counselorProfileID: 'counselor-1',
      durationMonths: 6,
      planType: 'PROFESSIONAL',
    );

const _initiation = PaymentInitiation(
  subscriptionID: 'sub-1',
  attemptID: 'attempt-1',
  redirectURL: 'https://pay.example.com/attempt-1',
  status: 'PENDING',
);

Matcher _checkoutError(String message) => throwsA(
      isA<CheckoutException>().having((e) => e.message, 'message', message),
    );

void main() {
  group('start', () {
    test('requests a new subscription and opens its first attempt', () async {
      final api = _FakeApi({
        'myCounselingSubscriptions': _noPending,
        'requestCounseling': _requested('sub-9'),
        'myCounselingPaymentAttempts': _attempts([]),
        'beginCounselingPayment': (_) async => _begin('attempt-1'),
      });

      final initiation = await _start(api);

      expect(initiation.subscriptionID, 'sub-9');
      expect(initiation.redirectURL, 'https://pay.example.com/attempt-1');
      expect(api.callsTo('beginCounselingPayment').single['input'], {
        'subscriptionID': 'sub-9',
        'idempotencyKey': 'sub_sub-9_1',
      });
    });

    test('resumes a leftover purchase for the same selection', () async {
      // Without this, requestCounseling fails with "already has an active or
      // pending counseling subscription" for 30 minutes after a closed try,
      // and the gateway never opens again.
      final api = _FakeApi({
        'myCounselingSubscriptions': _pending(),
        'myCounselingPaymentAttempts': _attempts([
          {'id': 'attempt-0', 'status': 'FAILED', 'redirectURL': ''},
        ]),
        'beginCounselingPayment': (_) async => _begin('attempt-1'),
      });

      final initiation = await _start(api);

      expect(api.callsTo('requestCounseling'), isEmpty);
      expect(initiation.subscriptionID, 'sub-1');
      // One closed attempt, so the key moves to the second slot.
      expect(
        api.callsTo('beginCounselingPayment').single['input']['idempotencyKey'],
        'sub_sub-1_2',
      );
    });

    test('opens a fresh attempt when the resumed one had expired', () async {
      var round = 0;
      final api = _FakeApi({
        'myCounselingSubscriptions': _pending(),
        'myCounselingPaymentAttempts': (_) async => {
              'myCounselingPaymentAttempts': [
                {
                  'id': 'attempt-1',
                  'status': round == 0 ? 'PENDING' : 'EXPIRED',
                  'redirectURL': 'x',
                },
              ],
            },
        'beginCounselingPayment': (_) async => round++ == 0
            ? _begin('attempt-1', status: 'EXPIRED')
            : _begin('attempt-2'),
      });

      final initiation = await _start(api);

      expect(initiation.attemptID, 'attempt-2');
      expect(
        api
            .callsTo('beginCounselingPayment')
            .map((v) => v['input']['idempotencyKey']),
        ['sub_sub-1_1', 'sub_sub-1_2'],
      );
    });

    test('reuses an open attempt that was started under another key', () async {
      final api = _FakeApi({
        'myCounselingSubscriptions': _pending(),
        'myCounselingPaymentAttempts': _attempts([
          {
            'id': 'attempt-old',
            'status': 'PENDING',
            'redirectURL': 'https://pay.example.com/old',
            'expiresAt': '2026-10-14T10:20:00Z',
          },
        ]),
        'beginCounselingPayment': (_) async => throw _pendingAttemptError,
      });

      final initiation = await _start(api);

      expect(initiation.attemptID, 'attempt-old');
      expect(initiation.redirectURL, 'https://pay.example.com/old');
    });

    test('cancels a leftover purchase for another plan, then requests',
        () async {
      final api = _FakeApi({
        'myCounselingSubscriptions':
            _pending(id: 'sub-old', planType: 'NORMAL'),
        'cancelPendingCounselingSubscription': _ok,
        'requestCounseling': _requested('sub-new'),
        'myCounselingPaymentAttempts': _attempts([]),
        'beginCounselingPayment': (_) async => _begin('attempt-1'),
      });

      final initiation = await _start(api);

      expect(
        api.callsTo('cancelPendingCounselingSubscription').single,
        {'subscriptionID': 'sub-old'},
      );
      expect(initiation.subscriptionID, 'sub-new');
    });

    test('ignores a leftover purchase whose deadline has passed', () async {
      final api = _FakeApi({
        'myCounselingSubscriptions': _pending(
          planType: 'NORMAL',
          pendingExpiresAt: '2026-10-14T09:59:00Z',
        ),
        'requestCounseling': _requested('sub-new'),
        'myCounselingPaymentAttempts': _attempts([]),
        'beginCounselingPayment': (_) async => _begin('attempt-1'),
      });

      await _start(api);

      expect(api.callsTo('cancelPendingCounselingSubscription'), isEmpty);
      expect(api.callsTo('requestCounseling'), hasLength(1));
    });

    test('explains when a previous payment is still open', () async {
      final api = _FakeApi({
        'myCounselingSubscriptions': _pending(planType: 'NORMAL'),
        'cancelPendingCounselingSubscription': (_) async =>
            throw _pendingAttemptError,
        'myCounselingPaymentAttempts': _attempts([
          {'id': 'attempt-1', 'status': 'PENDING', 'redirectURL': 'x'},
        ]),
        // Mellat cannot verify before the bank's callback has arrived.
        'verifyCounselingPayment': (_) async =>
            throw const GraphQLRawException('gateway is unavailable'),
      });

      await expectLater(
        _start(api),
        _checkoutError(kCheckoutPreviousPaymentOpenMessage),
      );
      expect(api.callsTo('requestCounseling'), isEmpty);
    });

    test('turns server errors into Persian messages', () async {
      final api = _FakeApi({
        'myCounselingSubscriptions': _noPending,
        'requestCounseling': (_) async => throw const GraphQLRawException(
              'student already has an active or pending counseling subscription',
            ),
      });

      await expectLater(
        _start(api),
        _checkoutError('شما در حال حاضر یک مشاور فعال دارید.'),
      );
    });

    test('reports a lost connection plainly', () async {
      final api = _FakeApi({
        'myCounselingSubscriptions': (_) async =>
            throw const SocketException('offline'),
      });

      await expectLater(
        _start(api),
        throwsA(
          isA<CheckoutException>()
              .having((e) => e.message, 'message', contains('اینترنت')),
        ),
      );
    });
  });

  group('finish', () {
    test('succeeds only when the subscription is ACTIVE', () async {
      final api = _FakeApi({
        'verifyCounselingPayment': (_) async =>
            _verify('SUCCEEDED', subscriptionStatus: 'ACTIVE'),
      });

      final outcome =
          await _checkout(api).finish(_initiation, returnedFromGateway: true);

      expect(outcome.kind, CheckoutOutcomeKind.succeeded);
    });

    test('waits while the bank is still confirming', () async {
      var calls = 0;
      final api = _FakeApi({
        'verifyCounselingPayment': (_) async => ++calls < 3
            ? _verify('PENDING')
            : _verify('SUCCEEDED', subscriptionStatus: 'ACTIVE'),
      });

      final outcome =
          await _checkout(api).finish(_initiation, returnedFromGateway: true);

      expect(outcome.kind, CheckoutOutcomeKind.succeeded);
      expect(calls, 3);
    });

    test('reports a still-pending payment', () async {
      final api = _FakeApi({
        'verifyCounselingPayment': (_) async => _verify('PENDING'),
      });

      final outcome =
          await _checkout(api).finish(_initiation, returnedFromGateway: true);

      expect(outcome.kind, CheckoutOutcomeKind.pending);
    });

    test('reports an unknown result when the server never answers', () async {
      final api = _FakeApi({
        'verifyCounselingPayment': (_) async =>
            throw const SocketException('offline'),
      });

      final outcome =
          await _checkout(api).finish(_initiation, returnedFromGateway: true);

      expect(outcome.kind, CheckoutOutcomeKind.unknown);
      expect(api.callsTo('verifyCounselingPayment'), hasLength(4));
    });

    test('a declined payment fails and releases the request', () async {
      final api = _FakeApi({
        'verifyCounselingPayment': (_) async =>
            _verify('FAILED', failureCode: 'MELLAT_CALLBACK_51'),
        'cancelPendingCounselingSubscription': _ok,
      });

      final outcome =
          await _checkout(api).finish(_initiation, returnedFromGateway: true);

      expect(outcome.kind, CheckoutOutcomeKind.failed);
      expect(outcome.message, kCheckoutFailedMessage);
      expect(
        api.callsTo('cancelPendingCounselingSubscription').single,
        {'subscriptionID': 'sub-1'},
      );
    });

    test('an expired attempt explains the deadline', () async {
      final api = _FakeApi({
        'verifyCounselingPayment': (_) async => _verify('EXPIRED'),
        'cancelPendingCounselingSubscription': _ok,
      });

      final outcome =
          await _checkout(api).finish(_initiation, returnedFromGateway: true);

      expect(outcome.kind, CheckoutOutcomeKind.cancelled);
      expect(outcome.message, kCheckoutExpiredMessage);
    });

    test('cancel on the bank page reads as cancelled, not failed', () async {
      final api = _FakeApi({
        'verifyCounselingPayment': (_) async =>
            _verify('FAILED', failureCode: 'MELLAT_CALLBACK_17'),
        'cancelPendingCounselingSubscription': _ok,
      });

      final outcome =
          await _checkout(api).finish(_initiation, returnedFromGateway: true);

      expect(outcome.kind, CheckoutOutcomeKind.cancelled);
    });

    test('closing the gateway early checks once and reads as cancelled',
        () async {
      final api = _FakeApi({
        'verifyCounselingPayment': (_) async =>
            throw const GraphQLRawException('provider transaction ID'),
      });

      final outcome =
          await _checkout(api).finish(_initiation, returnedFromGateway: false);

      expect(outcome.kind, CheckoutOutcomeKind.cancelled);
      expect(api.callsTo('verifyCounselingPayment'), hasLength(1));
    });

    test('an early close still honours a payment the bank settled', () async {
      final api = _FakeApi({
        'verifyCounselingPayment': (_) async =>
            _verify('SUCCEEDED', subscriptionStatus: 'ACTIVE'),
      });

      final outcome =
          await _checkout(api).finish(_initiation, returnedFromGateway: false);

      expect(outcome.kind, CheckoutOutcomeKind.succeeded);
    });
  });
}
