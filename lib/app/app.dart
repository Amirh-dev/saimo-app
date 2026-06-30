import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/features/auth/cubit/auth_cubit.dart';
import 'package:simo_learn/presentation/screens/authentication/login/index.dart';
import 'package:simo_learn/presentation/screens/authentication/otp_code/index.dart';
import 'package:simo_learn/presentation/screens/authentication/register/index.dart';
import 'package:simo_learn/presentation/screens/chat/inbox_subscription_client.dart';
import 'package:simo_learn/presentation/screens/goals/index.dart';
import 'package:simo_learn/presentation/widgets/re_toast.dart';
import 'package:simo_learn/utils/_utils.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return _LiveInboxConnector(
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, state) =>
            state is AuthAuthenticated && state.action == AuthAction.login,
        listener: (context, state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final overlayContext =
                _rootNavigatorKey.currentState?.overlay?.context;
            if (overlayContext == null) return;
            showReToast(
              overlayContext,
              'با موفقیت به حساب خود وارد شدید',
              ReToastType.success,
            );
          });
        },
        child: MaterialApp(
          navigatorKey: _rootNavigatorKey,
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
              if (state is AuthInitial ||
                  (state is AuthLoading &&
                      state.action == AuthAction.checkStatus)) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator.adaptive()),
                );
              }

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
        ),
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
        AuthAction.refresh || AuthAction.logout => false,
        AuthAction.checkStatus => true,
      };
    }

    return state is AuthInitial || state is AuthUnauthenticated;
  }
}

class _LiveInboxConnector extends StatefulWidget {
  const _LiveInboxConnector({required this.child});

  final Widget child;

  @override
  State<_LiveInboxConnector> createState() => _LiveInboxConnectorState();
}

class _LiveInboxConnectorState extends State<_LiveInboxConnector>
    with WidgetsBindingObserver {
  late final AuthCubit _authCubit;
  late final InboxSubscriptionClient _inboxClient;
  StreamSubscription<AuthState>? _authSubscription;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authCubit = context.read<AuthCubit>();
    _inboxClient = context.read<InboxSubscriptionClient>();
    _handleAuthState(_authCubit.state);
    _authSubscription = _authCubit.stream.listen(_handleAuthState);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    unawaited(_inboxClient.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isAuthenticated) {
      unawaited(_inboxClient.connect(force: true));
    }
  }

  void _handleAuthState(AuthState state) {
    if (state is AuthAuthenticated) {
      _isAuthenticated = true;
      unawaited(
          _inboxClient.connect(force: state.action == AuthAction.refresh));
      return;
    }

    if (_shouldDisconnectForAuthState(state)) {
      _isAuthenticated = false;
      unawaited(_inboxClient.disconnect());
    }
  }

  bool _shouldDisconnectForAuthState(AuthState state) {
    return state is AuthUnauthenticated ||
        state is AuthInitial ||
        state is AuthNeedsRegistration ||
        (state is AuthLoading && state.action == AuthAction.logout);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
