import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/features/study_hall/hall_avatar.dart';
import 'package:simo_learn/features/study_hall/hall_presets.dart';
import 'package:simo_learn/presentation/screens/study_hall/avatar_builder_screen.dart';

import '../tasks/support/app_fonts.dart';

void main() {
  test('avatars survive a round trip through json', () {
    for (final a in [...hallBoyPresets, ...hallGirlPresets]) {
      final b = HallAvatar.fromJson(a.toJson());
      expect(hallAvatarSvg(b), hallAvatarSvg(a));
    }
    expect(HallAvatar.fallback.boy, isTrue);
  });

  final shotDir = Platform.environment['SCREENSHOT_DIR'];
  testWidgets('gallery', skip: shotDir == null, (tester) async {
    tester.view
      ..physicalSize = const Size(600, 560)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Widget cell(HallAvatar a) => Container(
          width: 64,
          height: 74,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFE7B0), Color(0xFFFFC566)])),
          clipBehavior: Clip.antiAlias,
          child: SvgPicture.string(hallAvatarSvg(a), alignment: Alignment.bottomCenter),
        );
    await tester.pumpWidget(MaterialApp(
      home: RepaintBoundary(
        key: const ValueKey('shot'),
        child: ColoredBox(
          color: Colors.white,
          child: Column(children: [
            const SizedBox(height: 8),
            Wrap(children: [cell(HallAvatar.fallback), for (final a in hallBoyPresets) cell(a)]),
            const SizedBox(height: 14),
            Wrap(children: [for (final a in hallGirlPresets) cell(a)]),
          ]),
        ),
      ),
    ));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    final b = tester.renderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('shot')));
    final png = await tester.runAsync(() async {
      final image = await b.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    });
    File('$shotDir/avatar_gallery.png').writeAsBytesSync(png!);
  });
  testWidgets('builder screenshots', skip: shotDir == null, (tester) async {
    await tester.runAsync(loadAppFonts);
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Future<void> shoot(String name) async {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await tester.pump();
      final b = tester.renderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('shot')));
      final png = await tester.runAsync(() async {
        final image = await b.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      });
      File('$shotDir/$name.png').writeAsBytesSync(png!);
    }

    await tester.pumpWidget(const MaterialApp(home: RepaintBoundary(key: ValueKey('shot'), child: AvatarBuilderScreen(initial: HallAvatar.fallback))));
    await tester.pumpAndSettle();
    await shoot('builder_ready');
    await tester.tap(find.byKey(const ValueKey('builder-cat-face')));
    await tester.pumpAndSettle();
    await shoot('builder_face');
  });
}
