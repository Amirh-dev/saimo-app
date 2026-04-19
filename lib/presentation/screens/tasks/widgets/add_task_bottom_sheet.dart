import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/widgets/re_button.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/extentions.dart';
import 'package:simo_learn/utils/helpers.dart';

class AddTaskBottomSheet extends StatefulWidget {
  const AddTaskBottomSheet({super.key});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  bool _isWeeklyRepeat = false;
  bool _isReminderEnabled = false;
  late Jalali _selectedDate;
  late TimeOfDay _selectedTime;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagController;

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

  @override
  void initState() {
    super.initState();
    _selectedDate = Jalali.now();
    _selectedTime = TimeOfDay.fromDateTime(DateTime.now());
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _tagController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  int get _descriptionCount => _descriptionController.text.length;

  int get _tagsCount {
    return _tagController.text
        .split(RegExp(r'[,\u060C]'))
        .where((tag) => tag.trim().isNotEmpty)
        .length;
  }

  bool get _isFormValid => _titleController.text.trim().isNotEmpty;

  String get _formattedDate {
    final today = Jalali.now();
    final isToday = _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
    final prefix = isToday ? 'امروز، ' : '';
    final hour = _selectedTime.hour.toString().padLeft(2, '0');
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    return '$prefix${_selectedDate.day} ${_persianMonths[_selectedDate.month - 1]} ${_selectedDate.year} - $hour:$minute';
  }

  Future<void> _pickPersianDateTime() async {
    final result = await showModalBottomSheet<_PersianDateTimePickerResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.black1.withOpacity(0.2),
      builder: (_) => _PersianDateTimePickerSheet(
        initialDate: _selectedDate,
        initialTime: _selectedTime,
        monthNames: _persianMonths,
      ),
    );

    if (result == null) return;

    setState(() {
      _selectedDate = result.date;
      _selectedTime = result.time;
    });
  }

  void _submitTask() {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: ReText(
            'عنوان تسک را وارد کنید',
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      return;
    }

    final description = _descriptionController.text.trim();
    final tags = _tagController.text.trim();
    final time =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    Navigator.of(context).pop(
      <String, dynamic>{
        'title': _titleController.text.trim(),
        'subtitle': description.isNotEmpty
            ? description
            : (tags.isNotEmpty ? tags : 'توضیحی ثبت نشده'),
        'time': time,
        'status': 'pending',
        'date': _selectedDate,
        'tags': tags,
        'repeatWeekly': _isWeeklyRepeat,
        'reminder': _isReminderEnabled,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = context.deviceWidth;
    final horizontalPadding = width < 360 ? 14.0 : 18.0;
    final sectionSpacing = width < 360 ? 10.0 : 12.0;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.gray1,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(34),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    10,
                    horizontalPadding,
                    14,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(context),
                      SizedBox(height: sectionSpacing),
                      _buildField(
                        hintText: 'عنوان',
                        controller: _titleController,
                      ),
                      SizedBox(height: sectionSpacing),
                      _buildField(
                        hintText: 'توضیح کوتاه',
                        controller: _descriptionController,
                        maxLength: 50,
                        leadingText:
                            '${_descriptionCount > 50 ? 50 : _descriptionCount}/50',
                      ),
                      SizedBox(height: sectionSpacing),
                      _buildField(
                        hintText: 'افزودن تگ',
                        controller: _tagController,
                        leadingText: '${_tagsCount > 2 ? 2 : _tagsCount}/2',
                      ),
                      SizedBox(height: sectionSpacing + 4),
                      _buildDateCard(),
                      SizedBox(height: sectionSpacing + 2),
                      _buildReminderCard(),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              text: 'لغو',
                              icon: Icons.close,
                              background: AppColors.gray1,
                              textColor: AppColors.black1,
                              borderColor: AppColors.gray2,
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: _ActionButton(
                              text: 'افزودن',
                              icon: Icons.add,
                              background: AppColors.primary,
                              textColor: AppColors.white,
                              onTap: _submitTask,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 62,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ReText(
                'افزودن چک لیست',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.black1,
                textAlign: TextAlign.center,
              ),
              ReText(
                'افزودن تسک چک لیست',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.dark6Color,
                textAlign: TextAlign.center,
              ),
            ],
          ).rMargin(10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 48,
                height: 48,
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
    );
  }

  Widget _buildField({
    required String hintText,
    required TextEditingController controller,
    String? leadingText,
    int? maxLength,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.gray2,
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          if (leadingText != null) ...[
            ReText(
              leadingText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.black1.withOpacity(0.35),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: maxLength,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              inputFormatters: const [
                PersianDigitsInputFormatter(),
              ],
              onChanged: (_) {
                setState(() {});
              },
              style: const TextStyle(
                fontFamily: 'Sanse',
                color: AppColors.black1,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontVariations: <FontVariation>[
                  FontVariation.weight(500),
                ],
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                counterText: '',
                isDense: true,
                hintStyle: TextStyle(
                  fontFamily: 'Sanse',
                  color: AppColors.black1.withOpacity(0.45),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontVariations: const <FontVariation>[
                    FontVariation.weight(500),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.gray2),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(width: 8),
              const ReText(
                'تاریخ',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black1,
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickPersianDateTime,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.gray1,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.gray2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.black1,
                    size: 16,
                  ),
                  const Spacer(),
                  ReText(
                    _formattedDate,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black1,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(
            color: AppColors.gray2,
            thickness: 1,
            height: 1,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isWeeklyRepeat = !_isWeeklyRepeat;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.dark4Color),
                    ),
                    child: _isWeeklyRepeat
                        ? Container(
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  const Spacer(),
                  const ReText(
                    'تـکــــرار هفتگی',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark7Color,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.gray2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isReminderEnabled = !_isReminderEnabled;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 44,
              height: 28,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _isReminderEnabled
                    ? AppColors.primary.withOpacity(0.25)
                    : AppColors.gray2,
                borderRadius: BorderRadius.circular(100),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                alignment: _isReminderEnabled
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isReminderEnabled
                        ? AppColors.primary
                        : AppColors.dark4Color,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          const ReText(
            'یادآوری',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black1,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
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
    return SizedBox(
      height: 56,
      child: ReButton(
        onPressed: onTap,
        text: text,
        icon: icon,
        fontSize: 16,
        iconSize: 18,
        fontWeight: FontWeight.w800,
        background: background,
        textDirection: TextDirection.ltr,
        textColor: textColor,
        isOutlined: borderColor != null,
        color: borderColor,
      ),
    );
  }
}

class _PersianDateTimePickerResult {
  const _PersianDateTimePickerResult({
    required this.date,
    required this.time,
  });

  final Jalali date;
  final TimeOfDay time;
}

class _PersianDateTimePickerSheet extends StatefulWidget {
  const _PersianDateTimePickerSheet({
    required this.initialDate,
    required this.initialTime,
    required this.monthNames,
  });

  final Jalali initialDate;
  final TimeOfDay initialTime;
  final List<String> monthNames;

  @override
  State<_PersianDateTimePickerSheet> createState() =>
      _PersianDateTimePickerSheetState();
}

class _PersianDateTimePickerSheetState
    extends State<_PersianDateTimePickerSheet> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;
  late int _selectedHour;
  late int _selectedMinute;

  late List<int> _years;
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    final now = Jalali.now();

    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;

    _years = List<int>.generate(
      61,
      (index) => now.year - 20 + index,
    );

    final yearInitialIndex = _years.indexOf(_selectedYear);
    if (yearInitialIndex == -1) {
      _selectedYear = _years[20];
    }
    _yearController = FixedExtentScrollController(
      initialItem: yearInitialIndex == -1 ? 20 : yearInitialIndex,
    );
    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonth - 1,
    );
    _dayController = FixedExtentScrollController(
      initialItem: _selectedDay - 1,
    );
    _hourController = FixedExtentScrollController(
      initialItem: _selectedHour,
    );
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute,
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  int get _daysInSelectedMonth =>
      Jalali(_selectedYear, _selectedMonth, 1).monthLength;

  void _normalizeDayIfNeeded() {
    final maxDay = _daysInSelectedMonth;
    if (_selectedDay <= maxDay) return;

    _selectedDay = maxDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dayController.hasClients) return;
      _dayController.jumpToItem(_selectedDay - 1);
    });
  }

  Widget _buildWheelPicker({
    required String label,
    required int itemCount,
    required FixedExtentScrollController controller,
    required ValueChanged<int> onChanged,
    required String Function(int index) itemTextBuilder,
  }) {
    return Expanded(
      child: Column(
        children: [
          ReText(
            label,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.black1,
          ),
          const SizedBox(height: 8),
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.gray1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gray2),
            ),
            child: CupertinoPicker(
              scrollController: controller,
              itemExtent: 36,
              useMagnifier: true,
              magnification: 1.05,
              onSelectedItemChanged: onChanged,
              selectionOverlay: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.28),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              children: List<Widget>.generate(
                itemCount,
                (index) => Center(
                  child: ReText(
                    itemTextBuilder(index),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSelection() {
    Navigator.of(context).pop(
      _PersianDateTimePickerResult(
        date: Jalali(_selectedYear, _selectedMonth, _selectedDay),
        time: TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.gray2,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 12),
              const ReText(
                'انتخاب تاریخ و زمان',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.black1,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildWheelPicker(
                    label: 'سال',
                    itemCount: _years.length,
                    controller: _yearController,
                    onChanged: (index) {
                      setState(() {
                        _selectedYear = _years[index];
                        _normalizeDayIfNeeded();
                      });
                    },
                    itemTextBuilder: (index) => _years[index].toString(),
                  ),
                  const SizedBox(width: 8),
                  _buildWheelPicker(
                    label: 'ماه',
                    itemCount: widget.monthNames.length,
                    controller: _monthController,
                    onChanged: (index) {
                      setState(() {
                        _selectedMonth = index + 1;
                        _normalizeDayIfNeeded();
                      });
                    },
                    itemTextBuilder: (index) => widget.monthNames[index],
                  ),
                  const SizedBox(width: 8),
                  _buildWheelPicker(
                    label: 'روز',
                    itemCount: _daysInSelectedMonth,
                    controller: _dayController,
                    onChanged: (index) {
                      setState(() {
                        _selectedDay = index + 1;
                      });
                    },
                    itemTextBuilder: (index) => (index + 1).toString(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildWheelPicker(
                    label: 'ساعت',
                    itemCount: 24,
                    controller: _hourController,
                    onChanged: (index) {
                      setState(() {
                        _selectedHour = index;
                      });
                    },
                    itemTextBuilder: (index) =>
                        index.toString().padLeft(2, '0'),
                  ),
                  const SizedBox(width: 10),
                  _buildWheelPicker(
                    label: 'دقیقه',
                    itemCount: 60,
                    controller: _minuteController,
                    onChanged: (index) {
                      setState(() {
                        _selectedMinute = index;
                      });
                    },
                    itemTextBuilder: (index) =>
                        index.toString().padLeft(2, '0'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ReButton(
                        onPressed: () => Navigator.of(context).pop(),
                        text: 'لغو',
                        textColor: AppColors.black1,
                        background: AppColors.white,
                        isOutlined: true,
                        color: AppColors.gray2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ReButton(
                        onPressed: _confirmSelection,
                        text: 'تایید',
                        background: AppColors.primary,
                        textColor: AppColors.white,
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
