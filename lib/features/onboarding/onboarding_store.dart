import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How far a newly registered student has got with their first steps: the
/// welcome page, a first plan, a first finished task and a first goal. It
/// starts only at registration on this device, so people who signed up
/// before it existed never see it, and each step is remembered once done.
class OnboardingStore extends ChangeNotifier {
  OnboardingStore._();

  @visibleForTesting
  OnboardingStore.forTest();

  static final OnboardingStore instance = OnboardingStore._();

  static const _prefix = 'onboarding_';
  static const _activeKey = '${_prefix}active';
  static const _welcomeKey = '${_prefix}welcome_seen';
  static const _plannedKey = '${_prefix}planned';
  static const _studiedKey = '${_prefix}studied';
  static const _goalKey = '${_prefix}goal_set';
  static const _offerKey = '${_prefix}counselor_offer_shown';

  bool _loaded = false;
  Future<void>? _loading;

  bool _active = false;
  bool _welcomeSeen = false;
  bool _planned = false;
  bool _studied = false;
  bool _goalSet = false;
  bool _offerShown = false;

  bool get isLoaded => _loaded;
  bool get isActive => _active;
  bool get planned => _planned;
  bool get studied => _studied;
  bool get goalSet => _goalSet;

  /// The welcome page, once, right after registration.
  bool get showWelcome => _active && !_welcomeSeen;

  /// The hint at the tasks screen's add button, until the first task exists.
  bool get showTaskHint => _active && !_planned;

  /// The home checklist, until every step is done.
  bool get showChecklist => _active && !isComplete;

  /// The counselor offer after the first finished task, once.
  bool get shouldOfferCounselor => _active && !_offerShown;

  int get doneCount =>
      (_planned ? 1 : 0) + (_studied ? 1 : 0) + (_goalSet ? 1 : 0);

  static const int stepCount = 3;

  bool get isComplete => doneCount == stepCount;

  /// Reads the saved progress; later calls wait for the first read.
  Future<void> load() => _loading ??= _read();

  Future<void> _read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Registration may have started the flow while this was reading.
      if (!_active) {
        _active = prefs.getBool(_activeKey) ?? false;
        _welcomeSeen = prefs.getBool(_welcomeKey) ?? false;
        _planned = prefs.getBool(_plannedKey) ?? false;
        _studied = prefs.getBool(_studiedKey) ?? false;
        _goalSet = prefs.getBool(_goalKey) ?? false;
        _offerShown = prefs.getBool(_offerKey) ?? false;
      }
    } catch (error) {
      debugPrint('OnboardingStore.load failed: $error');
    }
    _loaded = true;
    notifyListeners();
  }

  /// A new account was just made: every step starts over.
  void start() {
    _loaded = true;
    _loading ??= Future.value();
    _active = true;
    _welcomeSeen = false;
    _planned = false;
    _studied = false;
    _goalSet = false;
    _offerShown = false;
    notifyListeners();
    unawaited(_write({
      _activeKey: true,
      _welcomeKey: false,
      _plannedKey: false,
      _studiedKey: false,
      _goalKey: false,
      _offerKey: false,
    }));
  }

  /// Signing out ends the flow; the next account on this device starts it
  /// again only by registering.
  void reset() {
    final wasActive = _active;
    _active = false;
    _welcomeSeen = false;
    _planned = false;
    _studied = false;
    _goalSet = false;
    _offerShown = false;
    if (wasActive) notifyListeners();
    unawaited(_clear());
  }

  void markWelcomeSeen() {
    if (!_loaded) {
      unawaited(load().then((_) => markWelcomeSeen()));
      return;
    }
    if (!_active || _welcomeSeen) return;
    _welcomeSeen = true;
    _save(_welcomeKey);
  }

  void markPlanned() {
    if (!_loaded) {
      unawaited(load().then((_) => markPlanned()));
      return;
    }
    if (!_active || _planned) return;
    _planned = true;
    _save(_plannedKey);
  }

  void markStudied() {
    if (!_loaded) {
      unawaited(load().then((_) => markStudied()));
      return;
    }
    if (!_active || _studied) return;
    _studied = true;
    // A finished task needs a plan before it.
    if (!_planned) {
      _planned = true;
      unawaited(_write({_plannedKey: true}));
    }
    _save(_studiedKey);
  }

  void markGoalSet() {
    if (!_loaded) {
      unawaited(load().then((_) => markGoalSet()));
      return;
    }
    if (!_active || _goalSet) return;
    _goalSet = true;
    _save(_goalKey);
  }

  void markOfferShown() {
    if (!_loaded) {
      unawaited(load().then((_) => markOfferShown()));
      return;
    }
    if (!_active || _offerShown) return;
    _offerShown = true;
    _save(_offerKey);
  }

  void _save(String key) {
    notifyListeners();
    unawaited(_write({key: true}));
  }

  /// Saves run one after another, in the order the steps happened, so an
  /// older save can never land over a newer one.
  Future<void> _saving = Future.value();

  Future<void> _write(Map<String, bool> values) =>
      _saving = _saving.then((_) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          for (final entry in values.entries) {
            await prefs.setBool(entry.key, entry.value);
          }
        } catch (error) {
          debugPrint('OnboardingStore save failed: $error');
        }
      });

  Future<void> _clear() => _saving = _saving.then((_) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
          for (final key in keys.toList()) {
            await prefs.remove(key);
          }
        } catch (error) {
          debugPrint('OnboardingStore clear failed: $error');
        }
      });

  /// Waits for every save so far; for tests.
  @visibleForTesting
  Future<void> get saved => _saving;
}
