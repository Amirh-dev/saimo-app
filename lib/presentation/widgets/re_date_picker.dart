import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:solar_icons/solar_icons.dart';

import '_widgets.dart';

class ReDatePicker extends StatefulWidget {
  final Function(Jalali?) onDateChanged;
  final Jalali? initialDate;
  final String placeholder;
  final int startYear;
  final int endYear;

  const ReDatePicker({
    super.key,
    required this.onDateChanged,
    this.initialDate,
    this.placeholder = 'انتخاب تاریخ',
    this.startYear = 1280,
    this.endYear = 1410,
  });

  @override
  State<ReDatePicker> createState() => _ReDatePickerState();
}

class _ReDatePickerState extends State<ReDatePicker> {
  late Jalali? _selectedDate;
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  final List<String> _monthNames = [
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
    'اسفند'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate;
      _selectedYear = _selectedDate!.year;
      _selectedMonth = _selectedDate!.month;
      _selectedDay = _selectedDate!.day;
    } else {
      _selectedDate = null;
      final now = Jalali.now();
      _selectedYear = now.year;
      _selectedMonth = now.month;
      _selectedDay = now.day;
    }
  }

  int _getDaysInMonth(int year, int month) {
    if (month <= 6) {
      return 31;
    } else if (month <= 11) {
      return 30;
    } else {
      // For month 12 (Esfand), check if it's a leap year
      return _isLeapYear(year) ? 30 : 29;
    }
  }

  bool _isLeapYear(int year) {
    // Jalali leap year calculation
    final breaks = [
      -61,
      9,
      38,
      199,
      426,
      686,
      756,
      818,
      1111,
      1181,
      1210,
      1635,
      2060,
      2097,
      2192,
      2262,
      2324,
      2394,
      2456,
      3178
    ];

    int gYear = year + 1600;
    int leapAdj = 0;

    for (var i = 0; i < breaks.length; i++) {
      int ibDate = breaks[i];
      if (ibDate < gYear) {
        leapAdj = breaks[i];
      }
    }

    int jp = breaks[0];
    int jump = 0;

    for (var i = 1; i < breaks.length; i++) {
      var jm = breaks[i];
      jump = jm - jp;
      if (jm > gYear) break;
      jp = jm;
    }

    int n = gYear - jp;

    if (jump - n < 6) {
      n = n + ((jump - n) ~/ 33) * 33;
    }

    return ((n + 1) % 33) % 4 == 0 && ((n + 1) % 33) != 1;
  }

  String _formatDateDisplay() {
    if (_selectedDate == null) {
      return widget.placeholder;
    }
    return '$_selectedYear/${_selectedMonth.toString().padLeft(2, '0')}/${_selectedDay.toString().padLeft(2, '0')}';
  }

  void _updateDate() {
    try {
      _selectedDate = Jalali(_selectedYear, _selectedMonth, _selectedDay);
      widget.onDateChanged(_selectedDate);
    } catch (e) {
      // Invalid date
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDatePickerModal(context);
      },
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.white,
          border: Border.all(color: AppColors.dark2Color),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              SolarIconsOutline.calendar,
              size: 18,
              color: AppColors.black1,
            ).hMargin(16),
            Flexible(
              child: ReText(
                _formatDateDisplay(),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _selectedDate == null
                    ? Colors.grey.shade500
                    : AppColors.black1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDatePickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _DatePickerModal(
        initialYear: _selectedYear,
        initialMonth: _selectedMonth,
        initialDay: _selectedDay,
        startYear: widget.startYear,
        endYear: widget.endYear,
        monthNames: _monthNames,
        getDaysInMonth: _getDaysInMonth,
        onDateSelected: (year, month, day) {
          setState(() {
            _selectedYear = year;
            _selectedMonth = month;
            _selectedDay = day;
            _updateDate();
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _DatePickerModal extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final int initialDay;
  final int startYear;
  final int endYear;
  final List<String> monthNames;
  final int Function(int, int) getDaysInMonth;
  final Function(int, int, int) onDateSelected;

  const _DatePickerModal({
    required this.initialYear,
    required this.initialMonth,
    required this.initialDay,
    required this.startYear,
    required this.endYear,
    required this.monthNames,
    required this.getDaysInMonth,
    required this.onDateSelected,
  });

  @override
  State<_DatePickerModal> createState() => _DatePickerModalState();
}

class _DatePickerModalState extends State<_DatePickerModal> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    _selectedMonth = widget.initialMonth;
    _selectedDay = widget.initialDay;

    _yearController = FixedExtentScrollController(
      initialItem: _selectedYear - widget.startYear,
    );
    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonth - 1,
    );
    _dayController = FixedExtentScrollController(
      initialItem: _selectedDay - 1,
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  int _getDaysInCurrentMonth() {
    return widget.getDaysInMonth(_selectedYear, _selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.gray2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const ReText(
                    'انصراف',
                    color: AppColors.black1,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const ReText(
                  'انتخاب تاریخ تولد',
                  color: AppColors.black1,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                GestureDetector(
                  onTap: () {
                    widget.onDateSelected(
                        _selectedYear, _selectedMonth, _selectedDay);
                  },
                  child: const ReText(
                    'تایید',
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Pickers
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              children: [
                // Year Picker
                Expanded(
                  child: Column(
                    children: [
                      const ReText(
                        'سال',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black1,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 150,
                        child: CupertinoPicker(
                          scrollController: _yearController,
                          itemExtent: 40,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedYear = widget.startYear + index;
                              // Adjust day if current day exceeds max days in month
                              int maxDays = widget.getDaysInMonth(
                                _selectedYear,
                                _selectedMonth,
                              );
                              if (_selectedDay > maxDays) {
                                _selectedDay = maxDays;
                              }
                            });
                          },
                          children: List.generate(
                            widget.endYear - widget.startYear + 1,
                            (index) {
                              int year = widget.startYear + index;
                              return Center(
                                child: ReText(
                                  convertToPersianNumbers(year.toString()),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black1,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Month Picker
                Expanded(
                  child: Column(
                    children: [
                      const ReText(
                        'ماه',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black1,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 150,
                        child: CupertinoPicker(
                          scrollController: _monthController,
                          itemExtent: 40,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedMonth = index + 1;
                              // Adjust day if current day exceeds max days in month
                              int maxDays = widget.getDaysInMonth(
                                _selectedYear,
                                _selectedMonth,
                              );
                              if (_selectedDay > maxDays) {
                                _selectedDay = maxDays;
                              }
                            });
                          },
                          children: List.generate(
                            widget.monthNames.length,
                            (index) {
                              return Center(
                                child: ReText(
                                  widget.monthNames[index],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black1,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Day Picker
                Expanded(
                  child: Column(
                    children: [
                      const ReText(
                        'روز',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black1,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 150,
                        child: CupertinoPicker(
                          scrollController: _dayController,
                          itemExtent: 40,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedDay = index + 1;
                            });
                          },
                          children: List.generate(
                            _getDaysInCurrentMonth(),
                            (index) {
                              int day = index + 1;
                              return Center(
                                child: ReText(
                                  convertToPersianNumbers(
                                    day.toString().padLeft(2, '0'),
                                  ),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black1,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).hMargin(16),
          ),
        ],
      ),
    );
  }
}
