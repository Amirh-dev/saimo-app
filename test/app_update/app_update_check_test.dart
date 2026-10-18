import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/data/app_update/app_update_check.dart';
import 'package:simo_learn/presentation/widgets/app_update_banner.dart';

/// Answers version.json like the server, from whatever release is deployed.
class _Server {
  String? release = '1.0.18+40';
  bool down = false;
  int reloads = 0;

  Future<String?> fetch() async {
    if (down) throw Exception('offline');
    return release;
  }

  Future<void> reload() async => reloads++;
}

AppUpdateCheck _check(_Server server, {String? running}) => AppUpdateCheck(
      fetchRelease: server.fetch,
      reload: server.reload,
      runningRelease: running,
    );

void main() {
  group('AppUpdateCheck', () {
    test('the release this build was stamped with is not an update', () async {
      final server = _Server();
      final check = _check(server, running: '1.0.18+40');
      await check.check();
      expect(check.available, isFalse);
    });

    test('a newer release on the server is offered', () async {
      final server = _Server()..release = '1.0.19+41';
      final check = _check(server, running: '1.0.18+40');
      await check.check();
      expect(check.available, isTrue);
    });

    test('an unstamped build takes the first release it sees as its own',
        () async {
      final server = _Server();
      final check = _check(server);
      await check.check();
      expect(check.available, isFalse);

      server.release = '1.0.19+41';
      await check.check();
      expect(check.available, isTrue);
    });

    test('a failed or empty answer changes nothing', () async {
      final server = _Server()..down = true;
      final check = _check(server, running: '1.0.18+40');
      await check.check();
      expect(check.available, isFalse);

      server
        ..down = false
        ..release = null;
      await check.check();
      expect(check.available, isFalse);
    });

    test('a waved-off release stays hidden until a newer one comes out',
        () async {
      final server = _Server()..release = '1.0.19+41';
      final check = _check(server, running: '1.0.18+40');
      await check.check();
      check.dismiss();
      expect(check.available, isFalse);

      await check.check();
      expect(check.available, isFalse);

      server.release = '1.0.20+42';
      await check.check();
      expect(check.available, isTrue);
    });

    test('update reloads onto the new release', () async {
      final server = _Server()..release = '1.0.19+41';
      final check = _check(server, running: '1.0.18+40');
      await check.check();
      await check.update();
      expect(server.reloads, 1);
    });
  });

  group('AppUpdateBanner', () {
    Future<AppUpdateCheck> pump(WidgetTester tester, _Server server) async {
      final check = _check(server, running: '1.0.18+40');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: AppUpdateBanner(check: check),
            ),
          ),
        ),
      );
      return check;
    }

    testWidgets('shows nothing while the running release is current',
        (tester) async {
      final server = _Server();
      final check = await pump(tester, server);
      await check.check();
      await tester.pumpAndSettle();
      expect(find.text('به‌روزرسانی'), findsNothing);
    });

    testWidgets('offers the new release and reloads on tap', (tester) async {
      final server = _Server()..release = '1.0.19+41';
      final check = await pump(tester, server);
      await check.check();
      await tester.pumpAndSettle();
      expect(find.text('نسخه‌ی جدید آماده است'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('app-update-reload')));
      await tester.pumpAndSettle();
      expect(server.reloads, 1);
    });

    testWidgets('closing it hides the offer', (tester) async {
      final server = _Server()..release = '1.0.19+41';
      final check = await pump(tester, server);
      await check.check();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('app-update-dismiss')));
      await tester.pumpAndSettle();
      expect(find.text('به‌روزرسانی'), findsNothing);
    });
  });
}
