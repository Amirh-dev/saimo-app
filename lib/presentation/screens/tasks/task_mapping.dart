import 'dart:math' as math;

import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/utils/helpers.dart';

/// Converts tasks from the API into the maps the tasks screens, the details
/// sheet and the add/edit screens share, so the daily and weekly views always
/// agree on what a task looks like.

const List<String> kPersianMonths = [
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

/// Task fields every tasks query selects, so any of them can be mapped with
/// [plannedTaskFromApi].
const String kTaskFields = r'''
    id
    title
    shortDescription
    note
    type
    date
    durationM
    hasReminder
    reminderTime
    recurringDays
    recurrenceID
    elapsedSeconds
    timerStartedAt
    status
    goal { id title }
    tags { id name moderationStatus parent { id name } }
    completionReport { performanceRating tookTest totalQuestions correctAnswers note }
''';

bool isSameJalaliDay(Jalali a, Jalali b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

Jalali? jalaliFromIso(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  return Jalali.fromDateTime(parsed.toLocal());
}

String timeFromIso(String value) {
  final parsed = DateTime.tryParse(value)?.toLocal();
  if (parsed == null) return '';
  final formatted =
      '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
  return convertToPersianNumbers(formatted);
}

/// RFC 3339 with the device's UTC offset, so the server resolves the same
/// calendar day the user sees.
String rfc3339Local(DateTime value) {
  final local = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  final offset = local.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final offsetMinutes = offset.inMinutes.abs();
  return '${local.year.toString().padLeft(4, '0')}-${two(local.month)}-${two(local.day)}'
      'T${two(local.hour)}:${two(local.minute)}:${two(local.second)}'
      '$sign${two(offsetMinutes ~/ 60)}:${two(offsetMinutes % 60)}';
}

/// "mm:ss" in Persian digits; negative values show as zero.
String formatTaskSeconds(int seconds) {
  final safeSeconds = math.max(0, seconds);
  final minutes = safeSeconds ~/ 60;
  final remainingSeconds = safeSeconds % 60;
  final formatted =
      '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  return convertToPersianNumbers(formatted);
}

String taskStatusFromApi(String? status) {
  return switch (status) {
    'COMPLETED' => 'done',
    'IN_PROGRESS' => 'running',
    'PAUSED' => 'paused',
    _ => 'pending',
  };
}

bool isTimedTask(Map<String, dynamic> task) => task['type'] == 'TIMED';

List<String> _tagNames(Map<String, dynamic> task, {String? status}) {
  final tags = task['tags'];
  if (tags is! List) return <String>[];
  return [
    for (final tag in tags.whereType<Map>())
      if (tag['name'] is String &&
          (status == null || tag['moderationStatus'] == status))
        tag['name'] as String,
  ];
}

/// The subject a task counts under, as the server's tag statistics group it:
/// its first approved tag's parent, or that tag itself when it has none.
/// Tags still pending review are the user's own and count as "other" (null).
String? _subjectOf(Map<String, dynamic> task) {
  final tags = task['tags'];
  if (tags is! List) return null;
  for (final tag in tags.whereType<Map>()) {
    if (tag['moderationStatus'] != 'APPROVED') continue;
    final parent = tag['parent'];
    final name = parent is Map ? parent['name'] : tag['name'];
    if (name is String && name.trim().isNotEmpty) return name;
  }
  return null;
}

String _taskSubtitle(Map<String, dynamic> task) {
  final description = (task['shortDescription'] as String?)?.trim();
  if (description != null && description.isNotEmpty) return description;

  final note = (task['note'] as String?)?.trim();
  if (note != null && note.isNotEmpty) return note;

  final tags = _tagNames(task).join('، ').trim();
  if (tags.isNotEmpty) return tags;

  return 'توضیحی ثبت نشده';
}

Map<String, dynamic> taskFromApi(Map<String, dynamic> task) {
  final date = task['date'] as String? ?? '';
  final reminderTime = task['reminderTime'] as String? ?? '';
  final goal = task['goal'] as Map<String, dynamic>?;

  return {
    'id': task['id'] as String?,
    'title': task['title'] as String?,
    'type': task['type'] as String?,
    'subtitle': _taskSubtitle(task),
    'time': timeFromIso(date),
    'status': taskStatusFromApi(task['status'] as String?),
    'date': jalaliFromIso(date),
    'goalId': goal?['id'] as String?,
    'goalTitle': goal?['title'] as String?,
    'subject': _subjectOf(task),
    'reminder': task['hasReminder'] as bool? ?? false,
    'note': task['note'] as String?,
    'shortDescription': task['shortDescription'] as String?,
    'tags': _tagNames(task),
    // Blocked since they were added: saving the task with them would fail.
    'blockedTags': _tagNames(task, status: 'BLOCKED'),
    'recurringDays': task['recurringDays'] as String?,
    'recurrenceId': task['recurrenceID'] as String?,
    'dateTime': DateTime.tryParse(date)?.toLocal(),
    'reminderTime': DateTime.tryParse(reminderTime)?.toLocal(),
    'report': TaskReport.fromApi(task['completionReport']),
  };
}

/// What the user said about a finished task: a 1–5 self-rating and, when
/// they took a test, its question counts.
class TaskReport {
  const TaskReport({
    required this.rating,
    this.totalQuestions,
    this.correctAnswers,
    this.note,
  });

  final int rating;
  final int? totalQuestions;
  final int? correctAnswers;

  /// The user's own words on how it went; null when they wrote none.
  final String? note;

  bool get tookTest => totalQuestions != null && correctAnswers != null;

  static TaskReport? fromApi(Object? report) {
    if (report is! Map) return null;
    final rating = report['performanceRating'];
    if (rating is! int) return null;
    final tookTest = report['tookTest'] == true;
    return TaskReport(
      rating: rating,
      totalQuestions: tookTest ? report['totalQuestions'] as int? : null,
      correctAnswers: tookTest ? report['correctAnswers'] as int? : null,
      note: _nonBlank(report['note']),
    );
  }

  /// The `SaveTaskCompletionReportInput` for this report.
  Map<String, dynamic> toInput() => {
        'performanceRating': rating,
        'tookTest': tookTest,
        if (tookTest) 'totalQuestions': totalQuestions,
        if (tookTest) 'correctAnswers': correctAnswers,
        if (note != null) 'note': note,
      };

  static String? _nonBlank(Object? text) {
    if (text is! String) return null;
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

Map<String, dynamic> timedTaskFromApi(Map<String, dynamic> task) {
  final minutes = task['durationM'] as int? ?? 45;
  final durationSeconds = minutes * 60;
  final elapsedSeconds = task['elapsedSeconds'] as int? ?? 0;

  return {
    ...taskFromApi(task),
    'duration': formatTaskSeconds(durationSeconds),
    'durationSeconds': durationSeconds,
    'remainingSeconds': durationSeconds - elapsedSeconds,
    'label': '${convertToPersianNumbers(minutes.toString())} دقیقه',
    'elapsedSeconds': elapsedSeconds,
    'timerStartedAt':
        DateTime.tryParse(task['timerStartedAt'] as String? ?? '')?.toLocal(),
  };
}

Map<String, dynamic> plannedTaskFromApi(Map<String, dynamic> task) {
  return task['type'] == 'TIMED' ? timedTaskFromApi(task) : taskFromApi(task);
}

/// Durations, in minutes, offered for timed tasks wherever they are created,
/// and the one picked by default.
const List<int> kTaskDurations = [25, 45, 60, 90, 120];
const int kDefaultTaskMinutes = 45;
