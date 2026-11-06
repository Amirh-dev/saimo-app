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

    test('sends a discount code only when one is applied', () async {
      Map<String, dynamic>? sentVariables;
      final repository = ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async {
        sentVariables = variables;
        return {
          'requestCounseling': {'id': 'sub-1', 'cost': 15904000},
        };
      });

      final request = await repository.requestCounseling(
        counselorProfileID: 'counselor-1',
        durationMonths: 12,
        planType: 'ADVANCED',
        discountCode: 'SAIMO20',
      );

      expect(sentVariables?['input']['discountCode'], 'SAIMO20');
      expect(request.cost, 15904000);
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

  group('previewDiscount', () {
    test('sends the selection and maps the preview', () async {
      Map<String, dynamic>? sentVariables;
      final repository = ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async {
        expect(query, contains('previewCounselingDiscount'));
        sentVariables = variables;
        return {
          'previewCounselingDiscount': {
            'status': 'VALID',
            'code': 'SAIMO20',
            'listPrice': 19880000,
            'discountAmount': 3976000,
            'finalPrice': 15904000,
            'percentOff': 20,
          },
        };
      });

      final preview = await repository.previewDiscount(
        code: 'SAIMO20',
        planType: 'ADVANCED',
        durationMonths: 12,
      );

      expect(sentVariables, {
        'input': {
          'code': 'SAIMO20',
          'planType': 'ADVANCED',
          'durationMonths': 12,
        },
      });
      expect(preview.isValid, isTrue);
      expect(preview.finalPrice, 15904000);
      expect(preview.percentOff, 20);
    });

    test('an unusable code is not valid', () {
      final preview = DiscountPreview.fromJson(const {
        'status': 'EXPIRED',
        'code': 'OLD',
        'listPrice': 100,
        'discountAmount': 0,
        'finalPrice': 100,
      });
      expect(preview.isValid, isFalse);
      expect(preview.percentOff, isNull);
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

    test('returns a closed attempt that came back without a URL', () async {
      final repository = ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async =>
          const {
            'beginCounselingPayment': {
              'redirectURL': '',
              'attempt': {'id': 'attempt-1', 'status': 'EXPIRED'},
            },
          });

      final initiation = await repository.beginPayment(
        subscriptionID: 'sub-1',
        idempotencyKey: 'sub_sub-1_1',
      );

      expect(initiation.subscriptionID, 'sub-1');
      expect(initiation.status, 'EXPIRED');
      expect(initiation.isOpen, isFalse);
    });
  });

  group('fetchPendingSubscription', () {
    test('maps the unpaid purchase and its deadline', () async {
      final repository = ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async {
        expect(query, contains('myCounselingSubscriptions(status: PENDING'));
        return {
          'myCounselingSubscriptions': [
            {
              'id': 'sub-1',
              'counselorID': 'counselor-1',
              'planType': 'PROFESSIONAL',
              'durationMonths': 6,
              'pendingExpiresAt': '2026-10-14T10:30:00Z',
            },
          ],
        };
      });

      final pending = await repository.fetchPendingSubscription();

      expect(pending, isNotNull);
      expect(pending!.id, 'sub-1');
      expect(
        pending.matches(
          counselorProfileID: 'counselor-1',
          durationMonths: 6,
          planType: 'PROFESSIONAL',
        ),
        isTrue,
      );
      expect(pending.isExpiredAt(DateTime.utc(2026, 10, 14, 10, 29)), isFalse);
      expect(pending.isExpiredAt(DateTime.utc(2026, 10, 14, 10, 30)), isTrue);
    });

    test('returns null when there is none', () async {
      final repository = ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async =>
          const {'myCounselingSubscriptions': []});

      expect(await repository.fetchPendingSubscription(), isNull);
    });
  });

  group('fetchPaymentAttemptStatus', () {
    test('reads the stored status without verifying', () async {
      final repository = ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async {
        expect(query, contains('myCounselingPaymentAttempt('));
        expect(query, isNot(contains('verifyCounselingPayment')));
        expect(variables, {'id': 'attempt-1'});
        return {
          'myCounselingPaymentAttempt': {
            'id': 'attempt-1',
            'status': 'PENDING'
          },
        };
      });

      expect(
          await repository.fetchPaymentAttemptStatus('attempt-1'), 'PENDING');
    });
  });

  group('fetchPaymentAttempts', () {
    test('maps attempts and tells which one can still be opened', () async {
      Map<String, dynamic>? sentVariables;
      final repository = ConsultantRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async {
        expect(query, contains('myCounselingPaymentAttempts'));
        sentVariables = variables;
        return {
          'myCounselingPaymentAttempts': [
            {
              'id': 'attempt-2',
              'status': 'PENDING',
              'redirectURL': 'https://pay.example.com/2',
              'expiresAt': '2026-10-14T10:15:00Z',
            },
            {
              'id': 'attempt-1',
              'status': 'FAILED',
              'redirectURL': 'https://pay.example.com/1',
              'expiresAt': '2026-10-14T10:00:00Z',
            },
          ],
        };
      });

      final attempts = await repository.fetchPaymentAttempts('sub-1');
      final before = DateTime.utc(2026, 10, 14, 10, 10);
      final after = DateTime.utc(2026, 10, 14, 10, 20);

      expect(sentVariables, {'subscriptionID': 'sub-1'});
      expect(attempts.map((a) => a.id), ['attempt-2', 'attempt-1']);
      expect(attempts.first.isOpenAt(before), isTrue);
      expect(attempts.first.isOpenAt(after), isFalse);
      expect(attempts.last.isOpenAt(before), isFalse);
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
    ConsultantRepository repositoryReturning(
        Map<String, dynamic> subscription) {
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

    test('keeps the counselor title and the subscription end date', () async {
      final active = subscription('ACTIVE', endDate: '2100-01-01T00:00:00Z');
      (active['counselor'] as Map<String, dynamic>)['title'] =
          'مشاور تحصیلی کنکور';

      final counselor =
          await repositoryReturning(active).fetchMyActiveCounselor();

      expect(counselor?.title, 'مشاور تحصیلی کنکور');
      expect(counselor?.endDate, DateTime.utc(2100));
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

  group('fetchCounselors details', () {
    ConsultantRepository answering(Map<String, dynamic> counselor) =>
        ConsultantRepository.withRawRequest(({
          required String query,
          Map<String, dynamic> variables = const {},
          bool requiresAuth = true,
        }) async {
          expect(query, contains('educationItems { title detail }'));
          expect(query, contains('studentCard { url status }'));
          return {
            'counselors': [counselor],
          };
        });

    test('maps the details page fields and drops empty rows', () async {
      final repository = answering({
        'id': 'p1',
        'title': 'مشاور',
        'intro': '  سلام  ',
        'experienceYears': 4,
        'educationItems': [
          {'title': ' رتبه ۱۲۰ ', 'detail': ' ۱۴۰۲ '},
          {'title': ' ', 'detail': 'بدون عنوان'},
        ],
        'skillItems': [
          {'title': 'برنامه هفتگی', 'description': null},
        ],
        'personalityTraits': [' صبور ', '', 7],
        'studentCard': {
          'url': 'https://cdn.test/card.jpg',
          'status': 'VERIFIED'
        },
        'user': {'fullName': 'سارا'},
      });

      final c = (await repository.fetchCounselors()).single;

      expect(c.intro, 'سلام');
      expect(c.experienceYears, 4);
      expect(c.education.single.title, 'رتبه ۱۲۰');
      expect(c.education.single.detail, '۱۴۰۲');
      expect(c.skills.single.description, '');
      expect(c.traits, ['صبور']);
      expect(c.studentCardUrl, 'https://cdn.test/card.jpg');
      expect(c.isVerified, isTrue);
    });

    test('a card that is not verified gives no badge', () async {
      final repository = answering({
        'id': 'p1',
        'title': 'مشاور',
        'studentCard': {
          'url': 'https://cdn.test/card.jpg',
          'status': 'PENDING'
        },
        'user': {'fullName': 'سارا'},
      });

      final c = (await repository.fetchCounselors()).single;

      expect(c.studentCardUrl, isNull);
      expect(c.isVerified, isFalse);
      expect(c.education, isEmpty);
      expect(c.experienceYears, isNull);
    });
  });

  test('fetchStudentCount reads the count for one counselor', () async {
    Map<String, dynamic>? sent;
    final repository = ConsultantRepository.withRawRequest(({
      required String query,
      Map<String, dynamic> variables = const {},
      bool requiresAuth = true,
    }) async {
      expect(query, contains('counselorStudentCount('));
      sent = variables;
      return {'counselorStudentCount': 45};
    });

    expect(await repository.fetchStudentCount('p1'), 45);
    expect(sent, {'counselorProfileID': 'p1'});
  });
}
