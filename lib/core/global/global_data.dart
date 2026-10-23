import 'dart:async';

import 'package:flutter/foundation.dart';

import 'global_data_model.dart';

class GlobalData {
  GlobalData._();

  static final GlobalData instance = GlobalData._();

  /// How long loaded parent tags are trusted before [refreshParentTags]
  /// asks again.
  static const Duration parentTagsMaxAge = Duration(minutes: 5);

  List<ParentTagModel> parentTags = [];

  /// Loads [parentTags] from the server; set once at start-up.
  Future<void> Function()? loadParentTags;

  DateTime? _parentTagsLoadedAt;
  Future<void>? _loading;

  void setParentTags(List<ParentTagModel> tags) {
    parentTags = tags;
    _parentTagsLoadedAt = DateTime.now();
  }

  /// Reloads [parentTags] in the background when older than
  /// [parentTagsMaxAge]. Admins rename, merge and demote parent tags, and a
  /// stale name would be saved as a new tag of the user's own.
  void refreshParentTags() {
    final load = loadParentTags;
    if (load == null || _loading != null) return;
    final loadedAt = _parentTagsLoadedAt;
    if (loadedAt != null &&
        DateTime.now().difference(loadedAt) < parentTagsMaxAge) {
      return;
    }
    _loading = load().catchError((Object error) {
      debugPrint('Failed refreshing parent tags: $error');
    }).whenComplete(() => _loading = null);
  }

  void clear() {
    parentTags.clear();
    _parentTagsLoadedAt = null;
  }
}
