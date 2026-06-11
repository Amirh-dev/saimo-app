import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/create_task.req.gql.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/widgets/re_button.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/presentation/widgets/re_toast.dart';
import 'package:simo_learn/utils/_utils.dart';

DateTime _toDateTime(Jalali date, {TimeOfDay? time}) {
  final gregorian = date.toGregorian();
  return DateTime(
    gregorian.year,
    gregorian.month,
    gregorian.day,
    time?.hour ?? 0,
    time?.minute ?? 0,
  );
}

List<String> _parseTagNames(String value) {
  return value
      .split(RegExp(r'[,\u060C]'))
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .take(2)
      .toList();
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? _recurringDay(Jalali date, bool isWeeklyRepeat) {
  if (!isWeeklyRepeat) return null;
  return switch (date.weekDay) {
    1 => 'SAT',
    2 => 'SUN',
    3 => 'MON',
    4 => 'TUE',
    5 => 'WED',
    6 => 'THU',
    _ => 'FRI',
  };
}

class AddTimedTaskScreen extends StatefulWidget {
  const AddTimedTaskScreen({super.key, this.goalId});

  final String? goalId;

  @override
  State<AddTimedTaskScreen> createState() => _AddTimedTaskScreenState();
}

class _AddTimedTaskScreenState extends State<AddTimedTaskScreen> {
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

  static const List<int> _minuteOptions = [60, 55, 50, 45, 40, 35, 30];

  bool _isWeeklyRepeat = false;
  bool _isReminderEnabled = false;
  bool _isSubmitting = false;

  late Jalali _selectedDate;
  late Jalali _visibleCalendarMonth;

  int _selectedMinutes = 45;
  late PageController _minutesPageController;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagController;
  late TextEditingController _noteController;

  late FocusNode _titleFocusNode;
  late FocusNode _descriptionFocusNode;
  late FocusNode _tagFocusNode;
  late FocusNode _noteFocusNode;

  @override
  void initState() {
    super.initState();
    _selectedDate = Jalali.now();
    _visibleCalendarMonth = Jalali(_selectedDate.year, _selectedDate.month, 1);
    _selectedMinutes = _minuteOptions.contains(45) ? 45 : _minuteOptions.first;
    _minutesPageController = PageController(
      initialPage: _minuteOptions.indexOf(_selectedMinutes).clamp(
            0,
            _minuteOptions.length - 1,
          ),
      viewportFraction: 0.22,
    );
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _tagController = TextEditingController();
    _noteController = TextEditingController();
    _titleFocusNode = FocusNode()..addListener(_handleFieldFocusChange);
    _descriptionFocusNode = FocusNode()..addListener(_handleFieldFocusChange);
    _tagFocusNode = FocusNode()..addListener(_handleFieldFocusChange);
    _noteFocusNode = FocusNode()..addListener(_handleFieldFocusChange);
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
    _noteFocusNode
      ..removeListener(_handleFieldFocusChange)
      ..dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    _noteController.dispose();
    _minutesPageController.dispose();
    super.dispose();
  }

  void _handleFieldFocusChange() {
    if (!mounted) return;
    setState(() {});
  }

  bool get _isFormValid => _titleController.text.trim().isNotEmpty;

  int get _descriptionCount => _descriptionController.text.length;

  int get _noteCount => _noteController.text.length;

  int get _tagsCount {
    return _tagController.text
        .split(RegExp(r'[,\u060C]'))
        .where((tag) => tag.trim().isNotEmpty)
        .length;
  }

  String get _scheduleDateLabel {
    final today = Jalali.now();
    final isToday = _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
    final prefix = isToday ? 'امروز، ' : '';
    return '$prefix${_selectedDate.day} ${_persianMonths[_selectedDate.month - 1]} ${_selectedDate.year}';
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

  int _persianWeekStartOffset(Jalali date) {
    return date.weekDay - 1;
  }

  List<Jalali?> _monthGridDates(Jalali month) {
    final firstDay = Jalali(month.year, month.month, 1);
    final leadingEmptyCells = _persianWeekStartOffset(firstDay);
    final dates = <Jalali?>[
      for (var i = 0; i < leadingEmptyCells; i++) null,
      for (var day = 1; day <= firstDay.monthLength; day++)
        Jalali(month.year, month.month, day),
    ];
    while (dates.length % 7 != 0) {
      dates.add(null);
    }
    return dates;
  }

  Future<void> _openDatePickerSheet() async {
    final today = Jalali.now();
    var sheetMonth = _visibleCalendarMonth;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final monthLabel =
                '${_persianMonths[sheetMonth.month - 1]} ${sheetMonth.year}';
            final canGoPrev = _compareJalaliDate(
                  sheetMonth,
                  Jalali(today.year, today.month, 1),
                ) >
                0;
            final gridDates = _monthGridDates(sheetMonth);

            return SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(26),
                    topRight: Radius.circular(26),
                  ),
                ),
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
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _CalendarNavButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          isEnabled: true,
                          onTap: () {
                            setSheetState(() {
                              sheetMonth = _addMonths(sheetMonth, 1);
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        _CalendarNavButton(
                          icon: Icons.arrow_forward_ios_rounded,
                          isEnabled: canGoPrev,
                          onTap: () {
                            if (!canGoPrev) return;
                            setSheetState(() {
                              sheetMonth = _addMonths(sheetMonth, -1);
                            });
                          },
                        ),
                        const Spacer(),
                        ReText(
                          monthLabel,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black1,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: gridDates.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        childAspectRatio: 1.05,
                      ),
                      itemBuilder: (_, index) {
                        final date = gridDates[index];
                        if (date == null) return const SizedBox.shrink();

                        final isSelected = date.year == _selectedDate.year &&
                            date.month == _selectedDate.month &&
                            date.day == _selectedDate.day;
                        final isDisabled = _compareJalaliDate(date, today) < 0;
                        final isToday = date.year == today.year &&
                            date.month == today.month &&
                            date.day == today.day;

                        return _CalendarDayCell(
                          date: date,
                          isSelected: isSelected,
                          isToday: isToday,
                          isDisabled: isDisabled,
                          onTap: isDisabled
                              ? null
                              : () {
                                  setState(() {
                                    _selectedDate = date;
                                    _visibleCalendarMonth =
                                        Jalali(date.year, date.month, 1);
                                  });
                                  Navigator.of(sheetContext).pop();
                                },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openCalendarModal() async {
    final picked = await showModalBottomSheet<Jalali>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _ThreeColumnJalaliDatePickerSheet(
          initialDate: _selectedDate,
          minDate: Jalali.now(),
          monthNames: _persianMonths,
        );
      },
    );

    if (picked == null || !mounted) return;
    setState(() {
      _selectedDate = picked;
      _visibleCalendarMonth = Jalali(picked.year, picked.month, 1);
    });
  }

  Future<void> _submitTimedTask() async {
    if (!_isFormValid) {
      showReToast(context, 'عنوان تسک را وارد کنید', ReToastType.warning);
      return;
    }

    final description = _descriptionController.text.trim();
    final tags = _tagController.text.trim();
    final note = _noteController.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final taskDate = _toDateTime(_selectedDate);
      final response = await context.read<GraphQLRepository>().requestOnce(
        GCreateTaskReq(
          (request) {
            request.vars.input
              ..title = _titleController.text.trim()
              ..shortDescription = _emptyToNull(description)
              ..type = GTaskType.TIMED
              ..note = _emptyToNull(note)
              ..date.value = taskDate.toUtc().toIso8601String()
              ..durationM = _selectedMinutes
              ..hasReminder = _isReminderEnabled
              ..recurringDays = _recurringDay(_selectedDate, _isWeeklyRepeat)
              ..tagNames.addAll(_parseTagNames(tags));

            final goalId = _emptyToNull(widget.goalId ?? '');
            if (goalId != null) {
              request.vars.input.goalID = goalId;
            }

            if (_isReminderEnabled) {
              request.vars.input.reminderTime.value =
                  taskDate.toUtc().toIso8601String();
            }
          },
        ),
      );

      if (!mounted) return;

      if (response.hasErrors || response.data?.createTask == null) {
        showReToast(
          context,
          graphQLResponseErrorMessage(response),
          ReToastType.failed,
        );
        return;
      }

      final task = response.data!.createTask;
      final minutesLabel = convertToPersianNumbers(_selectedMinutes.toString());
      final subtitle = task.shortDescription?.trim().isNotEmpty == true
          ? task.shortDescription!.trim()
          : (task.note?.trim().isNotEmpty == true
              ? task.note!.trim()
              : (tags.isNotEmpty ? tags : 'توضیحی ثبت نشده'));
      final durationSeconds = (task.durationM ?? _selectedMinutes) * 60;

      Navigator.of(context).pop(
        <String, dynamic>{
          'id': task.id,
          'title': task.title,
          'subtitle': subtitle,
          'durationSeconds': durationSeconds,
          'remainingSeconds': durationSeconds,
          'status': 'pending',
          'label': '$minutesLabel دقیقه',
          'date': _selectedDate,
          'tags': tags,
          'note': task.note ?? note,
          'repeatWeekly': _isWeeklyRepeat,
          'reminder': task.hasReminder,
        },
      );
    } catch (error) {
      if (!mounted) return;
      showReToast(context, error.toString(), ReToastType.failed);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
                      _buildTimedHeader(context),
                      SizedBox(height: sectionSpacing),
                      _buildPillField(
                        hintText: 'عنوان',
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                      ),
                      SizedBox(height: sectionSpacing),
                      _buildPillField(
                        hintText: 'توضیح کوتاه',
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                        maxLength: 50,
                        leadingPill:
                            '${_descriptionCount > 50 ? 50 : _descriptionCount}/50',
                      ),
                      SizedBox(height: sectionSpacing),
                      _buildPillField(
                        hintText: 'افزودن تگ',
                        controller: _tagController,
                        focusNode: _tagFocusNode,
                        leadingPill: '${_tagsCount > 2 ? 2 : _tagsCount}/2',
                      ),
                      SizedBox(height: sectionSpacing + 2),
                      _buildDurationPicker(),
                      SizedBox(height: sectionSpacing),
                      _buildNoteField(),
                      SizedBox(height: sectionSpacing),
                      _buildDateCardCompact(),
                      SizedBox(height: sectionSpacing),
                      _buildReminderCardCompact(),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _ActionButton(
                              text: 'افزودن',
                              icon: Icons.add,
                              background: AppColors.primary,
                              textColor: AppColors.white,
                              isLoading: _isSubmitting,
                              onTap: _submitTimedTask,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ActionButton(
                              text: 'لغو',
                              icon: Icons.close,
                              background: AppColors.white,
                              textColor: AppColors.black1,
                              borderColor: AppColors.gray2,
                              onTap: _isSubmitting
                                  ? () {}
                                  : () => Navigator.of(context).pop(),
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

  Widget _buildTimedHeader(BuildContext context) {
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
                'افزودن تسک زمان دار',
                color: AppColors.black1,
                fontSize: 16,
                fontWeight: 1100,
              ),
              ReText(
                'افزودن تسک زمان دار',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.gray,
                textAlign: TextAlign.center,
              ),
            ],
          ).rMargin(16).tMargin(3),
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
                  color: AppColors.white,
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

  Widget _buildPillField({
    required String hintText,
    required TextEditingController controller,
    required FocusNode focusNode,
    String? leadingPill,
    int? maxLength,
  }) {
    final isFocused = focusNode.hasFocus;

    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(100),
        border:
            isFocused ? Border.all(color: AppColors.primary, width: 1.4) : null,
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
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          if (leadingPill != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gray2,
                borderRadius: BorderRadius.circular(100),
              ),
              child: ReText(
                leadingPill,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.black1.withOpacity(0.45),
                textDirection: TextDirection.ltr,
              ),
            ),
            const SizedBox(width: 10),
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

  Widget _buildDurationPicker() {
    const itemHeight = 44.0;
    const pickerHeight = 48.0;
    const highlightWidth = 64.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.gray2),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ReText(
                'دقیقه',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.black1.withOpacity(0.5),
              ).rMargin(4),
              const ReText(
                'تنظیم مدت زمان',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.black1,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.gray2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Selection highlight (fixed size so the wheel doesn't "jump")
                Container(
                  width: highlightWidth,
                  height: itemHeight,
                  decoration: BoxDecoration(
                    color: AppColors.black1,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                PageView.builder(
                  controller: _minutesPageController,
                  padEnds: true,
                  itemCount: _minuteOptions.length,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedMinutes = _minuteOptions[index];
                    });
                  },
                  itemBuilder: (context, index) {
                    final value = _minuteOptions[index];
                    final isSelected = value == _selectedMinutes;
                    return Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _minutesPageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                          );
                        },
                        child: SizedBox(
                          width: highlightWidth,
                          height: itemHeight,
                          child: Center(
                            child: ReText(
                              convertToPersianNumbers(value.toString()),
                              fontSize: isSelected ? 16 : 13,
                              fontWeight: FontWeight.w400,
                              color:
                                  isSelected ? AppColors.white : AppColors.gray,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteField() {
    final isFocused = _noteFocusNode.hasFocus;
    final safeCount = _noteCount > 200 ? 200 : _noteCount;

    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(32),
        border: isFocused
            ? Border.all(color: AppColors.primary, width: 1.4)
            : Border.all(color: Colors.transparent),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gray2,
              borderRadius: BorderRadius.circular(100),
            ),
            child: ReText(
              '${convertToPersianNumbers(safeCount.toString())}/200',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.black1.withOpacity(0.45),
              textDirection: TextDirection.ltr,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              focusNode: _noteFocusNode,
              controller: _noteController,
              maxLength: 200,
              maxLines: 4,
              minLines: 3,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              cursorColor: AppColors.primary,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              inputFormatters: const [
                PersianDigitsInputFormatter(),
              ],
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                fontFamily: AppFonts.iranSansVar,
                color: AppColors.black1,
                fontSize: 14,
                fontVariations: AppFonts.fontVariations(FontWeight.w600),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'یادداشت',
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

  Widget _buildDateCardCompact() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.gray2),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const ReText(
                'تاریخ',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.black1,
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.errorColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _openCalendarModal,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: AppColors.gray2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.gray1,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gray2),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.black1,
                      size: 18,
                    ),
                  ),
                  const Spacer(),
                  ReText(
                    _scheduleDateLabel,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black1,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _isWeeklyRepeat = !_isWeeklyRepeat;
                if (_isWeeklyRepeat) _isReminderEnabled = true;
              });
            },
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: AppColors.gray2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _CircleCheckbox(isChecked: _isWeeklyRepeat),
                  const Spacer(),
                  const ReText(
                    'تکرار هفتگی',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCardCompact() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.gray2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          _ReminderSwitch(
            value: _isReminderEnabled,
            onChanged: (value) {
              setState(() {
                _isReminderEnabled = value;
                if (!_isReminderEnabled) _isWeeklyRepeat = false;
              });
            },
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

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key, this.goalId});

  final String? goalId;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  bool _isWeeklyRepeat = false;
  bool _isReminderEnabled = false;
  bool _isSubmitting = false;
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
    _openCalendarModal();
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

  Future<void> _openCalendarModal() async {
    final picked = await showModalBottomSheet<Jalali>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _ThreeColumnJalaliDatePickerSheet(
          initialDate: _selectedDate,
          minDate: Jalali.now(),
          monthNames: _persianMonths,
        );
      },
    );

    if (picked == null || !mounted) return;
    setState(() {
      _selectedDate = picked;
      _visibleCalendarMonth = Jalali(picked.year, picked.month, 1);
    });
  }

  Future<void> _submitTask() async {
    if (!_isFormValid) {
      showReToast(context, 'عنوان تسک را وارد کنید', ReToastType.warning);
      return;
    }

    final description = _descriptionController.text.trim();
    final tags = _tagController.text.trim();
    final time =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    setState(() {
      _isSubmitting = true;
    });

    try {
      final taskDate = _toDateTime(_selectedDate, time: _selectedTime);
      final response = await context.read<GraphQLRepository>().requestOnce(
        GCreateTaskReq(
          (request) {
            request.vars.input
              ..title = _titleController.text.trim()
              ..shortDescription = _emptyToNull(description)
              ..type = GTaskType.NORMAL
              ..date.value = taskDate.toUtc().toIso8601String()
              ..hasReminder = _isReminderEnabled
              ..recurringDays = _recurringDay(_selectedDate, _isWeeklyRepeat)
              ..tagNames.addAll(_parseTagNames(tags));

            final goalId = _emptyToNull(widget.goalId ?? '');
            if (goalId != null) {
              request.vars.input.goalID = goalId;
            }

            if (_isReminderEnabled) {
              request.vars.input.reminderTime.value =
                  taskDate.toUtc().toIso8601String();
            }
          },
        ),
      );

      if (!mounted) return;

      if (response.hasErrors || response.data?.createTask == null) {
        showReToast(
          context,
          graphQLResponseErrorMessage(response),
          ReToastType.failed,
        );
        return;
      }

      final task = response.data!.createTask;
      Navigator.of(context).pop(
        <String, dynamic>{
          'id': task.id,
          'title': task.title,
          'subtitle': task.shortDescription?.trim().isNotEmpty == true
              ? task.shortDescription!.trim()
              : (tags.isNotEmpty ? tags : 'توضیحی ثبت نشده'),
          'time': time,
          'status': 'pending',
          'date': _selectedDate,
          'tags': tags,
          'repeatWeekly': _isWeeklyRepeat,
          'reminder': task.hasReminder,
        },
      );
    } catch (error) {
      if (!mounted) return;
      showReToast(context, error.toString(), ReToastType.failed);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _ActionButton(
                              text: 'افزودن',
                              icon: Icons.add,
                              background: AppColors.primary,
                              textColor: AppColors.white,
                              isLoading: _isSubmitting,
                              onTap: _submitTask,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ActionButton(
                              text: 'لغو',
                              icon: Icons.close,
                              background: AppColors.white,
                              textColor: AppColors.black1,
                              borderColor: AppColors.gray2,
                              onTap: _isSubmitting
                                  ? () {}
                                  : () {
                                      Navigator.of(context).pop();
                                    },
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReText(
                'افزودن چک لیست',
                color: AppColors.black1,
                fontSize: 16,
                fontWeight: 1000,
              ),
              ReText(
                'افزودن تسک چک لیست',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.gray,
                textAlign: TextAlign.center,
              ),
            ],
          ).rMargin(16).tMargin(3),
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
                  color: AppColors.white,
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
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.white,
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
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
          const SizedBox(height: 16),
          const Divider(
            color: AppColors.gray2,
            thickness: 1,
            height: 1,
          ),
          GestureDetector(
            onTap: onSelectWeeklyRepeat,
            behavior: HitTestBehavior.opaque,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              opacity: isWeeklyRepeat ? 1 : 0.55,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ReText(
                      'تـکــــرار هفتگی',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isWeeklyRepeat
                          ? AppColors.black1
                          : AppColors.dark7Color,
                    ),
                    const SizedBox(width: 8),
                    _RadioDot(isSelected: isWeeklyRepeat).bMargin(8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Calendar UI now opens in a modal sheet to match the design.
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
      ignoring: !isEnabled,
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
              color: AppColors.white,
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: AppColors.gray2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.black,
                  size: 12,
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
    this.isLoading = false,
  });

  final String text;
  final IconData icon;
  final Color background;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ReButton(
      onPressed: onTap,
      text: text,
      icon: icon,
      fontSize: 16,
      iconSize: 18,
      fontWeight: FontWeight.w800,
      background: background,
      isLoading: isLoading,
      textDirection: TextDirection.ltr,
      textColor: textColor,
      isOutlined: borderColor != null,
      color: borderColor,
    );
  }
}

class _CircleCheckbox extends StatelessWidget {
  const _CircleCheckbox({required this.isChecked});

  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isChecked
            ? AppColors.primary.withOpacity(0.12)
            : Colors.transparent,
        border: Border.all(
          color: isChecked ? AppColors.primary : AppColors.dark4Color,
          width: 1.2,
        ),
      ),
      child: isChecked
          ? const Center(
              child: Icon(
                Icons.check_rounded,
                size: 14,
                color: AppColors.primary,
              ),
            )
          : null,
    );
  }
}

class _ReminderSwitch extends StatelessWidget {
  const _ReminderSwitch({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Transform.flip(
        flipX: true,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 44,
          height: 28,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color:
                value ? AppColors.primary.withOpacity(0.25) : AppColors.gray2,
            borderRadius: BorderRadius.circular(100),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value ? AppColors.primary : AppColors.dark4Color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThreeColumnJalaliDatePickerSheet extends StatefulWidget {
  const _ThreeColumnJalaliDatePickerSheet({
    required this.initialDate,
    required this.minDate,
    required this.monthNames,
  });

  final Jalali initialDate;
  final Jalali minDate;
  final List<String> monthNames;

  @override
  State<_ThreeColumnJalaliDatePickerSheet> createState() =>
      _ThreeColumnJalaliDatePickerSheetState();
}

class _ThreeColumnJalaliDatePickerSheetState
    extends State<_ThreeColumnJalaliDatePickerSheet> {
  static const double _wheelItemExtent = 56.0;
  static const double _dayChipSize = 46.0;
  static const double _yearChipSize = 54.0;
  static const double _monthChipWidth = 108.0;
  static const double _monthChipHeight = 42.0;

  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  late List<int> _years;
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  FixedExtentScrollController? _dayController;

  @override
  void initState() {
    super.initState();
    final today = Jalali.now();
    final baseYear = today.year;

    _years = [for (var y = baseYear + 2; y >= baseYear - 4; y--) y];
    if (!_years.contains(widget.initialDate.year)) {
      _years = [
        widget.initialDate.year,
        ..._years.where((y) => y != widget.initialDate.year),
      ];
    }

    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;

    _yearController = FixedExtentScrollController(
      initialItem: _years.indexOf(_selectedYear).clamp(0, _years.length - 1),
    );
    _monthController = FixedExtentScrollController(
      initialItem: (_selectedMonth - 1).clamp(0, 11),
    );
    _resetDayController();
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController?.dispose();
    super.dispose();
  }

  void _resetDayController() {
    _dayController?.dispose();
    final days = _daysInSelectedMonth;
    _selectedDay = _selectedDay.clamp(1, days.length);
    _dayController = FixedExtentScrollController(
      initialItem: (_selectedDay - 1).clamp(0, days.length - 1),
    );
  }

  List<int> get _daysInSelectedMonth {
    final monthLength = Jalali(_selectedYear, _selectedMonth, 1).monthLength;
    return [for (var d = 1; d <= monthLength; d++) d];
  }

  int _compareJalaliDate(Jalali a, Jalali b) {
    if (a.year != b.year) return a.year.compareTo(b.year);
    if (a.month != b.month) return a.month.compareTo(b.month);
    return a.day.compareTo(b.day);
  }

  Jalali get _selectedDate =>
      Jalali(_selectedYear, _selectedMonth, _selectedDay);

  bool get _canSubmit => _compareJalaliDate(_selectedDate, widget.minDate) >= 0;

  @override
  Widget build(BuildContext context) {
    final safeHeight = MediaQuery.of(context).size.height;
    final sheetHeight = (safeHeight * 0.58).clamp(300.0, 400.0);

    return SafeArea(
      child: Container(
        height: sheetHeight,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const ReText(
                      'تقویـــم',
                      fontSize: 16,
                      fontWeight: 1000,
                      color: AppColors.black1,
                    ),
                    const SizedBox(height: 2),
                    ReText(
                      'انتخاب تاریخ',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black1.withOpacity(0.5),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    margin: const EdgeInsets.only(right: 32, left: 16),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFEBECF0)),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: AppColors.black1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
                    child: ReText(
                      'ماه',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black1,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ReText(
                      'سال',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _PickerWheel(
                          controller: _dayController!,
                          itemCount: _daysInSelectedMonth.length,
                          itemExtent: _wheelItemExtent,
                          onSelected: (index) {
                            setState(() {
                              _selectedDay = index + 1;
                            });
                          },
                          itemBuilder: (context, index) {
                            final day = index + 1;
                            return SizedBox(
                              height: _wheelItemExtent,
                              child: Center(
                                child: ReText(
                                  convertToPersianNumbers(day.toString()),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.gray,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                        IgnorePointer(
                          child: Container(
                            width: 64,
                            height: 48,
                            decoration: BoxDecoration(
                                color: AppColors.black1,
                                borderRadius: BorderRadius.circular(100)),
                            alignment: Alignment.center,
                            child: ReText(
                              convertToPersianNumbers(_selectedDay.toString()),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.white,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _PickerWheel(
                          controller: _monthController,
                          itemCount: widget.monthNames.length,
                          itemExtent: _wheelItemExtent,
                          onSelected: (index) {
                            setState(() {
                              _selectedMonth = index + 1;
                              _resetDayController();
                            });
                          },
                          itemBuilder: (context, index) {
                            final name = widget.monthNames[index];
                            return SizedBox(
                              height: _wheelItemExtent,
                              child: Center(
                                child: ReText(
                                  name,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gray,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                        IgnorePointer(
                          child: Container(
                            height: 48,
                            width: 90,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: AppColors.gray2),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: ReText(
                                widget.monthNames[_selectedMonth - 1],
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.black1,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _PickerWheel(
                          controller: _yearController,
                          itemCount: _years.length,
                          itemExtent: _wheelItemExtent,
                          onSelected: (index) {
                            setState(() {
                              _selectedYear = _years[index];
                              _resetDayController();
                            });
                          },
                          itemBuilder: (context, index) {
                            final year = _years[index];
                            return SizedBox(
                              height: _wheelItemExtent,
                              child: Center(
                                child: ReText(
                                  convertToPersianNumbers(year.toString()),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.gray,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                        IgnorePointer(
                          child: Container(
                            width: 64,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: AppColors.white,
                              border: Border.all(color: AppColors.gray2),
                            ),
                            child: ReText(
                              convertToPersianNumbers(_selectedYear.toString()),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: _ActionButton(
                    text: 'لغو',
                    icon: Icons.close,
                    background: AppColors.white,
                    textColor: AppColors.black1,
                    borderColor: AppColors.gray2,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Opacity(
                    opacity: _canSubmit ? 1 : 0.45,
                    child: IgnorePointer(
                      ignoring: !_canSubmit,
                      child: _ActionButton(
                        text: 'برو به تاریخ',
                        icon: Icons.arrow_back_ios_new_rounded,
                        background: AppColors.primary,
                        textColor: AppColors.white,
                        onTap: () => Navigator.of(context).pop(_selectedDate),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

typedef _PickerItemBuilder = Widget Function(BuildContext context, int index);

class _PickerWheel extends StatelessWidget {
  const _PickerWheel({
    required this.controller,
    required this.itemCount,
    required this.itemExtent,
    required this.onSelected,
    required this.itemBuilder,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final double itemExtent;
  final ValueChanged<int> onSelected;
  final _PickerItemBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      physics: const FixedExtentScrollPhysics(),
      itemExtent: itemExtent,
      diameterRatio: 2.4,
      perspective: 0.004,
      onSelectedItemChanged: onSelected,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          return Center(child: itemBuilder(context, index));
        },
      ),
    );
  }
}
