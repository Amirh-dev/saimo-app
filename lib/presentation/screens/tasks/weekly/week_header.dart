import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_widgets.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/tasks_view_mode.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/week_plan.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/weekly_plan_controller.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/weekly_plan_view.dart'
    show VisibleDays;
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
        width: 172,
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
/// from day to day, and today keeps a small dot.
///
/// When [compact] (weekly mode, where the board names each day and its
/// date), the cards fold away into a single row of their rings, the blob
/// shrinks to a dot on the selected day, and a soft window behind the rings
/// follows the days the board shows ([visibleDays]).
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
    this.compact = false,
    this.visibleDays,
  });

  final bool compact;
  final ValueListenable<VisibleDays>? visibleDays;

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

class _WeekHeaderState extends State<WeekHeader>
    with SingleTickerProviderStateMixin {
  /// Page of the current week; pages to either side are other weeks.
  static const int _origin = 10000;
  static const double _stripHeight = 104;
  static const double _compactHeight = 44;

  late final PageController _pages;
  late int _settledPage;

  /// 0 with the full cards, 1 folded into the row of rings.
  late final AnimationController _fold = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
    value: widget.compact ? 1 : 0,
  );

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
    if (oldWidget.compact != widget.compact) {
      final target = widget.compact ? 1.0 : 0.0;
      if (reduceMotion(context)) {
        _fold.value = target;
      } else {
        _fold.animateTo(target);
      }
    }
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
    _fold.dispose();
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
              // Only the tray follows the fold: it closes around the middle
              // of a week that keeps its full size, so the week is not laid
              // out again on every frame of it, only repainted.
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _fold,
                  builder: (context, week) {
                    final eased = Curves.easeInOutCubic.transform(_fold.value);
                    return Container(
                      key: const ValueKey('week-tray'),
                      height: lerpDouble(_stripHeight, _compactHeight, eased),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        // The tray melts into the panel as the cards fold.
                        color:
                            Color.lerp(AppColors.gray1, AppColors.white, eased),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: week,
                    );
                  },
                  child: OverflowBox(
                    minHeight: _stripHeight,
                    maxHeight: _stripHeight,
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
                              fold: _fold,
                              visibleDays: hasPlan ? widget.visibleDays : null,
                            ),
                          );
                        },
                      ),
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

/// One week of cards. Layers, bottom to top: the white cards (painted in one
/// pass, with the window of the days the board shows), the cards' contents,
/// and the selection blob, which carries a white copy of the contents
/// clipped to its own shape, so whatever it passes over turns white exactly
/// where it is.
///
/// Everything [fold] moves is painted or transformed, never laid out again,
/// so folding the strip costs a repaint per frame and no rebuilds.
class _WeekPage extends StatelessWidget {
  const _WeekPage({
    required this.weekStart,
    required this.plan,
    required this.today,
    required this.selectedDate,
    required this.onSelectDay,
    required this.fold,
    required this.visibleDays,
  });

  final Jalali weekStart;

  /// This week's progress, when it is the week the controller holds.
  final WeekPlan? plan;
  final Jalali today;
  final Jalali selectedDate;
  final ValueChanged<Jalali> onSelectDay;

  /// 0 with full cards, 1 folded into a row of rings.
  final Animation<double> fold;

  /// The days the board shows, for the window behind the rings.
  final ValueListenable<VisibleDays>? visibleDays;

  static const double _gap = 2.5;
  static const double _dot = 30;

  /// Each day folds a moment after its neighbour nearer the selected day, so
  /// the fold ripples outward from it.
  static const double _ripple = 0.06;

  static Curve slotCurve(int slot, int anchor) {
    final delay = (slot - anchor).abs() * _ripple;
    return Interval(delay, delay + 1 - 6 * _ripple);
  }

  /// A card shrinks from its full slot to a dot behind its ring, a little
  /// past it and back, as if on a spring.
  static RRect cardShape(int slot, double slotWidth, double height, double t) {
    final left = (6 - slot) * slotWidth;
    final full = Rect.fromLTWH(left + _gap, 0, slotWidth - 2 * _gap, height);
    final dot = Rect.fromCenter(
      center: Offset(left + slotWidth / 2, height / 2),
      width: _dot,
      height: _dot,
    );
    return RRect.fromRectAndRadius(
      Rect.lerp(full, dot, Curves.easeOutBack.transform(t))!,
      Radius.circular(lerpDouble(26, _dot / 2, t)!),
    );
  }

  int get _anchor {
    final selected = daysBetween(weekStart, selectedDate);
    return selected >= 0 && selected < 7 ? selected : 3;
  }

  Animation<double> _foldOf(int slot) =>
      fold.drive(CurveTween(curve: slotCurve(slot, _anchor)));

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
              fold: _foldOf(index),
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
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _CardsPainter(
                fold: fold,
                anchor: _anchor,
                visibleDays: visibleDays,
              ),
            ),
          ),
          Positioned.fill(
            child: Row(
              children: [
                for (var index = 0; index < 7; index++)
                  Expanded(
                    child: _DayCard(
                      key: ValueKey('week-capsule-$index'),
                      date: weekStart.addDays(index),
                      day: plan?.days[index],
                      today: today,
                      selected: index == selectedSlot,
                      fold: _foldOf(index),
                      onTap: () => onSelectDay(weekStart.addDays(index)),
                    ),
                  ),
              ],
            ),
          ),
          if (selectedSlot >= 0 && selectedSlot < 7)
            Positioned.fill(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: _SelectionBlob(
                    first: selectedSlot,
                    last: selectedSlot,
                    gap: _gap,
                    fold: _foldOf(selectedSlot),
                    dot: _dot,
                    contents: _contents(onBlob: true),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The white cards, fading as they shrink to dots, and under them the soft
/// window behind the rings of the days the board shows. Repaints with the
/// fold and the board's scroll; never rebuilds.
class _CardsPainter extends CustomPainter {
  _CardsPainter({
    required this.fold,
    required this.anchor,
    required this.visibleDays,
  }) : super(repaint: Listenable.merge([fold, visibleDays]));

  final Animation<double> fold;
  final int anchor;
  final ValueListenable<VisibleDays>? visibleDays;

  static const Interval _windowIn = Interval(0.55, 1, curve: Curves.easeOut);

  @override
  void paint(Canvas canvas, Size size) {
    final slotWidth = size.width / 7;
    final value = fold.value;
    final paint = Paint();

    final visible = visibleDays?.value;
    final shown = _windowIn.transform(value);
    if (visible != null && shown > 0) {
      // Days run right to left: Saturday's slot is the rightmost.
      final right = ((7 - visible.first) * slotWidth).clamp(0.0, size.width);
      final left = ((7 - visible.first - visible.count) * slotWidth)
          .clamp(0.0, size.width);
      const height = _WeekPage._dot + 4;
      final top = (size.height - height) / 2;
      paint.color = AppColors.gray1.withValues(alpha: shown);
      canvas.drawRRect(
        RRect.fromLTRBR(
            left, top, right, top + height, const Radius.circular(height / 2)),
        paint,
      );
    }

    for (var slot = 0; slot < 7; slot++) {
      final t = _WeekPage.slotCurve(slot, anchor).transform(value);
      if (t >= 1) continue;
      paint.color = AppColors.white.withValues(alpha: 1 - t);
      canvas.drawRRect(
          _WeekPage.cardShape(slot, slotWidth, size.height, t), paint);
    }
  }

  @override
  bool shouldRepaint(_CardsPainter oldDelegate) =>
      oldDelegate.fold != fold ||
      oldDelegate.anchor != anchor ||
      oldDelegate.visibleDays != visibleDays;
}

/// The black blob under the selected day. When it moves, the edge moving outward reaches first
/// and the other follows, so it stretches and settles like a drop of ink.
/// As the strip folds it shrinks to a dot behind the day's ring.
class _SelectionBlob extends StatefulWidget {
  const _SelectionBlob({
    required this.first,
    required this.last,
    required this.gap,
    required this.contents,
    this.fold = kAlwaysDismissedAnimation,
    this.dot = 30,
  });

  /// The first and last selected slots; the same slot for a single day.
  final int first;
  final int last;
  final double gap;

  /// 0 covering the whole card, 1 shrunk to a [dot] behind the ring.
  final Animation<double> fold;
  final double dot;

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

  /// The blob's shape in a week [size] wide and tall.
  RRect _shape(Size size) {
    final slotWidth = size.width / 7;
    double leftOf(int slot) => (6 - slot) * slotWidth; // right to left
    final t = _glide.value;
    // The range's left edge belongs to its last slot, the right edge to its
    // first.
    final fromLeft = leftOf(_from.$2);
    final fromRight = leftOf(_from.$1) + slotWidth;
    final toLeft = leftOf(widget.last);
    final toRight = leftOf(widget.first) + slotWidth;
    final leftT = (toLeft < fromLeft ? _lead : _trail).transform(t);
    final rightT = (toRight > fromRight ? _lead : _trail).transform(t);
    var left = fromLeft + (toLeft - fromLeft) * leftT + widget.gap;
    var right = fromRight + (toRight - fromRight) * rightT - widget.gap;
    final scale = 0.85 + 0.15 * Curves.easeOutBack.transform(_appear.value);
    if (scale != 1) {
      final inset = (right - left) * (1 - scale) / 2;
      left += inset;
      right -= inset;
    }

    final full = Rect.fromLTRB(left, 0, right, size.height);
    final dot = Rect.fromCenter(
      center: Offset(full.center.dx, size.height / 2),
      width: widget.dot,
      height: widget.dot,
    );
    final fold = widget.fold.value;
    return RRect.fromRectAndRadius(
      Rect.lerp(full, dot, Curves.easeOutBack.transform(fold))!,
      Radius.circular(lerpDouble(_radius, widget.dot / 2, fold)!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final motion = Listenable.merge([_glide, _appear, widget.fold]);
    // Painted and clipped from the same shape, both following [motion]
    // without rebuilding.
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _BlobPainter(motion: motion, shape: _shape),
            child: ClipRRect(
              clipper: _BlobClipper(motion: motion, shape: _shape),
              child: widget.contents,
            ),
          ),
        ),
        // An empty box over the blob, so it can be found where it is.
        Positioned.fill(
          child: CustomSingleChildLayout(
            delegate: _BlobLayout(motion: motion, shape: _shape),
            child: const SizedBox.expand(key: ValueKey('week-selection')),
          ),
        ),
      ],
    );
  }
}

class _BlobLayout extends SingleChildLayoutDelegate {
  _BlobLayout({required this.motion, required this.shape})
      : super(relayout: motion);

  final Listenable motion;
  final RRect Function(Size size) shape;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.tight(shape(constraints.biggest).outerRect.size);

  @override
  Offset getPositionForChild(Size size, Size childSize) =>
      shape(size).outerRect.topLeft;

  @override
  bool shouldRelayout(_BlobLayout oldDelegate) =>
      oldDelegate.motion != motion || oldDelegate.shape != shape;
}

class _BlobPainter extends CustomPainter {
  _BlobPainter({required this.motion, required this.shape})
      : super(repaint: motion);

  final Listenable motion;
  final RRect Function(Size size) shape;

  static final Paint _fill = Paint()..color = AppColors.black1;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawRRect(shape(size), _fill);

  @override
  bool shouldRepaint(_BlobPainter oldDelegate) =>
      oldDelegate.motion != motion || oldDelegate.shape != shape;
}

class _BlobClipper extends CustomClipper<RRect> {
  _BlobClipper({required this.motion, required this.shape})
      : super(reclip: motion);

  final Listenable motion;
  final RRect Function(Size size) shape;

  @override
  RRect getClip(Size size) => shape(size);

  @override
  bool shouldReclip(_BlobClipper oldClipper) =>
      oldClipper.motion != motion || oldClipper.shape != shape;
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
    this.fold = kAlwaysDismissedAnimation,
  });

  final Jalali date;

  /// The day's tasks, when this week's plan is loaded.
  final WeekDayPlan? day;
  final Jalali today;
  final bool selected;
  final VoidCallback onTap;
  final Animation<double> fold;

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
              fold: widget.fold,
            ),
          ),
        ),
      ),
    );
  }
}

/// A day's ring, number and name, drawn for a light ([dark] 0) or dark
/// ([dark] 1) background. As [fold] runs, the number and name fade while
/// the ring drops to the middle of the tray and shrinks a little; all of it
/// by transform and fade, so the day is never laid out again.
class _DayContent extends StatelessWidget {
  const _DayContent({
    required this.date,
    required this.day,
    required this.today,
    required this.selected,
    required this.dark,
    required this.markToday,
    this.fold = kAlwaysDismissedAnimation,
  });

  final Jalali date;
  final WeekDayPlan? day;
  final Jalali today;
  final bool selected;
  final double dark;

  /// Whether this copy carries the today dot (the blob's copy does not).
  final bool markToday;

  /// 0 in full; at 1 only the ring is left, a little smaller.
  final Animation<double> fold;

  /// The number, the name and the today dot under the ring. The ring sits
  /// half of this above the middle, so moving it down by that much centres
  /// it.
  static const double _detailsHeight = 46;

  static final Animatable<double> _fadeOut = Tween<double>(begin: 1, end: 0)
      .chain(CurveTween(curve: const Interval(0, 0.45, curve: Curves.easeOut)));
  static final Animatable<Offset> _sink =
      Tween<Offset>(begin: Offset.zero, end: const Offset(0, 0.12))
          .chain(CurveTween(curve: Curves.easeIn));

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
        AnimatedBuilder(
          animation: fold,
          child: _ProgressRing(day: day, dark: dark, today: isToday),
          builder: (context, ring) {
            final t = fold.value;
            if (t == 0) return ring!;
            final drop =
                _detailsHeight / 2 * Curves.easeInOutCubic.transform(t);
            final scale = lerpDouble(1, 0.82, Curves.easeOutBack.transform(t))!;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.translationValues(0, drop, 0)
                ..scaleByDouble(scale, scale, 1, 1),
              child: ring,
            );
          },
        ),
        SizedBox(
          height: _detailsHeight,
          child: FadeTransition(
            opacity: fold.drive(_fadeOut),
            child: SlideTransition(
              position: fold.drive(_sink),
              child: OverflowBox(
                maxHeight: double.infinity,
                alignment: Alignment.topCenter,
                child: _details(isToday, number, label),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _details(bool isToday, Color number, Color label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
