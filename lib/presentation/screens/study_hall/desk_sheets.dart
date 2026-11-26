import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/feedback/feedback_repository.dart';
import 'package:simo_learn/features/study_hall/hall_avatar.dart';
import 'package:simo_learn/features/study_hall/hall_sounds.dart';
import 'package:simo_learn/features/study_hall/study_hall_api.dart';
import 'package:simo_learn/presentation/screens/study_hall/sound_panel.dart';
import 'package:simo_learn/presentation/screens/study_hall/study_hall_screen.dart';
import 'package:simo_learn/presentation/screens/study_hall/suggest_sound_sheet.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';

/// The sheets the things on the desk open (docs: design-previews/study-hall/desk.html).

const _warm = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFE7B0), Color(0xFFFFC566)]);

Future<T?> _showSheet<T>(BuildContext context, Widget Function(BuildContext) body, {bool scroll = true}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .86),
        padding: EdgeInsets.fromLTRB(20, 12, 20, 18 + MediaQuery.paddingOf(context).bottom),
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
            Flexible(child: scroll ? SingleChildScrollView(child: body(context)) : body(context)),
          ],
        ),
      ),
    ),
  );
}

Widget _title(String text) =>
    ReText(text, fontSize: 18, fontWeight: 1000, color: AppColors.black1, textAlign: TextAlign.right, overflow: TextOverflow.visible);

Widget _text(String text) => Padding(
      padding: const EdgeInsets.only(top: 4),
      child: ReText(text,
          fontSize: 12.5,
          fontWeight: 600,
          color: const Color(0xFF6B6B73),
          lineHeight: 1.9,
          maxLines: 6,
          overflow: TextOverflow.visible,
          textAlign: TextAlign.right),
    );

Widget deskButton(String label, {Key? key, required VoidCallback onTap, bool main = true}) => Padding(
      padding: EdgeInsets.only(top: main ? 16 : 8),
      child: SizedBox(
        height: 52,
        child: FilledButton(
          key: key,
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: main ? AppColors.primary : AppColors.gray1,
            shape: const StadiumBorder(),
          ),
          child: ReText(label, fontSize: 15, fontWeight: 1000, color: main ? Colors.white : AppColors.black1),
        ),
      ),
    );

// ----------------------------------------------------------------- sounds

Future<void> showDeskSoundSheet(BuildContext context, HallSoundMixer mixer) {
  SoundSuggestionSender? send;
  try {
    send = feedbackSoundSender(FeedbackRepository(context.read<GraphQLRepository>()));
  } catch (_) {}
  return _showSheet<void>(
    context,
    scroll: false,
    (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title('صداها'),
        _text('هر صدایی روشن باشه هدفون می‌ره روی سرت. بارون روی شیشه‌ی پنجره‌ات هم می‌باره.'),
        const SizedBox(height: 4),
        Flexible(
          child: SizedBox(
            height: 430,
            child: HallSoundPanel(
              mixer: mixer,
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
              onSuggest: send == null ? null : () => showSuggestSoundSheet(context, send!),
            ),
          ),
        ),
      ],
    ),
  );
}

// ------------------------------------------------------------------ break

/// True starts the five-minute break.
Future<bool?> showDeskBreakSheet(BuildContext context) => _showSheet<bool>(
      context,
      (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _title('یه چای بخوریم؟'),
          _text('۵ دقیقه استراحت. تایمر درس متوقف می‌شه و پنجره‌ات کم‌نور می‌شه که بقیه بدونن داری استراحت می‌کنی.'),
          deskButton('شروع استراحت ۵ دقیقه‌ای', key: const ValueKey('desk-break-start'), onTap: () => Navigator.of(context).pop(true)),
          deskButton('نه، ادامه می‌دم', main: false, onTap: () => Navigator.of(context).pop(false)),
        ],
      ),
    );

// ------------------------------------------------------------------ plant

/// The plant drawn on its own (origin at the pot's rim, growing up).
String deskPlantSvg(HallPlant? plant, {String viewBox = '-45 -100 90 110', bool pot = true}) {
  final leaves = plant?.leaves ?? 0, wilt = plant?.wilting ?? false, flower = plant?.flowering ?? false;
  final n = math.min(leaves, 12);
  final stem = 16 + n * 3.6;
  final g = StringBuffer();
  final bend = wilt ? 6 : 0, lean = wilt ? 14 : 0, top = stem - (wilt ? 6 : 0);
  g.write('<path d="M0 0 C$bend -${stem * .5} $lean -${stem * .8} ${wilt ? 18 : 0} -$top" stroke="#5E8C4E" stroke-width="2.4" fill="none" stroke-linecap="round"/>');
  for (var i = 0; i < n; i++) {
    final y = -7 - i * (stem - 9) / math.max(n, 1);
    final side = i.isOdd ? 1 : -1, s = .7 + (i / 12) * .45;
    final col = wilt ? (i.isOdd ? '#A8A65E' : '#9A9852') : (i.isOdd ? '#7DB56A' : '#69A65A');
    final r = wilt ? side * 38 : 0;
    g.write('<path transform="translate(${wilt ? (i * 1.3).toStringAsFixed(1) : 0},${y.toStringAsFixed(1)}) rotate($r) '
        'scale(${(side * s).toStringAsFixed(2)},${s.toStringAsFixed(2)})" d="M0 0 C6 -8 16 -8 18 -2 C12 2 5 3 0 0Z" fill="$col"/>');
  }
  if (flower) {
    g.write('<g transform="translate(0,-${(stem + 2).toStringAsFixed(1)})">');
    for (final a in const [0, 72, 144, 216, 288]) {
      g.write('<ellipse rx="3.4" ry="6" transform="rotate($a) translate(0,-5)" fill="#F7D46B"/>');
    }
    g.write('<circle r="3" fill="#E58A3A"/></g>');
  }
  if (pot) {
    g.write('<path d="M-16 -2 H16 L12 20 H-12 Z" fill="#C46A45"/><rect x="-18" y="-5" width="36" height="6" rx="2" fill="#D47B55"/>');
  }
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="$viewBox">$g</svg>';
}

const _weekDays = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

Future<void> showDeskPlantSheet(BuildContext context, {required HallPlant plant, required StudyHall hall, required int todaySeconds}) {
  final goal = plant.waterSeconds;
  final week = [...plant.days.skip(math.max(0, plant.days.length - 6)), plant.today];
  final weekday = (DateTime.now().weekday + 1) % 7; // Saturday = 0
  return _showSheet<void>(
    context,
    (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(width: 96, height: 116, child: SvgPicture.string(deskPlantSvg(plant, viewBox: '-45 -96 90 120'))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title(plant.wilting ? 'گلدونت تشنه‌ست' : '${plant.leaves} برگ'),
                  _text(plant.wilting
                      ? 'دیروز به سالن ۲ نرسیدی و گلدون یه کم پژمرده شد. امروز برسی دوباره سرحال می‌شه.'
                      : 'هر روز که به سالن ۲ ساختمونت برسی، گلدونت آب می‌خوره و یه برگ می‌ده. هر سالن بالاتر، یه برگ دیگه.'),
                ],
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(color: AppColors.gray1, borderRadius: BorderRadius.circular(18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                const Expanded(
                    child: ReText('آب امروز: رسیدن به سالن ۲',
                        fontSize: 12, fontWeight: 900, color: AppColors.black1, textAlign: TextAlign.right)),
                ReText(
                  plant.wateredToday ? 'امروز آب خورد' : '${((goal - todaySeconds) / 60).ceil()} دقیقه مونده',
                  key: const ValueKey('plant-water'),
                  fontSize: 12,
                  fontWeight: 900,
                  color: plant.wateredToday ? AppColors.success : AppColors.black1,
                ),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: (todaySeconds / goal).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.white,
                  color: const Color(0xFF5FA552),
                ),
              ),
              const SizedBox(height: 6),
              ReText('${hall.building.title}: سالن ۲ یعنی ${hallClock(goal)} ساعت مطالعه.',
                  fontSize: 11, fontWeight: 600, color: AppColors.gray, textAlign: TextAlign.right),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < week.length; i++)
              Column(children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.gray1,
                    borderRadius: BorderRadius.circular(12),
                    border: i == week.length - 1 ? Border.all(color: AppColors.primary, width: 2) : null,
                  ),
                  child: ReText(
                    week[i] > 0 ? '+${week[i]}' : (i == week.length - 1 ? '…' : '۰'),
                    fontSize: 12,
                    fontWeight: 1000,
                    color: week[i] > 0 ? const Color(0xFF2F8F57) : const Color(0xFFC0A060),
                    textDirection: TextDirection.ltr,
                  ),
                ),
                const SizedBox(height: 4),
                ReText(_weekDays[(weekday - (week.length - 1 - i)) % 7], fontSize: 10.5, fontWeight: 800, color: AppColors.gray),
              ]),
          ],
        ),
        const SizedBox(height: 8),
        _text('با ${HallPlant.flowerAt} برگ گلدونت گل می‌ده.'),
        deskButton('باشه', main: false, onTap: () => Navigator.of(context).pop()),
      ],
    ),
  );
}

// ------------------------------------------------------------------- look

/// Your best day and the items it unlocks; tap one to wear it.
Future<void> showDeskLookSheet(
  BuildContext context, {
  required HallAvatar avatar,
  required int bestDaySeconds,
  required ValueChanged<HallAvatar> onWear,
  required VoidCallback onBuilder,
}) {
  final next = hallRewards.where((r) => bestDaySeconds < r.hours * 3600).firstOrNull;
  return _showSheet<void>(
    context,
    (context) => StatefulBuilder(builder: (context, setState) {
      Widget item(String id, String name, int hours) {
        final locked = hours * 3600 > bestDaySeconds;
        final on = avatar.reward == id;
        return GestureDetector(
          key: ValueKey('look-item-${id.isEmpty ? 'none' : id}'),
          onTap: locked
              ? null
              : () {
                  setState(() => avatar = avatar.copyWith(reward: id));
                  onWear(avatar);
                },
          child: Container(
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 10),
            decoration: BoxDecoration(
              color: on ? const Color(0xFFFFF3EF) : AppColors.gray1,
              borderRadius: BorderRadius.circular(20),
              border: on ? Border.all(color: AppColors.primary, width: 2) : null,
            ),
            child: Stack(
              children: [
                Column(children: [
                  Opacity(
                    opacity: locked ? .4 : 1,
                    child: SizedBox(
                      height: 72,
                      child: SvgPicture.string(
                        hallAvatarSvg(locked ? avatar.copyWith(reward: id) : avatar.copyWith(reward: id),
                            silhouette: locked ? '#9A9AA6' : null, viewBox: '-62 -172 124 150'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ReText(name, fontSize: 11, fontWeight: 900, color: locked ? AppColors.gray : AppColors.black1, maxLines: 1),
                ]),
                if (locked)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.black1, borderRadius: BorderRadius.circular(100)),
                      child: ReText('$hours ساعت', fontSize: 10, fontWeight: 900, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 104,
                height: 96,
                decoration: BoxDecoration(gradient: _warm, borderRadius: BorderRadius.circular(28)),
                clipBehavior: Clip.antiAlias,
                child: SvgPicture.string(hallAvatarSvg(avatar, viewBox: '-62 -172 124 150'), alignment: Alignment.bottomCenter),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ReText('رکورد تو', fontSize: 12, fontWeight: 800, color: AppColors.gray),
                    ReText(hallClock(bestDaySeconds), key: const ValueKey('look-record'), fontSize: 24, fontWeight: 1000, color: AppColors.black1),
                    ReText(
                      next == null
                          ? 'بیشترین ساعتی که یه روز خوندی. همه‌ی آیتم‌ها باز شدن!'
                          : 'بیشترین ساعتی که یه روز خوندی. با رکورد ${next.hours} ساعت «${next.name}» باز می‌شه.',
                      fontSize: 12,
                      fontWeight: 700,
                      color: const Color(0xFF6B6B73),
                      lineHeight: 1.8,
                      maxLines: 4,
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: .92,
            children: [
              item('', 'هیچی', 0),
              for (final r in hallRewards) item(r.id, r.name, r.hours),
            ],
          ),
          deskButton('عوض کردن مو، صورت و لباس', key: const ValueKey('look-builder'), main: false, onTap: () {
            Navigator.of(context).pop();
            onBuilder();
          }),
        ],
      );
    }),
  );
}
