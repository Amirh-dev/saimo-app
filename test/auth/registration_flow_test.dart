import 'dart:convert';

import 'package:ferry/ferry.dart';
import 'package:flutter_test/flutter_test.dart';
// gql_exec is a transitive test fixture API exposed through Ferry's link stack.
// ignore: depend_on_referenced_packages
import 'package:gql_exec/gql_exec.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/auth/cubit/auth_cubit.dart';
import 'package:simo_learn/features/profile/user_major.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';

const _phone = '09123456789';

void main() {
  tearDown(() => AuthCubit.clock = DateTime.now);

  test('a new number goes phone -> OTP -> register form -> account', () async {
    Map<String, dynamic>? verifyInput;
    Map<String, dynamic>? registerInput;
    final harness = await _createHarness(
      Link.function((request, [forward]) async* {
        switch (request.operation.operationName) {
          case 'SendOTP':
            yield _sendOtpResponse(isRegistered: false);
            return;
          case 'VerifyOTPForRegistration':
            verifyInput = _input(request);
            yield _verifyResponse();
            return;
          case 'Register':
            registerInput = _input(request);
            yield _dataResponse({
              '__typename': 'Mutation',
              'register': {
                '__typename': 'AuthPayload',
                'accessToken': 'access-token',
                'refreshToken': 'refresh-token',
                'user': {'__typename': 'User', 'id': 'new-user'},
              },
            });
            return;
          default:
            fail('Unexpected operation: ${request.operation.operationName}');
        }
      }),
    );
    addTearDown(harness.authCubit.close);

    await harness.authCubit.sendOtp(_phone);
    final sent = harness.authCubit.state;
    expect(sent, isA<OtpSent>());
    expect((sent as OtpSent).isRegistered, isFalse);

    await harness.authCubit.verifyOtpForNextStep(
      phoneNumber: _phone,
      code: '12345',
      isRegistered: false,
    );
    final needsRegistration = harness.authCubit.state;
    expect(needsRegistration, isA<AuthNeedsRegistration>());
    expect((needsRegistration as AuthNeedsRegistration).phoneNumber, _phone);
    expect(needsRegistration.completeProfileOnly, isFalse);
    expect(verifyInput, {'phoneNumber': _phone, 'code': '12345'});

    await harness.authCubit.register(
      fullName: 'علی رضایی',
      username: 'ali_rezaei',
      birthDate: DateTime(2001, 2, 3),
      studyTime: GUserStudyTime.BETWEEN_4_AND_7,
      major: UserMajor.science,
    );

    expect(harness.authCubit.state, isA<AuthAuthenticated>());
    expect(registerInput, {
      'registrationToken': 'reg-token',
      'fullName': 'علی رضایی',
      'username': 'ali_rezaei',
      'birthDate': '2001-02-03T00:00:00.000Z',
      'studyTime': 'BETWEEN_4_AND_7',
    });
    expect(await harness.tokenStorage.getAccessToken(), 'access-token');
  });

  group('saving the major after the account is created', () {
    Future<_AuthHarness> registeredHarness() => _createHarness(
          Link.function((request, [forward]) async* {
            if (request.operation.operationName == 'Register') {
              yield _dataResponse({
                '__typename': 'Mutation',
                'register': {
                  '__typename': 'AuthPayload',
                  'accessToken': 'access-token',
                  'refreshToken': 'refresh-token',
                  'user': {'__typename': 'User', 'id': 'new-user'},
                },
              });
            } else {
              yield _verifyResponse();
            }
          }),
        );

    Future<void> register(_AuthHarness harness) async {
      await harness.authCubit.verifyOtpForNextStep(
        phoneNumber: _phone,
        code: '12345',
        isRegistered: false,
      );
      await harness.authCubit.register(
        fullName: 'علی رضایی',
        username: 'ali_rezaei',
        birthDate: DateTime(2001, 2, 3),
        studyTime: GUserStudyTime.BETWEEN_4_AND_7,
        major: UserMajor.art,
      );
    }

    test('sends the chosen major as its server value', () async {
      final harness = await registeredHarness();
      addTearDown(harness.authCubit.close);
      Map<String, dynamic>? sent;

      await http.runWithClient(
        () => register(harness),
        () => MockClient((request) async {
          sent = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('{"data":{"updateProfile":{"id":"new-user"}}}', 200);
        }),
      );

      expect(sent?['variables'], {
        'input': {'major': 'ART'},
      });
      expect(harness.authCubit.state, isA<AuthAuthenticated>());
    });

    test('a failed save does not fail the registration', () async {
      final harness = await registeredHarness();
      addTearDown(harness.authCubit.close);

      await http.runWithClient(
        () => register(harness),
        () => MockClient((_) async => throw http.ClientException('offline')),
      );

      expect(harness.authCubit.state, isA<AuthAuthenticated>());
    });
  });

  test('an expired registration token returns to phone entry', () async {
    var now = DateTime(2026, 10, 14, 12);
    AuthCubit.clock = () => now;
    var registerCalls = 0;
    final harness = await _createHarness(
      Link.function((request, [forward]) async* {
        switch (request.operation.operationName) {
          case 'VerifyOTPForRegistration':
            yield _verifyResponse(expiresInSeconds: 900);
            return;
          case 'Register':
            registerCalls += 1;
            return;
          default:
            fail('Unexpected operation: ${request.operation.operationName}');
        }
      }),
    );
    addTearDown(harness.authCubit.close);
    final states = <AuthState>[];
    final subscription = harness.authCubit.stream.listen(states.add);
    addTearDown(subscription.cancel);

    await harness.authCubit.verifyOtpForNextStep(
      phoneNumber: _phone,
      code: '12345',
      isRegistered: false,
    );
    now = now.add(const Duration(minutes: 16));
    await harness.authCubit.register(
      fullName: 'علی رضایی',
      username: 'ali_rezaei',
      birthDate: DateTime(2001, 2, 3),
      studyTime: GUserStudyTime.BETWEEN_4_AND_7,
      major: UserMajor.science,
    );
    await Future<void>.delayed(Duration.zero);

    expect(registerCalls, 0);
    expect(states[states.length - 2], isA<AuthFailure>());
    expect(states.last, isA<AuthUnauthenticated>());
  });

  test('a spent token after a server error returns to phone entry', () async {
    final harness = await _createHarness(
      Link.function((request, [forward]) async* {
        switch (request.operation.operationName) {
          case 'VerifyOTPForRegistration':
            yield _verifyResponse();
            return;
          case 'Register':
            yield _errorResponse(
              'phone number or username is already registered',
            );
            return;
          default:
            fail('Unexpected operation: ${request.operation.operationName}');
        }
      }),
    );
    addTearDown(harness.authCubit.close);

    await harness.authCubit.verifyOtpForNextStep(
      phoneNumber: _phone,
      code: '12345',
      isRegistered: false,
    );
    await harness.authCubit.register(
      fullName: 'علی رضایی',
      username: 'ali_rezaei',
      birthDate: DateTime(2001, 2, 3),
      studyTime: GUserStudyTime.BETWEEN_4_AND_7,
      major: UserMajor.science,
    );

    expect(harness.authCubit.state, isA<AuthUnauthenticated>());
  });

  test('a wrong code stays on the OTP screen with an error', () async {
    final harness = await _createHarness(
      Link.function((request, [forward]) async* {
        yield _errorResponse('invalid OTP code');
      }),
    );
    addTearDown(harness.authCubit.close);

    await harness.authCubit.verifyOtpForNextStep(
      phoneNumber: _phone,
      code: '00000',
      isRegistered: false,
    );

    final state = harness.authCubit.state;
    expect(state, isA<AuthFailure>());
    expect((state as AuthFailure).action, AuthAction.verifyOtp);
  });
}

Map<String, dynamic> _input(Request request) =>
    Map<String, dynamic>.from(request.variables['input'] as Map);

Response _sendOtpResponse({required bool isRegistered}) {
  return _dataResponse({
    '__typename': 'Mutation',
    'sendOTP': {
      '__typename': 'SendOTPPayload',
      'success': true,
      'message': 'sent',
      'expiresInSeconds': 120,
      'isRegistered': isRegistered,
    },
  });
}

Response _verifyResponse({int expiresInSeconds = 900}) {
  return _dataResponse({
    '__typename': 'Mutation',
    'verifyOTPForRegistration': {
      '__typename': 'RegistrationVerificationPayload',
      'registrationToken': 'reg-token',
      'expiresInSeconds': expiresInSeconds,
    },
  });
}

Future<_AuthHarness> _createHarness(Link link) async {
  SharedPreferences.setMockInitialValues({});
  final tokenStorage = await TokenStorage.create();
  final repository = GraphQLRepository(
    Client(link: link),
    tokenStorage: tokenStorage,
    logger: GraphQLConsoleLogger(endpoint: 'https://example.invalid/graphql'),
  );
  return _AuthHarness(
    AuthCubit(graphQLRepository: repository, tokenStorage: tokenStorage),
    tokenStorage,
  );
}

Response _dataResponse(Map<String, dynamic> data) {
  return Response(data: data, response: data);
}

Response _errorResponse(String message) {
  return Response(
    errors: [GraphQLError(message: message)],
    response: {
      'errors': [
        {'message': message},
      ],
    },
  );
}

class _AuthHarness {
  const _AuthHarness(this.authCubit, this.tokenStorage);

  final AuthCubit authCubit;
  final TokenStorage tokenStorage;
}
