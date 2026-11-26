import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/features/study_hall/hall_avatar.dart';

/// The user's character, kept on the device. Screens listen to it so a
/// change in the builder shows at once in the window and the building.
class HallAvatarStore extends ChangeNotifier {
  HallAvatarStore._();
  static final HallAvatarStore instance = HallAvatarStore._();

  static const _key = 'hall_avatar_v1';

  HallAvatar _avatar = HallAvatar.fallback;
  bool _loaded = false;
  bool _custom = false;

  HallAvatar get avatar => _avatar;

  /// False until the user saved a character of their own.
  bool get isCustom => _custom;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    if (raw == null) return;
    try {
      _avatar = HallAvatar.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      _custom = true;
      notifyListeners();
    } catch (_) {
      // A broken entry falls back to the default character.
    }
  }

  Future<void> save(HallAvatar avatar) async {
    _avatar = avatar;
    _custom = true;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString(_key, jsonEncode(avatar.toJson()));
  }

  /// A new phone gets the character back from the server; a character made
  /// here before the server knew it is sent up.
  Future<void> syncWith(HallAvatar? server, Future<void> Function(HallAvatar) upload) async {
    await load();
    if (!_custom && server != null) {
      await save(server);
    } else if (_custom && server == null) {
      try {
        await upload(_avatar);
      } catch (_) {}
    }
  }

  @visibleForTesting
  void reset() {
    _avatar = HallAvatar.fallback;
    _loaded = false;
    _custom = false;
  }
}
