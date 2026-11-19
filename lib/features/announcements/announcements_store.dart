import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:simo_learn/features/announcements/announcements_repository.dart';

/// The unread message count (the bell's badge) and the home header card,
/// shared by every header. Refreshed on login, when the app comes back, on
/// returning to the home tab and when a message push arrives.
class AnnouncementsStore extends ChangeNotifier {
  AnnouncementsStore._();

  static final AnnouncementsStore instance = AnnouncementsStore._();

  /// Headers ask on every screen; once this fresh, they don't.
  static const _freshFor = Duration(minutes: 1);

  AnnouncementsRepository? _repository;
  int _unread = 0;
  Announcement? _homeCard;
  DateTime? _checkedAt;
  Future<void>? _refreshing;

  /// Bumped by [clear]; a lookup started before it is dropped.
  int _session = 0;

  int get unreadCount => _unread;

  /// The signed-in user's inbox, or null when signed out.
  AnnouncementsRepository? get repository => _repository;
  Announcement? get homeCard => _homeCard;

  /// Set once the user is signed in; until then [refresh] does nothing.
  void attach(AnnouncementsRepository repository) => _repository = repository;

  Future<void> refresh({bool force = false}) {
    final repository = _repository;
    if (repository == null) return Future.value();
    final checkedAt = _checkedAt;
    if (!force && checkedAt != null && DateTime.now().difference(checkedAt) < _freshFor) {
      return Future.value();
    }
    return _refreshing ??= _refresh(repository).whenComplete(() => _refreshing = null);
  }

  Future<void> _refresh(AnnouncementsRepository repository) async {
    final session = _session;
    try {
      final inbox = await repository.inbox(limit: 0);
      if (session != _session) return;
      _checkedAt = DateTime.now();
      set(unreadCount: inbox.unreadCount, homeCard: inbox.homeCard);
    } catch (error) {
      // An older backend, or offline: keep what is shown.
      debugPrint('Announcements lookup failed: $error');
    }
  }

  @visibleForTesting
  void set({required int unreadCount, Announcement? homeCard}) {
    final changed = unreadCount != _unread || homeCard?.id != _homeCard?.id;
    _unread = unreadCount;
    _homeCard = homeCard;
    if (changed) notifyListeners();
  }

  /// The inbox was opened: everything in it is seen, so the badge and the
  /// home card go at once, before the server confirms.
  void markAllSeen() {
    final repository = _repository;
    set(unreadCount: 0);
    if (repository == null) return;
    unawaited(repository.markAllSeen().catchError((Object error) {
      debugPrint('Marking announcements seen failed: $error');
    }));
  }

  /// Records where a message was first opened; best effort.
  void reportOpened(String id, AnnouncementVia via) {
    unawaited(_repository?.reportOpened(id, via).catchError((Object _) {}));
  }

  void reportClicked(String id) {
    unawaited(_repository?.reportClicked(id).catchError((Object _) {}));
  }

  /// Forgets everything, as on logout.
  void clear() {
    _session++;
    _repository = null;
    _refreshing = null;
    _checkedAt = null;
    set(unreadCount: 0);
  }
}
