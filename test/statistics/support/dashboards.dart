import 'package:ferry/ferry.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/features/statistics/statistics_repository.dart';
import 'package:simo_learn/graphql/queries/__generated__/statistics_dashboard.data.gql.dart';

typedef DayBucket = GStatisticsDashboardData_statisticsDashboard_dailyBuckets;
typedef SubjectBucket
    = GStatisticsDashboardData_statisticsDashboard_subjectBuckets;

/// A bucket for [day], with its start written the way the server writes it:
/// Tehran midnight with its offset.
DayBucket dayBucket(
  Jalali day, {
  int studySeconds = 0,
  int completedTasks = 0,
  int totalQuestions = 0,
  int correctAnswers = 0,
  double? rating,
}) {
  final g = day.toGregorian();
  String two(int value) => value.toString().padLeft(2, '0');
  return DayBucket((b) => b
    ..start.value = '${g.year}-${two(g.month)}-${two(g.day)}T00:00:00+03:30'
    ..studySeconds = studySeconds
    ..completedTasks = completedTasks
    ..totalQuestions = totalQuestions
    ..correctAnswers = correctAnswers
    ..incorrectAnswers = totalQuestions - correctAnswers
    ..averagePerformanceRating = rating);
}

SubjectBucket subjectBucket(
  String name, {
  int studySeconds = 0,
  int totalQuestions = 0,
  int correctAnswers = 0,
  double? rating,
  bool miscellaneous = false,
}) =>
    SubjectBucket((b) => b
      ..tagName = name
      ..isMiscellaneous = miscellaneous
      ..studySeconds = studySeconds
      ..completedTasks = 0
      ..totalQuestions = totalQuestions
      ..correctAnswers = correctAnswers
      ..incorrectAnswers = totalQuestions - correctAnswers
      ..averagePerformanceRating = rating);

StatisticsDashboard dashboard({
  int studySeconds = 0,
  int previousStudySeconds = 0,
  double adherence = 0,
  double? adherenceChange,
  int totalQuestions = 0,
  int correctAnswers = 0,
  int previousTotalQuestions = 0,
  int previousCorrectAnswers = 0,
  double? questionsChange,
  int plannedSeconds = 0,
  int finishedSeconds = 0,
  int progressedSeconds = 0,
  List<DayBucket> days = const [],
  List<SubjectBucket> subjects = const [],
}) =>
    StatisticsDashboard((b) => b
      ..comparison.current.studySeconds = studySeconds
      ..comparison.current.adherencePercentage = adherence
      ..comparison.current.totalQuestions = totalQuestions
      ..comparison.current.correctAnswers = correctAnswers
      ..comparison.current.tasksWithTests = 0
      ..comparison.current.planVsCompleted.plannedSeconds = plannedSeconds
      ..comparison.current.planVsCompleted.completedOnlySeconds =
          finishedSeconds
      ..comparison.current.planVsCompleted.completedAndStudiedSeconds =
          progressedSeconds
      ..comparison.current.planVsCompleted.completedOnlyPercentage = 0
      ..comparison.current.planVsCompleted.completedAndStudiedPercentage = 0
      ..comparison.previous.studySeconds = previousStudySeconds
      ..comparison.previous.adherencePercentage = 0
      ..comparison.previous.totalQuestions = previousTotalQuestions
      ..comparison.previous.correctAnswers = previousCorrectAnswers
      ..comparison.previous.tasksWithTests = 0
      ..comparison.adherenceChangePercentage = adherenceChange
      ..comparison.totalQuestionsChangePercentage = questionsChange
      ..dailyBuckets.addAll(days)
      ..subjectBuckets.addAll(subjects));

/// Answers each fetch with [respond], and remembers what was asked.
class FakeStatisticsRepository implements StatisticsRepository {
  FakeStatisticsRepository(this.respond);

  Future<StatisticsDashboard> Function(DateTime start, DateTime end) respond;

  final requests = <(DateTime, DateTime)>[];

  @override
  Future<StatisticsDashboard> fetchDashboard({
    required DateTime start,
    required DateTime end,
    required DateTime previousStart,
    required DateTime previousEnd,
    FetchPolicy fetchPolicy = FetchPolicy.NetworkOnly,
  }) {
    requests.add((start, end));
    return respond(start, end);
  }
}
