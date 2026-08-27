import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/extentions.dart';

/// خروجی انتخاب بازه زمانی
class DateRangeResult {
  final Jalali startDate;
  final Jalali? endDate;
  final bool isUntilToday;

  DateRangeResult({
    required this.startDate,
    this.endDate,
    this.isUntilToday = false,
  });
}

enum _PickerView { main, selectStart, selectEnd }

class DateRangePickerBottomSheet extends StatefulWidget {
  const DateRangePickerBottomSheet({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.isUntilToday = false,
  });

  final Jalali? initialStartDate;
  final Jalali? initialEndDate;
  final bool isUntilToday;

  static Future<DateRangeResult?> show(
    BuildContext context, {
    Jalali? initialStartDate,
    Jalali? initialEndDate,
    bool isUntilToday = false,
  }) {
    return showReModalBottomSheet<DateRangeResult>(
      context: context,
      isScrollControlled: false,
      builder: (_) => DateRangePickerBottomSheet(
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
        isUntilToday: isUntilToday,
      ),
    );
  }

  @override
  State<DateRangePickerBottomSheet> createState() =>
      _DateRangePickerBottomSheetState();
}

class _DateRangePickerBottomSheetState
    extends State<DateRangePickerBottomSheet> {
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

  _PickerView _activeView = _PickerView.main;
  Jalali? _startDate;
  Jalali? _endDate;
  bool _isUntilToday = false;

  // نگهدارنده مقدار تاریخ هنگام چرخاندن Wheel Picker
  late Jalali _tempPickerDate;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _isUntilToday = widget.isUntilToday;
    _tempPickerDate = _startDate ?? Jalali.now();
  }

  String _formatJalali(Jalali? date) {
    if (date == null) return 'انتخاب تاریخ';
    final monthName = _persianMonths[date.month - 1];
    return toPersianNumber('${date.day} $monthName ${date.year}', separated: false);
  }

  void _openWheelPicker(_PickerView view) {
    final initial = (view == _PickerView.selectStart ? _startDate : _endDate) ??
        Jalali.now();
    setState(() {
      _tempPickerDate = initial;
      _activeView = view;
      _errorMessage = null;
    });
  }

  void _confirmWheelPicker() {
    setState(() {
      if (_activeView == _PickerView.selectStart) {
        _startDate = _tempPickerDate;
      } else if (_activeView == _PickerView.selectEnd) {
        _endDate = _tempPickerDate;
      }
      _activeView = _PickerView.main;
    });
  }

  void _submitRange() {
    if (_startDate == null) {
      setState(() => _errorMessage = 'لطفاً تاریخ شروع را انتخاب کنید.');
      return;
    }
    if (!_isUntilToday && _endDate == null) {
      setState(() => _errorMessage = 'لطفاً تاریخ پایان را انتخاب کنید.');
      return;
    }
    if (!_isUntilToday && _endDate != null && _startDate!.isAfter(_endDate!)) {
      setState(() =>
          _errorMessage = 'تاریخ شروع نمی‌تواند بعد از تاریخ پایان باشد.');
      return;
    }

    Navigator.of(context).pop(
      DateRangeResult(
        startDate: _startDate!,
        endDate: _isUntilToday ? Jalali.now() : _endDate,
        isUntilToday: _isUntilToday,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final sheetHeight = math.min(
      620.0,
      math.max(490.0, screenHeight * 0.65 - keyboardHeight),
    );

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        key: const ValueKey('date-range-picker-sheet'),
        height: sheetHeight,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(34),
            topRight: Radius.circular(34),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Handle top bar
              Container(
                width: 62,
                height: 5,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 16, 28, 20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _activeView == _PickerView.main
                        ? _buildMainView()
                        : _buildWheelPickerView(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// نمای اول: انتخاب از تاریخ و تا تاریخ
  Widget _buildMainView() {
    return Column(
      key: const ValueKey('main_view'),
      children: [
        _SheetHeader(
          title: 'انتخاب بازه زمانی',
          subtitle: 'انتخاب بازه زمانی مشخص',
          onClose: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const ReText(
                  'از تاریخ',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black1,
                ).bMargin(6),
                _DateSelectorTile(
                  text: _formatJalali(_startDate),
                  isSelected: _startDate != null,
                  onTap: () => _openWheelPicker(_PickerView.selectStart),
                ),
                const SizedBox(height: 16),
                const ReText(
                  'تا تاریخ',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black1,
                ).bMargin(6),
                Opacity(
                  opacity: _isUntilToday ? 0.4 : 1.0,
                  child: _DateSelectorTile(
                    text: _isUntilToday ? 'امروز' : _formatJalali(_endDate),
                    isSelected: _endDate != null || _isUntilToday,
                    onTap: _isUntilToday
                        ? null
                        : () => _openWheelPicker(_PickerView.selectEnd),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isUntilToday = !_isUntilToday;
                      _errorMessage = null;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const ReText(
                        'تا امروز',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black1,
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _isUntilToday,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _isUntilToday = val ?? false;
                              _errorMessage = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (_errorMessage != null)
                  ReText(
                    _errorMessage!,
                    color: AppColors.errorColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ).tMargin(10),
              ],
            ),
          ),
        ),
        _buildBottomActions(
          onSubmit: _submitRange,
          onCancel: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// نمای دوم: انتخاب چرخشی تاریخ (Wheel Picker)
  Widget _buildWheelPickerView() {
    final isStart = _activeView == _PickerView.selectStart;

    return Column(
      key: const ValueKey('picker_view'),
      children: [
        _SheetHeader(
          title: isStart ? 'از تاریخ' : 'تا تاریخ',
          subtitle: isStart
              ? 'انتخاب تاریخ شروع بازه زمانی'
              : 'انتخاب تاریخ پایان بازه زمانی',
          onClose: () => setState(() => _activeView = _PickerView.main),
        ),
        const SizedBox(height: 10),
        // Header columns
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: ReText(
                    'سال',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: ReText(
                    'ماه',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: ReText(
                    'روز',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                // روز
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40,
                    scrollController: FixedExtentScrollController(
                      initialItem: _tempPickerDate.day - 1,
                    ),
                    onSelectedItemChanged: (index) {
                      _tempPickerDate = _tempPickerDate.copy(day: index + 1);
                    },
                    children: List.generate(
                      _tempPickerDate.monthLength,
                      (i) => Center(
                        child: ReText(
                          toPersianNumber('${i + 1}'),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                // ماه
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40,
                    scrollController: FixedExtentScrollController(
                      initialItem: _tempPickerDate.month - 1,
                    ),
                    onSelectedItemChanged: (index) {
                      final newMonth = index + 1;
                      final maxDays =
                          Jalali(_tempPickerDate.year, newMonth).monthLength;
                      final newDay = math.min(_tempPickerDate.day, maxDays);
                      _tempPickerDate = _tempPickerDate.copy(
                        month: newMonth,
                        day: newDay,
                      );
                      setState(() {});
                    },
                    children: _persianMonths
                        .map(
                          (m) => Center(
                            child: ReText(
                              m,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                // سال
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40,
                    scrollController: FixedExtentScrollController(
                      initialItem: _tempPickerDate.year - 1385,
                    ),
                    onSelectedItemChanged: (index) {
                      _tempPickerDate =
                          _tempPickerDate.copy(year: 1385 + index);
                    },
                    children: List.generate(
                      65, // 1385 تا 1450
                      (i) => Center(
                        child: ReText(
                          toPersianNumber('${1385 + i}', separated: false),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildBottomActions(
          onSubmit: _confirmWheelPicker,
          onCancel: () => setState(() => _activeView = _PickerView.main),
        ),
      ],
    );
  }

  /// دکمه‌های پایین (ثبت و لغو)
  Widget _buildBottomActions({
    required VoidCallback onSubmit,
    required VoidCallback onCancel,
  }) {
    return Row(
      children: [
        Expanded(
          child: ReButton(
            text: 'ثبت',
            icon: Icons.arrow_forward_ios,
            reverseIconPosition: true,
            onPressed: onSubmit,
            height: 54,
            borderRadius: 100,
            background: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 112,
          child: ReButton(
            text: 'لغو',
            icon: Icons.close_rounded,
            reverseIconPosition: true,
            onPressed: onCancel,
            height: 54,
            borderRadius: 100,
            isOutlined: true,
            background: AppColors.white,
            color: AppColors.gray2,
            textColor: AppColors.black1,
          ),
        ),
      ],
    );
  }
}

/// کامپوننت هدر با همان دکمه بسته شدن گرد
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.title,
    required this.subtitle,
    required this.onClose,
  });

  final String title;
  final String subtitle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ReText(
                  title,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
                const SizedBox(height: 4),
                ReText(
                  subtitle,
                  color: AppColors.gray,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gray2),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.gray,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// کامپوننت فیلدهای انتخاب تاریخ
class _DateSelectorTile extends StatelessWidget {
  const _DateSelectorTile({
    required this.text,
    required this.isSelected,
    this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.gray1,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.gray,
              size: 22,
            ),
            ReText(
              text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? AppColors.black1 : AppColors.gray,
            ),
          ],
        ),
      ),
    );
  }
}
