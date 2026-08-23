import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:simo_learn/app/routes.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/data/notifications/active_chat_tracker.dart';
import 'package:simo_learn/data/notifications/device_token_repository.dart';
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
import 'package:simo_learn/presentation/screens/statistics/index.dart';
import 'package:simo_learn/presentation/widgets/re_toast.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
          supportedLocales: const [
            Locale("fa", "IR"),
            Locale("en", "US"),
          ],
          localizationsDelegates: const [
            PersianMaterialLocalizations.delegate,
            PersianCupertinoLocalizations.delegate,

            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
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
  late final DeviceTokenRepository _deviceTokenRepository;
  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<InboxEvent>? _inboxEventSubscription;
  bool _isAuthenticated = false;
  String? _registeredToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authCubit = context.read<AuthCubit>();
    _inboxClient = context.read<InboxSubscriptionClient>();
    final graphql = context.read<GraphQLRepository>();
    _chatRepository = ChatRepository(graphql);
    _deviceTokenRepository = DeviceTokenRepository(graphql);
    // Tapping a notification (from any app state) brings the user to chat.
    NotificationService.instance.onOpenChat = _openChatFromNotification;
    // Register this device's FCM token with the backend so the server can push
    // to it. Fires on first token fetch and on every refresh; registration only
    // succeeds once authenticated, so [_handleAuthState] also retries on login.
    NotificationService.instance.onToken = _registerDeviceToken;
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
    // Only navigate once logged in; otherwise stash the tap and open it after
    // login (also covers a cold launch where the UI isn't mounted yet).
    if (!_isAuthenticated) {
      NotificationService.instance.setPendingOpenChat(senderID);
      return;
    }

    // Defer to the next frame so the root navigator is guaranteed mounted
    // (matters on cold launch, when this runs before the first build).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = _rootNavigatorKey.currentState;
      if (navigator == null) {
        NotificationService.instance.setPendingOpenChat(senderID);
        return;
      }
      // Push the inbox with an auto-open target. The conversation opens on top
      // of the inbox, so back goes room, inbox, then home.
      navigator.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => ChatScreen(
            initialChatUserID:
                (senderID != null && senderID.isNotEmpty) ? senderID : null,
          ),
        ),
      );
    });
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
      // The FCM token may have been fetched before login (when registration was
      // skipped for lack of auth); register it now that we're authenticated.
      final token = NotificationService.instance.currentToken;
      if (token != null) unawaited(_registerDeviceToken(token));
      // A notification tapped before login (or from a cold launch) is opened
      // now that we're authenticated and can navigate.
      NotificationService.instance
          .consumePendingOpenChat(_openChatFromNotification);
      unawaited(
          _inboxClient.connect(force: state.action == AuthAction.refresh));
      return;
    }

    // Logout is the last moment the access token is still valid, so drop this
    // device's push registration before the session is torn down.
    if (state is AuthLoading && state.action == AuthAction.logout) {
      unawaited(_unregisterDeviceToken());
    }

    if (_shouldDisconnectForAuthState(state)) {
      _isAuthenticated = false;
      unawaited(_inboxClient.disconnect());
    }
  }

  /// Sends the FCM token to the backend. No-op until authenticated (login
  /// retries via [_handleAuthState]) and when the token is already registered.
  Future<void> _registerDeviceToken(String token) async {
    if (!_isAuthenticated || token.isEmpty || token == _registeredToken) return;
    try {
      final accepted = await _deviceTokenRepository.register(token);
      if (accepted) _registeredToken = token;
    } catch (_) {
      // Best-effort: a failed registration just means no push on this device
      // until the next token refresh or login retries it.
    }
  }

  Future<void> _unregisterDeviceToken() async {
    final token = _registeredToken ?? NotificationService.instance.currentToken;
    if (token == null || token.isEmpty) return;
    _registeredToken = null;
    try {
      await _deviceTokenRepository.unregister(token);
    } catch (_) {
      // Best-effort; on failure the server prunes stale tokens on push failure.
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
