import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/tag_selection.dart';
import 'package:simo_learn/presentation/screens/tasks/task_form_widgets.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/screens/tasks/tasks_api.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_widgets.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/week_plan.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
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

/// A week of day chips, browsed with the arrows or by dragging the chips
/// sideways. Past days and weeks beyond the planning horizon cannot be
/// picked.
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
  late final PageController _pages;

  /// Page 0 is this week; the last page is the last week the server plans.
  Jalali get _firstWeek => weekStartOf(widget.today);
  int get _weekCount =>
      daysBetween(_firstWeek, weekStartOf(lastPlannableDay(widget.today))) ~/
          7 +
      1;

  int get _page => daysBetween(_firstWeek, _weekStart) ~/ 7;

  @override
  void initState() {
    super.initState();
    final shown =
        weekStartOf(widget.selected ?? widget.markedDay ?? widget.today);
    final page = (daysBetween(_firstWeek, shown) ~/ 7).clamp(0, _weekCount - 1);
    _weekStart = _firstWeek.addDays(7 * page);
    _pages = PageController(initialPage: page);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  bool get _canGoBack => _page > 0;
  bool get _canGoForward => _page < _weekCount - 1;

  void _browse(int weeks) {
    if (weeks < 0 ? !_canGoBack : !_canGoForward) return;
    _pages.animateToPage(
      _page + weeks,
      duration: const Duration(milliseconds: 320),
      curve: AppMotion.settle,
    );
  }

  /// Arrows and drags both land here, once the new week is in place.
  void _onPageChanged(int page) {
    HapticFeedback.selectionClick();
    setState(() => _weekStart = _firstWeek.addDays(7 * page));
  }

  Widget _week(Jalali weekStart, {bool keyed = true}) {
    return Row(
      children: [
        for (var index = 0; index < 7; index++)
          Expanded(
            child: _chip(index, weekStart.addDays(index), keyed: keyed),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _arrow('day-picker-prev', Icons.chevron_left_rounded, _canGoBack,
                () => _browse(-1)),
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
            _arrow('day-picker-next', Icons.chevron_right_rounded,
                _canGoForward, () => _browse(1)),
          ],
        ),
        const SizedBox(height: 10),
        // An unseen copy of the week gives the pages their height.
        Stack(
          children: [
            Visibility.maintain(
              visible: false,
              child: ExcludeSemantics(child: _week(_weekStart, keyed: false)),
            ),
            Positioned.fill(
              child: PageView.builder(
                key: const ValueKey('day-picker-weeks'),
                controller: _pages,
                itemCount: _weekCount,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, page) =>
                    _week(_firstWeek.addDays(7 * page)),
              ),
            ),
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

  Widget _chip(int index, Jalali day, {bool keyed = true}) {
    final isPast = daysBetween(widget.today, day) < 0;
    final selected =
        widget.selected != null && isSameJalaliDay(day, widget.selected!);
    final marked =
        widget.markedDay != null && isSameJalaliDay(day, widget.markedDay!);
    final isToday = isSameJalaliDay(day, widget.today);

    return Semantics(
      button: true,
      enabled: !isPast,
      selected: selected,
      label: dayLabel(day),
      child: GestureDetector(
        key: keyed ? ValueKey('week-day-chip-$index') : null,
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
              color:
                  marked && !selected ? AppColors.black1 : Colors.transparent,
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
                          ? AppColors.black1
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

/// Quick add: a title, a day, a type and tags, then the next task.
/// [onSubmit] returns null when the task was created, otherwise the message
/// to show. "Advanced settings" closes the sheet and hands everything chosen
/// so far to [onMoreOptions], which opens the full form with it.
///
/// There are no tags until a title is typed: then [suggestTags] asks the
/// server which tags fit it, and those come already selected. Each new title
/// asks again. While a tag is typed, [tagCatalog] entries matching it are
/// offered.
Future<void> showQuickAddSheet(
  BuildContext context, {
  required Jalali initialDay,
  required Jalali today,
  required Future<String?> Function(QuickTaskDraft draft) onSubmit,
  required ValueChanged<QuickTaskDraft> onMoreOptions,
  Future<List<String>> Function(String title)? suggestTags,
  List<String> tagCatalog = const [],
  bool initialTimed = true,
}) {
  return _showPlanSheet<void>(
    context,
    _QuickAddSheet(
      initialDay: daysBetween(today, initialDay) < 0 ? today : initialDay,
      today: today,
      suggestTags: suggestTags,
      tagCatalog: tagCatalog,
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
    required this.suggestTags,
    required this.tagCatalog,
    required this.initialTimed,
    required this.onSubmit,
    required this.onMoreOptions,
  });

  final Jalali initialDay;
  final Jalali today;
  final Future<List<String>> Function(String title)? suggestTags;
  final List<String> tagCatalog;
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
  bool _submitting = false;
  String? _error;
  String? _titleError;
  int _titleErrorTick = 0;
  final List<String> _added = [];
  final TextEditingController _title = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  late final TagSelection _tags = TagSelection(
    suggest: widget.suggestTags,
    catalog: widget.tagCatalog,
  );

  @override
  void initState() {
    super.initState();
    _title.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _title.dispose();
    _titleFocus.dispose();
    _tags.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    if (_title.text.trim().isNotEmpty &&
        (_titleError != null || _error != null)) {
      setState(() {
        _titleError = null;
        _error = null;
      });
    }
    _tags.titleChanged(_title.text);
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() {
        _titleError = 'عنوان تسک را بنویسید.';
        _titleErrorTick++;
      });
      _titleFocus.requestFocus();
      return;
    }

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
        // The next task starts clean; its title brings its own tags.
        _tags.reset();
        _title.clear();
      } else {
        _error = error;
      }
    });
    if (error == null) {
      HapticFeedback.lightImpact();
      _titleFocus.requestFocus();
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  QuickTaskDraft _draft(String title) => QuickTaskDraft(
        title: title,
        day: _day,
        timedMinutes: _timed ? _minutes : null,
        tags: List.unmodifiable(_tags.selected),
      );

  void _openFullForm() {
    final draft = _draft(_title.text.trim());
    Navigator.of(context).pop();
    widget.onMoreOptions(draft);
  }

  @override
  Widget build(BuildContext context) {
    var section = 0;
    Widget enter(Widget child) =>
        TaskFormEntrance(index: section++, child: child);

    return PlanSheetFrame(
      key: const ValueKey('quick-add-sheet'),
      title: 'تسک جدید',
      subtitle: 'برای ${dayLabel(_day)}',
      footer: _buildActions(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          enter(
            TaskTextField(
              fieldKey: const ValueKey('quick-add-title'),
              controller: _title,
              focusNode: _titleFocus,
              autofocus: true,
              hint: 'عنوان تسک، مثلاً «حل تمرین فصل ۳»',
              textInputAction: TextInputAction.done,
              error: _titleError,
              errorTick: _titleErrorTick,
              onSubmitted: (_) => _submit(),
            ),
          ),
          enter(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TaskSectionLabel('روز'),
                WeekDayPicker(
                  selected: _day,
                  today: widget.today,
                  onChanged: (day) => setState(() => _day = day),
                ),
              ],
            ),
          ),
          enter(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TaskSectionLabel('نوع'),
                _Segmented(
                  options: const [
                    (key: 'quick-add-type-timed', text: 'زمان‌دار'),
                    (key: 'quick-add-type-checklist', text: 'چک‌لیست'),
                  ],
                  selected: _timed ? 0 : 1,
                  onChanged: (index) => setState(() => _timed = index == 0),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: !_timed
                        ? const SizedBox(width: double.infinity)
                        : Padding(
                            key: const ValueKey('quick-add-durations'),
                            padding: const EdgeInsets.only(top: 10),
                            child: TaskDurationPicker(
                              options: _minuteOptions,
                              selected: _minutes,
                              keyPrefix: 'quick-add',
                              onChanged: (minutes) =>
                                  setState(() => _minutes = minutes),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          enter(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TaskSectionLabel(
                  'تگ‌ها',
                  trailing: TagSuggestionStatus(
                    selection: _tags,
                    keyPrefix: 'quick-add',
                  ),
                ),
                TagSelectionChips(selection: _tags, keyPrefix: 'quick-add'),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _added.isEmpty
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: _AddedTasks(titles: _added),
                  ),
          ),
          TaskFormError(
            message: _error,
            messageKey: const ValueKey('quick-add-error'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Pinned under the scrolling fields, so «ثبت تسک» never needs a scroll.
  Widget _buildActions() {
    return TaskFormActions(
      secondary: PlanPillButton.outlined(
        key: const ValueKey('quick-add-more'),
        text: 'تنظیمات پیشرفته',
        icon: Icons.tune_rounded,
        fontSize: 13,
        onTap: _openFullForm,
      ),
      primary: PlanPillButton(
        key: const ValueKey('quick-add-submit'),
        text: 'ثبت تسک',
        icon: Icons.check_rounded,
        isLoading: _submitting,
        onTap: _submit,
      ),
    );
  }
}

/// Two or more options on one gray track; the chosen one sits on a white
/// thumb.
class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<({String key, String text})> options;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          for (var index = 0; index < options.length; index++)
            Expanded(
              child: Semantics(
                button: true,
                selected: index == selected,
                child: GestureDetector(
                  key: ValueKey(options[index].key),
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (index == selected) return;
                    HapticFeedback.selectionClick();
                    onChanged(index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: index == selected
                          ? AppColors.whiteSec
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: index == selected
                          ? [
                              BoxShadow(
                                color: AppColors.black1.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: ReText(
                      options[index].text,
                      fontSize: 13,
                      fontWeight:
                          index == selected ? FontWeight.w800 : FontWeight.w600,
                      color:
                          index == selected ? AppColors.black1 : AppColors.gray,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// What was added from this sheet so far, newest first; each new title
/// slides in at the front.
class _AddedTasks extends StatelessWidget {
  const _AddedTasks({required this.titles});

  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Saved: the one place green belongs.
              const Icon(Icons.check_circle_rounded,
                  size: 16, color: AppColors.done),
              const SizedBox(width: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: ReText(
                  '${convertToPersianNumbers(titles.length.toString())} تسک ثبت شد',
                  key: ValueKey(titles.length),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              // Keyed from the oldest, so only the new one animates in.
              for (var index = 0; index < titles.length; index++)
                _AddedTitle(
                  key: ValueKey('added-${titles.length - index}'),
                  title: titles[index],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddedTitle extends StatelessWidget {
  const _AddedTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
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
    );
    if (reduceMotion(context)) return chip;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      child: chip,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.8 + 0.2 * t, child: child),
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
  return _showPlanSheet<Jalali>(
      context, _MoveTaskSheet(task: task, today: today));
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
