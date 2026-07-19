import 'package:ferry/ferry.dart';
import 'package:flutter/foundation.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/register_device_token.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/unregister_device_token.req.gql.dart';

/// Registers/removes this device's FCM token with the backend so the server can
/// target it for push. Wraps the `registerDeviceToken`/`unregisterDeviceToken`
/// GraphQL mutations; both require a valid access token.
class DeviceTokenRepository {
  DeviceTokenRepository(this._graphql);

  final GraphQLRepository _graphql;

  /// Stores [token] against the authenticated user. Returns whether the server
  /// accepted it. Requires the caller to already be authenticated.
  Future<bool> register(String token) async {
    if (token.isEmpty) return false;
    final response = await _graphql.requestOnce(
      GRegisterDeviceTokenReq(
        (b) => b
          ..fetchPolicy = FetchPolicy.NetworkOnly
          ..vars.token = token
          ..vars.platform = _platform,
      ),
    );
    if (response.hasErrors) {
      throw GraphQLRawException(graphQLResponseErrorMessage(response));
    }
    return response.data?.registerDeviceToken ?? false;
  }

  /// Removes [token] from the authenticated user (e.g. on logout) so the server
  /// stops pushing to this device.
  Future<void> unregister(String token) async {
    if (token.isEmpty) return;
    final response = await _graphql.requestOnce(
      GUnregisterDeviceTokenReq(
        (b) => b
          ..fetchPolicy = FetchPolicy.NetworkOnly
          ..vars.token = token,
      ),
    );
    if (response.hasErrors) {
      throw GraphQLRawException(graphQLResponseErrorMessage(response));
    }
  }

  GDeviceTokenPlatform get _platform {
    if (kIsWeb) return GDeviceTokenPlatform.WEB;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return GDeviceTokenPlatform.IOS;
      case TargetPlatform.android:
        return GDeviceTokenPlatform.ANDROID;
      default:
        return GDeviceTokenPlatform.ANDROID;
    }
  }
}
