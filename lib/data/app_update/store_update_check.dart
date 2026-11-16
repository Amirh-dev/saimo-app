import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';

/// What the server says about app versions (`appUpdatePolicy`).
@immutable
class StoreUpdatePolicy {
  const StoreUpdatePolicy({
    this.latestVersion,
    this.minVersion,
    this.message,
    this.apkDownloads = const [],
  });

  final String? latestVersion;

  /// Builds below this one must update before they can be used.
  final String? minVersion;
  final String? message;

  /// Uploaded APKs by architecture ("arm64-v8a" → url), recommended first.
  final List<MapEntry<String, String>> apkDownloads;

  static StoreUpdatePolicy? fromJson(Object? json) {
    if (json is! Map) return null;
    String? text(Object? value) =>
        value is String && value.trim().isNotEmpty ? value.trim() : null;
    final downloads = <MapEntry<String, String>>[];
    final list = json['apkDownloads'];
    if (list is List) {
      for (final item in list) {
        if (item is! Map) continue;
        final abi = text(item['abi']);
        final url = text(item['url']);
        if (abi != null && url != null) downloads.add(MapEntry(abi, url));
      }
    }
    return StoreUpdatePolicy(
      latestVersion: text(json['latestVersion']),
      minVersion: text(json['minVersion']),
      message: text(json['message']),
      apkDownloads: downloads,
    );
  }

  Map<String, dynamic> toJson() => {
        'latestVersion': latestVersion,
        'minVersion': minVersion,
        'message': message,
        'apkDownloads': [
          for (final d in apkDownloads) {'abi': d.key, 'url': d.value},
        ],
      };
}

/// Where the update page sends the user.
enum StoreUpdateTarget {
  googlePlay,

  /// The APK for this phone from the website (its download page if none).
  website,
}

/// Small key/value store, so tests run without SharedPreferences.
abstract class StoreUpdateStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String? value);
}

/// Compares dotted numeric versions ("1.0.43"): negative, 0 or positive.
/// Anything after a "+" (the build number) is ignored; missing parts are 0.
int compareAppVersions(String a, String b) {
  List<int> parts(String v) => v
      .split('+')
      .first
      .split('.')
      .map((p) => int.tryParse(p.trim()) ?? 0)
      .toList();
  final pa = parts(a), pb = parts(b);
  for (var i = 0; i < pa.length || i < pb.length; i++) {
    final x = i < pa.length ? pa[i] : 0;
    final y = i < pb.length ? pb[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  return 0;
}

/// Stops the installed (Android/iOS) app when it is older than the version
/// the server requires; the update page then sends the user to Google Play
/// or the website.
///
/// The web app has its own reload offer ([AppUpdateCheck]).
///
/// It asks when the app starts and when it comes back after [recheckAfter].
/// The last answer is kept, so the block also holds offline. A server that
/// can't be reached or doesn't know the query changes nothing.
class StoreUpdateCheck extends ChangeNotifier {
  StoreUpdateCheck({
    required Future<StoreUpdatePolicy?> Function() fetchPolicy,
    required Future<String?> Function() runningVersion,
    required StoreUpdateStorage storage,
    required Future<bool> Function(
      StoreUpdatePolicy policy,
      StoreUpdateTarget target,
    ) openUpdate,
    this.enabled = true,
    DateTime Function()? clock,
    this.recheckAfter = const Duration(hours: 1),
  })  : _fetchPolicy = fetchPolicy,
        _runningVersion = runningVersion,
        _storage = storage,
        _openUpdate = openUpdate,
        _clock = clock ?? DateTime.now;

  /// The app's check, set up in `main` on Android and iOS.
  static StoreUpdateCheck? instance;

  static const String policyKey = 'store_update.policy';

  final Future<StoreUpdatePolicy?> Function() _fetchPolicy;
  final Future<String?> Function() _runningVersion;
  final StoreUpdateStorage _storage;
  final Future<bool> Function(
    StoreUpdatePolicy policy,
    StoreUpdateTarget target,
  ) _openUpdate;
  final DateTime Function() _clock;
  final bool enabled;
  final Duration recheckAfter;

  String? _running;
  StoreUpdatePolicy? _policy;
  DateTime? _lastCheck;
  bool _started = false;
  StoreUpdateTarget? _opening;
  AppLifecycleListener? _lifecycle;

  StoreUpdatePolicy? get policy => _policy;
  String? get runningVersion => _running;

  /// The update page is opening this target.
  StoreUpdateTarget? get opening => _opening;

  /// This version is below the one the server requires.
  bool get required {
    final running = _running;
    final min = _policy?.minVersion;
    if (running == null || min == null) return false;
    return compareAppVersions(running, min) < 0;
  }

  Future<void> start() async {
    if (!enabled || _started) return;
    _started = true;
    try {
      _running = await _runningVersion();
    } catch (_) {}
    await _restore();
    notifyListeners();
    _lifecycle = AppLifecycleListener(onResume: () {
      final last = _lastCheck;
      if (last == null || _clock().difference(last) >= recheckAfter) {
        unawaited(check());
      }
    });
    await check();
  }

  Future<void> check() async {
    _lastCheck = _clock();
    final StoreUpdatePolicy? fetched;
    try {
      fetched = await _fetchPolicy();
    } catch (_) {
      // Offline, or a backend without the query: keep what is known.
      return;
    }
    if (fetched == null) return;
    _policy = fetched;
    notifyListeners();
    try {
      await _storage.write(policyKey, jsonEncode(fetched.toJson()));
    } catch (_) {}
  }

  /// Opens Google Play or the website's download. False if nothing opened.
  Future<bool> openUpdate(StoreUpdateTarget target) async {
    final policy = _policy;
    if (policy == null || _opening != null) return false;
    _opening = target;
    notifyListeners();
    try {
      return await _openUpdate(policy, target);
    } catch (_) {
      return false;
    } finally {
      _opening = null;
      notifyListeners();
    }
  }

  Future<void> _restore() async {
    try {
      final stored = await _storage.read(policyKey);
      if (stored != null) {
        _policy = StoreUpdatePolicy.fromJson(jsonDecode(stored));
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _lifecycle?.dispose();
    super.dispose();
  }
}
