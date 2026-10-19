import 'package:shared_preferences/shared_preferences.dart';

/// Which goal the user made their main one. It lives on the device: the
/// server has no field for it, and it is only how this phone shows goals.
class PinnedGoalStore {
  const PinnedGoalStore();

  static const _key = 'goals.pinned_id';

  Future<String?> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_key);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String? id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (id == null) {
        await prefs.remove(_key);
      } else {
        await prefs.setString(_key, id);
      }
    } catch (_) {
      // Not being able to remember the pin only loses the pin.
    }
  }
}
