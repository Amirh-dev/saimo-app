import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/screens/study_hall/study_desk_screen.dart';

/// Frames of the window rain, to judge the motion by eye (SCREENSHOT_DIR).
void main() {
  final shotDir = Platform.environment['SCREENSHOT_DIR'];
  testWidgets('rain frames', skip: shotDir == null, (tester) async {
    const frames = [0.0, 0.05, 0.10, 6.2, 7.04, 7.3, 59.95];
    tester.view
      ..physicalSize = Size(202.0 * frames.length, 178 * 2)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Widget pane(double t, bool day) => Container(
          width: 194,
          height: 170,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: day ? const [Color(0xFF9FAABB), Color(0xFFC9D0DA)] : const [Color(0xFF0E1030), Color(0xFF2A2C5C)],
            ),
          ),
          child: hallRainFrame(t, day: day, thunder: true),
        );
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        key: const ValueKey('shot'),
        child: Column(children: [
          for (final day in [false, true]) ...[
            Row(children: [
              for (final t in frames) ...[pane(t, day), const SizedBox(width: 8)],
            ]),
            const SizedBox(height: 8),
          ],
        ]),
      ),
    ));
    final b = tester.renderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('shot')));
    final png = await tester.runAsync(() async {
      final image = await b.toImage(pixelRatio: 2);
      return (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    });
    File('$shotDir/rain_frames.png').writeAsBytesSync(png!);
  });
}
