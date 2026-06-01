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
    emit(const AuthLoading());

    try {
      final response = await _graphql.requestOnce(
        GSendOTPReq(
          (request) => request.vars.input.phoneNumber = phoneNumber,
        ),
      );

      if (response.hasErrors) {
        emit(AuthFailure(graphQLResponseErrorMessage(response)));
        return;
      }

      final payload = response.data?.sendOTP;
      if (payload == null || !payload.success) {
        emit(AuthFailure(payload?.message ?? 'Sending OTP failed'));
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
      emit(AuthFailure(_friendlyError(error)));
    }
  }

  Future<void> verifyLogin({
    required String phoneNumber,
    required String code,
  }) async {
    emit(const AuthLoading());

    try {
      final response = await _graphql.requestOnce(
        GVerifyOTPAndLoginReq(
          (request) => request.vars.input
            ..phoneNumber = phoneNumber
            ..code = code,
        ),
      );

      if (response.hasErrors) {
        emit(AuthFailure(graphQLResponseErrorMessage(response)));
        return;
      }

      final payload = response.data?.verifyOTPAndLogin;
      if (payload == null || payload.accessToken.isEmpty) {
        emit(const AuthFailure('Login failed'));
        return;
      }

      await _tokenStorage.saveAccessToken(payload.accessToken);
      emit(
        AuthAuthenticated(
          userId: payload.user.id,
          accessToken: payload.accessToken,
        ),
      );
    } catch (error) {
      emit(AuthFailure(_friendlyError(error)));
    }
  }

  Future<void> verifyRegister({
    required String phoneNumber,
    required String code,
    required String fullName,
    required DateTime birthDate,
    required dynamic studyTime,
  }) async {
    emit(const AuthLoading());

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
      );

      if (response.hasErrors) {
        emit(AuthFailure(graphQLResponseErrorMessage(response)));
        return;
      }

      final payload = response.data?.verifyOTPAndRegister;
      if (payload == null || payload.accessToken.isEmpty) {
        emit(const AuthFailure('Registration failed'));
        return;
      }

      await _tokenStorage.saveAccessToken(payload.accessToken);
      emit(
        AuthAuthenticated(
          userId: payload.user.id,
          accessToken: payload.accessToken,
        ),
      );
    } catch (error) {
      emit(AuthFailure(_friendlyError(error)));
    }
  }

  Future<void> refreshToken() async {
    emit(const AuthLoading());

    try {
      final response = await _graphql.requestOnce(GRefreshTokenReq());
      if (response.hasErrors) {
        await _tokenStorage.clear();
        emit(AuthFailure(graphQLResponseErrorMessage(response)));
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
          accessToken: payload.accessToken,
        ),
      );
    } catch (error) {
      await _tokenStorage.clear();
      emit(AuthFailure(_friendlyError(error)));
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

      emit(AuthAuthenticated(userId: user.id));
    } catch (_) {
      await _tokenStorage.clear();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
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

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('Failed host lookup')) {
      return 'Network connection failed';
    }
    if (message.contains('401') ||
        message.toLowerCase().contains('unauthorized')) {
      return 'Authentication expired';
    }
    return message;
  }
}
