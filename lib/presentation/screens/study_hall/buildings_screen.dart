import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/features/study_hall/study_hall_api.dart';
import 'package:simo_learn/presentation/screens/study_hall/study_hall_screen.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/presentation/widgets/re_toast.dart';
import 'package:simo_learn/utils/colors.dart';

/// Moving building is allowed once per hall day, so nobody hops between
/// buildings late at night to land higher.
const _movedOnKey = 'hall_moved_on_day';

Future<void> markHallMovedToday(DateTime dayStartedAt) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_movedOnKey, dayStartedAt.millisecondsSinceEpoch);
}

Future<bool> hallMovedToday(DateTime dayStartedAt) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(_movedOnKey) == dayStartedAt.millisecondsSinceEpoch;
}

/// The three buildings (the profile's study time). Tap one to move there;
/// pops with the new building when the user moved.
class HallBuildingsScreen extends StatefulWidget {
  const HallBuildingsScreen({super.key, required this.hall, required this.repository});

  final StudyHall hall;
  final StudyHallRepository repository;

  @override
  State<HallBuildingsScreen> createState() => _HallBuildingsScreenState();
}

class _HallBuildingsScreenState extends State<HallBuildingsScreen> {
  bool _moving = false;

  Future<void> _ask(HallBuilding to) async {
    if (to == widget.hall.building || _moving) return;
    final already = await hallMovedToday(widget.hall.dayStartedAt);
    if (!mounted) return;
    final go = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MoveSheet(to: to, blocked: already),
    );
    if (go != true || !mounted) return;
    setState(() => _moving = true);
    try {
      await widget.repository.move(to);
      await markHallMovedToday(widget.hall.dayStartedAt);
      if (mounted) Navigator.of(context).pop(to);
    } catch (_) {
      if (mounted) {
        setState(() => _moving = false);
        showReToast(context, 'جابه‌جایی ناموفق بود. دوباره امتحان کن.', ReToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hall = widget.hall;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: hallNight,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Material(
                      color: Colors.white.withAlpha(20),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const SizedBox(width: 40, height: 40, child: Icon(Icons.chevron_left_rounded, color: Colors.white, size: 26)),
                      ),
                    ),
                    const Expanded(child: ReText('ساختمون‌ها', fontSize: 18, fontWeight: 1000, color: Colors.white, textAlign: TextAlign.center)),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                  children: [
                    SizedBox(
                      height: 372,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (final b in HallBuilding.values)
                            Expanded(
                              child: _BuildingTile(
                                building: b,
                                current: b == hall.building,
                                people: hall.buildingPeople[b] ?? 0,
                                onTap: () => _ask(b),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white.withAlpha(15), borderRadius: BorderRadius.circular(24)),
                      child: const ReText(
                        'ساختمونت از ساعت مطالعه‌ای که توی پروفایل زدی میاد. روی یه ساختمون دیگه بزن تا بری اونجا؛ پروفایلت هم عوض می‌شه. روزی یه بار می‌شه عوضش کرد، و مطالعه‌ی امروزت باهات میاد.',
                        fontSize: 12.5,
                        fontWeight: 700,
                        color: Color(0xFFD7D8E2),
                        lineHeight: 2,
                        maxLines: 6,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    if (_moving) const Padding(padding: EdgeInsets.only(top: 20), child: Center(child: CircularProgressIndicator(color: Colors.white54))),
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

class _BuildingTile extends StatelessWidget {
  const _BuildingTile({required this.building, required this.current, required this.people, required this.onTap});

  final HallBuilding building;
  final bool current;
  final int people;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final h = [120.0, 175.0, 230.0][building.index];
    return GestureDetector(
      key: ValueKey('hall-building-${building.apiValue}'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (current)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(100)),
              child: const ReText('تو اینجایی', fontSize: 11, fontWeight: 1000, color: Colors.white),
            )
          else
            const SizedBox(height: 22),
          const SizedBox(height: 8),
          SizedBox(width: 100, height: h + 30, child: CustomPaint(painter: _TowerPainter(building.index, current, h))),
          const SizedBox(height: 8),
          ReText(building.name, fontSize: 15, fontWeight: 1000, color: Color(building.color)),
          ReText(building.range, fontSize: 10.5, fontWeight: 700, color: const Color(0xFF8B8FB8)),
          ReText('$people نفر امروز', fontSize: 11, fontWeight: 700, color: const Color(0xFFB9BBCB)),
        ],
      ),
    );
  }
}

class _TowerPainter extends CustomPainter {
  _TowerPainter(this.kind, this.current, this.h);
  final int kind;
  final bool current;
  final double h;

  @override
  void paint(Canvas canvas, Size size) {
    const top = 30.0;
    final body = [const Color(0xFF3A3550), const Color(0xFF262940), const Color(0xFF1F2E44)][kind];
    if (kind == 0) {
      canvas.drawPath(Path()..moveTo(0, top + 12)..lineTo(50, top - 6)..lineTo(100, top + 12)..close(), Paint()..color = const Color(0xFF5A3E3A));
    } else if (kind == 1) {
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-4, top + 6, 108, 10), const Radius.circular(3)), Paint()..color = const Color(0xFF353956));
    } else {
      canvas.drawRect(const Rect.fromLTWH(48.5, top - 26, 3, 26), Paint()..color = const Color(0xFF8B8FB8));
      canvas.drawCircle(const Offset(50, top - 28), 4, Paint()..color = const Color(0xFFFF5A3C));
    }
    final rect = RRect.fromRectAndRadius(Rect.fromLTWH(0, top + 14, 100, h - 14), Radius.circular(kind == 1 ? 4 : 2));
    canvas.drawRRect(rect, Paint()..color = body);
    if (current) {
      canvas.drawRRect(rect, Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
    final rnd = math.Random(20 + kind);
    final rows = ((h - 30) / 22).floor();
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < 4; c++) {
        final lit = rnd.nextDouble() < .78;
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(12 + c * 20.0, top + 24 + r * 22.0, 13, 14), const Radius.circular(2.5)),
          Paint()..color = lit ? const Color(0xFFFFD27A).withValues(alpha: rnd.nextDouble() < .5 ? .95 : .75) : const Color(0xFF1C1F33),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_TowerPainter old) => old.current != current;
}

class _MoveSheet extends StatelessWidget {
  const _MoveSheet({required this.to, required this.blocked});
  final HallBuilding to;
  final bool blocked;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 22, 20, 24 + MediaQuery.paddingOf(context).bottom),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReText(blocked ? 'امروز یه بار عوض کردی' : 'بری ${to.title}؟',
                fontSize: 18, fontWeight: 1000, color: AppColors.black1, textAlign: TextAlign.right),
            const SizedBox(height: 8),
            ReText(
              blocked
                  ? 'فردا ساعت ۵ صبح دوباره می‌تونی ساختمونت رو عوض کنی.'
                  : 'ساعت مطالعه‌ی پروفایلت هم می‌شه «${to.range}». مطالعه‌ی امروزت باهات میاد. روزی یه بار می‌شه عوضش کرد.',
              fontSize: 13,
              fontWeight: 700,
              color: AppColors.gray,
              lineHeight: 1.9,
              maxLines: 4,
              overflow: TextOverflow.visible,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 18),
            if (blocked)
              FilledButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(52), shape: const StadiumBorder()),
                child: const ReText('باشه', fontSize: 15, fontWeight: 900, color: Colors.white),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey('move-yes'),
                      onPressed: () => Navigator.of(context).pop(true),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(52), shape: const StadiumBorder()),
                      child: const ReText('آره، برو', fontSize: 15, fontWeight: 900, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(backgroundColor: AppColors.gray1, minimumSize: const Size(110, 52), shape: const StadiumBorder()),
                    child: const ReText('لغو', fontSize: 15, fontWeight: 900, color: AppColors.black1),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
