import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/features/statistics/cubit/statistics_state.dart';
import 'package:simo_learn/features/statistics/statistics_repository.dart';

/// The summary numbers of one range, with their change from the range
/// before. A change is null when there is nothing to compare with.
class StatisticsOverview {
  const StatisticsOverview({
    required this.studySeconds,
    required this.previousStudySeconds,
    required this.plannedSeconds,
    required this.finishedSeconds,
    required this.progressedSeconds,
    required this.adherence,
    required this.adherenceChange,
    required this.completedTasks,
    required this.activeDays,
    required this.elapsedDays,
    required this.totalQuestions,
    required this.questionsChange,
    required this.correctAnswers,
    required this.previousTotalQuestions,
    required this.previousCorrectAnswers,
  });

  factory StatisticsOverview.of(StatisticsDashboard dashboard) {
    final comparison = dashboard.comparison;
    final current = comparison.current;
    final previous = comparison.previous;
    final plan = current.planVsCompleted;
    final days = dashboard.dailyBuckets;
    return StatisticsOverview(
      studySeconds: current.studySeconds,
      previousStudySeconds: previous.studySeconds,
      plannedSeconds: plan.plannedSeconds,
      finishedSeconds: plan.completedOnlySeconds,
      progressedSeconds: plan.completedAndStudiedSeconds,
      adherence: current.adherencePercentage,
      adherenceChange: comparison.adherenceChangePercentage,
      completedTasks: days.fold(0, (sum, day) => sum + day.completedTasks),
      activeDays: days.where((day) => day.studySeconds > 0).length,
      elapsedDays: days.length,
      totalQuestions: current.totalQuestions,
      questionsChange: comparison.totalQuestionsChangePercentage,
      correctAnswers: current.correctAnswers,
      previousTotalQuestions: previous.totalQuestions,
      previousCorrectAnswers: previous.correctAnswers,
    );
  }

  final int studySeconds;
  final int previousStudySeconds;

  /// Time planned for timed tasks, the part of it in finished tasks, and
  /// that plus the timer time of unfinished ones (so never less).
  final int plannedSeconds;
  final int finishedSeconds;
  final int progressedSeconds;

  /// Share of planned tasks that were finished, in percent.
  final double adherence;
  final double? adherenceChange;

  final int completedTasks;
  final int activeDays;
  final int elapsedDays;

  final int totalQuestions;
  final double? questionsChange;
  final int correctAnswers;
  final int previousTotalQuestions;
  final int previousCorrectAnswers;

  /// Study time gained (or lost, below zero) on the range before; null when
  /// the range before had none to compare with.
  int? get studyDifference => previousStudySeconds == 0 && studySeconds == 0
      ? null
      : studySeconds - previousStudySeconds;

  double? get accuracy =>
      totalQuestions == 0 ? null : correctAnswers * 100 / totalQuestions;

  double? get previousAccuracy => previousTotalQuestions == 0
      ? null
      : previousCorrectAnswers * 100 / previousTotalQuestions;

  /// Change in accuracy, in percentage points.
  double? get accuracyChange {
    final now = accuracy;
    final before = previousAccuracy;
    if (now == null || before == null) return null;
    return now - before;
  }

  /// Planned time worked on so far, in percent.
  double get progress =>
      plannedSeconds == 0 ? 0 : progressedSeconds * 100 / plannedSeconds;

  /// Nothing at all happened: no study, tests, plan or finished tasks.
  bool get isEmpty =>
      studySeconds == 0 &&
      totalQuestions == 0 &&
      plannedSeconds == 0 &&
      completedTasks == 0 &&
      adherence == 0;
}

/// One bar on the day charts: a day, or a week of a long range.
class StatisticsDay {
  const StatisticsDay({
    required this.first,
    required this.last,
    this.studySeconds = 0,
    this.completedTasks = 0,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.rating,
    this.isFuture = false,
    this.isToday = false,
    this.isFocused = false,
  });

  final Jalali first;
  final Jalali last;
  final int studySeconds;
  final int completedTasks;
  final int totalQuestions;
  final int correctAnswers;

  /// Average self-rating, when there was any.
  final double? rating;

  /// Not reached yet.
  final bool isFuture;

  /// Contains today.
  final bool isToday;

  /// The day the user picked, when a single day is shown within its week.
  final bool isFocused;

  int get wrongAnswers => totalQuestions - correctAnswers;

  bool get isGroup => first.julianDayNumber != last.julianDayNumber;

  bool get hasActivity =>
      studySeconds > 0 || totalQuestions > 0 || rating != null;

  /// Every day of [range], filled from [dashboard] (which only has the days
  /// up to today), as weeks when the range is longer than a month.
  static List<StatisticsDay> listFor(
    StatisticsRange range,
    StatisticsDashboard dashboard, {
    Jalali? focus,
    Jalali? today,
  }) {
    final now = today ?? jalaliToday();
    final byDay = {
      for (final bucket in dashboard.dailyBuckets)
        dayOf(bucket.start.value).julianDayNumber: bucket,
    };
    final days = [
      for (final day in range.days)
        () {
          final bucket = byDay[day.julianDayNumber];
          return StatisticsDay(
            first: day,
            last: day,
            studySeconds: bucket?.studySeconds ?? 0,
            completedTasks: bucket?.completedTasks ?? 0,
            totalQuestions: bucket?.totalQuestions ?? 0,
            correctAnswers: bucket?.correctAnswers ?? 0,
            rating: bucket?.averagePerformanceRating,
            isFuture: day.julianDayNumber > now.julianDayNumber,
            isToday: day.julianDayNumber == now.julianDayNumber,
            isFocused: focus != null &&
                day.julianDayNumber == focus.julianDayNumber,
          );
        }(),
    ];
    if (days.length <= 31) return days;
    return [
      for (var i = 0; i < days.length; i += 7)
        _group(days.sublist(i, i + 7 > days.length ? days.length : i + 7)),
    ];
  }

  static StatisticsDay _group(List<StatisticsDay> days) {
    final rated = [
      for (final day in days)
        if (day.rating != null) day.rating!,
    ];
    return StatisticsDay(
      first: days.first.first,
      last: days.last.last,
      studySeconds: days.fold(0, (sum, day) => sum + day.studySeconds),
      completedTasks: days.fold(0, (sum, day) => sum + day.completedTasks),
      totalQuestions: days.fold(0, (sum, day) => sum + day.totalQuestions),
      correctAnswers: days.fold(0, (sum, day) => sum + day.correctAnswers),
      rating: rated.isEmpty
          ? null
          : rated.reduce((a, b) => a + b) / rated.length,
      isFuture: days.every((day) => day.isFuture),
      isToday: days.any((day) => day.isToday),
      isFocused: days.any((day) => day.isFocused),
    );
  }

  /// The calendar day a bucket starts on, as the server wrote it. The time's
  /// own offset is ignored on purpose: parsing it would move midnight in
  /// Tehran to the evening before in UTC, and so onto the wrong day.
  static Jalali dayOf(String time) {
    final parts = time.substring(0, 10).split('-').map(int.parse).toList();
    return Jalali.fromDateTime(DateTime(parts[0], parts[1], parts[2]));
  }
}

/// One subject (tag) in the range.
class SubjectStatistics {
  const SubjectStatistics({
    required this.name,
    required this.isMiscellaneous,
    required this.studySeconds,
    required this.totalQuestions,
    required this.correctAnswers,
    this.rating,
  });

  final String name;
  final bool isMiscellaneous;
  final int studySeconds;
  final int totalQuestions;
  final int correctAnswers;
  final double? rating;

  double? get accuracy =>
      totalQuestions == 0 ? null : correctAnswers * 100 / totalQuestions;

  /// The subjects with any activity, most studied first, "other" last.
  static List<SubjectStatistics> listOf(StatisticsDashboard dashboard) {
    final subjects = [
      for (final bucket in dashboard.tagBuckets)
        if (bucket.studySeconds > 0 ||
            bucket.totalQuestions > 0 ||
            bucket.averagePerformanceRating != null)
          SubjectStatistics(
            name: bucket.tagName,
            isMiscellaneous: bucket.isMiscellaneous,
            studySeconds: bucket.studySeconds,
            totalQuestions: bucket.totalQuestions,
            correctAnswers: bucket.correctAnswers,
            rating: bucket.averagePerformanceRating,
          ),
    ];
    subjects.sort((a, b) {
      if (a.isMiscellaneous != b.isMiscellaneous) {
        return a.isMiscellaneous ? 1 : -1;
      }
      return b.studySeconds.compareTo(a.studySeconds);
    });
    return subjects;
  }

  /// One plain sentence about the subjects worth acting on, or null.
  /// Only subjects with enough questions to mean something are judged.
  static String? insight(List<SubjectStatistics> subjects) {
    final tested = [
      for (final subject in subjects)
        if (subject.totalQuestions >= 10 && !subject.isMiscellaneous) subject,
    ];
    if (tested.isEmpty) return null;
    tested.sort((a, b) => a.accuracy!.compareTo(b.accuracy!));
    final weakest = tested.first;
    final best = tested.last;
    final mostStudied = subjects.firstWhere(
      (subject) => !subject.isMiscellaneous,
      orElse: () => subjects.first,
    );
    if (tested.length >= 2 &&
        weakest.name == mostStudied.name &&
        weakest.accuracy! < best.accuracy!) {
      return 'بیشترین وقتت را روی ${weakest.name} گذاشتی ولی دقت تستش از بقیه کمتر است.';
    }
    if (weakest.accuracy! < 60) {
      return 'دقت تست‌های ${weakest.name} ${weakest.accuracy!.round()}٪ است؛ '
          'مرور بیشتری لازم دارد.';
    }
    if (tested.length >= 2) {
      return 'بهترین دقتت در ${best.name} بوده: ${best.accuracy!.round()}٪.';
    }
    return null;
  }
}
