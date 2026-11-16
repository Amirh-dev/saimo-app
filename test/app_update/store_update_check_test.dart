import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/data/app_update/store_update_check.dart';
import 'package:simo_learn/presentation/widgets/store_update_gate.dart';

class _MemoryStorage implements StoreUpdateStorage {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String? value) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }
}

class _Server {
  StoreUpdatePolicy? policy;
  bool fails = false;
  bool opensSucceed = true;
  final targets = <StoreUpdateTarget>[];
}

StoreUpdateCheck _check(
  _Server server, {
  String running = '1.0.43',
  _MemoryStorage? storage,
}) {
  return StoreUpdateCheck(
    fetchPolicy: () async {
      if (server.fails) throw Exception('offline');
      return server.policy;
    },
    runningVersion: () async => running,
    storage: storage ?? _MemoryStorage(),
    openUpdate: (_, target) async {
      server.targets.add(target);
      return server.opensSucceed;
    },
  );
}

const _required = StoreUpdatePolicy(
  latestVersion: '1.0.50',
  minVersion: '1.0.50',
);

void main() {
  // start() listens for the app coming back.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('compareAppVersions', () {
    test('compares numerically, part by part', () {
      expect(compareAppVersions('1.0.43', '1.0.43'), 0);
      expect(compareAppVersions('1.0.9', '1.0.10'), lessThan(0));
      expect(compareAppVersions('1.1', '1.0.99'), greaterThan(0));
      expect(compareAppVersions('1.2', '1.2.0'), 0);
      expect(compareAppVersions('1.0.43+50', '1.0.43'), 0);
    });
  });

  group('StoreUpdateCheck', () {
    test('nothing required when the server sets nothing', () async {
      final server = _Server()..policy = const StoreUpdatePolicy();
      final check = _check(server);
      await check.start();
      expect(check.required, isFalse);
    });

    test('blocks a version below the required one', () async {
      final server = _Server()..policy = _required;
      final check = _check(server);
      await check.start();
      expect(check.required, isTrue);
    });

    test('the required version itself and newer ones run', () async {
      final server = _Server()..policy = _required;
      for (final running in ['1.0.50', '1.1.0']) {
        final check = _check(server, running: running);
        await check.start();
        expect(check.required, isFalse, reason: running);
      }
    });

    test('an unreachable server changes nothing', () async {
      final server = _Server()..fails = true;
      final check = _check(server);
      await check.start();
      expect(check.required, isFalse);
    });

    test('the block holds offline on the next launch', () async {
      final storage = _MemoryStorage();
      final server = _Server()..policy = _required;
      await _check(server, storage: storage).start();

      server.fails = true;
      final next = _check(server, storage: storage);
      await next.start();
      expect(next.required, isTrue);
    });

    test('a later answer lifts a stored block', () async {
      final storage = _MemoryStorage();
      final server = _Server()..policy = _required;
      await _check(server, storage: storage).start();

      server.policy = const StoreUpdatePolicy();
      final next = _check(server, storage: storage);
      await next.start();
      expect(next.required, isFalse);
    });

    test('reads the server answer', () {
      final policy = StoreUpdatePolicy.fromJson(jsonDecode('''{
        "latestVersion": "1.0.50", "minVersion": null, "message": " ",
        "apkDownloads": [
          {"abi": "arm64-v8a", "url": "https://x/a.apk"},
          {"abi": "armeabi-v7a", "url": ""}
        ]}'''))!;
      expect(policy.latestVersion, '1.0.50');
      expect(policy.minVersion, isNull);
      expect(policy.message, isNull);
      expect(policy.apkDownloads.map((d) => d.key), ['arm64-v8a']);
    });
  });

  group('StoreUpdateGate', () {
    Future<StoreUpdateCheck> pump(WidgetTester tester, _Server server) async {
      final check = _check(server);
      // Mounted as app.dart does: in MaterialApp.builder, over the app.
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => Stack(
            children: [child!, StoreUpdateGate(check: check)],
          ),
          home: const Scaffold(body: Text('home')),
        ),
      );
      await tester.runAsync(check.start);
      await tester.pumpAndSettle();
      return check;
    }

    Future<void> tapKey(WidgetTester tester, String key) async {
      // The short test screen scrolls.
      await tester.ensureVisible(find.byKey(ValueKey(key)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey(key)));
      await tester.pumpAndSettle();
    }

    testWidgets('shows nothing while this version is allowed', (tester) async {
      final server = _Server()
        ..policy = const StoreUpdatePolicy(latestVersion: '1.0.50');
      await pump(tester, server);
      expect(find.byKey(const ValueKey('store-update-gate')), findsNothing);
    });

    testWidgets(
        'covers the app, tells Bazaar users to uninstall first, '
        'and opens Google Play or the website', (tester) async {
      final server = _Server()
        ..policy = const StoreUpdatePolicy(
          latestVersion: '1.0.50',
          minVersion: '1.0.50',
          message: 'تایمر سریع‌تر شد.',
        );
      await pump(tester, server);
      expect(find.byKey(const ValueKey('store-update-gate')), findsOneWidget);
      expect(find.text('۱.۰.۵۰'), findsOneWidget);
      expect(find.text('تایمر سریع‌تر شد.'), findsOneWidget);
      expect(
        find.text(
          'اگه سایمو رو از بازار نصب کردی، اول اپ رو پاک کن و بعد از یکی از دو راه زیر نصبش کن.',
        ),
        findsOneWidget,
      );

      await tapKey(tester, 'store-update-play');
      await tapKey(tester, 'store-update-website');
      expect(server.targets,
          [StoreUpdateTarget.googlePlay, StoreUpdateTarget.website]);
    });

    testWidgets('says so when the download page does not open', (tester) async {
      final server = _Server()
        ..opensSucceed = false
        ..policy = _required;
      await pump(tester, server);
      await tapKey(tester, 'store-update-play');
      expect(
        find.text('باز کردن صفحه‌ی دانلود ناموفق بود. دوباره امتحان کن.'),
        findsOneWidget,
      );
    });
  });
}
