import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/features/study_hall/hall_sounds.dart';
import 'package:simo_learn/presentation/screens/study_hall/hall_sounds_screen.dart';
import 'package:simo_learn/presentation/screens/study_hall/suggest_sound_sheet.dart';

import '../tasks/support/app_fonts.dart';

class _FakePlayer implements HallSoundPlayer {
  final playing = <String, double>{};
  final log = <String>[];

  @override
  Future<void> start(HallSound s, double v) async {
    playing[s.id] = v;
    log.add('start ${s.id}');
  }

  @override
  Future<void> setVolume(HallSound s, double v) async => playing[s.id] = v;

  @override
  Future<void> stop(HallSound s) async {
    playing.remove(s.id);
    log.add('stop ${s.id}');
  }

  @override
  Future<void> dispose() async => playing.clear();
}

HallSound _sound(String id) => hallSounds.firstWhere((s) => s.id == id);

Widget _app(HallSoundMixer mixer, {Future<void> Function(String)? suggest}) => MaterialApp(
      builder: (context, child) =>
          RepaintBoundary(key: const ValueKey('shot'), child: child),
      home: HallSoundsScreen(mixer: mixer, suggest: suggest ?? (_) async {}),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('every sound has its file', () {
    for (final s in hallSounds) {
      expect(File(s.asset).existsSync(), isTrue, reason: s.asset);
    }
    expect(hallSounds.map((s) => s.id).toSet().length, hallSounds.length);
  });

  testWidgets('the switch starts and stops a sound', (tester) async {
    final player = _FakePlayer();
    final mixer = HallSoundMixer(player: player);
    await tester.pumpWidget(_app(mixer));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('hall-sound-switch-rain')));
    await tester.pumpAndSettle();
    expect(player.playing, {'rain': _sound('rain').defaultVolume});
    expect(find.text('۱ صدا روشن'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('hall-sound-switch-rain')));
    await tester.pumpAndSettle();
    expect(player.playing, isEmpty);
    expect(player.log, ['start rain', 'stop rain']);
  });

  testWidgets('dragging the slider of a sound that is off turns it on', (tester) async {
    final player = _FakePlayer();
    final mixer = HallSoundMixer(player: player);
    await tester.pumpWidget(_app(mixer));
    await tester.pumpAndSettle();

    final slider = find.byKey(const ValueKey('hall-sound-slider-sea'));
    // Pressing the middle of the track first jumps to 0.5; RTL: dragging
    // left from there makes it louder.
    await tester.drag(slider, const Offset(-60, 0));
    await tester.pumpAndSettle();
    expect(mixer.isOn(_sound('sea')), isTrue);
    expect(player.playing.containsKey('sea'), isTrue);
    expect(mixer.volumeOf(_sound('sea')), greaterThan(.55));
  });

  test('the mix is kept and restored', () async {
    final first = HallSoundMixer(player: _FakePlayer());
    await first.toggle(_sound('fireplace'));
    await first.setVolume(_sound('fireplace'), .3);
    await first.commit();

    final player = _FakePlayer();
    final second = HallSoundMixer(player: player);
    await second.restore(play: true);
    expect(second.isOn(_sound('fireplace')), isTrue);
    expect(second.volumeOf(_sound('fireplace')), closeTo(.3, 1e-9));
    expect(player.playing, {'fireplace': closeTo(.3, 1e-9)});

    final quiet = HallSoundMixer(player: _FakePlayer());
    await quiet.restore();
    expect(quiet.isOn(_sound('fireplace')), isTrue);
  });

  testWidgets('a sound suggestion goes out from the sheet', (tester) async {
    final sent = <String>[];
    await tester.pumpWidget(_app(HallSoundMixer(player: _FakePlayer()), suggest: (b) async => sent.add(b)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const ValueKey('hall-sound-suggest')), 200);
    await tester.tap(find.byKey(const ValueKey('hall-sound-suggest')));
    await tester.pumpAndSettle();
    expect(find.text('پیشنهاد صدا'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('suggest-sound-text')), 'ب');
    await tester.tap(find.byKey(const ValueKey('suggest-sound-send')));
    await tester.pumpAndSettle();
    expect(find.text('یه کم بیشتر بنویس.'), findsOneWidget);
    expect(sent, isEmpty);

    await tester.enterText(find.byKey(const ValueKey('suggest-sound-text')), '  صدای قطار شب  ');
    await tester.tap(find.byKey(const ValueKey('suggest-sound-send')));
    await tester.pumpAndSettle();
    expect(sent, ['صدای قطار شب']);
    expect(find.text('پیشنهاد صدا'), findsNothing);
    await tester.pump(const Duration(seconds: 10));
  });

  test('the suggestion is marked as a sound request', () {
    expect(soundSuggestionPrefix, contains('صدا'));
  });

  test('the night forest starts quieter', () {
    final mixer = HallSoundMixer(player: _FakePlayer());
    expect(mixer.volumeOf(_sound('forest_night')), .4);
  });

  final shotDir = Platform.environment['SCREENSHOT_DIR'];
  testWidgets('screenshot', skip: shotDir == null, (tester) async {
    await tester.runAsync(loadAppFonts);
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final mixer = HallSoundMixer(player: _FakePlayer());
    await mixer.toggle(_sound('rain'));
    await mixer.toggle(_sound('fireplace'));
    await mixer.setVolume(_sound('fireplace'), .35);
    await mixer.toggle(_sound('clock'));
    await tester.pumpWidget(_app(mixer));
    await tester.pumpAndSettle();
    Future<void> shoot(String name) async {
      final b = tester.renderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('shot')));
      final png = await tester.runAsync(() async {
        final image = await b.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      });
      File('$shotDir/$name.png').writeAsBytesSync(png!);
    }

    final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('shot')));
    final bytes = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    });
    File('$shotDir/hall_sounds.png').writeAsBytesSync(bytes!);

    await tester.scrollUntilVisible(find.byKey(const ValueKey('hall-sound-suggest')), 200);
    await tester.pumpAndSettle();
    await shoot('hall_sounds_end');
    await tester.tap(find.byKey(const ValueKey('hall-sound-suggest')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('suggest-sound-text')), 'صدای بازار قدیمی');
    await tester.pumpAndSettle();
    await shoot('hall_sounds_suggest');
  });
}
