import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_repository.dart';

void main() {
  group('fetchOffers', () {
    test('maps offers and computes the undiscounted base total', () async {
      Map<String, dynamic>? sentVariables;
      final repository = ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async {
        expect(query, contains('counselingOffers'));
        sentVariables = variables;
        return {
          'counselingOffers': [
            {
              'planType': 'PROFESSIONAL',
              'durationMonths': 6,
              'discountPercent': 10,
              'currency': 'TOMAN',
              'monthlyBasePrice': 500000,
              'displayMonthlyPrice': 450000,
              'totalPrice': 2700000,
            },
            'not-an-object',
          ],
        };
      });

      final offers = await repository.fetchOffers('counselor-1');

      expect(sentVariables, {'counselorProfileID': 'counselor-1'});
      expect(offers, hasLength(1));
      final offer = offers.single;
      expect(offer.planType, 'PROFESSIONAL');
      expect(offer.durationMonths, 6);
      expect(offer.totalPrice, 2700000);
      // 500000 * 6 months, undiscounted.
      expect(offer.baseTotalPrice, 3000000);
    });

    test('returns empty when the field is absent', () async {
      final repository = ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async =>
          const {});

      expect(await repository.fetchOffers('counselor-1'), isEmpty);
    });
  });

  group('requestCounseling', () {
    test('sends the input and returns the subscription id and cost', () async {
      Map<String, dynamic>? sentVariables;
      final repository = ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async {
        expect(query, contains('requestCounseling'));
        sentVariables = variables;
        return {
          'requestCounseling': {
            'id': 'sub-1',
            'cost': 2700000,
            'status': 'PENDING',
          },
        };
      });

      final request = await repository.requestCounseling(
        counselorProfileID: 'counselor-1',
        durationMonths: 6,
        planType: 'PROFESSIONAL',
      );

      expect(sentVariables, {
        'input': {
          'counselorProfileID': 'counselor-1',
          'durationMonths': 6,
          'planType': 'PROFESSIONAL',
        },
      });
      expect(request.subscriptionID, 'sub-1');
      expect(request.cost, 2700000);
      expect(request.status, 'PENDING');
    });

    test('throws when the response omits the subscription id', () async {
      final repository = ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async =>
          const {'requestCounseling': {}});

      await expectLater(
        repository.requestCounseling(
          counselorProfileID: 'counselor-1',
          durationMonths: 6,
          planType: 'PROFESSIONAL',
        ),
        throwsA(isA<GraphQLRawException>()),
      );
    });
  });

  group('beginPayment', () {
    test('returns the attempt id and gateway redirect URL', () async {
      Map<String, dynamic>? sentVariables;
      final repository = ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async {
        expect(query, contains('beginCounselingPayment'));
        sentVariables = variables;
        return {
          'beginCounselingPayment': {
            'redirectURL': 'https://pay.example.com/checkout/abc',
            'attempt': {
              'id': 'attempt-1',
              'status': 'PENDING',
              'amount': 2700000,
            },
          },
        };
      });

      final initiation = await repository.beginPayment(
        subscriptionID: 'sub-1',
        idempotencyKey: 'sub_sub-1',
      );

      expect(sentVariables, {
        'input': {
          'subscriptionID': 'sub-1',
          'idempotencyKey': 'sub_sub-1',
        },
      });
      expect(initiation.attemptID, 'attempt-1');
      expect(initiation.redirectURL, 'https://pay.example.com/checkout/abc');
    });

    test('throws when the redirect URL is missing', () async {
      final repository = ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async =>
          const {
            'beginCounselingPayment': {
              'redirectURL': '',
              'attempt': {'id': 'attempt-1', 'status': 'PENDING'},
            },
          });

      await expectLater(
        repository.beginPayment(
          subscriptionID: 'sub-1',
          idempotencyKey: 'sub_sub-1',
        ),
        throwsA(isA<GraphQLRawException>()),
      );
    });
  });

  group('verifyPayment', () {
    test('reports a succeeded attempt with the activated subscription',
        () async {
      Map<String, dynamic>? sentVariables;
      final repository = ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async {
        expect(query, contains('verifyCounselingPayment'));
        sentVariables = variables;
        return {
          'verifyCounselingPayment': {
            'attempt': {'id': 'attempt-1', 'status': 'SUCCEEDED'},
            'subscription': {'id': 'sub-1', 'status': 'ACTIVE'},
          },
        };
      });

      final verification = await repository.verifyPayment('attempt-1');

      expect(sentVariables, {'attemptID': 'attempt-1'});
      expect(verification.succeeded, isTrue);
      expect(verification.failed, isFalse);
      expect(verification.pending, isFalse);
      expect(verification.subscriptionStatus, 'ACTIVE');
    });

    test('reports a failed attempt with its failure message', () async {
      final repository = ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async =>
          const {
            'verifyCounselingPayment': {
              'attempt': {
                'id': 'attempt-1',
                'status': 'FAILED',
                'failureMessage': 'پرداخت لغو شد',
              },
              'subscription': {'id': 'sub-1', 'status': 'PENDING'},
            },
          });

      final verification = await repository.verifyPayment('attempt-1');

      expect(verification.succeeded, isFalse);
      expect(verification.failed, isTrue);
      expect(verification.failureMessage, 'پرداخت لغو شد');
    });

    test('treats a still-pending attempt as neither succeeded nor failed',
        () async {
      final repository = ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async =>
          const {
            'verifyCounselingPayment': {
              'attempt': {'id': 'attempt-1', 'status': 'PENDING'},
              'subscription': {'id': 'sub-1', 'status': 'PENDING'},
            },
          });

      final verification = await repository.verifyPayment('attempt-1');

      expect(verification.pending, isTrue);
    });

    test('is not a success until the subscription is ACTIVE', () async {
      final repository = ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async =>
          const {
            'verifyCounselingPayment': {
              'attempt': {'id': 'attempt-1', 'status': 'SUCCEEDED'},
              'subscription': {'id': 'sub-1', 'status': 'PENDING'},
            },
          });

      final verification = await repository.verifyPayment('attempt-1');

      expect(verification.succeeded, isFalse);
      expect(verification.pending, isTrue);
    });
  });

  group('fetchMyActiveCounselor', () {
    ConsultantRepository repositoryReturning(Map<String, dynamic> subscription) {
      return ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async =>
          {'myActiveCounselor': subscription});
    }

    Map<String, dynamic> subscription(String status, {String? endDate}) => {
          'status': status,
          'endDate': endDate,
          'counselor': {
            'id': 'profile-1',
            'userID': 'user-1',
            'user': {'fullName': 'مشاور', 'username': 'c1'},
          },
        };

    test('returns the counselor of an ACTIVE subscription', () async {
      final counselor = await repositoryReturning(subscription('ACTIVE'))
          .fetchMyActiveCounselor();

      expect(counselor?.userID, 'user-1');
    });

    test('ignores an unpaid PENDING subscription', () async {
      final counselor = await repositoryReturning(subscription('PENDING'))
          .fetchMyActiveCounselor();

      expect(counselor, isNull);
    });

    test('ignores a subscription whose end date has passed', () async {
      final counselor = await repositoryReturning(
        subscription('ACTIVE', endDate: '2000-01-01T00:00:00Z'),
      ).fetchMyActiveCounselor();

      expect(counselor, isNull);
    });
  });

  group('cancelPendingSubscription', () {
    test('sends the subscription id', () async {
      Map<String, dynamic>? sentVariables;
      final repository = ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async {
        expect(query, contains('cancelPendingCounselingSubscription'));
        sentVariables = variables;
        return const {};
      });

      await repository.cancelPendingSubscription('sub-1');

      expect(sentVariables, {'subscriptionID': 'sub-1'});
    });
  });
}
