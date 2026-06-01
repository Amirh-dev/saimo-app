import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/refresh_token.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/send_otp.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_login.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_register.req.gql.dart';
import 'package:simo_learn/graphql/queries/__generated__/get_me.req.gql.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required GraphQLRepository graphQLRepository,
    required TokenStorage tokenStorage,
  })  : _graphql = graphQLRepository,
        _tokenStorage = tokenStorage,
        super(const AuthInitial());

  final GraphQLRepository _graphql;
  final TokenStorage _tokenStorage;

  Future<void> sendOtp(String phoneNumber) async {
    emit(const AuthLoading(AuthAction.sendOtp));

    try {
      final response = await _graphql.requestOnce(
        GSendOTPReq(
          (request) => request.vars.input.phoneNumber = phoneNumber,
        ),
        requiresAuth: false,
      );

      if (response.hasErrors) {
        emit(
          AuthFailure(
            _extractGraphQLErrorMessage(
              response,
              fallbackMessage: 'Sending OTP failed',
            ),
            action: AuthAction.sendOtp,
          ),
        );
        return;
      }

      final payload = response.data?.sendOTP;
      if (payload == null || !payload.success) {
        emit(
          AuthFailure(
            payload?.message ?? 'Sending OTP failed',
            action: AuthAction.sendOtp,
          ),
        );
        return;
      }

      emit(
        OtpSent(
          phoneNumber: phoneNumber,
          expiresInSeconds: payload.expiresInSeconds,
          isRegistered: payload.isRegistered,
          message: payload.message,
        ),
      );
    } catch (error) {
      emit(
        AuthFailure(
          _friendlyError(error, fallbackMessage: 'Sending OTP failed'),
          action: AuthAction.sendOtp,
        ),
      );
    }
  }

  Future<void> verifyLogin({
    required String phoneNumber,
    required String code,
  }) async {
    emit(const AuthLoading(AuthAction.login));

    try {
      final response = await _graphql.requestOnce(
        GVerifyOTPAndLoginReq(
          (request) => request.vars.input
            ..phoneNumber = phoneNumber
            ..code = code,
        ),
        requiresAuth: false,
      );

      if (response.hasErrors) {
        emit(
          AuthFailure(
            _extractGraphQLErrorMessage(
              response,
              fallbackMessage: 'Invalid verification code',
            ),
            action: AuthAction.login,
          ),
        );
        return;
      }

      final payload = response.data?.verifyOTPAndLogin;
      if (payload == null || payload.accessToken.isEmpty) {
        emit(
          const AuthFailure(
            'Invalid verification code',
            action: AuthAction.login,
          ),
        );
        return;
      }

      await _tokenStorage.saveAccessToken(payload.accessToken);
      emit(
        AuthAuthenticated(
          userId: payload.user.id,
          action: AuthAction.login,
          accessToken: payload.accessToken,
        ),
      );
    } catch (error) {
      emit(
        AuthFailure(
          _friendlyError(error, fallbackMessage: 'Invalid verification code'),
          action: AuthAction.login,
        ),
      );
    }
  }

  Future<void> verifyRegister({
    required String phoneNumber,
    required String code,
    required String fullName,
    required DateTime birthDate,
    required dynamic studyTime,
  }) async {
    emit(const AuthLoading(AuthAction.register));

    try {
      final resolvedStudyTime = _resolveStudyTime(studyTime);
      final response = await _graphql.requestOnce(
        GVerifyOTPAndRegisterReq(
          (request) => request.vars.input
            ..phoneNumber = phoneNumber
            ..code = code
            ..fullName = fullName
            ..birthDate.value = birthDate.toUtc().toIso8601String()
            ..studyTime = resolvedStudyTime,
        ),
        requiresAuth: false,
      );

      if (response.hasErrors) {
        emit(
          AuthFailure(
            _extractGraphQLErrorMessage(
              response,
              fallbackMessage: 'Invalid verification code',
            ),
            action: AuthAction.register,
          ),
        );
        return;
      }

      final payload = response.data?.verifyOTPAndRegister;
      if (payload == null || payload.accessToken.isEmpty) {
        emit(
          const AuthFailure(
            'Invalid verification code',
            action: AuthAction.register,
          ),
        );
        return;
      }

      await _tokenStorage.saveAccessToken(payload.accessToken);
      emit(
        AuthAuthenticated(
          userId: payload.user.id,
          action: AuthAction.register,
          accessToken: payload.accessToken,
        ),
      );
    } catch (error) {
      emit(
        AuthFailure(
          _friendlyError(error, fallbackMessage: 'Invalid verification code'),
          action: AuthAction.register,
        ),
      );
    }
  }

  Future<void> refreshToken() async {
    emit(const AuthLoading(AuthAction.refresh));

    try {
      final response = await _graphql.requestOnce(
        GRefreshTokenReq(),
        requiresAuth: false,
        skipAuthRefresh: true,
      );
      if (response.hasErrors) {
        await _tokenStorage.clear();
        emit(const AuthUnauthenticated());
        return;
      }

      final payload = response.data?.refreshToken;
      if (payload == null || payload.accessToken.isEmpty) {
        await _tokenStorage.clear();
        emit(const AuthUnauthenticated());
        return;
      }

      await _tokenStorage.saveAccessToken(payload.accessToken);
      emit(
        AuthAuthenticated(
          userId: payload.user.id,
          action: AuthAction.refresh,
          accessToken: payload.accessToken,
        ),
      );
    } catch (_) {
      await _tokenStorage.clear();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> checkAuthStatus() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      emit(const AuthUnauthenticated());
      return;
    }

    try {
      final response = await _graphql.requestOnce(GGetMeReq());
      if (response.hasErrors) {
        await _tokenStorage.clear();
        emit(const AuthUnauthenticated());
        return;
      }

      final user = response.data?.getMe;
      if (user == null) {
        await _tokenStorage.clear();
        emit(const AuthUnauthenticated());
        return;
      }

      emit(
        AuthAuthenticated(
          userId: user.id,
          action: AuthAction.checkStatus,
        ),
      );
    } catch (_) {
      await _tokenStorage.clear();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    _graphql.clearCache();
    emit(const AuthUnauthenticated());
  }

  GUserStudyTime _resolveStudyTime(dynamic studyTime) {
    if (studyTime is GUserStudyTime) return studyTime;
    if (studyTime is int) {
      return switch (studyTime) {
        0 => GUserStudyTime.UNDER_4_HOURS,
        1 => GUserStudyTime.BETWEEN_4_AND_7,
        2 => GUserStudyTime.OVER_7_HOURS,
        _ => throw ArgumentError('Invalid study time option'),
      };
    }
    if (studyTime is String) return GUserStudyTime.valueOf(studyTime);
    throw ArgumentError('Invalid study time option');
  }

  String _extractGraphQLErrorMessage(
    dynamic response, {
    required String fallbackMessage,
  }) {
    final message = graphQLResponseErrorMessage(response);
    if (message == 'Unknown GraphQL error' || message.trim().isEmpty) {
      return fallbackMessage;
    }
    return message;
  }

  String _friendlyError(
    Object error, {
    required String fallbackMessage,
  }) {
    final message = error.toString();
    if (message.contains('Failed host lookup')) {
      return 'Network connection failed';
    }
    if (message.contains('401') ||
        message.toLowerCase().contains('unauthorized')) {
      return 'Authentication expired';
    }
    if (message.trim().isEmpty) return fallbackMessage;
    return message;
  }
}
