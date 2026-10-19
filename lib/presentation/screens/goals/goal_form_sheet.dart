import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/features/goals/cubit/goals_cubit.dart';
import 'package:simo_learn/features/goals/cubit/goals_state.dart';
import 'package:simo_learn/features/goals/goal_timing.dart';
import 'package:simo_learn/features/goals/goals_repository.dart';
import 'package:simo_learn/presentation/screens/goals/goal_widgets.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_widgets.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_date_picker.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/jalali_text.dart';

/// Opens the form for a new goal, or for [goal]. [extend] starts it at the
/// deadline, for a goal whose time ran out. True once saved.
Future<bool> showGoalForm(
  BuildContext context, {
  Goal? goal,
  String? title,
  bool extend = false,
}) async {
  final saved = await showReModalBottomSheet<bool>(
    context: context,
    builder: (_) => GoalFormSheet(goal: goal, title: title, extend: extend),
  );
  return saved ?? false;
}

enum _Span { month1, month3, month6, year1, custom }

class GoalFormSheet extends StatefulWidget {
  const GoalFormSheet({super.key, this.goal, this.title, this.extend = false});

  final Goal? goal;
  final String? title;
  final bool extend;

  @override
  State<GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends State<GoalFormSheet> {
  late final TextEditingController _title =
      TextEditingController(text: widget.goal?.title ?? widget.title ?? '');
  late final TextEditingController _note =
      TextEditingController(text: widget.goal?.note ?? '');
  final _titleFocus = FocusNode();

  final Jalali _today = goalToday();
  late _Span? _span;
  late Jalali _target;
  late bool _pin;

  bool get _editing => widget.goal != null;

  static const _spans = [
    (_Span.month1, '۱ ماه'),
    (_Span.month3, '۳ ماه'),
    (_Span.month6, '۶ ماه'),
    (_Span.year1, '۱ سال'),
  ];

  @override
  void initState() {
    super.initState();
    final goals = context.read<GoalsCubit>().state;
    final existing = goalDateOf(widget.goal?.targetDate?.value);
    if (_editing && existing != null && !widget.extend) {
      _span = _Span.custom;
      _target = existing;
    } else {
      _span = widget.extend ? _Span.month1 : _Span.month3;
      _target = _after(_span!);
    }
    // The first goal is the main one unless the user says otherwise.
    _pin = _editing
        ? goals.pinnedId == widget.goal!.id
        : goals.pinnedId == null &&
            !goals.goals.any(GoalsBoard.isRunning);
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  Jalali _after(_Span span) {
    final months = switch (span) {
      _Span.month1 => 1,
      _Span.month3 => 3,
      _Span.month6 => 6,
      _Span.year1 => 12,
      _Span.custom => 0,
    };
    final index = _today.year * 12 + _today.month - 1 + months;
    final month = Jalali(index ~/ 12, index % 12 + 1, 1);
    final day = _today.day.clamp(1, month.monthLength);
    return Jalali(month.year, month.month, day);
  }

  Future<void> _pickSpan(_Span span) async {
    HapticFeedback.selectionClick();
    if (span != _Span.custom) {
      setState(() {
        _span = span;
        _target = _after(span);
      });
      return;
    }
    final picked = await showPlanDatePicker(
      context,
      initialDate: _target.julianDayNumber > _today.julianDayNumber
          ? _target
          : _after(_Span.month1),
      today: _today,
    );
    if (!mounted || picked == null) return;
    if (picked.julianDayNumber <= _today.julianDayNumber) {
      showReToast(context, 'موعد باید بعد از امروز باشد.', ReToastType.info);
      return;
    }
    setState(() {
      _span = _Span.custom;
      _target = Jalali(picked.year, picked.month, picked.day);
    });
  }

  void _suggest(String text) {
    _title.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _titleFocus.requestFocus();
    setState(() {});
  }

  Future<void> _submit() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      showReToast(context, 'عنوان هدف را بنویس.', ReToastType.failed);
      _titleFocus.requestFocus();
      return;
    }
    final g = _target.toGregorian();
    final target = DateTime(g.year, g.month, g.day, 12);
    final note = _note.text.trim();
    final cubit = context.read<GoalsCubit>();
    final saved = _editing
        ? await cubit.updateGoal(
            id: widget.goal!.id,
            title: title,
            note: note,
            targetDate: target,
            pin: _pin,
          )
        : await cubit.createGoal(
            title: title,
            note: note.isEmpty ? null : note,
            targetDate: target,
            pin: _pin,
          );
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop(true);
      return;
    }
    showReToast(
      context,
      cubit.state.errorMessage ??
          (_editing ? 'ویرایش هدف ناموفق بود.' : 'ثبت هدف ناموفق بود.'),
      ReToastType.failed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _target.julianDayNumber - _today.julianDayNumber;
    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 8, right: 4),
          child: ReText(text,
              fontSize: 12.5,
              fontWeight: 800,
              color: GoalColors.ink,
              textAlign: TextAlign.right),
        );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SheetHandle(),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReText(
                              widget.extend
                                  ? 'تمدید موعد'
                                  : _editing
                                      ? 'ویرایش هدف'
                                      : 'هدف جدید',
                              fontSize: 18,
                              fontWeight: 1000,
                              color: GoalColors.ink,
                            ),
                            ReText(
                              widget.extend
                                  ? 'یک فرصت تازه به این هدف بده.'
                                  : 'هدفی بگذار و تا موعدش برایش بجنگ.',
                              fontSize: 12,
                              fontWeight: 600,
                              color: GoalColors.muted,
                            ),
                          ],
                        ),
                      ),
                      const CloseCircle(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  label('عنوان'),
                  ReTextField(
                    controller: _title,
                    focusNode: _titleFocus,
                    placeholder: 'مثلاً تراز ۷۰۰۰ در آزمون قلم‌چی',
                    height: 52,
                    borderRadius: 18,
                    backgroundColor: GoalColors.surface,
                    showFocusShadow: false,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                  ),
                  AnimatedSize(
                    duration: StatMotion.of(
                        context, const Duration(milliseconds: 240)),
                    curve: StatMotion.curve,
                    alignment: Alignment.topCenter,
                    child: !_editing && _title.text.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final text in GoalsEmpty.suggestions)
                                  SuggestionChip(
                                    text: text,
                                    onTap: () => _suggest(text),
                                  ),
                              ],
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                  const SizedBox(height: 22),
                  label('موعد'),
                  Wrap(
                    spacing: 6,
                    runSpacing: 8,
                    children: [
                      for (final (span, text) in _spans)
                        _SpanChip(
                          text: text,
                          selected: _span == span,
                          onTap: () => _pickSpan(span),
                        ),
                      _SpanChip(
                        text: 'تاریخ دلخواه',
                        icon: IconsaxPlusLinear.calendar,
                        selected: _span == _Span.custom,
                        onTap: () => _pickSpan(_Span.custom),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(IconsaxPlusLinear.calendar_tick,
                          size: 15, color: GoalColors.muted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: StatMotion.of(
                              context, const Duration(milliseconds: 220)),
                          layoutBuilder: (current, previous) => Stack(
                            alignment: AlignmentDirectional.centerStart,
                            children: [...previous, if (current != null) current],
                          ),
                          child: ReText(
                            '${JalaliText.fullDate(_target)} ، $days روز دیگر',
                            key: ValueKey(_target.julianDayNumber),
                            fontSize: 12,
                            fontWeight: 700,
                            color: GoalColors.muted,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  label('یادداشت (اختیاری)'),
                  ReTextField(
                    controller: _note,
                    placeholder: 'چرا این هدف برایت مهم است؟',
                    maxLines: 3,
                    maxLength: 200,
                    height: 88,
                    borderRadius: 18,
                    backgroundColor: GoalColors.surface,
                    showFocusShadow: false,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _pin = !_pin),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ReText('هدف اصلی من باشد',
                                  fontSize: 13,
                                  fontWeight: 800,
                                  color: GoalColors.ink),
                              ReText('بزرگ، بالای صفحه‌ی اهداف',
                                  fontSize: 11,
                                  fontWeight: 600,
                                  color: GoalColors.muted),
                            ],
                          ),
                        ),
                        _Switch(value: _pin),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  BlocBuilder<GoalsCubit, GoalsState>(
                    buildWhen: (a, b) => a.isMutating != b.isMutating,
                    builder: (context, state) => Pressable(
                      onTap: state.isMutating ? null : _submit,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: state.isMutating
                              ? GoalColors.accent.withAlpha(150)
                              : GoalColors.accent,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: ReText(
                          state.isMutating
                              ? 'در حال ذخیره...'
                              : _editing
                                  ? 'ذخیره'
                                  : 'ثبت هدف',
                          fontSize: 14.5,
                          fontWeight: 800,
                          color: Colors.white,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpanChip extends StatelessWidget {
  const _SpanChip({
    required this.text,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : GoalColors.ink;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: StatMotion.of(context, const Duration(milliseconds: 200)),
        curve: StatMotion.curve,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? GoalColors.ink : AppColors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? GoalColors.ink : GoalColors.line,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
            ],
            ReText(text, fontSize: 12.5, fontWeight: 800, color: color),
          ],
        ),
      ),
    );
  }
}

/// The app's switch, as in the task form: orange when on.
class _Switch extends StatelessWidget {
  const _Switch({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 44,
        height: 28,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: value ? AppColors.primary.withAlpha(64) : AppColors.gray2,
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
    );
  }
}

/// The sheets' grey drag handle.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: GoalColors.line,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

/// The sheets' round close button.
class CloseCircle extends StatelessWidget {
  const CloseCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: GoalColors.line, width: 1.5),
        ),
        child: const Icon(Icons.close_rounded, size: 18, color: GoalColors.muted),
      ),
    );
  }
}
