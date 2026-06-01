import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/auth/token_storage.dart';

void main() {
  test('TokenStorage saves and clears the access token', () async {
    SharedPreferences.setMockInitialValues({});

    final storage = await TokenStorage.create();
    await storage.saveAccessToken('access-token');

    expect(await storage.getAccessToken(), 'access-token');
    expect(await storage.getAccessTokenSavedAt(), isNotNull);
    expect(await storage.shouldRefreshAccessToken(), isFalse);

    await storage.clear();

    expect(await storage.getAccessToken(), isNull);
    expect(await storage.getAccessTokenSavedAt(), isNull);
  });
}
