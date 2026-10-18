import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';
import 'package:simo_learn/presentation/screens/tasks/tasks_api.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/checklists_popup.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_widgets.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/week_plan.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/weekly_plan_controller.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/presentation/widgets/re_toast.dart';
import 'package:simo_learn/utils/_utils.dart';

/// The days in view on the board: the first (counted from Saturday,
/// fractional while scrolling between days) and how many fit.
typedef VisibleDays = ({double first, double count});

/// All seven days fit side by side when each gets this much; narrower
/// screens show about [_visibleColumns] days and scroll sideways.
const double _fullColumnWidth = 132;
const double _visibleColumns = 2.35;
const double _minColumnWidth = 136;

/// Half the gap between two day lanes, and a lane's inner padding.
const double _columnPad = 5;
const double _lanePad = 6;
const double _laneRadius = 24;
const double _taskGap = 8;
const double _chipHeight = 40;
const double _chipRadius = 22;

/// The board's color; its sides fade into it.
const Color _boardColor = AppColors.white;

/// While a time box is dragged this close to the board's side, the days
/// scroll that way.
const double _dragEdge = 44;

/// How far past an edge the days must be pulled to turn the week.
const double _weekPullDistance = 80;
const double _dragScrollStep = 9;

/// A timed task's box grows with its time box: 25 minutes is the smallest
/// box, three hours about two and a half times as tall.
const double _boxBase = 34;
const double _boxPerMinute = 0.5;
const double _boxMinHeight = 52;
const double _boxMaxHeight = 150;

double _boxHeight(int minutes) =>
    (_boxBase + minutes * _boxPerMinute).clamp(_boxMinHeight, _boxMaxHeight);

/// Whether a task can go to another day: a started timer belongs to the day
/// it ran on, and a finished task stays where it was done.
bool _isMovable(Map<String, dynamic> task) =>
    (task['status'] as String? ?? 'pending') == 'pending';

/// The body of week mode: the week as columns of time boxes. Each day stacks
/// its tasks, a timed task as tall as the time it was given, and ends with a
/// button that adds to that day. The columns scroll sideways under their day
/// headers on narrow screens.
///
/// A time box opens its details on a tap and moves to another day when held
/// and dropped there. A day's checklists open in a popup where they are
/// checked off. Each day's bar compares its time boxes with the week's
/// busiest day. A past day with unfinished work offers to bring it to today. The week never
/// switches to daily mode on its own.
class WeeklyPlanView extends StatefulWidget {
  const WeeklyPlanView({
    super.key,
    required this.controller,
    required this.onOpenTask,
    required this.onAddToDay,
    required this.onMoveTasks,
    required this.onRefresh,
    this.onChangeWeek,
    this.visibleDays,
  });

  final WeeklyPlanController controller;

  /// Told which days are in view as the columns scroll: the first one (from
  /// Saturday, fractional while between days) and how many fit.
  final ValueNotifier<VisibleDays>? visibleDays;

  /// The days were pulled past their edge: -1 past Saturday (the right
  /// side) for the previous week, +1 past Friday (the left) for the next.
  final ValueChanged<int>? onChangeWeek;

  /// Opens a task's details.
  final ValueChanged<Map<String, dynamic>> onOpenTask;

  /// Starts adding a task to a day: a time box, or a checklist when
  /// [timed] is false.
  final void Function(Jalali day, {bool timed}) onAddToDay;

  /// Saves tasks moved to [day]; the week already shows them there.
  final void Function(List<Map<String, dynamic>> tasks, Jalali day) onMoveTasks;
  final Future<void> Function() onRefresh;

  @override
  State<WeeklyPlanView> createState() => WeeklyPlanViewState();
}

class WeeklyPlanViewState extends State<WeeklyPlanView> {
  final ScrollController _scroll = ScrollController();

  /// The day columns, and the day headers that follow them sideways.
  final ScrollController _columns = ScrollController();
  final ScrollController _headers = ScrollController();
  final GlobalKey _boardKey = GlobalKey();

  double _columnWidth = _minColumnWidth;

  /// The week the columns were last placed for.
  String? _placedWeek;

  /// The day last asked for with [scrollToDay]; a week that loads later
  /// opens on it.
  Jalali? _requestedDay;

  /// Scrolls the days while a time box is held near the board's side.
  Timer? _edgeScroll;
  Offset? _dragPoint;

  WeeklyPlanController get _controller => widget.controller;

  /// How far the days are pulled past an edge, as a share of
  /// [_weekPullDistance]: negative past Saturday, positive past Friday.
  final ValueNotifier<double> _pull = ValueNotifier(0);
  bool _pulling = false;

  @override
  void initState() {
    super.initState();
    _columns.addListener(_syncHeaders);
  }

  @override
  void dispose() {
    _edgeScroll?.cancel();
    _columns.removeListener(_syncHeaders);
    _scroll.dispose();
    _columns.dispose();
    _headers.dispose();
    _pull.dispose();
    super.dispose();
  }

  // ------------------------------------------------- pulling to next week

  /// Follows a finger dragging the days sideways; pulled far enough past an
  /// edge and let go, the week turns.
  bool _onColumnsScroll(ScrollNotification notification) {
    if (widget.onChangeWeek == null ||
        notification.depth != 0 ||
        notification.metrics.axis != Axis.horizontal) {
      return false;
    }
    final metrics = notification.metrics;
    final dragging = switch (notification) {
      ScrollStartNotification(:final dragDetails) => dragDetails != null,
      ScrollUpdateNotification(:final dragDetails) => dragDetails != null,
      OverscrollNotification(:final dragDetails) => dragDetails != null,
      _ => false,
    };

    // Only measured while a finger drags; letting go is read from the
    // pointer itself ([_onFingerUp]), which arrives even if the days are
    // rebuilt before the scroll settles.
    if (dragging) {
      _pulling = true;
      final beforeStart = metrics.minScrollExtent - metrics.pixels;
      final afterEnd = metrics.pixels - metrics.maxScrollExtent;
      final pulled = beforeStart > 0
          ? -beforeStart / _weekPullDistance
          : afterEnd > 0
              ? afterEnd / _weekPullDistance
              : 0.0;
      final wasArmed = _pull.value.abs() >= 1;
      _pull.value = pulled;
      if (!wasArmed && pulled.abs() >= 1) HapticFeedback.mediumImpact();
    }
    return false;
  }

  /// The finger left the days: turn the week if it was pulled far enough,
  /// and in any case put the hint away.
  void _onFingerUp(PointerEvent _) {
    final pulled = _pull.value;
    final wasPulling = _pulling;
    _pulling = false;
    _pull.value = 0;
    if (wasPulling && pulled.abs() >= 1) {
      widget.onChangeWeek?.call(pulled < 0 ? -1 : 1);
    }
  }

  void _onFingerCancel(PointerEvent _) {
    _pulling = false;
    _pull.value = 0;
  }

  void _syncHeaders() {
    if (_columns.hasClients && _headers.hasClients) {
      _headers.jumpTo(_columns.offset);
    }
    _reportVisibleDays();
  }

  void _reportVisibleDays() {
    final notifier = widget.visibleDays;
    if (notifier == null || !_columns.hasClients) return;
    final position = _columns.position;
    if (!position.hasViewportDimension || _columnWidth <= 0) return;
    notifier.value = (
      first: (position.pixels / _columnWidth).clamp(0.0, 7.0),
      count: position.viewportDimension / _columnWidth,
    );
  }

  int? _indexOf(Jalali? day) {
    if (day == null) return null;
    final index = daysBetween(_controller.weekStart, day);
    return index >= 0 && index <= 6 ? index : null;
  }

  double _offsetOf(int index) {
    final position = _columns.position;
    return (index * _columnWidth)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
  }

  /// Scrolls the week sideways so [day] is the first column in view.
  Future<void> scrollToDay(Jalali day, {bool animate = true}) async {
    _requestedDay = day;
    // Lets a week whose data has only now arrived lay out first.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || !identical(_requestedDay, day)) return;
    final index = _indexOf(day);
    if (index == null || !_controller.hasData || !_columns.hasClients) return;

    final target = _offsetOf(index);
    if (animate && !reduceMotion(context)) {
      await _columns.animateTo(
        target,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    } else {
      _columns.jumpTo(target);
    }
  }

  /// A new week opens on the day asked for, else on today, else on its first
  /// day.
  void _placeColumns() {
    if (!mounted || !_controller.hasData || !_columns.hasClients) return;
    final today = _controller.plan.days.indexWhere((day) => day.isToday);
    final index = _indexOf(_requestedDay) ?? (today >= 0 ? today : 0);
    _columns.jumpTo(_offsetOf(index));
    _syncHeaders();
  }

  // ------------------------------------------------------------- dragging

  void _onDragStarted() {
    HapticFeedback.mediumImpact();
    _edgeScroll?.cancel();
    _edgeScroll = Timer.periodic(
        const Duration(milliseconds: 16), (_) => _scrollAtEdge());
  }

  void _onDragEnded() {
    _edgeScroll?.cancel();
    _edgeScroll = null;
    _dragPoint = null;
  }

  void _scrollAtEdge() {
    final board = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    final point = _dragPoint;
    if (board == null || point == null || !_columns.hasClients) return;
    final x = board.globalToLocal(point).dx;
    // Days run right to left: the left side holds the later days, which lie
    // further along the scroll.
    final step = x < _dragEdge
        ? _dragScrollStep
        : x > board.size.width - _dragEdge
            ? -_dragScrollStep
            : 0.0;
    if (step == 0) return;
    final position = _columns.position;
    final target = (position.pixels + step)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if (target != position.pixels) _columns.jumpTo(target);
  }

  void _move(List<Map<String, dynamic>> tasks, Jalali day) {
    if (tasks.isEmpty) return;
    _controller.showMoved(tasks, day);
    widget.onMoveTasks(tasks, day);
  }

  // ----------------------------------------------------------- checklists

  void _openChecklists(WeekDayPlan day) {
    final date = day.date;
    showChecklistsPopup(
      context,
      listenable: _controller,
      date: date,
      tasks: () => [
        for (final task in _controller.plan.dayOf(date)?.tasks ??
            const <Map<String, dynamic>>[])
          if (!isTimedTask(task)) task,
      ],
      onToggle: _toggleChecklist,
      onOpenTask: widget.onOpenTask,
      onAdd: day.isPast ? null : () => widget.onAddToDay(date, timed: false),
    );
  }

  Future<void> _toggleChecklist(Map<String, dynamic> task) async {
    try {
      await _controller.setTaskDone(task, done: !isTaskDone(task));
    } catch (error) {
      if (!mounted) return;
      showReToast(
        context,
        error is TaskActionException
            ? error.message
            : 'تغییر وضعیت تسک ناموفق بود. دوباره تلاش کنید.',
        ReToastType.failed,
      );
    }
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListenableBuilder(
        key: const ValueKey('weekly-plan-view'),
        listenable: _controller,
        builder: (context, _) {
          if (_controller.hasError) {
            return _ErrorState(onRetry: () => _controller.reload());
          }
          if (!_controller.hasData) return const _WeekPlanSkeleton();

          final plan = _controller.plan;
          final weekKey =
              '${plan.start.year}-${plan.start.month}-${plan.start.day}';
          if (weekKey != _placedWeek) {
            _placedWeek = weekKey;
            // A new week starts with nothing pulled (after this build, as
            // the hints listen to it).
            _pulling = false;
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _pull.value = 0);
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _placeColumns());
          }

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: _buildBoard(plan, weekKey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBoard(WeekPlan plan, String weekKey) {
    // On an empty week, the first day still ahead says where to start.
    final hintIndex =
        plan.isEmpty ? plan.days.indexWhere((day) => !day.isPast) : -1;
    return Container(
      key: _boardKey,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        color: _boardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final available = constraints.maxWidth;
          _columnWidth = available / 7 >= _fullColumnWidth
              ? available / 7
              : math.max(_minColumnWidth, available / _visibleColumns);
          final width = _columnWidth * 7;

          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SingleChildScrollView(
                    controller: _headers,
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Row(
                      children: [
                        for (var index = 0; index < 7; index++)
                          SizedBox(
                            width: _columnWidth,
                            child: _DayHeader(
                              key: ValueKey('week-day-header-$index'),
                              day: plan.days[index],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildColumns(plan, weekKey, width, hintIndex),
                  ),
                ],
              ),
              // The days fade out at the board's sides when more lie beyond.
              if (width > available) ...[
                const _EdgeFade(start: true),
                const _EdgeFade(start: false),
              ],
              // Shown while the days are pulled past an edge.
              _WeekPullHint(pull: _pull, next: false),
              _WeekPullHint(pull: _pull, next: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildColumns(
    WeekPlan plan,
    String weekKey,
    double width,
    int hintIndex,
  ) {
    return LayoutBuilder(
      builder: (context, viewport) => RefreshIndicator(
        color: AppColors.primary,
        onRefresh: widget.onRefresh,
        child: SingleChildScrollView(
          key: const ValueKey('week-columns'),
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Listener(
            onPointerUp: _onFingerUp,
            onPointerCancel: _onFingerCancel,
            child: NotificationListener<ScrollNotification>(
              onNotification: _onColumnsScroll,
              child: SingleChildScrollView(
                // A new week starts from its first column and replays
                // the entrance; a reload of the same week updates in
                // place.
                key: ValueKey('week-columns-$weekKey'),
                controller: _columns,
                scrollDirection: Axis.horizontal,
                // Elastic past the edges, where a long pull turns the
                // week.
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: width,
                    maxWidth: width,
                    minHeight: viewport.maxHeight,
                  ),
                  // Every column as tall as the tallest, so a box can be
                  // dropped anywhere in a day.
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var index = 0; index < 7; index++)
                          _Entrance(
                            order: index,
                            child: _DayColumn(
                              key: ValueKey('week-day-column-$index'),
                              width: _columnWidth,
                              index: index,
                              day: plan.days[index],
                              today: _controller.today,
                              showHint: index == hintIndex,
                              onOpenTask: widget.onOpenTask,
                              onShowChecklists: () =>
                                  _openChecklists(plan.days[index]),
                              onAdd: () =>
                                  widget.onAddToDay(plan.days[index].date),
                              onMove: _move,
                              onDragStarted: _onDragStarted,
                              onDragMoved: (point) => _dragPoint = point,
                              onDragEnded: _onDragEnded,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Previous week" or "next week" at the side the days are pulled from: it
/// fades in with the pull and fills in once letting go will turn the week.
class _WeekPullHint extends StatelessWidget {
  const _WeekPullHint({required this.pull, required this.next});

  final ValueNotifier<double> pull;

  /// Past Friday (the left side) for the next week; past Saturday (the
  /// right) for the previous one.
  final bool next;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: next ? 10 : null,
      right: next ? null : 10,
      child: IgnorePointer(
        child: Center(
          child: ValueListenableBuilder<double>(
            valueListenable: pull,
            builder: (context, value, _) {
              final share = next ? value : -value;
              if (share <= 0) return const SizedBox.shrink();
              final armed = share >= 1;
              final shown = share.clamp(0.0, 1.0);
              return Opacity(
                opacity: shown,
                child: Transform.scale(
                  scale: 0.8 + 0.2 * shown,
                  child: AnimatedContainer(
                    key: ValueKey(
                        next ? 'week-pull-next' : 'week-pull-previous'),
                    duration: const Duration(milliseconds: 160),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: armed ? AppColors.black1 : AppColors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: armed ? AppColors.black1 : AppColors.gray2,
                      ),
                    ),
                    // The arrow points out to the side the week comes from;
                    // laid out LTR so the chevrons are not mirrored.
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (next) ...[
                            Icon(
                              Icons.chevron_left_rounded,
                              size: 18,
                              color: armed ? AppColors.white : AppColors.black1,
                            ),
                            const SizedBox(width: 2),
                          ],
                          ReText(
                            next ? 'هفته بعد' : 'هفته قبل',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: armed ? AppColors.white : AppColors.black1,
                          ),
                          if (!next) ...[
                            const SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: armed ? AppColors.white : AppColors.black1,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A soft fade at one side of the board, so the days scrolled out of view
/// melt into it instead of being cut off.
class _EdgeFade extends StatelessWidget {
  const _EdgeFade({required this.start});

  /// The start side (the right, Saturday's) or the end (the left).
  final bool start;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: 0,
      bottom: 0,
      start: start ? 0 : null,
      end: start ? null : 0,
      width: 10,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: start
                  ? AlignmentDirectional.centerStart
                  : AlignmentDirectional.centerEnd,
              end: start
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              colors: [_boardColor, _boardColor.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}

class _Entrance extends StatelessWidget {
  const _Entrance({required this.order, required this.child});

  final int order;
  final Widget child;

  static const int _stepMs = 45;
  static const int _riseMs = 380;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return child;
    final total = _riseMs + order * _stepMs;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(order * _stepMs / total, 1, curve: AppMotion.settle),
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value.clamp(0.0, 1.0),
        child: Transform.translate(
            offset: Offset(0, (1 - value) * 14), child: child),
      ),
    );
  }
}

// ----------------------------------------------------------------- calendar

/// The weekday, today's in a dark pill, over the time the day has boxed and
/// a thin bar of how much of the day's work is done (see
/// [WeekDayPlan.workDoneRatio]); green once all of it is. An overloaded
/// day's time takes the main color. Dates live in the strip above.
/// The day's date in a small white circle at the start of its header, where
/// the strip above showed it in daily mode.
class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.day});

  final WeekDayPlan day;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 28),
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.whiteSec,
        borderRadius: BorderRadius.circular(100),
      ),
      child: ReText(
        convertToPersianNumbers('${day.date.day}'),
        fontSize: 12.5,
        fontWeight: FontWeight.w900,
        color: day.isPast ? AppColors.gray : AppColors.black1,
        maxLines: 1,
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({super.key, required this.day});

  final WeekDayPlan day;

  @override
  Widget build(BuildContext context) {
    final planned = day.plannedMinutes;
    final over = day.isHeavy;
    final done = day.workDoneRatio;
    final accent = day.isAllDone
        ? AppColors.done
        : AppColors.black1.withValues(alpha: day.isPast ? 0.35 : 0.75);
    final percent = convertToPersianNumbers('${(done * 100).round()}');
    return Semantics(
      label: [
        dayLabel(day.date),
        if (planned > 0) formatDuration(planned),
        if (!day.isEmpty) '$percent درصد انجام شده',
      ].join('، '),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_columnPad, 12, _columnPad, 8),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              height: 40,
              padding: const EdgeInsetsDirectional.fromSTEB(6, 0, 12, 0),
              alignment: AlignmentDirectional.centerStart,
              decoration: BoxDecoration(
                color: day.isToday ? AppColors.black1 : AppColors.gray1,
                borderRadius: BorderRadius.circular(100),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DateBadge(day: day),
                    const SizedBox(width: 7),
                    ReText(
                      weekdayName(day.date),
                      fontSize: 12.5,
                      fontWeight:
                          day.isToday ? FontWeight.w900 : FontWeight.w800,
                      color: day.isToday
                          ? AppColors.white
                          : day.isPast
                              ? AppColors.gray
                              : AppColors.black1,
                      maxLines: 1,
                    ),
                    // Today is named; the first of a month names its month.
                    if (day.isToday || day.date.day == 1) ...[
                      const SizedBox(width: 6),
                      ReText(
                        day.isToday
                            ? 'امروز'
                            : kPersianMonths[day.date.month - 1],
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: day.isToday
                            ? AppColors.white.withValues(alpha: 0.5)
                            : AppColors.gray,
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // How much of the day is done, with the time it has boxed.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                height: 16,
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: done),
                          duration: const Duration(milliseconds: 600),
                          curve: AppMotion.settle,
                          builder: (context, value, _) =>
                              LinearProgressIndicator(
                            value: value,
                            minHeight: 3,
                            backgroundColor: AppColors.gray2,
                            color: accent,
                          ),
                        ),
                      ),
                    ),
                    if (planned > 0) ...[
                      const SizedBox(width: 6),
                      ReText(
                        formatClock(planned),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: over ? AppColors.primary : AppColors.gray,
                      ),
                    ],
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

/// One day: unfinished work left on a past day, the checklists pill, the
/// time boxes in order, then the button that adds to the day. The whole
/// column takes a dropped time box.
class _DayColumn extends StatelessWidget {
  const _DayColumn({
    super.key,
    required this.width,
    required this.index,
    required this.day,
    required this.today,
    required this.showHint,
    required this.onOpenTask,
    required this.onShowChecklists,
    required this.onAdd,
    required this.onMove,
    required this.onDragStarted,
    required this.onDragMoved,
    required this.onDragEnded,
  });

  final double width;
  final int index;
  final WeekDayPlan day;
  final Jalali today;
  final bool showHint;
  final ValueChanged<Map<String, dynamic>> onOpenTask;
  final VoidCallback onShowChecklists;
  final VoidCallback onAdd;
  final void Function(List<Map<String, dynamic>> tasks, Jalali day) onMove;
  final VoidCallback onDragStarted;
  final ValueChanged<Offset> onDragMoved;
  final VoidCallback onDragEnded;

  bool _accepts(Map<String, dynamic> task) {
    final from = task['date'];
    return !day.isPast && (from is! Jalali || daysBetween(from, day.date) != 0);
  }

  @override
  Widget build(BuildContext context) {
    final checklists = day.tasks.where((task) => !isTimedTask(task)).toList();
    final List<Map<String, dynamic>> leftovers = day.isPast
        ? day.tasks.where((task) => !isTaskDone(task)).toList()
        : const [];
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) => _accepts(details.data),
      onAcceptWithDetails: (details) => onMove([details.data], day.date),
      builder: (context, candidates, _) {
        final incoming =
            candidates.whereType<Map<String, dynamic>>().firstOrNull;
        return Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: _columnPad),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: incoming == null ? AppColors.gray1 : AppColors.gray2,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(_laneRadius)),
            ),
            // Clear of the undo bar and the timer banner at the bottom.
            padding:
                const EdgeInsets.fromLTRB(_lanePad, _lanePad, _lanePad, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: _taskGap,
              children: [
                if (leftovers.isNotEmpty)
                  _LeftoverNote(
                    key: ValueKey('week-leftover-$index'),
                    count: leftovers.length,
                    onMoveToToday: leftovers.any(_isMovable)
                        ? () =>
                            onMove(leftovers.where(_isMovable).toList(), today)
                        : null,
                  ),
                if (checklists.isNotEmpty)
                  ChecklistsPill(
                    key: ValueKey('week-checklists-$index'),
                    tasks: checklists,
                    onTap: onShowChecklists,
                    height: _chipHeight,
                    fontSize: 11.5,
                    color: AppColors.whiteSec,
                  ),
                for (final task in day.tasks)
                  if (isTimedTask(task))
                    _DraggableBox(
                      task: task,
                      width: width - (_columnPad + _lanePad) * 2,
                      faded: day.isPast,
                      onTap: () => onOpenTask(task),
                      onDragStarted: onDragStarted,
                      onDragMoved: onDragMoved,
                      onDragEnded: onDragEnded,
                    ),
                // Where the held box will land.
                if (incoming != null)
                  DashedBorder(
                    key: const ValueKey('week-drop-slot'),
                    radius: _chipRadius,
                    child: SizedBox(
                      height: isTimedTask(incoming)
                          ? _boxHeight(taskPlannedMinutes(incoming))
                          : _chipHeight,
                    ),
                  ),
                if (showHint)
                  const Padding(
                    key: ValueKey('week-empty-hint'),
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: ReText(
                      'اولین زمان‌بندی هفته را بساز',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray,
                      textAlign: TextAlign.center,
                      lineHeight: 1.5,
                    ),
                  ),
                // A past day takes no new tasks.
                if (!day.isPast)
                  _AddButton(key: ValueKey('week-add-$index'), onTap: onAdd),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// "۲ کار مانده" on a past day, with a tap that brings the movable ones to
/// today.
class _LeftoverNote extends StatelessWidget {
  const _LeftoverNote(
      {super.key, required this.count, required this.onMoveToToday});

  final int count;
  final VoidCallback? onMoveToToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 9, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.whiteSec,
        borderRadius: BorderRadius.circular(_chipRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReText(
            '$count کار مانده',
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: AppColors.gray,
            textAlign: TextAlign.center,
          ),
          if (onMoveToToday != null) ...[
            const SizedBox(height: 4),
            Semantics(
              button: true,
              label: 'انتقال $count کار مانده به امروز',
              excludeSemantics: true,
              child: PressScale(
                onTap: onMoveToToday,
                child: Container(
                  key: const ValueKey('week-leftover-move'),
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.black1,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: ReText(
                        'انتقال به امروز',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A time box that lifts when held and goes to whichever day it is dropped
/// on; one already started or done stays put.
class _DraggableBox extends StatelessWidget {
  const _DraggableBox({
    required this.task,
    required this.width,
    required this.onTap,
    required this.onDragStarted,
    required this.onDragMoved,
    required this.onDragEnded,
    this.faded = false,
  });

  final Map<String, dynamic> task;
  final double width;
  final VoidCallback onTap;
  final VoidCallback onDragStarted;
  final ValueChanged<Offset> onDragMoved;
  final VoidCallback onDragEnded;

  /// A past day's box, which steps back.
  final bool faded;

  @override
  Widget build(BuildContext context) {
    final height = _boxHeight(taskPlannedMinutes(task));
    final box =
        _TaskBox(task: task, height: height, onTap: onTap, faded: faded);
    if (!_isMovable(task)) return box;
    return LongPressDraggable<Map<String, dynamic>>(
      data: task,
      delay: const Duration(milliseconds: 280),
      onDragStarted: onDragStarted,
      onDragUpdate: (details) => onDragMoved(details.globalPosition),
      onDragEnd: (_) => onDragEnded(),
      onDraggableCanceled: (_, __) => onDragEnded(),
      childWhenDragging: Opacity(opacity: 0.3, child: box),
      feedback: Directionality(
        textDirection: TextDirection.rtl,
        child: Material(
          color: Colors.transparent,
          child: Transform.scale(
            scale: 1.04,
            child: Container(
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_chipRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black1.withValues(alpha: 0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _TaskBox(
                  task: task, height: height, onTap: () {}, raised: true),
            ),
          ),
        ),
      ),
      child: box,
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'ثبت تسک',
      excludeSemantics: true,
      child: PressScale(
        onTap: onTap,
        child: Container(
          height: _chipHeight,
          decoration: BoxDecoration(
            color: AppColors.whiteSec,
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: ReText(
                  'ثبت تسک',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black1,
                  maxLines: 1,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.add_rounded, size: 19, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------- tasks

/// Where a time box stands, colored as in daily mode: not started (gray),
/// running now (orange), partly done (blue), finished (green).
enum _Stage { notStarted, running, partial, done }

/// The live timer decides for the task it holds, as in daily mode; other
/// tasks go by what the server last said.
_Stage _stageOf(Map<String, dynamic> task) {
  if (isTaskDone(task)) return _Stage.done;
  final timer = TaskTimerService.instance;
  if (timer.isActive(task['id'] as String?)) {
    if (timer.isCompleted) return _Stage.done;
    if (timer.isRunning) return _Stage.running;
    return timer.elapsedSeconds > 0 ? _Stage.partial : _Stage.notStarted;
  }
  final status = task['status'];
  // Another task holds the timer now, so this one is no longer ticking.
  if (status == 'running') {
    return timer.hasActiveTask ? _Stage.partial : _Stage.running;
  }
  if (status == 'paused') return _Stage.partial;
  return (task['elapsedSeconds'] as int? ?? 0) > 0
      ? _Stage.partial
      : _Stage.notStarted;
}

/// The stage's color; none for a task not started, which stays neutral.
Color? _stageColor(_Stage stage) => switch (stage) {
      _Stage.notStarted => null,
      _Stage.running => AppColors.primary,
      _Stage.partial => AppColors.secondary,
      _Stage.done => AppColors.done,
    };

/// Every task is a white chip on its day's lane; the stage shows in its
/// badge, not its fill.
BoxDecoration _taskDecoration({
  required double radius,
  bool raised = false,
}) {
  return BoxDecoration(
    color: AppColors.whiteSec,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: raised
        ? [
            BoxShadow(
              color: AppColors.black1.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
        : null,
  );
}

/// How much of a timed task's time has run, or null if none has; live from
/// the timer for the task it holds.
double? _timerProgress(Map<String, dynamic> task) {
  if (!isTimedTask(task) || isTaskDone(task)) return null;
  final timer = TaskTimerService.instance;
  if (timer.isActive(task['id'] as String?)) {
    return timer.elapsedSeconds > 0 ? timer.progress : null;
  }
  final total = task['durationSeconds'] as int? ?? 0;
  if (total <= 0) return null;
  final elapsed = taskWorkedSeconds(task);
  if (elapsed <= 0) return null;
  return (elapsed / total).clamp(0.0, 1.0);
}

/// "۴۵ دقیقه", "۱٫۵ ساعت", "۱:۴۵"
String _shortDuration(int minutes) {
  if (minutes < 60) return convertToPersianNumbers('$minutes دقیقه');
  if (minutes % 30 == 0) return '${formatHours(minutes)} ساعت';
  return formatClock(minutes);
}

/// A timed task as a white chip: its stage badge at the start, then its
/// title over its time box. [raised] is the copy that follows the finger
/// while it moves; [faded] a past day's, which steps back.
class _TaskBox extends StatelessWidget {
  const _TaskBox({
    required this.task,
    required this.height,
    required this.onTap,
    this.raised = false,
    this.faded = false,
  });

  final Map<String, dynamic> task;
  final double height;
  final VoidCallback onTap;
  final bool raised;
  final bool faded;

  static const double _pad = 8;
  static const double _titleLine = 16;

  @override
  Widget build(BuildContext context) {
    final stage = _stageOf(task);
    final color = _stageColor(stage);
    final progress = stage == _Stage.done ? null : _timerProgress(task);
    // Two title lines when the box has room for them above the time.
    final twoLines = height >= 2 * _pad + 2 * _titleLine + 2 + 15;

    final content = AnimatedContainer(
      key: raised ? null : ValueKey('week-task-${task['id']}'),
      duration: const Duration(milliseconds: 260),
      height: height,
      decoration: _taskDecoration(radius: _chipRadius, raised: raised),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsetsDirectional.fromSTEB(7, _pad, 10, _pad),
      child: Row(
        children: [
          _StageBadge(stage: stage, color: color, progress: progress),
          const SizedBox(width: 8),
          Expanded(child: _text(stage, twoLines)),
        ],
      ),
    );
    return raised ? content : PressScale(onTap: onTap, child: content);
  }

  Widget _text(_Stage stage, bool twoLines) {
    final done = stage == _Stage.done;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReText(
          task['title'] as String? ?? '',
          fontSize: 12,
          fontWeight: FontWeight.w800,
          lineHeight: 1.35,
          maxLines: twoLines ? 2 : 1,
          color: done || faded ? AppColors.gray : AppColors.black1,
          decoration: done ? TextDecoration.lineThrough : null,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 2),
        ReText(
          _shortDuration(taskPlannedMinutes(task)),
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          lineHeight: 1.35,
          maxLines: 1,
          color: faded ? AppColors.dark5Color : AppColors.gray,
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}

/// Where a chip's task stands: a gray ring not started, an arc of the time
/// run so far while under way (orange running, blue paused), a green check
/// once done.
class _StageBadge extends StatelessWidget {
  const _StageBadge({
    required this.stage,
    required this.color,
    required this.progress,
  });

  final _Stage stage;
  final Color? color;
  final double? progress;

  static const double _size = 24;

  @override
  Widget build(BuildContext context) {
    final accent = color;
    return SizedBox.square(
      dimension: _size,
      child: switch (stage) {
        _Stage.done => DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.done.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                size: 17, color: AppColors.done),
          ),
        _ when accent == null => Center(
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.dark4Color, width: 1.6),
              ),
            ),
          ),
        _ => Padding(
            padding: const EdgeInsets.all(3),
            child: CircularProgressIndicator(
              // Never indeterminate: a spinning ring would read as loading.
              value: math.max(progress ?? 0, 0.04),
              strokeWidth: 2.6,
              strokeCap: StrokeCap.round,
              color: accent,
              backgroundColor: accent.withValues(alpha: 0.2),
            ),
          ),
      },
    );
  }
}

// ------------------------------------------------------------ load states

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('week-plan-error'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 44, color: AppColors.dark5Color),
            const SizedBox(height: 12),
            const ReText(
              'دریافت برنامه هفته ناموفق بود.',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.black1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const ReText(
              'اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.',
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.gray,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 180,
              child: PlanPillButton(
                key: const ValueKey('week-plan-retry'),
                text: 'تلاش دوباره',
                icon: Icons.refresh_rounded,
                height: 46,
                onTap: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading placeholder shaped like the week: a few day columns.
class _WeekPlanSkeleton extends StatefulWidget {
  const _WeekPlanSkeleton();

  @override
  State<_WeekPlanSkeleton> createState() => _WeekPlanSkeletonState();
}

class _WeekPlanSkeletonState extends State<_WeekPlanSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  Widget _block({required double height, double radius = 12}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.gray2,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _column(int seed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            _block(height: 40, radius: 100),
            const SizedBox(height: 14),
            _block(height: 40, radius: 100),
            SizedBox(height: 8.0 + seed * 18),
            _block(height: 76, radius: _chipRadius),
            const SizedBox(height: 8),
            _block(height: 40, radius: 100),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      key: const ValueKey('week-plan-skeleton'),
      alignment: Alignment.topCenter,
      child: AnimatedBuilder(
        animation: _shimmer,
        builder: (context, child) {
          final travel = _shimmer.value * 3;
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment(-1.5 + travel, 0),
              end: Alignment(-0.5 + travel, 0),
              colors: const [
                Color(0xFFE3E5EA),
                Color(0xFFF8F9FB),
                Color(0xFFE3E5EA),
              ],
              stops: const [0.18, 0.5, 0.82],
            ).createShader(bounds),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 8),
                  for (var column = 0; column < 3; column++) _column(column),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
