import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/features/auth/cubit/auth_cubit.dart';
import 'package:simo_learn/presentation/screens/authentication/login/index.dart';
import 'package:simo_learn/presentation/screens/authentication/otp_code/index.dart';
import 'package:simo_learn/presentation/screens/authentication/register/index.dart';
import 'package:simo_learn/presentation/screens/goals/index.dart';
import 'package:simo_learn/utils/_utils.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: AppFonts.iranSansVar,
        useMaterial3: true,
      ),
      home: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: _shouldBuildAuthShell,
        builder: (context, state) {
          if (state is OtpSent) {
            return OTPCodeScreen(
              phoneNumber: state.phoneNumber,
              isRegistered: state.isRegistered,
            );
          }

          if (state is AuthAuthenticated) {
            return const GoalScreen();
          }

          if (state is AuthNeedsRegistration) {
            return RegisterScreen(
              phoneNumber: state.phoneNumber,
              code: state.code,
              completeProfileOnly: state.completeProfileOnly,
            );
          }

          return const LoginScreen();
        },
      ),
    );
  }

  bool _shouldBuildAuthShell(AuthState previous, AuthState state) {
    if (state is AuthNeedsRegistration) {
      return true;
    }

    if (state is OtpSent || state is AuthAuthenticated) {
      return true;
    }

    if (state is AuthFailure) {
      return false;
    }

    if (state is AuthLoading) {
      return switch (state.action) {
        AuthAction.sendOtp ||
        AuthAction.verifyOtp ||
        AuthAction.login ||
        AuthAction.register =>
          false,
        AuthAction.refresh ||
        AuthAction.checkStatus ||
        AuthAction.logout =>
          false,
      };
    }

    return state is AuthInitial || state is AuthUnauthenticated;
  }
}
