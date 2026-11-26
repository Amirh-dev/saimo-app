import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simo_learn/features/study_hall/hall_sounds.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';

/// The «صدا» tab of the study hall window (design A in
/// docs/design/study-hall/sound-designs.html): every sound in a row with a
/// volume slider and a switch, grouped into nature, places and work rhythm.
class HallSoundPanel extends StatelessWidget {
  const HallSoundPanel({super.key, required this.mixer, this.padding, this.onSuggest});

  final HallSoundMixer mixer;
  final EdgeInsetsGeometry? padding;

  /// Shows the small «suggest a sound» row at the end when set.
  final VoidCallback? onSuggest;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    HallSoundGroup? group;
    for (final s in hallSounds) {
      if (s.group != group) {
        group = s.group;
        rows.add(_GroupLabel(group.label, first: rows.isEmpty));
      }
      rows.add(_SoundRow(sound: s, mixer: mixer));
    }
    if (onSuggest != null) rows.add(_SuggestRow(onTap: onSuggest!));
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListenableBuilder(
        listenable: mixer,
        builder: (context, _) => ListView(
          padding: padding ?? const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: rows,
        ),
      ),
    );
  }
}

class _SuggestRow extends StatelessWidget {
  const _SuggestRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Center(
          child: Material(
            color: AppColors.gray1,
            shape: const StadiumBorder(),
            child: InkWell(
              key: const ValueKey('hall-sound-suggest'),
              customBorder: const StadiumBorder(),
              onTap: onTap,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 17, color: Color(0xFF6B6B73)),
                    SizedBox(width: 6),
                    ReText(
                      'صدایی که می‌خوای نیست؟ پیشنهاد بده',
                      fontSize: 12.5,
                      fontWeight: 800,
                      color: Color(0xFF6B6B73),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text, {required this.first});

  final String text;
  final bool first;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(2, first ? 6 : 14, 2, 4),
        child: ReText(
          text,
          fontSize: 11.5,
          fontWeight: 900,
          color: AppColors.gray,
          textAlign: TextAlign.right,
        ),
      );
}

class _SoundRow extends StatelessWidget {
  const _SoundRow({required this.sound, required this.mixer});

  final HallSound sound;
  final HallSoundMixer mixer;

  @override
  Widget build(BuildContext context) {
    final on = mixer.isOn(sound);
    return Semantics(
      toggled: on,
      label: sound.name,
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => mixer.toggle(sound),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: on ? AppColors.black1 : AppColors.gray1,
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.string(
                      _icons[sound.id]!,
                      width: 19,
                      height: 19,
                      colorFilter: ColorFilter.mode(
                        on ? Colors.white : const Color(0xFF6B6B73),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 84,
                    child: ReText(
                      sound.name,
                      fontSize: 13,
                      fontWeight: 900,
                      color: AppColors.black1,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: on ? 1 : .4,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    activeTrackColor: AppColors.black1,
                    inactiveTrackColor: AppColors.gray2,
                    thumbColor: Colors.white,
                    overlayColor: AppColors.black1.withAlpha(20),
                    thumbShape: const _SoftThumb(),
                    trackShape: const RoundedRectSliderTrackShape(),
                  ),
                  child: Slider(
                    key: ValueKey('hall-sound-slider-${sound.id}'),
                    value: mixer.volumeOf(sound),
                    onChanged: (v) => mixer.setVolume(sound, v),
                    onChangeEnd: (_) => mixer.commit(),
                  ),
                ),
              ),
            ),
            GestureDetector(
              key: ValueKey('hall-sound-switch-${sound.id}'),
              onTap: () => mixer.toggle(sound),
              child: _Switch(value: on),
            ),
          ],
        ),
      ),
    );
  }
}

/// A white knob with a soft shadow (Material's elevation draws a hard ring).
class _SoftThumb extends SliderComponentShape {
  const _SoftThumb();

  static const double _r = 9;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_r);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(
      center + const Offset(0, 1.5),
      _r,
      Paint()
        ..color = const Color(0x3323232B)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(center, _r, Paint()..color = Colors.white);
  }
}

/// Same switch as the goal form: orange when on.
class _Switch extends StatelessWidget {
  const _Switch({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 40,
        height: 24,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.gray2,
          borderRadius: BorderRadius.circular(100),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 1))],
            ),
          ),
        ),
      ),
    );
  }
}

String _svg(String body) =>
    '<svg viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="1.8" '
    'stroke-linecap="round" stroke-linejoin="round">$body</svg>';

final _icons = <String, String>{
  'rain': _svg('<path d="M7 14a4 4 0 0 1 .5-8A5 5 0 0 1 17 7a3.5 3.5 0 0 1 0 7z"/><path d="M9 17l-1 2.5M13 17l-1 2.5M17 17l-1 2.5"/>'),
  'thunder': _svg('<path d="M7 13a4 4 0 0 1 .5-8A5 5 0 0 1 17 6a3.5 3.5 0 0 1 0 7"/><path d="M12 11l-2.5 5h4L11 21"/>'),
  'sea': _svg('<path d="M3 9q2.25-3 4.5 0t4.5 0 4.5 0 4.5 0M3 14q2.25-3 4.5 0t4.5 0 4.5 0 4.5 0M3 19q2.25-3 4.5 0t4.5 0 4.5 0 4.5 0"/>'),
  'river': _svg('<path d="M12 3c3 4 6 7 6 11a6 6 0 0 1-12 0c0-4 3-7 6-11z"/><path d="M9 14a3 3 0 0 0 3 3"/>'),
  'forest_day': _svg('<path d="M12 3l5 7h-3l4 6H6l4-6H7z"/><path d="M12 16v5"/>'),
  'forest_night': _svg('<path d="M9 4l4 6h-2.5l3.5 5H4l3.5-5H5z"/><path d="M9 15v5"/><path d="M19 3a3 3 0 1 0 2 5 4 4 0 0 1-2-5z"/>'),
  'wind': _svg('<path d="M3 8h11a3 3 0 1 0-3-3M3 12h15a3 3 0 1 1-3 3M3 16h7"/>'),
  'fireplace': _svg('<path d="M12 3c1 4 6 6 6 11a6 6 0 0 1-12 0c0-3 2-4 2-6 1 1 2 2 3 2 0-3-1-4 1-7z"/>'),
  'library': _svg('<path d="M4 19V5M8 19V5M12 19l3-14 4 1-3 14z"/><path d="M3 19h18"/>'),
  'cafe': _svg('<path d="M5 9h11v5a5 5 0 0 1-5 5h-1a5 5 0 0 1-5-5z"/><path d="M16 11h1.5a2.5 2.5 0 0 1 0 5H16M9 3q-1 2 0 4M12 3q-1 2 0 4"/>'),
  'keyboard': _svg('<rect x="2.5" y="6" width="19" height="12" rx="3"/><path d="M6 10h.5M9.5 10h.5M13 10h.5M16.5 10h.5M7 14h10"/>'),
  'clock': _svg('<circle cx="12" cy="12" r="8.5"/><path d="M12 7.5V12l3 2"/>'),
};
