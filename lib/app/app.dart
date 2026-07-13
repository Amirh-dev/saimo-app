import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/app/routes.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/data/notifications/active_chat_tracker.dart';
import 'package:simo_learn/data/notifications/notification_service.dart';
import 'package:simo_learn/features/auth/cubit/auth_cubit.dart';
import 'package:simo_learn/features/profile/profile_cubit.dart';
import 'package:simo_learn/presentation/screens/authentication/login/index.dart';
import 'package:simo_learn/presentation/screens/authentication/otp_code/index.dart';
import 'package:simo_learn/presentation/screens/authentication/register/index.dart';
import 'package:simo_learn/presentation/screens/chat/chat_models.dart';
import 'package:simo_learn/presentation/screens/chat/chat_repository.dart';
import 'package:simo_learn/presentation/screens/chat/inbox_subscription_client.dart';
import 'package:simo_learn/presentation/screens/chat/index.dart';
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
        listenWhen: _shouldHandleRootAuthState,
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.read<ProfileCubit>().reset();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final navigator = _rootNavigatorKey.currentState;
              if (navigator == null) return;
              navigator.pushAndRemoveUntil<void>(
                PageRouteBuilder<void>(
                  pageBuilder: (_, __, ___) => const _AuthGate(),
                  settings: const RouteSettings(name: Routes.initialRoute),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
                (_) => false,
              );
            });
            return;
          }

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
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

bool _shouldHandleRootAuthState(AuthState previous, AuthState state) {
  if (state is AuthAuthenticated && state.action == AuthAction.login) {
    return true;
  }

  if (state is! AuthUnauthenticated) return false;
  if (previous is AuthInitial) return false;
  if (previous is AuthUnauthenticated) return false;
  return previous is! AuthLoading || previous.action != AuthAction.checkStatus;
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: _shouldBuildAuthShell,
      builder: (context, state) {
        if (state is AuthInitial ||
            (state is AuthLoading && state.action == AuthAction.checkStatus)) {
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
  late final ChatRepository _chatRepository;
  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<InboxEvent>? _inboxEventSubscription;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authCubit = context.read<AuthCubit>();
    _inboxClient = context.read<InboxSubscriptionClient>();
    _chatRepository = ChatRepository(context.read<GraphQLRepository>());
    // Tapping a notification (from any app state) brings the user to chat.
    NotificationService.instance.onOpenChat = _openChatFromNotification;
    // Surface a notification for every new message that arrives over the live
    // socket while the user is not reading that exact conversation.
    _inboxEventSubscription = _inboxClient.events.listen(_handleInboxEvent);
    _handleAuthState(_authCubit.state);
    _authSubscription = _authCubit.stream.listen(_handleAuthState);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    _inboxEventSubscription?.cancel();
    unawaited(_inboxClient.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ActiveChatTracker.instance.appInForeground =
        state == AppLifecycleState.resumed;
    if (state == AppLifecycleState.resumed && _isAuthenticated) {
      unawaited(_inboxClient.connect(force: true));
    }
  }

  void _handleInboxEvent(InboxEvent event) {
    if (event is! NewMessageInboxEvent) return;
    final message = event.message;
    if (message.content.trim().isEmpty) return;
    if (!ActiveChatTracker.instance.shouldNotifyForMessageFrom(
      message.senderID,
    )) {
      return;
    }

    final senderName =
        ActiveChatTracker.instance.displayNameFor(message.senderID);
    unawaited(
      NotificationService.instance.showMessageNotification(
        title: senderName ?? 'پیام جدید',
        body: message.content,
        senderID: message.senderID,
        chatID: message.chatID,
      ),
    );
  }

  void _openChatFromNotification(String? senderID) {
    final navigator = _rootNavigatorKey.currentState;
    if (navigator == null) return;
    navigator.push<void>(
      MaterialPageRoute<void>(builder: (_) => const ChatScreen()),
    );
  }

  Future<void> _resolveCurrentUser() async {
    if (ActiveChatTracker.instance.currentUserID != null) return;
    try {
      final userID = await _chatRepository.getCurrentUserID();
      ActiveChatTracker.instance.currentUserID = userID;
    } catch (_) {
      // Best-effort; self-message filtering also happens on the chat screen.
    }
  }

  void _handleAuthState(AuthState state) {
    if (state is AuthAuthenticated) {
      _isAuthenticated = true;
      unawaited(_resolveCurrentUser());
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
