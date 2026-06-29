import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/auth/token_storage.dart';

void main() {
  test('TokenStorage saves and clears the token pair', () async {
    SharedPreferences.setMockInitialValues({});

    final storage = await TokenStorage.create();
    final issuedAt = DateTime.now().toUtc();
    await storage.saveTokenPair(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      issuedAt: issuedAt,
    );

    expect(await storage.getAccessToken(), 'access-token');
    expect(await storage.getRefreshToken(), 'refresh-token');
    expect(await storage.getAccessTokenSavedAt(), issuedAt);
    expect(await storage.shouldRefreshAccessToken(), isFalse);

    final restoredStorage = await TokenStorage.create();
    expect(await restoredStorage.getAccessToken(), 'access-token');
    expect(await restoredStorage.getRefreshToken(), 'refresh-token');
    expect(await restoredStorage.getAccessTokenSavedAt(), issuedAt);

    await restoredStorage.clear();

    expect(await restoredStorage.getAccessToken(), isNull);
    expect(await restoredStorage.getRefreshToken(), isNull);
    expect(await restoredStorage.getAccessTokenSavedAt(), isNull);
  });

  test('TokenStorage treats a missing saved timestamp as needing refresh',
      () async {
    SharedPreferences.setMockInitialValues({
      'access_token': 'legacy-access-token',
      'refresh_token': 'legacy-refresh-token',
    });

    final storage = await TokenStorage.create();

    expect(await storage.shouldRefreshAccessToken(), isTrue);
  });
}
