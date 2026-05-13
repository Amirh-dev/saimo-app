import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_header.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  static const Duration _goalListAnimationDuration = Duration(
    milliseconds: 260,
  );
  static const double _goalItemHeight = 102.0;
  static const List<String> _persianMonths = [
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

  static const double _goalSheetItemExtent = 48;
  static const int _goalSheetVisibleWheelItems = 3;

  final List<Map<String, dynamic>> _goals = [];
  late final ScrollController _goalCardsScrollController;
  late final ScrollController _goalDotsScrollController;
  bool _isSyncingGoalScroll = false;

  @override
  void initState() {
    super.initState();
    _goalCardsScrollController = ScrollController();
    _goalDotsScrollController = ScrollController();

    _goalCardsScrollController.addListener(() {
      if (_isSyncingGoalScroll) return;
      if (!_goalDotsScrollController.hasClients) return;
      _isSyncingGoalScroll = true;
      _goalDotsScrollController.jumpTo(
        _goalCardsScrollController.offset.clamp(
          _goalDotsScrollController.position.minScrollExtent,
          _goalDotsScrollController.position.maxScrollExtent,
        ),
      );
      _isSyncingGoalScroll = false;
    });

    _goalDotsScrollController.addListener(() {
      if (_isSyncingGoalScroll) return;
      if (!_goalCardsScrollController.hasClients) return;
      _isSyncingGoalScroll = true;
      _goalCardsScrollController.jumpTo(
        _goalDotsScrollController.offset.clamp(
          _goalCardsScrollController.position.minScrollExtent,
          _goalCardsScrollController.position.maxScrollExtent,
        ),
      );
      _isSyncingGoalScroll = false;
    });
  }

  @override
  void dispose() {
    _goalCardsScrollController.dispose();
    _goalDotsScrollController.dispose();
    super.dispose();
  }

  Future<void> _openAddGoalModal() async {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    final initialDate = Jalali.now();
    var selectedDay = initialDate.day;
    var selectedMonth = initialDate.month;
    var selectedYear = initialDate.year;
    var noteLength = 0;
    final years = [
      for (var year = initialDate.year + 2;
          year >= initialDate.year - 4;
          year--)
        year
    ];
    final dayController = FixedExtentScrollController(
      initialItem: selectedDay - 1,
    );
    final monthController = FixedExtentScrollController(
      initialItem: selectedMonth - 1,
    );
    final yearController = FixedExtentScrollController(
      initialItem: years.indexOf(selectedYear),
    );

    final newGoal = await showReModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            final maxDay = Jalali(selectedYear, selectedMonth, 1).monthLength;
            if (selectedDay > maxDay) {
              selectedDay = maxDay;
              dayController.jumpToItem(selectedDay - 1);
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.only(bottom: bottomInset),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildGoalSheetHeader(context),
                        const SizedBox(height: 25),
                        ReTextField(
                          controller: titleController,
                          placeholder: 'عنوان هدف',
                          height: 56,
                          borderRadius: 32,
                          backgroundColor: AppColors.gray.withOpacity(
                             0.1,
                          ),
                          showFocusShadow: false,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 42),
                        _buildGoalDatePicker(
                          years: years,
                          selectedDay: selectedDay,
                          selectedMonth: selectedMonth,
                          selectedYear: selectedYear,
                          dayController: dayController,
                          monthController: monthController,
                          yearController: yearController,
                          onDayChanged: (value) {
                            setModalState(() => selectedDay = value);
                          },
                          onMonthChanged: (value) {
                            setModalState(() {
                              selectedMonth = value;
                              final nextMaxDay = Jalali(
                                selectedYear,
                                selectedMonth,
                                1,
                              ).monthLength;
                              selectedDay = selectedDay.clamp(1, nextMaxDay);
                            });
                          },
                          onYearChanged: (value) {
                            setModalState(() {
                              selectedYear = value;
                              final nextMaxDay = Jalali(
                                selectedYear,
                                selectedMonth,
                                1,
                              ).monthLength;
                              selectedDay = selectedDay.clamp(1, nextMaxDay);
                            });
                          },
                        ),
                        const SizedBox(height: 34),
                        _buildGoalNoteField(
                          controller: noteController,
                          noteLength: noteLength,
                          onChanged: (value) {
                            setModalState(() => noteLength = value.length);
                          },
                        ),
                        const SizedBox(height: 36),
                        _buildGoalSheetActions(
                          context,
                          titleController: titleController,
                          noteController: noteController,
                          selectedDay: selectedDay,
                          selectedMonth: selectedMonth,
                          selectedYear: selectedYear,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    await Future<void>.delayed(const Duration(milliseconds: 350));
    titleController.dispose();
    noteController.dispose();
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();

    if (newGoal == null || !mounted) return;

    setState(() {
      _goals.insert(0, newGoal);
    });

    if (_goalCardsScrollController.hasClients) {
      _goalCardsScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
    if (_goalDotsScrollController.hasClients) {
      _goalDotsScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildGoalSheetHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gray2, width: 1.5),
            ),
            child: const Icon(
              Icons.close,
              size: 20,
              color: AppColors.gray,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ReText(
              'افزودن هدف',
              fontSize: 16,
              fontWeight: 1000,
              color: AppColors.black1,
            ),
            ReText(
              'هدف جدیدی برای خود مشخص کنید.',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.black1.withOpacity( 0.5),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalDatePicker({
    required List<int> years,
    required int selectedDay,
    required int selectedMonth,
    required int selectedYear,
    required FixedExtentScrollController dayController,
    required FixedExtentScrollController monthController,
    required FixedExtentScrollController yearController,
    required ValueChanged<int> onDayChanged,
    required ValueChanged<int> onMonthChanged,
    required ValueChanged<int> onYearChanged,
  }) {
    final days = [
      for (var day = 1;
          day <= Jalali(selectedYear, selectedMonth, 1).monthLength;
          day++)
        day
    ];

    return SizedBox(
      height: 184,
      child: Column(
        children: [
          const Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Center(
                  child: ReText(
                    'روز',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black1,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child:
                      ReText('ماه', fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Center(
                  child:
                      ReText('سال', fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: _buildWheelColumn(
                    controller: dayController,
                    itemCount: days.length,
                    onSelected: (index) => onDayChanged(index + 1),
                    selectedChild: ReText(
                      selectedDay.toString(),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                      textAlign: TextAlign.center,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: AppColors.black1,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    itemBuilder: (index) => ReText(
                      days[index].toString(),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: _wheelItemColor(
                          (index + 1) == selectedDay, index, selectedDay - 1),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                _buildDateDivider(),
                Expanded(
                  child: _buildWheelColumn(
                    controller: monthController,
                    itemCount: _persianMonths.length,
                    selectedWidth: 100,
                    onSelected: (index) => onMonthChanged(index + 1),
                    selectedChild: ReText(
                      _persianMonths[selectedMonth - 1],
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black1,
                      textAlign: TextAlign.center,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.gray2, width: 1.5),
                    ),
                    itemBuilder: (index) => ReText(
                      _persianMonths[index],
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: _wheelItemColor((index + 1) == selectedMonth,
                          index, selectedMonth - 1),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                _buildDateDivider(),
                Expanded(
                  child: _buildWheelColumn(
                    controller: yearController,
                    itemCount: years.length,
                    onSelected: (index) => onYearChanged(years[index]),
                    selectedChild: ReText(
                      selectedYear.toString(),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black1,
                      textAlign: TextAlign.center,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.gray2, width: 1.5),
                    ),
                    itemBuilder: (index) => ReText(
                      years[index].toString(),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: _wheelItemColor(years[index] == selectedYear,
                          index, years.indexOf(selectedYear)),
                      textAlign: TextAlign.center,
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

  Widget _buildWheelColumn({
    required FixedExtentScrollController controller,
    required int itemCount,
    required ValueChanged<int> onSelected,
    required Widget Function(int index) itemBuilder,
    required Widget selectedChild,
    required BoxDecoration selectedDecoration,
    double selectedWidth = 66,
  }) {
    return Center(
      child: SizedBox(
        height: _goalSheetItemExtent * _goalSheetVisibleWheelItems,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ListWheelScrollView.useDelegate(
              controller: controller,
              physics: const FixedExtentScrollPhysics(),
              itemExtent: _goalSheetItemExtent,
              diameterRatio: 10,
              perspective: 0.001,
              overAndUnderCenterOpacity: 0.6,
              onSelectedItemChanged: onSelected,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: itemCount,
                builder: (context, index) {
                  return Center(child: itemBuilder(index));
                },
              ),
            ),
            IgnorePointer(
              child: Container(
                width: selectedWidth,
                height: 48,
                alignment: Alignment.center,
                decoration: selectedDecoration,
                child: selectedChild,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateDivider() {
    return Container(
      width: 1,
      margin: const EdgeInsets.only(top: 2, bottom: 10),
      color: AppColors.gray2.withOpacity( 0.45),
    );
  }

  Color _wheelItemColor(bool isSelected, int index, int selectedIndex) {
    if (isSelected) return Colors.transparent;
    return (index - selectedIndex).abs() == 1
        ? AppColors.gray
        : AppColors.gray2;
  }

  Widget _buildGoalNoteField({
    required TextEditingController controller,
    required int noteLength,
    required ValueChanged<String> onChanged,
  }) {
    return Stack(
      children: [
        ReTextField(
          controller: controller,
          placeholder: 'یادداشت',
          maxLines: 4,
          maxLength: 200,
          height: 96,
          borderRadius: 32,
          backgroundColor: AppColors.gray2,
          textInputAction: TextInputAction.done,
          showFocusShadow: false,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          onChanged: onChanged,
        ),
        Positioned(
          left: 16,
          top: 16,
          child: ReText(
            '${noteLength.clamp(0, 200)}/200',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.black1.withOpacity( 0.5),
            textDirection: TextDirection.ltr,
          ),
        ),
      ],
    );
  }

  void _submitGoal(
    BuildContext context, {
    required TextEditingController titleController,
    required TextEditingController noteController,
    required int selectedDay,
    required int selectedMonth,
    required int selectedYear,
  }) {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: ReText(
            'عنوان هدف را وارد کنید',
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      return;
    }

    final dueDate = Jalali(selectedYear, selectedMonth, selectedDay);
    Navigator.of(context).pop(
      <String, dynamic>{
        'title': title,
        'note': noteController.text.trim(),
        'dueDate': dueDate,
        'color': _goals.length.isEven ? AppColors.primary : AppColors.secondary,
      },
    );
  }

  Widget _buildGoalSheetActions(
    BuildContext context, {
    required TextEditingController titleController,
    required TextEditingController noteController,
    required int selectedDay,
    required int selectedMonth,
    required int selectedYear,
  }) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        SizedBox(
          width: 118,
          height: 58,
          child: ReButton(
            onPressed: () => Navigator.of(context).pop(),
            text: 'لغو',
            icon: Icons.close,
            textDirection: TextDirection.ltr,
            isOutlined: true,
            background: AppColors.white,
            color: AppColors.gray2,
            textColor: AppColors.black1,
            borderRadius: 32,
            fontSize: 17,
            iconSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 58,
            child: ReButton(
              onPressed: () => _submitGoal(
                context,
                titleController: titleController,
                noteController: noteController,
                selectedDay: selectedDay,
                selectedMonth: selectedMonth,
                selectedYear: selectedYear,
              ),
              text: 'افزودن',
              icon: Icons.add,
              textDirection: TextDirection.ltr,
              background: AppColors.primary,
              textColor: AppColors.white,
              borderRadius: 32,
              fontSize: 20,
              iconSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  int _goalRemainingDays(Jalali dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDateTime = dueDate.toDateTime();
    final dueDay = DateTime(
      dueDateTime.year,
      dueDateTime.month,
      dueDateTime.day,
    );

    return math.max(0, dueDay.difference(today).inDays);
  }

  Widget _buildGoalTile(Map<String, dynamic> goal) {
    final dueDate = goal['dueDate'] as Jalali;
    final color = goal['color'] as Color? ?? AppColors.primary;
    final remainingDays = _goalRemainingDays(dueDate);

    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: AppColors.black1.withOpacity( 0.04),
            blurRadius: 80,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.arrow_back_ios,
            size: 18,
            color: AppColors.gray,
          ).lMargin(28),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 28, left: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ReText(
                    goal['title']?.toString() ?? '',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black1,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 7),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const ReText(
                        'روز باقی مانده',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray,
                      ),
                      const SizedBox(width: 10),
                      ReText(
                        remainingDays.toString(),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: color,
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalList() {
    if (_goals.isEmpty) {
      return const ReEmptyList(
        imageWidth: 220,
        title: 'هنوز هدفی مشخص نکردی!',
        subtitle: 'برای افزودن هدف روی + کلیک کنید.',
        imagePath: 'assets/images/empty_list_goal.png',
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                controller: _goalCardsScrollController,
                padding: const EdgeInsets.fromLTRB(32, 12, 4, 24),
                itemCount: _goals.length,
                itemBuilder: (_, index) => AnimatedContainer(
                  duration: _goalListAnimationDuration,
                  curve: Curves.easeOutCubic,
                  height: _goalItemHeight,
                  alignment: Alignment.center,
                  child: _buildGoalTile(_goals[index]),
                ),
              ),
            ),
            SizedBox(
              width: 68,
              child: ListView.builder(
                controller: _goalDotsScrollController,
                padding: const EdgeInsets.only(top: 12, bottom: 24, right: 8),
                itemCount: _goals.length,
                itemBuilder: (_, index) {
                  final color =
                      _goals[index]['color'] as Color? ?? AppColors.primary;
                  return AnimatedContainer(
                    duration: _goalListAnimationDuration,
                    curve: Curves.easeOutCubic,
                    height: _goalItemHeight,
                    child: ReTimelineDot(
                      showTopLine: index != 0,
                      showBottomLine: index != _goals.length - 1,
                      isDone: true,
                      height: _goalItemHeight,
                      width: 56,
                      circleSize: 42,
                      innerCircleSize: 32,
                      lineColor: AppColors.gray.withOpacity( 0.45),
                      activeBackgroundColor: color.withOpacity( 0.12),
                      innerPadding: const EdgeInsets.all(5),
                      dotConnectorGap: 0,
                      segmentHeight: 8,
                      segmentGap: 8,
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppColors.white,
                          size: 20,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray1,
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) => navigateToIndex(context, index),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: Column(
                children: [
                  reAppHeader(
                    'اهداف',
                    prefixIcon: GestureDetector(
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          SolarIconsOutline.bell,
                          size: 24,
                        ),
                      ),
                    ),
                    suffixIcon: GestureDetector(
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          SolarIconsOutline.history,
                          size: 24,
                        ),
                      ),
                    ),
                  ).bMargin(24)
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ReButton(
                  onPressed: _openAddGoalModal,
                  text: 'افزودن هدف',
                  textDirection: TextDirection.ltr,
                  icon: Icons.add,
                  iconSize: 18,
                  isOutlined: true,
                  background: AppColors.gray1,
                  textColor: AppColors.black1,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ).sizedBox(
                  height: 40,
                  width: 132,
                ),
                const ReText(
                  'اهداف شما',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                )
              ],
            ).hMargin(32).vMargin(16),
            Expanded(
              child: _buildGoalList(),
            ),
          ],
        ),
      ),
    );
  }
}
