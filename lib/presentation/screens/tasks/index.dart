import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ferry/ferry.dart' show FetchPolicy;
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/data/notifications/task_reminder_service.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/delete_task.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/update_task.req.gql.dart';
import 'package:simo_learn/graphql/queries/__generated__/get_tasks.data.gql.dart';
import 'package:simo_learn/graphql/queries/__generated__/get_tasks.req.gql.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/chat/index.dart';
import 'package:simo_learn/presentation/screens/tasks/add_task/index.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_screen.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_header.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with TickerProviderStateMixin {
  late final Jalali _today;
  late Jalali _selectedDate;
  late AnimationController _animationController;
  late AnimationController _slideAnimationController;

  // Add Menu Animation Controllers
  bool _isAddMenuOpen = false;
  late AnimationController _menuAnimationController;
  late Animation<double> _menuScaleAnimation;
  late Animation<double> _menuOpacityAnimation;

  List<Map<String, dynamic>> _checklistTasks = [];
  List<Map<String, dynamic>> _timedTasks = [];
  bool _isLoadingTasks = false;
  final TaskTimerService _timer = TaskTimerService.instance;
  late ScrollController _checklistDotsScrollController;
  late ScrollController _checklistCardsScrollController;
  int? _expandedChecklistTaskIndex;
  int? _expandedTimedTaskIndex;
  bool _isSyncingChecklistScroll = false;
  static const double _checklistItemCollapsedHeight = 90.0;
  static const double _checklistItemExpandedHeight = 140.0;
  static const Duration _taskExpansionDuration = Duration(milliseconds: 260);

  final List<String> _persianMonths = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  @override
  void initState() {
    super.initState();
    _today = Jalali.now();
    _selectedDate = _today;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animationController.value = 1.0;
    _slideAnimationController.value = 1.0;

    _menuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _menuScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
          parent: _menuAnimationController, curve: Curves.easeOutCubic),
    );
    _menuOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _menuAnimationController, curve: Curves.easeOut),
    );

    _checklistDotsScrollController = ScrollController();
    _checklistCardsScrollController = ScrollController();

    _checklistDotsScrollController.addListener(() {
      if (_isSyncingChecklistScroll) return;
      if (!_checklistCardsScrollController.hasClients) return;
      _isSyncingChecklistScroll = true;
      final offset = _checklistDotsScrollController.offset;
      _checklistCardsScrollController.jumpTo(
        offset.clamp(
          _checklistCardsScrollController.position.minScrollExtent,
          _checklistCardsScrollController.position.maxScrollExtent,
        ),
      );
      _isSyncingChecklistScroll = false;
    });

    _checklistCardsScrollController.addListener(() {
      if (_isSyncingChecklistScroll) return;
      if (!_checklistDotsScrollController.hasClients) return;
      _isSyncingChecklistScroll = true;
      final offset = _checklistCardsScrollController.offset;
      _checklistDotsScrollController.jumpTo(
        offset.clamp(
          _checklistDotsScrollController.position.minScrollExtent,
          _checklistDotsScrollController.position.maxScrollExtent,
        ),
      );
      _isSyncingChecklistScroll = false;
    });

    _timer.addListener(_onGlobalTimerChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer.bindRepository(
          TaskTimerRepository(context.read<GraphQLRepository>()));
      _loadTasksForSelectedDate();
    });
  }

  @override
  void dispose() {
    _timer.removeListener(_onGlobalTimerChanged);
    _checklistDotsScrollController.dispose();
    _checklistCardsScrollController.dispose();
    _animationController.dispose();
    _slideAnimationController.dispose();
    _menuAnimationController.dispose();
    super.dispose();
  }

  void _toggleAddMenu() {
    setState(() {
      _isAddMenuOpen = !_isAddMenuOpen;
      if (_isAddMenuOpen) {
        _menuAnimationController.forward();
      } else {
        _menuAnimationController.reverse();
      }
    });
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 204,
        height: 56,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: AppColors.black1.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.add, size: 16, color: AppColors.gray),
            Row(
              children: [
                ReText(
                  title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black1,
                ),
                const SizedBox(width: 10),
                Icon(icon, size: 16, color: AppColors.black1),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Jalali> get _weekDaysList {
    return List.generate(17, (index) => _today.addDays(index - 3));
  }

  bool _isSameDay(Jalali a, Jalali b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Jalali? _jalaliFromIso(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return null;
    return Jalali.fromDateTime(parsed.toLocal());
  }

  String _timeFromIso(String value) {
    final parsed = DateTime.tryParse(value)?.toLocal();
    if (parsed == null) return '';
    final formatted =
        '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
    return convertToPersianNumbers(formatted);
  }

  String _taskStatus(GTaskStatus status) {
    return switch (status) {
      GTaskStatus.COMPLETED => 'done',
      GTaskStatus.IN_PROGRESS => 'running',
      GTaskStatus.CANCELED => 'done',
      GTaskStatus.PAUSED => 'paused',
      _ => 'pending',
    };
  }

  String _taskSubtitle(GGetTasksData_getTasks task) {
    final description = task.shortDescription?.trim();
    if (description != null && description.isNotEmpty) return description;

    final note = task.note?.trim();
    if (note != null && note.isNotEmpty) return note;

    final tags = task.tags?.map((tag) => tag.name).join('، ').trim();
    if (tags != null && tags.isNotEmpty) return tags;

    return 'توضیحی ثبت نشده';
  }

  Map<String, dynamic> _checklistTaskFromApi(GGetTasksData_getTasks task) {
    return {
      'id': task.id,
      'title': task.title,
      'subtitle': _taskSubtitle(task),
      'time': _timeFromIso(task.date.value),
      'status': _taskStatus(task.status),
      'date': _jalaliFromIso(task.date.value),
      'goalId': task.goal?.id,
      'goalTitle': task.goal?.title,
      'reminder': task.hasReminder,
      'note': task.note,
      'shortDescription': task.shortDescription,
      'tags': task.tags?.map((tag) => tag.name).toList() ?? <String>[],
      'recurringDays': task.recurringDays,
      'dateTime': DateTime.tryParse(task.date.value)?.toLocal(),
    };
  }

  Map<String, dynamic> _timedTaskFromApi(GGetTasksData_getTasks task) {
    final minutes = task.durationM ?? 45;
    final durationSeconds = minutes * 60;
    final status = _taskStatus(task.status);

    return {
      'id': task.id,
      'title': task.title,
      'subtitle': _taskSubtitle(task),
      'duration': _formatTimedTaskSeconds(durationSeconds),
      'durationSeconds': durationSeconds,
      'remainingSeconds': durationSeconds - task.elapsedSeconds,
      'status': status,
      'label': '${convertToPersianNumbers(minutes.toString())} دقیقه',
      'date': _jalaliFromIso(task.date.value),
      'goalId': task.goal?.id,
      'goalTitle': task.goal?.title,
      'reminder': task.hasReminder,
      'note': task.note,
      'elapsedSeconds': task.elapsedSeconds,
      'shortDescription': task.shortDescription,
      'tags': task.tags?.map((tag) => tag.name).toList() ?? <String>[],
      'recurringDays': task.recurringDays,
      'dateTime': DateTime.tryParse(task.date.value)?.toLocal(),
    };
  }

  Future<void> _loadTasksForSelectedDate({bool showLoading = true}) async {
    if (showLoading && mounted) setState(() => _isLoadingTasks = true);
    try {
      final selectedDate = _selectedDate;
      final response = await context.read<GraphQLRepository>().requestOnce(
            GGetTasksReq(
              (request) => request.vars
                ..limit = 100
                ..offset = 0,
            ).rebuild(
              (request) => request.fetchPolicy = FetchPolicy.NetworkOnly,
            ),
          );

      if (!mounted || !_isSameDay(selectedDate, _selectedDate)) return;
      if (response.hasErrors || response.data == null) {
        setState(() => _isLoadingTasks = false);
        showReToast(
          context,
          graphQLResponseErrorMessage(response),
          ReToastType.failed,
        );
        return;
      }

      final checklistTasks = <Map<String, dynamic>>[];
      final timedTasks = <Map<String, dynamic>>[];
      for (final task in response.data!.getTasks) {
        // Safety net: a finished task must never keep a pending reminder.
        if (task.status == GTaskStatus.COMPLETED ||
            task.status == GTaskStatus.CANCELED) {
          unawaited(TaskReminderService.instance.cancel(task.id));
        }

        final taskDate = _jalaliFromIso(task.date.value);
        if (taskDate == null || !_isSameDay(taskDate, selectedDate)) {
          continue;
        }

        if (task.type == GTaskType.TIMED) {
          timedTasks.add(_timedTaskFromApi(task));
        } else {
          checklistTasks.add(_checklistTaskFromApi(task));
        }
      }

      setState(() {
        _checklistTasks = checklistTasks;
        _timedTasks = timedTasks;
        _expandedChecklistTaskIndex = null;
        _expandedTimedTaskIndex = null;
        _isLoadingTasks = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoadingTasks = false);
      showReToast(context, error.toString(), ReToastType.failed);
    }
  }

  Future<void> _completeChecklistTask(int index) async {
    if (index < 0 || index >= _checklistTasks.length) return;

    final task = _checklistTasks[index];
    final taskId = task['id'] as String?;

    if (taskId == null || taskId.isEmpty) {
      showReToast(context, 'شناسه تسک پیدا نشد', ReToastType.failed);
      return;
    }

    if (task['status'] == 'done') return;

    try {
      final response = await context.read<GraphQLRepository>().requestOnce(
        GUpdateTaskReq(
          (request) {
            request.vars.id = taskId;
            request.vars.input.status = GTaskStatus.COMPLETED;
          },
        ),
      );

      if (!mounted) return;

      if (response.hasErrors || response.data?.updateTask == null) {
        showReToast(
            context, graphQLResponseErrorMessage(response), ReToastType.failed);
        return;
      }

      await TaskReminderService.instance.cancel(taskId);
      if (!mounted) return;

      setState(() {
        task['previousStatus'] = task['status'] ?? 'pending';
        task['status'] = 'done';
      });
    } catch (error) {
      if (!mounted) return;
      showReToast(context, error.toString(), ReToastType.failed);
    }
  }

  /// Deletes the task on the server. Returns whether it was deleted.
  Future<bool> _deleteTaskById(String? taskId) async {
    if (taskId == null || taskId.isEmpty) {
      showReToast(context, 'شناسه تسک پیدا نشد', ReToastType.failed);
      return false;
    }

    try {
      final response = await context.read<GraphQLRepository>().requestOnce(
        GDeleteTaskReq(
          (request) {
            request.vars.id = taskId;
          },
        ),
      );

      if (!mounted) return false;

      if (response.hasErrors) {
        showReToast(
            context, graphQLResponseErrorMessage(response), ReToastType.failed);
        return false;
      }

      await TaskReminderService.instance.cancel(taskId);
      if (!mounted) return false;

      showReToast(context, 'تسک حذف شد', ReToastType.success);
      return true;
    } catch (error) {
      if (!mounted) return false;
      showReToast(context, error.toString(), ReToastType.failed);
      return false;
    }
  }

  Future<void> _deleteTask(int index) async {
    if (index < 0 || index >= _checklistTasks.length) return;

    final deleted =
        await _deleteTaskById(_checklistTasks[index]['id'] as String?);
    if (!deleted || !mounted) return;

    setState(() {
      _checklistTasks.removeAt(index);
    });
  }

  Future<void> _addTaskToToday(int index) async {
    if (index < 0 || index >= _checklistTasks.length) return;

    final task = _checklistTasks[index];
    final taskId = task['id'] as String?;

    if (taskId == null || taskId.isEmpty) {
      showReToast(context, 'شناسه تسک پیدا نشد', ReToastType.failed);
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentDateValue = task['date'];

    if (currentDateValue != null) {
      final currentDate = DateTime.tryParse(currentDateValue.toString());
      if (currentDate != null) {
        final taskDay = DateTime(currentDate.toLocal().year,
            currentDate.toLocal().month, currentDate.toLocal().day);
        if (taskDay == today) {
          showReToast(context, 'این تسک برای امروز است', ReToastType.info);
          return;
        }
      }
    }

    try {
      final response = await context.read<GraphQLRepository>().requestOnce(
        GUpdateTaskReq(
          (request) {
            request.vars.id = taskId;
            final todayRfc3339 = today.toUtc().toIso8601String();
            request.vars.input.date.value = todayRfc3339;
          },
        ),
      );

      if (!mounted) return;

      if (response.hasErrors || response.data?.updateTask == null) {
        showReToast(
            context, graphQLResponseErrorMessage(response), ReToastType.failed);
        return;
      }

      setState(() {
        task['date'] = today.toIso8601String();
      });

      showReToast(context, 'تسک به امروز اضافه شد', ReToastType.success);
    } catch (error) {
      if (!mounted) return;
      showReToast(context, error.toString(), ReToastType.failed);
    }
  }

  double _checklistRowHeightAt(int index) {
    return _expandedChecklistTaskIndex == index
        ? _checklistItemExpandedHeight
        : _checklistItemCollapsedHeight;
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

  void _toggleChecklistTaskStatus(int index) {
    if (index < 0 || index >= _checklistTasks.length) return;

    setState(() {
      final task = _checklistTasks[index];
      final status = task['status'] as String?;
      if (status == 'done') {
        task['status'] = task['previousStatus'] ?? 'pending';
        return;
      }

      task['previousStatus'] = status ?? 'pending';
      task['status'] = 'done';
    });
  }

  void _toggleChecklistTaskActions(int index) {
    setState(() {
      _expandedChecklistTaskIndex =
          _expandedChecklistTaskIndex == index ? null : index;
    });
  }

  void _toggleTimedTaskActions(int index) {
    setState(() {
      _expandedTimedTaskIndex = _expandedTimedTaskIndex == index ? null : index;
    });
  }

  Future<bool> _confirmDeleteTask(Future<void> Function() onDelete) async {
    final result = await showModalBottomSheet<bool>(
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
                const ReText(
                  'تسک موردنظر حذف شود؟',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const ReText(
                  'درصورت تایید، روی دکمه حذف کلیک کنید.',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    Expanded(
                      child: _ActionSheetButton(
                        text: 'حذف',
                        background: AppColors.errorColor,
                        textColor: AppColors.white,
                        onTap: () async {
                          await onDelete();
                          if (!context.mounted) return;
                          Navigator.of(context).pop(false);
                          unawaited(
                              _loadTasksForSelectedDate(showLoading: false));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionSheetButton(
                        text: 'لغو',
                        background: AppColors.white,
                        textColor: AppColors.black1,
                        borderColor: AppColors.gray2,
                        onTap: () => Navigator.of(context).pop(false),
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
    return result ?? false;
  }

  Future<void> _requestDeleteChecklistTask(int index) async {
    if (index < 0 || index >= _checklistTasks.length) return;
    final confirmed = await _confirmDeleteTask(() => _deleteTask(index));
    if (!confirmed || !mounted) return;
    _deleteChecklistTask(index);
  }

  void _deleteTimedTask(int index) {
    if (index < 0 || index >= _timedTasks.length) return;

    setState(() {
      _timedTasks.removeAt(index);
      if (_expandedTimedTaskIndex == index) {
        _expandedTimedTaskIndex = null;
      } else if (_expandedTimedTaskIndex != null &&
          _expandedTimedTaskIndex! > index) {
        _expandedTimedTaskIndex = _expandedTimedTaskIndex! - 1;
      }
    });
  }

  Future<void> _requestDeleteTimedTask(int index) async {
    if (index < 0 || index >= _timedTasks.length) return;
    final confirmed =
        await _confirmDeleteTask(() async => _deleteTimedTask(index));
    if (!confirmed || !mounted) return;
    _deleteTimedTask(index);
  }

  void _deleteChecklistTask(int index) {
    if (index < 0 || index >= _checklistTasks.length) return;

    setState(() {
      _checklistTasks.removeAt(index);

      if (_expandedChecklistTaskIndex == index) {
        _expandedChecklistTaskIndex = null;
      } else if (_expandedChecklistTaskIndex != null &&
          _expandedChecklistTaskIndex! > index) {
        _expandedChecklistTaskIndex = _expandedChecklistTaskIndex! - 1;
      }
    });
  }

  void _addChecklistTaskToToday(int index) {
    if (index < 0 || index >= _checklistTasks.length) return;

    setState(() {
      final task = Map<String, dynamic>.from(_checklistTasks.removeAt(index));
      final now = DateTime.now();

      task['status'] = 'pending';
      task['date'] = Jalali.now();
      task['time'] =
          '${convertToPersianNumbers(now.hour.toString().padLeft(2, '0'))}:${convertToPersianNumbers(now.minute.toString().padLeft(2, '0'))}';

      _checklistTasks.insert(0, task);
      _expandedChecklistTaskIndex = 0;
    });

    if (_checklistCardsScrollController.hasClients) {
      _checklistCardsScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
    if (_checklistDotsScrollController.hasClients) {
      _checklistDotsScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Widget _buildTaskTile(
      BuildContext context, Map<String, dynamic> task, int index) {
    const padding = 16.0;
    const titleSize = 14.0;
    const subtitleSize = 10.0;

    final isDone = task['status'] == 'done';
    final opacity = isDone ? 0.5 : 1.0;
    final isExpanded = _expandedChecklistTaskIndex == index;

    return Opacity(
      opacity: opacity,
      child: AnimatedContainer(
        duration: _taskExpansionDuration,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(isExpanded ? 36 : 100),
          border: Border.all(color: AppColors.gray2),
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(padding),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showTaskDetails(task, timed: false),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => _toggleChecklistTaskActions(index),
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 12),
                                child: AnimatedRotation(
                                  duration: _taskExpansionDuration,
                                  curve: Curves.easeOutCubic,
                                  turns: isExpanded ? -0.25 : 0,
                                  child: const Icon(
                                    Icons.arrow_back_ios,
                                    size: 12,
                                    color: AppColors.black1,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ReText(
                                  task['title'] ?? '',
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.black1,
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
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ClipRect(
                  child: AnimatedAlign(
                    duration: _taskExpansionDuration,
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    heightFactor: isExpanded ? 1 : 0,
                    child: AnimatedOpacity(
                      duration: _taskExpansionDuration,
                      curve: Curves.easeOutCubic,
                      opacity: isExpanded ? 1 : 0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: _TaskItemActionButton(
                                text: 'افزودن به امروز',
                                disable: DateTime.now().year ==
                                        task['date'].toDateTime().year &&
                                    DateTime.now().month ==
                                        task['date'].toDateTime().month &&
                                    DateTime.now().day ==
                                        task['date'].toDateTime().day,
                                textColor: AppColors.primary,
                                background: const Color(0xFFFBEAE5),
                                icon: Icons.add,
                                iconColor: AppColors.primary,
                                onTap: () async {
                                  await _addTaskToToday(index);
                                  unawaited(_loadTasksForSelectedDate(
                                      showLoading: false));
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _TaskItemActionButton(
                                text: 'حذف تسک',
                                textColor: AppColors.black1,
                                background: AppColors.white,
                                borderColor: AppColors.gray2,
                                icon: SolarIconsOutline.trashBinMinimalistic,
                                iconColor: AppColors.dark5Color,
                                onTap: () => _requestDeleteChecklistTask(index),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(
      BuildContext context, List<Map<String, dynamic>> tasks, bool isTimeTask) {
    if (_isLoadingTasks) return const _TasksShimmer();

    if (tasks.isEmpty) {
      return ReEmptyList(
        title: '${!isTimeTask ? 'چک لیستی' : '‌تسک زمان‌داری'} ندارید!',
        subtitle: 'برای امروز تسکی اضافه نکردید.',
        onTap: () {
          if (isTimeTask) {
            _openAddTimedTaskScreen();
            return;
          }
          _openAddTaskScreen();
        },
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _checklistCardsScrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: tasks.length,
                  itemBuilder: (_, index) => AnimatedContainer(
                    duration: _taskExpansionDuration,
                    curve: Curves.easeOutCubic,
                    height: _checklistRowHeightAt(index),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _buildTaskTile(
                      context,
                      tasks[index],
                      index,
                    ).lMargin(12),
                  ),
                ),
              ),
              SizedBox(
                width: 50,
                child: ListView.builder(
                  controller: _checklistDotsScrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: tasks.length,
                  itemBuilder: (_, index) {
                    final task = tasks[index];
                    return AnimatedContainer(
                      duration: _taskExpansionDuration,
                      curve: Curves.easeOutCubic,
                      height: _checklistRowHeightAt(index),
                      child: ReTimelineDot(
                        showTopLine: index != 0,
                        showBottomLine: index != tasks.length - 1,
                        isDone: task['status'] == 'done',
                        height: _checklistRowHeightAt(index),
                        onTap: () => _completeChecklistTask(index),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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

  IconData _timedTaskMarkerIcon(String status) {
    switch (status) {
      case 'running':
        return Icons.pause_rounded;
      case 'done':
        return CupertinoIcons.checkmark_alt;
      default:
        return Icons.timer_outlined;
    }
  }

  String _timedTaskDurationValue(Map<String, dynamic> task) {
    return (task['label']?.toString() ?? '').replaceAll('دقیقه', '').trim();
  }

  bool _timedTaskShowsProgress(Map<String, dynamic> task) {
    final status = _timedTaskStatus(task);
    return status == 'running' || status == 'paused';
  }

  double _timedTaskRowHeight(Map<String, dynamic> task, int index) {
    final base = _timedTaskShowsProgress(task) ? 98.0 : 74.0;
    final isExpanded = _expandedTimedTaskIndex == index;
    return isExpanded ? base + 66.0 : base;
  }

  double _timedTaskRemainingProgress(Map<String, dynamic> task) {
    final duration = task['durationSeconds'] as int? ?? 1;
    final remaining = _timedTaskRemainingSeconds(task);
    return (remaining / duration).clamp(0.0, 1.0);
  }

  String _formatTimedTaskSeconds(int seconds) {
    final safeSeconds = math.max(0, seconds);
    final minutes = safeSeconds ~/ 60;
    final remainingSeconds = safeSeconds % 60;
    final formatted =
        '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    return convertToPersianNumbers(formatted);
  }

  String _timedTaskRemainingLabel(Map<String, dynamic> task) {
    return _formatTimedTaskSeconds(_timedTaskRemainingSeconds(task));
  }

  String _timedTaskDurationLabel(Map<String, dynamic> task) {
    return _formatTimedTaskSeconds(task['durationSeconds'] as int? ?? 0);
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
    await _timer.start();
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
    final isExpanded = _expandedTimedTaskIndex == index;
    final cardHeight = (hasProgress ? 120.0 : 70.0) + (isExpanded ? 58 : 0);

    return Opacity(
      opacity: isDone ? 0.55 : 1,
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(vertical: hasProgress ? 8 : 0),
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
                    child: AnimatedRotation(
                      duration: _taskExpansionDuration,
                      curve: Curves.easeOutCubic,
                      turns: isExpanded ? -0.25 : 0,
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 11,
                        color: AppColors.gray,
                      ),
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
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  status == 'done'
                      ? const SizedBox()
                      : GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (final _) => TaskTimerScreen(
                                  task: task,
                                  onPop: () {
                                    _loadTasksForSelectedDate(
                                        showLoading: false);
                                  }),
                            ),
                          ),
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
                          value: (task['durationSeconds'] -
                                  task['remainingSeconds']) /
                              task['durationSeconds'],
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
      return _buildTaskList(context, const [], true);
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
            final rowHeight = _timedTaskRowHeight(task, index);
            return SizedBox(
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
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
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
                    reAppHeader(
                      'تسک ها',
                      firstIcon: GestureDetector(
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(SolarIconsOutline.bell, size: 24),
                        ),
                      ),
                      secondIcon: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (final _) => const ChatScreen())),
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child:
                              Icon(SolarIconsOutline.chatRoundLine, size: 24),
                        ),
                      ),
                    ),
                    calenderWidget(),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Main Scrollable and Tabbable Layout
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _toggleAddMenu,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: _isAddMenuOpen
                                    ? AppColors.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _isAddMenuOpen
                                      ? AppColors.primary
                                      : AppColors.gray2,
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 18,
                                    color: _isAddMenuOpen
                                        ? AppColors.white
                                        : AppColors.primary,
                                  ).rMargin(6),
                                  ReText(
                                    'افزودن تسک',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: _isAddMenuOpen
                                        ? AppColors.white
                                        : AppColors.black1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const ReText(
                            'تسک های امروز',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.black1,
                          ),
                        ],
                      ).hMargin(32).tMargin(16),
                      const SizedBox(height: 16),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.gray2,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TabBar(
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          labelColor: AppColors.black1,
                          unselectedLabelColor: AppColors.gray,
                          labelStyle: TextStyle(
                            fontFamily: AppFonts.iranSansVar,
                            fontVariations:
                                AppFonts.fontVariations(FontWeight.w900),
                            fontSize: 14,
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontFamily: AppFonts.iranSansVar,
                            fontVariations:
                                AppFonts.fontVariations(FontWeight.w500),
                            fontSize: 14,
                          ),
                          tabs: const [
                            Tab(text: 'چک لیست'),
                            Tab(text: 'زمان دار'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildTaskList(context, _checklistTasks, false),
                            _buildTimedTaskList(context),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Invisible Full Screen Blocker to Dismiss the Dropdown
                  if (_isAddMenuOpen)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _toggleAddMenu,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),

                  // Floating Expanding Menu Options
                  if (_isAddMenuOpen)
                    Positioned(
                      left: 32,
                      top: 64, // Positioned slightly below the Add Task button
                      child: FadeTransition(
                        opacity: _menuOpacityAnimation,
                        child: ScaleTransition(
                          scale: _menuScaleAnimation,
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMenuItem(
                                title: 'تسک زمان دار',
                                icon: IconsaxPlusLinear.timer_1,
                                onTap: () {
                                  if (_isAddMenuOpen) {
                                    _toggleAddMenu();
                                    _openAddTimedTaskScreen();
                                  }
                                },
                              ),
                              _buildMenuItem(
                                title: 'چک لیست',
                                icon: IconsaxPlusLinear.tick_square,
                                onTap: () {
                                  _toggleAddMenu();
                                  _openAddTaskScreen();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Snapshot of what the details sheet shows; recomputed on every timer tick
  /// so the countdown stays live while the sheet is open.
  _SheetTaskState _sheetTaskState(Map<String, dynamic> task,
      {required bool timed}) {
    if (!timed) {
      return _SheetTaskState(
        isDone: task['status'] == 'done',
        primaryText: 'انجام شد',
        progressColor: AppColors.black1,
      );
    }

    final status = _timedTaskStatus(task);
    final showsProgress = _timedTaskShowsProgress(task);
    return _SheetTaskState(
      isDone: status == 'done',
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
                onPop: () => _loadTasksForSelectedDate(showLoading: false),
              ),
            ),
          );
        } else {
          final index =
              _checklistTasks.indexWhere((item) => item['id'] == task['id']);
          await _completeChecklistTask(index);
        }
      case _TaskSheetAction.edit:
        final edited = await context.to<Map<String, dynamic>>(
          timed ? AddTimedTaskScreen(task: task) : AddTaskScreen(task: task),
        );
        if (edited == null || !mounted) return;
        showReToast(context, 'تسک با موفقیت ویرایش شد', ReToastType.success);
        await _loadTasksForSelectedDate();
      case _TaskSheetAction.delete:
        var deleted = false;
        // The confirm sheet runs the delete itself and always pops false.
        await _confirmDeleteTask(() async {
          deleted = await _deleteTaskById(task['id'] as String?);
        });
        if (deleted && mounted) await _loadTasksForSelectedDate();
    }
  }

  Future<void> _openAddTaskScreen() async {
    final newTask = await context.to<Map<String, dynamic>>(
      const AddTaskScreen(),
    );

    if (newTask == null) return;
    if (!mounted) return;

    showReToast(context, 'تسک با موفقیت اضافه شد', ReToastType.success);
    await _loadTasksForSelectedDate();
    if (!mounted) return;

    if (_checklistCardsScrollController.hasClients) {
      _checklistCardsScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
    if (_checklistDotsScrollController.hasClients) {
      _checklistDotsScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _openAddTimedTaskScreen() async {
    final newTask = await context.to<Map<String, dynamic>>(
      const AddTimedTaskScreen(),
    );

    if (newTask == null) return;
    if (!mounted) return;

    showReToast(context, 'تسک با موفقیت اضافه شد', ReToastType.success);
    await _loadTasksForSelectedDate();
  }

  Container calenderWidget() {
    return Container(
      height: 78,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.gray2,
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      child: Stack(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  Jalali? picked = await showPersianDatePicker(
                    context: context,
                    initialDate: Jalali.now(),
                    firstDate: Jalali(1385, 8),
                    lastDate: Jalali(1450, 9),
                    holidayConfig: const PersianHolidayConfig(weekendDays: {7}),
                    initialEntryMode: PersianDatePickerEntryMode.calendarOnly,
                    initialDatePickerMode: PersianDatePickerMode.day,
                    locale: const Locale('fa', "IR"),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          primaryColor: AppColors.black1,
                          colorScheme: const ColorScheme(
                            brightness: Brightness.light,
                            primary: AppColors.black1,
                            onPrimary: AppColors.white,
                            secondary: AppColors.gray1,
                            onSecondary: AppColors.black1,
                            error: AppColors.white,
                            onError: AppColors.white,
                            surface: AppColors.white,
                            onSurface: AppColors.gray,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                      _animationController.forward(from: 0.0);
                      _slideAnimationController.forward(from: 0.0);
                      unawaited(_loadTasksForSelectedDate());
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  width: 44,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(
                    IconsaxPlusLinear.calendar,
                    color: AppColors.black1,
                  ),
                ),
              ),
              const SizedBox(width: 0),
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _weekDaysList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 0),
                  itemBuilder: (context, index) {
                    final date = _weekDaysList[index];
                    final isSelected = _isSameDay(
                      date,
                      _selectedDate,
                    );
                    return GestureDetector(
                      onTap: () {
                        if (_isSameDay(date, _selectedDate)) return;
                        setState(() {
                          _selectedDate = date;
                          _animationController.forward(from: 0.0);
                          _slideAnimationController.forward(from: 0.0);
                        });
                        unawaited(_loadTasksForSelectedDate());
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        height: 46,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.black1
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: isSelected ? 12 : 5,
                          horizontal: isSelected ? 12 : 0,
                        ),
                        child: Center(
                          child: isSelected
                              ? SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(-0.2, 0),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: _slideAnimationController,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                                  child: FadeTransition(
                                    opacity: Tween<double>(
                                      begin: 0,
                                      end: 1,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: _slideAnimationController,
                                        curve: Curves.easeInCubic,
                                      ),
                                    ),
                                    child: ScaleTransition(
                                      scale: Tween<double>(
                                        begin: 0.8,
                                        end: 1.0,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: _animationController,
                                          curve: Curves.elasticOut,
                                        ),
                                      ),
                                      child: ReText(
                                        '${convertToPersianNumbers(date.day.toString())} ${_persianMonths[date.month - 1]} ${convertToPersianNumbers(date.year.toString())}',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        isBold: true,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 6),
                                    ReText(
                                      convertToPersianNumbers(
                                        date.day.toString(),
                                      ),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13,
                                      isBold: true,
                                      color: AppColors.black1.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                  ],
                                ).hMargin(12),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskItemActionButton extends StatelessWidget {
  const _TaskItemActionButton({
    required this.text,
    required this.textColor,
    required this.background,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.borderColor,
    this.disable,
  });

  final String text;
  final Color textColor;
  final Color background;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final Color? borderColor;
  final bool? disable;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disable ?? false ? 0.4 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: disable ?? false ? () {} : onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(100),
            border:
                borderColor == null ? null : Border.all(color: borderColor!),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: iconColor,
              ),
              const Spacer(),
              ReText(
                text,
                fontSize: 11,
                fontWeight: FontWeight.w800,
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

enum _TaskSheetAction { primary, edit, delete }

class _SheetTaskState {
  const _SheetTaskState({
    required this.isDone,
    required this.primaryText,
    required this.progressColor,
    this.progress,
    this.remainingLabel,
    this.durationLabel,
  });

  final bool isDone;
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(state.progressColor),
                        ),
                      ),
                    ),
                  ],
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
