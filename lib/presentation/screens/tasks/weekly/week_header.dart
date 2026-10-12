import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_widgets.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/tasks_view_mode.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/week_plan.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/weekly_plan_controller.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/_utils.dart';

export 'package:simo_learn/presentation/screens/tasks/weekly/tasks_view_mode.dart';

/// The «روزانه | هفتگی» switch at the start of the toolbar above the tasks.
/// Each side carries an icon of the layout it shows below: a list of the
/// day, or the week's columns.
class TasksViewModeToggle extends StatelessWidget {
  const TasksViewModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final TasksViewMode mode;
  final ValueChanged<TasksViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        key: const ValueKey('tasks-view-mode-toggle'),
        width: 196,
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.gray2,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: mode == TasksViewMode.day
                  ? AlignmentDirectional.centerStart
                  : AlignmentDirectional.centerEnd,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black1.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Row(
                children: [
                  _segment(
                    TasksViewMode.day,
                    'روزانه',
                    Icons.view_agenda_outlined,
                  ),
                  _segment(
                    TasksViewMode.week,
                    'هفتگی',
                    Icons.view_week_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segment(TasksViewMode value, String label, IconData icon) {
    final selected = mode == value;
    final color = selected ? AppColors.black1 : AppColors.gray;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label:
            '$label، نمایش ${value == TasksViewMode.day ? 'یک روز' : 'کل هفته'}',
        excludeSemantics: true,
        child: GestureDetector(
          key: ValueKey('tasks-view-mode-${value.name}'),
          behavior: HitTestBehavior.opaque,
          onTap: selected
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onChanged(value);
                },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 5),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ReText(
                    label,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The tasks screen's date picker, in both daily and weekly mode: the
/// selected date with a calendar button, and a week of day cards that follows
/// the finger to earlier or later weeks. Each card shows with a ring how much
/// of its day is done; the selected day sits under a black blob that flows
/// from day to day, and today keeps a small dot. Cards also accept dropped
/// tasks, so a task can move to any day without scrolling.
class WeekHeader extends StatefulWidget {
  const WeekHeader({
    super.key,
    required this.controller,
    required this.selectedDate,
    required this.onSelectDay,
    required this.onChangeWeek,
    required this.onPickDate,
    this.canShowWeek,
    this.onBlockedForward,
  });

  /// Supplies today and, for the week it holds, each day's progress.
  final WeeklyPlanController controller;
  final Jalali selectedDate;
  final ValueChanged<Jalali> onSelectDay;

  /// The user swiped to another week: +1 for the next, -1 for the previous.
  final ValueChanged<int> onChangeWeek;
  final VoidCallback onPickDate;

  /// Whether a week may be shown; the strip springs back from one that may
  /// not. All weeks are allowed when null.
  final bool Function(Jalali weekStart)? canShowWeek;
  final VoidCallback? onBlockedForward;

  @override
  State<WeekHeader> createState() => _WeekHeaderState();
}

class _WeekHeaderState extends State<WeekHeader> {
  /// Page of the current week; pages to either side are other weeks.
  static const int _origin = 10000;
  static const double _stripHeight = 104;

  late final PageController _pages;
  late int _settledPage;

  Jalali get _currentWeek => weekStartOf(widget.controller.today);

  int _pageOf(Jalali date) =>
      _origin + daysBetween(_currentWeek, weekStartOf(date)) ~/ 7;

  Jalali _weekOf(int page) => _currentWeek.addDays(7 * (page - _origin));

  @override
  void initState() {
    super.initState();
    _settledPage = _pageOf(widget.selectedDate);
    _pages = PageController(initialPage: _settledPage);
  }

  @override
  void didUpdateWidget(covariant WeekHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A date picked elsewhere (the calendar, a mode switch) brings its week.
    final target = _pageOf(widget.selectedDate);
    if (target != _settledPage) {
      _settledPage = target;
      if (_pages.hasClients) {
        _pages.animateToPage(
          target,
          duration: const Duration(milliseconds: 460),
          curve: AppMotion.settle,
        );
      }
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is! ScrollEndNotification || notification.depth != 0) {
      return false;
    }
    final position = _pages.page;
    if (position == null) return false;
    final page = position.round();
    // A released drag ends here too, mid-way; wait until the snap settles.
    if ((position - page).abs() > 0.001 || page == _settledPage) return false;

    if (!(widget.canShowWeek?.call(_weekOf(page)) ?? true)) {
      // Started after this notification: the position goes idle once it is
      // dispatched, which would cancel an animation started now.
      scheduleMicrotask(() {
        if (!mounted) return;
        _pages.animateToPage(
          _settledPage,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutBack,
        );
      });
      widget.onBlockedForward?.call();
      return false;
    }

    final weeks = page - _settledPage;
    _settledPage = page;
    HapticFeedback.selectionClick();
    widget.onChangeWeek(weeks);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final controller = widget.controller;
          return Column(
            key: const ValueKey('week-header'),
            mainAxisSize: MainAxisSize.min,
            children: [
              _SelectedDateBar(
                selectedDate: widget.selectedDate,
                today: controller.today,
                onPickDate: widget.onPickDate,
              ),
              const SizedBox(height: 12),
              Container(
                height: _stripHeight,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.gray1,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onScroll,
                  child: PageView.builder(
                    key: const ValueKey('week-strip'),
                    controller: _pages,
                    itemBuilder: (context, page) {
                      final weekStart = _weekOf(page);
                      final hasPlan = controller.hasData &&
                          isSameJalaliDay(controller.weekStart, weekStart);
                      return DepthOnSwipe(
                        pages: _pages,
                        page: page,
                        child: _WeekPage(
                          weekStart: weekStart,
                          plan: hasPlan ? controller.plan : null,
                          today: controller.today,
                          selectedDate: widget.selectedDate,
                          onSelectDay: widget.onSelectDay,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The selected date ("امروز، ۲۰ مهر ۱۴۰۵") and the calendar button.
class _SelectedDateBar extends StatelessWidget {
  const _SelectedDateBar({
    required this.selectedDate,
    required this.today,
    required this.onPickDate,
  });

  final Jalali selectedDate;
  final Jalali today;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                key: const ValueKey('week-range-title'),
                behavior: HitTestBehavior.opaque,
                onTap: onPickDate,
                // Scales down on narrow phones rather than being cut.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: _RollingDate(date: selectedDate, today: today),
                ),
              ),
            ),
            const SizedBox(width: 12),
            PressScale(
              onTap: onPickDate,
              child: Container(
                key: const ValueKey('week-pick-date'),
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.gray2, width: 1.2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(IconsaxPlusLinear.calendar,
                        size: 20, color: AppColors.black1),
                    SizedBox(width: 8),
                    ReText(
                      'انتخاب تاریخ',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "امروز،", "فردا،" or "دیروز،" before a date that close, else null.
String? relativeDayPrefix(Jalali date, Jalali today) {
  return switch (daysBetween(today, date)) {
    0 => 'امروز،',
    1 => 'فردا،',
    -1 => 'دیروز،',
    _ => null,
  };
}

/// The selected date: its numbers roll digit by digit, like an odometer,
/// while the month name slides into place. Today, tomorrow and yesterday
/// are named before it.
class _RollingDate extends StatelessWidget {
  const _RollingDate({required this.date, required this.today});

  final Jalali date;
  final Jalali today;

  @override
  Widget build(BuildContext context) {
    final month = kPersianMonths[date.month - 1];
    final prefix = relativeDayPrefix(date, today);
    return Semantics(
      container: true,
      label: convertToPersianNumbers(
        '${prefix == null ? '' : '$prefix '}${date.day} $month ${date.year}',
      ),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: AppMotion.settle,
              child: prefix == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsetsDirectional.only(end: 6),
                      child: _SlidingWord(
                        text: prefix,
                        color: AppColors.gray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            RollingNumber(value: date.day),
            const SizedBox(width: 6),
            _SlidingWord(text: month),
            const SizedBox(width: 6),
            RollingNumber(value: date.year),
          ],
        ),
      ),
    );
  }
}

/// A word that slides up into its new value.
class _SlidingWord extends StatelessWidget {
  const _SlidingWord({
    required this.text,
    this.color = AppColors.black1,
    this.fontWeight = FontWeight.w900,
  });

  final String text;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      switchInCurve: AppMotion.settle,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (current, previous) => Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [...previous, if (current != null) current],
      ),
      transitionBuilder: (child, animation) {
        final entering = child.key == ValueKey(text);
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
        text,
        key: ValueKey(text),
        fontSize: 18,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}

/// One week of cards. Layers, bottom to top: the white cards, the cards'
/// contents, and the selection blob, which carries a white copy of the
/// contents clipped to its own shape, so whatever it passes over turns white
/// exactly where it is.
class _WeekPage extends StatelessWidget {
  const _WeekPage({
    required this.weekStart,
    required this.plan,
    required this.today,
    required this.selectedDate,
    required this.onSelectDay,
  });

  final Jalali weekStart;

  /// This week's progress, when it is the week the controller holds.
  final WeekPlan? plan;
  final Jalali today;
  final Jalali selectedDate;
  final ValueChanged<Jalali> onSelectDay;

  static const double _gap = 2.5;

  Widget _contents({required bool onBlob}) {
    final selectedSlot = daysBetween(weekStart, selectedDate);
    return Row(
      children: [
        for (var index = 0; index < 7; index++)
          Expanded(
            child: _DayContent(
              date: weekStart.addDays(index),
              day: plan?.days[index],
              today: today,
              selected: index == selectedSlot,
              dark: onBlob ? 1 : 0,
              markToday: !onBlob,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedSlot = daysBetween(weekStart, selectedDate);
    return Padding(
      padding: const EdgeInsets.all(5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slotWidth = constraints.maxWidth / 7;
          return Stack(
            children: [
              Row(
                children: [
                  for (var index = 0; index < 7; index++)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: _gap),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  for (var index = 0; index < 7; index++)
                    Expanded(
                      child: _DayCard(
                        key: ValueKey('week-capsule-$index'),
                        date: weekStart.addDays(index),
                        day: plan?.days[index],
                        today: today,
                        selected: index == selectedSlot,
                        onTap: () => onSelectDay(weekStart.addDays(index)),
                      ),
                    ),
                ],
              ),
              if (selectedSlot >= 0 && selectedSlot < 7)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ExcludeSemantics(
                      child: _SelectionBlob(
                        first: selectedSlot,
                        last: selectedSlot,
                        slotWidth: slotWidth,
                        gap: _gap,
                        contents: _contents(onBlob: true),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// The black blob under the selected day. When it moves, the edge moving outward reaches first
/// and the other follows, so it stretches and settles like a drop of ink.
class _SelectionBlob extends StatefulWidget {
  const _SelectionBlob({
    required this.first,
    required this.last,
    required this.slotWidth,
    required this.gap,
    required this.contents,
  });

  /// The first and last selected slots; the same slot for a single day.
  final int first;
  final int last;
  final double slotWidth;
  final double gap;

  /// The week's contents drawn for a dark background, shown only inside the
  /// blob.
  final Widget contents;

  @override
  State<_SelectionBlob> createState() => _SelectionBlobState();
}

class _SelectionBlobState extends State<_SelectionBlob>
    with TickerProviderStateMixin {
  static const Curve _lead = Cubic(0.2, 0.9, 0.25, 1);
  static const Curve _trail = Cubic(0.6, 0, 0.2, 1);
  static const double _radius = 26;

  late final AnimationController _glide = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 440),
    value: 1,
  );

  /// Pops the blob in when a week first shows it.
  late final AnimationController _appear = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  )..forward();
  late (int, int) _from = (widget.first, widget.last);

  @override
  void didUpdateWidget(covariant _SelectionBlob oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.first != widget.first || oldWidget.last != widget.last) {
      _from = (oldWidget.first, oldWidget.last);
      _glide.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _glide.dispose();
    _appear.dispose();
    super.dispose();
  }

  /// Left edge of a slot; slots run right to left.
  double _leftOf(int slot) => (6 - slot) * widget.slotWidth;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glide, _appear]),
      builder: (context, _) {
        final t = _glide.value;
        // The range's left edge belongs to its last slot, the right edge to
        // its first.
        final fromLeft = _leftOf(_from.$2);
        final fromRight = _leftOf(_from.$1) + widget.slotWidth;
        final toLeft = _leftOf(widget.last);
        final toRight = _leftOf(widget.first) + widget.slotWidth;
        final leftT = (toLeft < fromLeft ? _lead : _trail).transform(t);
        final rightT = (toRight > fromRight ? _lead : _trail).transform(t);
        var rect = Rect.fromLTRB(
          fromLeft + (toLeft - fromLeft) * leftT + widget.gap,
          0,
          fromRight + (toRight - fromRight) * rightT - widget.gap,
          double.infinity,
        );
        final scale = 0.85 + 0.15 * Curves.easeOutBack.transform(_appear.value);
        if (scale != 1) {
          final inset = rect.width * (1 - scale) / 2;
          rect = Rect.fromLTRB(
              rect.left + inset, 0, rect.right - inset, double.infinity);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final shape = RRect.fromRectAndRadius(
              Rect.fromLTRB(rect.left, 0, rect.right, constraints.maxHeight),
              const Radius.circular(_radius),
            );
            return Stack(
              children: [
                Positioned.fromRect(
                  rect: shape.outerRect,
                  child: const DecoratedBox(
                    key: ValueKey('week-selection'),
                    decoration: BoxDecoration(
                      color: AppColors.black1,
                      borderRadius: BorderRadius.all(Radius.circular(_radius)),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ClipRRect(
                    clipper: _RRectClipper(shape),
                    child: widget.contents,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _RRectClipper extends CustomClipper<RRect> {
  const _RRectClipper(this.shape);

  final RRect shape;

  @override
  RRect getClip(Size size) => shape;

  @override
  bool shouldReclip(covariant _RRectClipper oldClipper) =>
      oldClipper.shape != shape;
}

/// A tappable day: selects the day.
class _DayCard extends StatefulWidget {
  const _DayCard({
    super.key,
    required this.date,
    required this.day,
    required this.today,
    required this.selected,
    required this.onTap,
  });

  final Jalali date;

  /// The day's tasks, when this week's plan is loaded.
  final WeekDayPlan? day;
  final Jalali today;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.selected,
      label: dayLabel(widget.date),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.5),
          child: AnimatedScale(
            scale: _pressed ? 0.9 : 1,
            duration: Duration(milliseconds: _pressed ? 90 : 280),
            curve: _pressed ? Curves.easeOut : Curves.easeOutBack,
            child: _DayContent(
              date: widget.date,
              day: widget.day,
              today: widget.today,
              selected: widget.selected,
              dark: 0,
              markToday: true,
            ),
          ),
        ),
      ),
    );
  }
}

/// A day's ring, number and name, drawn for a light ([dark] 0) or dark
/// ([dark] 1) background.
class _DayContent extends StatelessWidget {
  const _DayContent({
    required this.date,
    required this.day,
    required this.today,
    required this.selected,
    required this.dark,
    required this.markToday,
  });

  final Jalali date;
  final WeekDayPlan? day;
  final Jalali today;
  final bool selected;
  final double dark;

  /// Whether this copy carries the today dot (the blob's copy does not).
  final bool markToday;

  @override
  Widget build(BuildContext context) {
    final isToday = isSameJalaliDay(date, today);
    final number = Color.lerp(AppColors.black1, AppColors.white, dark)!;
    final label = Color.lerp(
      AppColors.gray,
      AppColors.white.withValues(alpha: 0.65),
      dark,
    )!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ProgressRing(day: day, dark: dark, today: isToday),
        const SizedBox(height: 8),
        ReText(
          '${date.day}',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: number,
        ),
        SizedBox(
          height: 14,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ReText(
              isToday ? 'امروز' : weekdayName(date),
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: label,
            ),
          ),
        ),
        SizedBox(
          height: 5,
          child: markToday && isToday && !selected
              ? TweenAnimationBuilder<double>(
                  key: const ValueKey('week-today-dot'),
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 520),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

/// How much of a day is done: a green check once all of it is, otherwise a
/// ring (orange for today, blue for other days) filling up as tasks finish.
class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.day,
    required this.dark,
    required this.today,
  });

  final WeekDayPlan? day;

  /// 0..1, how dark the card under the ring is.
  final double dark;
  final bool today;

  static const double _size = 22;

  @override
  Widget build(BuildContext context) {
    final day = this.day;
    if (day != null && day.isAllDone) {
      return Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: AppColors.done.withValues(alpha: 0.15 + 0.1 * dark),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, size: 15, color: AppColors.done),
      );
    }

    final progress =
        day == null || day.taskCount == 0 ? 0.0 : day.doneCount / day.taskCount;
    return SizedBox.square(
      dimension: _size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 600),
        curve: AppMotion.settle,
        builder: (context, value, _) => CircularProgressIndicator(
          value: progress == 0 ? 0 : value,
          strokeWidth: 2.6,
          strokeCap: StrokeCap.round,
          backgroundColor: Color.lerp(
            AppColors.dark4Color,
            AppColors.white.withValues(alpha: 0.22),
            dark,
          ),
          color: today ? AppColors.primary : AppColors.secondary,
        ),
      ),
    );
  }
}
