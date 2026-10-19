import 'dart:convert';
import 'dart:js_interop';

import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

const bool canCheckServedRelease = true;

/// The release the server hands out now, as "version+build" from the
/// version.json that `flutter build web` writes; null when it can't be read.
Future<String?> fetchServedRelease() async {
  final base = Uri.parse(web.document.baseURI);
  // The query keeps any cache on the way from answering with an old copy.
  final url = base.resolve(
    'version.json?t=${DateTime.now().millisecondsSinceEpoch}',
  );
  final response = await http.get(url);
  if (response.statusCode != 200) return null;
  final json = jsonDecode(response.body);
  if (json is! Map) return null;
  final version = json['version'];
  if (version is! String || version.isEmpty) return null;
  final build = json['build_number'];
  return build is String && build.isNotEmpty ? '$version+$build' : version;
}

/// Reloads onto the release the server has now. Clears what older builds may
/// have stored on their own first (Flutter's old service worker and its
/// caches), so nothing can serve the old files again.
Future<void> reloadToLatestRelease() async {
  try {
    final registrations =
        (await web.window.navigator.serviceWorker.getRegistrations().toDart)
            .toDart;
    for (final registration in registrations) {
      await registration.unregister().toDart;
    }
  } catch (_) {
    // No service workers here (e.g. an insecure origin); nothing to clear.
  }
  try {
    final caches = web.window.caches;
    final names = (await caches.keys().toDart).toDart;
    for (final name in names) {
      await caches.delete(name.toDart).toDart;
    }
  } catch (_) {
    // No Cache Storage here; nothing to clear.
  }
  await _refetchAppFiles();
  web.window.location.reload();
}

/// The files that decide which build starts. Their names stay the same every
/// release, so the browser's HTTP cache (which no script can clear) may still
/// hold the old ones; fetching them with `cache: 'reload'` puts the new ones
/// in their place before the page reloads onto them.
const _appFiles = [
  '',
  'index.html',
  'flutter_bootstrap.js',
  'main.dart.wasm',
  'main.dart.mjs',
  'main.dart.js',
  'version.json',
];

Future<void> _refetchAppFiles() async {
  final base = Uri.parse(web.document.baseURI);
  await Future.wait([
    for (final file in _appFiles) _refetch(base.resolve(file)),
  ]).timeout(const Duration(seconds: 20), onTimeout: () => const []);
}

Future<void> _refetch(Uri url) async {
  try {
    final response = await web.window
        .fetch(url.toString().toJS, web.RequestInit(cache: 'reload'))
        .toDart;
    // The cache keeps the file once its body has been read in full.
    await response.arrayBuffer().toDart;
  } catch (_) {
    // A file this build does not have (e.g. main.dart.js) or a dropped
    // connection must not keep the page from reloading.
  }
}
