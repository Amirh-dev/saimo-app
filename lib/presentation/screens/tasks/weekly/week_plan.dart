import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';
import 'package:simo_learn/utils/helpers.dart';

/// How far ahead the server builds recurring tasks; it rejects schedule
/// requests that end later than this many days from today.
const int kPlanHorizonDays = 84;

/// Load a checklist task adds to its day. They have no duration of their own,
/// but a day of ten to-dos is still busier than an empty one.
const int kChecklistLoadMinutes = 20;

/// A day is heavy when it carries this much more than the other planned days
/// on average, and at least [_heavyDayMinLoad] minutes in total.
const double _heavyDayRatio = 1.6;
const int _heavyDayMinLoad = 120;

/// Named subjects the subject balance shows before grouping the rest.
const int _maxNamedSubjects = 4;

const List<String> kPersianWeekdays = [
  'شنبه',
  'یکشنبه',
  'دوشنبه',
  'سه‌شنبه',
  'چهارشنبه',
  'پنجشنبه',
  'جمعه',
];

const List<String> kPersianWeekdayInitials = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

/// The Saturday that opens [date]'s week, at the start of the day.
Jalali weekStartOf(Jalali date) {
  final start = date.addDays(1 - date.weekDay);
  return Jalali(start.year, start.month, start.day);
}

/// Calendar days from [from] to [to]; negative when [to] is earlier.
int daysBetween(Jalali from, Jalali to) =>
    to.julianDayNumber - from.julianDayNumber;

/// Whether the server can return the whole week starting at [weekStart].
bool isWeekWithinHorizon(Jalali weekStart, Jalali today) =>
    daysBetween(today, weekStart.addDays(7)) <= kPlanHorizonDays;

/// The Friday of the last week the server can return.
Jalali lastPlannableDay(Jalali today) {
  var weekStart = weekStartOf(today);
  while (isWeekWithinHorizon(weekStart.addDays(7), today)) {
    weekStart = weekStart.addDays(7);
  }
  return weekStart.addDays(6);
}

bool isTaskDone(Map<String, dynamic> task) => task['status'] == 'done';

/// Minutes the user planned for a timed task; checklist tasks plan none.
int taskPlannedMinutes(Map<String, dynamic> task) {
  if (!isTimedTask(task)) return 0;
  return (task['durationSeconds'] as int? ?? 0) ~/ 60;
}

int taskLoadMinutes(Map<String, dynamic> task) =>
    isTimedTask(task) ? taskPlannedMinutes(task) : kChecklistLoadMinutes;

/// Seconds worked on a timed task so far: live from the timer for the task
/// it holds, otherwise what the server last said plus the session running
/// since.
int taskWorkedSeconds(Map<String, dynamic> task) {
  final timer = TaskTimerService.instance;
  if (timer.isActive(task['id'] as String?)) return timer.elapsedSeconds;
  var elapsed = task['elapsedSeconds'] as int? ?? 0;
  final startedAt = task['timerStartedAt'];
  if (task['status'] == 'running' && startedAt is DateTime) {
    elapsed += DateTime.now().difference(startedAt).inSeconds;
  }
  return elapsed;
}

/// How much of [task]'s load is done, in seconds: all of it once finished,
/// the time already worked for a timed task under way, nothing otherwise.
int taskDoneSeconds(Map<String, dynamic> task) {
  final load = taskLoadMinutes(task) * 60;
  if (isTaskDone(task)) return load;
  if (!isTimedTask(task)) return 0;
  return taskWorkedSeconds(task).clamp(0, load);
}

int _sum(Iterable<Map<String, dynamic>> tasks, int Function(Map<String, dynamic>) value) =>
    tasks.fold(0, (total, task) => total + value(task));

class WeekDayPlan {
  WeekDayPlan({
    required this.date,
    required this.tasks,
    required this.isPast,
    required this.isToday,
    this.isHeavy = false,
  });

  final Jalali date;
  final List<Map<String, dynamic>> tasks;
  final bool isPast;
  final bool isToday;
  final bool isHeavy;

  int get taskCount => tasks.length;
  int get doneCount => tasks.where(isTaskDone).length;
  int get plannedMinutes => _sum(tasks, taskPlannedMinutes);
  int get loadMinutes => _sum(tasks, taskLoadMinutes);
  int get doneLoadMinutes => _sum(tasks.where(isTaskDone), taskLoadMinutes);

  /// Share of the day's work done, 0 to 1, weighed by time: a timed task
  /// counts its minutes (worked so far, if under way), a checklist task
  /// [kChecklistLoadMinutes] once ticked.
  double get workDoneRatio {
    final load = loadMinutes;
    if (load == 0) return 0;
    return (_sum(tasks, taskDoneSeconds) / (load * 60)).clamp(0.0, 1.0);
  }
  bool get isEmpty => tasks.isEmpty;
  bool get isAllDone => tasks.isNotEmpty && doneCount == taskCount;
}

/// Planned load of one subject; a null [name] groups everything else.
class SubjectShare {
  const SubjectShare(this.name, this.loadMinutes);

  final String? name;
  final int loadMinutes;
}

class WeekPlan {
  WeekPlan._(this.start, this.days, this.subjects);

  /// Lays [tasks] out on the week starting at [weekStart]; tasks of other
  /// weeks are left out.
  factory WeekPlan.build({
    required Jalali weekStart,
    required Iterable<Map<String, dynamic>> tasks,
    required Jalali today,
  }) {
    final byDay = List.generate(7, (_) => <Map<String, dynamic>>[]);
    for (final task in tasks) {
      final date = task['date'];
      if (date is! Jalali) continue;
      final index = daysBetween(weekStart, date);
      if (index < 0 || index > 6) continue;
      byDay[index].add(task);
    }

    final loads = [for (final dayTasks in byDay) _sum(dayTasks, taskLoadMinutes)];
    final days = <WeekDayPlan>[];
    for (var index = 0; index < 7; index++) {
      final date = weekStart.addDays(index);
      final offset = daysBetween(today, date);
      days.add(
        WeekDayPlan(
          date: date,
          tasks: byDay[index],
          isPast: offset < 0,
          isToday: offset == 0,
          isHeavy: offset >= 0 && _isHeavy(loads, index),
        ),
      );
    }

    return WeekPlan._(weekStart, days, _subjectShares(byDay.expand((day) => day)));
  }

  final Jalali start;
  final List<WeekDayPlan> days;

  /// The heaviest named subjects first, then one share for everything else.
  final List<SubjectShare> subjects;

  int get taskCount => days.fold(0, (total, day) => total + day.taskCount);
  int get doneCount => days.fold(0, (total, day) => total + day.doneCount);
  int get plannedMinutes => days.fold(0, (total, day) => total + day.plannedMinutes);
  int get loadMinutes => days.fold(0, (total, day) => total + day.loadMinutes);
  int get maxDayLoad =>
      days.fold(0, (max, day) => day.loadMinutes > max ? day.loadMinutes : max);
  bool get isEmpty => taskCount == 0;
  bool get hasSubjects => subjects.any((share) => share.name != null);
  double get doneRatio => taskCount == 0 ? 0 : doneCount / taskCount;

  WeekDayPlan? dayOf(Jalali date) {
    final index = daysBetween(start, date);
    if (index < 0 || index > 6) return null;
    return days[index];
  }

  static bool _isHeavy(List<int> loads, int index) {
    final load = loads[index];
    if (load < _heavyDayMinLoad) return false;
    final others = [
      for (var other = 0; other < loads.length; other++)
        if (other != index && loads[other] > 0) loads[other],
    ];
    if (others.isEmpty) return false;
    final average = others.reduce((a, b) => a + b) / others.length;
    return load > average * _heavyDayRatio;
  }

  static List<SubjectShare> _subjectShares(Iterable<Map<String, dynamic>> tasks) {
    final bySubject = <String?, int>{};
    for (final task in tasks) {
      final subject = task['subject'] as String?;
      bySubject[subject] = (bySubject[subject] ?? 0) + taskLoadMinutes(task);
    }

    final named = bySubject.entries.where((entry) => entry.key != null).toList()
      ..sort((a, b) {
        final byLoad = b.value.compareTo(a.value);
        return byLoad != 0 ? byLoad : a.key!.compareTo(b.key!);
      });

    final rest = named.skip(_maxNamedSubjects).fold(0, (total, e) => total + e.value) +
        (bySubject[null] ?? 0);
    return [
      for (final entry in named.take(_maxNamedSubjects))
        SubjectShare(entry.key, entry.value),
      if (rest > 0) SubjectShare(null, rest),
    ];
  }
}

String weekdayName(Jalali date) => kPersianWeekdays[date.weekDay - 1];

/// "دوشنبه ۲۰ مهر"
String dayLabel(Jalali date) => convertToPersianNumbers(
      '${weekdayName(date)} ${date.day} ${kPersianMonths[date.month - 1]}',
    );

/// "۱۸ تا ۲۴ مهر", "۲۵ مهر تا ۱ آبان"; the year is added outside [today]'s.
String weekRangeLabel(Jalali weekStart, {required Jalali today}) {
  final end = weekStart.addDays(6);
  String month(Jalali date) => kPersianMonths[date.month - 1];

  final String label;
  if (weekStart.year != end.year) {
    label = '${weekStart.day} ${month(weekStart)} ${weekStart.year} '
        'تا ${end.day} ${month(end)} ${end.year}';
  } else {
    final year = end.year == today.year ? '' : ' ${end.year}';
    label = weekStart.month == end.month
        ? '${weekStart.day} تا ${end.day} ${month(end)}$year'
        : '${weekStart.day} ${month(weekStart)} تا ${end.day} ${month(end)}$year';
  }
  return convertToPersianNumbers(label);
}

/// "این هفته", "هفته بعد", "۳ هفته قبل", ...
String relativeWeekLabel(Jalali weekStart, Jalali today) {
  final weeks = daysBetween(weekStartOf(today), weekStartOf(weekStart)) ~/ 7;
  return switch (weeks) {
    0 => 'این هفته',
    1 => 'هفته بعد',
    -1 => 'هفته قبل',
    > 1 => convertToPersianNumbers('$weeks هفته بعد'),
    _ => convertToPersianNumbers('${-weeks} هفته قبل'),
  };
}

/// "۴۵ دقیقه", "۲ ساعت", "۱ ساعت و ۴۵ دقیقه"
String formatDuration(int minutes) {
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  final String text;
  if (hours == 0) {
    text = '$rest دقیقه';
  } else if (rest == 0) {
    text = '$hours ساعت';
  } else {
    text = '$hours ساعت و $rest دقیقه';
  }
  return convertToPersianNumbers(text);
}

/// "۱:۴۵", "۵:۳۰"
String formatClock(int minutes) => convertToPersianNumbers(
      '${minutes ~/ 60}:${(minutes % 60).toString().padLeft(2, '0')}',
    );

/// Hours rounded to the nearest half: "۱۳", "۱۳٫۵".
String formatHours(int minutes) {
  final halves = (minutes / 30).round();
  final whole = halves ~/ 2;
  return convertToPersianNumbers(halves.isOdd ? '$whole٫۵' : '$whole');
}
