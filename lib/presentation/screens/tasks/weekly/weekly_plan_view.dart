import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/screens/tasks/tasks_api.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/checklists_popup.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_widgets.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/week_plan.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/weekly_plan_controller.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/presentation/widgets/re_toast.dart';
import 'package:simo_learn/utils/_utils.dart';

/// All seven days fit side by side when each gets this much; narrower
/// screens show about [_visibleColumns] days and scroll sideways.
const double _fullColumnWidth = 100;
const double _visibleColumns = 3.4;
const double _minColumnWidth = 84;

const double _columnPad = 4;
const double _taskGap = 6;
const double _chipHeight = 34;

/// While a time box is dragged this close to the board's side, the days
/// scroll that way.
const double _dragEdge = 44;
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
  });

  final WeeklyPlanController controller;

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
    super.dispose();
  }

  void _syncHeaders() {
    if (_columns.hasClients && _headers.hasClients) {
      _headers.jumpTo(_columns.offset);
    }
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
      decoration: const BoxDecoration(
        color: AppColors.whiteSec,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.gray2),
          left: BorderSide(color: AppColors.gray2),
          right: BorderSide(color: AppColors.gray2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final available = constraints.maxWidth;
          _columnWidth = available / 7 >= _fullColumnWidth
              ? available / 7
              : math.max(_minColumnWidth, available / _visibleColumns);
          final width = _columnWidth * 7;

          return Column(
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
              const Divider(height: 1, thickness: 1, color: AppColors.gray2),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, viewport) => RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: widget.onRefresh,
                    child: SingleChildScrollView(
                      key: const ValueKey('week-columns'),
                      controller: _scroll,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SingleChildScrollView(
                        // A new week starts from its first column and replays
                        // the entrance; a reload of the same week updates in
                        // place.
                        key: ValueKey('week-columns-$weekKey'),
                        controller: _columns,
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: width,
                            maxWidth: width,
                            minHeight: viewport.maxHeight,
                          ),
                          child: CustomPaint(
                            painter: _ColumnsPainter(columnWidth: _columnWidth),
                            child: Padding(
                              // Clear of the undo bar and the timer banner.
                              padding: const EdgeInsets.only(bottom: 110),
                              // Every column as tall as the tallest, so a box
                              // can be dropped anywhere in a day.
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    for (var index = 0; index < 7; index++)
                                      _Entrance(
                                        order: index,
                                        child: _DayColumn(
                                          key: ValueKey(
                                              'week-day-column-$index'),
                                          width: _columnWidth,
                                          index: index,
                                          day: plan.days[index],
                                          today: _controller.today,
                                          showHint: index == hintIndex,
                                          onOpenTask: widget.onOpenTask,
                                          onShowChecklists: () =>
                                              _openChecklists(plan.days[index]),
                                          onAdd: () => widget.onAddToDay(
                                              plan.days[index].date),
                                          onMove: _move,
                                          onDragStarted: _onDragStarted,
                                          onDragMoved: (point) =>
                                              _dragPoint = point,
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
                ),
              ),
            ],
          );
        },
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
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: day.isToday ? AppColors.black1 : Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: ReText(
                weekdayName(day.date),
                fontSize: 11.5,
                fontWeight: day.isToday ? FontWeight.w900 : FontWeight.w800,
                color: day.isToday
                    ? AppColors.white
                    : day.isPast
                        ? AppColors.dark5Color
                        : AppColors.black1,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 16,
              child: planned > 0
                  ? ReText(
                      formatClock(planned),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: over ? AppColors.primary : AppColors.gray,
                      textAlign: TextAlign.center,
                    )
                  : null,
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: done),
                duration: const Duration(milliseconds: 600),
                curve: AppMotion.settle,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 3,
                  backgroundColor: AppColors.gray2,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The lines between days.
class _ColumnsPainter extends CustomPainter {
  _ColumnsPainter({required this.columnWidth});

  final double columnWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = AppColors.gray2
      ..strokeWidth = 1;
    for (var day = 1; day < 7; day++) {
      final x = day * columnWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
  }

  @override
  bool shouldRepaint(_ColumnsPainter old) => old.columnWidth != columnWidth;
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
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: width,
          color: incoming == null
              ? Colors.transparent
              : AppColors.black1.withValues(alpha: 0.03),
          padding: const EdgeInsets.fromLTRB(_columnPad, 8, _columnPad, 8),
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
                ),
              for (final task in day.tasks)
                if (isTimedTask(task))
                  _DraggableBox(
                    task: task,
                    width: width - _columnPad * 2,
                    onTap: () => onOpenTask(task),
                    onDragStarted: onDragStarted,
                    onDragMoved: onDragMoved,
                    onDragEnded: onDragEnded,
                  ),
              // Where the held box will land.
              if (incoming != null)
                Container(
                  key: const ValueKey('week-drop-slot'),
                  height: isTimedTask(incoming)
                      ? _boxHeight(taskPlannedMinutes(incoming))
                      : _chipHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.dark5Color, width: 1.2),
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
      padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray2),
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
                  height: 28,
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
  });

  final Map<String, dynamic> task;
  final double width;
  final VoidCallback onTap;
  final VoidCallback onDragStarted;
  final ValueChanged<Offset> onDragMoved;
  final VoidCallback onDragEnded;

  @override
  Widget build(BuildContext context) {
    final height = _boxHeight(taskPlannedMinutes(task));
    final box = _TaskBox(task: task, height: height, onTap: onTap);
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
                borderRadius: BorderRadius.circular(12),
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
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gray2, width: 1.2),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, size: 16, color: AppColors.dark6Color),
              SizedBox(width: 3),
              Flexible(
                child: ReText(
                  'ثبت تسک',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gray,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------- tasks

/// Tasks to do sit on a soft gray; finished ones step back to an outline.
BoxDecoration _taskDecoration(
    {required bool done, required double radius, bool raised = false}) {
  return BoxDecoration(
    color: raised ? AppColors.whiteSec : (done ? null : kTaskFill),
    border: done ? Border.all(color: AppColors.gray2) : null,
    borderRadius: BorderRadius.circular(radius),
  );
}

/// How much of a timed task's time has run, or null if none has.
double? _timerProgress(Map<String, dynamic> task) {
  if (!isTimedTask(task) || isTaskDone(task)) return null;
  final total = task['durationSeconds'] as int? ?? 0;
  if (total <= 0) return null;
  var elapsed = task['elapsedSeconds'] as int? ?? 0;
  final startedAt = task['timerStartedAt'];
  if (task['status'] == 'running' && startedAt is DateTime) {
    elapsed += DateTime.now().difference(startedAt).inSeconds;
  }
  if (elapsed <= 0) return null;
  return (elapsed / total).clamp(0.0, 1.0);
}

/// "۴۵ دقیقه", "۱٫۵ ساعت", "۱:۴۵"
String _shortDuration(int minutes) {
  if (minutes < 60) return convertToPersianNumbers('$minutes دقیقه');
  if (minutes % 30 == 0) return '${formatHours(minutes)} ساعت';
  return formatClock(minutes);
}

/// A timed task: its title, its time box and, once started, how much of it
/// has run. [raised] is the copy that follows the finger while it moves.
class _TaskBox extends StatelessWidget {
  const _TaskBox({
    required this.task,
    required this.height,
    required this.onTap,
    this.raised = false,
  });

  final Map<String, dynamic> task;
  final double height;
  final VoidCallback onTap;
  final bool raised;

  static const double _pad = 7;
  static const double _titleLine = 16;

  @override
  Widget build(BuildContext context) {
    final done = isTaskDone(task);
    final progress = _timerProgress(task);
    // Two title lines when the box has room for them beside the rest.
    final twoLines = height >= 2 * _pad + 2 * _titleLine + 2 + 15 + 9;

    final content = Container(
      key: raised ? null : ValueKey('week-task-${task['id']}'),
      height: height,
      padding: const EdgeInsetsDirectional.fromSTEB(8, _pad, 6, _pad),
      decoration: _taskDecoration(done: done, radius: 12, raised: raised),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ReText(
                  task['title'] as String? ?? '',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  lineHeight: 1.35,
                  maxLines: twoLines ? 2 : 1,
                  color: done ? AppColors.gray : AppColors.black1,
                  decoration: done ? TextDecoration.lineThrough : null,
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: TaskStatusMark(task: task, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 2),
          ReText(
            _shortDuration(taskPlannedMinutes(task)),
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            lineHeight: 1.35,
            maxLines: 1,
            color: AppColors.gray,
            textAlign: TextAlign.start,
          ),
          const Spacer(),
          if (progress != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
    return raised ? content : PressScale(onTap: onTap, child: content);
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
            _block(height: 46, radius: 16),
            const SizedBox(height: 14),
            _block(height: 30, radius: 9),
            SizedBox(height: 24.0 + seed * 18),
            _block(height: 76),
            const SizedBox(height: 10),
            _block(height: 36),
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
