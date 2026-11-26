import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The groups the sound panel lists the sounds under.
enum HallSoundGroup {
  nature('طبیعت'),
  places('مکان‌ها'),
  rhythm('کارها');

  const HallSoundGroup(this.label);
  final String label;
}

/// One looping background sound of the study hall window.
class HallSound {
  const HallSound(this.id, this.name, this.group, {this.defaultVolume = .6});

  final String id;
  final String name;
  final HallSoundGroup group;

  /// Where the slider starts the first time the sound is switched on.
  final double defaultVolume;

  String get asset => 'assets/sounds/$id.m4a';
}

/// Every sound the window offers, in the order the panel shows them.
/// Sources and licenses (all CC0): docs/design/study-hall/SOUNDS.md.
const hallSounds = <HallSound>[
  HallSound('rain', 'بارون', HallSoundGroup.nature),
  HallSound('thunder', 'رعد و بارون', HallSoundGroup.nature),
  HallSound('sea', 'دریا', HallSoundGroup.nature),
  HallSound('river', 'رودخونه', HallSoundGroup.nature),
  HallSound('forest_day', 'جنگل روز', HallSoundGroup.nature),
  // The user found the night forest a bit loud, so it starts quieter.
  HallSound('forest_night', 'جنگل شب', HallSoundGroup.nature, defaultVolume: .4),
  HallSound('wind', 'باد ملایم', HallSoundGroup.nature),
  HallSound('fireplace', 'شومینه', HallSoundGroup.places),
  HallSound('library', 'کتابخونه', HallSoundGroup.places),
  HallSound('cafe', 'کافه', HallSoundGroup.places),
  HallSound('keyboard', 'تایپ کیبورد', HallSoundGroup.rhythm, defaultVolume: .45),
  HallSound('clock', 'تیک‌تاک ساعت', HallSoundGroup.rhythm, defaultVolume: .4),
];

/// Plays the loops. The real one uses just_audio; tests pass a fake.
abstract class HallSoundPlayer {
  Future<void> start(HallSound sound, double volume);
  Future<void> setVolume(HallSound sound, double volume);
  Future<void> stop(HallSound sound);
  Future<void> dispose();
}

/// One just_audio player per sound that is on, looping its file.
class JustAudioHallSoundPlayer implements HallSoundPlayer {
  final _players = <String, AudioPlayer>{};

  // Sliders feel even when loudness follows the square of their position.
  static double _gain(double v) => v * v;

  @override
  Future<void> start(HallSound sound, double volume) async {
    if (_players.containsKey(sound.id)) return setVolume(sound, volume);
    final player = AudioPlayer();
    _players[sound.id] = player;
    await player.setAsset(sound.asset);
    await player.setLoopMode(LoopMode.one);
    await player.setVolume(_gain(volume));
    // play() completes only when playback stops, so it is not awaited.
    unawaited(player.play());
  }

  @override
  Future<void> setVolume(HallSound sound, double volume) async =>
      _players[sound.id]?.setVolume(_gain(volume));

  @override
  Future<void> stop(HallSound sound) async =>
      _players.remove(sound.id)?.dispose();

  @override
  Future<void> dispose() async {
    for (final p in _players.values) {
      await p.dispose();
    }
    _players.clear();
  }
}

/// Which sounds are on and how loud, kept across app starts.
class HallSoundMixer extends ChangeNotifier {
  HallSoundMixer({HallSoundPlayer? player})
      : _player = player ?? JustAudioHallSoundPlayer();

  /// One mix for the whole app, so the sounds keep playing while you move
  /// between the desk and other screens with the timer running.
  static final HallSoundMixer shared = HallSoundMixer();

  static const _prefsKey = 'hall_sounds_v1';

  final HallSoundPlayer _player;
  final _on = <String>{};
  final _volume = <String, double>{};

  bool isOn(HallSound s) => _on.contains(s.id);
  double volumeOf(HallSound s) => _volume[s.id] ?? s.defaultVolume;
  int get onCount => _on.length;

  /// Restores the last mix. Sounds start playing only when [play] is true,
  /// so opening the screen doesn't make noise unless the user wants it.
  Future<void> restore({bool play = false}) async {
    final raw = (await SharedPreferences.getInstance()).getString(_prefsKey);
    if (raw == null) return;
    final saved = jsonDecode(raw) as Map<String, dynamic>;
    for (final e in (saved['volume'] as Map<String, dynamic>? ?? {}).entries) {
      _volume[e.key] = (e.value as num).toDouble().clamp(0.0, 1.0);
    }
    final on = (saved['on'] as List? ?? []).cast<String>();
    for (final s in hallSounds.where((s) => on.contains(s.id))) {
      _on.add(s.id);
      if (play) await _player.start(s, volumeOf(s));
    }
    notifyListeners();
  }

  Future<void> toggle(HallSound s) async {
    if (_on.remove(s.id)) {
      notifyListeners();
      await _player.stop(s);
    } else {
      _on.add(s.id);
      notifyListeners();
      await _player.start(s, volumeOf(s));
    }
    await _save();
  }

  /// Moving a slider of a sound that is off switches it on.
  Future<void> setVolume(HallSound s, double v) async {
    _volume[s.id] = v.clamp(0.0, 1.0);
    final starting = _on.add(s.id);
    notifyListeners();
    if (starting) {
      await _player.start(s, volumeOf(s));
    } else {
      await _player.setVolume(s, volumeOf(s));
    }
  }

  /// Saved when a drag ends, not on every frame of it.
  Future<void> commit() => _save();

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode({'on': _on.toList(), 'volume': _volume}),
    );
  }

  @override
  void dispose() {
    unawaited(_player.dispose());
    super.dispose();
  }
}
