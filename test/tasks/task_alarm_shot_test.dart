import 'dart:io';
import 'dart:ui' show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/screens/tasks/task_alarm_screen.dart';

import 'support/app_fonts.dart';

/// Screenshots of the alarm page, night and day; set SHOT_DIR to write them.
void main() {
  final shotDir = Platform.environment['SHOT_DIR'];

  testWidgets('alarm page screenshots', (tester) async {
    await tester.runAsync(loadAppFonts);
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    Future<void> shoot(String name, Widget screen) async {
      await tester.pumpWidget(MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(key: const ValueKey('shot'), child: screen),
      ));
      await tester.pump();
      final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('shot')));
      final bytes = await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ImageByteFormat.png);
        return data!.buffer.asUint8List();
      });
      File('$shotDir/$name.png').writeAsBytesSync(bytes!);
    }

    await shoot(
      'alarm_night',
      TaskAlarmScreen(
        title: 'مرور خلاصه‌ی شیمی قبل از خواب',
        at: DateTime(2026, 11, 19, 22, 15),
        tagName: 'شیمی',
        onStart: () {},
        onSnooze: () {},
        onDismiss: () {},
        animate: false,
      ),
    );
    await shoot(
      'alarm_day',
      TaskAlarmScreen(
        title: 'تست زیست، فصل ۳',
        at: DateTime(2026, 11, 19, 16, 30),
        tagName: 'زیست‌شناسی',
        minutes: 45,
        onStart: () {},
        onSnooze: () {},
        onDismiss: () {},
        animate: false,
      ),
    );
  }, skip: shotDir == null);
}
