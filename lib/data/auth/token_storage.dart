import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage._(this._prefs)
      : _accessToken = _prefs.getString(_accessTokenKey),
        _accessTokenSavedAt = _readSavedAt(_prefs);

  static const _accessTokenKey = 'access_token';
  static const _accessTokenSavedAtKey = 'access_token_saved_at';
  static const _refreshAfter = Duration(minutes: 25);

  final SharedPreferences _prefs;
  String? _accessToken;
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

  Future<String?> getAccessToken() async => _accessToken;

  Future<DateTime?> getAccessTokenSavedAt() async => _accessTokenSavedAt;

  Future<void> clear() async {
    _accessToken = null;
    _accessTokenSavedAt = null;
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_accessTokenSavedAtKey);
  }

  Future<bool> shouldRefreshAccessToken() async {
    final token = _accessToken;
    final savedAt = _accessTokenSavedAt;
    if (token == null || token.isEmpty || savedAt == null) return false;

    return DateTime.now().toUtc().difference(savedAt.toUtc()) >= _refreshAfter;
  }

  static DateTime? _readSavedAt(SharedPreferences prefs) {
    final value = prefs.getString(_accessTokenSavedAtKey);
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
