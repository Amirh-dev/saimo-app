import 'dart:async';

import 'package:ferry/ferry.dart' show OperationResponse;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gql_http_link/gql_http_link.dart' show HttpLinkServerException;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/core/global/global_data.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/data/notifications/task_reminder_service.dart';
import 'package:simo_learn/features/tags/tag_suggestion_repository.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/create_task.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/update_task.req.gql.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/tag_selection.dart';
import 'package:simo_learn/presentation/screens/tasks/task_form_widgets.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/screens/tasks/tasks_api.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_button.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/presentation/widgets/re_text_field.dart';
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

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// Earliest selectable date: today, or the task's own date when editing a
/// task that is already in the past.
Jalali _pickerMinDate(Jalali selected) {
  final now = Jalali.now();
  final selectedIsPast = selected.year != now.year
      ? selected.year < now.year
      : selected.month != now.month
          ? selected.month < now.month
          : selected.day < now.day;
  return selectedIsPast ? selected : now;
}

/// The form's tags, picked as in quick add: the task's own when editing, or
/// what quick add chose. Tags already chosen belong to the title they came
/// with, so the server is asked only once the title changes; a title handed
/// over without tags is asked about at once.
TagSelection _formTagSelection(
  BuildContext context, {
  required Map<String, dynamic>? editing,
  required String title,
  required List<String> initialTags,
}) {
  final existing = editing != null
      ? (editing['tags'] as List?)?.cast<String>() ?? const <String>[]
      : initialTags;
  return TagSelection(
    suggest:
        TagSuggestionRepository(context.read<GraphQLRepository>()).suggestTags,
    catalog: [for (final tag in GlobalData.instance.parentTags) tag.name],
    initial: existing,
    initialTitle: editing != null || existing.isNotEmpty ? title : '',
  )..titleChanged(title);
}

Set<String> _weekdaysFromRecurring(String? raw) {
  if (raw == null) return {};
  final known = _weekDayOptions.map((day) => day.code).toSet();
  return RegExp(r'[A-Za-z]{3}')
      .allMatches(raw)
      .map((m) => m.group(0)!.toUpperCase())
      .where(known.contains)
      .toSet();
}

class WeekDayOption {
  const WeekDayOption(this.code, this.label);

  final String code;
  final String label;
}

const List<WeekDayOption> _weekDayOptions = [
  WeekDayOption('SAT', 'شنبه'),
  WeekDayOption('SUN', 'یکشنبه'),
  WeekDayOption('MON', 'دوشنبه'),
  WeekDayOption('TUE', 'سه‌شنبه'),
  WeekDayOption('WED', 'چهارشنبه'),
  WeekDayOption('THU', 'پنجشنبه'),
  WeekDayOption('FRI', 'جمعه'),
];

List<String> _recurrenceWeekdays(Set<String> selectedDays) {
  return _weekDayOptions
      .map((day) => day.code)
      .where(selectedDays.contains)
      .toList();
}

/// Schedules the local reminder for a freshly created task: weekly on the
/// selected weekdays for recurring tasks, otherwise once at [date].
Future<void> _scheduleReminder(
  String taskId,
  String title,
  DateTime date, {
  bool isWeekly = false,
  Set<String> weekdays = const {},
  TimeOfDay time = kDefaultReminderTime,
}) async {
  final service = TaskReminderService.instance;
  final days = isWeekly ? _recurrenceWeekdays(weekdays) : const <String>[];
  if (days.isNotEmpty) {
    await service.scheduleWeekly(
        taskId: taskId, title: title, weekdays: days, time: time);
  } else {
    await service.scheduleOnce(
      taskId: taskId,
      title: title,
      when: DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }
}

const String _taskRecurrenceQuery = r'''
query TaskRecurrence($id: ID!) {
  getTask(id: $id) { recurrenceID }
}
''';

/// Schedules the reminder of a task just created. A weekly reminder is keyed
/// by the recurrence rather than by the first occurrence the server returned.
Future<void> _scheduleCreatedTaskReminder(
  GraphQLRepository repository,
  String taskId,
  String title,
  DateTime date, {
  required bool isWeekly,
  required Set<String> weekdays,
  required TimeOfDay time,
}) async {
  var key = taskId;
  if (isWeekly) {
    try {
      final data = await repository.rawRequest(
        query: _taskRecurrenceQuery,
        variables: {'id': taskId},
      );
      final recurrenceId =
          (data['getTask'] as Map?)?['recurrenceID'] as String?;
      if (recurrenceId != null)
        key = TaskReminderService.recurrenceKey(recurrenceId);
    } catch (error) {
      debugPrint('Loading task recurrence for its reminder failed: $error');
    }
  }
  await _scheduleReminder(key, title, date,
      isWeekly: isWeekly, weekdays: weekdays, time: time);
}

/// Default reminder hour for a new task: the start of the next hour.
TimeOfDay _initialReminderTime(Map<String, dynamic>? editing) {
  final saved = editing?['reminderTime'] as DateTime?;
  if (saved != null) return TimeOfDay.fromDateTime(saved);
  return TimeOfDay(hour: (TimeOfDay.now().hour + 1) % 24, minute: 0);
}

String _formatReminderTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return convertToPersianNumbers('$hour:$minute');
}

/// One-off reminders must be in the future; weekly ones always have a next
/// occurrence.
bool _isReminderInPast(Jalali date, TimeOfDay time, {required bool isWeekly}) {
  if (isWeekly) return false;
  return !_toDateTime(date, time: time).isAfter(DateTime.now());
}

Future<TimeOfDay?> _showReminderTimePicker(
    BuildContext context, TimeOfDay initial) {
  FocusManager.instance.primaryFocus?.unfocus();
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _ReminderTimePickerSheet(initialTime: initial),
  );
}

/// The header's subtitle: when the task happens.
String _formSubtitle(String dateLabel, bool weekly) =>
    weekly ? 'تکرار هفتگی' : 'برای $dateLabel';

/// The scrolling column the forms' sections sit in.
Widget _taskFormBody({required List<Widget> children}) {
  return SingleChildScrollView(
    physics: const ClampingScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    ),
  );
}

/// Pinned under the form, as in quick add: what went wrong, if anything,
/// then «لغو» and the main action.
Widget _taskFormFooter({
  required String? error,
  required String submitText,
  required bool isSubmitting,
  required VoidCallback onSubmit,
  required VoidCallback? onCancel,
}) {
  return DecoratedBox(
    decoration: const BoxDecoration(
      color: AppColors.white,
      border: Border(top: BorderSide(color: AppColors.gray2)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        // heightFactor: a bottom bar may be as tall as the screen; without
        // it this would stretch over (and swallow taps on) the whole form.
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TaskFormError(
                  message: error,
                  messageKey: const ValueKey('task-form-error'),
                ),
                const SizedBox(height: 12),
                TaskFormActions(
                  secondary: PlanPillButton.outlined(
                    key: const ValueKey('task-form-cancel'),
                    text: 'لغو',
                    icon: Icons.close_rounded,
                    onTap: onCancel,
                  ),
                  primary: PlanPillButton(
                    key: const ValueKey('task-form-submit'),
                    text: submitText,
                    icon: Icons.check_rounded,
                    isLoading: isSubmitting,
                    onTap: onSubmit,
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

/// The tags, picked as in quick add.
Widget _formTagsSection(TagSelection tags) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TaskSectionLabel(
        'تگ‌ها',
        trailing: TagSuggestionStatus(selection: tags, keyPrefix: 'task-form'),
      ),
      TagSelectionChips(selection: tags, keyPrefix: 'task-form'),
    ],
  );
}

/// Why the server refused to save the task, for the form's error box.
String _responseFailure(OperationResponse<dynamic, dynamic> response) {
  const fallback = 'ذخیره تسک ناموفق بود؛ دوباره تلاش کنید.';
  final link = response.linkException;
  if (link != null) {
    if (link is HttpLinkServerException) {
      final status = link.response.statusCode;
      if (status == 401) {
        return taskFailureMessage(const UnauthorizedException(),
            fallback: fallback);
      }
      if (status >= 500) {
        return 'سرور فعلاً پاسخ نمی‌دهد؛ کمی بعد دوباره تلاش کنید.';
      }
    }
    // No answer at all: most often the connection.
    return taskFailureMessage(
      link.originalException ?? link,
      fallback:
          'اتصال به اینترنت برقرار نیست؛ اتصال را بررسی کنید و دوباره تلاش کنید.',
    );
  }
  return taskFailureMessage(graphQLResponseErrorMessage(response),
      fallback: fallback);
}

/// How both full forms tell the user what is wrong: the title field itself
/// for a missing title, the box above the actions for everything else.
mixin _TaskFormFeedback<T extends StatefulWidget> on State<T> {
  String? _titleError;
  int _titleErrorTick = 0;
  String? _formError;

  FocusNode get _titleFocusNode;

  void _showTitleError() {
    setState(() {
      _titleError = 'عنوان تسک را بنویسید.';
      _titleErrorTick++;
    });
    _titleFocusNode.requestFocus();
  }

  void _failWith(String message) {
    HapticFeedback.heavyImpact();
    setState(() => _formError = message);
  }

  void _clearTitleErrorFor(String title) {
    if (_titleError != null && title.trim().isNotEmpty) {
      setState(() => _titleError = null);
    }
  }
}

class AddTimedTaskScreen extends StatefulWidget {
  const AddTimedTaskScreen({
    super.key,
    this.goalId,
    this.onBack,
    this.task,
    this.initialDate,
    this.initialTitle,
    this.initialMinutes,
    this.initialTags = const [],
  });

  final String? goalId;
  final VoidCallback? onBack;

  /// When set, the screen edits this task (update API) instead of creating one.
  final Map<String, dynamic>? task;

  /// Date a new task starts on (defaults to today). Ignored when editing.
  final Jalali? initialDate;

  /// Title typed elsewhere (quick add) before opening the full form.
  final String? initialTitle;

  /// Duration and tags already chosen in quick add. Ignored when editing.
  final int? initialMinutes;
  final List<String> initialTags;

  @override
  State<AddTimedTaskScreen> createState() => _AddTimedTaskScreenState();
}

class _AddTimedTaskScreenState extends State<AddTimedTaskScreen>
    with _TaskFormFeedback {
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

  // The same durations quick add offers.
  static const List<int> _baseMinuteOptions = kTaskDurations;
  late List<int> _minuteOptions;

  bool get _isEditing => widget.task != null;

  bool _isWeeklyRepeat = false;
  bool _isReminderEnabled = false;
  late TimeOfDay _reminderTime;
  bool _isSubmitting = false;

  final Set<String> _selectedWeekDays = {};

  late Jalali _selectedDate;
  late Jalali _visibleCalendarMonth;

  int _selectedMinutes = 45;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _noteController;

  @override
  late FocusNode _titleFocusNode;
  late FocusNode _descriptionFocusNode;
  late FocusNode _noteFocusNode;

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.initialDate ?? Jalali.now();
    _reminderTime = _initialReminderTime(widget.task);
    _selectedMinutes = widget.initialMinutes ?? kDefaultTaskMinutes;
    final editing = widget.task;
    if (editing != null) {
      _selectedDate = editing['date'] as Jalali? ?? _selectedDate;
      final seconds = editing['durationSeconds'] as int?;
      if (seconds != null && seconds > 0) _selectedMinutes = seconds ~/ 60;
    }
    _minuteOptions = {..._baseMinuteOptions, _selectedMinutes}.toList()..sort();
    _visibleCalendarMonth = Jalali(_selectedDate.year, _selectedDate.month, 1);
    _titleController = TextEditingController(
        text: widget.task?['title'] as String? ?? widget.initialTitle ?? '');
    _tags = _formTagSelection(
      context,
      editing: editing,
      title: _titleController.text,
      initialTags: widget.initialTags,
    );
    _descriptionController = TextEditingController(
        text: widget.task?['shortDescription'] as String? ?? '');
    _noteController =
        TextEditingController(text: widget.task?['note'] as String? ?? '');
    if (editing != null) {
      _isReminderEnabled = editing['reminder'] as bool? ?? false;
      _selectedWeekDays
          .addAll(_weekdaysFromRecurring(editing['recurringDays'] as String?));
      _isWeeklyRepeat = _selectedWeekDays.isNotEmpty;
    }
    _titleFocusNode = FocusNode()..addListener(_handleFieldFocusChange);
    _descriptionFocusNode = FocusNode()..addListener(_handleFieldFocusChange);
    _noteFocusNode = FocusNode()..addListener(_handleFieldFocusChange);
  }

  @override
  void dispose() {
    _tags.dispose();
    _titleFocusNode
      ..removeListener(_handleFieldFocusChange)
      ..dispose();
    _descriptionFocusNode
      ..removeListener(_handleFieldFocusChange)
      ..dispose();
    _noteFocusNode
      ..removeListener(_handleFieldFocusChange)
      ..dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleFieldFocusChange() {
    if (!mounted) return;
    setState(() {});
  }

  late final TagSelection _tags;

  void _onTitleChanged(String value) {
    _tags.titleChanged(value);
    _clearTitleErrorFor(value);
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

  void _selectDateModeTimed() {
    setState(() {
      _isWeeklyRepeat = false;
      _visibleCalendarMonth =
          Jalali(_selectedDate.year, _selectedDate.month, 1);
    });
    _openCalendarModal();
  }

  void _selectWeeklyRepeatTimed() {
    setState(() {
      _isWeeklyRepeat = true;
    });
  }

  void _toggleWeekDay(String code) {
    setState(() {
      if (code == 'ALL') {
        if (_selectedWeekDays.length == _weekDayOptions.length) {
          _selectedWeekDays.clear();
        } else {
          _selectedWeekDays
            ..clear()
            ..addAll(_weekDayOptions.map((day) => day.code));
        }
      } else if (!_selectedWeekDays.remove(code)) {
        _selectedWeekDays.add(code);
      }
    });
  }

  Future<void> _onReminderChanged(bool value) async {
    if (!value) {
      setState(() => _isReminderEnabled = false);
      return;
    }
    final picked = await _showReminderTimePicker(context, _reminderTime);
    if (picked == null || !mounted) return;
    setState(() {
      _reminderTime = picked;
      _isReminderEnabled = true;
    });
  }

  Future<void> _changeReminderTime() async {
    final picked = await _showReminderTimePicker(context, _reminderTime);
    if (picked == null || !mounted) return;
    setState(() => _reminderTime = picked);
  }

  Future<void> _openCalendarModal() async {
    final picked = await showModalBottomSheet<Jalali>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _ThreeColumnJalaliDatePickerSheet(
          initialDate: _selectedDate,
          minDate: _pickerMinDate(_selectedDate),
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

  Future<void> _updateTimedTask() async {
    final taskId = widget.task!['id'] as String;
    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    try {
      final taskDate = _toDateTime(_selectedDate);
      final response = await context.read<GraphQLRepository>().requestOnce(
        GUpdateTaskReq(
          (request) {
            request.vars.id = taskId;
            request.vars.input
              ..title = _titleController.text.trim()
              ..shortDescription = _descriptionController.text.trim()
              ..note = _noteController.text.trim()
              ..durationM = _selectedMinutes
              ..hasReminder = _isReminderEnabled
              ..tagNames.replace(_tags.selected);

            // An edit targets this task, or this one occurrence of a recurring
            // task; updateTask has no recurrence input.
            request.vars.input.date.value = taskDate.toUtc().toIso8601String();

            if (_isReminderEnabled) {
              request.vars.input.reminderTime.value =
                  _toDateTime(_selectedDate, time: _reminderTime)
                      .toUtc()
                      .toIso8601String();
            }
          },
        ),
      );

      if (!mounted) return;

      if (response.hasErrors || response.data?.updateTask == null) {
        _failWith(_responseFailure(response));
        return;
      }

      final task = response.data!.updateTask;
      await TaskReminderService.instance.cancel(taskId);
      if (_isReminderEnabled) {
        unawaited(_scheduleReminder(task.id, task.title, taskDate,
            time: _reminderTime));
      }
      if (!mounted) return;

      Navigator.of(context)
          .pop(<String, dynamic>{'id': task.id, 'updated': true});
    } catch (error) {
      if (!mounted) return;
      debugPrint('Saving the task failed: $error');
      _failWith(taskFailureMessage(error,
          fallback: 'ذخیره تسک ناموفق بود؛ دوباره تلاش کنید.'));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitTimedTask() async {
    setState(() => _formError = null);
    if (!_isFormValid) {
      _showTitleError();
      return;
    }

    if (_isWeeklyRepeat && _selectedWeekDays.isEmpty) {
      _failWith('حداقل یک روز را برای تکرار انتخاب کنید.');
      return;
    }

    if (_isReminderEnabled &&
        _isReminderInPast(_selectedDate, _reminderTime,
            isWeekly: _isWeeklyRepeat)) {
      _failWith('زمان یادآوری گذشته است؛ زمان دیگری انتخاب کنید.');
      return;
    }

    if (_isEditing) {
      await _updateTimedTask();
      return;
    }

    final description = _descriptionController.text.trim();
    final tags = _tags.selected.join(' ');
    final note = _noteController.text.trim();

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    try {
      final taskDate = _toDateTime(_selectedDate);
      final tagNames = _tags.selected;
      final response = await context.read<GraphQLRepository>().requestOnce(
        GCreateTaskReq(
          (request) {
            request.vars.input
              ..title = _titleController.text.trim()
              ..shortDescription = _emptyToNull(description)
              ..type = GTaskType.TIMED
              ..note = _emptyToNull(note)
              ..durationM = _selectedMinutes
              ..hasReminder = _isReminderEnabled
              ..tagNames.addAll(tagNames);

            // The server requires exactly one of `date` or `recurrence`.
            final weekdays = _isWeeklyRepeat
                ? _recurrenceWeekdays(_selectedWeekDays)
                : <String>[];
            if (weekdays.isNotEmpty) {
              request.vars.input.recurrence.weekdays.replace(weekdays);
            } else {
              request.vars.input.date.value =
                  taskDate.toUtc().toIso8601String();
            }

            final goalId = _emptyToNull(widget.goalId ?? '');
            if (goalId != null) {
              request.vars.input.goalID = goalId;
            }

            // The server rejects reminderTime on a recurring task; its weekly
            // reminder is scheduled on the device below.
            if (_isReminderEnabled && weekdays.isEmpty) {
              request.vars.input.reminderTime.value =
                  _toDateTime(_selectedDate, time: _reminderTime)
                      .toUtc()
                      .toIso8601String();
            }
          },
        ),
      );

      if (!mounted) return;

      if (response.hasErrors || response.data?.createTask == null) {
        debugPrint(
            'Creating the task failed: ${response.graphqlErrors} ${response.linkException}');
        _failWith(_responseFailure(response));
        return;
      }

      final task = response.data!.createTask;
      if (_isReminderEnabled) {
        unawaited(_scheduleCreatedTaskReminder(
            context.read<GraphQLRepository>(), task.id, task.title, taskDate,
            isWeekly: _isWeeklyRepeat,
            weekdays: _selectedWeekDays,
            time: _reminderTime));
      }
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
      debugPrint('Saving the task failed: $error');
      _failWith(taskFailureMessage(error,
          fallback: 'ذخیره تسک ناموفق بود؛ دوباره تلاش کنید.'));
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
    var section = 0;
    Widget enter(Widget child) =>
        TaskFormEntrance(index: section++, child: child);

    return PopScope(
      onPopInvokedWithResult: (final _, final __) {
        widget.onBack?.call();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          bottom: false,
          child: _taskFormBody(
            children: [
              enter(
                TaskFormHeader(
                  title:
                      _isEditing ? 'ویرایش تسک زمان‌دار' : 'تسک زمان‌دار جدید',
                  subtitle: _formSubtitle(_scheduleDateLabel, _isWeeklyRepeat),
                ),
              ),
              const SizedBox(height: 22),
              enter(
                TaskTextField(
                  fieldKey: const ValueKey('task-form-title'),
                  controller: _titleController,
                  focusNode: _titleFocusNode,
                  hint: 'عنوان تسک، مثلاً «حل تمرین فصل ۳»',
                  error: _titleError,
                  errorTick: _titleErrorTick,
                  textInputAction: TextInputAction.next,
                  onChanged: _onTitleChanged,
                ),
              ),
              const SizedBox(height: 10),
              enter(
                TaskTextField(
                  fieldKey: const ValueKey('task-form-description'),
                  controller: _descriptionController,
                  focusNode: _descriptionFocusNode,
                  hint: 'توضیح کوتاه (اختیاری)',
                  maxLength: 50,
                ),
              ),
              enter(_formTagsSection(_tags)),
              enter(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TaskSectionLabel('مدت زمان'),
                    TaskDurationPicker(
                      options: _minuteOptions,
                      selected: _selectedMinutes,
                      keyPrefix: 'task-form',
                      onChanged: (minutes) =>
                          setState(() => _selectedMinutes = minutes),
                    ),
                  ],
                ),
              ),
              enter(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TaskSectionLabel('یادداشت'),
                    TaskTextField(
                      fieldKey: const ValueKey('task-form-note'),
                      controller: _noteController,
                      focusNode: _noteFocusNode,
                      hint: 'نکته‌ای که موقع انجام کار لازم دارید (اختیاری)',
                      maxLength: 200,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              enter(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TaskSectionLabel('زمان'),
                    _buildDateCardCompact(),
                    const SizedBox(height: 10),
                    _buildReminderCardCompact(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _taskFormFooter(
          error: _formError,
          submitText: _isEditing ? 'ذخیره' : 'ثبت تسک',
          isSubmitting: _isSubmitting,
          onSubmit: _submitTimedTask,
          onCancel: _isSubmitting ? null : () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildDateCardCompact() {
    return _ScheduleSelectionCard(
      formattedDateLabel: _scheduleDateLabel,
      isWeeklyRepeat: _isWeeklyRepeat,
      onSelectDateMode: _selectDateModeTimed,
      onSelectWeeklyRepeat: _selectWeeklyRepeatTimed,
      showWeeklyRepeat: !_isEditing,
      selectedWeekDays: _selectedWeekDays,
      onToggleWeekDay: _toggleWeekDay,
      timedTask: true,
    );
  }

  Widget _buildReminderCardCompact() {
    return _ReminderCard(
      isEnabled: _isReminderEnabled,
      time: _reminderTime,
      onChanged: _onReminderChanged,
      onTapTime: _changeReminderTime,
      borderRadius: 32,
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({
    super.key,
    this.goalId,
    this.task,
    this.initialDate,
    this.initialTitle,
    this.initialTags = const [],
  });

  final String? goalId;

  /// When set, the screen edits this task (update API) instead of creating one.
  final Map<String, dynamic>? task;

  /// Date a new task starts on (defaults to today). Ignored when editing.
  final Jalali? initialDate;

  /// Title typed elsewhere (quick add) before opening the full form.
  final String? initialTitle;

  /// Tags already chosen in quick add. Ignored when editing.
  final List<String> initialTags;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> with _TaskFormFeedback {
  bool _isWeeklyRepeat = false;
  bool _isReminderEnabled = false;
  late TimeOfDay _reminderTime;
  bool _isSubmitting = false;

  bool get _isEditing => widget.task != null;

  final Set<String> _selectedWeekDays = {};

  late Jalali _selectedDate;
  late Jalali _visibleCalendarMonth;
  late TimeOfDay _selectedTime;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  @override
  late FocusNode _titleFocusNode;
  late FocusNode _descriptionFocusNode;

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

    _selectedDate = widget.initialDate ?? Jalali.now();
    _reminderTime = _initialReminderTime(widget.task);
    _visibleCalendarMonth = Jalali(_selectedDate.year, _selectedDate.month, 1);
    _selectedTime = TimeOfDay.fromDateTime(DateTime.now());
    final editing = widget.task;
    if (editing != null) {
      _selectedDate = editing['date'] as Jalali? ?? _selectedDate;
      _visibleCalendarMonth =
          Jalali(_selectedDate.year, _selectedDate.month, 1);
      final dateTime = editing['dateTime'] as DateTime?;
      if (dateTime != null) _selectedTime = TimeOfDay.fromDateTime(dateTime);
      _isReminderEnabled = editing['reminder'] as bool? ?? false;
      _selectedWeekDays
          .addAll(_weekdaysFromRecurring(editing['recurringDays'] as String?));
      _isWeeklyRepeat = _selectedWeekDays.isNotEmpty;
    }
    _titleController = TextEditingController(
        text: editing?['title'] as String? ?? widget.initialTitle ?? '');
    _tags = _formTagSelection(
      context,
      editing: editing,
      title: _titleController.text,
      initialTags: widget.initialTags,
    );
    _descriptionController = TextEditingController(
        text: editing?['shortDescription'] as String? ?? '');
    _titleFocusNode = FocusNode()..addListener(_handleFieldFocusChange);
    _descriptionFocusNode = FocusNode()..addListener(_handleFieldFocusChange);
  }

  @override
  void dispose() {
    _tags.dispose();
    _titleFocusNode
      ..removeListener(_handleFieldFocusChange)
      ..dispose();
    _descriptionFocusNode
      ..removeListener(_handleFieldFocusChange)
      ..dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  late final TagSelection _tags;

  void _onTitleChanged(String value) {
    _tags.titleChanged(value);
    _clearTitleErrorFor(value);
  }

  void _handleFieldFocusChange() {
    if (!mounted) return;
    setState(() {});
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
    });
  }

  void _toggleWeekDay(String code) {
    setState(() {
      if (code == 'ALL') {
        if (_selectedWeekDays.length == _weekDayOptions.length) {
          _selectedWeekDays.clear();
        } else {
          _selectedWeekDays
            ..clear()
            ..addAll(_weekDayOptions.map((day) => day.code));
        }
      } else if (!_selectedWeekDays.remove(code)) {
        _selectedWeekDays.add(code);
      }
    });
  }

  Future<void> _onReminderChanged(bool value) async {
    if (!value) {
      setState(() => _isReminderEnabled = false);
      return;
    }
    final picked = await _showReminderTimePicker(context, _reminderTime);
    if (picked == null || !mounted) return;
    setState(() {
      _reminderTime = picked;
      _isReminderEnabled = true;
    });
  }

  Future<void> _changeReminderTime() async {
    final picked = await _showReminderTimePicker(context, _reminderTime);
    if (picked == null || !mounted) return;
    setState(() => _reminderTime = picked);
  }

  Future<void> _openCalendarModal() async {
    final picked = await showModalBottomSheet<Jalali>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _ThreeColumnJalaliDatePickerSheet(
          initialDate: _selectedDate,
          minDate: _pickerMinDate(_selectedDate),
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

  Future<void> _updateTask() async {
    final taskId = widget.task!['id'] as String;
    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    try {
      final taskDate = _toDateTime(_selectedDate, time: _selectedTime);
      final response = await context.read<GraphQLRepository>().requestOnce(
        GUpdateTaskReq(
          (request) {
            request.vars.id = taskId;
            request.vars.input
              ..title = _titleController.text.trim()
              ..shortDescription = _descriptionController.text.trim()
              ..hasReminder = _isReminderEnabled
              ..tagNames.replace(_tags.selected);

            // An edit targets this task, or this one occurrence of a recurring
            // task; updateTask has no recurrence input.
            request.vars.input.date.value = taskDate.toUtc().toIso8601String();

            if (_isReminderEnabled) {
              request.vars.input.reminderTime.value =
                  _toDateTime(_selectedDate, time: _reminderTime)
                      .toUtc()
                      .toIso8601String();
            }
          },
        ),
      );

      if (!mounted) return;

      if (response.hasErrors || response.data?.updateTask == null) {
        _failWith(_responseFailure(response));
        return;
      }

      final task = response.data!.updateTask;
      await TaskReminderService.instance.cancel(taskId);
      if (_isReminderEnabled) {
        unawaited(_scheduleReminder(task.id, task.title, taskDate,
            time: _reminderTime));
      }
      if (!mounted) return;

      Navigator.of(context)
          .pop(<String, dynamic>{'id': task.id, 'updated': true});
    } catch (error) {
      if (!mounted) return;
      debugPrint('Saving the task failed: $error');
      _failWith(taskFailureMessage(error,
          fallback: 'ذخیره تسک ناموفق بود؛ دوباره تلاش کنید.'));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitTask() async {
    setState(() => _formError = null);
    if (!_isFormValid) {
      _showTitleError();
      return;
    }

    if (_isWeeklyRepeat && _selectedWeekDays.isEmpty) {
      _failWith('حداقل یک روز را برای تکرار انتخاب کنید.');
      return;
    }

    if (_isReminderEnabled &&
        _isReminderInPast(_selectedDate, _reminderTime,
            isWeekly: _isWeeklyRepeat)) {
      _failWith('زمان یادآوری گذشته است؛ زمان دیگری انتخاب کنید.');
      return;
    }

    if (_isEditing) {
      await _updateTask();
      return;
    }

    final description = _descriptionController.text.trim();
    final tags = _tags.selected.join(' ');
    final time =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    try {
      final taskDate = _toDateTime(_selectedDate, time: _selectedTime);
      final tagNames = _tags.selected;
      final response = await context.read<GraphQLRepository>().requestOnce(
        GCreateTaskReq(
          (request) {
            request.vars.input
              ..title = _titleController.text.trim()
              ..shortDescription = _emptyToNull(description)
              ..type = GTaskType.NORMAL
              ..hasReminder = _isReminderEnabled
              ..tagNames.addAll(tagNames);

            // The server requires exactly one of `date` or `recurrence`.
            final weekdays = _isWeeklyRepeat
                ? _recurrenceWeekdays(_selectedWeekDays)
                : <String>[];
            if (weekdays.isNotEmpty) {
              request.vars.input.recurrence.weekdays.replace(weekdays);
            } else {
              request.vars.input.date.value =
                  taskDate.toUtc().toIso8601String();
            }

            final goalId = _emptyToNull(widget.goalId ?? '');
            if (goalId != null) {
              request.vars.input.goalID = goalId;
            }

            // The server rejects reminderTime on a recurring task; its weekly
            // reminder is scheduled on the device below.
            if (_isReminderEnabled && weekdays.isEmpty) {
              request.vars.input.reminderTime.value =
                  _toDateTime(_selectedDate, time: _reminderTime)
                      .toUtc()
                      .toIso8601String();
            }
          },
        ),
      );

      if (!mounted) return;

      if (response.hasErrors || response.data?.createTask == null) {
        debugPrint(
            'Creating the task failed: ${response.graphqlErrors} ${response.linkException}');
        _failWith(_responseFailure(response));
        return;
      }

      final task = response.data!.createTask;
      if (_isReminderEnabled) {
        unawaited(_scheduleCreatedTaskReminder(
            context.read<GraphQLRepository>(), task.id, task.title, taskDate,
            isWeekly: _isWeeklyRepeat,
            weekdays: _selectedWeekDays,
            time: _reminderTime));
      }
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
      debugPrint('Saving the task failed: $error');
      _failWith(taskFailureMessage(error,
          fallback: 'ذخیره تسک ناموفق بود؛ دوباره تلاش کنید.'));
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
    var section = 0;
    Widget enter(Widget child) =>
        TaskFormEntrance(index: section++, child: child);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: _taskFormBody(
          children: [
            enter(
              TaskFormHeader(
                title: _isEditing ? 'ویرایش چک‌لیست' : 'چک‌لیست جدید',
                subtitle: _formSubtitle(_scheduleDateLabel, _isWeeklyRepeat),
              ),
            ),
            const SizedBox(height: 22),
            enter(
              TaskTextField(
                fieldKey: const ValueKey('task-form-title'),
                controller: _titleController,
                focusNode: _titleFocusNode,
                hint: 'عنوان تسک، مثلاً «خرید کتاب تست»',
                error: _titleError,
                errorTick: _titleErrorTick,
                textInputAction: TextInputAction.next,
                onChanged: _onTitleChanged,
              ),
            ),
            const SizedBox(height: 10),
            enter(
              TaskTextField(
                fieldKey: const ValueKey('task-form-description'),
                controller: _descriptionController,
                focusNode: _descriptionFocusNode,
                hint: 'توضیح کوتاه (اختیاری)',
                maxLength: 50,
              ),
            ),
            enter(_formTagsSection(_tags)),
            enter(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TaskSectionLabel('زمان'),
                  _buildDateCard(),
                  const SizedBox(height: 10),
                  _buildReminderCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _taskFormFooter(
        error: _formError,
        submitText: _isEditing ? 'ذخیره' : 'ثبت تسک',
        isSubmitting: _isSubmitting,
        onSubmit: _submitTask,
        onCancel: _isSubmitting ? null : () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildDateCard() {
    return _ScheduleSelectionCard(
      formattedDateLabel: _scheduleDateLabel,
      isWeeklyRepeat: _isWeeklyRepeat,
      onSelectDateMode: _selectDateModeDirectly,
      onSelectWeeklyRepeat: _selectWeeklyRepeatDirectly,
      showWeeklyRepeat: !_isEditing,
      selectedWeekDays: _selectedWeekDays,
      onToggleWeekDay: _toggleWeekDay,
      timedTask: false,
    );
  }

  Widget _buildReminderCard() {
    return _ReminderCard(
      isEnabled: _isReminderEnabled,
      time: _reminderTime,
      onChanged: _onReminderChanged,
      onTapTime: _changeReminderTime,
      borderRadius: 26,
    );
  }
}

class _ScheduleSelectionCard extends StatelessWidget {
  const _ScheduleSelectionCard({
    required this.formattedDateLabel,
    required this.isWeeklyRepeat,
    required this.onSelectDateMode,
    required this.onSelectWeeklyRepeat,
    required this.selectedWeekDays,
    required this.onToggleWeekDay,
    required this.timedTask,
    this.showWeeklyRepeat = true,
  });

  final String formattedDateLabel;
  final bool isWeeklyRepeat;
  final VoidCallback onSelectDateMode;
  final VoidCallback onSelectWeeklyRepeat;
  final Set<String> selectedWeekDays;
  final ValueChanged<String> onToggleWeekDay;
  final bool timedTask;

  /// The server cannot turn an existing task into a recurring one, so the
  /// edit screens hide this option.
  final bool showWeeklyRepeat;

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
          if (showWeeklyRepeat) ...[
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
            if (isWeeklyRepeat)
              _WeekDaysPopupField(
                selectedDays: selectedWeekDays,
                onToggleDay: onToggleWeekDay,
                timedTask: timedTask,
              ),
          ],
        ],
      ),
    );
  }
}

class _WeekDaysPopupField extends StatefulWidget {
  const _WeekDaysPopupField({
    required this.selectedDays,
    required this.onToggleDay,
    required this.timedTask,
  });

  final Set<String> selectedDays;
  final ValueChanged<String> onToggleDay;
  final bool timedTask;

  @override
  State<_WeekDaysPopupField> createState() => _WeekDaysPopupFieldState();
}

class _WeekDaysPopupFieldState extends State<_WeekDaysPopupField> {
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void didUpdateWidget(covariant _WeekDaysPopupField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_overlayEntry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _overlayEntry?.markNeedsBuild();
      });
    }
  }

  @override
  void dispose() {
    _removeOverlayEntry();
    super.dispose();
  }

  void _removeOverlayEntry() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _closePopup() {
    _removeOverlayEntry();
    if (mounted) setState(() => _isOpen = false);
  }

  void _openPopup() {
    final overlayState = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closePopup,
              ),
            ),
            Positioned(
              bottom: widget.timedTask ? 50 : 100,
              child: SafeArea(
                child: Material(
                  color: Colors.transparent,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width,
                        maxHeight: 300),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.gray2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black1.withOpacity(0.14),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: _WeekDaysGrid(
                        selectedDays: widget.selectedDays,
                        onToggleDay: widget.onToggleDay,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlayState.insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _togglePopup() {
    if (_isOpen) {
      _closePopup();
    } else {
      _openPopup();
    }
  }

  String get _triggerLabel {
    if (widget.selectedDays.isEmpty) return 'انتخاب روز';
    final labels = _weekDayOptions
        .where((day) => widget.selectedDays.contains(day.code))
        .map((day) => day.label);
    return 'هر ${labels.join('، ')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePopup,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.gray1,
          borderRadius: BorderRadius.circular(34),
          border:
              Border.all(color: _isOpen ? AppColors.primary : AppColors.gray2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(
              _isOpen
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: AppColors.black1.withOpacity(0.5),
              size: 20,
            ),
            Expanded(
              child: ReText(
                textAlign: TextAlign.start,
                _triggerLabel,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.black1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekDaysGrid extends StatelessWidget {
  const _WeekDaysGrid({
    required this.selectedDays,
    required this.onToggleDay,
  });

  final Set<String> selectedDays;
  final ValueChanged<String> onToggleDay;

  bool get _isAllSelected => selectedDays.length == _weekDayOptions.length;

  @override
  Widget build(BuildContext context) {
    final items = <MapEntry<String, String>>[
      const MapEntry('ALL', 'هرروز'),
      for (final day in _weekDayOptions) MapEntry(day.code, 'هر ${day.label}'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 0),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5,
          childAspectRatio: 3.1,
          mainAxisExtent: 35),
      itemBuilder: (context, index) {
        final entry = items[index];
        final isChecked = entry.key == 'ALL'
            ? _isAllSelected
            : selectedDays.contains(entry.key);

        return GestureDetector(
          onTap: () => onToggleDay(entry.key),
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              ReText(
                entry.value,
                fontSize: 13,
                fontWeight: isChecked ? FontWeight.w700 : FontWeight.w600,
                color: isChecked
                    ? AppColors.black1
                    : AppColors.black1.withOpacity(0.55),
              ),
              const SizedBox(width: 8),
              _SquareCheckbox(isChecked: isChecked),
            ],
          ),
        );
      },
    );
  }
}

class _SquareCheckbox extends StatelessWidget {
  const _SquareCheckbox({required this.isChecked});

  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: isChecked
            ? AppColors.primary.withOpacity(0.12)
            : Colors.transparent,
        border: Border.all(
          color: isChecked ? AppColors.primary : AppColors.dark4Color,
          width: 1.2,
        ),
      ),
      child: isChecked
          ? const Icon(
              Icons.check_rounded,
              size: 14,
              color: AppColors.primary,
            )
          : null,
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

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    // The picked option in the brand color; the dot grows in.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.dark4Color,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Center(
        child: AnimatedScale(
          scale: isSelected ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
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

class _ReminderTimePickerSheet extends StatefulWidget {
  const _ReminderTimePickerSheet({required this.initialTime});

  final TimeOfDay initialTime;

  @override
  State<_ReminderTimePickerSheet> createState() =>
      _ReminderTimePickerSheetState();
}

class _ReminderTimePickerSheetState extends State<_ReminderTimePickerSheet> {
  static const double _wheelItemExtent = 56.0;
  static const int _minuteStep = 5;

  late int _selectedHour;
  late int _selectedMinute;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute ~/ _minuteStep * _minuteStep;
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(
        initialItem: _selectedMinute ~/ _minuteStep);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  Widget _buildColumn({
    required FixedExtentScrollController controller,
    required int itemCount,
    required int Function(int index) valueAt,
    required int selectedValue,
    required ValueChanged<int> onSelected,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _PickerWheel(
          controller: controller,
          itemCount: itemCount,
          itemExtent: _wheelItemExtent,
          onSelected: (index) => setState(() => onSelected(valueAt(index))),
          itemBuilder: (context, index) {
            return SizedBox(
              height: _wheelItemExtent,
              child: Center(
                child: ReText(
                  convertToPersianNumbers(
                      valueAt(index).toString().padLeft(2, '0')),
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
              convertToPersianNumbers(selectedValue.toString().padLeft(2, '0')),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.white,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeHeight = MediaQuery.of(context).size.height;
    final sheetHeight = (safeHeight * 0.58).clamp(300.0, 400.0);

    return Container(
      height: sheetHeight,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
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
                      'یادآوری',
                      fontSize: 16,
                      fontWeight: 1000,
                      color: AppColors.black1,
                    ),
                    const SizedBox(height: 2),
                    ReText(
                      'انتخاب ساعت یادآوری',
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
                      'دقیقه',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black1,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ReText(
                      'ساعت',
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
                    child: _buildColumn(
                      controller: _minuteController,
                      itemCount: 60 ~/ _minuteStep,
                      valueAt: (index) => index * _minuteStep,
                      selectedValue: _selectedMinute,
                      onSelected: (value) => _selectedMinute = value,
                    ),
                  ),
                  Expanded(
                    child: _buildColumn(
                      controller: _hourController,
                      itemCount: 24,
                      valueAt: (index) => index,
                      selectedValue: _selectedHour,
                      onSelected: (value) => _selectedHour = value,
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
                  child: _ActionButton(
                    text: 'تنظیم یادآوری',
                    icon: Icons.check,
                    background: AppColors.primary,
                    textColor: AppColors.white,
                    onTap: () => Navigator.of(context).pop(
                      TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
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

/// Reminder toggle row; shows the chosen time (tap to change) while enabled.
class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.isEnabled,
    required this.time,
    required this.onChanged,
    required this.onTapTime,
    required this.borderRadius,
  });

  final bool isEnabled;
  final TimeOfDay time;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTapTime;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.gray2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          _ReminderSwitch(value: isEnabled, onChanged: onChanged),
          if (isEnabled) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onTapTime,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gray1,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    ReText(
                      _formatReminderTime(time),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black1,
                    ),
                  ],
                ),
              ),
            ),
          ],
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
