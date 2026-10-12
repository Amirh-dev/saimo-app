import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_widgets.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/week_plan.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/_utils.dart';

/// The app's calendar: a month of day cards in the week strip's style.
/// Months swipe like the week strip; tapping a day picks it. Days after
/// [lastDate] cannot be picked. Null when dismissed.
Future<Jalali?> showPlanDatePicker(
  BuildContext context, {
  required Jalali initialDate,
  required Jalali today,
  Jalali? lastDate,
}) {
  return showModalBottomSheet<Jalali>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _PlanDatePicker(
      initialDate: initialDate,
      today: today,
      lastDate: lastDate,
    ),
  );
}

int _monthIndex(Jalali date) => date.year * 12 + date.month - 1;

Jalali _monthOf(int index) => Jalali(index ~/ 12, index % 12 + 1, 1);

class _PlanDatePicker extends StatefulWidget {
  const _PlanDatePicker({
    required this.initialDate,
    required this.today,
    required this.lastDate,
  });

  final Jalali initialDate;
  final Jalali today;
  final Jalali? lastDate;

  @override
  State<_PlanDatePicker> createState() => _PlanDatePickerState();
}

class _PlanDatePickerState extends State<_PlanDatePicker> {
  /// Page of today's month; other months sit to either side.
  static const int _origin = 10000;
  static const double _cellHeight = 46;

  late final PageController _pages;
  late int _page;

  /// The day just tapped; the sheet closes once its pop has played.
  Jalali? _picked;

  int _pageOf(Jalali date) =>
      _origin + _monthIndex(date) - _monthIndex(widget.today);

  Jalali _monthAt(int page) =>
      _monthOf(_monthIndex(widget.today) + page - _origin);

  @override
  void initState() {
    super.initState();
    _page = _pageOf(widget.initialDate);
    _pages = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _browse(int months) {
    _pages.animateToPage(
      _page + months,
      duration: const Duration(milliseconds: 420),
      curve: AppMotion.settle,
    );
  }

  void _pick(Jalali day) {
    if (_picked != null) return;
    HapticFeedback.selectionClick();
    setState(() => _picked = day);
  }

  @override
  Widget build(BuildContext context) {
    final month = _monthAt(_page);
    final selected = _picked ?? widget.initialDate;

    return PlanSheetFrame(
      key: const ValueKey('calendar-sheet'),
      title: 'انتخاب تاریخ',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _MonthArrow(
                key: const ValueKey('calendar-prev'),
                // Mirrored in RTL: drawn as "›", towards earlier months.
                icon: Icons.chevron_left_rounded,
                label: 'ماه قبل',
                onTap: () => _browse(-1),
              ),
              Expanded(
                child: Center(
                  child: Row(
                    key: const ValueKey('calendar-month-title'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SlidingMonth(name: kPersianMonths[month.month - 1]),
                      const SizedBox(width: 6),
                      RollingNumber(value: month.year, fontSize: 17),
                    ],
                  ),
                ),
              ),
              _MonthArrow(
                key: const ValueKey('calendar-next'),
                icon: Icons.chevron_right_rounded,
                label: 'ماه بعد',
                onTap: () => _browse(1),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
            decoration: BoxDecoration(
              color: AppColors.gray1,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    for (var index = 0; index < 7; index++)
                      Expanded(
                        child: Center(
                          child: ReText(
                            kPersianWeekdays[index],
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            color: index == 6 ? AppColors.primary : AppColors.gray,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: (_cellHeight + 5) * 6,
                  child: PageView.builder(
                    key: const ValueKey('calendar-pages'),
                    controller: _pages,
                    onPageChanged: (page) {
                      HapticFeedback.selectionClick();
                      setState(() => _page = page);
                    },
                    itemBuilder: (context, page) => DepthOnSwipe(
                      pages: _pages,
                      page: page,
                      child: _MonthGrid(
                        month: _monthAt(page),
                        selected: selected,
                        today: widget.today,
                        lastDate: widget.lastDate,
                        picked: _picked,
                        cellHeight: _cellHeight,
                        onPick: _pick,
                        onPicked: () => Navigator.of(context).pop(_picked),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PlanPillButton.outlined(
            key: const ValueKey('calendar-today'),
            text: 'برو به امروز',
            icon: Icons.today_rounded,
            height: 48,
            onTap: () => Navigator.of(context).pop(widget.today),
          ),
        ],
      ),
    );
  }
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: PressScale(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gray2),
          ),
          child: Icon(icon, size: 22, color: AppColors.black1),
        ),
      ),
    );
  }
}

/// The month's name, sliding up into place when the month changes.
class _SlidingMonth extends StatelessWidget {
  const _SlidingMonth({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      switchInCurve: AppMotion.settle,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.center,
        children: [...previous, if (current != null) current],
      ),
      transitionBuilder: (child, animation) {
        final entering = child.key == ValueKey(name);
        return ClipRect(
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, entering ? 0.6 : -0.6),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
        );
      },
      child: ReText(
        name,
        key: ValueKey(name),
        fontSize: 17,
        fontWeight: FontWeight.w900,
        color: AppColors.black1,
      ),
    );
  }
}

/// Six weeks of day cards, starting on the Saturday row of the 1st.
class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.today,
    required this.lastDate,
    required this.picked,
    required this.cellHeight,
    required this.onPick,
    required this.onPicked,
  });

  /// The 1st of the month.
  final Jalali month;
  final Jalali selected;
  final Jalali today;
  final Jalali? lastDate;
  final Jalali? picked;
  final double cellHeight;
  final ValueChanged<Jalali> onPick;
  final VoidCallback onPicked;

  @override
  Widget build(BuildContext context) {
    final leading = month.weekDay - 1;
    final length = month.monthLength;
    return Column(
      children: [
        for (var row = 0; row < 6; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                for (var column = 0; column < 7; column++)
                  Expanded(child: _cell(row * 7 + column - leading + 1, length)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cell(int day, int length) {
    if (day < 1 || day > length) return SizedBox(height: cellHeight);
    final date = Jalali(month.year, month.month, day);
    final last = lastDate;
    return _DayCell(
      key: ValueKey('calendar-day-$day'),
      date: date,
      height: cellHeight,
      selected: isSameJalaliDay(date, selected),
      isToday: isSameJalaliDay(date, today),
      enabled: last == null || daysBetween(date, last) >= 0,
      justPicked: picked != null && isSameJalaliDay(date, picked!),
      onTap: () => onPick(date),
      onPicked: onPicked,
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    super.key,
    required this.date,
    required this.height,
    required this.selected,
    required this.isToday,
    required this.enabled,
    required this.justPicked,
    required this.onTap,
    required this.onPicked,
  });

  final Jalali date;
  final double height;
  final bool selected;
  final bool isToday;
  final bool enabled;
  final bool justPicked;
  final VoidCallback onTap;
  final VoidCallback onPicked;

  @override
  Widget build(BuildContext context) {
    final friday = date.weekDay == 7;
    return Opacity(
      opacity: enabled ? 1 : 0.3,
      child: Semantics(
        button: true,
        enabled: enabled,
        selected: selected,
        label: dayLabel(date),
        child: PressScale(
          onTap: enabled ? onTap : null,
          child: Container(
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (selected)
                  // Pops in on the tapped day; the sheet closes after it.
                  TweenAnimationBuilder<double>(
                    key: const ValueKey('calendar-selected'),
                    tween: Tween(begin: justPicked ? 0.4 : 1, end: 1),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    onEnd: justPicked ? onPicked : null,
                    builder: (context, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.black1,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 5),
                    ReText(
                      '${date.day}',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? AppColors.white
                          : friday
                              ? AppColors.primary
                              : AppColors.black1,
                    ),
                    SizedBox(
                      height: 5,
                      child: isToday && !selected
                          ? Container(
                              key: const ValueKey('calendar-today-dot'),
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
