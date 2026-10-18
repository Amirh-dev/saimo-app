import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:simo_learn/data/app_update/served_release.dart';

/// Notices when the server hands out a newer web release than the one
/// running, so an open tab can offer to reload instead of staying on the old
/// build until someone clears the cache.
///
/// It asks when the app starts, whenever the tab comes back into view, and
/// every [interval] in between.
class AppUpdateCheck extends ChangeNotifier {
  AppUpdateCheck({
    required Future<String?> Function() fetchRelease,
    required Future<void> Function() reload,
    String? runningRelease,
    this.enabled = true,
    this.interval = const Duration(minutes: 10),
  })  : _fetchRelease = fetchRelease,
        _reload = reload,
        _running = runningRelease;

  static final AppUpdateCheck instance = AppUpdateCheck(
    fetchRelease: fetchServedRelease,
    reload: reloadToLatestRelease,
    runningRelease: _builtRelease.isEmpty ? null : _builtRelease,
    enabled: canCheckServedRelease,
  );

  /// "version+build" of this build, stamped by CI to match its version.json.
  static const String _builtRelease = String.fromEnvironment('APP_RELEASE');

  final Future<String?> Function() _fetchRelease;
  final Future<void> Function() _reload;
  final bool enabled;
  final Duration interval;

  /// The running release; when the build was not stamped, the first one the
  /// server reports stands in for it.
  String? _running;
  String? _latest;
  String? _dismissed;
  bool _updating = false;
  Timer? _timer;
  AppLifecycleListener? _lifecycle;

  /// A newer release is on the server and was not waved off.
  bool get available => _latest != null;

  /// The reload is under way.
  bool get updating => _updating;

  void start() {
    if (!enabled || _timer != null) return;
    unawaited(check());
    _timer = Timer.periodic(interval, (_) => unawaited(check()));
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(check()));
  }

  Future<void> check() async {
    final String? served;
    try {
      served = await _fetchRelease();
    } catch (_) {
      // Offline or mid-deploy; the next check asks again.
      return;
    }
    if (served == null) return;
    _running ??= served;
    if (served == _running || served == _dismissed || served == _latest) {
      return;
    }
    _latest = served;
    notifyListeners();
  }

  /// Hides the offer until a release newer than this one comes out.
  void dismiss() {
    if (_latest == null) return;
    _dismissed = _latest;
    _latest = null;
    notifyListeners();
  }

  Future<void> update() async {
    if (_updating) return;
    _updating = true;
    notifyListeners();
    try {
      await _reload();
    } finally {
      // Still here if the reload did not happen; let it be tried again.
      _updating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycle?.dispose();
    super.dispose();
  }
}
