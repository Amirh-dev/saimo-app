import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/data/notifications/task_reminder_service.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/screens/tasks/task_report_popup.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

/// A task's details sheet (start, report, edit, move, delete) and the delete
/// it can lead to. The tasks tab opens it from its rows, the home from its
/// capsules, so both show the very same sheet.

const String _deleteTaskMutation = r'''
mutation DeleteTaskWithScope($id: ID!, $scope: RecurringTaskDeleteScope) {
  deleteTask(id: $id, recurrenceScope: $scope)
}
''';

/// What a timed task is doing now: the live timer wins over the status the
/// task was loaded with. One of pending, running, paused, done.
String timedTaskStatus(Map<String, dynamic> task, TaskTimerService timer) {
  final id = task['id'] as String?;
  if (timer.isActive(id)) {
    if (timer.isCompleted) return 'done';
    return timer.isRunning ? 'running' : 'paused';
  }

  final status = task['status'] as String? ?? 'pending';
  if (status == 'running' && timer.hasActiveTask) return 'paused';

  return status;
}

int timedTaskRemainingSeconds(
    Map<String, dynamic> task, TaskTimerService timer) {
  final id = task['id'] as String?;
  if (timer.isActive(id)) return timer.remainingSeconds;
  return task['remainingSeconds'] as int? ?? 0;
}

Color timedTaskColor(String status) {
  switch (status) {
    case 'running':
      return AppColors.primary;
    case 'paused':
      return AppColors.secondary;
    case 'done':
      return AppColors.done;
    default:
      return AppColors.black1;
  }
}

/// Snapshot of what the details sheet shows; recomputed on every timer tick
/// so the countdown stays live while the sheet is open.
SheetTaskState sheetTaskStateFor(
  Map<String, dynamic> task, {
  required bool timed,
  required TaskTimerService timer,
}) {
  if (!timed) {
    final isDone = task['status'] == 'done';
    return SheetTaskState(
      isDone: isDone,
      canMove: !isDone,
      primaryText: 'انجام شد',
      progressColor: AppColors.black1,
    );
  }

  final status = timedTaskStatus(task, timer);
  final showsProgress = status == 'running' || status == 'paused';
  final duration = task['durationSeconds'] as int? ?? 0;
  final remaining = timedTaskRemainingSeconds(task, timer);
  final remainingShare =
      duration <= 0 ? 0.0 : (remaining / duration).clamp(0.0, 1.0);
  return SheetTaskState(
    isDone: status == 'done',
    // A started timer belongs to the day it ran on.
    canMove: status == 'pending',
    primaryText: status == 'pending' ? 'شروع' : 'ادامه',
    progress: showsProgress ? 1 - remainingShare : null,
    remainingLabel: showsProgress ? formatTaskSeconds(remaining) : null,
    durationLabel: showsProgress ? formatTaskSeconds(duration) : null,
    progressColor: timedTaskColor(status),
  );
}

/// Opens the details sheet for [task] and returns what was picked in it.
Future<TaskSheetAction?> showTaskDetailsSheet(
  BuildContext context, {
  required Map<String, dynamic> task,
  required bool timed,
}) {
  final timer = TaskTimerService.instance;
  // The banner hides itself while this sheet is open
  // (TaskTimerBannerRouteObserver).
  return showModalBottomSheet<TaskSheetAction>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => TaskDetailsSheet(
      task: task,
      timed: timed,
      listenable: timer,
      resolveState: () => sheetTaskStateFor(task, timed: timed, timer: timer),
    ),
  );
}

/// Deletes the task on the server. For an occurrence of a recurring task,
/// [scope] decides whether only this occurrence or the whole series goes.
/// Returns whether it was deleted.
Future<bool> deleteTaskOnServer(
  BuildContext context,
  String? taskId, {
  RecurringDeleteScope? scope,
}) async {
  if (taskId == null || taskId.isEmpty) {
    showReToast(context, 'این تسک پیدا نشد', ReToastType.failed);
    return false;
  }

  try {
    await context.read<GraphQLRepository>().rawRequest(
      query: _deleteTaskMutation,
      variables: {
        'id': taskId,
        // A non-recurring task ignores the scope; send the safe one anyway.
        'scope': switch (scope) {
          RecurringDeleteScope.series => 'STOP_RECURRENCE',
          _ => 'OCCURRENCE_ONLY',
        },
      },
    );

    // A deleted task's timer must not live on in the black banner at the
    // bottom of the app, nor ring when it would have run out.
    final timer = TaskTimerService.instance;
    if (timer.isActive(taskId)) timer.clear();
    await TaskReminderService.instance.cancel(taskId);
    // A stopped series leaves its later copies canceled on the server.
    if (scope == RecurringDeleteScope.series) {
      unawaited(TaskReminderService.instance.sync());
    }
    if (!context.mounted) return false;

    showReToast(context, 'تسک حذف شد', ReToastType.success);
    return true;
  } catch (error) {
    debugPrint('Delete task failed: $error');
    if (!context.mounted) return false;
    showReToast(
      context,
      'حذف تسک ناموفق بود. دوباره امتحان کن.',
      ReToastType.failed,
    );
    return false;
  }
}

/// Asks for confirmation (and a scope for recurring tasks), then deletes.
/// Returns whether the task was deleted.
Future<bool> requestDeleteTask(
    BuildContext context, Map<String, dynamic> task) async {
  final isRecurring = task['recurrenceId'] != null;
  final choice = await confirmDeleteTask(context, isRecurring: isRecurring);
  if (choice == null || !context.mounted) return false;

  return deleteTaskOnServer(context, task['id'] as String?, scope: choice);
}

/// Returns the chosen scope, or null when the user cancels. Recurring tasks
/// get a choice between this occurrence and the whole series; the server
/// otherwise stops the entire recurrence.
Future<RecurringDeleteScope?> confirmDeleteTask(
  BuildContext context, {
  required bool isRecurring,
}) {
  return showModalBottomSheet<RecurringDeleteScope>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.errorColor),
                    color: AppColors.white,
                  ),
                  child: const Icon(
                    SolarIconsOutline.trashBinMinimalistic,
                    color: AppColors.errorColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ReText(
                isRecurring ? 'این تسک تکرارشونده است' : 'این تسک حذف بشه؟',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.black1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              ReText(
                isRecurring
                    ? 'می‌تونی فقط همین روز رو حذف کنی یا تکرار روزهای بعد رو هم برداری.'
                    : 'این کار قابل بازگشت نیست.',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.gray,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (isRecurring) ...[
                _ActionSheetButton(
                  text: 'فقط همین روز',
                  background: AppColors.errorColor,
                  textColor: AppColors.white,
                  onTap: () => Navigator.of(context)
                      .pop(RecurringDeleteScope.occurrence),
                ),
                const SizedBox(height: 10),
                _ActionSheetButton(
                  text: 'همین روز و روزهای آینده',
                  background: AppColors.white,
                  textColor: AppColors.errorColor,
                  borderColor: AppColors.errorColor,
                  onTap: () =>
                      Navigator.of(context).pop(RecurringDeleteScope.series),
                ),
                const SizedBox(height: 10),
                _ActionSheetButton(
                  text: 'لغو',
                  background: AppColors.white,
                  textColor: AppColors.black1,
                  borderColor: AppColors.gray2,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ] else
                Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    Expanded(
                      child: _ActionSheetButton(
                        text: 'حذف',
                        background: AppColors.errorColor,
                        textColor: AppColors.white,
                        onTap: () => Navigator.of(context)
                            .pop(RecurringDeleteScope.occurrence),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionSheetButton(
                        text: 'لغو',
                        background: AppColors.white,
                        textColor: AppColors.black1,
                        borderColor: AppColors.gray2,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    },
  );
}

enum TaskSheetAction { primary, report, edit, move, delete }

/// How much of a recurring task a delete removes.
enum RecurringDeleteScope { occurrence, series }

class SheetTaskState {
  const SheetTaskState({
    required this.isDone,
    required this.canMove,
    required this.primaryText,
    required this.progressColor,
    this.progress,
    this.remainingLabel,
    this.durationLabel,
  });

  final bool isDone;

  /// Whether the task can still be moved to another day.
  final bool canMove;
  final String primaryText;
  final Color progressColor;
  final double? progress;
  final String? remainingLabel;
  final String? durationLabel;
}

class TaskDetailsSheet extends StatelessWidget {
  const TaskDetailsSheet({
    super.key,
    required this.task,
    required this.timed,
    required this.listenable,
    required this.resolveState,
  });

  final Map<String, dynamic> task;
  final bool timed;
  final Listenable listenable;
  final SheetTaskState Function() resolveState;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) => _buildContent(context, resolveState()),
    );
  }

  Widget _buildContent(BuildContext context, SheetTaskState state) {
    final note = (task['note'] as String?)?.trim() ?? '';
    final tags = (task['tags'] as List?)?.cast<String>() ?? const <String>[];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              Row(
                children: [
                  if (timed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: ReText(
                        task['label'] ?? '',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ReText(
                          task['title'] ?? '',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.black1,
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 4),
                        ReText(
                          task['subtitle'] ?? '',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ).hMargin(12),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gray2),
                      ),
                      child: const Icon(Icons.close,
                          size: 18, color: AppColors.black1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(height: 1, color: AppColors.gray2),
              if (note.isNotEmpty) ...[
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ReText(
                    note,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in tags)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.black1,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: ReText(
                            '#$tag',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (task['report'] is TaskReport) ...[
                const SizedBox(height: 18),
                _ReportSummary(report: task['report'] as TaskReport),
              ],
              if (state.progress != null) ...[
                const SizedBox(height: 22),
                Row(
                  children: [
                    ReText(
                      '${state.remainingLabel}   / ',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.black1,
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(width: 6),
                    ReText(
                      state.durationLabel ?? '',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray,
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: state.progress!.clamp(0.0, 1.0),
                          minHeight: 3,
                          backgroundColor: AppColors.gray2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              state.progressColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (state.canMove) ...[
                const SizedBox(height: 20),
                GestureDetector(
                  key: const ValueKey('task-sheet-move'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(TaskSheetAction.move),
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: AppColors.gray1,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 14,
                          color: AppColors.gray,
                        ),
                        Spacer(),
                        ReText(
                          'انتقال به روز دیگر',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black1,
                        ),
                        SizedBox(width: 10),
                        Icon(
                          IconsaxPlusLinear.calendar,
                          size: 20,
                          color: AppColors.black1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 26),
              Row(
                children: [
                  if (!state.isDone) ...[
                    Expanded(
                      flex: 1,
                      child: _SheetButton(
                        text: state.primaryText,
                        icon: Icons.arrow_back_ios_new_rounded,
                        background: AppColors.secondary,
                        textColor: AppColors.white,
                        onTap: () =>
                            Navigator.of(context).pop(TaskSheetAction.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // A timed task ends only when its timer runs out, so it can
                  // be reported on only once it is done.
                  if (!timed || state.isDone) ...[
                    Expanded(
                      flex: 1,
                      child: _SheetButton(
                        key: const ValueKey('task-sheet-report'),
                        text: 'گزارش',
                        icon: SolarIconsOutline.clipboardText,
                        background: AppColors.white,
                        textColor: AppColors.black1,
                        borderColor: AppColors.gray2,
                        // A filled dot: this task already has a report.
                        marked: task['report'] != null,
                        onTap: () =>
                            Navigator.of(context).pop(TaskSheetAction.report),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    flex: 1,
                    child: _SheetButton(
                      text: 'ویرایش',
                      icon: SolarIconsOutline.pen,
                      background: AppColors.white,
                      textColor: AppColors.black1,
                      borderColor: AppColors.gray2,
                      onTap: () =>
                          Navigator.of(context).pop(TaskSheetAction.edit),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pop(TaskSheetAction.delete),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gray2),
                      ),
                      child: const Icon(
                        SolarIconsOutline.trashBinMinimalistic,
                        size: 22,
                        color: AppColors.black1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The saved report in the details sheet: the self-rating and, when a test
/// was taken, its score.
class _ReportSummary extends StatelessWidget {
  const _ReportSummary({required this.report});

  final TaskReport report;

  @override
  Widget build(BuildContext context) {
    final total = report.totalQuestions;
    final correct = report.correctAnswers;
    final hasTest = report.tookTest && total != null && total > 0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        key: const ValueKey('task-sheet-report-summary'),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.gray1,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(SolarIconsOutline.clipboardText,
                    size: 20, color: AppColors.black1),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReText(
                        'امتیاز به خودت: ${convertToPersianNumbers('${report.rating}')} از ۵',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black1,
                      ),
                      const SizedBox(height: 2),
                      ReText(
                        hasTest
                            ? '${convertToPersianNumbers('$correct')} پاسخ صحیح از ${convertToPersianNumbers('$total')} سوال'
                            : 'بدون تست',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray,
                      ),
                    ],
                  ),
                ),
                if (hasTest)
                  ReText(
                    formatPercent(correct! / total),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.success,
                  ),
              ],
            ),
            if (report.note != null) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.gray2),
              const SizedBox(height: 10),
              ReText(
                report.note!,
                key: const ValueKey('task-sheet-report-note'),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.black1,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    super.key,
    required this.text,
    required this.icon,
    required this.background,
    required this.textColor,
    required this.onTap,
    this.borderColor,
    this.marked = false,
  });

  final String text;
  final IconData icon;
  final Color background;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  /// Shows a small success dot on the icon.
  final bool marked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(100),
          border: borderColor == null ? null : Border.all(color: borderColor!),
        ),
        // Three of these share a row with the delete button, so the label
        // shrinks rather than overflow on narrow phones.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.ltr,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 17, color: textColor),
                  if (marked)
                    Positioned(
                      top: -2,
                      right: -3,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: background, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 5),
              ReText(
                text,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionSheetButton extends StatelessWidget {
  const _ActionSheetButton({
    required this.text,
    required this.background,
    required this.textColor,
    required this.onTap,
    this.borderColor,
  });

  final String text;
  final Color background;
  final Color textColor;
  final VoidCallback onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(100),
          border: borderColor == null ? null : Border.all(color: borderColor!),
        ),
        child: ReText(
          text,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: textColor,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}