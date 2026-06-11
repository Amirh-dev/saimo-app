part of 'auth_cubit.dart';

sealed class AuthState {
  const AuthState();
}

enum AuthAction {
  sendOtp,
  verifyOtp,
  login,
  register,
  refresh,
  checkStatus,
  logout,
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading(this.action);

  final AuthAction action;
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
    this.completeProfileOnly = false,
  });

  final String phoneNumber;
  final String? code;
  final bool completeProfileOnly;
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.userId,
    required this.action,
    this.accessToken,
  });

  final String userId;
  final AuthAction action;
  final String? accessToken;
}

final class AuthFailure extends AuthState {
  const AuthFailure(
    this.message, {
    required this.action,
  });

  final String message;
  final AuthAction action;
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
