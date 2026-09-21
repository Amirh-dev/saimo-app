import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/core/global/global_data.dart';
import 'package:simo_learn/core/global/global_data_model.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/data/notifications/task_reminder_service.dart';
import 'package:simo_learn/features/tags/tag_suggestion_repository.dart';
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
  return value.split(' ').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).take(2).toList();
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
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
  return _weekDayOptions.map((day) => day.code).where(selectedDays.contains).toList();
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
    await service.scheduleWeekly(taskId: taskId, title: title, weekdays: days, time: time);
  } else {
    await service.scheduleOnce(
      taskId: taskId,
      title: title,
      when: DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }
}

class AddTimedTaskScreen extends StatefulWidget {
  const AddTimedTaskScreen({super.key, this.goalId, this.onBack});

  final String? goalId;
  final VoidCallback? onBack;

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

  final Set<String> _selectedWeekDays = {};

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

  List<ParentTagModel> availableTags = GlobalData.instance.parentTags;

  @override
  void initState() {
    super.initState();

    _tagSuggestionRepository = TagSuggestionRepository(
      context.read<GraphQLRepository>(),
    );

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
    _tagSuggestionDebounce?.cancel();
    _tagSuggestionRequestId++;

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

  final List<ParentTagModel> _selectedTags = [];

  late final TagSuggestionRepository _tagSuggestionRepository;
  Timer? _tagSuggestionDebounce;
  int _tagSuggestionRequestId = 0;
  List<ParentTagModel> _specificSuggestedTags = <ParentTagModel>[];

  void _onTitleChanged(String value) {
    setState(() {
      _tagSuggestionDebounce?.cancel();

      final title = value.trim();

      if (title.isEmpty) {
        _tagSuggestionRequestId++;

        if (mounted) {
          _specificSuggestedTags = <ParentTagModel>[];
          availableTags = GlobalData.instance.parentTags;
        }

        return;
      }

      // Clear the previous title's suggestions immediately.
      // Until the new API result arrives, global public tags are used as backup.
      if (mounted) {
        _specificSuggestedTags = <ParentTagModel>[];
        availableTags = GlobalData.instance.parentTags;
      }

      // Avoid sending one request for every keystroke.
      _tagSuggestionDebounce = Timer(
        const Duration(milliseconds: 450),
            () => _loadSpecificSuggestedTags(title),
      );
    });
  }

  Future<void> _loadSpecificSuggestedTags(String title) async {
    final requestId = ++_tagSuggestionRequestId;

    try {
      final names = await _tagSuggestionRepository.suggestTags(title);

      // Ignore an old response if the user has already typed a newer title.
      if (!mounted || requestId != _tagSuggestionRequestId) return;

      final uniqueNames = <String>[];
      final seen = <String>{};

      for (final name in names) {
        final normalized = name.trim();

        if (normalized.isEmpty) continue;

        final key = normalized.toLowerCase();

        if (seen.add(key)) {
          uniqueNames.add(normalized);
        }
      }

        _specificSuggestedTags = [
          for (var index = 0; index < uniqueNames.length; index++)
            ParentTagModel(
              id: 'suggested_${index}_${uniqueNames[index]}',
              name: uniqueNames[index],
              kind: 'SUGGESTED',
              moderationStatus: 'APPROVED',
            ),
        ];
        availableTags = _specificSuggestedTags;
    } catch (error) {
      if (!mounted || requestId != _tagSuggestionRequestId) return;

      debugPrint('SUGGEST TAGS ERROR: $error');

      // Empty means "use the global public tags as fallback".
        _specificSuggestedTags = <ParentTagModel>[];
        availableTags = GlobalData.instance.parentTags;
    }
  }

  List<String> get _selectedTagNames {
    return _tagController.text.trim().split(RegExp(r'\s+')).where((value) => value.isNotEmpty).toList();
  }

  bool _isTagAlreadySelected(ParentTagModel tag) {
    final selected = _tagController.text.trim().split(RegExp(r'\s+')).where((value) => value.isNotEmpty);

    return selected.any(
      (value) => value.toLowerCase() == tag.name.trim().toLowerCase(),
    );
  }

  void _selectTag(ParentTagModel tag) {
    if (_isTagAlreadySelected(tag)) return;

    final currentText = _tagController.text.trim();

    // Maximum 2 tags.
    final currentParts = currentText.split(RegExp(r'\s+')).where((value) => value.isNotEmpty).toList();

    if (currentParts.length >= 2) return;

    final newText = currentText.isEmpty ? tag.name.trim() : '$currentText ${tag.name.trim()}';

    _tagController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );

    setState(() {});

    // Keep keyboard open so the user can select the second tag.
    _tagFocusNode.requestFocus();
  }

  bool get _isFormValid => _titleController.text.trim().isNotEmpty;

  int get _descriptionCount => _descriptionController.text.length;

  int get _noteCount => _noteController.text.length;

  int get _tagsCount => _selectedTags.length;

  String get _scheduleDateLabel {
    final today = Jalali.now();
    final isToday = _selectedDate.year == today.year && _selectedDate.month == today.month && _selectedDate.day == today.day;
    final prefix = isToday ? 'امروز، ' : '';
    return '$prefix${_selectedDate.day} ${_persianMonths[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  void _selectDateModeTimed() {
    setState(() {
      _isWeeklyRepeat = false;
      _visibleCalendarMonth = Jalali(_selectedDate.year, _selectedDate.month, 1);
    });
    _openCalendarModal();
  }

  void _selectWeeklyRepeatTimed() {
    setState(() {
      _isWeeklyRepeat = true;
      // _isReminderEnabled = true;
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

    if (_isWeeklyRepeat && _selectedWeekDays.isEmpty) {
      showReToast(context, 'حداقل یک روز تکرار را انتخاب کنید', ReToastType.warning);
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
      final tagNames = _selectedTags.map((tag) => tag.name).toList();
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
            final weekdays = _isWeeklyRepeat ? _recurrenceWeekdays(_selectedWeekDays) : <String>[];
            if (weekdays.isNotEmpty) {
              request.vars.input.recurrence.weekdays.replace(weekdays);
            } else {
              request.vars.input.date.value = taskDate.toUtc().toIso8601String();
            }

            final goalId = _emptyToNull(widget.goalId ?? '');
            if (goalId != null) {
              request.vars.input.goalID = goalId;
            }

            if (_isReminderEnabled) {
              request.vars.input.reminderTime.value = taskDate.toUtc().toIso8601String();
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
      if (_isReminderEnabled) {
        unawaited(_scheduleReminder(task.id, task.title, taskDate, isWeekly: _isWeeklyRepeat, weekdays: _selectedWeekDays));
      }
      final minutesLabel = convertToPersianNumbers(_selectedMinutes.toString());
      final subtitle = task.shortDescription?.trim().isNotEmpty == true ? task.shortDescription!.trim() : (task.note?.trim().isNotEmpty == true ? task.note!.trim() : (tags.isNotEmpty ? tags : 'توضیحی ثبت نشده'));
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

    return PopScope(
      onPopInvokedWithResult: (final _, final __) {
        widget.onBack?.call();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
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
                        onChanged: _onTitleChanged,
                      ),
                      SizedBox(height: sectionSpacing),
                      _buildPillField(
                        hintText: 'توضیح کوتاه',
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                        maxLength: 50,
                        leadingPill: '${_descriptionCount > 50 ? 50 : _descriptionCount}/50',
                      ),
                      SizedBox(height: sectionSpacing),
                      _buildTagSuggestionField(),
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
                              onTap: _isSubmitting ? () {} : () => Navigator.of(context).pop(),
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

  Widget _buildTagSuggestionField() {
    final isFocused = _tagFocusNode.hasFocus;

    return RawAutocomplete<ParentTagModel>(
      key: ValueKey(
        _specificSuggestedTags
            .map((e) => '${e.id}_${e.name}')
            .join('|'),
      ),

      optionsBuilder: (TextEditingValue textEditingValue) {
        final tags = availableTags;

        debugPrint(
          'AVAILABLE TAGS: ${tags.map((e) => e.name).toList()}',
        );

        return tags.where((tag) {
          final query = textEditingValue.text.trim().toLowerCase();

          if (query.isEmpty) {
            return true;
          }

          return tag.name.toLowerCase().contains(query);
        });
      },
      displayStringForOption: (ParentTagModel tag) => tag.name,
      onSelected: (ParentTagModel tag) {
        if (_selectedTags.length >= 2) return;

        setState(() {
          _selectedTags.add(tag);
        });

        // The controller is ONLY the search/query text.
        _tagController.clear();

        // Let the user immediately type the second tag.
        _tagFocusNode.requestFocus();
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController controller,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return Container(
          constraints: const BoxConstraints(
            minHeight: 55,
          ),
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
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          child: Row(
            children: [
              // Counter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ReText(
                  '${_selectedTags.length}/2',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black1.withOpacity(0.35),
                ),
              ),

              const SizedBox(width: 4),

              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    // Search / typing field
                    if (_selectedTags.length < 2)
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 70,
                        ),
                        child: IntrinsicWidth(
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            cursorColor: AppColors.primary,
                            onChanged: (_) {
                              setState(() {});
                            },
                            style: TextStyle(
                              fontFamily: AppFonts.iranSansVar,
                              color: AppColors.black1,
                              fontSize: 15,
                              fontVariations: AppFonts.fontVariations(
                                FontWeight.w600,
                              ),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'افزودن تگ',
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintStyle: TextStyle(
                                fontFamily: AppFonts.iranSansVar,
                                color: AppColors.black1.withOpacity(0.45),
                                fontSize: 13,
                                fontVariations: AppFonts.fontVariations(
                                  FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Selected tag pills
                    ..._selectedTags.map(
                      (tag) => _buildSelectedTagChip(tag),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<ParentTagModel> onSelected,
        Iterable<ParentTagModel> options,
      ) {
        final items = options.toList();

        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.topRight,
          child: Material(
            color: AppColors.white,
            elevation: 8,
            shadowColor: AppColors.black1.withOpacity(0.10),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: MediaQuery.of(context).size.width - 36,
              constraints: const BoxConstraints(
                maxHeight: 230,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.gray2,
                ),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) {
                  return Divider(
                    height: 1,
                    color: AppColors.gray2,
                  );
                },
                itemBuilder: (context, index) {
                  final tag = items[index];

                  return InkWell(
                    onTap: () => onSelected(tag),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ReText(
                            tag.name,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black1,
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedTagChip(ParentTagModel tag) {
    return Container(
      height: 38,
      padding: const EdgeInsets.only(
        left: 8,
        right: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.gray2,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedTags.removeWhere(
                  (selected) => selected.id == tag.id,
                );
              });

              _tagFocusNode.requestFocus();
            },
            child: Icon(
              Icons.close,
              size: 18,
              color: AppColors.black1.withOpacity(0.45),
            ),
          ),
          const SizedBox(width: 5),
          ReText(
            '#${tag.name}',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.black1,
          ),
        ],
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
    ValueChanged<String>? onChanged,
  }) {
    final isFocused = focusNode.hasFocus;

    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(100),
        border: isFocused ? Border.all(color: AppColors.primary, width: 1.4) : null,
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
              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              inputFormatters: const [
                PersianDigitsInputFormatter(),
              ],
              onChanged: onChanged,
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
                              color: isSelected ? AppColors.white : AppColors.gray,
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
        border: isFocused ? Border.all(color: AppColors.primary, width: 1.4) : Border.all(color: Colors.transparent),
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
              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
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
    return _ScheduleSelectionCard(
      formattedDateLabel: _scheduleDateLabel,
      isWeeklyRepeat: _isWeeklyRepeat,
      onSelectDateMode: _selectDateModeTimed,
      onSelectWeeklyRepeat: _selectWeeklyRepeatTimed,
      selectedWeekDays: _selectedWeekDays,
      onToggleWeekDay: _toggleWeekDay,
      timedTask: true,
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

  final Set<String> _selectedWeekDays = {};

  late Jalali _selectedDate;
  late Jalali _visibleCalendarMonth;
  late TimeOfDay _selectedTime;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagController;
  late FocusNode _titleFocusNode;
  late FocusNode _descriptionFocusNode;
  late FocusNode _tagFocusNode;

  List<ParentTagModel> availableTags = GlobalData.instance.parentTags;


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

    _tagSuggestionRepository = TagSuggestionRepository(
      context.read<GraphQLRepository>(),
    );

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
    _tagSuggestionDebounce?.cancel();
    _tagSuggestionRequestId++;

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

  final List<ParentTagModel> _selectedTags = [];

  late final TagSuggestionRepository _tagSuggestionRepository;
  Timer? _tagSuggestionDebounce;
  int _tagSuggestionRequestId = 0;
  List<ParentTagModel> _specificSuggestedTags = <ParentTagModel>[];

  List<ParentTagModel> get _availableTags {
    if (_specificSuggestedTags.isNotEmpty) {
      return _specificSuggestedTags;
    }

    return GlobalData.instance.parentTags;
  }

  void _onTitleChanged(String value) {
    setState(() {
      _tagSuggestionDebounce?.cancel();

      final title = value.trim();

      if (title.isEmpty) {
        _tagSuggestionRequestId++;

        if (mounted) {
          _specificSuggestedTags = <ParentTagModel>[];
          availableTags = GlobalData.instance.parentTags;
        }

        return;
      }

      // Clear the previous title's suggestions immediately.
      // Until the new API result arrives, global public tags are used as backup.
      if (mounted) {
        _specificSuggestedTags = <ParentTagModel>[];
        availableTags = GlobalData.instance.parentTags;
      }

      // Avoid sending one request for every keystroke.
      _tagSuggestionDebounce = Timer(
        const Duration(milliseconds: 450),
            () => _loadSpecificSuggestedTags(title),
      );
    });
  }

  Future<void> _loadSpecificSuggestedTags(String title) async {
    final requestId = ++_tagSuggestionRequestId;

    try {
      final names = await _tagSuggestionRepository.suggestTags(title);

      // Ignore an old response if the user has already typed a newer title.
      if (!mounted || requestId != _tagSuggestionRequestId) return;

      final uniqueNames = <String>[];
      final seen = <String>{};

      for (final name in names) {
        final normalized = name.trim();

        if (normalized.isEmpty) continue;

        final key = normalized.toLowerCase();

        if (seen.add(key)) {
          uniqueNames.add(normalized);
        }
      }

      _specificSuggestedTags = [
        for (var index = 0; index < uniqueNames.length; index++)
          ParentTagModel(
            id: 'suggested_${index}_${uniqueNames[index]}',
            name: uniqueNames[index],
            kind: 'SUGGESTED',
            moderationStatus: 'APPROVED',
          ),
      ];
      availableTags = _specificSuggestedTags;
    } catch (error) {
      if (!mounted || requestId != _tagSuggestionRequestId) return;

      debugPrint('SUGGEST TAGS ERROR: $error');

      // Empty means "use the global public tags as fallback".
      _specificSuggestedTags = <ParentTagModel>[];
      availableTags = GlobalData.instance.parentTags;
    }
  }

  List<String> get _selectedTagNames {
    return _tagController.text.trim().split(RegExp(r'\s+')).where((value) => value.isNotEmpty).toList();
  }

  bool _isTagAlreadySelected(ParentTagModel tag) {
    final selected = _tagController.text.trim().split(RegExp(r'\s+')).where((value) => value.isNotEmpty);

    return selected.any(
      (value) => value.toLowerCase() == tag.name.trim().toLowerCase(),
    );
  }

  void _selectTag(ParentTagModel tag) {
    if (_isTagAlreadySelected(tag)) return;

    final currentText = _tagController.text.trim();

    // Maximum 2 tags.
    final currentParts = currentText.split(RegExp(r'\s+')).where((value) => value.isNotEmpty).toList();

    if (currentParts.length >= 2) return;

    final newText = currentText.isEmpty ? tag.name.trim() : '$currentText ${tag.name.trim()}';

    _tagController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );

    setState(() {});

    // Keep keyboard open so the user can select the second tag.
    _tagFocusNode.requestFocus();
  }

  void _handleFieldFocusChange() {
    if (!mounted) return;
    setState(() {});
  }

  int get _descriptionCount => _descriptionController.text.length;

  int get _tagsCount => _selectedTags.length;

  bool get _isFormValid => _titleController.text.trim().isNotEmpty;

  String get _scheduleDateLabel {
    final today = Jalali.now();
    final isToday = _selectedDate.year == today.year && _selectedDate.month == today.month && _selectedDate.day == today.day;
    final prefix = isToday ? 'امروز، ' : '';
    return '$prefix${_selectedDate.day} ${_persianMonths[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  void _selectDateModeDirectly() {
    setState(() {
      _isWeeklyRepeat = false;
      _visibleCalendarMonth = Jalali(_selectedDate.year, _selectedDate.month, 1);
    });
    _openCalendarModal();
  }

  void _selectWeeklyRepeatDirectly() {
    setState(() {
      _isWeeklyRepeat = true;
      // _isReminderEnabled = true;
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

    if (_isWeeklyRepeat && _selectedWeekDays.isEmpty) {
      showReToast(context, 'حداقل یک روز تکرار را انتخاب کنید', ReToastType.warning);
      return;
    }

    final description = _descriptionController.text.trim();
    final tags = _tagController.text.trim();
    final time = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    setState(() {
      _isSubmitting = true;
    });

    try {
      final taskDate = _toDateTime(_selectedDate, time: _selectedTime);
      final tagNames = _selectedTags.map((tag) => tag.name).toList();
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
            final weekdays = _isWeeklyRepeat ? _recurrenceWeekdays(_selectedWeekDays) : <String>[];
            if (weekdays.isNotEmpty) {
              request.vars.input.recurrence.weekdays.replace(weekdays);
            } else {
              request.vars.input.date.value = taskDate.toUtc().toIso8601String();
            }

            final goalId = _emptyToNull(widget.goalId ?? '');
            if (goalId != null) {
              request.vars.input.goalID = goalId;
            }

            if (_isReminderEnabled) {
              request.vars.input.reminderTime.value = taskDate.toUtc().toIso8601String();
            }
          },
        ),
      );

      if (!mounted) return;

      if (response.hasErrors || response.data?.createTask == null) {
        debugPrint(response.graphqlErrors.toString());
        debugPrint(response.linkException.toString());
        showReToast(
          context,
          graphQLResponseErrorMessage(response),
          ReToastType.failed,
        );
        return;
      }

      final task = response.data!.createTask;
      if (_isReminderEnabled) {
        unawaited(_scheduleReminder(task.id, task.title, taskDate, isWeekly: _isWeeklyRepeat, weekdays: _selectedWeekDays, time: _selectedTime));
      }
      Navigator.of(context).pop(
        <String, dynamic>{
          'id': task.id,
          'title': task.title,
          'subtitle': task.shortDescription?.trim().isNotEmpty == true ? task.shortDescription!.trim() : (tags.isNotEmpty ? tags : 'توضیحی ثبت نشده'),
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
                      onChanged: _onTitleChanged,
                    ),
                    SizedBox(height: sectionSpacing),
                    _buildField(
                      hintText: 'توضیح کوتاه',
                      controller: _descriptionController,
                      focusNode: _descriptionFocusNode,
                      maxLength: 50,
                      leadingText: '${_descriptionCount > 50 ? 50 : _descriptionCount}/50',
                    ),
                    SizedBox(height: sectionSpacing),
                    _buildTagSuggestionField(),
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
    );
  }

  Widget _buildTagSuggestionField() {
    final isFocused = _tagFocusNode.hasFocus;

    return RawAutocomplete<ParentTagModel>(
      key: ValueKey(
        _specificSuggestedTags
            .map((e) => '${e.id}_${e.name}')
            .join('|'),
      ),

      optionsBuilder: (TextEditingValue textEditingValue) {
        final tags = availableTags;

        debugPrint(
          'AVAILABLE TAGS: ${tags.map((e) => e.name).toList()}',
        );

        return tags.where((tag) {
          final query = textEditingValue.text.trim().toLowerCase();

          if (query.isEmpty) {
            return true;
          }

          return tag.name.toLowerCase().contains(query);
        });
      },
      displayStringForOption: (ParentTagModel tag) => tag.name,
      onSelected: (ParentTagModel tag) {
        if (_selectedTags.length >= 2) return;

        setState(() {
          _selectedTags.add(tag);
        });

        // The controller is ONLY the search/query text.
        _tagController.clear();

        // Let the user immediately type the second tag.
        _tagFocusNode.requestFocus();
      },
      fieldViewBuilder: (
          BuildContext context,
          TextEditingController controller,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted,
          ) {
        return Container(
          constraints: const BoxConstraints(
            minHeight: 55,
          ),
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
            ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          child: Row(
            children: [
              // Counter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ReText(
                  '${_selectedTags.length}/2',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black1.withOpacity(0.35),
                ),
              ),

              const SizedBox(width: 4),

              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    // Search / typing field
                    if (_selectedTags.length < 2)
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 70,
                        ),
                        child: IntrinsicWidth(
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            cursorColor: AppColors.primary,
                            onChanged: (_) {
                              setState(() {});
                            },
                            style: TextStyle(
                              fontFamily: AppFonts.iranSansVar,
                              color: AppColors.black1,
                              fontSize: 15,
                              fontVariations: AppFonts.fontVariations(
                                FontWeight.w600,
                              ),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'افزودن تگ',
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintStyle: TextStyle(
                                fontFamily: AppFonts.iranSansVar,
                                color: AppColors.black1.withOpacity(0.45),
                                fontSize: 13,
                                fontVariations: AppFonts.fontVariations(
                                  FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Selected tag pills
                    ..._selectedTags.map(
                          (tag) => _buildSelectedTagChip(tag),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      optionsViewBuilder: (
          BuildContext context,
          AutocompleteOnSelected<ParentTagModel> onSelected,
          Iterable<ParentTagModel> options,
          ) {
        final items = options.toList();

        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.topRight,
          child: Material(
            color: AppColors.white,
            elevation: 8,
            shadowColor: AppColors.black1.withOpacity(0.10),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: MediaQuery.of(context).size.width - 36,
              constraints: const BoxConstraints(
                maxHeight: 230,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.gray2,
                ),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) {
                  return Divider(
                    height: 1,
                    color: AppColors.gray2,
                  );
                },
                itemBuilder: (context, index) {
                  final tag = items[index];

                  return InkWell(
                    onTap: () => onSelected(tag),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ReText(
                            tag.name,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black1,
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedTagChip(ParentTagModel tag) {
    return Container(
      height: 38,
      padding: const EdgeInsets.only(
        left: 8,
        right: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.gray2,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedTags.removeWhere(
                  (selected) => selected.id == tag.id,
                );
              });

              _tagFocusNode.requestFocus();
            },
            child: Icon(
              Icons.close,
              size: 18,
              color: AppColors.black1.withOpacity(0.45),
            ),
          ),
          const SizedBox(width: 5),
          ReText(
            '#${tag.name}',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.black1,
          ),
        ],
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
    ValueChanged<String>? onChanged,
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
              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              inputFormatters: const [
                PersianDigitsInputFormatter(),
              ],
              onChanged: onChanged,
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
      onSelectDateMode: _selectDateModeDirectly,
      onSelectWeeklyRepeat: _selectWeeklyRepeatDirectly,
      selectedWeekDays: _selectedWeekDays,
      onToggleWeekDay: _toggleWeekDay,
      timedTask: false,
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
            color: _isReminderEnabled ? AppColors.primary.withOpacity(0.25) : AppColors.gray2,
            borderRadius: BorderRadius.circular(100),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: _isReminderEnabled ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isReminderEnabled ? AppColors.primary : AppColors.dark4Color,
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
    required this.onSelectDateMode,
    required this.onSelectWeeklyRepeat,
    required this.selectedWeekDays,
    required this.onToggleWeekDay,
    required this.timedTask,
  });

  final String formattedDateLabel;
  final bool isWeeklyRepeat;
  final VoidCallback onSelectDateMode;
  final VoidCallback onSelectWeeklyRepeat;
  final Set<String> selectedWeekDays;
  final ValueChanged<String> onToggleWeekDay;
  final bool timedTask;

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
                    color: isDateModeSelected ? AppColors.black1 : AppColors.dark7Color,
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
                      color: isWeeklyRepeat ? AppColors.black1 : AppColors.dark7Color,
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
              bottom: widget.timedTask ?  50 : 100,
              child: SafeArea(
                child: Material(
                  color: Colors.transparent,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width,maxHeight: 300),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    final labels = _weekDayOptions.where((day) => widget.selectedDays.contains(day.code)).map((day) => day.label);
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
          border: Border.all(color: _isOpen ? AppColors.primary : AppColors.gray2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(
              _isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
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
        mainAxisExtent: 35
      ),
      itemBuilder: (context, index) {
        final entry = items[index];
        final isChecked = entry.key == 'ALL' ? _isAllSelected : selectedDays.contains(entry.key);

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
                color: isChecked ? AppColors.black1 : AppColors.black1.withOpacity(0.55),
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
        color: isChecked ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
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
            color: value ? AppColors.primary.withOpacity(0.25) : AppColors.gray2,
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
  State<_ThreeColumnJalaliDatePickerSheet> createState() => _ThreeColumnJalaliDatePickerSheetState();
}

class _ThreeColumnJalaliDatePickerSheetState extends State<_ThreeColumnJalaliDatePickerSheet> {
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

  Jalali get _selectedDate => Jalali(_selectedYear, _selectedMonth, _selectedDay);

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
                            decoration: BoxDecoration(color: AppColors.black1, borderRadius: BorderRadius.circular(100)),
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
