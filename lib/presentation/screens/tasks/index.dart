import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/app_navigation_tabs.dart';
import 'package:simo_learn/presentation/screens/goals/index.dart';
import 'package:simo_learn/presentation/screens/tasks/add_task/index.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_header.dart';
import 'package:simo_learn/presentation/screens/profile/index.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

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

  late List<Map<String, dynamic>> _checklistTasks;
  late List<Map<String, dynamic>> _timedTasks;
  Timer? _timedTaskTicker;
  late ScrollController _checklistDotsScrollController;
  late ScrollController _checklistCardsScrollController;
  int? _expandedChecklistTaskIndex;
  int? _expandedTimedTaskIndex;
  bool _isSyncingChecklistScroll = false;
  static const double _checklistItemCollapsedHeight = 90.0;
  static const double _checklistItemExpandedHeight = 140.0;
  static const Duration _taskExpansionDuration = Duration(milliseconds: 260);

  void _initChecklistTasks() {
    _checklistTasks = [
      {
        'title': 'مطالعه فارسی',
        'subtitle': 'مطالعه فصل ۴ و ۵ علوم',
        'time': '۰۹:۳۰',
        'status': 'pending',
      },
      {
        'title': 'مطالعـــه فارسی',
        'subtitle': 'حل تمرین کتاب درسی',
        'time': '۱۲:۱۵',
        'status': 'pending',
      },
      {
        'title': 'یادگیری لغات',
        'subtitle': '۵ لغت جدید انگلیسی',
        'time': '۱۷:۰۰',
        'status': 'pending',
      },
    ];
  }

  void _initTimedTasks() {
    _timedTasks = [
      {
        'title': 'مطالعه فارسی',
        'subtitle': 'مطالعه فصل ۴ و ۵ علوم',
        'elapsed': '۴۳:۵۲',
        'duration': '۴۵:۰۰',
        'durationSeconds': 2700,
        'remainingSeconds': 2632,
        'status': 'running',
        'label': '۴۵ دقیقه',
      },
      {
        'title': 'مطالعه فارسی',
        'subtitle': 'مطالعه فصل ۴ و ۵ علوم',
        'elapsed': '۴۳:۵۲',
        'duration': '۴۵:۰۰',
        'durationSeconds': 2700,
        'remainingSeconds': 1215,
        'status': 'paused',
        'label': '۴۵ دقیقه',
      },
      {
        'title': 'مطالعه فارسی',
        'subtitle': 'مطالعه فصل ۴ و ۵ علوم',
        'elapsed': '۰۰:۰۰',
        'duration': '۴۵:۰۰',
        'durationSeconds': 2700,
        'remainingSeconds': 2700,
        'status': 'pending',
        'label': '۴۵ دقیقه',
      },
      {
        'title': 'مطالعه فارسی',
        'subtitle': 'مطالعه فصل ۴ و ۵ علوم',
        'elapsed': '۴۳:۵۲',
        'duration': '۴۵:۰۰',
        'durationSeconds': 2700,
        'remainingSeconds': 0,
        'status': 'done',
        'label': '۴۵ دقیقه',
      },
    ];
  }

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
    _initChecklistTasks();
    _initTimedTasks();
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

    _ensureTimedTaskTicker();
  }

  @override
  void dispose() {
    _timedTaskTicker?.cancel();
    _checklistDotsScrollController.dispose();
    _checklistCardsScrollController.dispose();
    _animationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  List<Jalali> get _weekDaysList {
    return List.generate(17, (index) => _today.addDays(index - 3));
  }

  bool _isSameDay(Jalali a, Jalali b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  double _checklistRowHeightAt(int index) {
    return _expandedChecklistTaskIndex == index
        ? _checklistItemExpandedHeight
        : _checklistItemCollapsedHeight;
  }

  void _ensureTimedTaskTicker() {
    final hasRunningTask =
        _timedTasks.any((task) => task['status'] == 'running');
    if (!hasRunningTask) {
      _timedTaskTicker?.cancel();
      _timedTaskTicker = null;
      return;
    }

    _timedTaskTicker ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickTimedTasks(),
    );
  }

  void _tickTimedTasks() {
    if (!mounted) return;

    setState(() {
      for (final task in _timedTasks) {
        if (task['status'] != 'running') continue;

        final remaining = (task['remainingSeconds'] as int? ?? 0) - 1;
        task['remainingSeconds'] = math.max(0, remaining);

        if ((task['remainingSeconds'] as int) == 0) {
          task['status'] = 'done';
        }
      }
    });

    _ensureTimedTaskTicker();
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

  Future<bool> _confirmDeleteTask() async {
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
                        onTap: () => Navigator.of(context).pop(true),
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
    final confirmed = await _confirmDeleteTask();
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

    _ensureTimedTaskTicker();
  }

  Future<void> _requestDeleteTimedTask(int index) async {
    if (index < 0 || index >= _timedTasks.length) return;
    final confirmed = await _confirmDeleteTask();
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
    BuildContext context,
    Map<String, dynamic> task,
    int index,
  ) {
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
          boxShadow: [
            BoxShadow(
              color: AppColors.black1.withOpacity(0.06),
              blurRadius: 100,
              offset: const Offset(0, 6),
            ),
          ],
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
                        onTap: () => _toggleChecklistTaskActions(index),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AnimatedRotation(
                              duration: _taskExpansionDuration,
                              curve: Curves.easeOutCubic,
                              turns: isExpanded ? -0.25 : 0,
                              child: const Icon(
                                Icons.arrow_back_ios,
                                size: 12,
                                color: AppColors.black1,
                              ),
                            ).lMargin(5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ReText(
                                  task['title'] ?? '',
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.black1,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
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
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
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
                                textColor: AppColors.primary,
                                background: const Color(0xFFFBEAE5),
                                icon: Icons.add,
                                iconColor: AppColors.primary,
                                onTap: () => _addChecklistTaskToToday(index),
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
    BuildContext context,
    List<Map<String, dynamic>> tasks,
  ) {
    if (tasks.isEmpty) {
      return const ReEmptyList(
        title: 'چک لیستی ندارید!',
        subtitle: 'برای امروز تسکی اضافه نکردید.',
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task cards
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

            // Dots timeline
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
                      onTap: () => _toggleChecklistTaskStatus(index),
                    ),
                  );
                },
              ),
            ),
          ],
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
    final status = task['status'] as String? ?? 'pending';
    return status == 'running' || status == 'paused';
  }

  double _timedTaskRowHeight(Map<String, dynamic> task, int index) {
    final base = _timedTaskShowsProgress(task) ? 98.0 : 74.0;
    final isExpanded = _expandedTimedTaskIndex == index;
    return isExpanded ? base + 66.0 : base;
  }

  double _timedTaskRemainingProgress(Map<String, dynamic> task) {
    final duration = task['durationSeconds'] as int? ?? 1;
    final remaining = task['remainingSeconds'] as int? ?? 0;
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
    return _formatTimedTaskSeconds(task['remainingSeconds'] as int? ?? 0);
  }

  String _timedTaskDurationLabel(Map<String, dynamic> task) {
    return _formatTimedTaskSeconds(task['durationSeconds'] as int? ?? 0);
  }

  void _toggleTimedTaskTimer(int index) {
    if (index < 0 || index >= _timedTasks.length) return;

    setState(() {
      final task = _timedTasks[index];
      final status = task['status'] as String? ?? 'pending';
      final remaining = task['remainingSeconds'] as int? ?? 0;

      if (status == 'done' || remaining <= 0) return;

      // If currently running, pause it (button turns blue).
      if (status == 'running') {
        task['status'] = 'paused';
        return;
      }

      for (final timedTask in _timedTasks) {
        if (timedTask['status'] == 'running') {
          timedTask['status'] = 'paused';
        }
      }
      // Start/resume selected task (button turns primary).
      task['status'] = 'running';
    });

    _ensureTimedTaskTicker();
  }

  Widget _buildTimedConnector({
    required bool visible,
    required double height,
  }) {
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
    final status = task['status'] as String? ?? 'pending';
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
                    border: Border.all(color: color.withOpacity(0.70)),
                  ),
                  child: Icon(
                    _timedTaskMarkerIcon(status),
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

    final status = task['status'] as String? ?? 'pending';
    final color = _timedTaskColor(status);
    final progress = _timedTaskRemainingProgress(task);
    final hasProgress = _timedTaskShowsProgress(task);
    final isDone = status == 'done';
    final isExpanded = _expandedTimedTaskIndex == index;
    final cardHeight = hasProgress ? 84.0 : 60.0;

    return Opacity(
      opacity: isDone ? 0.55 : 1,
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(isExpanded ? 36 : 34),
          border: Border.all(color: AppColors.gray2),
          boxShadow: [
            BoxShadow(
              color: AppColors.black1.withOpacity(0.05),
              blurRadius: 80,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: hasProgress ? 10 : 8,
        ),
        child: Column(
          children: [
            Row(
              textDirection: TextDirection.ltr,
              children: [
                GestureDetector(
                  onTap: () => _toggleTimedTaskActions(index),
                  behavior: HitTestBehavior.opaque,
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
                    onTap: () => _toggleTimedTaskActions(index),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ReText(
                          task['title'] ?? '',
                          fontSize: titleSize,
                          fontWeight: FontWeight.w900,
                          color: AppColors.black1,
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
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
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
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
            if (hasProgress) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  ReText(
                    _timedTaskRemainingLabel(task),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black1,
                    textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 2,
                        backgroundColor: AppColors.gray2,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  ReText(
                    _timedTaskDurationLabel(task),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray,
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ],
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
                            text: status == 'running' ? 'توقف' : 'شروع',
                            textColor: AppColors.primary,
                            background: const Color(0xFFFBEAE5),
                            icon: status == 'running'
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            iconColor: AppColors.primary,
                            onTap: () => _toggleTimedTaskTimer(index),
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
                            onTap: () => _requestDeleteTimedTask(index),
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
    );
  }

  Widget _buildTimedTaskList(BuildContext context) {
    if (_timedTasks.isEmpty) {
      return _buildTaskList(context, const []);
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
              height: rowHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: _buildTimedTaskTile(task, index),
                    ),
                  ),
                  const SizedBox(width: 10),
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
      child: Scaffold(
        backgroundColor: AppColors.gray1,
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: 2,
          onTap: _onBottomNavigationTap,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  children: [
                    reAppHeader(
                      'تسک ها',
                      suffixIcon: const Icon(
                        SolarIconsOutline.history,
                      ),
                      prefixIcon: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.white,
                        ),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            const Icon(
                              SolarIconsOutline.bell,
                              size: 20,
                            ).vMargin(10).hMargin(10),
                            Container(
                              margin: const EdgeInsets.only(top: 5, right: 5),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: AppColors.errorColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    calenderWidget(),
                  ],
                ),
              ),
              Builder(
                builder: (tabContext) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          final controller =
                              DefaultTabController.maybeOf(tabContext);
                          if (controller != null && controller.index == 1) {
                            _openAddTimedTaskScreen();
                            return;
                          }
                          _openAddTaskScreen();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.gray2),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.add,
                                size: 18,
                                color: AppColors.primary,
                              ).rMargin(6),
                              const ReText(
                                'افزودن تسک',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.black1,
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
                  ).hMargin(32).tMargin(16);
                },
              ),
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
                    fontVariations: AppFonts.fontVariations(FontWeight.w900),
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontFamily: AppFonts.iranSansVar,
                    fontVariations: AppFonts.fontVariations(FontWeight.w500),
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
                    _buildTaskList(context, _checklistTasks),
                    _buildTimedTaskList(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onBottomNavigationTap(int index) {
    if (index == 2) return;
    switch (index) {
      case 0:
        context.toOff(const GoalScreen());
        break;
      case 1:
        context.toOff(const TrophiesScreen());
        break;
      case 3:
        context.toOff(const TimerScreen());
        break;
      case 4:
        context.toOff(const ProfileScreen());
        break;
    }
  }

  Future<void> _openAddTaskScreen() async {
    final newTask = await context.to<Map<String, dynamic>>(
      const AddTaskScreen(),
    );

    if (newTask == null) return;

    setState(() {
      _checklistTasks.insert(0, newTask);
      if (_expandedChecklistTaskIndex != null) {
        _expandedChecklistTaskIndex = _expandedChecklistTaskIndex! + 1;
      }
    });

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

    setState(() {
      _timedTasks.insert(0, newTask);
    });

    _ensureTimedTaskTicker();
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
              Container(
                margin: const EdgeInsets.only(right: 4),
                width: 44,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(
                  SolarIconsOutline.calendar,
                  color: AppColors.black1,
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
          // Container(
          //   margin: const EdgeInsets.only(left: 50),
          //   alignment: Alignment.topRight,
          //   width: 50,
          //   height: 80,
          //   decoration: BoxDecoration(
          //       gradient: LinearGradient(
          //           begin: Alignment.centerRight,
          //           stops: const [0, 0.8],
          //           end: Alignment.centerLeft,
          //           colors: [
          //             const Color(0xFFEBECF0).withOpacity(0.0),
          //             const Color(0xFFEBECF0),
          //           ]),
          //       borderRadius: const BorderRadius.only(
          //           topLeft: Radius.circular(100),
          //           bottomLeft: Radius.circular(100))),
          // )
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
  });

  final String text;
  final Color textColor;
  final Color background;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(100),
          border: borderColor == null ? null : Border.all(color: borderColor!),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 26,
              color: iconColor,
            ),
            const Spacer(),
            ReText(
              text,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ],
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
