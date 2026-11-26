import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Downloads one picture, reporting bytes received (and the total, when the
/// server sends it).
typedef ImageFetch = Future<Uint8List> Function(
  String url,
  void Function(int received, int? total) onProgress,
);

/// Keeps downloaded pictures on disk, so a picture seen once (a counselor's
/// photo, a note cover) opens instantly on every later visit and app launch
/// instead of being downloaded again. Flutter's own `Image.network` keeps
/// pictures only in memory, so they were lost on every restart.
///
/// The server never reuses a picture's address (every upload gets a new
/// name), so a stored file never goes stale and is never re-checked. Files
/// unused for [maxAge] are dropped, and once the folder passes [maxBytes] the
/// least recently used ones go until it is under [trimToBytes]. Android may
/// also clear the folder itself when the phone runs low on space.
class ImageDiskCache {
  ImageDiskCache({
    required Future<Directory> Function() directory,
    ImageFetch? fetch,
    this.maxBytes = 150 * 1024 * 1024,
    this.trimToBytes = 100 * 1024 * 1024,
    this.maxAge = const Duration(days: 60),
  })  : _directory = directory,
        _fetch = fetch ?? _httpFetch;

  /// The app's cache, in the platform cache folder.
  static ImageDiskCache instance = ImageDiskCache(
    directory: () async {
      final base = await getApplicationCacheDirectory();
      return Directory('${base.path}${Platform.pathSeparator}net_images');
    },
  );

  final Future<Directory> Function() _directory;
  final ImageFetch _fetch;
  final int maxBytes;
  final int trimToBytes;
  final Duration maxAge;

  Future<Directory>? _dir;
  final Map<String, Future<Uint8List>> _inFlight = {};
  bool _pruned = false;

  /// The file name a picture is stored under.
  static String fileNameFor(String url) =>
      sha1.convert(utf8.encode(url)).toString();

  Future<Directory> _folder() => _dir ??= () async {
        final dir = await _directory();
        await dir.create(recursive: true);
        return dir;
      }();

  Future<File> _file(String url) async =>
      File('${(await _folder()).path}${Platform.pathSeparator}${fileNameFor(url)}');

  /// The stored picture, or null when it was never downloaded.
  Future<Uint8List?> cached(String url) async {
    try {
      final file = await _file(url);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return null;
      unawaited(_touch(file));
      return bytes;
    } on FileSystemException {
      return null;
    }
  }

  /// The picture from disk, or downloaded and stored when missing. Several
  /// widgets asking for the same picture at once share one download.
  Future<Uint8List> load(
    String url, {
    void Function(int received, int? total)? onProgress,
  }) {
    final running = _inFlight[url];
    if (running != null) return running;
    final future = _load(url, onProgress ?? (_, __) {});
    _inFlight[url] = future;
    return future.whenComplete(() => _inFlight.remove(url));
  }

  Future<Uint8List> _load(
    String url,
    void Function(int received, int? total) onProgress,
  ) async {
    final hit = await cached(url);
    if (hit != null) return hit;
    final bytes = await _fetch(url, onProgress);
    if (bytes.isEmpty) throw StateError('empty image: $url');
    await _store(url, bytes);
    if (!_pruned) {
      _pruned = true;
      unawaited(prune());
    }
    return bytes;
  }

  /// Forgets a stored picture, e.g. one that turned out to be unreadable.
  Future<void> remove(String url) async {
    try {
      final file = await _file(url);
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // Already gone or locked; the next download overwrites it.
    }
  }

  Future<void> _store(String url, Uint8List bytes) async {
    try {
      final file = await _file(url);
      // Written beside the final name and renamed, so a crash mid-write never
      // leaves a half picture that would be served from then on.
      final part = File('${file.path}.part');
      await part.writeAsBytes(bytes, flush: true);
      await part.rename(file.path);
    } on FileSystemException {
      // A full disk only costs the cache; the picture still shows.
    }
  }

  /// Marks a file as recently used (at most once a day) for [prune].
  Future<void> _touch(File file) async {
    try {
      final now = DateTime.now();
      final last = await file.lastModified();
      if (now.difference(last) > const Duration(days: 1)) {
        await file.setLastModified(now);
      }
    } on FileSystemException {
      // Only affects which file is dropped first.
    }
  }

  /// Drops old files and keeps the folder under [maxBytes].
  Future<void> prune() async {
    try {
      final dir = await _folder();
      final now = DateTime.now();
      final files = <(File, FileStat)>[];
      var total = 0;
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        final stat = await entity.stat();
        final stale = now.difference(stat.modified) > maxAge ||
            (entity.path.endsWith('.part') &&
                now.difference(stat.modified) > const Duration(hours: 1));
        if (stale) {
          await entity.delete();
          continue;
        }
        files.add((entity, stat));
        total += stat.size;
      }
      if (total <= maxBytes) return;
      files.sort((a, b) => a.$2.modified.compareTo(b.$2.modified));
      for (final (file, stat) in files) {
        if (total <= trimToBytes) break;
        await file.delete();
        total -= stat.size;
      }
    } on FileSystemException {
      // Tried again on the next launch.
    }
  }

  static final http.Client _client = http.Client();

  static Future<Uint8List> _httpFetch(
    String url,
    void Function(int received, int? total) onProgress,
  ) async {
    final response = await _client
        .send(http.Request('GET', Uri.parse(url)))
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('HTTP ${response.statusCode}', uri: Uri.parse(url));
    }
    final total = response.contentLength;
    final builder = BytesBuilder(copy: false);
    await for (final chunk
        in response.stream.timeout(const Duration(seconds: 30))) {
      builder.add(chunk);
      onProgress(builder.length, total);
    }
    return builder.takeBytes();
  }
}
