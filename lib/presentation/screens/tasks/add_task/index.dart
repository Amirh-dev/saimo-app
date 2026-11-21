import 'dart:async';

import 'package:ferry/ferry.dart' show OperationResponse;
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:simo_learn/features/onboarding/onboarding_store.dart';
import 'package:flutter/services.dart';
import 'package:gql_http_link/gql_http_link.dart' show HttpLinkServerException;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/core/global/global_data.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/data/notifications/task_reminder_service.dart';
import 'package:simo_learn/presentation/screens/tasks/alarm_access_sheet.dart';
import 'package:simo_learn/features/tags/tag_suggestion_repository.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/create_task.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/update_task.req.gql.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/presentation/screens/tasks/tag_selection.dart';
import 'package:simo_learn/presentation/screens/tasks/task_form_widgets.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/screens/tasks/tasks_api.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_widgets.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly_repeat.dart';
import 'package:simo_learn/presentation/widgets/re_button.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/presentation/widgets/re_text_field.dart';
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
/// what quick add chose. A title the form opens with is asked about at once,
/// so the related tags are on offer as in quick add, but none is selected by
/// itself: what the form was given is the user's choice.
TagSelection _formTagSelection(
  BuildContext context, {
  required Map<String, dynamic>? editing,
  required String title,
  required List<String> initialTags,
}) {
  final existing = editing != null
      ? (editing['tags'] as List?)?.cast<String>() ?? const <String>[]
      : initialTags;
  GlobalData.instance.refreshParentTags();
  return TagSelection(
    suggest:
        TagSuggestionRepository(context.read<GraphQLRepository>()).suggestTags,
    readCatalog: () => GlobalData.instance.tagCatalog,
    initial: existing,
    // A tag blocked since it was added would make saving fail; it starts off.
    initialOff: (editing?['blockedTags'] as List?)?.cast<String>() ?? const [],
    initialTitle: title,
  )..suggestNow(select: false);
}

Set<String> _weekdaysFromRecurring(String? raw) {
  if (raw == null) return {};
  final known = kWeekDayOptions.map((day) => day.code).toSet();
  return RegExp(r'[A-Za-z]{3}')
      .allMatches(raw)
      .map((m) => m.group(0)!.toUpperCase())
      .where(known.contains)
      .toSet();
}

List<String> _recurrenceWeekdays(Set<String> selectedDays) {
  return kWeekDayOptions
      .map((day) => day.code)
      .where(selectedDays.contains)
      .toList();
}

/// Sets the alarm for a task just saved. A one-off task rings at once from
/// here; every task, weekly ones included, is then rebuilt from the server's
/// schedule so each occurrence has its own alarm.
Future<void> _scheduleReminder(
  String taskId,
  String title,
  DateTime date, {
  bool isWeekly = false,
  TimeOfDay time = kDefaultReminderTime,
}) async {
  final service = TaskReminderService.instance;
  if (!isWeekly) {
    await service.scheduleOnce(
      taskId: taskId,
      title: title,
      when: DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  } else {
    await service.requestPermission();
  }
  await service.sync();
}

const String _seriesReminderMutation = r'''
mutation UpdateSeriesReminder($id: ID!, $input: UpdateTaskInput!) {
  updateTask(id: $id, input: $input) { id }
}
''';

/// Whether the edit turned the reminder on or off, or moved its time.
bool _reminderChangedFrom(
  Map<String, dynamic>? editing,
  bool enabled,
  TimeOfDay time,
) {
  final wasOn = editing?['reminder'] as bool? ?? false;
  if (wasOn != enabled) return true;
  if (!enabled) return false;
  final saved = editing?['reminderTime'] as DateTime?;
  return saved == null || TimeOfDay.fromDateTime(saved) != time;
}

/// After editing one copy of a weekly task. Its reminder belongs to the
/// whole series: a change goes to this and the later copies on the server,
/// then the phone's alarms are rebuilt from there.
Future<void> _saveSeriesReminder(
  GraphQLRepository repository, {
  required String taskId,
  required bool enabled,
  required DateTime reminderAt,
  required bool changed,
}) async {
  if (changed) {
    try {
      await repository.rawRequest(
        query: _seriesReminderMutation,
        variables: {
          'id': taskId,
          'input': {
            'hasReminder': enabled,
            if (enabled) 'reminderTime': reminderAt.toUtc().toIso8601String(),
            'recurrenceScope': 'FUTURE_OCCURRENCES',
          },
        },
      );
    } catch (error) {
      debugPrint('Saving the weekly reminder on the server failed: $error');
    }
  }
  if (enabled) await TaskReminderService.instance.requestPermission();
  await TaskReminderService.instance.sync();
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

/// The header's subtitle: when the task happens, in the switch's words.
String _formSubtitle(String dateLabel, bool weekly, Set<String> days) {
  if (!weekly) return 'برای $dateLabel';
  return days.isEmpty ? 'هر هفته' : weeklyRepeatSummary(days);
}

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
  const fallback = 'ذخیره تسک ناموفق بود؛ دوباره امتحان کن.';
  final link = response.linkException;
  if (link != null) {
    if (link is HttpLinkServerException) {
      final status = link.response.statusCode;
      if (status == 401) {
        return taskFailureMessage(const UnauthorizedException(),
            fallback: fallback);
      }
      if (status >= 500) {
        return 'سرور فعلاً جواب نمی‌ده؛ کمی بعد دوباره امتحان کن.';
      }
    }
    // No answer at all: most often the connection.
    return taskFailureMessage(
      link.originalException ?? link,
      fallback: 'اینترنت وصل نیست؛ اتصالت رو چک کن و دوباره امتحان کن.',
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
      _titleError = 'عنوان تسک رو بنویس.';
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
    this.initialWeekdays = const [],
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

  /// Weekly repeat days already picked in quick add. Ignored when editing.
  final List<String> initialWeekdays;

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
  static List<int> get _baseMinuteOptions => taskDurationOptions;
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

  // The note starts folded into a chip unless the task already has one.
  late bool _showNote;

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
    _showNote = _noteController.text.isNotEmpty;
    if (editing != null) {
      _isReminderEnabled = editing['reminder'] as bool? ?? false;
      _selectedWeekDays
          .addAll(_weekdaysFromRecurring(editing['recurringDays'] as String?));
      _isWeeklyRepeat = _selectedWeekDays.isNotEmpty;
    } else if (widget.initialWeekdays.isNotEmpty) {
      _selectedWeekDays.addAll(widget.initialWeekdays);
      _isWeeklyRepeat = true;
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

  void _openNote() {
    setState(() => _showNote = true);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _noteFocusNode.requestFocus());
  }

  void _selectOneDay() => setState(() => _isWeeklyRepeat = false);

  void _selectWeeklyRepeatTimed() {
    setState(() {
      _isWeeklyRepeat = true;
      // Start from the day already picked, as quick add does.
      if (_selectedWeekDays.isEmpty) {
        _selectedWeekDays.add(weekdayCodeOf(_selectedDate));
      }
    });
  }

  void _toggleWeekDay(String code) {
    setState(() {
      if (code == 'ALL') {
        if (_selectedWeekDays.length == kWeekDayOptions.length) {
          _selectedWeekDays.clear();
        } else {
          _selectedWeekDays
            ..clear()
            ..addAll(kWeekDayOptions.map((day) => day.code));
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
    if (await ensureAlarmAccess(context) || !mounted) return;
    setState(() => _isReminderEnabled = false);
    showReToast(context, kAlarmNotSetMessage, ReToastType.error);
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
      final recurrenceId = widget.task!['recurrenceId'] as String?;
      if (recurrenceId != null) {
        unawaited(_saveSeriesReminder(
          context.read<GraphQLRepository>(),
          taskId: taskId,
          enabled: _isReminderEnabled,
          reminderAt: _toDateTime(_selectedDate, time: _reminderTime),
          changed: _reminderChangedFrom(
              widget.task, _isReminderEnabled, _reminderTime),
        ));
      } else {
        await TaskReminderService.instance.cancel(taskId);
        if (_isReminderEnabled) {
          unawaited(_scheduleReminder(task.id, task.title, taskDate,
              time: _reminderTime));
        }
      }
      if (!mounted) return;

      Navigator.of(context)
          .pop(<String, dynamic>{'id': task.id, 'updated': true});
    } catch (error) {
      if (!mounted) return;
      debugPrint('Saving the task failed: $error');
      _failWith(taskFailureMessage(error,
          fallback: 'ذخیره تسک ناموفق بود؛ دوباره امتحان کن.'));
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
      _failWith('حداقل یک روز رو برای تکرار انتخاب کن.');
      return;
    }

    if (_isReminderEnabled &&
        _isReminderInPast(_selectedDate, _reminderTime,
            isWeekly: _isWeeklyRepeat)) {
      _failWith('زمان یادآوری گذشته؛ یک زمان دیگه انتخاب کن.');
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
      final repository = context.read<GraphQLRepository>();
      // A server from before Oct 2026 refuses a reminder time on a weekly
      // task; then it is sent again without one (the phone still reminds).
      send({required bool weeklyReminderTime}) => repository.requestOnce(
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

                // The server keeps this clock time for every weekly copy, so the
                // edit screen and other devices know it.
                if (_isReminderEnabled &&
                    (weekdays.isEmpty || weeklyReminderTime)) {
                  request.vars.input.reminderTime.value =
                      _toDateTime(_selectedDate, time: _reminderTime)
                          .toUtc()
                          .toIso8601String();
                }
              },
            ),
          );
      var response = await send(weeklyReminderTime: true);
      if (_isReminderEnabled &&
          _isWeeklyRepeat &&
          (response.graphqlErrors?.isNotEmpty ?? false)) {
        response = await send(weeklyReminderTime: false);
      }

      if (!mounted) return;

      if (response.hasErrors || response.data?.createTask == null) {
        debugPrint(
            'Creating the task failed: ${response.graphqlErrors} ${response.linkException}');
        _failWith(_responseFailure(response));
        return;
      }

      final task = response.data!.createTask;
      OnboardingStore.instance.markPlanned();
      if (_isReminderEnabled) {
        unawaited(_scheduleReminder(task.id, task.title, taskDate,
            isWeekly: _isWeeklyRepeat, time: _reminderTime));
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
          fallback: 'ذخیره تسک ناموفق بود؛ دوباره امتحان کن.'));
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
                  subtitle: _formSubtitle(
                      _scheduleDateLabel, _isWeeklyRepeat, _selectedWeekDays),
                ),
              ),
              const SizedBox(height: 22),
              enter(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    TagTitleHint(selection: _tags, keyPrefix: 'task-form'),
                  ],
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
              // When before the optional note, so weekly repeat is in view.
              enter(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Not «زمان»: it sat next to «مدت زمان» and read like the same thing.
                    TaskSectionLabel(
                        _isWeeklyRepeat ? 'روزهای انجام' : 'روز انجام'),
                    _buildDateCardCompact(),
                    const SizedBox(height: 10),
                    _buildReminderCardCompact(),
                  ],
                ),
              ),
              enter(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Folded, the chip names itself; no label above it.
                    if (_showNote) ...[
                      const TaskSectionLabel('یادداشت'),
                      TaskTextField(
                        fieldKey: const ValueKey('task-form-note'),
                        controller: _noteController,
                        focusNode: _noteFocusNode,
                        hint: 'نکته‌ای که موقع انجام کار لازم داری (اختیاری)',
                        maxLength: 200,
                        maxLines: 4,
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _AddNoteChip(onTap: _openNote),
                        ),
                      ),
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
      onSelectOneDay: _selectOneDay,
      onTapDate: _selectDateModeTimed,
      onSelectWeeklyRepeat: _selectWeeklyRepeatTimed,
      showWeeklyRepeat: !_isEditing,
      selectedWeekDays: _selectedWeekDays,
      onToggleWeekDay: _toggleWeekDay,
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
    this.initialWeekdays = const [],
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

  /// Weekly repeat days already picked in quick add. Ignored when editing.
  final List<String> initialWeekdays;

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
    } else if (widget.initialWeekdays.isNotEmpty) {
      _selectedWeekDays.addAll(widget.initialWeekdays);
      _isWeeklyRepeat = true;
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

  void _selectOneDay() => setState(() => _isWeeklyRepeat = false);

  void _selectWeeklyRepeatDirectly() {
    setState(() {
      _isWeeklyRepeat = true;
      // Start from the day already picked, as quick add does.
      if (_selectedWeekDays.isEmpty) {
        _selectedWeekDays.add(weekdayCodeOf(_selectedDate));
      }
    });
  }

  void _toggleWeekDay(String code) {
    setState(() {
      if (code == 'ALL') {
        if (_selectedWeekDays.length == kWeekDayOptions.length) {
          _selectedWeekDays.clear();
        } else {
          _selectedWeekDays
            ..clear()
            ..addAll(kWeekDayOptions.map((day) => day.code));
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
    if (await ensureAlarmAccess(context) || !mounted) return;
    setState(() => _isReminderEnabled = false);
    showReToast(context, kAlarmNotSetMessage, ReToastType.error);
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
      final recurrenceId = widget.task!['recurrenceId'] as String?;
      if (recurrenceId != null) {
        unawaited(_saveSeriesReminder(
          context.read<GraphQLRepository>(),
          taskId: taskId,
          enabled: _isReminderEnabled,
          reminderAt: _toDateTime(_selectedDate, time: _reminderTime),
          changed: _reminderChangedFrom(
              widget.task, _isReminderEnabled, _reminderTime),
        ));
      } else {
        await TaskReminderService.instance.cancel(taskId);
        if (_isReminderEnabled) {
          unawaited(_scheduleReminder(task.id, task.title, taskDate,
              time: _reminderTime));
        }
      }
      if (!mounted) return;

      Navigator.of(context)
          .pop(<String, dynamic>{'id': task.id, 'updated': true});
    } catch (error) {
      if (!mounted) return;
      debugPrint('Saving the task failed: $error');
      _failWith(taskFailureMessage(error,
          fallback: 'ذخیره تسک ناموفق بود؛ دوباره امتحان کن.'));
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
      _failWith('حداقل یک روز رو برای تکرار انتخاب کن.');
      return;
    }

    if (_isReminderEnabled &&
        _isReminderInPast(_selectedDate, _reminderTime,
            isWeekly: _isWeeklyRepeat)) {
      _failWith('زمان یادآوری گذشته؛ یک زمان دیگه انتخاب کن.');
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
      final repository = context.read<GraphQLRepository>();
      // A server from before Oct 2026 refuses a reminder time on a weekly
      // task; then it is sent again without one (the phone still reminds).
      send({required bool weeklyReminderTime}) => repository.requestOnce(
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

                // The server keeps this clock time for every weekly copy, so the
                // edit screen and other devices know it.
                if (_isReminderEnabled &&
                    (weekdays.isEmpty || weeklyReminderTime)) {
                  request.vars.input.reminderTime.value =
                      _toDateTime(_selectedDate, time: _reminderTime)
                          .toUtc()
                          .toIso8601String();
                }
              },
            ),
          );
      var response = await send(weeklyReminderTime: true);
      if (_isReminderEnabled &&
          _isWeeklyRepeat &&
          (response.graphqlErrors?.isNotEmpty ?? false)) {
        response = await send(weeklyReminderTime: false);
      }

      if (!mounted) return;

      if (response.hasErrors || response.data?.createTask == null) {
        debugPrint(
            'Creating the task failed: ${response.graphqlErrors} ${response.linkException}');
        _failWith(_responseFailure(response));
        return;
      }

      final task = response.data!.createTask;
      OnboardingStore.instance.markPlanned();
      if (_isReminderEnabled) {
        unawaited(_scheduleReminder(task.id, task.title, taskDate,
            isWeekly: _isWeeklyRepeat, time: _reminderTime));
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
          fallback: 'ذخیره تسک ناموفق بود؛ دوباره امتحان کن.'));
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
                subtitle: _formSubtitle(
                    _scheduleDateLabel, _isWeeklyRepeat, _selectedWeekDays),
              ),
            ),
            const SizedBox(height: 22),
            enter(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  TagTitleHint(selection: _tags, keyPrefix: 'task-form'),
                ],
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
                  // Not «زمان»: it sat next to «مدت زمان» and read like the same thing.
                  TaskSectionLabel(
                      _isWeeklyRepeat ? 'روزهای انجام' : 'روز انجام'),
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
      onSelectOneDay: _selectOneDay,
      onTapDate: _selectDateModeDirectly,
      onSelectWeeklyRepeat: _selectWeeklyRepeatDirectly,
      showWeeklyRepeat: !_isEditing,
      selectedWeekDays: _selectedWeekDays,
      onToggleWeekDay: _toggleWeekDay,
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

/// SharedPreferences key: the one-time tip on «هر هفته» was shown.
const weeklyRepeatTipSeenKey = 'weekly_repeat_tip_seen';

/// When the task happens: one day (a date) or every week (on picked days).
/// The «هر هفته» side is pulsed and explained by a tip the first time the
/// form is opened on this device; the days are picked inline, no popup.
class _ScheduleSelectionCard extends StatefulWidget {
  const _ScheduleSelectionCard({
    required this.formattedDateLabel,
    required this.isWeeklyRepeat,
    required this.onSelectOneDay,
    required this.onTapDate,
    required this.onSelectWeeklyRepeat,
    required this.selectedWeekDays,
    required this.onToggleWeekDay,
    this.showWeeklyRepeat = true,
  });

  final String formattedDateLabel;
  final bool isWeeklyRepeat;
  final VoidCallback onSelectOneDay;
  final VoidCallback onTapDate;
  final VoidCallback onSelectWeeklyRepeat;
  final Set<String> selectedWeekDays;
  final ValueChanged<String> onToggleWeekDay;

  /// The server cannot turn an existing task into a recurring one, so the
  /// edit screens hide this option.
  final bool showWeeklyRepeat;

  @override
  State<_ScheduleSelectionCard> createState() => _ScheduleSelectionCardState();
}

class _ScheduleSelectionCardState extends State<_ScheduleSelectionCard>
    with SingleTickerProviderStateMixin {
  bool _showTip = false;

  // Two soft pulses of the «هر هفته» outline while the tip is up.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  late final Animation<double> _glow = TweenSequence<double>([
    for (var i = 0; i < 2; i++) ...[
      TweenSequenceItem(tween: Tween(begin: 0.35, end: 1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0.35), weight: 1),
    ],
  ]).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    if (widget.showWeeklyRepeat && !widget.isWeeklyRepeat) _loadTip();
  }

  Future<void> _loadTip() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(weeklyRepeatTipSeenKey) ?? false) return;
      // Seen once it is shown, so it never comes back.
      await prefs.setBool(weeklyRepeatTipSeenKey, true);
    } catch (_) {
      return; // No storage: skip the tip rather than show it every time.
    }
    if (!mounted || widget.isWeeklyRepeat) return;
    setState(() => _showTip = true);
    _pulse.forward();
  }

  void _hideTip() {
    if (!_showTip) return;
    _pulse.stop();
    setState(() => _showTip = false);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = _SelectedDateSummary(
      formattedDateLabel: widget.formattedDateLabel,
      isEnabled: true,
      onTap: widget.onTapDate,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.gray2),
      ),
      padding: const EdgeInsets.all(14),
      child: !widget.showWeeklyRepeat
          ? date
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                RepeatSwitch(
                  isWeekly: widget.isWeeklyRepeat,
                  glow: _showTip ? _glow : null,
                  onOneDay: () {
                    _hideTip();
                    widget.onSelectOneDay();
                  },
                  onWeekly: () {
                    _hideTip();
                    widget.onSelectWeeklyRepeat();
                  },
                ),
                if (_showTip) ...[
                  const SizedBox(height: 4),
                  _RepeatTip(onTap: _hideTip),
                ],
                const SizedBox(height: 12),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: widget.isWeeklyRepeat
                      ? WeeklyRepeatDays(
                          selectedDays: widget.selectedWeekDays,
                          onToggleDay: widget.onToggleWeekDay,
                          today: Jalali.now(),
                        )
                      : date,
                ),
              ],
            ),
    );
  }
}

class _RepeatTip extends StatelessWidget {
  const _RepeatTip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // «هر هفته» is the left half of the switch; the arrow points at its middle.
    return LayoutBuilder(
      builder: (context, constraints) {
        final arrowLeft = (constraints.maxWidth - 8) / 4 + 4 - 8;
        return Directionality(
          // Physical left: the tip sits under «هر هفته».
          textDirection: TextDirection.ltr,
          child: GestureDetector(
            key: const ValueKey('repeat-tip'),
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: arrowLeft),
                  child: CustomPaint(
                    size: const Size(16, 8),
                    painter: _TipArrowPainter(),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.black1,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const ReText(
                    'درس‌هایی که هر هفته داری رو یه بار بساز.',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TipArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.black1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
                const SizedBox(width: 8),
                Expanded(
                  child: ReText(
                    formattedDateLabel,
                    textAlign: TextAlign.right,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// «+ یادداشت»: the folded note, in the dashed look of «+ تگ دیگر».
class _AddNoteChip extends StatelessWidget {
  const _AddNoteChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey('task-form-add-note'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const DashedBorder(
        child: SizedBox(
          height: 34,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.rtl,
              children: [
                Icon(Icons.add_rounded, size: 16, color: AppColors.gray),
                SizedBox(width: 4),
                ReText(
                  'یادداشت',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray,
                ),
              ],
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

  /// Only [minDate] and later are offered: a task cannot be planned for a
  /// day that has passed, so those days are not shown at all.
  late List<int> _years;
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  @override
  void initState() {
    super.initState();
    final min = widget.minDate;
    final soon = Jalali.now().year + 2;
    final lastYear =
        widget.initialDate.year > soon ? widget.initialDate.year : soon;
    _years = [for (var y = min.year; y <= lastYear; y++) y];

    _selectedYear = widget.initialDate.year.clamp(_years.first, _years.last);
    _selectedMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;

    _yearController = FixedExtentScrollController(
      initialItem: _years.indexOf(_selectedYear),
    );
    _monthController = _monthControllerFor(_selectedYear);
    _dayController = _dayControllerFor();
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  List<int> get _monthsInSelectedYear {
    final first =
        _selectedYear == widget.minDate.year ? widget.minDate.month : 1;
    return [for (var m = first; m <= 12; m++) m];
  }

  List<int> get _daysInSelectedMonth {
    final monthLength = Jalali(_selectedYear, _selectedMonth, 1).monthLength;
    final min = widget.minDate;
    final first =
        _selectedYear == min.year && _selectedMonth == min.month ? min.day : 1;
    return [for (var d = first; d <= monthLength; d++) d];
  }

  /// Keeps the month within [year]'s offered months and returns a wheel
  /// controller resting on it.
  FixedExtentScrollController _monthControllerFor(int year) {
    final months = _monthsInSelectedYear;
    _selectedMonth = _selectedMonth.clamp(months.first, months.last);
    return FixedExtentScrollController(
      initialItem: months.indexOf(_selectedMonth),
    );
  }

  FixedExtentScrollController _dayControllerFor() {
    final days = _daysInSelectedMonth;
    _selectedDay = _selectedDay.clamp(days.first, days.last);
    return FixedExtentScrollController(
      initialItem: days.indexOf(_selectedDay),
    );
  }

  /// Swaps in fresh wheels after the year or month changed, since the
  /// offered months and days may have changed with it. The old controllers
  /// are let go once the new wheels are built.
  void _rebuildWheels({required bool months}) {
    final oldMonth = months ? _monthController : null;
    final oldDay = _dayController;
    if (months) _monthController = _monthControllerFor(_selectedYear);
    _dayController = _dayControllerFor();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      oldMonth?.dispose();
      oldDay.dispose();
    });
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
                          controller: _dayController,
                          itemCount: _daysInSelectedMonth.length,
                          itemExtent: _wheelItemExtent,
                          onSelected: (index) {
                            setState(() {
                              _selectedDay = _daysInSelectedMonth[index];
                            });
                          },
                          itemBuilder: (context, index) {
                            final day = _daysInSelectedMonth[index];
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
                          itemCount: _monthsInSelectedYear.length,
                          itemExtent: _wheelItemExtent,
                          onSelected: (index) {
                            setState(() {
                              _selectedMonth = _monthsInSelectedYear[index];
                              _rebuildWheels(months: false);
                            });
                          },
                          itemBuilder: (context, index) {
                            final name = widget
                                .monthNames[_monthsInSelectedYear[index] - 1];
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
                              _rebuildWheels(months: true);
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
/// Tests set this to see the web look; null means the real platform.
@visibleForTesting
bool? debugTaskRemindersSupported;

/// Task reminders are local notifications, which browsers never fire.
bool get _taskRemindersSupported => debugTaskRemindersSupported ?? !kIsWeb;

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
    if (!_taskRemindersSupported) return _unsupported();
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

  /// On the web: the card faded and off, and why.
  Widget _unsupported() {
    return Column(
      key: const ValueKey('task-form-reminder-unsupported'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        IgnorePointer(
          child: Opacity(
            opacity: 0.5,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: AppColors.gray2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  _ReminderSwitch(value: false, onChanged: (_) {}),
                  const Spacer(),
                  const ReText(
                    'یادآوری',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black1,
                  ),
                ],
              ),
            ),
          ),
        ),
        const TaskFormHint('یادآوری فقط تو اپ گوشی کار می‌کنه.'),
      ],
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
