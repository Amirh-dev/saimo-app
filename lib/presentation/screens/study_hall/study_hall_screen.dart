import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/study_hall/hall_avatar.dart';
import 'package:simo_learn/features/study_hall/hall_avatar_store.dart';
import 'package:simo_learn/features/study_hall/study_hall_api.dart';
import 'package:simo_learn/presentation/screens/study_hall/buildings_screen.dart';
import 'package:simo_learn/presentation/screens/study_hall/hall_people.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/presentation/widgets/re_toast.dart';
import 'package:simo_learn/utils/colors.dart';

/// The study hall building for today (docs/design/study-hall/ranking.html):
/// floors are bands of today's study, nobody is ranked inside a floor, and
/// your window climbs live while your timer runs. Studying past the last band
/// puts you on the roof, which offers the next building.
class StudyHallScreen extends StatefulWidget {
  const StudyHallScreen({super.key, this.repository, this.clock, this.avatar});

  final StudyHallRepository? repository;
  final DateTime Function()? clock;
  /// Tests pin a character; the app shows the saved one.
  final HallAvatar? avatar;

  @override
  State<StudyHallScreen> createState() => _StudyHallScreenState();
}

const hallNight = Color(0xFF151729);
const _sky1 = Color(0xFF0E1022), _sky2 = Color(0xFF262A4E);
const _body = Color(0xFF262940), _darkWindow = Color(0xFF1C1F33);
const _litTop = Color(0xFFFFE3A6), _litBottom = Color(0xFFFFC566);
const _labelColor = Color(0xFFC9CBE6), _subLabel = Color(0xFF7D81A8), _me = Color(0xFFFF8A66);

/// Roof questions wait a week after «فعلاً همین‌جا».
const _roofDeclinedKey = 'hall_roof_declined_until';

/// Floors are «سالن»s: سالن ۱ at the bottom, the roof stays پشت‌بوم.
String hallFloorName(HallFloor f) => f.isRoof ? 'پشت‌بوم' : 'سالن ${f.index + 1}';

String _hours(int minutes) => minutes % 60 == 0 ? '${minutes ~/ 60}' : '${minutes ~/ 60}:${(minutes % 60).toString().padLeft(2, '0')}';

String hallBandText(HallFloor f, {bool unit = true}) {
  final u = unit ? ' ساعت' : '';
  if (f.isRoof) return 'بیشتر از ${_hours(f.fromMinutes)}$u';
  if (f.index == 0) return '۰ تا ${_hours(f.toMinutes!)}$u';
  return '${_hours(f.fromMinutes)} تا ${_hours(f.toMinutes!)}$u';
}

String hallClock(int seconds) => '${seconds ~/ 3600}:${((seconds % 3600) ~/ 60).toString().padLeft(2, '0')}';

class _StudyHallScreenState extends State<StudyHallScreen> with WidgetsBindingObserver {
  late final StudyHallRepository _repo =
      widget.repository ?? StudyHallRepository(context.read<GraphQLRepository>());
  DateTime _now() => (widget.clock ?? DateTime.now)();

  StudyHall? _hall;
  DateTime? _fetchedAt;
  bool _failed = false;
  int? _shownFloor;
  Timer? _tick, _refresh;
  final _scroll = ScrollController();
  bool _roofAsked = false;
  HallAvatar get _avatar => widget.avatar ?? HallAvatarStore.instance.avatar;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Open at once with the last answer; the fresh one replaces it.
    final cached = StudyHallRepository.cached;
    if (cached != null) {
      _hall = cached;
      _fetchedAt = StudyHallRepository.cachedAt;
      _shownFloor = cached.floorFor(_todaySeconds);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToMe(animate: false));
    }
    HallAvatarStore.instance.load();
    _load(first: cached == null);
    _refresh = Timer.periodic(const Duration(minutes: 1), (_) => _load());
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_hall?.studyingNow == true && mounted) _onTick();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    _refresh?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load({bool first = false}) async {
    try {
      final hall = await _repo.load();
      if (!mounted) return;
      setState(() {
        _hall = hall;
        _fetchedAt = _now();
        _failed = false;
      });
      if (first) {
        _shownFloor = hall.floorFor(_todaySeconds);
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToMe(animate: false));
      }
      _onTick();
    } catch (_) {
      if (mounted && _hall == null) setState(() => _failed = true);
    }
  }

  /// Today's study, counting on locally while a timer runs between refreshes.
  int get _todaySeconds {
    final hall = _hall;
    if (hall == null) return 0;
    var s = hall.todaySeconds;
    if (hall.studyingNow && _fetchedAt != null) s += _now().difference(_fetchedAt!).inSeconds;
    return s.clamp(0, hall.capSeconds);
  }

  void _onTick() {
    final hall = _hall;
    if (hall == null) return;
    final floor = hall.floorFor(_todaySeconds);
    final before = _shownFloor;
    setState(() => _shownFloor = floor);
    if (before != null && floor > before) {
      final f = hall.floors[floor];
      showReToast(context, f.isRoof ? 'رسیدی پشت‌بوم!' : 'رفتی ${hallFloorName(f)}!', ReToastType.success);
      _scrollToMe();
      if (f.isRoof) _maybeAskRoof();
    } else if (before == null || floor != before) {
      _scrollToMe();
    }
    if (floor == hall.floors.length - 1 && hall.hasRoof) _maybeAskRoof();
  }

  Future<void> _maybeAskRoof() async {
    final hall = _hall;
    if (_roofAsked || hall == null || hall.building.next == null) return;
    _roofAsked = true;
    final prefs = await SharedPreferences.getInstance();
    final until = prefs.getInt(_roofDeclinedKey) ?? 0;
    if (_now().millisecondsSinceEpoch < until || !mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final go = await showRoofSheet(context, from: hall.building, to: hall.building.next!, todaySeconds: _todaySeconds, avatar: _avatar);
    if (go == true) {
      await _move(hall.building.next!);
    } else if (go == false) {
      await prefs.setInt(_roofDeclinedKey, _now().add(const Duration(days: 7)).millisecondsSinceEpoch);
      if (mounted) showReToast(context, 'باشه؛ تا یه هفته دوباره نمی‌پرسیم.', ReToastType.info);
    }
  }

  Future<void> _move(HallBuilding to) async {
    try {
      await _repo.move(to);
      await markHallMovedToday(_hall!.dayStartedAt);
      _roofAsked = false;
      _shownFloor = null;
      await _load(first: true);
      if (mounted) showReToast(context, 'خوش اومدی به ${to.title}!', ReToastType.success);
    } catch (_) {
      if (mounted) showReToast(context, 'جابه‌جایی ناموفق بود. دوباره امتحان کن.', ReToastType.error);
    }
  }

  Future<void> _openBuildings() async {
    final hall = _hall;
    if (hall == null) return;
    final moved = await Navigator.of(context).push<HallBuilding>(MaterialPageRoute(
      builder: (_) => HallBuildingsScreen(hall: hall, repository: _repo),
    ));
    if (moved != null) {
      _roofAsked = false;
      _shownFloor = null;
      await _load(first: true);
    }
  }

  void _scrollToMe({bool animate = true}) {
    final hall = _hall, floor = _shownFloor;
    if (hall == null || floor == null || !_scroll.hasClients) return;
    final layout = _HallLayout(hall, MediaQuery.sizeOf(context).width);
    final target = (layout.myRect(floor).top - 170).clamp(0.0, _scroll.position.maxScrollExtent);
    if (animate) {
      _scroll.animateTo(target, duration: const Duration(milliseconds: 700), curve: Curves.easeOutCubic);
    } else {
      _scroll.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hall = _hall;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: hallNight,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _Header(
                title: hall == null ? 'ساختمون' : hall.building.title,
                subtitle: hall?.building.range ?? '',
                people: hall?.buildingPeople[hall.building],
                onBack: () => Navigator.of(context).maybePop(),
                onBuildings: hall == null ? null : _openBuildings,
              ),
              Expanded(
                child: hall == null
                    ? Center(
                        child: _failed
                            ? _Retry(onTap: () {
                                setState(() => _failed = false);
                                _load(first: true);
                              })
                            : const CircularProgressIndicator(color: Colors.white54, strokeWidth: 2.4),
                      )
                    : Stack(
                        children: [
                          Positioned.fill(
                            child: SingleChildScrollView(
                              controller: _scroll,
                              padding: const EdgeInsets.only(bottom: 250),
                              child: ListenableBuilder(
                                listenable: HallAvatarStore.instance,
                                builder: (context, _) => _Building(
                                  hall: hall,
                                  myFloor: _shownFloor ?? 0,
                                  avatar: _avatar,
                                  todaySeconds: _todaySeconds,
                                  onFloor: (f) => showHallFloorSheet(context,
                                      repository: _repo, hall: hall, floor: f, myFloor: _shownFloor ?? 0, me: _avatar, todaySeconds: _todaySeconds),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: _Panel(
                              hall: hall,
                              todaySeconds: _todaySeconds,
                              floor: _shownFloor ?? 0,
                              avatar: _avatar,
                              onBuildings: _openBuildings,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle, required this.people, required this.onBack, required this.onBuildings});

  final String title;
  final String subtitle;
  final int? people;
  final VoidCallback onBack;
  final VoidCallback? onBuildings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          _RoundButton(
            key: const ValueKey('hall-back'),
            onTap: onBack,
            child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 26),
          ),
          Expanded(
            child: Column(
              children: [
                ReText(title, fontSize: 17, fontWeight: 1000, color: Colors.white, textAlign: TextAlign.center),
                const SizedBox(height: 2),
                ReText(subtitle.isEmpty ? 'امروز تا ۵ صبح' : '$subtitle در روز، امروز تا ۵ صبح',
                    fontSize: 11, fontWeight: 700, color: const Color(0xFFB9BBCB), textAlign: TextAlign.center),
              ],
            ),
          ),
          InkWell(
            key: const ValueKey('hall-buildings'),
            onTap: onBuildings,
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withAlpha(26), borderRadius: BorderRadius.circular(100)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.apartment_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 5),
                  ReText(people == null ? 'ساختمون‌ها' : '$people نفر', fontSize: 12, fontWeight: 900, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({super.key, required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white.withAlpha(20),
        shape: const CircleBorder(),
        child: InkWell(customBorder: const CircleBorder(), onTap: onTap, child: SizedBox(width: 40, height: 40, child: child)),
      );
}

class _Retry extends StatelessWidget {
  const _Retry({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ReText('ساختمون باز نشد. دوباره امتحان کن.', fontSize: 14, fontWeight: 800, color: Colors.white),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: const StadiumBorder()),
            child: const ReText('دوباره', fontSize: 14, fontWeight: 900, color: Colors.white),
          ),
        ],
      );
}

// ------------------------------------------------------------------ building

/// Fixed geometry so the painter, the windows and the moving "you" agree.
class _HallLayout {
  _HallLayout(this.hall, this.width);

  final StudyHall hall;
  final double width;

  static const floorH = 92.0, winW = 38.0, winH = 34.0, rows = 2, cols = 5;
  static const topPad = 40.0, roofH = 150.0, groundPad = 56.0;

  double get bx => math.min(100.0, width * .26);
  double get bw => width - bx - 44;
  int get bandFloors => hall.hasRoof ? hall.floors.length - 1 : hall.floors.length;
  double get height => topPad + roofH + bandFloors * floorH + groundPad;
  double get roofLine => topPad + roofH;

  double floorTop(int f) => roofLine + (bandFloors - 1 - f) * floorH;
  double winX(int c) => bx + 14 + c * ((bw - 28 - winW) / (cols - 1));
  double winY(int f, int r) => floorTop(f) + 10 + r * (winH + 8);

  /// Where you sit on a floor: fixed per floor and not by rank.
  (int, int) seat(int f) {
    final k = (f * 7 + hall.building.index * 3 + 4) % (rows * cols);
    return (k ~/ cols, k % cols);
  }

  Rect myRect(int floor) {
    if (hall.floors[floor].isRoof) return Rect.fromLTWH(bx + bw / 2 - winW / 2, roofLine - 64, winW, winH);
    final (r, c) = seat(floor);
    return Rect.fromLTWH(winX(c), winY(floor, r), winW, winH);
  }
}

/// Far-away people: a few shapes, reused so each is parsed once.
final _silhouettes = [
  for (final (hair, acc, beard) in const [
    ('long', <String>{}, 'none'), ('short', <String>{}, 'none'), ('bun', <String>{}, 'none'), ('side', {'headphones'}, 'none'),
    ('pony', <String>{}, 'none'), ('curly', <String>{}, 'beard'), ('bob', <String>{}, 'none'), ('spiky', <String>{}, 'none'),
    ('wavy', {'headphones'}, 'none'), ('buzz', {'cap'}, 'none'), ('wolf', <String>{}, 'none'), ('twin', <String>{}, 'none'),
  ])
    hallAvatarSvg(HallAvatar(hair: hair, accessories: acc, beard: beard), silhouette: '#8A6432'),
];

class _Building extends StatelessWidget {
  const _Building({required this.hall, required this.myFloor, required this.avatar, required this.todaySeconds, required this.onFloor});

  final StudyHall hall;
  final int myFloor;
  final HallAvatar avatar;
  final int todaySeconds;

  /// Tap anywhere on a floor (windows or label) for its people.
  final ValueChanged<int> onFloor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final l = _HallLayout(hall, box.maxWidth);
      final children = <Widget>[
        Positioned.fill(child: CustomPaint(painter: _BuildingPainter(l))),
        for (var f = 0; f < hall.floors.length; f++)
          if (!hall.floors[f].isRoof)
            Positioned(
              left: 0,
              right: 0,
              top: l.floorTop(f),
              height: _HallLayout.floorH,
              child: GestureDetector(key: ValueKey('hall-floor-$f'), behavior: HitTestBehavior.opaque, onTap: () => onFloor(f)),
            )
          else
            Positioned(
              left: 0,
              right: 0,
              top: l.roofLine - 120,
              height: 120,
              child: GestureDetector(key: ValueKey('hall-floor-$f'), behavior: HitTestBehavior.opaque, onTap: () => onFloor(f)),
            ),
      ];
      final rnd = math.Random(17 + hall.building.index);
      for (var f = 0; f < l.bandFloors; f++) {
        final floor = hall.floors[f], mine = f == myFloor, top = l.floorTop(f);
        children.add(Positioned(
          left: 0,
          width: l.bx - 10,
          top: top + _HallLayout.floorH / 2 - 22,
          // RTL: start is the right edge, next to the building.
          child: IgnorePointer(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReText(hallFloorName(floor), fontSize: mine ? 13.5 : 12.5, fontWeight: 1000, color: mine ? _me : _labelColor, textAlign: TextAlign.right),
              ReText(hallBandText(floor, unit: false), fontSize: 10, fontWeight: 800, color: mine ? const Color(0xFFFFB59F) : _subLabel, textAlign: TextAlign.right),
            ],
          )),
        ));
        children.add(Positioned(
          left: l.bx + l.bw + 6,
          top: top + _HallLayout.floorH / 2 - 9,
          child: Semantics(
            label: '${floor.people} نفر',
            child: IgnorePointer(child: ReText('${floor.people}', fontSize: 10.5, fontWeight: 800, color: _subLabel)),
          ),
        ));
        // Lit windows stand for the people on this floor (the ones studying
        // right now glow brightest); seats are shuffled, not ranked.
        final others = math.max(0, floor.people - (mine ? 1 : 0));
        final lit = math.min(_HallLayout.rows * _HallLayout.cols - 1, others);
        final live = math.min(lit, floor.studyingNow);
        final (myR, myC) = l.seat(f);
        final seats = [
          for (var r = 0; r < _HallLayout.rows; r++)
            for (var c = 0; c < _HallLayout.cols; c++)
              if (!(r == myR && c == myC)) (r, c),
        ]..shuffle(rnd);
        // On your floor the people next to you show their own characters.
        final faces = mine ? hall.neighbors : const <HallNeighbor>[];
        for (var i = 0; i < seats.length; i++) {
          final (r, c) = seats[i];
          if (i < faces.length) {
            final n = faces[i];
            children.add(Positioned(
              left: l.winX(c),
              top: l.winY(f, r),
              child: HallFaceWindow(
                key: ValueKey('hall-face-${n.userId}'),
                avatar: n.avatar ?? HallAvatar.fallback,
                live: n.studyingNow,
                size: const Size(_HallLayout.winW, _HallLayout.winH),
                onTap: () => showHallPersonSheet(context, name: n.name, avatar: n.avatar ?? HallAvatar.fallback, todaySeconds: n.todaySeconds, studyingNow: n.studyingNow),
              ),
            ));
            continue;
          }
          children.add(Positioned(
            left: l.winX(c),
            top: l.winY(f, r),
            width: _HallLayout.winW,
            height: _HallLayout.winH,
            child: IgnorePointer(child: _Window(lit: i < lit, live: i < live, silhouette: _silhouettes[(f * 5 + i * 3) % _silhouettes.length])),
          ));
        }
        if (!mine) {
          children.add(Positioned(
            left: l.winX(myC),
            top: l.winY(f, myR),
            width: _HallLayout.winW,
            height: _HallLayout.winH,
            child: const IgnorePointer(child: _Window(lit: false, live: false, silhouette: '')),
          ));
        }
      }
      // Yesterday: where you ended up, beaten or not.
      final yf = hall.floorFor(hall.yesterdaySeconds);
      if (!hall.floors[yf].isRoof) {
        children.add(Positioned(
          left: l.bx + l.bw - 58,
          top: l.floorTop(yf) + _HallLayout.floorH - 22,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFF3A3E5C), borderRadius: BorderRadius.circular(100)),
            child: const IgnorePointer(child: ReText('دیروز', fontSize: 9.5, fontWeight: 900, color: _labelColor)),
          ),
        ));
      }
      if (hall.hasRoof) {
        final roof = hall.floors.last;
        children.add(Positioned(
          left: 0,
          right: 0,
          top: l.roofLine - 112,
          child: IgnorePointer(child: ReText('پشت‌بوم: ${hallBandText(roof)}', fontSize: 12, fontWeight: 900, color: const Color(0xFFFFD27A), textAlign: TextAlign.center)),
        ));
        final standing = math.min(6, roof.people - (hall.floors[myFloor].isRoof ? 1 : 0));
        for (var i = 0; i < standing; i++) {
          final dx = (i - (standing - 1) / 2) * 36;
          children.add(Positioned(
            left: l.bx + l.bw / 2 + dx - 14,
            top: l.roofLine - 40,
            width: 28,
            height: 34,
            child: IgnorePointer(child: SvgPicture.string(_silhouettes[i * 2 % _silhouettes.length])),
          ));
        }
      }
      final me = l.myRect(myFloor);
      children.add(AnimatedPositioned(
        key: const ValueKey('hall-me'),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutBack,
        left: me.left,
        top: me.top,
        width: me.width,
        height: me.height,
        child: GestureDetector(
          onTap: () => showHallPersonSheet(context, name: 'من', avatar: avatar, todaySeconds: todaySeconds, studyingNow: hall.studyingNow, isMe: true),
          child: _MyWindow(avatar: avatar),
        ),
      ));
      children.add(AnimatedPositioned(
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutBack,
        left: me.center.dx - 16,
        top: me.top - 21,
        width: 32,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(100)),
          child: const ReText('تو', fontSize: 10.5, fontWeight: 1000, color: Colors.white),
        ),
      ));
      return SizedBox(height: l.height, child: Stack(clipBehavior: Clip.none, children: children));
    });
  }
}

class _Window extends StatelessWidget {
  const _Window({required this.lit, required this.live, required this.silhouette});

  final bool lit;
  final bool live;
  final String silhouette;

  @override
  Widget build(BuildContext context) {
    if (!lit) {
      return DecoratedBox(decoration: BoxDecoration(color: _darkWindow, borderRadius: BorderRadius.circular(6)));
    }
    return Opacity(
      opacity: live ? 1 : .55,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_litTop, _litBottom]),
          boxShadow: live ? const [BoxShadow(color: Color(0x40FFD27A), blurRadius: 14, spreadRadius: 1)] : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: SvgPicture.string(silhouette, fit: BoxFit.contain, alignment: Alignment.bottomCenter),
      ),
    );
  }
}

class _MyWindow extends StatelessWidget {
  const _MyWindow({required this.avatar});
  final HallAvatar avatar;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFE7B0), Color(0xFFFFC566)]),
          border: Border.all(color: AppColors.primary, width: 3),
          boxShadow: const [BoxShadow(color: Color(0x66F14922), blurRadius: 26, spreadRadius: 4)],
        ),
        clipBehavior: Clip.antiAlias,
        child: SvgPicture.string(hallAvatarSvg(avatar), fit: BoxFit.contain, alignment: Alignment.bottomCenter),
      );
}

class _BuildingPainter extends CustomPainter {
  _BuildingPainter(this.l);
  final _HallLayout l;

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_sky1, _sky2])
          .createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);
    final rnd = math.Random(9);
    final star = Paint()..color = Colors.white;
    for (var i = 0; i < 50; i++) {
      star.color = Colors.white.withValues(alpha: .2 + rnd.nextDouble() * .6);
      canvas.drawCircle(Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height * .6), rnd.nextDouble() * 1.2 + .3, star);
    }
    final moon = Offset(size.width - 50, 56);
    canvas.drawCircle(moon, 15, Paint()..color = const Color(0xFFF5EBD0));
    canvas.drawCircle(moon + const Offset(7, -5), 14, Paint()..color = _sky1);

    final top = l.roofLine;
    if (l.hall.hasRoof) {
      canvas.drawRect(
        Rect.fromLTWH(l.bx - 30, top - 110, l.bw + 60, 120),
        Paint()..shader = const RadialGradient(colors: [Color(0x4DFFD27A), Color(0x00FFD27A)]).createShader(Rect.fromLTWH(l.bx - 30, top - 110, l.bw + 60, 120)),
      );
      final rail = Paint()..color = const Color(0xFF4A4F72);
      for (var x = l.bx - 4; x <= l.bx + l.bw + 4; x += 18) {
        canvas.drawRect(Rect.fromLTWH(x, top - 22, 3, 22), rail);
      }
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(l.bx - 6, top - 24, l.bw + 12, 4), const Radius.circular(2)), Paint()..color = const Color(0xFF5A5F85));
    }
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(l.bx - 8, top, l.bw + 16, 10), const Radius.circular(3)), Paint()..color = const Color(0xFF353956));
    canvas.drawRect(Rect.fromLTWH(l.bx, top + 8, l.bw, l.bandFloors * _HallLayout.floorH + _HallLayout.groundPad - 8), Paint()..color = _body);
    final line = Paint()..color = const Color(0xFF1E2136);
    for (var f = 1; f < l.bandFloors; f++) {
      canvas.drawRect(Rect.fromLTWH(l.bx, l.floorTop(f) + _HallLayout.floorH - 3, l.bw, 3), line);
    }
    final gy = top + l.bandFloors * _HallLayout.floorH;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(l.bx + l.bw / 2 - 22, gy + 12, 44, _HallLayout.groundPad - 12), const Radius.circular(4)), Paint()..color = const Color(0xD9FFC566));
    canvas.drawRect(Rect.fromLTWH(0, gy + _HallLayout.groundPad - 6, size.width, 6), Paint()..color = const Color(0xFF1A1C2C));
    for (final x in [l.bx - 40, l.bx + l.bw + 24]) {
      canvas.drawCircle(Offset(x, gy + _HallLayout.groundPad - 22), 14, Paint()..color = const Color(0xFF2F5A47));
      canvas.drawRect(Rect.fromLTWH(x - 2, gy + _HallLayout.groundPad - 14, 4, 9), Paint()..color = const Color(0xFF4A3A2A));
    }
  }

  @override
  bool shouldRepaint(_BuildingPainter old) => old.l.hall != l.hall || old.l.width != l.width;
}

// ------------------------------------------------------------------- panel

class _Panel extends StatelessWidget {
  const _Panel({required this.hall, required this.todaySeconds, required this.floor, required this.avatar, required this.onBuildings});

  final StudyHall hall;
  final int todaySeconds;
  final int floor;
  final HallAvatar avatar;
  final VoidCallback onBuildings;

  @override
  Widget build(BuildContext context) {
    final f = hall.floors[floor];
    final minutes = todaySeconds ~/ 60;
    String next;
    double progress;
    if (todaySeconds >= hall.capSeconds) {
      next = 'به سقف ۱۴ ساعت امروز رسیدی؛ برو استراحت کن';
      progress = 1;
    } else if (f.isRoof) {
      next = 'روی پشت‌بومی! از این ساختمون جلو زدی';
      progress = 1;
    } else if (floor == hall.floors.length - 1) {
      next = 'بالاترین سالن ساختمان الماس';
      progress = 1;
    } else {
      final to = hall.floors[floor + 1];
      final end = to.fromMinutes;
      next = '${end - minutes} دقیقه تا ${hallFloorName(to)}';
      progress = ((minutes - f.fromMinutes) / (end - f.fromMinutes)).clamp(0.0, 1.0);
    }
    final yesterday = hall.floors[hall.floorFor(hall.yesterdaySeconds)];
    return Container(
      padding: EdgeInsets.fromLTRB(18, 16, 18, 16 + MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 30, offset: Offset(0, -8))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFE7B0), Color(0xFFFFC566)]),
                  border: Border.all(color: AppColors.primary, width: 3),
                ),
                clipBehavior: Clip.antiAlias,
                child: SvgPicture.string(hallAvatarSvg(avatar, viewBox: '-56 -168 112 112')),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReText(hallFloorName(f), key: const ValueKey('hall-floor'), fontSize: 16, fontWeight: 1000, color: AppColors.black1, textAlign: TextAlign.right),
                    ReText(hallBandText(f), fontSize: 11.5, fontWeight: 700, color: AppColors.gray, textAlign: TextAlign.right),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hall.studyingNow)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                      ReText(hallClock(todaySeconds), key: const ValueKey('hall-today'), fontSize: 24, fontWeight: 1000, color: AppColors.black1),
                    ],
                  ),
                  ReText(hall.studyingNow ? 'داری می‌خونی' : 'امروز خوندی', fontSize: 11, fontWeight: 800, color: AppColors.gray),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(color: AppColors.gray1, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: ReText(next, key: const ValueKey('hall-next'), fontSize: 12.5, fontWeight: 900, color: AppColors.black1, textAlign: TextAlign.right)),
                    ReText('دیروز: ${hallFloorName(yesterday)}', fontSize: 11.5, fontWeight: 800, color: AppColors.gray),
                  ],
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: progress),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 8,
                      backgroundColor: AppColors.gray2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onBuildings,
            borderRadius: BorderRadius.circular(100),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ReText(hall.building.title, fontSize: 12.5, fontWeight: 800, color: AppColors.gray),
                  const SizedBox(width: 6),
                  const ReText('عوضش کن', fontSize: 12.5, fontWeight: 900, color: AppColors.black1),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.black1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------- roof sheet

/// True: move to [to]. False: stay (ask again in a week). Null: dismissed.
Future<bool?> showRoofSheet(BuildContext context, {required HallBuilding from, required HallBuilding to, required int todaySeconds, required HallAvatar avatar}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + MediaQuery.paddingOf(context).bottom),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A2E55), hallNight]),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  const Positioned(right: 30, top: 18, child: CircleAvatar(radius: 11, backgroundColor: Color(0xFFF5EBD0))),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < 5; i++)
                          SizedBox(
                            width: 46,
                            height: 62,
                            child: SvgPicture.string(i == 2 ? hallAvatarSvg(avatar) : _silhouettes[i * 3 % _silhouettes.length]),
                          ),
                      ],
                    ),
                  ),
                  Positioned(left: 0, right: 0, bottom: 0, child: Container(height: 10, color: const Color(0xFF353956))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ReText('از ${from.title} جلو زدی!', fontSize: 18, fontWeight: 1000, color: AppColors.black1, textAlign: TextAlign.right, overflow: TextOverflow.visible),
            const SizedBox(height: 8),
            ReText(
              'امروز ${hallClock(todaySeconds)} خوندی. می‌خوای بری ${to.title}؟ ساعت مطالعه‌ی پروفایلت هم عوض می‌شه و مطالعه‌ی امروزت باهات میاد.',
              fontSize: 13,
              fontWeight: 700,
              color: AppColors.gray,
              lineHeight: 1.9,
              maxLines: 4,
              overflow: TextOverflow.visible,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    key: const ValueKey('roof-move'),
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(52), shape: const StadiumBorder()),
                    child: const ReText('آره، برو', fontSize: 15, fontWeight: 900, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  key: const ValueKey('roof-stay'),
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(backgroundColor: AppColors.gray1, minimumSize: const Size(130, 52), shape: const StadiumBorder()),
                  child: const ReText('فعلاً همین‌جا', fontSize: 15, fontWeight: 900, color: AppColors.black1),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
