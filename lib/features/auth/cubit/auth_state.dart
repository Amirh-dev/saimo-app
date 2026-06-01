part of 'auth_cubit.dart';

sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class OtpSent extends AuthState {
  const OtpSent({
    required this.phoneNumber,
    required this.expiresInSeconds,
    required this.isRegistered,
    required this.message,
  });

  final String phoneNumber;
  final int expiresInSeconds;
  final bool isRegistered;
  final String message;
}

final class AuthNeedsRegistration extends AuthState {
  const AuthNeedsRegistration({
    required this.phoneNumber,
    this.code,
  });

  final String phoneNumber;
  final String? code;
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.userId,
    this.accessToken,
  });

  final String userId;
  final String? accessToken;
}

final class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
