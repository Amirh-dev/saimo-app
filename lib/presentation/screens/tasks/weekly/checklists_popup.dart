import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_widgets.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/week_plan.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/_utils.dart';

/// A day's checklists, in both modes: folded into a pill with their count,
/// and opened in a popup where they are checked off.

/// Background of a task to do, wherever tasks are drawn as boxes.
const Color kTaskFill = Color(0xFFF3F4F7);

/// A ring for a task to do, a dark check once it is done; a running timer
/// rings in the main color.
class TaskStatusMark extends StatelessWidget {
  const TaskStatusMark({super.key, required this.task, required this.size});

  final Map<String, dynamic> task;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (isTaskDone(task)) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.black1,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_rounded, size: size * 0.72, color: AppColors.white),
      );
    }
    final running = task['status'] == 'running';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: running ? AppColors.primary : AppColors.black1.withValues(alpha: 0.55),
          width: running ? 1.8 : 1.5,
        ),
      ),
    );
  }
}

/// «چک‌لیست‌ها» with how many there are; the count turns dark once all are
/// done.
class ChecklistsPill extends StatelessWidget {
  const ChecklistsPill({
    super.key,
    required this.tasks,
    required this.onTap,
    this.height = 32,
    this.fontSize = 11,
  });

  final List<Map<String, dynamic>> tasks;
  final VoidCallback onTap;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final allDone = tasks.isNotEmpty && tasks.every(isTaskDone);
    return Semantics(
      button: true,
      label: convertToPersianNumbers('چک‌لیست‌ها، ${tasks.length}'),
      excludeSemantics: true,
      child: PressScale(
        onTap: onTap,
        child: Container(
          height: height,
          padding: EdgeInsetsDirectional.fromSTEB(height * 0.32, 0, height * 0.16, 0),
          decoration: BoxDecoration(
            color: kTaskFill,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: ReText(
                    'چک‌لیست‌ها',
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black1,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                constraints: BoxConstraints(minWidth: height * 0.68),
                height: height * 0.68,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: allDone ? AppColors.black1 : AppColors.whiteSec,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: ReText(
                  '${tasks.length}',
                  fontSize: fontSize - 0.5,
                  fontWeight: FontWeight.w900,
                  color: allDone ? AppColors.white : AppColors.black1,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens [date]'s checklists. [tasks] is read again whenever [listenable]
/// changes, so a check shows at once and a failed one springs back.
/// [onToggle] checks a task off or back on; [onOpenTask] opens its details,
/// for editing, moving or deleting; [onAdd], when given, adds another.
Future<void> showChecklistsPopup(
  BuildContext context, {
  required Listenable listenable,
  required List<Map<String, dynamic>> Function() tasks,
  required Jalali date,
  required ValueChanged<Map<String, dynamic>> onToggle,
  ValueChanged<Map<String, dynamic>>? onOpenTask,
  VoidCallback? onAdd,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'بستن',
    barrierColor: AppColors.black1.withValues(alpha: 0.28),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondary) => _ChecklistsPopup(
      listenable: listenable,
      tasks: tasks,
      date: date,
      onToggle: onToggle,
      onOpenTask: onOpenTask,
      onAdd: onAdd,
    ),
    transitionBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.settle,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _ChecklistsPopup extends StatelessWidget {
  const _ChecklistsPopup({
    required this.listenable,
    required this.tasks,
    required this.date,
    required this.onToggle,
    required this.onOpenTask,
    required this.onAdd,
  });

  final Listenable listenable;
  final List<Map<String, dynamic>> Function() tasks;
  final Jalali date;
  final ValueChanged<Map<String, dynamic>> onToggle;
  final ValueChanged<Map<String, dynamic>>? onOpenTask;
  final VoidCallback? onAdd;

  void _closeThen(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Material(
              key: const ValueKey('week-checklists-popup'),
              color: AppColors.whiteSec,
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: ListenableBuilder(
                  listenable: listenable,
                  builder: (context, _) {
                    final items = tasks();
                    final done = items.where(isTaskDone).length;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _header(context, items.length, done),
                        const SizedBox(height: 10),
                        if (items.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: ReText(
                              'چک‌لیستی برای این روز ندارید.',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray,
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 360),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (var index = 0; index < items.length; index++) ...[
                                    if (index > 0)
                                      const Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: AppColors.gray1,
                                      ),
                                    _ChecklistRow(
                                      key: ValueKey('week-checklist-${items[index]['id']}'),
                                      task: items[index],
                                      onTap: () => onToggle(items[index]),
                                      onMore: onOpenTask == null
                                          ? null
                                          : () => _closeThen(
                                                context,
                                                () => onOpenTask!(items[index]),
                                              ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        if (onAdd != null) ...[
                          const SizedBox(height: 14),
                          PlanPillButton.outlined(
                            key: const ValueKey('week-checklists-add'),
                            text: 'افزودن چک‌لیست',
                            icon: Icons.add_rounded,
                            height: 46,
                            fontSize: 13,
                            onTap: () => _closeThen(context, onAdd!),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, int total, int done) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReText(
                'چک‌لیست‌ها',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.black1,
              ),
              ReText(
                total == 0
                    ? dayLabel(date)
                    : '${dayLabel(date)}، $done از $total انجام شد',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.gray,
              ),
            ],
          ),
        ),
        Semantics(
          button: true,
          label: 'بستن',
          child: PressScale(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              key: const ValueKey('week-checklists-close'),
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.gray1,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 18, color: AppColors.black1),
            ),
          ),
        ),
      ],
    );
  }
}

/// One checklist: the row checks it off, or back on; «…» opens its details.
class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    super.key,
    required this.task,
    required this.onTap,
    required this.onMore,
  });

  final Map<String, dynamic> task;
  final VoidCallback onTap;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final done = isTaskDone(task);
    final title = task['title'] as String? ?? '';
    return Row(
      children: [
        Expanded(
          child: Semantics(
            checked: done,
            label: title,
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                onTap();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                        child: child,
                      ),
                      child: TaskStatusMark(key: ValueKey(done), task: task, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ReText(
                        title,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        maxLines: 2,
                        color: done ? AppColors.gray : AppColors.black1,
                        decoration: done ? TextDecoration.lineThrough : null,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (onMore != null)
          Semantics(
            button: true,
            label: 'گزینه‌های $title',
            excludeSemantics: true,
            child: GestureDetector(
              key: ValueKey('week-checklist-more-${task['id']}'),
              behavior: HitTestBehavior.opaque,
              onTap: onMore,
              child: const SizedBox(
                width: 40,
                height: 44,
                child: Icon(Icons.more_horiz_rounded, size: 20, color: AppColors.dark6Color),
              ),
            ),
          ),
      ],
    );
  }
}
