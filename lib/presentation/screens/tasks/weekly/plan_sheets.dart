import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/screens/tasks/tasks_api.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_widgets.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/week_plan.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/_utils.dart';

/// Sheets used while planning: quick add, moving a task to another day, and
/// bringing last week's leftovers into this one.

Future<T?> _showPlanSheet<T>(BuildContext context, Widget sheet) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => sheet,
  );
}

// --------------------------------------------------------------- day picker

/// A week of day chips with arrows to browse later weeks. Past days and
/// weeks beyond the planning horizon cannot be picked.
class WeekDayPicker extends StatefulWidget {
  const WeekDayPicker({
    super.key,
    required this.selected,
    required this.today,
    required this.onChanged,
    this.markedDay,
  });

  final Jalali? selected;
  final Jalali today;
  final ValueChanged<Jalali> onChanged;

  /// A day to outline, such as the day a task is on now.
  final Jalali? markedDay;

  @override
  State<WeekDayPicker> createState() => _WeekDayPickerState();
}

class _WeekDayPickerState extends State<WeekDayPicker> {
  late Jalali _weekStart;

  Jalali get _firstWeek => weekStartOf(widget.today);

  @override
  void initState() {
    super.initState();
    final shown = weekStartOf(widget.selected ?? widget.markedDay ?? widget.today);
    _weekStart = daysBetween(_firstWeek, shown) < 0 ? _firstWeek : shown;
  }

  bool get _canGoBack => daysBetween(_firstWeek, _weekStart) > 0;
  bool get _canGoForward => isWeekWithinHorizon(_weekStart.addDays(7), widget.today);

  void _browse(int weeks) {
    if (weeks < 0 ? !_canGoBack : !_canGoForward) return;
    HapticFeedback.selectionClick();
    setState(() => _weekStart = _weekStart.addDays(7 * weeks));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _arrow('day-picker-prev', Icons.chevron_left_rounded, _canGoBack, () => _browse(-1)),
            Expanded(
              child: Column(
                children: [
                  ReText(
                    weekRangeLabel(_weekStart, today: widget.today),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black1,
                    textAlign: TextAlign.center,
                  ),
                  ReText(
                    relativeWeekLabel(_weekStart, widget.today),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            _arrow('day-picker-next', Icons.chevron_right_rounded, _canGoForward, () => _browse(1)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var index = 0; index < 7; index++)
              Expanded(child: _chip(index, _weekStart.addDays(index))),
          ],
        ),
      ],
    );
  }

  Widget _arrow(String key, IconData icon, bool enabled, VoidCallback onTap) {
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        key: ValueKey(key),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 24,
            color: enabled ? AppColors.black1 : AppColors.dark4Color,
          ),
        ),
      ),
    );
  }

  Widget _chip(int index, Jalali day) {
    final isPast = daysBetween(widget.today, day) < 0;
    final selected = widget.selected != null && isSameJalaliDay(day, widget.selected!);
    final marked = widget.markedDay != null && isSameJalaliDay(day, widget.markedDay!);
    final isToday = isSameJalaliDay(day, widget.today);

    return Semantics(
      button: true,
      enabled: !isPast,
      selected: selected,
      label: dayLabel(day),
      child: GestureDetector(
        key: ValueKey('week-day-chip-$index'),
        behavior: HitTestBehavior.opaque,
        onTap: isPast
            ? null
            : () {
                HapticFeedback.selectionClick();
                widget.onChanged(day);
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.black1 : AppColors.gray1,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: marked && !selected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Opacity(
            opacity: isPast ? 0.35 : 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ReText(
                  kPersianWeekdayInitials[index],
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? AppColors.white.withValues(alpha: 0.7)
                      : isToday
                          ? AppColors.primary
                          : AppColors.gray,
                ),
                const SizedBox(height: 2),
                ReText(
                  '${day.day}',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: selected ? AppColors.white : AppColors.black1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------- quick add

/// Quick add: a title, a type and optionally a subject, then the next task.
/// [onSubmit] returns null when the task was created, otherwise the message
/// to show. "Advanced settings" closes the sheet and hands everything chosen
/// so far to [onMoreOptions], which opens the full form with it.
Future<void> showQuickAddSheet(
  BuildContext context, {
  required Jalali initialDay,
  required Jalali today,
  required List<String> subjects,
  required Future<String?> Function(QuickTaskDraft draft) onSubmit,
  required ValueChanged<QuickTaskDraft> onMoreOptions,
  bool initialTimed = true,
}) {
  return _showPlanSheet<void>(
    context,
    _QuickAddSheet(
      initialDay: daysBetween(today, initialDay) < 0 ? today : initialDay,
      today: today,
      subjects: subjects,
      initialTimed: initialTimed,
      onSubmit: onSubmit,
      onMoreOptions: onMoreOptions,
    ),
  );
}

class _QuickAddSheet extends StatefulWidget {
  const _QuickAddSheet({
    required this.initialDay,
    required this.today,
    required this.subjects,
    required this.initialTimed,
    required this.onSubmit,
    required this.onMoreOptions,
  });

  final Jalali initialDay;
  final Jalali today;
  final List<String> subjects;
  final bool initialTimed;
  final Future<String?> Function(QuickTaskDraft draft) onSubmit;
  final ValueChanged<QuickTaskDraft> onMoreOptions;

  @override
  State<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<_QuickAddSheet> {
  static const List<int> _minuteOptions = kTaskDurations;

  late Jalali _day = widget.initialDay;
  late bool _timed = widget.initialTimed;
  int _minutes = kDefaultTaskMinutes;
  String? _subject;
  bool _submitting = false;
  String? _error;
  final List<String> _added = [];
  final TextEditingController _title = TextEditingController();
  final FocusNode _titleFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _title.text.trim();
    if (title.isEmpty || _submitting) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    final error = await widget.onSubmit(_draft(title));
    if (!mounted) return;

    setState(() {
      _submitting = false;
      if (error == null) {
        _added.insert(0, title);
        _title.clear();
      } else {
        _error = error;
      }
    });
    if (error == null) {
      HapticFeedback.lightImpact();
      _titleFocus.requestFocus();
    }
  }

  QuickTaskDraft _draft(String title) => QuickTaskDraft(
        title: title,
        day: _day,
        timedMinutes: _timed ? _minutes : null,
        subject: _subject,
      );

  void _openFullForm() {
    final draft = _draft(_title.text.trim());
    Navigator.of(context).pop();
    widget.onMoreOptions(draft);
  }

  @override
  Widget build(BuildContext context) {
    return PlanSheetFrame(
      key: const ValueKey('quick-add-sheet'),
      title: 'افزودن سریع تسک',
      subtitle: 'برای ${dayLabel(_day)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          WeekDayPicker(
            selected: _day,
            today: widget.today,
            onChanged: (day) => setState(() => _day = day),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('quick-add-title'),
            controller: _title,
            focusNode: _titleFocus,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            style: TextStyle(
              fontFamily: AppFonts.iranSansVar,
              fontVariations: AppFonts.fontVariations(FontWeight.w700),
              fontSize: 15,
              color: AppColors.black1,
            ),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: 'عنوان تسک، مثلاً «حل تمرین فصل ۳»',
              hintStyle: TextStyle(
                fontFamily: AppFonts.iranSansVar,
                fontVariations: AppFonts.fontVariations(FontWeight.w500),
                fontSize: 14,
                color: AppColors.gray,
              ),
              filled: true,
              fillColor: AppColors.gray1,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ChoicePill(
                  key: const ValueKey('quick-add-type-timed'),
                  text: 'زمان‌دار',
                  icon: Icons.timer_outlined,
                  selected: _timed,
                  onTap: () => setState(() => _timed = true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ChoicePill(
                  key: const ValueKey('quick-add-type-checklist'),
                  text: 'چک‌لیست',
                  icon: Icons.check_circle_outline_rounded,
                  selected: !_timed,
                  onTap: () => setState(() => _timed = false),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !_timed
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        for (final minutes in _minuteOptions) ...[
                          if (minutes != _minuteOptions.first) const SizedBox(width: 8),
                          Expanded(
                            child: _MinutesOption(
                              key: ValueKey('quick-add-minutes-$minutes'),
                              minutes: minutes,
                              selected: _minutes == minutes,
                              onTap: () => setState(() => _minutes = minutes),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
          if (widget.subjects.isNotEmpty) ...[
            const SizedBox(height: 16),
            const ReText(
              'درس (اختیاری)',
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: AppColors.black1,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.subjects.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final subject = widget.subjects[index];
                  final selected = _subject == subject;
                  return _ChoicePill(
                    key: ValueKey('quick-add-subject-$subject'),
                    text: subject,
                    selected: selected,
                    compact: true,
                    onTap: () => setState(() => _subject = selected ? null : subject),
                  );
                },
              ),
            ),
          ],
          if (_added.isNotEmpty) ...[
            const SizedBox(height: 16),
            _AddedTasks(titles: _added),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            ReText(
              _error!,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.errorColor,
              textAlign: TextAlign.start,
              maxLines: 3,
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: PlanPillButton.outlined(
                  key: const ValueKey('quick-add-more'),
                  text: 'تنظیمات پیشرفته',
                  icon: Icons.tune_rounded,
                  fontSize: 13,
                  onTap: _openFullForm,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PlanPillButton(
                  key: const ValueKey('quick-add-submit'),
                  text: _added.isEmpty ? 'افزودن' : 'افزودن بعدی',
                  icon: Icons.add_rounded,
                  isLoading: _submitting,
                  onTap: _title.text.trim().isEmpty ? null : _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
    this.icon,
    this.compact = false,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.white : AppColors.black1;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: compact ? 38 : 46,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.black1 : AppColors.white,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: selected ? AppColors.black1 : AppColors.gray2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: foreground),
                const SizedBox(width: 6),
              ],
              ReText(
                text,
                fontSize: compact ? 12.5 : 13.5,
                fontWeight: FontWeight.w800,
                color: foreground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MinutesOption extends StatelessWidget {
  const _MinutesOption({
    super.key,
    required this.minutes,
    required this.selected,
    required this.onTap,
  });

  final int minutes;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.gray1,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReText(
                '$minutes',
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: selected ? AppColors.white : AppColors.black1,
              ),
              ReText(
                'دقیقه',
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.gray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddedTasks extends StatelessWidget {
  const _AddedTasks({required this.titles});

  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.done.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.done),
              const SizedBox(width: 6),
              ReText(
                '${titles.length} تسک اضافه شد',
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppColors.done,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final title in titles)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: ReText(
                    title,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black1,
                    maxLines: 1,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------- move

/// Asks which day [task] should move to; null when dismissed.
Future<Jalali?> showMoveTaskSheet(
  BuildContext context, {
  required Map<String, dynamic> task,
  required Jalali today,
}) {
  return _showPlanSheet<Jalali>(context, _MoveTaskSheet(task: task, today: today));
}

class _MoveTaskSheet extends StatelessWidget {
  const _MoveTaskSheet({required this.task, required this.today});

  final Map<String, dynamic> task;
  final Jalali today;

  @override
  Widget build(BuildContext context) {
    final current = task['date'] is Jalali ? task['date'] as Jalali : null;
    return PlanSheetFrame(
      key: const ValueKey('move-task-sheet'),
      title: 'انتقال به روز دیگر',
      subtitle: '«${task['title'] ?? ''}»',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WeekDayPicker(
            selected: null,
            markedDay: current,
            today: today,
            onChanged: (day) {
              if (current != null && isSameJalaliDay(day, current)) return;
              Navigator.of(context).pop(day);
            },
          ),
          const SizedBox(height: 12),
          const ReText(
            'روزی را که می‌خواهید تسک به آن منتقل شود انتخاب کنید.',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.gray,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
