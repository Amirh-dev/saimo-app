import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/install/home_screen_install.dart';
import 'package:simo_learn/presentation/screens/dashboard/install_card.dart';

import '../tasks/support/app_fonts.dart';

/// Stands in for the browser.
class _Browser {
  bool installed = false;
  bool ios = false;
  bool offer = false;
  bool accept = true;
  int prompts = 0;
  VoidCallback? listener;

  Future<bool> prompt() async {
    prompts++;
    offer = false;
    return accept;
  }

  /// The browser makes (or withdraws) its install offer later on.
  void change() => listener?.call();
}

HomeScreenInstall _install(_Browser browser, {DateTime Function()? now}) =>
    HomeScreenInstall(
      enabled: true,
      runsInstalled: () => browser.installed,
      runsOnIos: () => browser.ios,
      canPrompt: () => browser.offer,
      prompt: browser.prompt,
      onChange: (listener) => browser.listener = listener,
      now: now,
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('HomeScreenInstall', () {
    test('offers the browser dialog once the browser has one', () async {
      final browser = _Browser();
      final install = _install(browser);
      await install.start();
      expect(install.offer, InstallOffer.none);

      browser
        ..offer = true
        ..change();
      expect(install.offer, InstallOffer.prompt);
    });

    test('shows the Safari steps on iOS', () async {
      final install = _install(_Browser()..ios = true);
      await install.start();
      expect(install.offer, InstallOffer.iosSteps);
    });

    test('offers nothing when opened from the home screen', () async {
      final install = _install(
        _Browser()
          ..installed = true
          ..ios = true
          ..offer = true,
      );
      await install.start();
      expect(install.offer, InstallOffer.none);
    });

    test('offers nothing off the web', () async {
      final browser = _Browser()..offer = true;
      final install = HomeScreenInstall(
        enabled: false,
        runsInstalled: () => false,
        runsOnIos: () => false,
        canPrompt: () => browser.offer,
        prompt: browser.prompt,
        onChange: (_) {},
      );
      await install.start();
      expect(install.offer, InstallOffer.none);
    });

    test('an accepted install hides the card', () async {
      final browser = _Browser()..offer = true;
      final install = _install(browser);
      await install.start();
      await install.install();
      expect(browser.prompts, 1);
      expect(install.offer, InstallOffer.none);
    });

    test('«بعداً» hides the card for a week, across visits', () async {
      var now = DateTime(2026, 11, 5, 10);
      final browser = _Browser()..ios = true;
      final install = _install(browser, now: () => now);
      await install.start();
      await install.dismiss();
      expect(install.offer, InstallOffer.none);

      final nextVisit = _install(browser, now: () => now);
      now = now.add(const Duration(days: 6));
      await nextVisit.start();
      expect(nextVisit.offer, InstallOffer.none);

      now = now.add(const Duration(days: 1));
      expect(nextVisit.offer, InstallOffer.iosSteps);
    });
  });

  group('InstallAppCard', () {
    testWidgets('takes no space with nothing to offer', (tester) async {
      final install = _install(_Browser());
      await install.start();
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: InstallAppCard(install: install))),
      );
      expect(find.byKey(const ValueKey('install-card')), findsNothing);
    });

    testWidgets('«نصب» opens the browser dialog and «بعداً» hides it',
        (tester) async {
      final browser = _Browser()
        ..offer = true
        ..accept = false;
      final install = _install(browser);
      await tester.runAsync(install.start);
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: InstallAppCard(install: install))),
      );
      expect(find.text('نصب'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('install-action')));
      await tester.pumpAndSettle();
      expect(browser.prompts, 1);

      browser
        ..offer = true
        ..change();
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const ValueKey('install-dismiss')));
      });
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('install-card')), findsNothing);
    });

    testWidgets('on iOS the button opens the Safari steps', (tester) async {
      final install = _install(_Browser()..ios = true);
      await tester.runAsync(install.start);
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: InstallAppCard(install: install))),
      );
      await tester.tap(find.text('روش نصب'));
      await tester.pumpAndSettle();
      expect(find.text('نصب سایمو روی آیفون'), findsOneWidget);
    });
  });

  // Renders the card and the iOS sheet with real fonts for review. Run with
  // SCREENSHOT_DIR set.
  final shotDir = Platform.environment['SCREENSHOT_DIR'];
  group('screenshots', skip: shotDir == null, () {
    Future<void> shoot(WidgetTester tester, String name) async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('shot')),
      );
      final bytes = await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      });
      File('$shotDir/$name.png').writeAsBytesSync(bytes!);
    }

    for (final ios in [false, true]) {
      testWidgets('card ${ios ? 'ios' : 'android'}', (tester) async {
        await tester.runAsync(loadAppFonts);
        tester.view
          ..physicalSize = const Size(390, 760)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final install = _install(
          _Browser()
            ..ios = ios
            ..offer = !ios,
        );
        await tester.runAsync(install.start);
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'IRANSansVar'),
            // Above the navigator, so the sheet is in the picture too.
            builder: (context, child) => RepaintBoundary(
              key: const ValueKey('shot'),
              child: child,
            ),
            home: Builder(
              builder: (context) => Scaffold(
                backgroundColor: const Color(0xFFF5F5F9),
                body: Column(
                  children: [
                    // The home's white header: title, then the strip.
                    ColoredBox(
                      color: const Color(0xFFFCFCFC),
                      child: Column(
                        children: [
                          const SizedBox(height: 72),
                          InstallAppCard(install: install),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (!ios) {
          await shoot(tester, 'install_card_android');
          return;
        }
        await shoot(tester, 'install_card_ios');
        await tester.tap(find.text('روش نصب'));
        await tester.pumpAndSettle();
        await shoot(tester, 'install_sheet_ios');
      });
    }
  });
}
