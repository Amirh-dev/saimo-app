import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage._(this._prefs)
      : _accessToken = _prefs.getString(_accessTokenKey),
        _refreshToken = _prefs.getString(_refreshTokenKey),
        _accessTokenSavedAt = _readSavedAt(_prefs);

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _accessTokenSavedAtKey = 'access_token_saved_at';
  static const _refreshAfter = Duration(minutes: 25);

  final SharedPreferences _prefs;
  String? _accessToken;
  String? _refreshToken;
  DateTime? _accessTokenSavedAt;

  static Future<TokenStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TokenStorage._(prefs);
  }

  String? get currentAccessToken => _accessToken;

  Future<void> saveAccessToken(String token) async {
    final now = DateTime.now().toUtc();
    _accessToken = token;
    _accessTokenSavedAt = now;
    await _prefs.setString(_accessTokenKey, token);
    await _prefs.setString(_accessTokenSavedAtKey, now.toIso8601String());
  }

  Future<void> saveTokenPair({
    required String accessToken,
    required String refreshToken,
    required DateTime issuedAt,
  }) async {
    final savedAt = issuedAt.toUtc();
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _accessTokenSavedAt = savedAt;

    await Future.wait([
      _prefs.setString(_accessTokenKey, accessToken),
      _prefs.setString(_refreshTokenKey, refreshToken),
      _prefs.setString(
        _accessTokenSavedAtKey,
        savedAt.toIso8601String(),
      ),
    ]);

    if (kDebugMode) {
      debugPrint(
        '[AuthTokenStorage] '
        'accessToken exists=${accessToken.isNotEmpty} '
        'accessToken length=${accessToken.length} '
        'refreshToken exists=${refreshToken.isNotEmpty} '
        'refreshToken length=${refreshToken.length}',
      );
    }
  }

  Future<String?> getAccessToken() async => _accessToken;

  Future<String?> getRefreshToken() async => _refreshToken;

  Future<DateTime?> getAccessTokenSavedAt() async => _accessTokenSavedAt;

  Future<void> clear() async {
    await clearTokens();
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _accessTokenSavedAt = null;
    await Future.wait([
      _prefs.remove(_accessTokenKey),
      _prefs.remove(_refreshTokenKey),
      _prefs.remove(_accessTokenSavedAtKey),
    ]);
  }

  Future<bool> shouldRefreshAccessToken() async {
    final token = _accessToken;
    final savedAt = _accessTokenSavedAt;
    if (token == null || token.isEmpty || savedAt == null) return true;

    return DateTime.now().toUtc().difference(savedAt.toUtc()) >= _refreshAfter;
  }

  static DateTime? _readSavedAt(SharedPreferences prefs) {
    final value = prefs.getString(_accessTokenSavedAtKey);
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
