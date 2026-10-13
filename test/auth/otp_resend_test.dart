import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
// gql_exec is exposed by Ferry for the in-memory test link.
// ignore: depend_on_referenced_packages
import 'package:gql_exec/gql_exec.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/auth/cubit/auth_cubit.dart';
import 'package:simo_learn/presentation/screens/authentication/otp_code/index.dart';

const _phone = '09123456789';

/// Answers SendOTP like the server: a code, or the resend cooldown error.
class _Server {
  int sends = 0;
  bool inCooldown = false;

  Stream<Response> handle(Request request, [NextLink? forward]) async* {
    sends++;
    if (inCooldown) {
      yield const Response(
        errors: [
          GraphQLError(message: 'please wait before requesting another OTP'),
        ],
        response: {},
      );
      return;
    }
    yield const Response(
      data: {
        'sendOTP': {
          '__typename': 'SendOTPPayload',
          'success': true,
          'message': 'OTP sent successfully',
          'expiresInSeconds': 180,
          'isRegistered': true,
        },
      },
      response: {},
    );
  }
}

Finder get _resend => find.byKey(const ValueKey('otp-resend'));

void main() {
  late DateTime now;
  setUp(() {
    now = DateTime(2026, 10, 13, 12);
    AuthCubit.clock = () => now;
  });
  tearDown(() => AuthCubit.clock = DateTime.now);

  Future<(AuthCubit, _Server)> pumpOtp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final tokenStorage = await TokenStorage.create();
    final server = _Server();
    final cubit = AuthCubit(
      graphQLRepository: GraphQLRepository(
        Client(link: Link.function(server.handle)),
        tokenStorage: tokenStorage,
        logger: GraphQLConsoleLogger(endpoint: 'https://example.invalid'),
      ),
      tokenStorage: tokenStorage,
    );
    addTearDown(cubit.close);

    // The login screen sent the first code just before this screen opened.
    await tester.runAsync(() => cubit.sendOtp(_phone));
    expect(cubit.state, isA<OtpSent>());

    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(BlocProvider.value(
      value: cubit,
      child: const MaterialApp(
        home: OTPCodeScreen(phoneNumber: _phone, isRegistered: true),
      ),
    ));
    await tester.pump();
    return (cubit, server);
  }

  testWidgets('resend waits out the cooldown, then sends a new code',
      (tester) async {
    final (_, server) = await pumpOtp(tester);
    expect(server.sends, 1);
    expect(find.text('ارسال مجدد کد (۱:۰۰)'), findsOneWidget);

    // Too early: the tap is ignored rather than refused by the server.
    await tester.tap(_resend);
    await tester.pump();
    expect(server.sends, 1);

    now = now.add(const Duration(seconds: 59, milliseconds: 500));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('ارسال مجدد کد (۰:۰۱)'), findsOneWidget);

    now = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('ارسال مجدد کد'), findsOneWidget);

    await tester.tap(_resend);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    await tester.pump();
    expect(server.sends, 2);
    expect(find.text('کد جدید ارسال شد'), findsOneWidget);
    // A fresh cooldown for the new code.
    expect(find.text('ارسال مجدد کد (۱:۰۰)'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('a refused resend says to wait instead of staying silent',
      (tester) async {
    final (_, server) = await pumpOtp(tester);
    now = now.add(const Duration(seconds: 61));
    await tester.pump(const Duration(seconds: 1));

    server.inCooldown = true;
    await tester.tap(_resend);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    await tester.pump();

    expect(server.sends, 2);
    expect(find.text('برای دریافت کد جدید کمی صبر کنید.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });
}
