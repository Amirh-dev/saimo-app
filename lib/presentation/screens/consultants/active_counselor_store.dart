import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_repository.dart';

/// Whether the student has a counselor, shared by every screen's header
/// button. The last answer is kept on disk so the button opens right on a
/// cold start, then refreshes quietly.
class ActiveCounselorStore extends ChangeNotifier {
  ActiveCounselorStore._();

  static final ActiveCounselorStore instance = ActiveCounselorStore._();

  static const _key = 'active_counselor';

  /// Header buttons ask on every screen; once this fresh, they don't.
  static const _freshFor = Duration(minutes: 2);

  bool _known = false;
  ActiveCounselor? _counselor;
  DateTime? _checkedAt;
  bool _restored = false;
  Future<void>? _refreshing;

  /// Bumped by [clear]; a lookup started before it is dropped.
  int _session = 0;

  /// False until the first answer, from disk or the server.
  bool get isKnown => _known;
  ActiveCounselor? get counselor => _counselor;

  /// Brings the answer up to date, unless it was checked moments ago.
  /// [force] asks the server regardless, as after a purchase.
  Future<void> refresh(
    ConsultantRepository repository, {
    bool force = false,
  }) {
    final checkedAt = _checkedAt;
    if (!force &&
        checkedAt != null &&
        DateTime.now().difference(checkedAt) < _freshFor) {
      return Future.value();
    }
    return _refreshing ??= _refresh(repository).whenComplete(() {
      _refreshing = null;
    });
  }

  Future<void> _refresh(ConsultantRepository repository) async {
    final session = _session;
    await _restore();
    try {
      final counselor = await repository.fetchMyActiveCounselor();
      // Logged out meanwhile: the answer belongs to the old account.
      if (session != _session) return;
      set(counselor);
    } catch (error) {
      // Keep the last answer; the next screen asks again.
      debugPrint('Active counselor lookup failed: $error');
    }
  }

  /// Records an answer another screen already fetched.
  void set(ActiveCounselor? counselor) {
    _checkedAt = DateTime.now();
    final changed = !_known || !_same(_counselor, counselor);
    _known = true;
    _counselor = counselor;
    if (changed) notifyListeners();
    _save(counselor);
  }

  /// Forgets the counselor, as on logout.
  Future<void> clear() async {
    _session++;
    _refreshing = null;
    _known = false;
    _counselor = null;
    _checkedAt = null;
    _restored = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }

  Future<void> _restore() async {
    if (_restored) return;
    _restored = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || _known) return;
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return;
      _known = true;
      _counselor = json['userID'] is String
          ? ActiveCounselor(
              userID: json['userID'] as String,
              avatar: json['avatar'] as String? ?? '',
              name: json['name'] as String?,
              username: json['username'] as String?,
              title: json['title'] as String?,
            )
          : null;
      notifyListeners();
    } catch (error) {
      debugPrint('Active counselor cache unreadable: $error');
    }
  }

  void _save(ActiveCounselor? counselor) {
    SharedPreferences.getInstance().then((prefs) {
      return prefs.setString(
        _key,
        jsonEncode(counselor == null
            ? const {}
            : {
                'userID': counselor.userID,
                'avatar': counselor.avatar,
                'name': counselor.name,
                'username': counselor.username,
                'title': counselor.title,
              }),
      );
    }).catchError((Object error) {
      debugPrint('Active counselor not cached: $error');
      return false;
    });
  }

  static bool _same(ActiveCounselor? a, ActiveCounselor? b) =>
      a?.userID == b?.userID && a?.avatar == b?.avatar && a?.name == b?.name;

  @visibleForTesting
  void debugReset() {
    _known = false;
    _counselor = null;
    _checkedAt = null;
    _restored = false;
    _refreshing = null;
  }
}
