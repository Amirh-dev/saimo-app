import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/refresh_token.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/send_otp.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_login.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_register.req.gql.dart';

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
  static const _temporaryFullName = 'Simo User';

  Future<void> sendOtp(String phoneNumber) async {
    emit(const AuthLoading(AuthAction.sendOtp));

    try {
      await _tokenStorage.clear();
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
      await _tryCompleteLogin(
        phoneNumber: phoneNumber,
        code: code,
        emitFailure: true,
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

  Future<void> verifyOtpForNextStep({
    required String phoneNumber,
    required String code,
    required bool isRegistered,
  }) async {
    emit(AuthLoading(isRegistered ? AuthAction.login : AuthAction.verifyOtp));

    try {
      final loggedIn = await _tryCompleteLogin(
        phoneNumber: phoneNumber,
        code: code,
        emitFailure: isRegistered,
      );
      if (loggedIn || isRegistered) return;

      final response = await _graphql.requestOnce(
        GVerifyOTPAndRegisterReq(
          (request) => request.vars.input
            ..phoneNumber = phoneNumber
            ..code = code
            ..fullName = _temporaryFullName
            ..birthDate.value = DateTime.utc(2000).toIso8601String()
            ..studyTime = GUserStudyTime.UNDER_4_HOURS,
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
            action: AuthAction.verifyOtp,
          ),
        );
        return;
      }

      final payload = response.data?.verifyOTPAndRegister;
      if (payload == null || payload.accessToken.isEmpty) {
        emit(
          const AuthFailure(
            'Invalid verification code',
            action: AuthAction.verifyOtp,
          ),
        );
        return;
      }

      await _tokenStorage.saveAccessToken(payload.accessToken);
      emit(
        AuthNeedsRegistration(
          phoneNumber: phoneNumber,
          completeProfileOnly: true,
        ),
      );
    } catch (error) {
      emit(
        AuthFailure(
          _friendlyError(error, fallbackMessage: 'Invalid verification code'),
          action: AuthAction.verifyOtp,
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

  Future<void> completeRegistrationProfile({
    required String fullName,
    required DateTime birthDate,
    required dynamic studyTime,
  }) async {
    emit(const AuthLoading(AuthAction.register));

    try {
      final resolvedStudyTime = _resolveStudyTime(studyTime);
      final data = await _graphql.rawRequest(
        query: r'''
mutation UpdateProfile($input: UpdateProfileInput!) {
  updateProfile(input: $input) {
    id
  }
}
''',
        variables: {
          'input': {
            'fullName': fullName,
            'birthDate': birthDate.toUtc().toIso8601String(),
            'studyTime': resolvedStudyTime.name,
          },
        },
      );

      final updateProfile = data['updateProfile'];
      final userId = updateProfile is Map<String, dynamic>
          ? updateProfile['id']?.toString()
          : null;

      if (userId == null || userId.isEmpty) {
        emit(
          const AuthFailure(
            'Updating profile failed',
            action: AuthAction.register,
          ),
        );
        return;
      }

      emit(
        AuthAuthenticated(
          userId: userId,
          action: AuthAction.register,
        ),
      );
    } catch (error) {
      emit(
        AuthFailure(
          _friendlyError(error, fallbackMessage: 'Updating profile failed'),
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
      final profile = await _loadCurrentAuthProfile();
      _emitProfileAwareAuthState(
        profile: profile,
        action: AuthAction.checkStatus,
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

  Future<bool> _tryCompleteLogin({
    required String phoneNumber,
    required String code,
    required bool emitFailure,
  }) async {
    final response = await _graphql.requestOnce(
      GVerifyOTPAndLoginReq(
        (request) => request.vars.input
          ..phoneNumber = phoneNumber
          ..code = code,
      ),
      requiresAuth: false,
    );

    if (response.hasErrors) {
      if (response.linkException != null) throw response.linkException!;
      if (emitFailure) {
        emit(
          AuthFailure(
            _extractGraphQLErrorMessage(
              response,
              fallbackMessage: 'Invalid verification code',
            ),
            action: AuthAction.login,
          ),
        );
      }
      return false;
    }

    final payload = response.data?.verifyOTPAndLogin;
    if (payload == null || payload.accessToken.isEmpty) {
      if (emitFailure) {
        emit(
          const AuthFailure(
            'Invalid verification code',
            action: AuthAction.login,
          ),
        );
      }
      return false;
    }

    await _tokenStorage.saveAccessToken(payload.accessToken);
    final profile = await _loadCurrentAuthProfile(
      fallbackUserId: payload.user.id,
      fallbackPhoneNumber: phoneNumber,
    );
    _emitProfileAwareAuthState(
      profile: profile,
      action: AuthAction.login,
      accessToken: payload.accessToken,
    );
    return true;
  }

  Future<_AuthProfile> _loadCurrentAuthProfile({
    String? fallbackUserId,
    String? fallbackPhoneNumber,
  }) async {
    final data = await _graphql.rawRequest(
      query: r'''
query GetMeForAuthCompletion {
  getMe {
    id
    phoneNumber
    fullName
    birthDate
    studyTime
  }
}
''',
    );
    final user = data['getMe'];
    if (user is! Map<String, dynamic>) {
      throw const GraphQLRawException('User not found');
    }

    final fullName = user['fullName']?.toString().trim() ?? '';
    final birthDate = user['birthDate']?.toString().trim() ?? '';
    final studyTime = user['studyTime']?.toString().trim() ?? '';

    return _AuthProfile(
      userId: user['id']?.toString() ?? fallbackUserId ?? '',
      phoneNumber: user['phoneNumber']?.toString() ?? fallbackPhoneNumber ?? '',
      isComplete: fullName.isNotEmpty &&
          fullName != _temporaryFullName &&
          birthDate.isNotEmpty &&
          studyTime.isNotEmpty,
    );
  }

  void _emitProfileAwareAuthState({
    required _AuthProfile profile,
    required AuthAction action,
    String? accessToken,
  }) {
    if (!profile.isComplete) {
      emit(
        AuthNeedsRegistration(
          phoneNumber: profile.phoneNumber,
          completeProfileOnly: true,
        ),
      );
      return;
    }

    emit(
      AuthAuthenticated(
        userId: profile.userId,
        action: action,
        accessToken: accessToken,
      ),
    );
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

class _AuthProfile {
  const _AuthProfile({
    required this.userId,
    required this.phoneNumber,
    required this.isComplete,
  });

  final String userId;
  final String phoneNumber;
  final bool isComplete;
}
