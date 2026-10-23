import 'dart:async';

import 'package:flutter/foundation.dart';

import 'global_data_model.dart';

class GlobalData {
  GlobalData._();

  static final GlobalData instance = GlobalData._();

  /// How long loaded parent tags are trusted before [refreshParentTags]
  /// asks again.
  static const Duration parentTagsMaxAge = Duration(minutes: 5);

  static const TagCatalog _noTags = (names: [], aliases: {}, children: {});

  List<ParentTagModel> parentTags = [];

  /// Every tag a user can pick from: [parentTags], the tags under them, and
  /// their other names. Task forms read it whenever they need it, so tags
  /// that load after a form opens are still offered.
  TagCatalog tagCatalog = _noTags;

  /// Loads [parentTags] from the server; set once at start-up.
  Future<void> Function()? loadParentTags;

  DateTime? _parentTagsLoadedAt;
  Future<void>? _loading;

  void setParentTags(List<ParentTagModel> tags) {
    parentTags = tags;
    tagCatalog = (
      names: [
        for (final tag in tags) ...[tag.name, ...tag.children],
      ],
      aliases: {
        for (final tag in tags)
          if (tag.aliases.isNotEmpty) tag.name: tag.aliases,
      },
      children: {
        for (final tag in tags)
          if (tag.children.isNotEmpty) tag.name: tag.children,
      },
    );
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
    tagCatalog = _noTags;
    _parentTagsLoadedAt = null;
  }
}
