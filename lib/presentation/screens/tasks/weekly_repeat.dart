import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/week_plan.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/_utils.dart';

/// Weekly repeat, shared by the full task forms and quick add: the
/// «یک روز» | «هر هفته» switch, the seven day circles with a summary, and
/// the day the first copy lands on.

class WeekDayOption {
  const WeekDayOption(this.code, this.label);

  final String code;
  final String label;
}

/// Saturday first, as the Jalali week (and [Jalali.weekDay]) runs.
const List<WeekDayOption> kWeekDayOptions = [
  WeekDayOption('SAT', 'شنبه'),
  WeekDayOption('SUN', 'یکشنبه'),
  WeekDayOption('MON', 'دوشنبه'),
  WeekDayOption('TUE', 'سه‌شنبه'),
  WeekDayOption('WED', 'چهارشنبه'),
  WeekDayOption('THU', 'پنجشنبه'),
  WeekDayOption('FRI', 'جمعه'),
];

/// The recurrence code of [date]'s weekday, e.g. «SAT».
String weekdayCodeOf(Jalali date) => kWeekDayOptions[date.weekDay - 1].code;

/// The first day on or after [today] that falls on one of [codes]: the
/// server makes the first copy from today on, so a day already past this
/// week starts next week. Null without days.
Jalali? firstRepeatDay(Set<String> codes, Jalali today) {
  for (var ahead = 0; ahead < 7; ahead++) {
    final day = today.addDays(ahead);
    if (codes.contains(weekdayCodeOf(day))) return day;
  }
  return null;
}

/// The tag beside the first day: «امروز», «فردا», «هفته بعد» once this
/// week's day has passed, otherwise none.
String? firstRepeatDayTag(Jalali first, Jalali today) {
  final ahead = first.julianDayNumber - today.julianDayNumber;
  if (ahead == 0) return 'امروز';
  if (ahead == 1) return 'فردا';
  // Saturday starts the week: past Friday is next week.
  if (today.weekDay - 1 + ahead > 6) return 'هفته بعد';
  return null;
}

/// «یک روز» | «هر هفته»: a gray capsule with the picked side lifted in white.
class RepeatSwitch extends StatelessWidget {
  const RepeatSwitch({
    required this.isWeekly,
    required this.onOneDay,
    required this.onWeekly,
    this.glow,
  });

  final bool isWeekly;
  final VoidCallback onOneDay;
  final VoidCallback onWeekly;

  /// The first-time pulse on «هر هفته»; null when there is no tip.
  final Animation<double>? glow;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.gray1,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          children: [
            Expanded(
              child: _segment(
                key: const ValueKey('repeat-one-day'),
                label: 'یک روز',
                selected: !isWeekly,
                onTap: onOneDay,
              ),
            ),
            Expanded(
              child: glow == null
                  ? _segment(
                      key: const ValueKey('repeat-weekly'),
                      label: 'هر هفته',
                      icon: Icons.repeat_rounded,
                      selected: isWeekly,
                      onTap: onWeekly,
                    )
                  : AnimatedBuilder(
                      animation: glow!,
                      builder: (context, _) => _segment(
                        key: const ValueKey('repeat-weekly'),
                        label: 'هر هفته',
                        icon: Icons.repeat_rounded,
                        selected: isWeekly,
                        onTap: onWeekly,
                        glow: glow!.value,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segment({
    required Key key,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
    double? glow,
  }) {
    final lit = glow != null;
    return GestureDetector(
      key: key,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected || lit ? AppColors.whiteSec : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: lit
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.6 * glow),
                  width: 1.4,
                )
              : null,
          boxShadow: selected || lit
              ? [
                  BoxShadow(
                    color: lit
                        ? AppColors.primary.withValues(alpha: 0.2 * glow)
                        : AppColors.black1.withValues(alpha: 0.10),
                    blurRadius: lit ? 14 : 10,
                    offset: Offset(0, lit ? 0 : 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 17,
                color: lit ? AppColors.primary : AppColors.black1,
              ),
              const SizedBox(width: 6),
            ],
            ReText(
              label,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              // «هر هفته» stays dark even when off, so it never reads as
              // disabled; plain «یک روز» goes gray.
              color:
                  selected || icon != null ? AppColors.black1 : AppColors.gray,
            ),
          ],
        ),
      ),
    );
  }
}

/// The first-time tip under «هر هفته»; a tap closes it.
const _dayInitials = {
  'SAT': 'ش',
  'SUN': 'ی',
  'MON': 'د',
  'TUE': 'س',
  'WED': 'چ',
  'THU': 'پ',
  'FRI': 'ج',
};

/// «هر شنبه، دوشنبه و چهارشنبه»; «هر روز» for all seven.
String weeklyRepeatSummary(Set<String> codes) {
  final names = [
    for (final day in kWeekDayOptions)
      if (codes.contains(day.code)) day.label,
  ];
  if (names.isEmpty) return 'روزهای تکرار رو انتخاب کن.';
  if (names.length == kWeekDayOptions.length) return 'هر روز';
  if (names.length == 1) return 'هر ${names.single}';
  final head = names.sublist(0, names.length - 1).join('، ');
  return 'هر $head و ${names.last}';
}

/// Seven day circles in a row (picked ones dark), a summary of the pick and
/// an «هر روز» shortcut, then the day the first copy lands on.
class WeeklyRepeatDays extends StatelessWidget {
  const WeeklyRepeatDays({
    super.key,
    required this.selectedDays,
    required this.onToggleDay,
    required this.today,
  });

  final Set<String> selectedDays;
  final ValueChanged<String> onToggleDay;
  final Jalali today;

  @override
  Widget build(BuildContext context) {
    final all = selectedDays.length == kWeekDayOptions.length;
    final first = firstRepeatDay(selectedDays, today);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final day in kWeekDayOptions)
                _DayCircle(
                  key: ValueKey('repeat-day-${day.code}'),
                  label: _dayInitials[day.code]!,
                  selected: selectedDays.contains(day.code),
                  onTap: () => onToggleDay(day.code),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ReText(
                  weeklyRepeatSummary(selectedDays),
                  textAlign: TextAlign.right,
                  fontSize: first == null ? 12 : 13,
                  fontWeight: first == null ? FontWeight.w600 : FontWeight.w800,
                  color: first == null ? AppColors.gray : AppColors.black1,
                  overflow: TextOverflow.visible,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                key: const ValueKey('repeat-every-day'),
                onTap: () => onToggleDay('ALL'),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: all ? AppColors.black1 : AppColors.gray1,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ReText(
                    'هر روز',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: all ? AppColors.white : AppColors.dark8Color,
                  ),
                ),
              ),
            ],
          ),
          if (first != null) ...[
            const SizedBox(height: 10),
            FirstRepeatDayPill(day: first, today: today),
          ],
        ],
      ),
    );
  }
}

class _DayCircle extends StatelessWidget {
  const _DayCircle({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.black1 : AppColors.gray1,
          border: Border.all(
            color: selected ? AppColors.black1 : AppColors.gray2,
          ),
        ),
        child: ReText(
          label,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: selected ? AppColors.white : AppColors.dark8Color,
        ),
      ),
    );
  }
}

/// «اولین روز انجام  سه‌شنبه ۲۶ آبان  فردا»: when the first copy lands.
class FirstRepeatDayPill extends StatelessWidget {
  const FirstRepeatDayPill({super.key, required this.day, required this.today});

  final Jalali day;
  final Jalali today;

  @override
  Widget build(BuildContext context) {
    final tag = firstRepeatDayTag(day, today);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          key: const ValueKey('repeat-first-day'),
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
          decoration: BoxDecoration(
            color: AppColors.gray1,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.event_rounded, size: 17, color: AppColors.gray),
              const SizedBox(width: 6),
              // On a narrow screen the label gives way before the date.
              const Flexible(
                child: ReText(
                  'اولین روز انجام',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: ReText(
                  dayLabel(day),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black1,
                ),
              ),
              if (tag != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.whiteSec,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.gray2),
                  ),
                  child: ReText(
                    tag,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark8Color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
