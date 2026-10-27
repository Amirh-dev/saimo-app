import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simo_learn/features/dashboard/dashboard_repository.dart';
import 'package:simo_learn/features/dashboard/home_layout.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/_utils.dart';

/// The home's day card: a strip naming the suggested task with the one main
/// action, the day's tasks as capsules (the suggested one larger), and the
/// day's progress with a flame where the day starts to count.
class TodayActivityWidget extends StatefulWidget {
  const TodayActivityWidget({
    super.key,
    required this.tasks,
    required this.date,
    required this.onAllTasksTap,
    required this.onAddTap,
    required this.onOpenTask,
    this.consistency,
  });

  final List<DashboardTaskItem> tasks;

  /// Today, as the header shows it.
  final String date;
  final VoidCallback onAllTasksTap;
  final VoidCallback onAddTap;

  /// Opens a task's timer.
  final ValueChanged<DashboardTaskItem> onOpenTask;

  /// Places the flame on the progress bar; 70% while it is unknown.
  final DashboardConsistency? consistency;

  @override
  State<TodayActivityWidget> createState() => _TodayActivityWidgetState();
}

class _TodayActivityWidgetState extends State<TodayActivityWidget>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  Timer? _tooltipTimer;

  /// Plays when the card first shows its tasks, and again when they change:
  /// the capsules rise in one after another, each fills up to its progress,
  /// and the day's bar and percentage follow.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  @override
  void initState() {
    super.initState();
    _intro.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) _intro.value = 1;
  }

  @override
  void didUpdateWidget(TodayActivityWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_signature(oldWidget.tasks) != _signature(widget.tasks) &&
        !reduceMotion(context)) {
      _intro.forward(from: 0);
    }
  }

  /// Which tasks the day has. Progress is left out on purpose: a running
  /// timer moves it every second, and that should fill the capsule, not
  /// replay the whole entrance.
  static String _signature(List<DashboardTaskItem> tasks) =>
      [for (final task in tasks) task.id].join('|');

  /// Column [index]'s share of the intro: when it appears, then when it
  /// fills.
  Animation<double> _appear(int index) => CurvedAnimation(
        parent: _intro,
        curve: Interval(index * 0.06, index * 0.06 + 0.45,
            curve: Curves.easeOutCubic),
      );

  Animation<double> _fill(int index) => CurvedAnimation(
        parent: _intro,
        curve: Interval(0.2 + index * 0.06, 0.2 + index * 0.06 + 0.42,
            curve: Curves.easeInOutCubic),
      );

  late final Animation<double> _bar = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.35, 1, curve: Curves.easeOutCubic),
  );

  /// A long press shows a capsule's full name and plan above it.
  void _showTitle(BuildContext columnContext, DashboardTaskItem task) {
    _removePopup();
    final renderBox = columnContext.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenWidth = MediaQuery.of(context).size.width;
    final isRightHalf = (offset.dx + (size.width / 2)) > (screenWidth / 2);
    final color = _Stage.of(task).color;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removePopup,
              behavior: HitTestBehavior.opaque,
            ),
          ),
          Positioned(
            top: offset.dy - 46,
            left: isRightHalf ? null : offset.dx,
            right: isRightHalf ? (screenWidth - offset.dx - size.width) : null,
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: isRightHalf
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ReText(
                      '${task.title}، ${task.maxDuration} دقیقه',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      right: isRightHalf ? (size.width / 2) - 7 : 0,
                      left: !isRightHalf ? (size.width / 2) - 7 : 0,
                    ),
                    child: ClipPath(
                      clipper: TriangleClipper(),
                      child: Container(color: color, width: 14, height: 7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _tooltipTimer = Timer(const Duration(milliseconds: 2500), _removePopup);
  }

  void _removePopup() {
    _tooltipTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removePopup();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.tasks;
    final suggested = suggestedTaskIndex(tasks);
    final slots = todaySlots(tasks.length, suggested: suggested);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ReText(
                      'خلاصه فعالیت امروز',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF24242C),
                    ),
                    const SizedBox(height: 2),
                    ReText(
                      widget.date,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),
                const Spacer(),
                HomeOutlineButton(
                  title: 'همه تسک‌ها',
                  onTap: widget.onAllTasksTap,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xfffafafa),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) => Column(
                          children: [
                            _strip(
                              suggested,
                              notchCenter: _notchCenter(
                                slots,
                                suggested,
                                constraints.maxWidth,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _chart(slots, suggested),
                          ],
                        ),
                      ),
                      if (tasks.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Divider(color: Colors.grey.shade200, height: 1),
                        const SizedBox(height: 16),
                        const _Legend(),
                      ],
                    ],
                  ),
                ),
                if (tasks.isNotEmpty) _progressBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Where under the strip its pointer sits, from the start: over the
  /// suggested capsule, or the add capsule on an empty day.
  double? _notchCenter(List<TodaySlot> slots, int? suggested, double width) {
    final target = widget.tasks.isEmpty
        ? slots.indexWhere((slot) => slot.kind == TodaySlotKind.add)
        : slots
            .indexWhere((slot) => slot.index == suggested && suggested != null);
    if (target < 0) return null;
    return (target + 0.5) / slots.length * width;
  }

  Widget _strip(int? suggested, {double? notchCenter}) {
    final tasks = widget.tasks;
    if (tasks.isEmpty) {
      return _SuggestionStrip(
        notchCenter: notchCenter,
        title: 'برای امروز تسکی ندارید',
        subtitle: 'اولین تسک زمان‌دار را اضافه کنید.',
        onTap: widget.onAddTap,
        action: _StripButton(
          label: 'افزودن',
          icon: Icons.add_rounded,
          onTap: widget.onAddTap,
        ),
      );
    }

    if (suggested == null) {
      return _SuggestionStrip(
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.done.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Icons.check_rounded, color: AppColors.done, size: 18),
        ),
        title: 'همه‌ی تسک‌های امروز انجام شد',
        subtitle: _allDoneLine(),
        action: _StripButton(
          label: 'تسک',
          icon: Icons.add_rounded,
          onTap: widget.onAddTap,
          style: _StripButtonStyle.quiet,
        ),
      );
    }

    final task = tasks[suggested];
    void open() => widget.onOpenTask(task);
    if (task.isRunning) {
      return _SuggestionStrip(
        notchCenter: notchCenter,
        title: task.title,
        subtitle: 'در حال اجرا، ${task.remainingMinutes} دقیقه مانده',
        onTap: open,
        action: _StripButton(
          label: 'تایمر',
          icon: Icons.arrow_forward_ios_rounded,
          iconSize: 13,
          onTap: open,
          style: _StripButtonStyle.dark,
        ),
      );
    }
    final started = task.isPaused;
    return _SuggestionStrip(
      notchCenter: notchCenter,
      title: task.title,
      subtitle: started
          ? '${task.doneDuration} از ${task.maxDuration} دقیقه، ${task.remainingMinutes} دقیقه مانده'
          : '${task.maxDuration} دقیقه',
      onTap: open,
      action: _StripButton(
        label: started ? 'ادامه' : 'شروع',
        icon: Icons.play_arrow_rounded,
        textDirectionIcon: TextDirection.ltr,
        onTap: open,
      ),
    );
  }

  String _allDoneLine() {
    final consistency = widget.consistency;
    if (consistency == null || !consistency.hasPlan) {
      return 'آفرین، برنامه‌ی امروز تمام شد.';
    }
    if (consistency.countedToday) {
      return 'امروز حساب شد؛ ضریب امتیاز ${consistency.level}×';
    }
    return '${consistency.remainingMinutes} دقیقه مطالعه‌ی دیگر تا حساب شدن امروز';
  }

  Widget _chart(List<TodaySlot> slots, int? suggested) {
    return SizedBox(
      height: _Chart.height,
      child: Stack(
        children: [
          const Positioned(
            top: _Chart.dotCenter - 0.75,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: DashedLinePainter(),
              size: Size(double.infinity, 2),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < slots.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _animatedSlot(slots[i], i, suggested),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _animatedSlot(TodaySlot slot, int position, int? suggested) {
    final appear = _appear(position);
    return AnimatedBuilder(
      animation: appear,
      builder: (context, child) => Opacity(
        opacity: appear.value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - appear.value)),
          child: child,
        ),
      ),
      child: switch (slot.kind) {
        TodaySlotKind.task => _TaskColumn(
            task: widget.tasks[slot.index!],
            suggested: slot.index == suggested,
            fill: _fill(position),
            onTap: widget.onOpenTask,
            onLongPress: _showTitle,
          ),
        TodaySlotKind.add => _EmptyColumn(onTap: widget.onAddTap, add: true),
        TodaySlotKind.ghost => const _EmptyColumn(),
        TodaySlotKind.more =>
          _MoreColumn(count: slot.more, onTap: widget.onAllTasksTap),
        TodaySlotKind.blank => const SizedBox.shrink(),
      },
    );
  }

  Widget _progressBar() {
    var planned = 0;
    var done = 0;
    var partial = 0;
    var running = 0;
    for (final task in widget.tasks) {
      final max = task.maxDuration;
      planned += max;
      if (task.isDone) {
        done += max;
      } else if (task.isRunning) {
        running += task.doneDuration;
      } else {
        partial += task.doneDuration;
      }
    }
    final rest = (planned - done - partial - running).clamp(0, planned);
    final percent =
        planned > 0 ? ((done + partial + running) * 100 / planned).floor() : 0;
    final target = (widget.consistency?.targetPercentage ?? 70) / 100;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
      child: Row(
        children: [
          ReText(
            'پیشرفت امروز',
            fontSize: 11,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      // Drawn in from the start as the capsules fill.
                      child: AnimatedBuilder(
                        animation: _bar,
                        builder: (context, child) => Align(
                          alignment: AlignmentDirectional.centerStart,
                          widthFactor: _bar.value,
                          child: child,
                        ),
                        child: SizedBox(
                          height: 4,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (done > 0) _segment(done, AppColors.done),
                              if (partial > 0)
                                _segment(partial, AppColors.secondary),
                              if (running > 0)
                                _segment(running, AppColors.primary),
                              if (rest > 0 || planned == 0)
                                _segment(planned == 0 ? 1 : rest,
                                    const Color(0xFFE5E7EB)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Where the day starts to count toward the multiplier.
                    PositionedDirectional(
                      start: width * target.clamp(0.0, 1.0) - 7,
                      top: -16,
                      child: const _TargetMark(),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Counts up with the capsules.
          AnimatedBuilder(
            animation: _bar,
            builder: (context, _) => ReText(
              '${(percent * _bar.value).round()}٪',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _segment(int flex, Color color) => Expanded(
        flex: flex,
        child: ColoredBox(color: color),
      );
}

/// Sizes shared by the chart's columns, so every dot sits on the dashed
/// line, the suggested task's larger one included.
abstract final class _Chart {
  static const double capsule = 93;
  static const double height = 176;

  static const double dot = 32;
  static const double suggestedDot = 34;

  /// The gap above and below the suggested dot, a pixel less than the
  /// others' 8 so its center stays on the line.
  static const double suggestedGap = 8 - (suggestedDot - dot) / 2;

  /// The dot row's center: under the capsules, a gap and half a dot.
  static const double dotCenter = capsule + 8 + dot / 2;
}

/// A task's place in the app's stage colors (orange running, blue partly
/// done, green done, gray not started).
enum _Stage {
  running(AppColors.primary, Color(0xFFF26D4D), Icons.pause_rounded),
  partial(AppColors.secondary, Color(0xFF6E86F2), Icons.play_arrow_rounded),
  done(AppColors.done, Color(0xFF4CCF89), Icons.check_rounded),
  idle(AppColors.black1, AppColors.gray1, Icons.play_arrow_rounded);

  const _Stage(this.color, this.labelColor, this.icon);

  final Color color;

  /// The capsule's title pill, a lighter shade so it reads on the fill.
  final Color labelColor;

  /// The dot under the capsule: what tapping it does next.
  final IconData icon;

  static _Stage of(DashboardTaskItem task) {
    if (task.isDone) return _Stage.done;
    if (task.isRunning) return _Stage.running;
    if (task.isPaused) return _Stage.partial;
    return _Stage.idle;
  }
}

class _TaskColumn extends StatelessWidget {
  const _TaskColumn({
    required this.task,
    required this.suggested,
    required this.fill,
    required this.onTap,
    required this.onLongPress,
  });

  final DashboardTaskItem task;

  /// The strip's task: its dot turns into a solid button in its color.
  final bool suggested;
  final Animation<double> fill;
  final ValueChanged<DashboardTaskItem> onTap;
  final void Function(BuildContext context, DashboardTaskItem task) onLongPress;

  static const BorderRadius _capsule = BorderRadius.all(Radius.circular(100));

  @override
  Widget build(BuildContext context) {
    final stage = _Stage.of(task);
    final level = task.isDone ? 1.0 : (task.percentage / 100).clamp(0.0, 1.0);
    final inProgress = stage == _Stage.running || stage == _Stage.partial;

    return Semantics(
      button: true,
      label: '${task.title}، ${_minutesLabel(task)} دقیقه',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(task),
        onLongPress: () => onLongPress(context, task),
        child: Column(
          children: [
            Container(
              height: _Chart.capsule,
              decoration: const BoxDecoration(
                borderRadius: _capsule,
                color: Colors.white,
              ),
              // The fill is a plain level clipped by the capsule, so the
              // bottom stays round however full it gets.
              child: ClipRRect(
                borderRadius: _capsule,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    if (inProgress)
                      Container(color: stage.color.withValues(alpha: 0.12)),
                    if (stage != _Stage.idle)
                      AnimatedBuilder(
                        animation: fill,
                        builder: (context, _) => FractionallySizedBox(
                          heightFactor: level * fill.value,
                          widthFactor: 1,
                          child: ColoredBox(color: stage.color),
                        ),
                      ),
                    if (stage == _Stage.idle)
                      const RotatedBox(
                        quarterTurns: 3,
                        child: CustomPaint(
                          painter: StripedPainter(color: Color(0xFFE5E7EB)),
                          size: Size(double.infinity, double.infinity),
                        ),
                      ),
                    Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: stage.labelColor,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            child: ReText(
                              task.title,
                              fontSize: 10,
                              maxLines: 1,
                              color: stage == _Stage.idle
                                  ? Colors.grey.shade600
                                  : Colors.white,
                              fontWeight: FontWeight.w400,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Keeps every dot's center on the dashed line.
            SizedBox(height: suggested ? _Chart.suggestedGap : 8),
            if (suggested)
              _Dot(
                size: _Chart.suggestedDot,
                ring: 2,
                background: stage.color,
                shadow: stage.color.withValues(alpha: 0.35),
                child: Icon(
                  stage.icon,
                  textDirection: TextDirection.ltr,
                  size: 15,
                  color: Colors.white,
                ),
              )
            else
              _Dot(
                size: _Chart.dot,
                background: stage == _Stage.idle
                    ? AppColors.gray2
                    : stage.color.withValues(alpha: 0.12),
                child: Icon(
                  stage.icon,
                  // Play and pause point the same way in either direction.
                  textDirection: TextDirection.ltr,
                  size: 14,
                  color: stage.color,
                ),
              ),
            SizedBox(height: suggested ? _Chart.suggestedGap : 8),
            // «۱۰۰ از ۱۲۰» is a little wide for a column; it shrinks rather
            // than run into the next one.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: (task.isPaused || task.isRunning)
                  ? OutOfText(
                      task.doneDuration,
                      task.maxDuration,
                      fontWeight:
                          suggested ? FontWeight.w900 : FontWeight.w700,
                    )
                  : ReText(
                      '${task.maxDuration}',
                      fontSize: 11.5,
                      fontWeight:
                          suggested ? FontWeight.w900 : FontWeight.w700,
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.center,
                    ),
            ),
            ReText(
              'دقیقه',
              fontSize: 9.5,
              color: suggested ? AppColors.black1 : Colors.grey.shade500,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// «۲۵ از ۶۰» while under way, otherwise the planned minutes. Never a
  /// slash: in Persian «۲۵/۶۰» reads as a decimal.
  static String _minutesLabel(DashboardTaskItem task) =>
      (task.isPaused || task.isRunning)
          ? '${task.doneDuration} از ${task.maxDuration}'
          : '${task.maxDuration}';
}

/// An add column (the next task to plan), or a faint ghost on an empty day.
class _EmptyColumn extends StatelessWidget {
  const _EmptyColumn({this.onTap, this.add = false});

  final VoidCallback? onTap;
  final bool add;

  @override
  Widget build(BuildContext context) {
    final column = Column(
      children: [
        SizedBox(
          height: _Chart.capsule,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: _Chart.capsule,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: add ? Colors.white : const Color(0xFFFAFAFB),
                border: Border.all(
                  color: add ? AppColors.gray2 : const Color(0xFFF0F1F4),
                ),
              ),
              child: add
                  ? const Icon(Icons.add, color: Colors.grey, size: 20)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const _Dot(
          size: 32,
          background: AppColors.white,
          border: Color(0xFFE5E7EB),
        ),
      ],
    );
    if (!add) return column;
    return Semantics(
      button: true,
      label: 'افزودن تسک',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: column,
      ),
    );
  }
}

/// Stands for the tasks that did not fit; opens the tasks tab.
class _MoreColumn extends StatelessWidget {
  const _MoreColumn({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$count تسک دیگر',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            SizedBox(
              height: _Chart.capsule,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: _Chart.capsule,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: AppColors.gray1,
                  ),
                  child: ReText(
                    '+$count',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const _Dot(
              size: 32,
              background: AppColors.gray2,
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11,
                color: AppColors.black1,
              ),
            ),
            const SizedBox(height: 8),
            for (final word in const ['تسک', 'دیگر'])
              ReText(
                word,
                fontSize: 9.5,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
          ],
        ),
      ),
    );
  }
}

/// The round mark under a capsule, on the dashed line.
class _Dot extends StatelessWidget {
  const _Dot({
    required this.size,
    required this.background,
    this.ring = 4,
    this.border,
    this.shadow,
    this.child,
  });

  final double size;
  final Color background;

  /// The white ring around it, over the dashed line.
  final double ring;
  final Color? border;
  final Color? shadow;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(ring),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: background,
          border:
              border == null ? null : Border.all(color: border!, width: 1.5),
          boxShadow: shadow == null
              ? null
              : [
                  BoxShadow(
                    color: shadow!,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: child,
      ),
    );
  }
}

/// Names the suggested task above the capsules and holds the card's one main
/// action; a small pointer under it marks the capsule it speaks for.
class _SuggestionStrip extends StatelessWidget {
  const _SuggestionStrip({
    required this.title,
    required this.subtitle,
    required this.action,
    this.leading,
    this.onTap,
    this.notchCenter,
  });

  final String title;
  final String subtitle;
  final Widget action;
  final Widget? leading;
  final VoidCallback? onTap;

  /// The pointer's center from the strip's start; none when null.
  final double? notchCenter;

  @override
  Widget build(BuildContext context) {
    final notch = notchCenter;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (notch != null)
            PositionedDirectional(
              start: notch - 2 - 6,
              bottom: -5,
              child: Transform.rotate(
                angle: 0.785398,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.gray1,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.gray1,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 10)
                  ] else
                    const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReText(
                          title,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          maxLines: 1,
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 1),
                        ReText(
                          subtitle,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray,
                          maxLines: 1,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  action,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _StripButtonStyle { primary, dark, quiet }

class _StripButton extends StatelessWidget {
  const _StripButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.style = _StripButtonStyle.primary,
    this.iconSize = 15,
    this.textDirectionIcon,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final _StripButtonStyle style;
  final double iconSize;

  /// Pins the icon's direction (play stays pointing right in RTL).
  final TextDirection? textDirectionIcon;

  @override
  Widget build(BuildContext context) {
    // A light tint rather than a solid fill: the strip names the next step
    // without outshouting the capsules under it.
    final (Color background, Color foreground) = switch (style) {
      _StripButtonStyle.primary => (
          AppColors.primary.withValues(alpha: 0.1),
          AppColors.primary
        ),
      _StripButtonStyle.dark => (
          AppColors.black1.withValues(alpha: 0.07),
          AppColors.black1
        ),
      _StripButtonStyle.quiet => (Colors.white, AppColors.black1),
    };
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsetsDirectional.fromSTEB(14, 0, 12, 0),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(100),
          border: style == _StripButtonStyle.quiet
              ? Border.all(color: AppColors.gray2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReText(
              label,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
            const SizedBox(width: 5),
            Icon(
              icon,
              size: iconSize,
              color: foreground,
              textDirection: textDirectionIcon,
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _item('در حال اجرا', dot: _dot(AppColors.primary)),
        const SizedBox(width: 14),
        _item('نیمه‌کاره', dot: _dot(AppColors.secondary)),
        const SizedBox(width: 14),
        _item('انجام شده', dot: _dot(AppColors.done)),
        const SizedBox(width: 14),
        _item(
          'شروع نشده',
          dot: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipOval(
              child: CustomPaint(
                painter: StripedPainter(color: Colors.grey.shade400, gap: 3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _dot(Color color) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  static Widget _item(String title, {required Widget dot}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dot,
          const SizedBox(width: 6),
          ReText(
            title,
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ],
      );
}

/// The flame over today's progress bar where the day starts to count.
class _TargetMark extends StatelessWidget {
  const _TargetMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/flame.svg',
            width: 12,
            height: 12,
            colorFilter: const ColorFilter.mode(_flameRed, BlendMode.srcIn),
          ),
          const SizedBox(height: 1),
          Container(
            width: 2,
            height: 9,
            decoration: BoxDecoration(
              color: _flameRed,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

const Color _flameRed = Color(0xFFFF3040);

/// «۲۵ از ۶۰»: two numbers with a quieter «از» between them and even gaps.
/// Never written with a slash, which in Persian reads as a decimal.
class OutOfText extends StatelessWidget {
  const OutOfText(
    this.part,
    this.whole, {
    super.key,
    this.fontSize = 11.5,
    this.fontWeight = FontWeight.w700,
  });

  final int part;
  final int whole;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        ReText('$part', fontSize: fontSize, fontWeight: fontWeight),
        const SizedBox(width: 3),
        ReText(
          'از',
          fontSize: fontSize - 2,
          fontWeight: FontWeight.w600,
          color: AppColors.gray,
        ),
        const SizedBox(width: 3),
        ReText('$whole', fontSize: fontSize, fontWeight: fontWeight),
      ],
    );
  }
}

/// The home's small outlined link buttons («همه تسک‌ها», «همه اهداف»).
class HomeOutlineButton extends StatelessWidget {
  const HomeOutlineButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReText(title, fontSize: 11.5, fontWeight: FontWeight.w700),
              const SizedBox(width: 7),
              // Forward: it points left in RTL.
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: AppColors.gray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------- Helper Painters ----------------- //

class StripedPainter extends CustomPainter {
  const StripedPainter({required this.color, this.gap = 6.0});

  final Color color;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..isAntiAlias = true;

    for (double i = -size.height; i < size.width; i += gap) {
      canvas.drawLine(
        Offset(i + size.height, size.height),
        Offset(i, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DashedLinePainter extends CustomPainter {
  const DashedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 1.0;
    const dashSpace = 4.0;
    var startX = 0.0;

    final paint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
