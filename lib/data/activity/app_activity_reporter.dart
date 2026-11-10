import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Sends one GraphQL request; throws on failure.
typedef ActivitySend = Future<void> Function(
  String query,
  Map<String, dynamic> variables,
);

/// This build and device, as sent with every report.
class AppBuildInfo {
  const AppBuildInfo({
    this.appVersion,
    this.buildNumber,
    this.platform,
    this.osVersion,
    this.deviceModel,
  });

  final String? appVersion;
  final String? buildNumber;
  final String? platform;
  final String? osVersion;
  final String? deviceModel;

  Map<String, dynamic> toJson() => {
        'appVersion': appVersion,
        'buildNumber': buildNumber,
        'platform': platform,
        'osVersion': osVersion,
        'deviceModel': deviceModel,
      };

  static Future<AppBuildInfo> load() async {
    String? appVersion;
    String? buildNumber;
    String? osVersion;
    String? deviceModel;
    try {
      final package = await PackageInfo.fromPlatform();
      appVersion = package.version;
      buildNumber = package.buildNumber;
    } catch (_) {}
    try {
      final plugin = DeviceInfoPlugin();
      if (kIsWeb) {
        final web = await plugin.webBrowserInfo;
        osVersion = web.platform;
        deviceModel = web.browserName.name;
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final android = await plugin.androidInfo;
        osVersion = 'Android ${android.version.release}';
        deviceModel = '${android.manufacturer} ${android.model}';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = await plugin.iosInfo;
        osVersion = '${ios.systemName} ${ios.systemVersion}';
        deviceModel = ios.utsname.machine;
      }
    } catch (_) {}
    return AppBuildInfo(
      appVersion: appVersion,
      buildNumber: buildNumber,
      platform: kIsWeb ? 'WEB' : defaultTargetPlatform.name.toUpperCase(),
      osVersion: osVersion,
      deviceModel: deviceModel,
    );
  }
}

/// Counts how the app is used (opens, foreground time, tabs shown) and the
/// unhandled errors it hits, and sends them to the server in small batches:
/// when the app goes to the background, every few minutes while it stays
/// open, and shortly after an error.
///
/// Everything here is best-effort and invisible to the student: a failed send
/// keeps the counts for the next one, and a server that does not know these
/// mutations yet (an older backend) switches reporting off for the run.
class AppActivityReporter {
  AppActivityReporter({
    required ActivitySend send,
    Future<AppBuildInfo> Function()? loadBuildInfo,
    DateTime Function()? clock,
    this.flushInterval = const Duration(minutes: 5),
    this.errorDelay = const Duration(seconds: 5),
  })  : _send = send,
        _loadBuildInfo = loadBuildInfo ?? AppBuildInfo.load,
        _clock = clock ?? DateTime.now;

  /// The app's reporter, set up in `main`.
  static AppActivityReporter? instance;

  static const String reportActivityMutation = r'''
mutation ReportAppActivity($input: AppActivityReportInput!) {
  reportAppActivity(input: $input)
}''';

  static const String reportErrorsMutation = r'''
mutation ReportClientErrors($errors: [ClientErrorInput!]!) {
  reportClientErrors(errors: $errors)
}''';

  static const int _maxPendingErrors = 20;
  static const int _maxOpens = 500;
  static const int _maxForegroundSeconds = 24 * 60 * 60;

  final ActivitySend _send;
  final Future<AppBuildInfo> Function() _loadBuildInfo;
  final DateTime Function() _clock;
  final Duration flushInterval;
  final Duration errorDelay;

  Future<AppBuildInfo>? _buildInfo;
  bool _signedIn = false;
  bool _unsupported = false;
  Future<void>? _inFlight;
  bool _again = false;

  int _opens = 0;
  int _foregroundMs = 0;
  DateTime? _foregroundSince;
  final Map<String, int> _views = {};
  final Map<String, _PendingError> _errors = {};

  Timer? _periodic;
  Timer? _errorTimer;

  /// The screen shown when the app comes back, counted as a view.
  String? Function()? currentScreen;

  bool get isForeground => _foregroundSince != null;

  @visibleForTesting
  int get pendingOpens => _opens;

  @visibleForTesting
  int get pendingErrorCount => _errors.length;

  /// The app became visible (a launch or a return from the background).
  void appShown() {
    if (_foregroundSince != null || _unsupported) return;
    _foregroundSince = _clock();
    _opens = (_opens + 1).clamp(0, _maxOpens);
    final screen = currentScreen?.call();
    if (screen != null && _signedIn) screenViewed(screen);
    _periodic?.cancel();
    _periodic = Timer.periodic(flushInterval, (_) {
      _rollForeground();
      unawaited(flush());
    });
  }

  /// The app was hidden: bank the foreground time and send.
  void appHidden() {
    _rollForeground();
    _foregroundSince = null;
    _periodic?.cancel();
    _periodic = null;
    unawaited(flush());
  }

  /// [key] is a short ASCII name such as `home` or `statistics`.
  void screenViewed(String key) {
    if (!_signedIn || _unsupported) return;
    _views[key] = (_views[key] ?? 0) + 1;
  }

  /// Reports go out only for a signed-in user. Signing out sends what is
  /// pending first (call it while the session is still valid) and then drops
  /// the rest, so one account's usage never lands on the next.
  Future<void> setSignedIn(bool signedIn) async {
    if (signedIn == _signedIn) return;
    if (signedIn) {
      _signedIn = true;
      final screen = currentScreen?.call();
      if (screen != null && isForeground) screenViewed(screen);
      unawaited(flush());
      return;
    }
    _rollForeground();
    await flush();
    _signedIn = false;
    _opens = 0;
    _foregroundMs = 0;
    _views.clear();
    _errors.clear();
  }

  /// Records an unhandled error. Repeats of one error are folded into a count.
  void recordError(Object error, StackTrace? stack) {
    if (_unsupported) return;
    try {
      final message = _clip(error.toString().trim(), 500);
      if (message.isEmpty) return;
      final stackText = stack == null ? null : _stackHead(stack);
      final key = '$message\n${stackText?.split('\n').first ?? ''}';
      final existing = _errors[key];
      if (existing != null) {
        existing.count++;
      } else if (_errors.length < _maxPendingErrors) {
        _errors[key] = _PendingError(message, stackText);
      }
      _errorTimer ??= Timer(errorDelay, () {
        _errorTimer = null;
        unawaited(flush());
      });
    } catch (_) {
      // Never let error reporting raise an error of its own.
    }
  }

  void _rollForeground() {
    final since = _foregroundSince;
    if (since == null) return;
    final now = _clock();
    final elapsed = now.difference(since).inMilliseconds;
    if (elapsed > 0) {
      _foregroundMs =
          (_foregroundMs + elapsed).clamp(0, _maxForegroundSeconds * 1000);
    }
    _foregroundSince = now;
  }

  /// Sends what is pending. Safe to call at any time: a call made while a
  /// send is running is folded into one more round of it, and waits for it.
  Future<void> flush() {
    if (!_signedIn || _unsupported) return Future.value();
    final running = _inFlight;
    if (running != null) {
      _again = true;
      return running;
    }
    return _inFlight = _run();
  }

  Future<void> _run() async {
    try {
      do {
        _again = false;
        await _flushActivity();
        await _flushErrors();
      } while (_again && _signedIn && !_unsupported);
    } finally {
      _inFlight = null;
    }
  }

  Future<void> _flushActivity() async {
    final opens = _opens;
    final seconds = _foregroundMs ~/ 1000;
    final views = Map<String, int>.of(_views);
    if (opens == 0 && seconds == 0 && views.isEmpty) return;
    _opens = 0;
    _foregroundMs -= seconds * 1000;
    _views.clear();
    try {
      final build = await (_buildInfo ??= _loadBuildInfo());
      await _send(reportActivityMutation, {
        'input': {
          ...build.toJson(),
          'opens': opens,
          'foregroundSeconds': seconds,
          'screenViews': [
            for (final entry in views.entries)
              {'screen': entry.key, 'views': entry.value},
          ],
        },
      });
    } catch (error) {
      if (_isUnsupported(error)) return;
      // Keep the counts for the next try.
      _opens = (_opens + opens).clamp(0, _maxOpens);
      _foregroundMs = (_foregroundMs + seconds * 1000)
          .clamp(0, _maxForegroundSeconds * 1000);
      views.forEach((key, value) => _views[key] = (_views[key] ?? 0) + value);
    }
  }

  Future<void> _flushErrors() async {
    if (_errors.isEmpty) return;
    final pending = Map<String, _PendingError>.of(_errors);
    _errors.clear();
    try {
      final build = await (_buildInfo ??= _loadBuildInfo());
      await _send(reportErrorsMutation, {
        'errors': [
          for (final item in pending.values)
            {
              'message': item.message,
              'stack': item.stack,
              'count': item.count,
              'appVersion': build.appVersion,
              'platform': build.platform,
            },
        ],
      });
    } catch (error) {
      if (_isUnsupported(error)) return;
      for (final entry in pending.entries) {
        if (_errors.length >= _maxPendingErrors) break;
        _errors.putIfAbsent(entry.key, () => entry.value);
      }
    }
  }

  /// An older backend rejects the unknown mutation; stop for this run
  /// instead of retrying on every pause.
  bool _isUnsupported(Object error) {
    final text = error.toString();
    final unsupported = text.contains('Cannot query field') ||
        text.contains('Unknown type') ||
        text.contains('unknown type');
    if (unsupported) {
      _unsupported = true;
      _opens = 0;
      _foregroundMs = 0;
      _views.clear();
      _errors.clear();
    }
    return unsupported;
  }

  static String _clip(String value, int limit) =>
      value.length <= limit ? value : value.substring(0, limit);

  static String _stackHead(StackTrace stack) {
    final lines = stack
        .toString()
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .take(30)
        .join('\n');
    return _clip(lines, 4000);
  }

  void dispose() {
    _periodic?.cancel();
    _errorTimer?.cancel();
  }
}

class _PendingError {
  _PendingError(this.message, this.stack);

  final String message;
  final String? stack;
  int count = 1;
}
