import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
// gql_exec is a transitive test fixture API exposed through Ferry's link stack.
// ignore: depend_on_referenced_packages
import 'package:gql_exec/gql_exec.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/auth/cubit/auth_cubit.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';
import 'package:simo_learn/presentation/screens/authentication/login/index.dart';

void main() {
  testWidgets('register button opens registration without a phone or OTP call',
      (tester) async {
    var requestCount = 0;
    final harness = await _createHarness(
      Link.function((request, [forward]) async* {
        requestCount += 1;
      }),
    );
    addTearDown(harness.authCubit.close);

    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      BlocProvider.value(
        value: harness.authCubit,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.tap(find.text('ثبت نام'));
    await tester.pump();

    expect(harness.authCubit.state, isA<AuthNeedsRegistration>());
    expect(requestCount, 0);
  });

  test('registration draft is used after OTP verification', () async {
    Map<String, dynamic>? registrationInput;
    final harness = await _createHarness(
      Link.function((request, [forward]) async* {
        switch (request.operation.operationName) {
          case 'SendOTP':
            yield _dataResponse({
              '__typename': 'Mutation',
              'sendOTP': {
                '__typename': 'SendOTPPayload',
                'success': true,
                'message': 'sent',
                'expiresInSeconds': 120,
                'isRegistered': false,
              },
            });
            return;
          case 'VerifyOTPAndRegister':
            registrationInput = Map<String, dynamic>.from(
              request.variables['input'] as Map,
            );
            yield _dataResponse({
              '__typename': 'Mutation',
              'verifyOTPAndRegister': {
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

    await harness.authCubit.sendRegistrationOtp(
      phoneNumber: '09123456789',
      fullName: 'علی رضایی',
      username: 'ali_rezaei',
      birthDate: DateTime(2001, 2, 3),
      studyTime: GUserStudyTime.BETWEEN_4_AND_7,
    );
    expect(harness.authCubit.state, isA<OtpSent>());

    await harness.authCubit.verifyOtpForNextStep(
      phoneNumber: '09123456789',
      code: '12345',
      isRegistered: false,
    );

    expect(harness.authCubit.state, isA<AuthAuthenticated>());
    expect(registrationInput, containsPair('phoneNumber', '09123456789'));
    expect(registrationInput, containsPair('code', '12345'));
    expect(registrationInput, containsPair('fullName', 'علی رضایی'));
    expect(registrationInput, containsPair('username', 'ali_rezaei'));
    expect(
      registrationInput,
      containsPair('birthDate', '2001-02-03T00:00:00.000Z'),
    );
    expect(registrationInput, containsPair('studyTime', 'BETWEEN_4_AND_7'));
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
  );
}

Response _dataResponse(Map<String, dynamic> data) {
  return Response(data: data, response: data);
}

class _AuthHarness {
  const _AuthHarness(this.authCubit);

  final AuthCubit authCubit;
}
