import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/widgets/net_image.dart';
import 'package:simo_learn/utils/image_disk_cache.dart';

// A real picture from the app's assets.
final _png = File('assets/images/empty_list_friends.png').readAsBytesSync();

const _url = 'https://api.saimo.app/uploads/avatars/a/b.jpg';

void main() {
  late Directory dir;
  late int downloads;

  ImageDiskCache cacheIn(Directory d, {Uint8List? bytes, bool fail = false}) =>
      ImageDiskCache(
        directory: () async => d,
        fetch: (url, onProgress) async {
          downloads++;
          if (fail) throw const SocketException('offline');
          onProgress(10, 67);
          return bytes ?? _png;
        },
      );

  setUp(() {
    dir = Directory.systemTemp.createTempSync('net_image_test');
    downloads = 0;
  });
  tearDown(() => dir.deleteSync(recursive: true));

  group('ImageDiskCache', () {
    test('downloads once, then serves from disk, also after a restart',
        () async {
      final first = cacheIn(dir);
      expect(await first.load(_url), _png);
      expect(await first.load(_url), _png);
      expect(downloads, 1);

      // A new instance stands for the next app launch.
      final relaunched = cacheIn(dir);
      expect(await relaunched.cached(_url), _png);
      expect(await relaunched.load(_url), _png);
      expect(downloads, 1);
    });

    test('several requests for the same picture share one download',
        () async {
      final cache = cacheIn(dir);
      final results = await Future.wait([
        cache.load(_url),
        cache.load(_url),
        cache.load(_url),
      ]);
      expect(results, everyElement(_png));
      expect(downloads, 1);
    });

    test('a failed download stores nothing and is retried next time',
        () async {
      await expectLater(cacheIn(dir, fail: true).load(_url),
          throwsA(isA<SocketException>()));
      expect(await cacheIn(dir).cached(_url), isNull);
      expect(await cacheIn(dir).load(_url), _png);
      expect(downloads, 2);
    });

    test('prune drops old files, then the least recently used over the limit',
        () async {
      final cache = ImageDiskCache(
        directory: () async => dir,
        fetch: (_, __) async => _png,
        maxBytes: 250,
        trimToBytes: 150,
        maxAge: const Duration(days: 60),
      );
      final now = DateTime.now();
      File write(String name, int size, Duration age) {
        final f = File('${dir.path}/$name')..writeAsBytesSync(List.filled(size, 1));
        f.setLastModifiedSync(now.subtract(age));
        return f;
      }

      final ancient = write('ancient', 10, const Duration(days: 90));
      final oldest = write('oldest', 100, const Duration(days: 5));
      final older = write('older', 100, const Duration(days: 3));
      final newest = write('newest', 100, const Duration(days: 1));
      final leftover = write('x.part', 10, const Duration(hours: 2));

      await cache.prune();

      expect(ancient.existsSync(), isFalse);
      expect(leftover.existsSync(), isFalse);
      expect(oldest.existsSync(), isFalse);
      expect(older.existsSync(), isFalse);
      expect(newest.existsSync(), isTrue);
    });
  });

  // File reads and decoding never finish under the test's fake clock, so the
  // picture is resolved for real first; the widget then finds it in the
  // image cache.
  Future<void> resolveReal(WidgetTester tester, ImageProvider provider) async {
    await tester.runAsync(() async {
      final done = Completer<void>();
      provider.resolve(ImageConfiguration.empty).addListener(ImageStreamListener(
            (_, __) { if (!done.isCompleted) done.complete(); },
            onError: (_, __) { if (!done.isCompleted) done.complete(); },
          ));
      await done.future.timeout(const Duration(seconds: 10));
    });
  }

  testWidgets('shows the picture from the disk cache', (tester) async {
    final cache = cacheIn(dir);
    await tester.runAsync(() => cache.load(_url));
    expect(downloads, 1);

    final provider = CachedNetImage(_url, cache: cache);
    await resolveReal(tester, provider);
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.rtl,
      child: Image(
        image: provider,
        width: 20,
        height: 20,
        errorBuilder: (_, __, ___) => const Text('error'),
      ),
    ));
    await tester.pump();

    expect(find.text('error'), findsNothing);
    expect(tester.widget<RawImage>(find.byType(RawImage)).image, isNotNull);
    expect(downloads, 1);
  });

  testWidgets('a failed download reports an error', (tester) async {
    final cache = cacheIn(dir, fail: true);
    Object? error;
    await tester.runAsync(() async {
      final done = Completer<void>();
      CachedNetImage('$_url?fail', cache: cache)
          .resolve(ImageConfiguration.empty)
          .addListener(ImageStreamListener((_, __) => done.complete(),
              onError: (e, _) { error = e; done.complete(); }));
      await done.future.timeout(const Duration(seconds: 10));
    });
    expect(error, isA<SocketException>());
  });
}
