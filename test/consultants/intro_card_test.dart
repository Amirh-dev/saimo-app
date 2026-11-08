import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/screens/consultants/intro_popup.dart';
import 'package:simo_learn/presentation/screens/consultants/intro_screen.dart';
import 'package:simo_learn/presentation/screens/consultants/plans_sheet.dart';

import '../tasks/support/app_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  test('the lowest price is the cheapest plan for its shortest time', () {
    expect(lowestPlanPrice(), 1190000);
  });

  test('the popup waits five days after the app is first opened', () {
    expect(ConsultantIntroPopup.gracePeriod, const Duration(days: 5));
  });

  testWidgets('the intro card quotes the real lowest price', (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: RepaintBoundary(
        child: Scaffold(
          backgroundColor: Colors.black54,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ConsultantIntroCard(onStart: () {}, onClose: () {}),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final price = find.byKey(const ValueKey('consultant-intro-price'));
    for (final group in ['۱', '۱۹۰', '۰۰۰']) {
      expect(find.descendant(of: price, matching: find.text(group)),
          findsOneWidget);
    }
    expect(find.text('۴۹۹'), findsNothing);

    const dir = String.fromEnvironment('SHOT_DIR');
    if (dir.isNotEmpty) {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byType(RepaintBoundary).first);
      final bytes = await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      });
      File('$dir/consultant-intro.png').writeAsBytesSync(bytes!);
    }
  });
}
