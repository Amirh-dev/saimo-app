import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/widgets/re_button.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/extentions.dart';

class BirthDatePickerBottomSheet extends StatefulWidget {
  const BirthDatePickerBottomSheet({
    super.key,
    required this.initialDate,
  });

  final Jalali initialDate;

  @override
  State<BirthDatePickerBottomSheet> createState() =>
      _BirthDatePickerBottomSheetState();
}

class _BirthDatePickerBottomSheetState
    extends State<BirthDatePickerBottomSheet> {
  static const List<String> _months = [
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

  late List<int> _yearOptions;
  final List<int> _monthOptions = List<int>.generate(12, (index) => index + 1);
  late List<int> _dayOptions;

  late int _yearIndex;
  late int _monthIndex;
  late int _dayIndex;

  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  double _rf(double size) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = ((width / 375).clamp(0.85, 1.0)) * 0.92;
    return size * scale;
  }

  @override
  void initState() {
    super.initState();

    _yearOptions = List<int>.generate(
      86,
      (index) => widget.initialDate.year + 25 - index,
    );
    _yearIndex = _yearOptions.indexOf(widget.initialDate.year);
    if (_yearIndex < 0) {
      _yearIndex = 0;
    }

    _monthIndex = (widget.initialDate.month - 1).clamp(0, 11);

    _dayOptions = List<int>.generate(
      Jalali(
        _yearOptions[_yearIndex],
        _monthOptions[_monthIndex],
        1,
      ).monthLength,
      (index) => index + 1,
    );
    _dayIndex = (widget.initialDate.day - 1).clamp(0, _dayOptions.length - 1);

    _yearController = FixedExtentScrollController(initialItem: _yearIndex);
    _monthController = FixedExtentScrollController(initialItem: _monthIndex);
    _dayController = FixedExtentScrollController(initialItem: _dayIndex);
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  void _rebuildDays() {
    final selectedYear = _yearOptions[_yearIndex];
    final selectedMonth = _monthOptions[_monthIndex];
    final previousSelectedDay = _dayOptions[_dayIndex];
    final monthLength = Jalali(selectedYear, selectedMonth, 1).monthLength;

    _dayOptions = List<int>.generate(monthLength, (index) => index + 1);
    final clampedDay = previousSelectedDay.clamp(1, monthLength);
    _dayIndex = _dayOptions.indexOf(clampedDay);
    if (_dayIndex < 0) _dayIndex = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dayController.hasClients) return;
      _dayController.animateToItem(
        _dayIndex,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Widget _buildSliderRow({
    required List<String> labels,
    required int selectedIndex,
    required FixedExtentScrollController controller,
    required ValueChanged<int> onChanged,
    required double selectedWidth,
    required double itemExtent,
    bool darkSelected = false,
  }) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(31),
        border: Border.all(color: AppColors.gray2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: selectedWidth,
            height: 45,
            decoration: BoxDecoration(
              color: darkSelected ? const Color(0xFF222434) : AppColors.white,
              borderRadius: BorderRadius.circular(100),
              border: darkSelected ? null : Border.all(color: AppColors.gray2),
            ),
          ),
          RotatedBox(
            quarterTurns: 3,
            child: ListWheelScrollView.useDelegate(
              controller: controller,
              itemExtent: itemExtent,
              physics: const FixedExtentScrollPhysics(),
              diameterRatio: 1000,
              perspective: 0.0001,
              squeeze: 1,
              onSelectedItemChanged: onChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: labels.length,
                builder: (context, index) {
                  final isSelected = index == selectedIndex;
                  return RotatedBox(
                    quarterTurns: 1,
                    child: Center(
                      child: ReText(
                        labels[index],
                        fontSize: darkSelected ? _rf(15) : _rf(14),
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? (darkSelected
                                ? AppColors.white
                                : AppColors.black1)
                            : AppColors.dark6Color,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
          ).tMargin(2),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ReText(
                          'تاریخ تولد',
                          fontSize: _rf(19),
                          fontWeight: FontWeight.w900,
                          color: AppColors.black1,
                        ),
                        const SizedBox(height: 2),
                        ReText(
                          'انتخاب تاریخ تولد',
                          fontSize: _rf(13),
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark6Color,
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.gray2),
                            color: AppColors.gray1,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: AppColors.black1,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSliderRow(
                labels: _yearOptions.map((year) => year.toString()).toList(),
                selectedIndex: _yearIndex,
                controller: _yearController,
                onChanged: (index) {
                  setState(() {
                    _yearIndex = index;
                    _rebuildDays();
                  });
                },
                selectedWidth: 74,
                itemExtent: 58,
              ),
              const SizedBox(height: 10),
              _buildSliderRow(
                labels:
                    _monthOptions.map((month) => _months[month - 1]).toList(),
                selectedIndex: _monthIndex,
                controller: _monthController,
                onChanged: (index) {
                  setState(() {
                    _monthIndex = index;
                    _rebuildDays();
                  });
                },
                selectedWidth: 94,
                itemExtent: 72,
              ),
              const SizedBox(height: 10),
              _buildSliderRow(
                labels: _dayOptions.map((day) => day.toString()).toList(),
                selectedIndex: _dayIndex,
                controller: _dayController,
                onChanged: (index) {
                  setState(() {
                    _dayIndex = index;
                  });
                },
                selectedWidth: 40,
                itemExtent: 44,
                darkSelected: true,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 11,
                    child: ReButton(
                      text: 'ثبت',
                      textDirection: TextDirection.ltr,
                      icon: Icons.arrow_back_ios_new_rounded,
                      iconSize: 14,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      background: AppColors.primary,
                      textColor: AppColors.white,
                      onPressed: () {
                        Navigator.of(context).pop(
                          Jalali(
                            _yearOptions[_yearIndex],
                            _monthOptions[_monthIndex],
                            _dayOptions[_dayIndex],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 9,
                    child: ReButton(
                      textDirection: TextDirection.ltr,
                      text: 'لغو',
                      iconSize: 14,
                      isOutlined: true,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      icon: Icons.close,
                      background: AppColors.gray1,
                      textColor: AppColors.black1,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
