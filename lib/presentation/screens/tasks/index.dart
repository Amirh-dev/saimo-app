import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:simo_learn/presentation/screens/app_tabs_shell.dart';
import 'package:simo_learn/core/global/global_data.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/data/notifications/task_reminder_service.dart';
import 'package:simo_learn/features/tags/tag_suggestion_repository.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/add_task/index.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/screens/tasks/task_report_popup.dart';
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
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

/// Fades and slides a just-added row into place, once.
class _AppearIn extends StatelessWidget {
  const _AppearIn({
    super.key,
    required this.animate,
    required this.onDone,
    required this.child,
  });

  final bool animate;
  final VoidCallback onDone;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!animate || reduceMotion(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      onEnd: onDone,
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - t)),
          child: child,
        ),
      ),
    );
  }
}

class _TasksScreenState extends State<TasksScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver, AppTabRevisit {
  @override
  int get tabIndex => 1;

  @override
  void onTabRevisited() => unawaited(_reloadActiveView());

  late Jalali _selectedDate;

  /// Read on demand so "today" stays correct if the app is left open past
  /// midnight.
  Jalali get _today => Jalali.now();

  // Add Menu Animation Controllers

  List<Map<String, dynamic>> _checklistTasks = [];
  List<Map<String, dynamic>> _timedTasks = [];
  bool _isLoadingTasks = false;
  final TaskTimerService _timer = TaskTimerService.instance;
  StreamSubscription<String>? _taskWrites;
  final ScrollController _timedListController = ScrollController();

  /// Tasks created a moment ago; their rows animate in once.
  final Set<String> _justAddedIds = {};

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
  late final TagSuggestionRepository _tagSuggestions;
  late final WeeklyPlanController _week;
  final GlobalKey<WeeklyPlanViewState> _weekViewKey = GlobalKey();

  /// The days the week board shows, for the window in the folded strip.
  final ValueNotifier<VisibleDays> _visibleDays =
      ValueNotifier((first: 0, count: 2.5));
  ({String message, VoidCallback onUndo})? _undo;
  Timer? _undoTimer;

  bool get _isWeekMode => _mode == TasksViewMode.week;

  @override
  void initState() {
    super.initState();
    _selectedDate = _today;
    _tasksApi = GraphQLTasksApi(context.read<GraphQLRepository>());
    _tagSuggestions =
        TagSuggestionRepository(context.read<GraphQLRepository>());
    _week = WeeklyPlanController(_tasksApi)..addListener(_onWeekChanged);

    _timer.addListener(_onGlobalTimerChanged);
    WidgetsBinding.instance.addObserver(this);

    // A task written somewhere else (the home, a timer, another tab) while
    // this tab is out of sight: reload on the way back, however soon.
    _taskWrites = context
        .read<GraphQLRepository>()
        .completedMutations
        .where((mutation) => mutation.contains('Task'))
        .listen((_) {
      if (AppTabsShell.selectedTab.value != tabIndex) markStale();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer.bindRepository(
          TaskTimerRepository(context.read<GraphQLRepository>()));
      _loadTasksForSelectedDate();
    });
  }

  @override
  void dispose() {
    _taskWrites?.cancel();
    _undoTimer?.cancel();
    _week
      ..removeListener(_onWeekChanged)
      ..dispose();
    _timer.removeListener(_onGlobalTimerChanged);
    WidgetsBinding.instance.removeObserver(this);
    _timedListController.dispose();
    _dayChecklistsChanged.dispose();
    _visibleDays.dispose();
    super.dispose();
  }

  /// Tasks may have changed elsewhere (another device, the web) while the
  /// app was in the background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_reloadActiveView());
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
  /// Called after every change to tasks, so it also drops the day cache.
  Future<void> _reloadActiveView() {
    _clearDayCache();
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

  /// The day a week opens on: today in the current week, otherwise its
  /// first day (Saturday).
  Jalali _openingDayOf(Jalali anyDay) {
    final start = weekStartOf(anyDay);
    return isSameJalaliDay(start, weekStartOf(_today)) ? _today : start;
  }

  void _changeWeek(int weeks) {
    final target = weekStartOf(_selectedDate.addDays(7 * weeks));
    // Pulled past the board's edge toward a week the server cannot return.
    if (!isWeekWithinHorizon(target, _today)) {
      _explainPlanningHorizon();
      return;
    }
    final date = _openingDayOf(target);
    setState(() => _selectedDate = date);
    unawaited(_week.showWeekOf(date));
  }

  // ------------------------------------------------- daily mode date picker

  /// A day was picked from the week strip in daily mode.
  void _selectDay(Jalali day) {
    if (isSameJalaliDay(day, _selectedDate)) return;
    setState(() => _selectedDate = day);
    // Changing day doesn't change the week's data; its rings stay as they are.
    unawaited(_loadTasksForSelectedDate(refreshWeek: false));
  }

  /// The strip was swiped to another week in daily mode: the same weekday
  /// there is selected, so the selection keeps its place in the strip.
  void _changeDayWeek(int weeks) {
    setState(
        () => _selectedDate = _openingDayOf(_selectedDate.addDays(7 * weeks)));
    unawaited(_loadTasksForSelectedDate());
  }

  Future<void> _pickDay() async {
    final picked = await _pickDate();
    if (picked == null || !mounted) return;
    setState(() => _selectedDate = picked);
    await _loadTasksForSelectedDate();
  }

  /// Keeps the strip's progress rings current in daily mode, for the weeks
  /// the server can return. Without [force], a week already loaded is kept.
  void _syncWeekStrip({bool force = true}) {
    final start = weekStartOf(_selectedDate);
    if (!isWeekWithinHorizon(start, _today)) return;
    if (!force && _week.hasData && isSameJalaliDay(start, _week.weekStart)) {
      return;
    }
    unawaited(_week.showWeekOf(_selectedDate));
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
  /// back if it cannot be saved. Returns whether it was saved.
  Future<bool> _setTaskDone(
    Map<String, dynamic> task, {
    required bool done,
  }) async {
    if (_isWeekMode) {
      try {
        await _week.setTaskDone(task, done: done);
        _clearDayCache();
        if (!done) task['report'] = null;
        return true;
      } catch (error) {
        if (!mounted) return false;
        showReToast(
          context,
          _actionErrorMessage(
              error, 'تغییر وضعیت تسک ناموفق بود. دوباره تلاش کنید.'),
          ReToastType.failed,
        );
      }
      return false;
    }

    final id = task['id'] as String?;
    if (id == null || isTaskDone(task) == done) return false;
    if (!_pendingStatusTaskIds.add(id)) return false;
    final previous = task['status'];
    void show(Object? status) {
      if (!mounted) return;
      setState(() => task['status'] = status);
      _dayChecklistsChanged.value++;
    }

    show(done ? 'done' : 'pending');
    try {
      await _tasksApi.setTaskDone(task, done: done);
      // The server drops the report of a task that is no longer done.
      if (!done) task['report'] = null;
      // No cache change needed: the day's cached list holds this same task
      // map, which already shows the new status.
      // The strip's ring for this day.
      unawaited(_week.reload(silent: true));
      return true;
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
      return false;
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
    // Held until the sheet closes, so the new rows animate in where the
    // user can see them.
    final created = <Map<String, dynamic>>[];
    var sheetOpen = true;
    // The start-up load needs a signed-in user and may have failed; the
    // sheet reads the tags whenever it needs them, so they can land late.
    GlobalData.instance.refreshParentTags();
    await showQuickAddSheet(
      context,
      initialDay: day,
      today: _today,
      initialTimed: timed,
      suggestTags: _tagSuggestions.suggestTags,
      tagCatalog: () => GlobalData.instance.tagCatalog,
      onSubmit: (draft) async {
        try {
          final task = await _tasksApi.createQuickTask(draft);
          if (sheetOpen) {
            created.add(task);
          } else if (mounted) {
            _showCreated([task]);
          }
          return null;
        } catch (error) {
          debugPrint('Quick add failed: $error');
          return taskFailureMessage(
            error,
            fallback: 'ثبت تسک ناموفق بود؛ دوباره تلاش کنید.',
          );
        }
      },
      onMoreOptions: _openFullAddForm,
    );
    sheetOpen = false;
    if (mounted && created.isNotEmpty) _showCreated(created);
  }

  /// Puts tasks the server just created straight into the lists and the day
  /// cache. The create response has every field a fetch would (subject
  /// included), so the day is not fetched again.
  void _showCreated(List<Map<String, dynamic>> tasks) {
    var addedTimedHere = false;
    setState(() {
      for (final task in tasks) {
        final day = task['date'];
        if (day is! Jalali) continue;
        final timed = isTimedTask(task);
        if (isSameJalaliDay(day, _selectedDate)) {
          // The selected day's cache entry holds these same lists.
          (timed ? _timedTasks : _checklistTasks).add(task);
          if (task['id'] case final String id) _justAddedIds.add(id);
          addedTimedHere |= timed;
        } else {
          final cached = _dayCache[_dayKey(day)];
          (timed ? cached?.timed : cached?.checklist)?.add(task);
        }
      }
    });
    _dayChecklistsChanged.value++;
    if (addedTimedHere) _scrollToLastTimedTask();

    _week.showAdded(tasks);
    // The strip's rings and the week view, in the background.
    unawaited(_week.reload(silent: true));
  }

  void _scrollToLastTimedTask() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_timedListController.hasClients) return;
      final position = _timedListController.position;
      if (reduceMotion(context)) {
        position.jumpTo(position.maxScrollExtent);
      } else {
        position.animateTo(
          position.maxScrollExtent,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  /// "Advanced settings": the full form, filled with what quick add had.
  Future<void> _openFullAddForm(QuickTaskDraft draft) async {
    final tags = draft.tags;
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

  /// Days already loaded, keyed by [_dayKey]. A cached day is shown without
  /// asking the server again. Any change to tasks clears the whole cache
  /// ([_clearDayCache]), so only the day on screen is fetched again.
  final Map<
      String,
      ({
        List<Map<String, dynamic>> checklist,
        List<Map<String, dynamic>> timed,
      })> _dayCache = {};

  static String _dayKey(Jalali day) => '${day.year}-${day.month}-${day.day}';

  /// Clearing everything rather than the touched days: a recurring task, a
  /// move or an edited date can change days other than the one on screen.
  void _clearDayCache() => _dayCache.clear();

  Future<void> _loadTasksForSelectedDate({
    bool showLoading = true,
    bool refreshWeek = true,
  }) async {
    final cached = _dayCache[_dayKey(_selectedDate)];
    if (cached != null) {
      if (!mounted) return;
      setState(() {
        _checklistTasks = cached.checklist;
        _timedTasks = cached.timed;
        _isLoadingTasks = false;
      });
      _dayChecklistsChanged.value++;
      _resumeServerTimer(cached.timed);
      if (!_isWeekMode) _syncWeekStrip(force: refreshWeek);
      return;
    }

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

      _dayCache[_dayKey(selectedDate)] =
          (checklist: checklistTasks, timed: timedTasks);
      setState(() {
        _checklistTasks = checklistTasks;
        _timedTasks = timedTasks;
        _isLoadingTasks = false;
      });
      _dayChecklistsChanged.value++;
      _resumeServerTimer(timedTasks);
      if (!_isWeekMode) _syncWeekStrip(force: refreshWeek);
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
                      ? _ReportChip(
                          report: task['report'] as TaskReport?,
                          onTap: () => _reportTask(task, timed: true),
                        )
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
          controller: _timedListController,
          padding: const EdgeInsets.fromLTRB(16, 18, 14, 16),
          itemCount: _timedTasks.length,
          itemBuilder: (context, index) {
            final task = _timedTasks[index];
            final rowHeight = _timedTaskRowHeight(task);
            final id = task['id'] as String?;
            return _AppearIn(
              key: ValueKey('timed-row-$id'),
              animate: id != null && _justAddedIds.contains(id),
              onDone: () => _justAddedIds.remove(id),
              child: SizedBox(
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
                      // The board names each day, so the strip folds away.
                      compact: _isWeekMode,
                      visibleDays: _visibleDays,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // The toolbar of the body below: which view it shows, and adding to
          // the day, or in weekly mode (where each day has its own add
          // button) turning the week. It stays put while the body changes.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                TasksViewModeToggle(mode: _mode, onChanged: _setMode),
                const SizedBox(width: 10),
                Expanded(
                  child: Align(
                    // The row's end: the left, in this right-to-left row.
                    alignment: Alignment.centerLeft,
                    child: _ToolbarAction(
                      weekly: _isWeekMode,
                      weekLabel: weekRangeLabel(weekStartOf(_selectedDate),
                          today: _today),
                      onAdd: () => _openQuickAdd(_selectedDate),
                      onPreviousWeek: () => _changeWeek(-1),
                      onNextWeek: () => _changeWeek(1),
                    ),
                  ),
                ),
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

  Widget _buildTitleRow() => const AppTabHeader('تسک‌ها');

  Widget _buildWeekBody() {
    return WeeklyPlanView(
      key: _weekViewKey,
      controller: _week,
      onOpenTask: (task) => _showTaskDetails(task, timed: isTimedTask(task)),
      onAddToDay: _openQuickAdd,
      onMoveTasks: _moveTasks,
      onRefresh: () => _week.reload(silent: true),
      onChangeWeek: _changeWeek,
      visibleDays: _visibleDays,
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
    // The banner hides itself while this sheet is open
    // (TaskTimerBannerRouteObserver).
    final action = await showModalBottomSheet<_TaskSheetAction>(
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
        } else if (await _setTaskDone(task, done: true) && mounted) {
          // Just finished: the moment to ask how it went.
          await _reportTask(task, timed: false, justCompleted: true);
        }
      case _TaskSheetAction.edit:
        final edited = await context.to<Map<String, dynamic>>(
          timed ? AddTimedTaskScreen(task: task) : AddTaskScreen(task: task),
        );
        if (edited == null || !mounted) return;
        showReToast(context, 'تسک با موفقیت ویرایش شد', ReToastType.success);
        await _reloadActiveView();
      case _TaskSheetAction.report:
        await _reportTask(task, timed: timed);
      case _TaskSheetAction.move:
        final day = await showMoveTaskSheet(context, task: task, today: _today);
        if (day != null && mounted) await _moveTask(task, day);
      case _TaskSheetAction.delete:
        await _requestDeleteTask(task);
    }
  }

  /// Opens the report popup for [task]. The server keeps reports only for
  /// completed tasks, so reporting an unfinished one completes it first.
  Future<void> _reportTask(Map<String, dynamic> task,
      {required bool timed, bool justCompleted = false}) async {
    var completed = justCompleted || _sheetTaskState(task, timed: timed).isDone;
    // A timed task ends only when its timer runs out; never finish it here.
    if (timed && !completed) return;
    final finishesTask = !completed;
    final saved = await showTaskReportPopup(
      context,
      initial: task['report'] as TaskReport?,
      finishesTask: finishesTask,
      onSubmit: (report) async {
        if (!completed) {
          await _tasksApi.setTaskDone(task, done: true);
          completed = true;
        }
        await _tasksApi.saveReport(task, report);
      },
    );

    if (!mounted) return;
    if (saved != null) {
      task['report'] = saved;
      showReToast(context, 'گزارش تسک ثبت شد', ReToastType.success);
    }
    // Completing the task changes the day's lists and rings, even when the
    // report itself was then skipped or failed.
    if (saved != null || (finishesTask && completed)) {
      await _reloadActiveView();
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

enum _TaskSheetAction { primary, report, edit, move, delete }

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
                      flex: 1,
                      child: _SheetButton(
                        text: state.primaryText,
                        icon: Icons.arrow_back_ios_new_rounded,
                        background: AppColors.secondary,
                        textColor: AppColors.white,
                        onTap: () =>
                            Navigator.of(context).pop(_TaskSheetAction.primary),
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
                            Navigator.of(context).pop(_TaskSheetAction.report),
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

/// On a finished task card: its result (accuracy when a test was taken,
/// otherwise the self-rating), or a shortcut to report when there is none.
class _ReportChip extends StatelessWidget {
  const _ReportChip({required this.report, required this.onTap});

  final TaskReport? report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final report = this.report;
    final String label;
    final IconData icon;
    if (report == null) {
      label = 'گزارش';
      icon = Icons.add_rounded;
    } else if (report.tookTest && report.totalQuestions! > 0) {
      label = formatPercent(report.correctAnswers! / report.totalQuestions!);
      icon = Icons.check_rounded;
    } else {
      label = convertToPersianNumbers('${report.rating}');
      icon = Icons.star_rounded;
    }

    return Semantics(
      button: true,
      label: report == null ? 'ثبت گزارش' : 'گزارش تسک',
      excludeSemantics: true,
      child: GestureDetector(
        key: ValueKey('task-report-chip-${report == null ? 'add' : 'done'}'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: report == null ? AppColors.white : AppColors.gray1,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.gray2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.ltr,
            children: [
              Icon(icon, size: 15, color: AppColors.black1),
              const SizedBox(width: 3),
              ReText(
                label,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.black1,
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

/// The white pill at the end of the toolbar. In daily mode it adds to the
/// day ("ثبت تسک +"; quick add asks for a time box or a checklist). In
/// weekly mode, where every day has its own add button, the same pill turns
/// into the week switcher: the week's range between previous and next.
class _ToolbarAction extends StatefulWidget {
  const _ToolbarAction({
    required this.weekly,
    required this.weekLabel,
    required this.onAdd,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  final bool weekly;
  final String weekLabel;
  final VoidCallback onAdd;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  @override
  State<_ToolbarAction> createState() => _ToolbarActionState();
}

enum _PillPart { pill, add, week }

/// One motion, run forward into weekly mode and backward out of it: the
/// pill eases between the widths of its two contents while the add label
/// rolls up and out over the first half and the week switcher rolls up
/// into place over the second, overlapping a little. Width, slides and
/// fades all read the same controller, so they never drift apart, and none
/// of it rebuilds or lays out the contents again.
class _ToolbarActionState extends State<_ToolbarAction>
    with SingleTickerProviderStateMixin {
  static const double _height = 44;

  late final AnimationController _morph = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 560),
    value: widget.weekly ? 1 : 0,
  )..addStatusListener((_) => setState(() {}));

  /// The two contents' natural widths, measured as they are laid out.
  final _PillWidths _widths = _PillWidths();

  static final Animatable<double> _addFade = Tween<double>(begin: 1, end: 0)
      .chain(CurveTween(curve: const Interval(0, 0.4, curve: Curves.easeIn)));
  static final Animatable<Offset> _addRoll = Tween<Offset>(
          begin: Offset.zero, end: const Offset(0, -0.55))
      .chain(CurveTween(curve: const Interval(0, 0.55, curve: Curves.easeIn)));
  static final Animatable<double> _weekFade = Tween<double>(begin: 0, end: 1)
      .chain(
          CurveTween(curve: const Interval(0.3, 0.9, curve: Curves.easeOut)));
  static final Animatable<Offset> _weekRoll =
      Tween<Offset>(begin: const Offset(0, 0.55), end: Offset.zero).chain(
          CurveTween(
              curve: const Interval(0.25, 1, curve: Curves.easeOutCubic)));

  @override
  void didUpdateWidget(covariant _ToolbarAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weekly == widget.weekly) return;
    if (reduceMotion(context)) {
      _morph.value = widget.weekly ? 1 : 0;
    } else if (widget.weekly) {
      _morph.forward();
    } else {
      _morph.reverse();
    }
  }

  @override
  void dispose() {
    _morph.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A side is built only while it shows, and takes taps only once it is
    // the one arriving.
    final showAdd = _morph.value < 1;
    final showWeek = _morph.value > 0;
    return ClipRRect(
      clipper: _PillClipper(morph: _morph, widths: _widths, height: _height),
      child: CustomMultiChildLayout(
        delegate: _PillLayout(morph: _morph, widths: _widths, height: _height),
        children: [
          LayoutId(
            id: _PillPart.pill,
            child: const ColoredBox(color: AppColors.white),
          ),
          if (showAdd)
            LayoutId(
              id: _PillPart.add,
              child: IgnorePointer(
                ignoring: widget.weekly,
                child: FadeTransition(
                  opacity: _morph.drive(_addFade),
                  child: SlideTransition(
                    position: _morph.drive(_addRoll),
                    child: _AddLabel(onTap: widget.onAdd),
                  ),
                ),
              ),
            ),
          if (showWeek)
            LayoutId(
              id: _PillPart.week,
              child: IgnorePointer(
                ignoring: !widget.weekly,
                child: FadeTransition(
                  opacity: _morph.drive(_weekFade),
                  child: SlideTransition(
                    position: _morph.drive(_weekRoll),
                    child: _WeekSwitcher(
                      label: widget.weekLabel,
                      onPrevious: widget.onPreviousWeek,
                      onNext: widget.onNextWeek,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PillWidths {
  double add = 0;
  double week = 0;

  /// The pill's width at [morph] (0 adding, 1 switching weeks).
  double at(double morph) =>
      lerpDouble(add, week, Curves.easeInOutCubic.transform(morph))!;
}

/// Lays the pill out at the start (the left) of the space it is given, as
/// wide as [_PillWidths.at] says, with whichever contents show centred in
/// it. Relayout per frame touches only the pill; the contents keep their
/// constraints and are not laid out again.
class _PillLayout extends MultiChildLayoutDelegate {
  _PillLayout({
    required this.morph,
    required this.widths,
    required this.height,
  }) : super(relayout: morph);

  final Animation<double> morph;
  final _PillWidths widths;
  final double height;

  @override
  Size getSize(BoxConstraints constraints) =>
      Size(constraints.maxWidth, height);

  @override
  void performLayout(Size size) {
    final loose = BoxConstraints(maxWidth: size.width, maxHeight: height);
    Size? add, week;
    if (hasChild(_PillPart.add)) add = layoutChild(_PillPart.add, loose);
    if (hasChild(_PillPart.week)) week = layoutChild(_PillPart.week, loose);
    widths
      ..add = add?.width ?? week?.width ?? widths.add
      ..week = week?.width ?? add?.width ?? widths.week;

    final width = widths.at(morph.value).clamp(0.0, size.width);
    layoutChild(_PillPart.pill, BoxConstraints.tight(Size(width, height)));
    positionChild(_PillPart.pill, Offset.zero);
    for (final (id, child) in [(_PillPart.add, add), (_PillPart.week, week)]) {
      if (child == null) continue;
      positionChild(
        id,
        Offset((width - child.width) / 2, (height - child.height) / 2),
      );
    }
  }

  @override
  bool shouldRelayout(_PillLayout oldDelegate) =>
      oldDelegate.morph != morph || oldDelegate.widths != widths;
}

/// Rounds the pill and keeps the contents inside it while it changes width.
class _PillClipper extends CustomClipper<RRect> {
  _PillClipper({
    required this.morph,
    required this.widths,
    required this.height,
  }) : super(reclip: morph);

  final Animation<double> morph;
  final _PillWidths widths;
  final double height;

  @override
  RRect getClip(Size size) => RRect.fromLTRBR(
        0,
        0,
        widths.at(morph.value).clamp(0.0, size.width),
        height,
        Radius.circular(height / 2),
      );

  @override
  bool shouldReclip(_PillClipper oldClipper) =>
      oldClipper.morph != morph || oldClipper.widths != widths;
}

class _AddLabel extends StatelessWidget {
  const _AddLabel({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'ثبت تسک یا چک‌لیست',
      excludeSemantics: true,
      child: PressScale(
        onTap: onTap,
        child: const Padding(
          key: ValueKey('tasks-add-button'),
          padding: EdgeInsets.symmetric(horizontal: 18),
          // The label first, the plus after it on the left.
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            children: [
              ReText(
                'ثبت تسک',
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.black1,
              ),
              SizedBox(width: 10),
              Icon(Icons.add_rounded, size: 22, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// "‹ ۲۵ مهر تا ۱ آبان ›": the previous week on the right, the next on the
/// left, as the days run.
class _WeekSwitcher extends StatelessWidget {
  const _WeekSwitcher({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('week-nav'),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          _WeekArrow(
            key: const ValueKey('week-nav-previous'),
            label: 'هفته قبل',
            icon: Icons.chevron_right_rounded,
            onTap: onPrevious,
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: ReText(
                    label,
                    key: ValueKey(label),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black1,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ),
          _WeekArrow(
            key: const ValueKey('week-nav-next'),
            label: 'هفته بعد',
            icon: Icons.chevron_left_rounded,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _WeekArrow extends StatelessWidget {
  const _WeekArrow({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: PressScale(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.gray1,
            shape: BoxShape.circle,
          ),
          // Unmirrored: each arrow points out to the side its week lies on.
          child: Icon(
            icon,
            size: 20,
            color: AppColors.black1,
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}
