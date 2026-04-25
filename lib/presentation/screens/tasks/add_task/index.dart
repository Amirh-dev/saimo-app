import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/widgets/re_button.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/_utils.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  bool _isWeeklyRepeat = false;
  bool _isReminderEnabled = false;
  late Jalali _selectedDate;
  late Jalali _visibleCalendarMonth;
  late TimeOfDay _selectedTime;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagController;
  late FocusNode _titleFocusNode;
  late FocusNode _descriptionFocusNode;
  late FocusNode _tagFocusNode;

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
    _visibleCalendarMonth = Jalali(_selectedDate.year, _selectedDate.month, 1);
    _selectedTime = TimeOfDay.fromDateTime(DateTime.now());
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _tagController = TextEditingController();
    _titleFocusNode = FocusNode()..addListener(_handleFieldFocusChange);
    _descriptionFocusNode = FocusNode()..addListener(_handleFieldFocusChange);
    _tagFocusNode = FocusNode()..addListener(_handleFieldFocusChange);
  }

  @override
  void dispose() {
    _titleFocusNode
      ..removeListener(_handleFieldFocusChange)
      ..dispose();
    _descriptionFocusNode
      ..removeListener(_handleFieldFocusChange)
      ..dispose();
    _tagFocusNode
      ..removeListener(_handleFieldFocusChange)
      ..dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _handleFieldFocusChange() {
    if (!mounted) return;
    setState(() {});
  }

  int get _descriptionCount => _descriptionController.text.length;

  int get _tagsCount {
    return _tagController.text
        .split(RegExp(r'[,\u060C]'))
        .where((tag) => tag.trim().isNotEmpty)
        .length;
  }

  bool get _isFormValid => _titleController.text.trim().isNotEmpty;

  String get _scheduleDateLabel {
    final today = Jalali.now();
    final isToday = _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
    final prefix = isToday ? 'امروز، ' : '';
    return '$prefix${_selectedDate.day} ${_persianMonths[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  void _selectDateModeDirectly() {
    setState(() {
      _isWeeklyRepeat = false;
      _visibleCalendarMonth =
          Jalali(_selectedDate.year, _selectedDate.month, 1);
    });
  }

  void _selectWeeklyRepeatDirectly() {
    setState(() {
      _isWeeklyRepeat = true;
      _isReminderEnabled = true;
    });
  }

  int _compareJalaliDate(Jalali a, Jalali b) {
    if (a.year != b.year) return a.year.compareTo(b.year);
    if (a.month != b.month) return a.month.compareTo(b.month);
    return a.day.compareTo(b.day);
  }

  Jalali _addMonths(Jalali month, int delta) {
    final monthIndex = (month.year * 12) + month.month - 1 + delta;
    return Jalali(monthIndex ~/ 12, (monthIndex % 12) + 1, 1);
  }

  bool get _canGoToPreviousCalendarMonth {
    final today = Jalali.now();
    final currentMonth = Jalali(today.year, today.month, 1);
    return _compareJalaliDate(_visibleCalendarMonth, currentMonth) > 0;
  }

  void _goToPreviousCalendarMonth() {
    if (!_canGoToPreviousCalendarMonth) return;
    setState(() {
      _visibleCalendarMonth = _addMonths(_visibleCalendarMonth, -1);
    });
  }

  void _goToNextCalendarMonth() {
    setState(() {
      _visibleCalendarMonth = _addMonths(_visibleCalendarMonth, 1);
    });
  }

  void _selectCalendarDate(Jalali date) {
    final today = Jalali.now();
    if (_compareJalaliDate(date, today) < 0) return;

    setState(() {
      _selectedDate = date;
      _visibleCalendarMonth = Jalali(date.year, date.month, 1);
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

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
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
                        focusNode: _titleFocusNode,
                      ),
                      SizedBox(height: sectionSpacing),
                      _buildField(
                        hintText: 'توضیح کوتاه',
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                        maxLength: 50,
                        leadingText:
                            '${_descriptionCount > 50 ? 50 : _descriptionCount}/50',
                      ),
                      SizedBox(height: sectionSpacing),
                      _buildField(
                        hintText: 'افزودن تگ',
                        controller: _tagController,
                        focusNode: _tagFocusNode,
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
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.black1,
              ),
              ReText(
                'افزودن تسک چک لیست',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.gray,
                textAlign: TextAlign.center,
              ),
            ],
          ).rMargin(10).tMargin(3),
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
    required FocusNode focusNode,
    String? leadingText,
    int? maxLength,
  }) {
    final isFocused = focusNode.hasFocus;

    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(100),
        border: isFocused
            ? Border.all(
                color: AppColors.primary,
                width: 1.4,
              )
            : null,
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: AppColors.black1.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
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
              focusNode: focusNode,
              controller: controller,
              maxLength: maxLength,
              textAlign: TextAlign.right,
              textAlignVertical: TextAlignVertical.center,
              textDirection: TextDirection.rtl,
              cursorColor: AppColors.primary,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              inputFormatters: const [
                PersianDigitsInputFormatter(),
              ],
              onChanged: (_) {
                setState(() {});
              },
              style: TextStyle(
                fontFamily: AppFonts.iranSansVar,
                color: AppColors.black1,
                fontSize: 15,
                fontVariations: AppFonts.fontVariations(FontWeight.w600),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                counterText: '',
                isDense: true,
                hintStyle: TextStyle(
                  fontFamily: AppFonts.iranSansVar,
                  color: AppColors.black1.withOpacity(0.45),
                  fontSize: 13,
                  fontVariations: AppFonts.fontVariations(FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard() {
    return _ScheduleSelectionCard(
      formattedDateLabel: _scheduleDateLabel,
      isWeeklyRepeat: _isWeeklyRepeat,
      selectedDate: _selectedDate,
      visibleMonth: _visibleCalendarMonth,
      monthNames: _persianMonths,
      canGoToPreviousMonth: _canGoToPreviousCalendarMonth,
      onSelectDateMode: _selectDateModeDirectly,
      onDateSelected: _selectCalendarDate,
      onPreviousMonth: _goToPreviousCalendarMonth,
      onNextMonth: _goToNextCalendarMonth,
      onSelectWeeklyRepeat: _selectWeeklyRepeatDirectly,
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
          switchWidget(),
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

  GestureDetector switchWidget() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isReminderEnabled = !_isReminderEnabled;
        });
      },
      child: Transform.flip(
        flipX: true,
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
    );
  }
}

class _ScheduleSelectionCard extends StatelessWidget {
  const _ScheduleSelectionCard({
    required this.formattedDateLabel,
    required this.isWeeklyRepeat,
    required this.selectedDate,
    required this.visibleMonth,
    required this.monthNames,
    required this.canGoToPreviousMonth,
    required this.onSelectDateMode,
    required this.onDateSelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectWeeklyRepeat,
  });

  final String formattedDateLabel;
  final bool isWeeklyRepeat;
  final Jalali selectedDate;
  final Jalali visibleMonth;
  final List<String> monthNames;
  final bool canGoToPreviousMonth;
  final VoidCallback onSelectDateMode;
  final ValueChanged<Jalali> onDateSelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onSelectWeeklyRepeat;

  static const List<String> _weekDayLabels = [
    'ش',
    'ی',
    'د',
    'س',
    'چ',
    'پ',
    'ج',
  ];

  bool _isSameDay(Jalali a, Jalali b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _compareJalaliDate(Jalali a, Jalali b) {
    if (a.year != b.year) return a.year.compareTo(b.year);
    if (a.month != b.month) return a.month.compareTo(b.month);
    return a.day.compareTo(b.day);
  }

  int _persianWeekStartOffset(Jalali date) {
    return date.weekDay - 1;
  }

  List<Jalali?> _monthGridDates() {
    final firstDay = Jalali(visibleMonth.year, visibleMonth.month, 1);
    final leadingEmptyCells = _persianWeekStartOffset(firstDay);
    final dates = <Jalali?>[
      for (var i = 0; i < leadingEmptyCells; i++) null,
      for (var day = 1; day <= firstDay.monthLength; day++)
        Jalali(visibleMonth.year, visibleMonth.month, day),
    ];
    while (dates.length % 7 != 0) {
      dates.add(null);
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    final isDateModeSelected = !isWeeklyRepeat;
    final today = Jalali.now();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.gray2),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onSelectDateMode,
            behavior: HitTestBehavior.opaque,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              opacity: isDateModeSelected ? 1 : 0.55,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ReText(
                    'تاریخ',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDateModeSelected
                        ? AppColors.black1
                        : AppColors.dark7Color,
                  ),
                  const SizedBox(width: 8),
                  _RadioDot(isSelected: isDateModeSelected),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _SelectedDateSummary(
            formattedDateLabel: formattedDateLabel,
            isEnabled: isDateModeSelected,
            onTap: onSelectDateMode,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: isDateModeSelected
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildCalendar(today),
                  )
                : const SizedBox(width: double.infinity),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: isDateModeSelected
                ? const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Divider(
                      color: AppColors.gray2,
                      thickness: 1,
                      height: 1,
                    ),
                  )
                : const SizedBox(
                    key: ValueKey('date-divider-hidden'),
                    width: double.infinity,
                  ),
          ),
          GestureDetector(
            onTap: onSelectWeeklyRepeat,
            behavior: HitTestBehavior.opaque,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              opacity: isWeeklyRepeat ? 1 : 0.55,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ReText(
                      'تکرار هفتگی',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isWeeklyRepeat
                          ? AppColors.black1
                          : AppColors.dark7Color,
                    ),
                    const SizedBox(width: 8),
                    _RadioDot(isSelected: isWeeklyRepeat),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(Jalali today) {
    final dates = _monthGridDates();

    return Container(
      key: ValueKey('${visibleMonth.year}-${visibleMonth.month}'),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray2),
      ),
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 7),
      child: Column(
        children: [
          Row(
            textDirection: TextDirection.ltr,
            children: [
              _CalendarNavButton(
                icon: Icons.chevron_left_rounded,
                onTap: onNextMonth,
                isEnabled: true,
              ),
              const Spacer(),
              ReText(
                '${monthNames[visibleMonth.month - 1]} ${convertToPersianNumbers(visibleMonth.year.toString())}',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.black1,
              ),
              const Spacer(),
              _CalendarNavButton(
                icon: Icons.chevron_right_rounded,
                onTap: onPreviousMonth,
                isEnabled: canGoToPreviousMonth,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              for (final label in _weekDayLabels)
                Expanded(
                  child: Center(
                    child: ReText(
                      label,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dates.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              childAspectRatio: 1.22,
            ),
            itemBuilder: (context, index) {
              final date = dates[index];
              if (date == null) return const SizedBox.shrink();

              final isSelected = _isSameDay(date, selectedDate);
              final isToday = _isSameDay(date, today);
              final isDisabled = _compareJalaliDate(date, today) < 0;

              return _CalendarDayCell(
                date: date,
                isSelected: isSelected,
                isToday: isToday,
                isDisabled: isDisabled,
                onTap: isDisabled ? null : () => onDateSelected(date),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SelectedDateSummary extends StatelessWidget {
  const _SelectedDateSummary({
    required this.formattedDateLabel,
    required this.isEnabled,
    required this.onTap,
  });

  final String formattedDateLabel;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isEnabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        opacity: isEnabled ? 1 : 0.45,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.gray1,
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: AppColors.gray2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.gray,
                  size: 18,
                ),
                const Spacer(),
                ReText(
                  formattedDateLabel,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarNavButton extends StatelessWidget {
  const _CalendarNavButton({
    required this.icon,
    required this.onTap,
    required this.isEnabled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: isEnabled ? 1 : 0.28,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.gray1,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AppColors.gray2),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.black1,
          ),
        ),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.isDisabled,
    required this.onTap,
  });

  final Jalali date;
  final bool isSelected;
  final bool isToday;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? AppColors.primary
        : (isToday ? AppColors.primary.withOpacity(0.45) : AppColors.gray2);
    final textColor = isSelected
        ? AppColors.white
        : (isDisabled ? AppColors.dark5Color : AppColors.black1);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.gray1,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: ReText(
            convertToPersianNumbers(date.day.toString()),
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: textColor,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.dark4Color),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
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
