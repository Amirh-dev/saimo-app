import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/data/notifications/task_reminder_service.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/core/global/global_data.dart';
import 'package:simo_learn/presentation/screens/chat/index.dart';
import 'package:simo_learn/presentation/screens/tasks/add_task/index.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_screen.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';
import 'package:simo_learn/presentation/screens/tasks/tasks_api.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/checklists_popup.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_date_picker.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_widgets.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_sheets.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/undo_bar.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/week_header.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/week_plan.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/weekly_plan_controller.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/weekly_plan_view.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with TickerProviderStateMixin {
  late Jalali _selectedDate;

  /// Read on demand so "today" stays correct if the app is left open past
  /// midnight.
  Jalali get _today => Jalali.now();

  // Add Menu Animation Controllers

  List<Map<String, dynamic>> _checklistTasks = [];
  List<Map<String, dynamic>> _timedTasks = [];
  bool _isLoadingTasks = false;
  final TaskTimerService _timer = TaskTimerService.instance;

  /// Ticks whenever the day's checklists change, so their popup follows.
  final ValueNotifier<int> _dayChecklistsChanged = ValueNotifier(0);

  // Tasks with a status change in flight, so repeated taps don't stack
  // conflicting requests.
  final Set<String> _pendingStatusTaskIds = <String>{};
  static const Duration _modeSwitchDuration = Duration(milliseconds: 320);
  static const Duration _undoDuration = Duration(seconds: 5);

  /// Daily mode is for doing the day's tasks; weekly mode for planning the
  /// whole week. Both share [_selectedDate], so switching zooms in or out
  /// around the same day.
  TasksViewMode _mode = TasksViewMode.day;
  late final TasksApi _tasksApi;
  late final WeeklyPlanController _week;
  final GlobalKey<WeeklyPlanViewState> _weekViewKey = GlobalKey();
  ({String message, VoidCallback onUndo})? _undo;
  Timer? _undoTimer;

  bool get _isWeekMode => _mode == TasksViewMode.week;

  @override
  void initState() {
    super.initState();
    _selectedDate = _today;
    _tasksApi = GraphQLTasksApi(context.read<GraphQLRepository>());
    _week = WeeklyPlanController(_tasksApi)..addListener(_onWeekChanged);

    _timer.addListener(_onGlobalTimerChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer.bindRepository(
          TaskTimerRepository(context.read<GraphQLRepository>()));
      _loadTasksForSelectedDate();
    });
  }

  @override
  void dispose() {
    _undoTimer?.cancel();
    _week
      ..removeListener(_onWeekChanged)
      ..dispose();
    _timer.removeListener(_onGlobalTimerChanged);
    _dayChecklistsChanged.dispose();
    super.dispose();
  }

  /// "امروز" / "فردا" / "دیروز", or the date itself, for headings and copy.
  String _selectedDayPhrase() {
    final today = _today;
    if (isSameJalaliDay(_selectedDate, today)) return 'امروز';
    if (isSameJalaliDay(_selectedDate, today.addDays(1))) return 'فردا';
    if (isSameJalaliDay(_selectedDate, today.addDays(-1))) return 'دیروز';
    return '${convertToPersianNumbers(_selectedDate.day.toString())} ${kPersianMonths[_selectedDate.month - 1]}';
  }

  /// Logs the technical error and returns a message fit for the user.
  String _userErrorMessage(Object error, String fallback) {
    debugPrint('TasksScreen error: $error');
    return fallback;
  }

  String _actionErrorMessage(Object error, String fallback) =>
      error is TaskActionException
          ? error.message
          : _userErrorMessage(error, fallback);

  // ------------------------------------------------------------ view modes

  void _setMode(TasksViewMode mode) {
    if (mode == _mode) return;
    _hideUndo();
    setState(() {
      _mode = mode;
      // The server only returns weeks up to the planning horizon.
      if (mode == TasksViewMode.week &&
          !isWeekWithinHorizon(weekStartOf(_selectedDate), _today)) {
        _selectedDate = lastPlannableDay(_today);
      }
    });
    if (mode == TasksViewMode.week) {
      unawaited(_week.showWeekOf(_selectedDate));
    } else {
      unawaited(_loadTasksForSelectedDate());
    }
  }

  /// Reloads what the current mode shows, keeping it on screen meanwhile.
  Future<void> _reloadActiveView() {
    return _isWeekMode
        ? _week.reload(silent: true)
        : _loadTasksForSelectedDate(showLoading: false);
  }

  void _onWeekChanged() {
    if (!_isWeekMode || !_week.hasData || _week.isLoading) return;
    _resumeServerTimer(_week.tasks.where(isTimedTask).toList());
  }

  /// A day of the week strip was tapped.
  void _selectWeekDay(Jalali day) {
    setState(() => _selectedDate = day);
    _weekViewKey.currentState?.scrollToDay(day);
  }

  void _changeWeek(int weeks) {
    final date = _selectedDate.addDays(7 * weeks);
    setState(() => _selectedDate = date);
    unawaited(_week.showWeekOf(date));
  }

  // ------------------------------------------------- daily mode date picker

  /// A day was picked from the week strip in daily mode.
  void _selectDay(Jalali day) {
    if (isSameJalaliDay(day, _selectedDate)) return;
    setState(() => _selectedDate = day);
    unawaited(_loadTasksForSelectedDate());
  }

  /// The strip was swiped to another week in daily mode: the same weekday
  /// there is selected, so the selection keeps its place in the strip.
  void _changeDayWeek(int weeks) {
    setState(() => _selectedDate = _selectedDate.addDays(7 * weeks));
    unawaited(_loadTasksForSelectedDate());
  }

  Future<void> _pickDay() async {
    final picked = await _pickDate();
    if (picked == null || !mounted) return;
    setState(() => _selectedDate = picked);
    await _loadTasksForSelectedDate();
  }

  /// Keeps the strip's progress rings current in daily mode, for the weeks
  /// the server can return.
  void _syncWeekStrip() {
    if (isWeekWithinHorizon(weekStartOf(_selectedDate), _today)) {
      unawaited(_week.showWeekOf(_selectedDate));
    }
  }

  Future<void> _pickWeekDate() async {
    final picked = await _pickDate(lastDate: lastPlannableDay(_today));
    if (picked == null || !mounted) return;
    setState(() => _selectedDate = picked);
    await _week.showWeekOf(picked);
    if (mounted) await _weekViewKey.currentState?.scrollToDay(picked);
  }

  void _explainPlanningHorizon() {
    showReToast(
      context,
      'برنامه‌ریزی تا ۱۲ هفته آینده امکان‌پذیر است.',
      ReToastType.info,
    );
  }

  /// "امروز", "فردا", a weekday of this week, or the date.
  String _dayPhrase(Jalali day) {
    final today = _today;
    switch (daysBetween(today, day)) {
      case 0:
        return 'امروز';
      case 1:
        return 'فردا';
      case -1:
        return 'دیروز';
    }
    return isSameJalaliDay(weekStartOf(day), weekStartOf(today))
        ? weekdayName(day)
        : dayLabel(day);
  }

  // -------------------------------------------------------------- planning

  void _showUndo(String message, VoidCallback onUndo) {
    _undoTimer?.cancel();
    setState(() => _undo = (message: message, onUndo: onUndo));
    _undoTimer = Timer(_undoDuration, _hideUndo);
  }

  void _hideUndo() {
    _undoTimer?.cancel();
    _undoTimer = null;
    if (mounted && _undo != null) setState(() => _undo = null);
  }

  /// Moves [task] to [day] and offers to take it back.
  Future<void> _moveTask(Map<String, dynamic> task, Jalali day) =>
      _moveTasks([task], day);

  /// Moves [tasks] to [day], then offers to take them all back. Stops at the
  /// first one that fails; the reload shows where each really is.
  Future<void> _moveTasks(
    List<Map<String, dynamic>> tasks,
    Jalali day, {
    bool offerUndo = true,
  }) async {
    final moved = <(Map<String, dynamic>, Jalali)>[];
    for (final task in tasks) {
      final from = task['date'];
      try {
        await _tasksApi.moveTask(task, day);
      } catch (error) {
        if (mounted) {
          showReToast(
            context,
            _actionErrorMessage(
                error, 'جابه‌جایی تسک ناموفق بود. دوباره تلاش کنید.'),
            ReToastType.failed,
          );
        }
        break;
      }
      if (from is Jalali) moved.add((task, from));
    }
    if (!mounted) return;

    await _reloadActiveView();
    if (!mounted || !offerUndo || moved.isEmpty) return;
    final message = moved.length == 1
        ? 'به ${_dayPhrase(day)} منتقل شد'
        : convertToPersianNumbers(
            '${moved.length} کار به ${_dayPhrase(day)} منتقل شد');
    _showUndo(message, () async {
      _hideUndo();
      for (final (task, from) in moved) {
        try {
          await _tasksApi.moveTask(task, from);
        } catch (_) {
          // The reload below shows what could not go back.
        }
      }
      if (mounted) await _reloadActiveView();
    });
  }

  /// Checks [task] off, or back on. The change shows at once and springs
  /// back if it cannot be saved.
  Future<void> _setTaskDone(
    Map<String, dynamic> task, {
    required bool done,
  }) async {
    if (_isWeekMode) {
      try {
        await _week.setTaskDone(task, done: done);
      } catch (error) {
        if (!mounted) return;
        showReToast(
          context,
          _actionErrorMessage(
              error, 'تغییر وضعیت تسک ناموفق بود. دوباره تلاش کنید.'),
          ReToastType.failed,
        );
      }
      return;
    }

    final id = task['id'] as String?;
    if (id == null || isTaskDone(task) == done) return;
    if (!_pendingStatusTaskIds.add(id)) return;
    final previous = task['status'];
    void show(Object? status) {
      if (!mounted) return;
      setState(() => task['status'] = status);
      _dayChecklistsChanged.value++;
    }

    show(done ? 'done' : 'pending');
    try {
      await _tasksApi.setTaskDone(task, done: done);
      // The strip's ring for this day.
      unawaited(_week.reload(silent: true));
    } catch (error) {
      show(previous);
      if (mounted) {
        showReToast(
          context,
          _actionErrorMessage(
              error, 'تغییر وضعیت تسک ناموفق بود. دوباره تلاش کنید.'),
          ReToastType.failed,
        );
      }
    } finally {
      _pendingStatusTaskIds.remove(id);
    }
  }

  /// The day's checklists in the popup the week uses too.
  void _openDayChecklists() {
    showChecklistsPopup(
      context,
      listenable: _dayChecklistsChanged,
      date: _selectedDate,
      tasks: () => _checklistTasks,
      onToggle: (task) => _setTaskDone(task, done: !isTaskDone(task)),
      onOpenTask: (task) => _showTaskDetails(task, timed: false),
      onAdd: () => _openQuickAdd(_selectedDate, timed: false),
    );
  }

  Future<void> _openQuickAdd(Jalali day, {bool timed = true}) async {
    await showQuickAddSheet(
      context,
      initialDay: day,
      today: _today,
      initialTimed: timed,
      subjects: [for (final tag in GlobalData.instance.parentTags) tag.name],
      onSubmit: (draft) async {
        try {
          await _tasksApi.createQuickTask(draft);
          return null;
        } catch (error) {
          return _actionErrorMessage(
              error, 'افزودن تسک ناموفق بود. دوباره تلاش کنید.');
        }
      },
      onMoreOptions: _openFullAddForm,
    );
    // Shows the new tasks, with what the server filled in (the subject).
    if (mounted) unawaited(_reloadActiveView());
  }

  /// "Advanced settings": the full form, filled with what quick add had.
  Future<void> _openFullAddForm(QuickTaskDraft draft) async {
    final tags = [if (draft.subject != null) draft.subject!];
    final created = await context.to<Map<String, dynamic>>(
      draft.isTimed
          ? AddTimedTaskScreen(
              initialDate: draft.day,
              initialTitle: draft.title,
              initialMinutes: draft.timedMinutes,
              initialTags: tags,
            )
          : AddTaskScreen(
              initialDate: draft.day,
              initialTitle: draft.title,
              initialTags: tags,
            ),
    );
    if (created == null || !mounted) return;
    showReToast(context, 'تسک با موفقیت اضافه شد', ReToastType.success);
    await _reloadActiveView();
  }

  static const String _tasksQuery = '''
query TasksForDay(\$date: Time!) {
  getTasks(date: \$date, limit: 100, offset: 0) {
$kTaskFields
  }
}
''';

  static const String _deleteTaskMutation = r'''
mutation DeleteTaskWithScope($id: ID!, $scope: RecurringTaskDeleteScope) {
  deleteTask(id: $id, recurrenceScope: $scope)
}
''';

  Future<void> _loadTasksForSelectedDate({bool showLoading = true}) async {
    if (showLoading && mounted) setState(() => _isLoadingTasks = true);
    try {
      final selectedDate = _selectedDate;
      // Ask the server for this day only. Fetching an unfiltered page and
      // filtering locally drops the day's tasks once the user has more than
      // one page of tasks (recurring tasks are materialized weeks ahead).
      final data = await context.read<GraphQLRepository>().rawRequest(
        query: _tasksQuery,
        variables: {'date': rfc3339Local(selectedDate.toDateTime())},
      );

      if (!mounted || !isSameJalaliDay(selectedDate, _selectedDate)) return;

      final checklistTasks = <Map<String, dynamic>>[];
      final timedTasks = <Map<String, dynamic>>[];
      final tasks = (data['getTasks'] as List?) ?? const [];
      for (final task in tasks.whereType<Map<String, dynamic>>()) {
        final id = task['id'] as String?;
        final status = task['status'] as String?;
        // Safety net: a finished task must never keep a pending reminder.
        if (id != null && (status == 'COMPLETED' || status == 'CANCELED')) {
          unawaited(TaskReminderService.instance.cancel(id));
        }
        // Canceled occurrences belong to a stopped recurrence; they are
        // deleted from the user's point of view.
        if (status == 'CANCELED') continue;

        final taskDate = jalaliFromIso(task['date'] as String? ?? '');
        if (taskDate == null || !isSameJalaliDay(taskDate, selectedDate)) {
          continue;
        }

        if (task['type'] == 'TIMED') {
          timedTasks.add(timedTaskFromApi(task));
        } else {
          checklistTasks.add(taskFromApi(task));
        }
      }

      setState(() {
        _checklistTasks = checklistTasks;
        _timedTasks = timedTasks;
        _isLoadingTasks = false;
      });
      _dayChecklistsChanged.value++;
      _resumeServerTimer(timedTasks);
      if (!_isWeekMode) _syncWeekStrip();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoadingTasks = false);
      showReToast(
        context,
        _userErrorMessage(error, 'دریافت تسک‌ها ناموفق بود. دوباره تلاش کنید.'),
        ReToastType.failed,
      );
    }
  }

  /// Deletes the task on the server. For an occurrence of a recurring task,
  /// [scope] decides whether only this occurrence or the whole series goes.
  /// Returns whether it was deleted.
  Future<bool> _deleteTaskById(
    String? taskId, {
    _RecurringDeleteScope? scope,
    String? recurrenceId,
  }) async {
    if (taskId == null || taskId.isEmpty) {
      showReToast(context, 'شناسه تسک پیدا نشد', ReToastType.failed);
      return false;
    }

    try {
      await context.read<GraphQLRepository>().rawRequest(
        query: _deleteTaskMutation,
        variables: {
          'id': taskId,
          // A non-recurring task ignores the scope; send the safe one anyway.
          'scope': switch (scope) {
            _RecurringDeleteScope.series => 'STOP_RECURRENCE',
            _ => 'OCCURRENCE_ONLY',
          },
        },
      );

      await TaskReminderService.instance.cancel(taskId);
      if (scope == _RecurringDeleteScope.series && recurrenceId != null) {
        await TaskReminderService.instance
            .cancel(TaskReminderService.recurrenceKey(recurrenceId));
      }
      if (!mounted) return false;

      showReToast(context, 'تسک حذف شد', ReToastType.success);
      return true;
    } catch (error) {
      if (!mounted) return false;
      showReToast(
        context,
        _userErrorMessage(error, 'حذف تسک ناموفق بود. دوباره تلاش کنید.'),
        ReToastType.failed,
      );
      return false;
    }
  }

  /// Asks for confirmation (and a scope for recurring tasks), then deletes.
  Future<void> _requestDeleteTask(Map<String, dynamic> task) async {
    final isRecurring = task['recurrenceId'] != null;
    final choice = await _confirmDeleteTask(isRecurring: isRecurring);
    if (choice == null || !mounted) return;

    final deleted = await _deleteTaskById(
      task['id'] as String?,
      scope: choice,
      recurrenceId: task['recurrenceId'] as String?,
    );
    if (deleted && mounted) await _reloadActiveView();
  }

  void _onGlobalTimerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  String _timedTaskStatus(Map<String, dynamic> task) {
    final id = task['id'] as String?;
    if (_timer.isActive(id)) {
      if (_timer.isCompleted) return 'done';
      return _timer.isRunning ? 'running' : 'paused';
    }

    final status = task['status'] as String? ?? 'pending';
    if (status == 'running' && _timer.hasActiveTask) return 'paused';

    return status;
  }

  int _timedTaskRemainingSeconds(Map<String, dynamic> task) {
    final id = task['id'] as String?;
    if (_timer.isActive(id)) return _timer.remainingSeconds;
    return task['remainingSeconds'] as int? ?? 0;
  }

  /// Returns the chosen scope, or null when the user cancels. Recurring tasks
  /// get a choice between this occurrence and the whole series; the server
  /// otherwise stops the entire recurrence.
  Future<_RecurringDeleteScope?> _confirmDeleteTask({
    required bool isRecurring,
  }) {
    return showModalBottomSheet<_RecurringDeleteScope>(
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
                  isRecurring
                      ? 'این تسک تکرارشونده است'
                      : 'تسک موردنظر حذف شود؟',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                ReText(
                  isRecurring
                      ? 'می‌توانید فقط همین روز را حذف کنید یا تکرار را برای روزهای آینده هم متوقف کنید.'
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
                        .pop(_RecurringDeleteScope.occurrence),
                  ),
                  const SizedBox(height: 10),
                  _ActionSheetButton(
                    text: 'همین روز و روزهای آینده',
                    background: AppColors.white,
                    textColor: AppColors.errorColor,
                    borderColor: AppColors.errorColor,
                    onTap: () =>
                        Navigator.of(context).pop(_RecurringDeleteScope.series),
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
                              .pop(_RecurringDeleteScope.occurrence),
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

  /// Shown while the day has no time boxes; the add row above starts one.
  Widget _buildEmptyDay(BuildContext context) {
    return ReEmptyList(
      imageWidth: MediaQuery.of(context).size.width / 2.5,
      title: 'تسک زمان‌داری ندارید!',
      subtitle: 'برای ${_selectedDayPhrase()} تسکی اضافه نکردید.',
    );
  }

  Color _timedTaskColor(String status) {
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

  IconData _timedTaskIcon(String status) {
    switch (status) {
      case 'running':
        return Icons.pause_rounded;
      case 'paused':
        return Icons.play_arrow_rounded;
      case 'done':
        return CupertinoIcons.checkmark_alt;
      default:
        return Icons.play_arrow_rounded;
    }
  }

  String _timedTaskDurationValue(Map<String, dynamic> task) {
    return (task['label']?.toString() ?? '').replaceAll('دقیقه', '').trim();
  }

  bool _timedTaskShowsProgress(Map<String, dynamic> task) {
    final status = _timedTaskStatus(task);
    return status == 'running' || status == 'paused';
  }

  // Card heights used by [_buildTimedTaskTile]; the timeline marker must span
  // the same height or its dashed connector breaks between rows.
  static const double _timedCardHeight = 70.0;
  static const double _timedCardWithProgressHeight = 120.0;
  static const double _timedCardProgressMargin = 8.0;
  static const double _timedRowSpacing = 4.0;

  double _timedTaskRowHeight(Map<String, dynamic> task) {
    if (_timedTaskShowsProgress(task)) {
      return _timedCardWithProgressHeight + _timedCardProgressMargin * 2;
    }
    return _timedCardHeight + _timedRowSpacing;
  }

  double _timedTaskRemainingProgress(Map<String, dynamic> task) {
    final duration = task['durationSeconds'] as int? ?? 0;
    if (duration <= 0) return 0;
    final remaining = _timedTaskRemainingSeconds(task);
    return (remaining / duration).clamp(0.0, 1.0);
  }

  String _timedTaskRemainingLabel(Map<String, dynamic> task) {
    return formatTaskSeconds(_timedTaskRemainingSeconds(task));
  }

  String _timedTaskDurationLabel(Map<String, dynamic> task) {
    return formatTaskSeconds(task['durationSeconds'] as int? ?? 0);
  }

  Future<void> _toggleTimedTaskTimer(int index) async {
    if (index < 0 || index >= _timedTasks.length) return;

    final task = _timedTasks[index];
    final id = task['id'] as String?;
    if (id == null) return;
    if (_timedTaskStatus(task) == 'done') return;

    if (_timer.isRunningTask(id)) {
      await _timer.pause();
      return;
    }

    if (_timer.isRunning) {
      await _timer.pause();
    }

    _timer.load(
      taskId: id,
      totalSeconds: task['durationSeconds'] as int? ?? 0,
      elapsedSeconds: task['elapsedSeconds'] as int? ?? 0,
      isDone: task['status'] == 'done',
      taskData: task,
    );
    final started = await _timer.start();
    if (!started && !_timer.isCompleted && mounted) {
      showReToast(
        context,
        'شروع تایمر ناموفق بود. دوباره تلاش کنید.',
        ReToastType.failed,
      );
    }
  }

  /// A timer still running on the server (e.g. the app was closed while it
  /// ran) is picked up again instead of showing a frozen "running" row.
  void _resumeServerTimer(List<Map<String, dynamic>> timedTasks) {
    if (_timer.isRunning) return;
    for (final task in timedTasks) {
      final id = task['id'] as String?;
      final startedAt = task['timerStartedAt'] as DateTime?;
      if (id == null || startedAt == null || task['status'] == 'done') {
        continue;
      }
      _timer.resumeRunning(
        taskId: id,
        totalSeconds: task['durationSeconds'] as int? ?? 0,
        elapsedSeconds: task['elapsedSeconds'] as int? ?? 0,
        startedAt: startedAt,
        taskData: task,
      );
      return;
    }
  }

  Widget _buildTimedConnector({required bool visible, required double height}) {
    if (!visible) return SizedBox(height: height);

    const segmentHeight = 3.0;
    const segmentGap = 4.0;
    final count = math.max(1, (height / (segmentHeight + segmentGap)).floor());

    return SizedBox(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          count,
          (_) => Container(
            width: 2,
            height: segmentHeight,
            decoration: BoxDecoration(
              color: AppColors.dark4Color,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimedTaskMarker({
    required Map<String, dynamic> task,
    required bool showTopLine,
    required bool showBottomLine,
    required double height,
  }) {
    final status = _timedTaskStatus(task);
    final color = _timedTaskColor(status);

    return SizedBox(
      width: 42,
      height: height,
      child: Column(
        children: [
          _buildTimedConnector(
            visible: showTopLine,
            height: math.max(0, (height - 58) / 2),
          ),
          Container(
            width: 35,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.gray2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.12),
                  ),
                  child: Icon(
                    status == 'done' ? Icons.check : Icons.timer_outlined,
                    size: 12,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                ReText(
                  _timedTaskDurationValue(task),
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black1,
                  textAlign: TextAlign.center,
                ),
                const ReText(
                  'دقیقه',
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          _buildTimedConnector(
            visible: showBottomLine,
            height: math.max(0, (height - 58) / 2),
          ),
        ],
      ),
    );
  }

  Widget _buildTimedTaskTile(Map<String, dynamic> task, int index) {
    const titleSize = 14.0;
    const subtitleSize = 10.0;

    final status = _timedTaskStatus(task);
    final color = _timedTaskColor(status);
    final hasProgress = _timedTaskShowsProgress(task);
    final isDone = status == 'done';
    final cardHeight =
        hasProgress ? _timedCardWithProgressHeight : _timedCardHeight;

    return Opacity(
      opacity: isDone ? 0.55 : 1,
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(
            vertical: hasProgress ? _timedCardProgressMargin : 0),
        height: cardHeight,
        decoration: BoxDecoration(
          color: const Color(0xfffafafa),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.gray2),
          boxShadow: [
            BoxShadow(
              color: AppColors.black1.withOpacity(0.05),
              blurRadius: 80,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: 68,
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: hasProgress ? 10 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black1.withOpacity(0.05),
                    blurRadius: 80,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showTaskDetails(task, timed: true),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 11,
                      color: AppColors.gray,
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 6,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showTaskDetails(task, timed: true),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ReText(
                            task['title'] ?? '',
                            fontSize: titleSize,
                            fontWeight: FontWeight.w900,
                            color: AppColors.black1,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 2),
                          ReText(
                            task['subtitle'] ?? '',
                            fontSize: subtitleSize,
                            color: Color.lerp(
                              AppColors.gray,
                              Colors.transparent,
                              0.25,
                            ),
                            fontWeight: FontWeight.w600,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  status == 'done'
                      ? const SizedBox()
                      : GestureDetector(
                          // The icon shows play/pause, so the button does
                          // exactly that; the full timer is in the details.
                          onTap: () => _toggleTimedTaskTimer(index),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _timedTaskIcon(status),
                              color: AppColors.white,
                              size: status == 'done' ? 17 : 21,
                            ),
                          ),
                        ),
                ],
              ),
            ),
            if (hasProgress) ...[
              const SizedBox(height: 8),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    ReText(
                      '${_timedTaskRemainingLabel(task)}    / ',
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.black1,
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(width: 6),
                    ReText(
                      _timedTaskDurationLabel(task),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray,
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          // Live value from the timer, not the stale API
                          // snapshot, so the bar moves with the countdown.
                          value: 1 - _timedTaskRemainingProgress(task),
                          minHeight: 2,
                          backgroundColor: AppColors.gray2,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimedTaskList(BuildContext context) {
    if (_isLoadingTasks) return const _TasksShimmer();

    if (_timedTasks.isEmpty) {
      return _buildEmptyDay(context);
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 18, 14, 16),
          itemCount: _timedTasks.length,
          itemBuilder: (context, index) {
            final task = _timedTasks[index];
            final rowHeight = _timedTaskRowHeight(task);
            return SizedBox(
              height: rowHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: _buildTimedTaskTile(task, index),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _buildTimedTaskMarker(
                    task: task,
                    showTopLine: index != 0,
                    showBottomLine: index != _timedTasks.length - 1,
                    height: rowHeight,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray1,
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) => navigateToIndex(context, index, 1),
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildTitleRow(),
                  // One date picker for both modes; it stays put while the
                  // body below switches.
                  Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 20),
                    child: WeekHeader(
                      controller: _week,
                      selectedDate: _selectedDate,
                      onSelectDay: _isWeekMode ? _selectWeekDay : _selectDay,
                      onChangeWeek: _isWeekMode ? _changeWeek : _changeDayWeek,
                      onPickDate: _isWeekMode ? _pickWeekDate : _pickDay,
                      canShowWeek: _isWeekMode
                          ? (start) => isWeekWithinHorizon(start, _today)
                          : null,
                      onBlockedForward: _explainPlanningHorizon,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // The toolbar of the body below: which view it shows, and adding to
          // it. It stays put while the body changes.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                TasksViewModeToggle(mode: _mode, onChanged: _setMode),
                const Spacer(),
                _AddTaskButton(onTap: () => _openQuickAdd(_selectedDate)),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: _modeSwitchDuration,
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: _zoomTransition,
                    child: _isWeekMode
                        ? KeyedSubtree(
                            key: const ValueKey('week-body'),
                            child: _buildWeekBody(),
                          )
                        : KeyedSubtree(
                            key: const ValueKey('day-body'),
                            child: _buildDayBody(),
                          ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  // Clear of the floating timer banner when it shows.
                  bottom: _timer.shouldShowBanner ? 96 : 20,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.4),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _undo == null
                        ? const SizedBox.shrink()
                        : UndoBar(
                            key: ValueKey(_undo!.message),
                            message: _undo!.message,
                            onUndo: _undo!.onUndo,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Switching modes reads as zooming out of a day into its week, and back.
  Widget _zoomTransition(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.97, end: 1).animate(animation),
        child: child,
      ),
    );
  }

  Widget _buildTitleRow() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Row(
          children: [
            const ReText(
              'تسک‌ها',
              color: AppColors.black1,
              fontSize: 16,
              fontWeight: 1000,
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (final _) => const ChatScreen()),
              ),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(SolarIconsOutline.userSpeakRounded, size: 24),
              ),
            ),
            SizedBox(
              width: 48,
              height: 48,
              child: SvgPicture.asset('assets/icons/bell.svg').vMargin(11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekBody() {
    return WeeklyPlanView(
      key: _weekViewKey,
      controller: _week,
      onOpenTask: (task) => _showTaskDetails(task, timed: isTimedTask(task)),
      onAddToDay: _openQuickAdd,
      onMoveTasks: _moveTasks,
      onRefresh: () => _week.reload(silent: true),
    );
  }

  /// The day's time boxes, under a pill that opens its checklists, as in
  /// the week.
  Widget _buildDayBody() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: ChecklistsPill(
              key: const ValueKey('day-checklists'),
              tasks: _checklistTasks,
              height: 40,
              fontSize: 12.5,
              onTap: _openDayChecklists,
            ),
          ),
        ),
        Expanded(child: _buildTimedTaskList(context)),
      ],
    );
  }

  /// Snapshot of what the details sheet shows; recomputed on every timer tick
  /// so the countdown stays live while the sheet is open.
  _SheetTaskState _sheetTaskState(Map<String, dynamic> task,
      {required bool timed}) {
    if (!timed) {
      final isDone = task['status'] == 'done';
      return _SheetTaskState(
        isDone: isDone,
        canMove: !isDone,
        primaryText: 'انجام شد',
        progressColor: AppColors.black1,
      );
    }

    final status = _timedTaskStatus(task);
    final showsProgress = _timedTaskShowsProgress(task);
    return _SheetTaskState(
      isDone: status == 'done',
      // A started timer belongs to the day it ran on.
      canMove: status == 'pending',
      primaryText: status == 'pending' ? 'شروع' : 'ادامه',
      progress: showsProgress ? 1 - _timedTaskRemainingProgress(task) : null,
      remainingLabel: showsProgress ? _timedTaskRemainingLabel(task) : null,
      durationLabel: showsProgress ? _timedTaskDurationLabel(task) : null,
      progressColor: _timedTaskColor(status),
    );
  }

  Future<void> _showTaskDetails(Map<String, dynamic> task,
      {required bool timed}) async {
    _timer.suppressBanner();
    final _TaskSheetAction? action;
    try {
      action = await showModalBottomSheet<_TaskSheetAction>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => _TaskDetailsSheet(
          task: task,
          timed: timed,
          listenable: _timer,
          resolveState: () => _sheetTaskState(task, timed: timed),
        ),
      );
    } finally {
      _timer.unsuppressBanner();
    }

    if (!mounted || action == null) return;

    switch (action) {
      case _TaskSheetAction.primary:
        if (timed) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskTimerScreen(
                task: task,
                onPop: _reloadActiveView,
              ),
            ),
          );
        } else {
          await _setTaskDone(task, done: true);
        }
      case _TaskSheetAction.edit:
        final edited = await context.to<Map<String, dynamic>>(
          timed ? AddTimedTaskScreen(task: task) : AddTaskScreen(task: task),
        );
        if (edited == null || !mounted) return;
        showReToast(context, 'تسک با موفقیت ویرایش شد', ReToastType.success);
        await _reloadActiveView();
      case _TaskSheetAction.move:
        final day = await showMoveTaskSheet(context, task: task, today: _today);
        if (day != null && mounted) await _moveTask(task, day);
      case _TaskSheetAction.delete:
        await _requestDeleteTask(task);
    }
  }

  /// The app's calendar, starting on the selected day. Week mode passes
  /// [lastDate] so days beyond the planning horizon cannot be picked.
  Future<Jalali?> _pickDate({Jalali? lastDate}) {
    return showPlanDatePicker(
      context,
      initialDate: _selectedDate,
      today: _today,
      lastDate: lastDate,
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

class _TasksShimmer extends StatefulWidget {
  const _TasksShimmer();

  @override
  State<_TasksShimmer> createState() => _TasksShimmerState();
}

class _TasksShimmerState extends State<_TasksShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final travel = _controller.value * 3;
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
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            itemCount: 5,
            itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 78,
                      decoration: BoxDecoration(
                        color: AppColors.gray2,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.gray2,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _TaskSheetAction { primary, edit, move, delete }

/// How much of a recurring task a delete removes.
enum _RecurringDeleteScope { occurrence, series }

class _SheetTaskState {
  const _SheetTaskState({
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

class _TaskDetailsSheet extends StatelessWidget {
  const _TaskDetailsSheet({
    required this.task,
    required this.timed,
    required this.listenable,
    required this.resolveState,
  });

  final Map<String, dynamic> task;
  final bool timed;
  final Listenable listenable;
  final _SheetTaskState Function() resolveState;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) => _buildContent(context, resolveState()),
    );
  }

  Widget _buildContent(BuildContext context, _SheetTaskState state) {
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
                  onTap: () => Navigator.of(context).pop(_TaskSheetAction.move),
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
                      flex: 5,
                      child: _SheetButton(
                        text: state.primaryText,
                        icon: Icons.arrow_back_ios_new_rounded,
                        background: AppColors.secondary,
                        textColor: AppColors.white,
                        onTap: () =>
                            Navigator.of(context).pop(_TaskSheetAction.primary),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    flex: 4,
                    child: _SheetButton(
                      text: 'ویرایش',
                      icon: SolarIconsOutline.pen,
                      background: AppColors.white,
                      textColor: AppColors.black1,
                      borderColor: AppColors.gray2,
                      onTap: () =>
                          Navigator.of(context).pop(_TaskSheetAction.edit),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pop(_TaskSheetAction.delete),
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

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.text,
    required this.icon,
    required this.background,
    required this.textColor,
    required this.onTap,
    this.borderColor,
  });

  final String text;
  final IconData icon;
  final Color background;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(100),
          border: borderColor == null ? null : Border.all(color: borderColor!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: textColor),
            const Spacer(),
            ReText(
              text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// "+ افزودن" at the end of the toolbar: adds a time box or a checklist to
/// whichever view is open; quick add asks which.
class _AddTaskButton extends StatelessWidget {
  const _AddTaskButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'افزودن تسک یا چک‌لیست',
      excludeSemantics: true,
      child: PressScale(
        onTap: onTap,
        child: Container(
          key: const ValueKey('tasks-add-button'),
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.black1,
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            children: [
              Icon(Icons.add_rounded, size: 20, color: AppColors.white),
              SizedBox(width: 4),
              ReText(
                'افزودن',
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
