import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simo_learn/features/study_hall/hall_avatar.dart';
import 'package:simo_learn/features/study_hall/study_hall_api.dart';
import 'package:simo_learn/presentation/screens/study_hall/study_hall_screen.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';

const _warmTop = Color(0xFFFFE7B0), _warmBottom = Color(0xFFFFC566);

/// A small card for someone in the hall: their character, first name and
/// what they studied today. Nothing else about them is shown.
Future<void> showHallPersonSheet(BuildContext context,
    {required String name, required HallAvatar avatar, required int todaySeconds, required bool studyingNow, bool isMe = false}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + MediaQuery.paddingOf(context).bottom),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 44, height: 5, decoration: BoxDecoration(color: AppColors.gray2, borderRadius: BorderRadius.circular(100))),
            const SizedBox(height: 16),
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_warmTop, _warmBottom]),
                border: isMe ? Border.all(color: AppColors.primary, width: 3) : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: SvgPicture.string(hallAvatarSvg(avatar, viewBox: '-62 -172 124 150'), alignment: Alignment.bottomCenter),
            ),
            const SizedBox(height: 12),
            ReText(isMe ? '$name (تو)' : name, key: const ValueKey('person-name'), fontSize: 18, fontWeight: 1000, color: AppColors.black1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Chip(icon: Icons.schedule_rounded, text: 'امروز ${hallClock(todaySeconds)} خونده'),
                const SizedBox(width: 8),
                _Chip(
                  icon: studyingNow ? Icons.circle : Icons.circle_outlined,
                  iconColor: studyingNow ? AppColors.primary : AppColors.gray,
                  text: studyingNow ? 'الان داره می‌خونه' : 'الان استراحته',
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.text, this.iconColor = AppColors.gray});
  final IconData icon;
  final String text;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: AppColors.gray1, borderRadius: BorderRadius.circular(100)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 6),
          ReText(text, fontSize: 12, fontWeight: 800, color: AppColors.black1),
        ]),
      );
}

/// A window with someone's own character in colour (your floor, close up).
class HallFaceWindow extends StatelessWidget {
  const HallFaceWindow({super.key, required this.avatar, this.me = false, this.live = true, this.onTap, this.size = const Size(56, 50)});
  final HallAvatar avatar;
  final bool me;
  final bool live;
  final VoidCallback? onTap;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: live || me ? 1 : .6,
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_warmTop, _warmBottom]),
            border: me ? Border.all(color: AppColors.primary, width: 2.5) : null,
            boxShadow: me ? const [BoxShadow(color: Color(0x55F14922), blurRadius: 16, spreadRadius: 1)] : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: SvgPicture.string(hallAvatarSvg(avatar), alignment: Alignment.bottomCenter),
        ),
      ),
    );
  }
}

/// Your floor up close: you and the people next to you, each tappable.
class HallFloorStrip extends StatelessWidget {
  const HallFloorStrip(
      {super.key,
      required this.hall,
      required this.myFloor,
      required this.me,
      required this.myName,
      required this.todaySeconds,
      required this.studying});

  final StudyHall hall;
  final int myFloor;
  final HallAvatar me;
  final String myName;
  final int todaySeconds;
  final bool studying;

  @override
  Widget build(BuildContext context) {
    final floor = hall.floors[myFloor];
    final neighbors = hall.neighbors;
    final others = math.max(0, floor.people - 1 - neighbors.length);
    final windows = <Widget>[
      HallFaceWindow(
        key: const ValueKey('strip-me'),
        avatar: me,
        me: true,
        onTap: () => showHallPersonSheet(context, name: myName, avatar: me, todaySeconds: todaySeconds, studyingNow: studying, isMe: true),
      ),
      for (final n in neighbors)
        HallFaceWindow(
          key: ValueKey('strip-${n.userId}'),
          avatar: n.avatar ?? HallAvatar.fallback,
          live: n.studyingNow,
          onTap: () => showHallPersonSheet(context,
              name: n.name, avatar: n.avatar ?? HallAvatar.fallback, todaySeconds: n.todaySeconds, studyingNow: n.studyingNow),
        ),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(color: hallNight, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ReText(hallFloorName(floor), fontSize: 14, fontWeight: 1000, color: Colors.white),
              const SizedBox(width: 6),
              ReText(hallBandText(floor), fontSize: 11.5, fontWeight: 700, color: const Color(0xFFB9BBCB)),
              const Spacer(),
              ReText('${floor.people} نفر این سالن', fontSize: 11.5, fontWeight: 800, color: const Color(0xFFB9BBCB)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: windows),
          if (others > 0) ...[
            const SizedBox(height: 10),
            ReText('و $others نفر دیگه هم توی این سالن‌ان',
                fontSize: 11, fontWeight: 700, color: const Color(0xFF8B8FB8), textAlign: TextAlign.right),
          ],
          if (neighbors.isEmpty) ...[
            const SizedBox(height: 10),
            const ReText('فعلاً تنهایی توی این سالن؛ بقیه کم‌کم میان.',
                fontSize: 11.5, fontWeight: 700, color: Color(0xFF8B8FB8), textAlign: TextAlign.right),
          ],
        ],
      ),
    );
  }
}

/// Everybody on one سالن of your building today, with chips to switch سالن.
/// Tap someone for their card; the back arrow returns to the list.
Future<void> showHallFloorSheet(
  BuildContext context, {
  required StudyHallRepository repository,
  required StudyHall hall,
  required int floor,
  required int myFloor,
  required HallAvatar me,
  required int todaySeconds,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FloorSheet(
        repository: repository, hall: hall, floor: floor, myFloor: myFloor, me: me, todaySeconds: todaySeconds),
  );
}

class _FloorSheet extends StatefulWidget {
  const _FloorSheet(
      {required this.repository,
      required this.hall,
      required this.floor,
      required this.myFloor,
      required this.me,
      required this.todaySeconds});
  final StudyHallRepository repository;
  final StudyHall hall;
  final int floor;
  final int myFloor;
  final HallAvatar me;
  final int todaySeconds;

  @override
  State<_FloorSheet> createState() => _FloorSheetState();
}

class _FloorSheetState extends State<_FloorSheet> {
  late int _floor = widget.floor;
  final _people = <int, List<HallNeighbor>>{};
  final _failed = <int>{};
  HallNeighbor? _person;
  bool _showMe = false;

  @override
  void initState() {
    super.initState();
    _load(_floor);
  }

  Future<void> _load(int f) async {
    if (_people.containsKey(f)) return;
    _failed.remove(f);
    try {
      final list = await widget.repository.floorPeople(f);
      if (mounted) setState(() => _people[f] = list);
    } catch (_) {
      if (mounted) setState(() => _failed.add(f));
    }
  }

  void _pick(int f) {
    setState(() => _floor = f);
    _load(f);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .82),
        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + MediaQuery.paddingOf(context).bottom),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                  width: 44, height: 5, decoration: BoxDecoration(color: AppColors.gray2, borderRadius: BorderRadius.circular(100))),
            ),
            const SizedBox(height: 14),
            if (_person != null || _showMe) _card() else ..._list(widget.hall),
          ],
        ),
      ),
    );
  }

  Widget _card() {
    final n = _person;
    final avatar = n == null ? widget.me : (n.avatar ?? HallAvatar.fallback);
    final f = widget.hall.floors[_showMe ? widget.myFloor : _floor];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: IconButton(
            key: const ValueKey('floor-person-back'),
            onPressed: () => setState(() {
              _person = null;
              _showMe = false;
            }),
            style: IconButton.styleFrom(backgroundColor: AppColors.gray1),
            // RTL: Material mirrors chevrons, so «back» is chevron_left.
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.black1),
          ),
        ),
        _bigFace(avatar, me: n == null),
        const SizedBox(height: 12),
        ReText(n == null ? 'تو' : n.name, key: const ValueKey('person-name'), fontSize: 18, fontWeight: 1000, color: AppColors.black1),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _Chip(icon: Icons.schedule_rounded, text: 'امروز ${hallClock(n?.todaySeconds ?? widget.todaySeconds)} خونده'),
            _Chip(icon: Icons.apartment_rounded, text: hallFloorName(f)),
            if (n != null)
              _Chip(
                icon: n.studyingNow ? Icons.circle : Icons.circle_outlined,
                iconColor: n.studyingNow ? AppColors.primary : AppColors.gray,
                text: n.studyingNow ? 'الان داره می‌خونه' : 'الان استراحته',
              ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  List<Widget> _list(StudyHall hall) {
    final f = hall.floors[_floor];
    final people = _people[_floor];
    final mine = _floor == widget.myFloor;
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ReText(hall.building.title, fontSize: 18, fontWeight: 1000, color: AppColors.black1),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: ReText('${hall.building.range} در روز', fontSize: 11.5, fontWeight: 700, color: AppColors.gray),
          ),
        ],
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 38,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            for (var i = 0; i < hall.floors.length; i++)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 6),
                child: GestureDetector(
                  key: ValueKey('floor-chip-$i'),
                  onTap: () => _pick(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: i == _floor ? AppColors.black1 : AppColors.gray1, borderRadius: BorderRadius.circular(100)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (i == widget.myFloor) ...[
                        Container(
                            width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                      ],
                      ReText(hallFloorName(hall.floors[i]),
                          fontSize: 12, fontWeight: 900, color: i == _floor ? Colors.white : AppColors.black1),
                      const SizedBox(width: 5),
                      ReText('${hall.floors[i].people} نفر',
                          fontSize: 10.5, fontWeight: 700, color: i == _floor ? const Color(0xFFBBBBC4) : AppColors.gray),
                    ]),
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      ReText('${hallFloorName(f)}: ${hallBandText(f)}${mine ? '، سالن خودت' : ''}',
          fontSize: 11.5, fontWeight: 700, color: AppColors.gray, textAlign: TextAlign.right),
      const SizedBox(height: 10),
      Flexible(
        child: people == null
            ? SizedBox(
                height: 160,
                child: Center(
                  child: _failed.contains(_floor)
                      ? TextButton(
                          onPressed: () => setState(() => _load(_floor)),
                          child: const ReText('باز نشد؛ دوباره', fontSize: 13, fontWeight: 900, color: AppColors.black1))
                      : const CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.gray),
                ),
              )
            : (people.isEmpty && !mine)
                ? const SizedBox(
                    height: 120,
                    child: Center(
                        child: ReText('امروز هنوز کسی اینجا نرسیده.', fontSize: 13, fontWeight: 800, color: AppColors.gray)))
                : GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 8,
                    childAspectRatio: .72,
                    children: [
                      if (mine)
                        _Person(
                          key: const ValueKey('floor-me'),
                          avatar: widget.me,
                          name: 'تو',
                          seconds: widget.todaySeconds,
                          live: true,
                          me: true,
                          onTap: () => setState(() => _showMe = true),
                        ),
                      for (final n in people)
                        _Person(
                          key: ValueKey('floor-person-${n.userId}'),
                          avatar: n.avatar ?? HallAvatar.fallback,
                          name: n.name,
                          seconds: n.todaySeconds,
                          live: n.studyingNow,
                          onTap: () => setState(() => _person = n),
                        ),
                    ],
                  ),
      ),
    ];
  }
}

Widget _bigFace(HallAvatar avatar, {bool me = false}) => Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_warmTop, _warmBottom]),
        border: me ? Border.all(color: AppColors.primary, width: 3) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: SvgPicture.string(hallAvatarSvg(avatar, viewBox: '-62 -172 124 150'), alignment: Alignment.bottomCenter),
    );

class _Person extends StatelessWidget {
  const _Person(
      {super.key,
      required this.avatar,
      required this.name,
      required this.seconds,
      required this.live,
      required this.onTap,
      this.me = false});
  final HallAvatar avatar;
  final String name;
  final int seconds;
  final bool live;
  final bool me;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              children: [
                Opacity(
                  opacity: live || me ? 1 : .55,
                  child: Container(
                    width: 70,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_warmTop, _warmBottom]),
                      border: me ? Border.all(color: AppColors.primary, width: 2.5) : null,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: SvgPicture.string(hallAvatarSvg(avatar, viewBox: '-62 -172 124 150'), alignment: Alignment.bottomCenter),
                  ),
                ),
                if (live && !me)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            ReText(name, fontSize: 11.5, fontWeight: 900, color: AppColors.black1, maxLines: 1, overflow: TextOverflow.ellipsis),
            ReText(hallClock(seconds), fontSize: 10.5, fontWeight: 700, color: AppColors.gray),
          ],
        ),
      );
}
