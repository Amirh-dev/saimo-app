import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/register.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/send_otp.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_for_registration.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_login.req.gql.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required GraphQLRepository graphQLRepository,
    required TokenStorage tokenStorage,
  })  : _graphql = graphQLRepository,
        _tokenStorage = tokenStorage,
        super(const AuthInitial()) {
    _sessionExpiredSubscription = _graphql.sessionExpired.listen((_) {
      if (!isClosed) emit(const AuthUnauthenticated());
    });
  }

  final GraphQLRepository _graphql;
  final TokenStorage _tokenStorage;
  late final StreamSubscription<void> _sessionExpiredSubscription;
  static const _temporaryFullName = 'Simo User';

  /// Proof from verifyOTPForRegistration that the phone number was verified;
  /// the register mutation spends it once.
  _RegistrationVerification? _registration;

  /// The server refuses a new code this soon after the last one
  /// (OTP_RESEND_COOLDOWN, 60s by default).
  static const Duration otpResendCooldown = Duration(seconds: 60);

  /// The clock the cooldown is measured on; tests move it forward.
  @visibleForTesting
  static DateTime Function() clock = DateTime.now;

  DateTime? _lastOtpSentAt;

  /// How long until another code may be requested; zero when it may now.
  Duration get otpResendWait {
    final sentAt = _lastOtpSentAt;
    if (sentAt == null) return Duration.zero;
    final left = otpResendCooldown - clock().difference(sentAt);
    return left.isNegative ? Duration.zero : left;
  }

  // Persian, user-facing fallback messages for auth toasts.
  static final RegExp _persianChars = RegExp(r'[؀-ۿ]');
  static const _kSendOtpFailed =
      'ارسال کد تایید ناموفق بود. لطفاً دوباره تلاش کنید.';
  static const _kInvalidCode =
      'کد تایید نادرست است. لطفاً دوباره بررسی کنید.';
  static const _kUpdateProfileFailed = 'به‌روزرسانی پروفایل ناموفق بود.';
  static const _kRefreshFailed =
      'تمدید نشست ناموفق بود. لطفاً دوباره وارد شوید.';
  static const _kRegisterFailed = 'ثبت نام ناموفق بود. لطفاً دوباره تلاش کنید.';
  static const _kRegistrationExpired =
      'مهلت تکمیل ثبت نام به پایان رسیده است. لطفاً دوباره کد تایید دریافت کنید.';

  Future<void> sendOtp(String phoneNumber) async {
    // Every code request starts a new flow; a previous verification is void.
    _registration = null;
    emit(const AuthLoading(AuthAction.sendOtp));

    try {
      await _tokenStorage.clearTokens();

      final response = await _graphql.requestOnce(
        GSendOTPReq(
              (request) {
            request.vars.input.phoneNumber = phoneNumber;
            request.vars.input.client = GOTPClient.WEB;
          },
        ),
        requiresAuth: false,
      );

      if (response.hasErrors) {
        emit(
          AuthFailure(
            _extractGraphQLErrorMessage(
              response,
              fallbackMessage: _kSendOtpFailed,
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
            _localizeAuthError(payload?.message ?? '', fallback: _kSendOtpFailed),
            action: AuthAction.sendOtp,
          ),
        );
        return;
      }

      _lastOtpSentAt = clock();

      // Both flows verify the phone first:
      // registered:  phone -> OTP -> login
      // new number:  phone -> OTP -> register screen
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
          _friendlyError(error, fallbackMessage: _kSendOtpFailed),
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
          _friendlyError(error, fallbackMessage: _kInvalidCode),
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
    if (isRegistered) {
      await verifyLogin(phoneNumber: phoneNumber, code: code);
      return;
    }

    emit(const AuthLoading(AuthAction.verifyOtp));
    try {
      final response = await _graphql.requestOnce(
        GVerifyOTPForRegistrationReq(
          (request) => request.vars.input
            ..phoneNumber = phoneNumber
            ..code = code,
        ),
        requiresAuth: false,
      );

      if (response.hasErrors) {
        if (response.linkException != null) throw response.linkException!;
        final raw = graphQLResponseErrorMessage(response);
        // The number was registered after the code was sent. The code is
        // still unused (the server checks this first), so log in with it.
        if (raw.toLowerCase().contains('already registered')) {
          await _tryCompleteLogin(
            phoneNumber: phoneNumber,
            code: code,
            emitFailure: true,
          );
          return;
        }
        emit(
          AuthFailure(
            _localizeAuthError(raw, fallback: _kInvalidCode),
            action: AuthAction.verifyOtp,
          ),
        );
        return;
      }

      final payload = response.data?.verifyOTPForRegistration;
      if (payload == null || payload.registrationToken.isEmpty) {
        emit(
          const AuthFailure(_kInvalidCode, action: AuthAction.verifyOtp),
        );
        return;
      }

      _registration = _RegistrationVerification(
        token: payload.registrationToken,
        expiresAt: clock().add(Duration(seconds: payload.expiresInSeconds)),
      );
      emit(AuthNeedsRegistration(phoneNumber: phoneNumber));
    } catch (error) {
      emit(
        AuthFailure(
          _friendlyError(error, fallbackMessage: _kInvalidCode),
          action: AuthAction.verifyOtp,
        ),
      );
    }
  }

  /// Creates the account for the phone number verified by
  /// [verifyOtpForNextStep], using the profile entered on the register screen.
  Future<void> register({
    required String fullName,
    required String username,
    required DateTime birthDate,
    required dynamic studyTime,
  }) async {
    final registration = _registration;
    if (registration == null || !clock().isBefore(registration.expiresAt)) {
      _restartAfterSpentRegistration(_kRegistrationExpired);
      return;
    }

    emit(const AuthLoading(AuthAction.register));
    try {
      final response = await _graphql.requestOnce(
        GRegisterReq(
          (request) => request.vars.input
            ..registrationToken = registration.token
            ..fullName = fullName
            ..username = username
            ..birthDate.value = _dateOnlyUtc(birthDate).toIso8601String()
            ..studyTime = _resolveStudyTime(studyTime),
        ),
        requiresAuth: false,
      );

      if (response.hasErrors) {
        if (response.linkException != null) throw response.linkException!;
        final raw = graphQLResponseErrorMessage(response);
        final message = _localizeAuthError(raw, fallback: _kRegisterFailed);
        if (_registrationTokenWasSpent(raw)) {
          _restartAfterSpentRegistration(message);
          return;
        }
        emit(AuthFailure(message, action: AuthAction.register));
        return;
      }

      final payload = response.data?.register;
      if (payload == null ||
          payload.accessToken.isEmpty ||
          payload.refreshToken.isEmpty) {
        emit(
          const AuthFailure(_kRegisterFailed, action: AuthAction.register),
        );
        return;
      }

      await _tokenStorage.saveTokenPair(
        accessToken: payload.accessToken,
        refreshToken: payload.refreshToken,
        issuedAt: DateTime.now().toUtc(),
      );
      _registration = null;
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
          _friendlyError(error, fallbackMessage: _kRegisterFailed),
          action: AuthAction.register,
        ),
      );
    }
  }

  /// The server spends the registration token before it creates the user, so
  /// after these errors only a new code can complete registration.
  bool _registrationTokenWasSpent(String raw) {
    final m = raw.toLowerCase();
    return m.contains('registration verification') ||
        m.contains('already registered') ||
        m.contains('failed to complete registration') ||
        m.contains('failed to create user');
  }

  /// Shows [message] on the register screen, then returns to phone entry.
  void _restartAfterSpentRegistration(String message) {
    _registration = null;
    emit(AuthFailure(message, action: AuthAction.register));
    emit(const AuthUnauthenticated());
  }

  Future<void> completeRegistrationProfile({
    required String fullName,
    required String username,
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
            'username': username,
            'fullName': fullName,
            'birthDate': _dateOnlyUtc(birthDate).toIso8601String(),
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
            _kUpdateProfileFailed,
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
          _friendlyError(error, fallbackMessage: _kUpdateProfileFailed),
          action: AuthAction.register,
        ),
      );
    }
  }

  Future<void> refreshToken() async {
    emit(const AuthLoading(AuthAction.refresh));

    try {
      final token = await _graphql.ensureValidAccessToken(forceRefresh: true);
      if (token == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      final profile = await _loadCurrentAuthProfile();
      _emitProfileAwareAuthState(
        profile: profile,
        action: AuthAction.refresh,
        accessToken: token,
      );
    } on UnauthorizedException {
      emit(const AuthUnauthenticated());
    } catch (error) {
      emit(
        AuthFailure(
          _friendlyError(error, fallbackMessage: _kRefreshFailed),
          action: AuthAction.refresh,
        ),
      );
    }
  }

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading(AuthAction.checkStatus));
    final accessToken = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();

    if (kDebugMode) {
      debugPrint(
        '[Auth] startup checking saved tokens '
        'accessToken=${accessToken?.isNotEmpty == true} '
        'refreshToken=${refreshToken?.isNotEmpty == true}',
      );
    }

    if ((accessToken == null || accessToken.isEmpty) &&
        (refreshToken == null || refreshToken.isEmpty)) {
      emit(const AuthUnauthenticated());
      return;
    }

    try {
      final token = await _graphql.ensureValidAccessToken();
      if (token == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      final profile = await _loadCurrentAuthProfile();
      _emitProfileAwareAuthState(
        profile: profile,
        action: AuthAction.checkStatus,
        accessToken: token,
      );
    } on UnauthorizedException {
      emit(const AuthUnauthenticated());
    } catch (error) {
      final stillHasAccessToken =
          (await _tokenStorage.getAccessToken())?.isNotEmpty == true;
      final stillHasRefreshToken =
          (await _tokenStorage.getRefreshToken())?.isNotEmpty == true;
      if (stillHasAccessToken || stillHasRefreshToken) {
        if (kDebugMode) {
          debugPrint(
            '[Auth] startup validation temporarily unavailable; '
            'keeping saved session',
          );
        }
        emit(
          AuthAuthenticated(
            userId: '',
            action: AuthAction.checkStatus,
            accessToken: await _tokenStorage.getAccessToken(),
          ),
        );
        return;
      }
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    if (state is AuthLoading &&
        (state as AuthLoading).action == AuthAction.logout) {
      return;
    }

    _registration = null;
    emit(const AuthLoading(AuthAction.logout));
    try {
      await _graphql.clearAuthSession();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[Auth] logout cleanup failed: ${error.runtimeType}');
      }
    } finally {
      if (!isClosed) emit(const AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() async {
    await _sessionExpiredSubscription.cancel();
    return super.close();
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

  DateTime _dateOnlyUtc(DateTime value) {
    return DateTime.utc(value.year, value.month, value.day);
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
      if (response.linkException != null) {
        throw response.linkException!;
      }
      if (emitFailure) {
        debugPrint("ER2");
        debugPrint(response.graphqlErrors.toString());
        emit(
          AuthFailure(
            _extractGraphQLErrorMessage(
              response,
              fallbackMessage: _kInvalidCode,
            ),
            action: AuthAction.login,
          ),
        );
      }
      return false;
    }
    final payload = response.data?.verifyOTPAndLogin;
    if (payload == null ||
        payload.accessToken.isEmpty ||
        payload.refreshToken.isEmpty) {
      if (emitFailure) {
        emit(
          const AuthFailure(
            _kInvalidCode,
            action: AuthAction.login,
          ),
        );
      }
      return false;
    }

    await _tokenStorage.saveTokenPair(
      accessToken: payload.accessToken,
      refreshToken: payload.refreshToken,
      issuedAt: DateTime.now().toUtc(),
    );
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
    username
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
    final username = user['username']?.toString().trim() ?? '';

    return _AuthProfile(
      userId: user['id']?.toString() ?? fallbackUserId ?? '',
      phoneNumber: user['phoneNumber']?.toString() ?? fallbackPhoneNumber ?? '',
      isComplete: fullName.isNotEmpty &&
          fullName != _temporaryFullName &&
          username.isNotEmpty &&
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
    return _localizeAuthError(
      graphQLResponseErrorMessage(response),
      fallback: fallbackMessage,
    );
  }

  String _friendlyError(
    Object error, {
    required String fallbackMessage,
  }) {
    return _localizeAuthError(error.toString(), fallback: fallbackMessage);
  }

  /// Maps a raw (usually English) backend/exception message to a fluent Persian
  /// one for user-facing toasts. A message that already contains Persian is
  /// kept as-is; anything unrecognized falls back to [fallback] (also Persian).
  String _localizeAuthError(String raw, {required String fallback}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return fallback;
    // The backend may already return a Persian message; trust it.
    if (_persianChars.hasMatch(trimmed)) return trimmed;

    final m = trimmed.toLowerCase();
    if (m == 'unknown graphql error') return fallback;

    if (m.contains('failed host lookup') ||
        m.contains('socketexception') ||
        m.contains('network') ||
        m.contains('connection')) {
      return 'اتصال به اینترنت برقرار نیست. لطفاً شبکه‌ی خود را بررسی کنید.';
    }
    // "registration verification is expired; request a new OTP".
    if (m.contains('registration verification')) {
      return _kRegistrationExpired;
    }
    // "phone number or username is already registered".
    if (m.contains('username') && m.contains('already registered')) {
      return 'این نام کاربری یا شماره قبلاً ثبت شده است. لطفاً دوباره تلاش کنید.';
    }
    // The resend cooldown: "please wait before requesting another OTP".
    if (m.contains('wait') && (m.contains('otp') || m.contains('code'))) {
      return 'برای دریافت کد جدید کمی صبر کنید.';
    }
    if ((m.contains('expire') || m.contains('expired')) &&
        (m.contains('code') || m.contains('otp'))) {
      return 'کد تایید منقضی شده است. لطفاً کد جدید دریافت کنید.';
    }
    if (m.contains('too many') ||
        m.contains('rate limit') ||
        m.contains('attempt')) {
      return 'تعداد تلاش‌ها بیش از حد مجاز است. کمی بعد دوباره تلاش کنید.';
    }
    if ((m.contains('invalid') ||
            m.contains('incorrect') ||
            m.contains('wrong') ||
            m.contains('mismatch')) &&
        (m.contains('code') || m.contains('otp') || m.contains('verif'))) {
      return _kInvalidCode;
    }
    if (m.contains('not registered') || m.contains('not found')) {
      return 'این شماره ثبت نام نشده است.';
    }
    if (m.contains('already') &&
        (m.contains('register') || m.contains('exist'))) {
      return 'این شماره قبلاً ثبت نام شده است.';
    }
    if (m.contains('username') &&
        (m.contains('taken') || m.contains('exist') || m.contains('use'))) {
      return 'این نام کاربری قبلاً استفاده شده است.';
    }
    if (m.contains('phone') && (m.contains('invalid') || m.contains('format'))) {
      return 'شماره تماس نامعتبر است.';
    }
    if (m.contains('unauthorized') ||
        m.contains('unauthenticated') ||
        m.contains('401') ||
        m.contains('token')) {
      return 'نشست شما منقضی شده است. لطفاً دوباره وارد شوید.';
    }
    return fallback;
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

class _RegistrationVerification {
  const _RegistrationVerification({
    required this.token,
    required this.expiresAt,
  });

  final String token;
  final DateTime expiresAt;
}
