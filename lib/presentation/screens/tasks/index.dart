import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_header.dart';
import 'package:simo_learn/presentation/widgets/re_image.dart';
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
  late Jalali _currentMonth;
  late AnimationController _animationController;
  late AnimationController _slideAnimationController;

  final List<Map<String, String>> _checklistTasks = [
    {
      'title': 'مطالعه فارسی',
      'subtitle': 'مطالعه فصل ۴ و ۵ علوم',
      'time': '۰۹:۳۰',
    },
    {
      'title': 'تمرین ریاضی',
      'subtitle': 'حل تمرین کتاب درسی',
      'time': '۱۲:۱۵',
    },
    {
      'title': 'یادگیری لغات',
      'subtitle': '۵ لغت جدید انگلیسی',
      'time': '۱۷:۰۰',
    },
  ];

  final List<Map<String, String>> _timedTasks = [
    {
      'title': 'کلاس آنلاین زبان',
      'subtitle': 'جلسه تقویتی انگلیسی',
      'time': '۲۰:۰۰',
    },
    {
      'title': 'تمرین پیانو',
      'subtitle': 'نواختن قطعه جدید',
      'time': '۲۱:۳۰',
    },
  ];

  final List<String> _weekDays = [
    'شنبه',
    'یکشنبه',
    'دوشنبه',
    'سه شنبه',
    'چهارشنبه',
    'پنجشنبه',
    'جمعه',
  ];

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
    _currentMonth = Jalali(_today.year, _today.month, 1);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  List<Jalali> get _weekDaysList {
    return List.generate(7, (index) => _today.addDays(index - 3));
  }

  Widget _buildTaskDot({
    required bool showTopLine,
    required bool showBottomLine,
  }) {
    return SizedBox(
      width: 34,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Container(
              width: 2,
              color: showTopLine ? AppColors.gray2 : Colors.transparent,
            ),
          ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black1.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: 2,
              color: showBottomLine ? AppColors.gray2 : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(
    BuildContext context,
    Map<String, String> task,
    int index,
    int total,
  ) {
    final width = context.deviceWidth;
    final padding = width < 600 ? 16.0 : 20.0;
    final titleSize = width < 600 ? 15.0 : 16.0;
    final subtitleSize = width < 600 ? 12.0 : 13.0;
    final tagSize = width < 600 ? 11.0 : 12.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: IntrinsicHeight(
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTaskDot(
              showTopLine: index != 0,
              showBottomLine: index != total - 1,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
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
                    onTap: () {},
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ReText(
                            task['title'] ?? '',
                            fontSize: titleSize,
                            isBold: true,
                            color: AppColors.black1,
                          ),
                          const SizedBox(height: 6),
                          ReText(
                            task['subtitle'] ?? '',
                            fontSize: subtitleSize,
                            color: Color.lerp(
                                AppColors.black1, Colors.transparent, 0.25),
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.gray2,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: ReText(
                                  task['time'] ?? '',
                                  fontSize: tagSize,
                                  isBold: true,
                                  color: AppColors.black1,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.arrow_back_ios,
                                size: 16,
                                color: AppColors.black1,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    List<Map<String, String>> tasks,
  ) {
    if (tasks.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ReImage(
            'assets/images/empty_list.png',
            width: 180,
          ),
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
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: tasks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 0),
          itemBuilder: (_, index) => _buildTaskTile(
            context,
            tasks[index],
            index,
            tasks.length,
          ),
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
        body: SafeArea(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
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
                          color: AppColors.gray2,
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
                    Container(
                      height: 78,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 16,
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
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 0),
                              itemBuilder: (context, index) {
                                final date = _weekDaysList[index];
                                final isSelected = date == _selectedDate;
                                return GestureDetector(
                                  onTap: () => setState(() {
                                    _selectedDate = date;
                                    _animationController.forward(from: 0.0);
                                    _slideAnimationController.forward(
                                        from: 0.0);
                                  }),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOutCubic,
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
                                    width: isSelected ? null : 35,
                                    child: Center(
                                      child: isSelected
                                          ? SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(-0.2, 0),
                                                end: Offset.zero,
                                              ).animate(
                                                CurvedAnimation(
                                                  parent:
                                                      _slideAnimationController,
                                                  curve: Curves.easeOutCubic,
                                                ),
                                              ),
                                              child: FadeTransition(
                                                opacity: Tween<double>(
                                                  begin: 0,
                                                  end: 1,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent:
                                                        _slideAnimationController,
                                                    curve: Curves.easeInCubic,
                                                  ),
                                                ),
                                                child: ScaleTransition(
                                                  scale: Tween<double>(
                                                    begin: 0.8,
                                                    end: 1.0,
                                                  ).animate(
                                                    CurvedAnimation(
                                                      parent:
                                                          _animationController,
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
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
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
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
                    _buildTaskList(context, _timedTasks),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
