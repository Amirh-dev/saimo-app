import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:simo_learn/data/install/install_platform.dart' as platform;

/// What the home's install card offers.
enum InstallOffer {
  /// Nothing: not the web app, already installed, waved off lately, or a
  /// browser that cannot install.
  none,

  /// The browser's own install dialog (Chrome, Edge, Samsung Internet).
  prompt,

  /// Steps for Safari's Share menu: iOS has no install dialog.
  iosSteps,
}

/// Offers to add the web app to the home screen, so students open it like an
/// app instead of finding the tab again. «بعداً» hides the offer for
/// [snooze].
class HomeScreenInstall extends ChangeNotifier {
  HomeScreenInstall({
    required this.enabled,
    required bool Function() runsInstalled,
    required bool Function() runsOnIos,
    required bool Function() canPrompt,
    required Future<bool> Function() prompt,
    required void Function(VoidCallback) onChange,
    Future<SharedPreferences> Function()? preferences,
    DateTime Function()? now,
    this.snooze = const Duration(days: 7),
  })  : _runsInstalled = runsInstalled,
        _runsOnIos = runsOnIos,
        _canPrompt = canPrompt,
        _prompt = prompt,
        _onChange = onChange,
        _preferences = preferences ?? SharedPreferences.getInstance,
        _now = now ?? DateTime.now;

  static final HomeScreenInstall instance = HomeScreenInstall(
    enabled: platform.canOfferInstall,
    runsInstalled: platform.runsInstalled,
    runsOnIos: platform.runsOnIos,
    canPrompt: platform.canPromptInstall,
    prompt: platform.promptInstall,
    onChange: platform.onInstallChange,
  );

  static const String dismissedAtKey = 'home_install_dismissed_at';

  final bool enabled;
  final Duration snooze;
  final bool Function() _runsInstalled;
  final bool Function() _runsOnIos;
  final bool Function() _canPrompt;
  final Future<bool> Function() _prompt;
  final void Function(VoidCallback) _onChange;
  final Future<SharedPreferences> Function() _preferences;
  final DateTime Function() _now;

  bool _started = false;
  bool _loaded = false;
  bool _accepted = false;
  DateTime? _dismissedAt;

  InstallOffer get offer {
    if (!enabled || !_loaded || _accepted || _runsInstalled()) {
      return InstallOffer.none;
    }
    final dismissedAt = _dismissedAt;
    if (dismissedAt != null && _now().difference(dismissedAt) < snooze) {
      return InstallOffer.none;
    }
    if (_canPrompt()) return InstallOffer.prompt;
    if (_runsOnIos()) return InstallOffer.iosSteps;
    return InstallOffer.none;
  }

  Future<void> start() async {
    if (!enabled || _started) return;
    _started = true;
    _onChange(notifyListeners);
    try {
      final saved = (await _preferences()).getInt(dismissedAtKey);
      if (saved != null) {
        _dismissedAt = DateTime.fromMillisecondsSinceEpoch(saved);
      }
    } catch (_) {
      // Unreadable storage only means the card may show again.
    }
    _loaded = true;
    notifyListeners();
  }

  /// Shows the browser's install dialog. Once accepted the card goes away;
  /// a refusal leaves the card to the browser, which may offer again later.
  Future<void> install() async {
    if (offer != InstallOffer.prompt) return;
    if (await _prompt()) _accepted = true;
    notifyListeners();
  }

  Future<void> dismiss() async {
    final now = _now();
    _dismissedAt = now;
    notifyListeners();
    try {
      await (await _preferences())
          .setInt(dismissedAtKey, now.millisecondsSinceEpoch);
    } catch (_) {
      // Hidden for this visit at least.
    }
  }
}
