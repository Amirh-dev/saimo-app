import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:simo_learn/data/app_update/store_update_check.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';

const String kPlayStoreUrl =
    'https://play.google.com/store/apps/details?id=app.ravi.saimo';
const String kPlayStoreMarketUrl = 'market://details?id=app.ravi.saimo';

/// The website's download section, when no APK is uploaded.
const String kWebsiteDownloadUrl = 'https://saimo.app/#download';

const String appUpdatePolicyQuery = r'''
query AppUpdatePolicy($platform: AppUpdatePlatform!) {
  appUpdatePolicy(platform: $platform) {
    latestVersion
    minVersion
    message
    apkDownloads { abi url }
  }
}''';

/// The check wired to the real server, device and store; null on the web
/// and desktop, which don't install from a store.
StoreUpdateCheck? createStoreUpdateCheck(GraphQLRepository graphql) {
  if (kIsWeb) return null;
  final platform = switch (defaultTargetPlatform) {
    TargetPlatform.android => 'ANDROID',
    TargetPlatform.iOS => 'IOS',
    _ => null,
  };
  if (platform == null) return null;
  return StoreUpdateCheck(
    fetchPolicy: () async {
      final data = await graphql.rawRequest(
        query: appUpdatePolicyQuery,
        variables: {'platform': platform},
        requiresAuth: false,
      );
      return StoreUpdatePolicy.fromJson(data['appUpdatePolicy']);
    },
    runningVersion: () async => (await PackageInfo.fromPlatform()).version,
    storage: _PrefsStorage(),
    openUpdate: platform == 'ANDROID' ? _openAndroidUpdate : _openIosUpdate,
  );
}

/// Google Play opens the store page (the Play app when there is one); the
/// website downloads the APK built for this phone in the browser.
Future<bool> _openAndroidUpdate(
  StoreUpdatePolicy policy,
  StoreUpdateTarget target,
) async {
  if (target == StoreUpdateTarget.googlePlay) {
    if (await _launch(kPlayStoreMarketUrl)) return true;
    return _launch(kPlayStoreUrl);
  }
  final apk = await _apkFor(policy.apkDownloads);
  if (apk != null && await _launch(apk)) return true;
  return _launch(kWebsiteDownloadUrl);
}

Future<String?> _apkFor(List<MapEntry<String, String>> downloads) async {
  if (downloads.isEmpty) return null;
  try {
    final abis = (await DeviceInfoPlugin().androidInfo).supportedAbis;
    for (final abi in abis) {
      for (final download in downloads) {
        if (download.key == abi) return download.value;
      }
    }
  } catch (_) {}
  // Unknown phone: the server lists the recommended build first.
  return downloads.first.value;
}

/// No App Store listing yet; the website says where to get the app.
Future<bool> _openIosUpdate(
  StoreUpdatePolicy policy,
  StoreUpdateTarget target,
) =>
    _launch(kWebsiteDownloadUrl);

Future<bool> _launch(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

class _PrefsStorage implements StoreUpdateStorage {
  @override
  Future<String?> read(String key) async =>
      (await SharedPreferences.getInstance()).getString(key);

  @override
  Future<void> write(String key, String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value);
    }
  }
}
