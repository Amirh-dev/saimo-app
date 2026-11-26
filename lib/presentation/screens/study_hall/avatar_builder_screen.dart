import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simo_learn/features/study_hall/hall_avatar.dart';
import 'package:simo_learn/features/study_hall/hall_presets.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';

/// «ظاهرت»: build the character that sits in your window
/// (docs/design/study-hall/builder.html). Pops with the new character on
/// «ذخیره»; nothing is kept on back.
class AvatarBuilderScreen extends StatefulWidget {
  const AvatarBuilderScreen({super.key, required this.initial});
  final HallAvatar initial;

  @override
  State<AvatarBuilderScreen> createState() => _AvatarBuilderScreenState();
}

enum _Cat { ready, hair, face, skin, top, extras }

const _head = '-50 -168 100 100',
    _eyesBox = '-30 -112 60 40',
    _mouthBox = '-16 -84 32 20',
    _beardBox = '-36 -104 72 50',
    _bodyBox = '-60 -74 120 80';

class _AvatarBuilderScreenState extends State<AvatarBuilderScreen> {
  late HallAvatar _a = widget.initial;
  final _history = <HallAvatar>[];
  _Cat _cat = _Cat.ready;
  final _rnd = math.Random();

  void _set(HallAvatar next) => setState(() {
        _history.add(_a);
        if (_history.length > 30) _history.removeAt(0);
        _a = next;
      });

  void _undo() {
    if (_history.isEmpty) return;
    setState(() => _a = _history.removeLast());
  }

  void _random() {
    T pick<T>(List<T> l) => l[_rnd.nextInt(l.length)];
    final boy = _a.boy;
    _set(HallAvatar(
      boy: boy,
      skin: _rnd.nextInt(hallSkins.length),
      hair: pick(boy
          ? const ['short', 'side', 'spiky', 'wolf', 'curly', 'ahoge', 'buzz']
          : const ['long', 'wavy', 'twin', 'pony', 'bob', 'bun', 'wolf']),
      hairColor: _rnd.nextInt(hallHairColors.length),
      eyes: pick(boy ? const ['sharp', 'focus', 'happy'] : const ['sparkle', 'calm', 'happy', 'wink']),
      eyeColor: _rnd.nextInt(hallEyeColors.length),
      blush: !boy && _rnd.nextDouble() < .8,
      brows: boy ? 'thick' : 'thin',
      mouth: pick(const ['smile', 'grin', 'smirk', 'calm']),
      face: boy ? 'strong' : 'soft',
      beard: boy ? pick(const ['none', 'none', 'stubble', 'mustache', 'goatee', 'beard']) : 'none',
      top: pick(const ['hoodie', 'sweater', 'shirt', 'jacket', 'tee']),
      topColor: _rnd.nextInt(hallTopColors.length),
      accessories: {
        if (_rnd.nextDouble() < .3) 'headphones',
        if (_rnd.nextDouble() < .25) 'glasses',
        if (boy && _rnd.nextDouble() < .25) 'cap',
        if (!boy && _rnd.nextDouble() < .3) 'earrings',
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.gray1,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    _Round(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const Icon(Icons.chevron_left_rounded, size: 26, color: AppColors.black1)),
                    const Expanded(
                        child: ReText('ظاهرت', fontSize: 18, fontWeight: 1000, color: AppColors.black1, textAlign: TextAlign.center)),
                    _Round(
                        key: const ValueKey('builder-random'),
                        onTap: _random,
                        child: const Icon(Icons.casino_outlined, size: 21, color: AppColors.black1)),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFE7B0), Color(0xFFFFC566)]),
                  boxShadow: const [BoxShadow(color: Color(0x1A23232B), blurRadius: 26, offset: Offset(0, 10))],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned.fill(
                      top: 14,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: SvgPicture.string(hallAvatarSvg(_a, viewBox: '-75 -178 150 178'),
                            key: ValueKey(_a.toJson().toString()), alignment: Alignment.bottomCenter),
                      ),
                    ),
                    Positioned(left: 0, right: 0, bottom: 0, child: Container(height: 14, color: const Color(0xFFB87A3E))),
                    Positioned(
                      left: 12,
                      bottom: 24,
                      child: Opacity(
                        opacity: _history.isEmpty ? .35 : 1,
                        child: _Round(
                          key: const ValueKey('builder-undo'),
                          onTap: _undo,
                          light: true,
                          // LTR arrow on purpose: the RTL-mirrored one reads as redo.
                          child: const Icon(Icons.undo_rounded, size: 20, color: AppColors.black1, textDirection: TextDirection.ltr),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final (c, label) in const [
                      (_Cat.ready, 'آماده'),
                      (_Cat.hair, 'مو'),
                      (_Cat.face, 'صورت'),
                      (_Cat.skin, 'پوست'),
                      (_Cat.top, 'لباس'),
                      (_Cat.extras, 'اکسسوری')
                    ])
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: GestureDetector(
                          key: ValueKey('builder-cat-${c.name}'),
                          onTap: () => setState(() => _cat = c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration:
                                BoxDecoration(color: _cat == c ? AppColors.black1 : Colors.white, borderRadius: BorderRadius.circular(100)),
                            child: ReText(label, fontSize: 13, fontWeight: 900, color: _cat == c ? Colors.white : const Color(0xFF6B6B73)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                  child: ListView(padding: const EdgeInsets.all(14), children: _options()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    key: const ValueKey('builder-save'),
                    onPressed: () => Navigator.of(context).pop(_a),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: const StadiumBorder()),
                    child: const ReText('ذخیره', fontSize: 16, fontWeight: 900, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _options() {
    final a = _a, boy = a.boy;
    Widget tile(HallAvatar v, String vb, bool on, String label, {VoidCallback? onTap}) => _Tile(
          on: on,
          label: label,
          onTap: onTap ?? () => _set(v),
          child: SvgPicture.string(hallAvatarSvg(v, viewBox: vb)),
        );
    switch (_cat) {
      case _Cat.ready:
        return [
          _Gender(boy: boy, onBoy: (b) => _set((b ? hallBoyPresets : hallGirlPresets).first)),
          const SizedBox(height: 12),
          _Grid(children: [
            for (final p in boy ? hallBoyPresets : hallGirlPresets)
              tile(p, '-60 -172 120 172', a.toJson().toString() == p.toJson().toString(), 'آماده'),
          ]),
        ];
      case _Cat.hair:
        final hairs = boy
            ? const ['short', 'side', 'spiky', 'wolf', 'curly', 'ahoge', 'buzz', 'long', 'wavy', 'bob', 'pony', 'bun', 'twin']
            : const ['long', 'wavy', 'twin', 'pony', 'bob', 'bun', 'wolf', 'ahoge', 'short', 'side', 'curly', 'spiky', 'buzz'];
        return [
          const _Label('مدل مو'),
          _Grid(children: [
            for (final h in hairs) tile(a.copyWith(hair: h, accessories: {}), _head, a.hair == h, h, onTap: () => _set(a.copyWith(hair: h)))
          ]),
          const _Label('رنگ مو'),
          _Swatches(colors: hallHairColors, selected: a.hairColor, onPick: (i) => _set(a.copyWith(hairColor: i))),
        ];
      case _Cat.face:
        final eyes = boy ? const ['sharp', 'focus', 'happy', 'wink'] : const ['sparkle', 'calm', 'happy', 'wink'];
        return [
          if (boy) ...[
            const _Label('ریش و سبیل'),
            _Grid(children: [
              for (final b in const ['none', 'stubble', 'mustache', 'goatee', 'beard'])
                tile(a.copyWith(beard: b), _beardBox, a.beard == b, b)
            ]),
          ],
          const _Label('چشم'),
          _Grid(children: [for (final e in eyes) tile(a.copyWith(eyes: e), _eyesBox, a.eyes == e, e)]),
          const _Label('رنگ چشم'),
          _Swatches(colors: hallEyeColors, selected: a.eyeColor, onPick: (i) => _set(a.copyWith(eyeColor: i))),
          const _Label('ابرو'),
          _Grid(children: [
            for (final b in const ['thin', 'thick']) tile(a.copyWith(brows: b), _eyesBox, a.brows == b, b)
          ]),
          const _Label('دهن'),
          _Grid(children: [
            for (final m in const ['smile', 'grin', 'smirk', 'calm']) tile(a.copyWith(mouth: m), _mouthBox, a.mouth == m, m)
          ]),
        ];
      case _Cat.skin:
        return [
          const _Label('رنگ پوست'),
          _Swatches(colors: hallSkins, selected: a.skin, onPick: (i) => _set(a.copyWith(skin: i))),
          if (!boy) ...[
            const _Label('رژگونه'),
            _Grid(children: [tile(a.copyWith(blush: true), _head, a.blush, 'با'), tile(a.copyWith(blush: false), _head, !a.blush, 'بدون')]),
          ],
        ];
      case _Cat.top:
        final tops =
            boy ? const ['hoodie', 'jacket', 'tee', 'shirt', 'sweater'] : const ['hoodie', 'sweater', 'shirt', 'jacket', 'tee', 'sailor'];
        return [
          const _Label('لباس'),
          _Grid(children: [
            for (final t in tops) tile(a.copyWith(top: t, accessories: {}), _bodyBox, a.top == t, t, onTap: () => _set(a.copyWith(top: t)))
          ]),
          const _Label('رنگ لباس'),
          _Swatches(colors: hallTopColors, selected: a.topColor, onPick: (i) => _set(a.copyWith(topColor: i))),
        ];
      case _Cat.extras:
        final extras =
            boy ? const ['headphones', 'cap', 'glasses', 'earrings'] : const ['headphones', 'catphones', 'glasses', 'bow', 'earrings'];
        return [
          const _Label('اکسسوری (چند تا با هم هم می‌شه)'),
          _Grid(children: [
            for (final x in extras)
              tile(a.copyWith(accessories: {x}), _head, a.accessories.contains(x), x, onTap: () {
                final next = {...a.accessories};
                if (!next.remove(x)) {
                  next.add(x);
                  if (x == 'headphones') next.remove('catphones');
                  if (x == 'catphones') next.remove('headphones');
                  if (x == 'cap') next.remove('bow');
                  if (x == 'bow') next.remove('cap');
                }
                _set(a.copyWith(accessories: next));
              }),
          ]),
        ];
    }
  }
}

class _Round extends StatelessWidget {
  const _Round({super.key, required this.onTap, required this.child, this.light = false});
  final VoidCallback onTap;
  final Widget child;
  final bool light;

  @override
  Widget build(BuildContext context) => Material(
        color: light ? Colors.white.withAlpha(204) : Colors.white,
        shape: const CircleBorder(),
        elevation: light ? 0 : 1,
        shadowColor: const Color(0x1A23232B),
        child:
            InkWell(customBorder: const CircleBorder(), onTap: onTap, child: SizedBox(width: 40, height: 40, child: Center(child: child))),
      );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
        child: ReText(text, fontSize: 12, fontWeight: 900, color: const Color(0xFF6B6B73), textAlign: TextAlign.right),
      );
}

class _Grid extends StatelessWidget {
  const _Grid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: children,
      );
}

class _Tile extends StatelessWidget {
  const _Tile({required this.on, required this.label, required this.onTap, required this.child});
  final bool on;
  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: on,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: on ? AppColors.black1 : AppColors.gray1,
              borderRadius: BorderRadius.circular(20),
              boxShadow: on ? const [BoxShadow(color: Color(0x4023232B), blurRadius: 18, offset: Offset(0, 8))] : null,
            ),
            child: child,
          ),
        ),
      );
}

class _Swatches extends StatelessWidget {
  const _Swatches({required this.colors, required this.selected, required this.onPick});
  final List<String> colors;
  final int selected;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var i = 0; i < colors.length; i++)
            GestureDetector(
              onTap: () => onPick(i),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(int.parse('FF${colors[i].substring(1)}', radix: 16)),
                  border: i == selected ? Border.all(color: Colors.white, width: 3) : null,
                  boxShadow: i == selected ? const [BoxShadow(color: AppColors.black1, spreadRadius: 2.5)] : null,
                ),
              ),
            ),
        ],
      );
}

class _Gender extends StatelessWidget {
  const _Gender({required this.boy, required this.onBoy});
  final bool boy;
  final ValueChanged<bool> onBoy;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: AppColors.gray1, borderRadius: BorderRadius.circular(100)),
        child: Row(children: [
          for (final (b, label) in const [(false, 'دختر'), (true, 'پسر')])
            Expanded(
              child: GestureDetector(
                key: ValueKey('builder-${b ? 'boy' : 'girl'}'),
                onTap: () => b == boy ? null : onBoy(b),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(color: b == boy ? AppColors.black1 : Colors.transparent, borderRadius: BorderRadius.circular(100)),
                  child: ReText(label, fontSize: 14, fontWeight: 900, color: b == boy ? Colors.white : const Color(0xFF6B6B73)),
                ),
              ),
            ),
        ]),
      );
}
