import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/widgets/add_task_bottom_sheet.dart';
import 'package:simo_learn/presentation/screens/app_navigation_tabs.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_header.dart';
import 'package:simo_learn/presentation/widgets/re_image.dart';
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
  late ScrollController _checklistDotsScrollController;
  late ScrollController _checklistCardsScrollController;
  bool _isSyncingChecklistScroll = false;
  static const double _checklistItemHeight = 90.0;
  static const double _checklistItemVerticalPadding = 6.0;

  void _initChecklistTasks() {
    _checklistTasks = [
      {
        'title': 'مطالعه فارسی',
        'subtitle': 'مطالعه فصل ۴ و ۵ علوم',
        'time': '۰۹:۳۰',
        'status': 'pending',
      },
      {
        'title': 'تمرین ریاضی',
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
        'progress': 0.93,
        'status': 'pause',
        'label': '۴۵ دقیقه',
      },
      {
        'title': 'مطالعه فارسی',
        'subtitle': 'مطالعه فصل ۴ و ۵ علوم',
        'elapsed': '۴۳:۵۲',
        'duration': '۴۵:۰۰',
        'progress': 0.45,
        'status': 'play',
        'label': '۴۵ دقیقه',
      },
      {
        'title': 'مطالعه فارسی',
        'subtitle': 'مطالعه فصل ۴ و ۵ علوم',
        'elapsed': '۴۳:۵۲',
        'duration': '۴۵:۰۰',
        'progress': 1.0,
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
  }

  @override
  void dispose() {
    _checklistDotsScrollController.dispose();
    _checklistCardsScrollController.dispose();
    _animationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  List<Jalali> get _weekDaysList {
    return List.generate(7, (index) => _today.addDays(index - 3));
  }

  bool _isSameDay(Jalali a, Jalali b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildTaskDot({
    required bool showTopLine,
    required bool showBottomLine,
    required bool isDone,
    required double height,
  }) {
    const circleSize = 32.0;
    const segmentCount = 2;
    const segmentWidth = 2.0;
    const segmentHeight = 3.5;
    const segmentGap = 8.0;
    final lineAreaHeight = math.max(0.0, (height - circleSize) / 2);
    final fittedSegmentCount = math.min(
      segmentCount,
      ((lineAreaHeight + segmentGap) / (segmentHeight + segmentGap)).floor(),
    );

    Widget buildShortLine() => Container(
          width: segmentWidth,
          height: segmentHeight,
          decoration: BoxDecoration(
            color: AppColors.black1,
            borderRadius: BorderRadius.circular(100),
          ),
        );

    Widget buildShortLines(bool visible) {
      if (!visible ||
          lineAreaHeight < segmentHeight ||
          fittedSegmentCount == 0) {
        return SizedBox(height: lineAreaHeight);
      }

      return SizedBox(
        height: lineAreaHeight,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              fittedSegmentCount * 2 - 1,
              (index) => index.isEven
                  ? buildShortLine()
                  : const SizedBox(height: segmentGap),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 34,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          buildShortLines(showTopLine),
          Container(
            width: circleSize,
            height: circleSize,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color:
                    isDone ? AppColors.done.withOpacity(0.2) : AppColors.white,
                border: Border.all(
                  width: 2,
                  color: isDone ? Colors.transparent : AppColors.gray2,
                ),
                shape: BoxShape.circle,
              ),
              child: isDone
                  ? const Icon(
                      CupertinoIcons.checkmark_alt,
                      size: 16,
                      color: AppColors.done,
                    )
                  : null,
            ),
          ),
          buildShortLines(showBottomLine),
        ],
      ),
    );
  }

  Widget _buildTaskTile(
    BuildContext context,
    Map<String, dynamic> task,
    int index,
    int total,
  ) {
    void toggleTaskStatus() {
      setState(() {
        final status = task['status'] as String?;
        if (status == 'done') {
          task['status'] = task['previousStatus'] ?? 'pending';
          return;
        }

        task['previousStatus'] = status ?? 'pending';
        task['status'] = 'done';
      });
    }

    final width = context.deviceWidth;
    const padding = 16.0;
    final titleSize = width < 600 ? 15.0 : 16.0;
    final subtitleSize = width < 600 ? 12.0 : 13.0;
    final isDone = task['status'] == 'done';
    final opacity = isDone ? 0.5 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.gray2),
          boxShadow: [
            BoxShadow(
              color: AppColors.black1.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: toggleTaskStatus,
            child: Padding(
              padding: const EdgeInsets.all(padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.arrow_back_ios,
                    size: 12,
                    color: AppColors.black1,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ReText(
                        task['title'] ?? '',
                        fontSize: titleSize,
                        isBold: true,
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
                            AppColors.black1, Colors.transparent, 0.25),
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
        ),
      ),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    List<Map<String, dynamic>> tasks,
  ) {
    if (tasks.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const ReImage(
            'assets/images/empty_list.png',
            width: 180,
          ).tMargin(150),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 20),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.white,
                ),
                child:
                    const Icon(Icons.add, size: 20, color: AppColors.primary),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ReText(
                    'چک لیستی ندارید!',
                    fontSize: 16,
                    isBold: true,
                  ),
                  ReText(
                    'برای امروز تسکی اضافه نکردید.',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black1,
                  )
                ],
              ),
            ],
          ).tMargin(22)
        ],
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
                itemExtent: _checklistItemHeight,
                itemCount: tasks.length,
                itemBuilder: (_, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: _checklistItemVerticalPadding,
                  ),
                  child: _buildTaskTile(
                    context,
                    tasks[index],
                    index,
                    tasks.length,
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
                itemExtent: _checklistItemHeight,
                itemCount: tasks.length,
                itemBuilder: (_, index) {
                  final task = tasks[index];
                  return _buildTaskDot(
                    showTopLine: index != 0,
                    showBottomLine: index != tasks.length - 1,
                    isDone: task['status'] == 'done',
                    height: _checklistItemHeight,
                  );
                },
              ),
            ),
          ],
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _showAddTaskBottomSheet,
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
                    isBold: true,
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
                  unselectedLabelColor: AppColors.black1.withOpacity(0.5),
                  labelStyle: const TextStyle(
                    fontFamily: 'Sanse',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Sanse',
                    fontWeight: FontWeight.w500,
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
                    _buildTaskList(context, []),
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
        context.toOff(const HomeScreen());
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

  Future<void> _showAddTaskBottomSheet() async {
    final newTask = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.black1.withOpacity(0.2),
      builder: (_) => const AddTaskBottomSheet(),
    );

    if (newTask == null) return;

    setState(() {
      _checklistTasks.insert(0, newTask);
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
      child: Row(
        children: [
          Container(
            width: 46,
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
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.black1 : Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: isSelected ? 12 : 5,
                      horizontal: isSelected ? 12 : 0,
                    ),
                    width: isSelected ? null : 35,
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
                                  fontSize: 16,
                                  isBold: true,
                                  color: AppColors.black1,
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
