import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_header.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/extentions.dart';
import 'package:simo_learn/utils/helpers.dart';
import 'package:solar_icons/solar_icons.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
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

  static const double _goalSheetItemExtent = 56;

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

    await showReModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            final sheetHeight = MediaQuery.of(context).size.height * 0.98;
            final maxDay = Jalali(selectedYear, selectedMonth, 1).monthLength;
            if (selectedDay > maxDay) {
              selectedDay = maxDay;
              dayController.jumpToItem(selectedDay - 1);
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: SizedBox(
                  height: sheetHeight,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: 0,
                        child: Container(
                          width: 156,
                          height: 54,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(42),
                              bottomRight: Radius.circular(42),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 30,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(32, 112, 32, 32),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(52),
                              topRight: Radius.circular(52),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildGoalSheetHeader(context),
                              const SizedBox(height: 48),
                              ReTextField(
                                controller: titleController,
                                placeholder: 'عنوان هدف',
                                height: 56,
                                borderRadius: 32,
                                backgroundColor: AppColors.gray2,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
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
                                    selectedDay =
                                        selectedDay.clamp(1, nextMaxDay);
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
                                    selectedDay =
                                        selectedDay.clamp(1, nextMaxDay);
                                  });
                                },
                              ),
                              const Spacer(),
                              _buildGoalNoteField(
                                controller: noteController,
                                noteLength: noteLength,
                                onChanged: (value) {
                                  setModalState(
                                      () => noteLength = value.length);
                                },
                              ),
                              const SizedBox(height: 52),
                              _buildGoalSheetActions(context),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 29,
                        child: Container(
                          width: 100,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    noteController.dispose();
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
  }

  Widget _buildGoalSheetHeader(BuildContext context) {
    return Row(
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
        const SizedBox(width: 24),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ReText(
                'افزودن هدف',
                fontSize: 27,
                fontWeight: 1100,
                color: AppColors.black1,
              ),
              SizedBox(height: 6),
              ReText(
                'هدف جدیدی برای خود مشخص کنید.',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.gray,
              ),
            ],
          ),
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
      height: 252,
      child: Column(
        children: [
          const Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                  child: Center(
                      child: ReText('روز',
                          fontSize: 16, fontWeight: FontWeight.w900))),
              Expanded(
                  child: Center(
                      child: ReText('ماه',
                          fontSize: 16, fontWeight: FontWeight.w900))),
              Expanded(
                  child: Center(
                      child: ReText('سال',
                          fontSize: 16, fontWeight: FontWeight.w900))),
            ],
          ),
          const SizedBox(height: 20),
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
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                      textAlign: TextAlign.center,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: AppColors.black1,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    itemBuilder: (index) => ReText(
                      days[index].toString(),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
    return Stack(
      alignment: Alignment.center,
      children: [
        ListWheelScrollView.useDelegate(
          controller: controller,
          physics: const FixedExtentScrollPhysics(),
          itemExtent: _goalSheetItemExtent,
          diameterRatio: 10,
          perspective: 0.001,
          overAndUnderCenterOpacity: 1,
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
            height: 50,
            alignment: Alignment.center,
            decoration: selectedDecoration,
            child: selectedChild,
          ),
        ),
      ],
    );
  }

  Widget _buildDateDivider() {
    return Container(
      width: 1,
      margin: const EdgeInsets.only(top: 2, bottom: 10),
      color: AppColors.gray2.withOpacity(0.45),
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
          fontSize: 15,
          fontWeight: FontWeight.w800,
          onChanged: onChanged,
        ),
        Positioned(
          left: 34,
          top: 28,
          child: ReText(
            '${noteLength.clamp(0, 200)}/200',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.gray,
            textDirection: TextDirection.ltr,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalSheetActions(BuildContext context) {
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
              onPressed: () => Navigator.of(context).pop(),
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
            const Expanded(
              child: ReEmptyList(
                imageWidth: 220,
                title: 'هنوز هدفی مشخص نکردی!',
                subtitle: 'برای افزودن هدف روی + کلیک کنید.',
                imagePath: 'assets/images/empty_list_goal.png',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
