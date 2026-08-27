// ignore_for_file: deprecated_member_use

import 'package:ferry/typed_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/features/goals/cubit/goals_cubit.dart';
import 'package:simo_learn/features/goals/cubit/goals_state.dart';
import 'package:simo_learn/features/goals/goals_repository.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/app_exit_guard.dart';
import 'package:simo_learn/presentation/widgets/re_dots_loader.dart';
import 'package:simo_learn/presentation/widgets/re_header.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  static const Duration _goalListAnimationDuration = Duration(milliseconds: 260);
  static const double _goalItemHeight = 90.0;
  static const double _goalSheetItemExtent = 48;
  static const int _goalSheetVisibleWheelItems = 3;

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

  late final ScrollController _goalCardsScrollController;
  late final ScrollController _goalDotsScrollController;

  bool _isSyncingGoalScroll = false;

  @override
  void initState() {
    super.initState();
    _goalCardsScrollController = ScrollController();
    _goalDotsScrollController = ScrollController();

    _goalCardsScrollController.addListener(_syncDotsScroll);
    _goalDotsScrollController.addListener(_syncCardsScroll);
  }

  void _syncDotsScroll() {
    if (_isSyncingGoalScroll || !_goalDotsScrollController.hasClients) return;

    _isSyncingGoalScroll = true;
    _goalDotsScrollController.jumpTo(
      _goalCardsScrollController.offset.clamp(
        _goalDotsScrollController.position.minScrollExtent,
        _goalDotsScrollController.position.maxScrollExtent,
      ),
    );
    _isSyncingGoalScroll = false;
  }

  void _syncCardsScroll() {
    if (_isSyncingGoalScroll || !_goalCardsScrollController.hasClients) return;

    _isSyncingGoalScroll = true;
    _goalCardsScrollController.jumpTo(
      _goalDotsScrollController.offset.clamp(
        _goalCardsScrollController.position.minScrollExtent,
        _goalCardsScrollController.position.maxScrollExtent,
      ),
    );
    _isSyncingGoalScroll = false;
  }

  @override
  void dispose() {
    _goalCardsScrollController.dispose();
    _goalDotsScrollController.dispose();
    super.dispose();
  }

  Future<void> _openAddGoalModal() async {
    await _openGoalFormModal();
  }

  Future<void> _openEditGoalModal(Goal goal) async {
    await _openGoalFormModal(goal: goal);
  }

  Future<void> _openGoalFormModal({Goal? goal}) async {
    final today = Jalali.now();
    final isEditing = goal != null;

    final titleController = TextEditingController(text: goal?.title ?? '');
    final noteController = TextEditingController(text: goal?.note ?? '');

    final initialDate = _goalTargetDate(goal);
    var selectedDay = initialDate?.day ?? today.day;
    var selectedMonth = initialDate?.month ?? today.month;
    var selectedYear = initialDate?.year ?? today.year;
    var noteLength = noteController.text.length;

    final years = [
      for (var year = today.year - 4; year <= 1500; year++) year,
    ];

    if (!years.contains(selectedYear)) {
      selectedYear = today.year;
      selectedMonth = today.month;
      selectedDay = today.day;
    }

    final dayController = FixedExtentScrollController(
      initialItem: selectedDay - 1,
    );
    final monthController = FixedExtentScrollController(
      initialItem: selectedMonth - 1,
    );
    final yearController = FixedExtentScrollController(
      initialItem: years.indexOf(selectedYear),
    );

    var pickerDisposed = false;

    void jumpToWheelItem(
      FixedExtentScrollController controller,
      int item,
    ) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || pickerDisposed || !controller.hasClients) return;
        controller.jumpToItem(item);
      });
    }

    void clampSelectedDateToToday() {
      if (isEditing) return;

      final selectedDate = Jalali(
        selectedYear,
        selectedMonth,
        selectedDay,
      );

      if (_compareJalaliDate(selectedDate, today) >= 0) return;

      selectedDay = today.day;
      selectedMonth = today.month;
      selectedYear = today.year;

      jumpToWheelItem(dayController, selectedDay - 1);
      jumpToWheelItem(monthController, selectedMonth - 1);
      jumpToWheelItem(yearController, years.indexOf(selectedYear));
    }

    final submitted = await showReModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            final maxDay = Jalali(
              selectedYear,
              selectedMonth,
              1,
            ).monthLength;

            if (selectedDay > maxDay) {
              selectedDay = maxDay;
              jumpToWheelItem(dayController, selectedDay - 1);
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildGoalFormHeader(sheetContext, isEditing),
                        const SizedBox(height: 25),
                        ReTextField(
                          controller: titleController,
                          placeholder: 'عنوان هدف',
                          height: 56,
                          borderRadius: 32,
                          backgroundColor: AppColors.gray.withOpacity(0.1),
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
                            setModalState(() {
                              selectedDay = value;
                              clampSelectedDateToToday();
                            });
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
                              clampSelectedDateToToday();
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
                              clampSelectedDateToToday();
                            });
                          },
                        ),
                        const SizedBox(height: 34),
                        _buildGoalNoteField(
                          controller: noteController,
                          noteLength: noteLength,
                          onChanged: (value) {
                            setModalState(() {
                              noteLength = value.length;
                            });
                          },
                        ),
                        const SizedBox(height: 36),
                        _buildGoalFormActions(
                          sheetContext,
                          isEditing: isEditing,
                          goal: goal,
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

    pickerDisposed = true;
    titleController.dispose();
    noteController.dispose();
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();

    if (submitted == true && mounted) {
      _scrollGoalsToTop();
    }
  }

  Widget _buildGoalFormHeader(BuildContext context, bool isEditing) {
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
              border: Border.all(
                color: AppColors.gray2,
                width: 1.5,
              ),
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
            ReText(
              isEditing ? 'ویرایش هدف' : 'افزودن هدف',
              fontSize: 16,
              fontWeight: 1000,
              color: AppColors.black1,
            ),
            ReText(
              isEditing ? 'اطلاعات هدف را ویرایش کنید.' : 'هدف جدیدی برای خود مشخص کنید.',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.black1.withOpacity(0.5),
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
      for (var day = 1; day <= Jalali(selectedYear, selectedMonth, 1).monthLength; day++) day,
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
                  child: ReText(
                    'ماه',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: ReText(
                    'سال',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
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
                        index + 1 == selectedDay,
                        index,
                        selectedDay - 1,
                      ),
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
                      border: Border.all(
                        color: AppColors.gray2,
                        width: 1.5,
                      ),
                    ),
                    itemBuilder: (index) => ReText(
                      _persianMonths[index],
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: _wheelItemColor(
                        index + 1 == selectedMonth,
                        index,
                        selectedMonth - 1,
                      ),
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
                      border: Border.all(
                        color: AppColors.gray2,
                        width: 1.5,
                      ),
                    ),
                    itemBuilder: (index) => ReText(
                      years[index].toString(),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: _wheelItemColor(
                        years[index] == selectedYear,
                        index,
                        years.indexOf(selectedYear),
                      ),
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
              overAndUnderCenterOpacity: 1,
              onSelectedItemChanged: onSelected,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: itemCount,
                builder: (context, index) => Center(
                  child: itemBuilder(index),
                ),
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
      color: AppColors.gray2.withOpacity(0.45),
    );
  }

  Color _wheelItemColor(bool isSelected, int index, int selectedIndex) {
    if (isSelected) return Colors.transparent;

    return (index - selectedIndex).abs() == 1 ? AppColors.gray : AppColors.gray2;
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
          contentPadding: const EdgeInsets.fromLTRB(52, 20, 16, 30),
          textInputAction: TextInputAction.done,
          showFocusShadow: false,
          fontSize: 13,
          textColor: AppColors.black1.withOpacity(0.5),
          fontWeight: FontWeight.w600,
          onChanged: onChanged,
        ),
        Positioned(
          left: 16,
          bottom: 14,
          child: ReText(
            '${noteLength.clamp(0, 200)}/200',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.black1.withOpacity(0.5),
            textDirection: TextDirection.ltr,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalFormActions(
    BuildContext sheetContext, {
    required bool isEditing,
    required Goal? goal,
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
            onPressed: () => Navigator.of(sheetContext).pop(),
            text: 'لغو',
            icon: Icons.close,
            textDirection: TextDirection.ltr,
            isOutlined: true,
            background: AppColors.white,
            color: AppColors.gray2,
            textColor: AppColors.black1,
            borderRadius: 32,
            fontSize: 16,
            iconSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 58,
            child: BlocBuilder<GoalsCubit, GoalsState>(
              buildWhen: (previous, current) => previous.isCreating != current.isCreating || previous.isUpdating != current.isUpdating,
              builder: (context, state) {
                final isBusy = isEditing ? state.isUpdating : state.isCreating;

                return ReButton(
                  onPressed: isBusy
                      ? null
                      : () {
                          _submitGoal(
                            sheetContext: sheetContext,
                            goal: goal,
                            isEditing: isEditing,
                            titleController: titleController,
                            noteController: noteController,
                            selectedDay: selectedDay,
                            selectedMonth: selectedMonth,
                            selectedYear: selectedYear,
                          );
                        },
                  text: isBusy
                      ? 'در حال ذخیره...'
                      : isEditing
                          ? 'ذخیره'
                          : 'افزودن',
                  textDirection: TextDirection.ltr,
                  icon: isBusy
                      ? null
                      : isEditing
                          ? Icons.check
                          : Icons.add,
                  iconColor: AppColors.white,
                  color: AppColors.primary,
                  background: AppColors.primary,
                  textColor: AppColors.white,
                  borderRadius: 32,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitGoal({
    required BuildContext sheetContext,
    required Goal? goal,
    required bool isEditing,
    required TextEditingController titleController,
    required TextEditingController noteController,
    required int selectedDay,
    required int selectedMonth,
    required int selectedYear,
  }) async {
    final title = titleController.text.trim();

    if (title.isEmpty) {
      showReToast(
        context,
        'لطفاً عنوان هدف را وارد کنید.',
        ReToastType.failed,
      );
      return;
    }

    final jalaliDate = Jalali(selectedYear, selectedMonth, selectedDay);
    final gregorianDate = jalaliDate.toGregorian();
    final targetDate = DateTime(
      gregorianDate.year,
      gregorianDate.month,
      gregorianDate.day,
      12,
    );
    final note = noteController.text.trim();

    final success = isEditing
        ? await context.read<GoalsCubit>().updateGoal(
              id: goal!.id,
              title: title,
              note: note.isEmpty ? '' : note,
              targetDate: targetDate,
            )
        : await context.read<GoalsCubit>().createGoal(
              title: title,
              note: note.isEmpty ? null : note,
              targetDate: targetDate,
            );

    if (!mounted) return;

    if (success) {
      Navigator.of(sheetContext).pop(true);
      return;
    }

    final message = context.read<GoalsCubit>().state.errorMessage ?? (isEditing ? 'ویرایش هدف ناموفق بود.' : 'ایجاد هدف ناموفق بود.');

    showReToast(context, message, ReToastType.failed);
  }

  int _compareJalaliDate(Jalali a, Jalali b) {
    if (a.year != b.year) return a.year.compareTo(b.year);
    if (a.month != b.month) return a.month.compareTo(b.month);
    return a.day.compareTo(b.day);
  }

  int _goalRemainingDays(Jalali dueDate) {
    final today = Jalali.now();
    final todayGregorian = today.toGregorian();
    final dueGregorian = dueDate.toGregorian();

    final todayDate = DateTime(
      todayGregorian.year,
      todayGregorian.month,
      todayGregorian.day,
    );
    final dueDateTime = DateTime(
      dueGregorian.year,
      dueGregorian.month,
      dueGregorian.day,
    );

    return dueDateTime.difference(todayDate).inDays;
  }

  _GoalRemainingTime _goalRemainingTime(Jalali dueDate) {
    final remainingDays = _goalRemainingDays(dueDate);

    if (remainingDays <= 0) {
      return const _GoalRemainingTime(value: 0, unit: 'روز');
    }

    if (remainingDays < 30) {
      return _GoalRemainingTime(value: remainingDays, unit: 'روز');
    }

    if (remainingDays < 365) {
      return _GoalRemainingTime(
        value: (remainingDays / 30).ceil(),
        unit: 'ماه',
      );
    }

    return _GoalRemainingTime(
      value: (remainingDays / 365).ceil(),
      unit: 'سال',
    );
  }

  Jalali? _goalTargetDate(Goal? goal) {
    final targetDate = goal?.targetDate;
    if (targetDate == null) return null;

    final parsed = DateTime.tryParse(targetDate.value);
    if (parsed == null) return null;

    return Jalali.fromDateTime(parsed.toLocal());
  }

  DateTime? _goalCreatedDate(Goal goal) {
    final parsed = DateTime.tryParse(goal.createdAt.value);
    return parsed?.toLocal();
  }

  double _goalProgress(Goal goal, Jalali? dueDate) {
    DateTime now = DateTime.now();
    DateTime target = goal.targetDate == null ? DateTime.now() : DateTime.parse(goal.targetDate!.value);
    DateTime createdAt = DateTime.parse(goal.createdAt.value);
    debugPrint("""
    cr: ${goal.createdAt.value}
    trg: ${goal.targetDate?.value}
    now: ${now.toIso8601String()}
    """);
    debugPrint(now.difference(createdAt).inHours.toString());
    return ((now.difference(createdAt).inHours) / (target.difference(createdAt).inHours));
  }

  Widget _buildGoalTile(Goal goal, int index) {
    final dueDate = _goalTargetDate(goal);
    final color = index.isEven ? Color(0xffF14922) : Color(0xff4361EE);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openGoalDetailsModal(goal),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: AppColors.black1.withOpacity(0.04),
              blurRadius: 80,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.arrow_back_ios,
              size: 12,
              color: AppColors.gray,
            ).lMargin(24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 24, left: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ReText(
                      goal.title,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.black1,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    if (dueDate != null)
                      _buildRemainingTimeText(
                        dueDate: dueDate,
                        valueColor: color,
                        valueFontSize: 13,
                        unitFontSize: 10,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openGoalDetailsModal(Goal goal) async {
    await showReModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final dueDate = _goalTargetDate(goal);
        final remainingDays = dueDate == null ? null : _goalRemainingDays(dueDate);
        final progress = _goalProgress(goal, dueDate);
        debugPrint(progress.toString());
        return Container(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 75,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 30),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ReText(
                            goal.title,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.black1,
                            maxLines: 2,
                          ),
                          if (dueDate != null) ...[
                            const SizedBox(height: 2),
                            ReText(
                              _formatJalaliShortDate(dueDate),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => Navigator.of(sheetContext).pop(),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.gray2,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.gray,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  height: 1,
                  color: AppColors.gray2,
                ),
                if (goal.note?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ReText(
                      goal.note!.trim(),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray,
                      maxLines: 4,
                    ),
                  ),
                ],
                if (dueDate != null) ...[
                  const SizedBox(height: 34),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ReText(
                        remainingDays != null && remainingDays > 0
                            ? 'روز باقی مانده'
                            : remainingDays == 0
                                ? 'امروز موعد هدف است'
                                : 'از موعد هدف گذشته',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray,
                      ),
                      const SizedBox(width: 6),
                      if (remainingDays != null && remainingDays > 0)
                        ReText(
                          _remainingDaysText(remainingDays),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.black1,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  remainingDays == 0 || progress <= 0
                      ? const SizedBox()
                      : LinearProgressIndicator(
                          color: const Color(0xffF14922),
                          backgroundColor: AppColors.gray2,
                          value: progress,
                        )
                ],
                const SizedBox(height: 34),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 58,
                        child: ReButton(
                          onPressed: () async {
                            Navigator.of(sheetContext).pop();
                            await Future<void>.delayed(
                              const Duration(milliseconds: 250),
                            );
                            if (mounted) {
                              await _openEditGoalModal(goal);
                            }
                          },
                          text: 'ویرایش',
                          icon: IconsaxPlusLinear.edit,
                          iconColor: AppColors.black1,
                          color: AppColors.gray2,
                          background: AppColors.white,
                          textColor: AppColors.black1,
                          isOutlined: true,
                          textDirection: TextDirection.ltr,
                          borderRadius: 32,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () async {
                        final confirmed = await _confirmDeleteGoal(goal);
                        if (!confirmed || !mounted) return;

                        final success = await context.read<GoalsCubit>().deleteGoal(goal.id);

                        if (!mounted) return;

                        if (success) {
                          Navigator.of(sheetContext).pop();
                          showReToast(
                            context,
                            'هدف حذف شد',
                            ReToastType.success,
                          );
                        } else {
                          final message = context.read<GoalsCubit>().state.errorMessage ?? 'حذف هدف ناموفق بود.';
                          showReToast(
                            context,
                            message,
                            ReToastType.failed,
                          );
                        }
                      },
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.gray2,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          SolarIconsOutline.trashBinMinimalistic,
                          size: 22,
                          color: AppColors.black1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDeleteGoal(Goal goal) async {
    final result = await showReModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.errorColor),
                      ),
                      child: const Icon(
                        SolarIconsOutline.trashBinMinimalistic,
                        color: AppColors.errorColor,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ReText(
                    'هدف «${goal.title}» حذف شود؟',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const ReText(
                    'درصورت تایید، این هدف برای همیشه حذف می‌شود.',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      Expanded(
                        child: ReButton(
                          onPressed: () => Navigator.of(sheetContext).pop(true),
                          text: 'حذف',
                          color: AppColors.errorColor,
                          background: AppColors.errorColor,
                          textColor: AppColors.white,
                          borderRadius: 24,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ReButton(
                          onPressed: () => Navigator.of(sheetContext).pop(false),
                          text: 'لغو',
                          color: AppColors.gray2,
                          background: AppColors.white,
                          textColor: AppColors.black1,
                          isOutlined: true,
                          borderRadius: 24,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  String _formatJalaliShortDate(Jalali date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  String _remainingDaysText(int days) {
    return convertToPersianNumbers(days.toString());
  }

  String _goalStatusText(Goal goal) {
    switch (goal.status.name) {
      case 'COMPLETED':
        return 'تکمیل شده';
      case 'PAUSED':
        return 'متوقف شده';
      case 'ARCHIVED':
        return 'بایگانی شده';
      case 'IN_PROGRESS':
      default:
        return 'در حال انجام';
    }
  }

  Widget _buildRemainingTimeText({
    required Jalali dueDate,
    required Color valueColor,
    required double valueFontSize,
    required double unitFontSize,
    FontWeight valueFontWeight = FontWeight.w600,
    FontWeight unitFontWeight = FontWeight.w600,
    bool valueFirst = false,
  }) {
    final remaining = _goalRemainingTime(dueDate);
    final value = ReText(
      remaining.value.toString(),
      fontSize: valueFontSize,
      fontWeight: valueFontWeight,
      color: valueColor,
      textDirection: TextDirection.ltr,
    );
    final unit = ReText(
      remaining.unit,
      fontSize: unitFontSize,
      fontWeight: unitFontWeight,
      color: AppColors.gray,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: valueFirst ? [value, const SizedBox(width: 4), unit] : [unit, const SizedBox(width: 4), value],
    );
  }

  Widget _buildGoalList(GoalsState state) {
    if (state.isLoading && state.goals.isEmpty) {
      return const Center(child: ReDotsLoader());
    }

    if (state.status == GoalsStatus.failure && state.goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReText(
              state.errorMessage ?? 'خطا در دریافت اهداف',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ReButton(
              onPressed: () => context.read<GoalsCubit>().loadGoals(),
              text: 'تلاش مجدد',
              textDirection: TextDirection.rtl,
              icon: Icons.refresh,
              iconColor: AppColors.primary,
              color: AppColors.gray2,
              background: AppColors.gray1,
              textColor: AppColors.black1,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ).sizedBox(height: 44, width: 130),
          ],
        ),
      );
    }

    if (state.goals.isEmpty) {
      return ReEmptyList(
        imageWidth: 220,
        onTap: _openAddGoalModal,
        title: 'هنوز هدفی مشخص نکردی!',
        subtitle: 'برای افزودن هدف روی + کلیک کنید.',
        imagePath: 'assets/images/empty_list_goal.png',
      );
    }

    return RefreshIndicator(
      onRefresh: context.read<GoalsCubit>().refresh,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _goalCardsScrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(32, 0, 0, 24),
                  itemCount: state.goals.length,
                  itemBuilder: (_, index) {
                    final goal = state.goals[index];
                    return AnimatedContainer(
                      duration: _goalListAnimationDuration,
                      curve: Curves.easeOutCubic,
                      height: _goalItemHeight,
                      alignment: Alignment.center,
                      child: _buildGoalTile(goal, index),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 68,
                child: ListView.builder(
                  controller: _goalDotsScrollController,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                    top: 0,
                    bottom: 24,
                    right: 8,
                  ),
                  itemCount: state.goals.length,
                  itemBuilder: (_, index) {
                    final color = index.isEven ? const Color(0xffF14922) : const Color(0xff4361EE);
                    return AnimatedContainer(
                      duration: _goalListAnimationDuration,
                      curve: Curves.easeOutCubic,
                      height: _goalItemHeight,
                      child: ReTimelineDot(
                        showTopLine: index != 0,
                        showBottomLine: index != state.goals.length - 1,
                        isDone: true,
                        height: _goalItemHeight,
                        width: 56,
                        circleSize: 35,
                        innerCircleSize: 32,
                        lineColor: AppColors.black1.withOpacity(0.2),
                        activeBackgroundColor: color.withOpacity(0.12),
                        innerPadding: const EdgeInsets.all(5),
                        child: Icon(
                          SolarIconsBold.target,
                          color: color,
                          size: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollGoalsToTop() {
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

  @override
  Widget build(BuildContext context) {
    return AppExitGuard(
      child: Scaffold(
        backgroundColor: AppColors.gray1,
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: 2,
          onTap: (index) => navigateToIndex(context, index, 2),
        ),
        body: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: SafeArea(
                child: reAppHeader(
                  'اهداف',
                  prefixIcon: GestureDetector(
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(SolarIconsOutline.bell, size: 24),
                    ),
                  ),
                  suffixIcon: GestureDetector(
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(SolarIconsOutline.chatRoundLine, size: 24),
                    ),
                  ),
                ).bMargin(24),
              ),
            ),
            BlocBuilder<GoalsCubit, GoalsState>(
              builder: (context, state) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ReButton(
                      onPressed: state.isMutating ? null : _openAddGoalModal,
                      text: 'افزودن هدف',
                      textDirection: TextDirection.ltr,
                      icon: Icons.add,
                      iconColor: AppColors.primary,
                      color: AppColors.gray2,
                      iconSize: 18,
                      isOutlined: true,
                      background: AppColors.gray1,
                      textColor: AppColors.black1,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ).sizedBox(height: 40, width: 132),
                    const ReText(
                      'اهداف شما',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ).tMargin(2),
                  ],
                ).hMargin(32).tMargin(16).bMargin(8);
              },
            ),
            Expanded(
              child: BlocBuilder<GoalsCubit, GoalsState>(
                builder: (context, state) => _buildGoalList(state),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalRemainingTime {
  const _GoalRemainingTime({
    required this.value,
    required this.unit,
  });

  final int value;
  final String unit;
}
