import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/profile/profile_repository.dart';

/// Fetches the home screen's sections, and keeps the last copy of each on
/// disk so the screen can open with it before the network answers.
class DashboardRepository {
  DashboardRepository(this._graphql)
      : _profileRepository = ProfileRepository(_graphql);

  final GraphQLRepository _graphql;
  final ProfileRepository _profileRepository;

  static const _profileKey = 'dashboard_cache.profile';
  static const _goalsKey = 'dashboard_cache.goals';
  static const _tasksKey = 'dashboard_cache.tasks';
  static const _consistencyKey = 'dashboard_cache.consistency';

  /// The day the cached tasks belong to; they are dropped on any other day.
  static const _tasksDayKey = 'dashboard_cache.tasks_day';

  /// Likewise for the multiplier, which describes one day.
  static const _consistencyDayKey = 'dashboard_cache.consistency_day';

  /// Bumped by [clearCache]; a fetch started before it does not write back.
  int _epoch = 0;

  /// Names of writes the server just accepted, from anywhere in the app.
  Stream<String> get serverChanges => _graphql.completedMutations;

  Future<ProfileUser> getProfile() async {
    final epoch = _epoch;
    final profile = await _profileRepository.getMe();
    _write(epoch, (prefs) => prefs.setString(
          _profileKey,
          jsonEncode(profile.toJson()),
        ));
    return profile;
  }

  Future<List<DashboardGoal>> getGoals() async {
    final epoch = _epoch;
    final raw = await _fetchGoals();
    _write(epoch, (prefs) => prefs.setString(_goalsKey, jsonEncode(raw)));
    return raw.map(DashboardGoal.fromJson).toList(growable: false);
  }

  Future<List<DashboardTask>> getTasks() async {
    final epoch = _epoch;
    final raw = await _fetchTasks();
    _write(epoch, (prefs) async {
      await prefs.setString(_tasksKey, jsonEncode(raw));
      await prefs.setString(_tasksDayKey, _dayKey(DateTime.now()));
    });
    return raw.map(DashboardTask.fromJson).toList(growable: false);
  }

  /// The score multiplier and today's progress toward it. Asking also lets
  /// the server apply the days that ended since the last ask.
  Future<DashboardConsistency> getConsistency() async {
    final epoch = _epoch;
    final data = await _graphql.rawRequest(query: _consistencyQuery);
    final value = data['consistencyStatus'];
    if (value is! Map<String, dynamic>) {
      throw const DashboardFailure('دریافت ضریب امتیاز ناموفق بود.');
    }
    _write(epoch, (prefs) async {
      await prefs.setString(_consistencyKey, jsonEncode(value));
      await prefs.setString(_consistencyDayKey, _dayKey(DateTime.now()));
    });
    return DashboardConsistency.fromJson(value);
  }

  /// What the last fetches left on disk; a section is null when nothing
  /// usable is there.
  Future<DashboardCache> readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _dayKey(DateTime.now());
      final profile = _decodeMap(prefs.getString(_profileKey));
      final goals = _decodeList(prefs.getString(_goalsKey));
      final tasksAreToday = prefs.getString(_tasksDayKey) == today;
      final tasks =
          tasksAreToday ? _decodeList(prefs.getString(_tasksKey)) : null;
      final consistency = prefs.getString(_consistencyDayKey) == today
          ? _decodeMap(prefs.getString(_consistencyKey))
          : null;
      return DashboardCache(
        profile: profile == null ? null : ProfileUser.fromJson(profile),
        goals: goals?.map(DashboardGoal.fromJson).toList(growable: false),
        tasks: tasks?.map(DashboardTask.fromJson).toList(growable: false),
        consistency: consistency == null
            ? null
            : DashboardConsistency.fromJson(consistency),
      );
    } catch (error) {
      debugPrint('Dashboard cache unreadable: $error');
      return const DashboardCache();
    }
  }

  /// Forgets the cached sections, as on logout, so the next account never
  /// sees them.
  Future<void> clearCache() async {
    _epoch++;
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_profileKey),
      prefs.remove(_goalsKey),
      prefs.remove(_tasksKey),
      prefs.remove(_tasksDayKey),
      prefs.remove(_consistencyKey),
      prefs.remove(_consistencyDayKey),
    ]);
  }

  /// Caching is best effort: a failed write never fails the fetch.
  void _write(int epoch, Future<void> Function(SharedPreferences prefs) write) {
    if (epoch != _epoch) return;
    SharedPreferences.getInstance()
        .then(write)
        .catchError((Object error) => debugPrint('Dashboard cache: $error'));
  }

  static String _dayKey(DateTime date) {
    final local = date.toLocal();
    return '${local.year}-${local.month}-${local.day}';
  }

  static Map<String, dynamic>? _decodeMap(String? source) {
    if (source == null) return null;
    final value = jsonDecode(source);
    return value is Map<String, dynamic> ? value : null;
  }

  static List<Map<String, dynamic>>? _decodeList(String? source) {
    if (source == null) return null;
    final value = jsonDecode(source);
    return value is List
        ? value.whereType<Map<String, dynamic>>().toList(growable: false)
        : null;
  }

  Future<List<Map<String, dynamic>>> _fetchGoals() async {
    final data = await _graphql.rawRequest(
      query: _getGoalsQuery,
    );

    final value = data['getGoals'];

    if (value is! List) {
      throw const DashboardFailure(
        'دریافت اهداف ناموفق بود.',
      );
    }

    return value.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  /// Today's tasks only. An unfiltered page is ordered oldest first, so once
  /// a user has history (or recurring tasks materialized ahead) today's
  /// tasks would fall outside it.
  Future<List<Map<String, dynamic>>> _fetchTasks() async {
    final data = await _graphql.rawRequest(
      query: _getTasksQuery,
      variables: {
        'date': _rfc3339Local(DateTime.now()),
        'limit': 100,
        'offset': 0,
      },
    );

    final value = data['getTasks'];

    if (value is! List) {
      throw const DashboardFailure(
        'دریافت تسک‌ها ناموفق بود.',
      );
    }

    return value.whereType<Map<String, dynamic>>().toList(growable: false);
  }
}

class DashboardCache {
  const DashboardCache({
    this.profile,
    this.goals,
    this.tasks,
    this.consistency,
  });

  final ProfileUser? profile;
  final List<DashboardGoal>? goals;
  final List<DashboardTask>? tasks;
  final DashboardConsistency? consistency;
}

/// The score multiplier: a level that each finished day with a timed plan
/// moves one step, up when the day counted and down when it did not. A day
/// counts once its plan progress reaches [targetPercentage] and at least
/// [minStudySeconds] of study were timed. The server owns the rule; this is
/// its answer for today.
class DashboardConsistency {
  const DashboardConsistency({
    required this.level,
    required this.maxLevel,
    required this.countedToday,
    required this.plannedSeconds,
    required this.progressSeconds,
    required this.studiedSeconds,
    required this.minStudySeconds,
    required this.targetPercentage,
    required this.remainingSeconds,
    required this.fraction,
    this.fetchedAt,
  });

  /// When the server worked these numbers out; a timer running since adds
  /// to today's study on screen.
  final DateTime? fetchedAt;

  /// The level now, already including today once today has counted.
  final int level;
  final int maxLevel;
  final bool countedToday;

  /// Today's timed plan and the part of it done.
  final int plannedSeconds;
  final int progressSeconds;

  /// Study timed today, whatever the plan.
  final int studiedSeconds;
  final int minStudySeconds;

  /// Where today's progress bar must reach, as a percentage of the plan.
  final double targetPercentage;

  /// Work still needed for today to count; zero once it has.
  final int remainingSeconds;

  /// How far today is toward counting, from 0 to 1.
  final double fraction;

  bool get hasPlan => plannedSeconds > 0;

  int get remainingMinutes => (remainingSeconds / 60).ceil();

  factory DashboardConsistency.fromJson(
    Map<String, dynamic> json, {
    DateTime? fetchedAt,
  }) {
    int toInt(String key, [int fallback = 0]) =>
        (json[key] as num?)?.toInt() ?? fallback;
    double toDouble(String key, double fallback) =>
        (json[key] as num?)?.toDouble() ?? fallback;
    return DashboardConsistency(
      fetchedAt: fetchedAt ?? DateTime.now(),
      level: toInt('level', 1),
      maxLevel: toInt('maxLevel', 5),
      countedToday: json['countedToday'] == true,
      plannedSeconds: toInt('plannedSeconds'),
      progressSeconds: toInt('progressSeconds'),
      studiedSeconds: toInt('studiedSeconds'),
      minStudySeconds: toInt('minStudySeconds', 90 * 60),
      targetPercentage: toDouble('targetPercentage', 70),
      remainingSeconds: toInt('remainingSeconds'),
      fraction: toDouble('fraction', 0).clamp(0.0, 1.0),
    );
  }
}

class DashboardGoal {
  const DashboardGoal({
    required this.id,
    required this.title,
    this.targetDate,
    this.status = 'IN_PROGRESS',
  });

  final String id;
  final String title;
  final DateTime? targetDate;
  final String status;

  /// Still being worked toward: not reached and not archived.
  bool get isRunning => status != 'COMPLETED' && status != 'ARCHIVED';

  factory DashboardGoal.fromJson(
      Map<String, dynamic> json,
      ) {
    return DashboardGoal(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      targetDate: DateTime.tryParse(
        json['targetDate']?.toString() ?? '',
      ),
      status: json['status']?.toString() ?? 'IN_PROGRESS',
    );
  }
}

class DashboardTask {
  const DashboardTask({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.completedAt,
    required this.date,
    required this.durationM,
    required this.elapsedSeconds,
    required this.timerStartedAt,
  });

  final String id;
  final String title;
  final String type;
  final String status;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final DateTime? date;
  final int durationM;
  final int elapsedSeconds;
  final DateTime? timerStartedAt;

  factory DashboardTask.fromJson(
      Map<String, dynamic> json,
      ) {
    return DashboardTask(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? 'NORMAL',
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: DateTime.tryParse(
        json['createdAt']?.toString() ?? '',
      ),
      completedAt: DateTime.tryParse(
        json['completedAt']?.toString() ?? '',
      ),
      date: DateTime.tryParse(
        json['date']?.toString() ?? '',
      ),
      durationM: (json['durationM'] as num?)?.toInt() ?? 0,
      elapsedSeconds:
      (json['elapsedSeconds'] as num?)?.toInt() ?? 0,
      timerStartedAt: DateTime.tryParse(
        json['timerStartedAt']?.toString() ?? '',
      ),
    );
  }
}

class DashboardTaskItem {
  const DashboardTaskItem({
    required this.id,
    required this.title,
    required this.percentage,
    required this.doneDuration,
    required this.maxDuration,
    required this.durationText,
    required this.elapsedSeconds,
    required this.isDone,
    this.isRunning = false,
    this.timerStartedAt,
  });

  /// When the server last started its timer, while it runs.
  final DateTime? timerStartedAt;

  /// The work done so far, in seconds, as [percentage] of the plan.
  int get progressSeconds =>
      (percentage / 100 * maxDuration * 60).round().clamp(0, maxDuration * 60);

  /// This task with [seconds] worked, its timer [running] or not, [done] or
  /// not: how it stands now rather than when it was fetched.
  DashboardTaskItem withProgress({
    required int seconds,
    required bool running,
    required bool done,
  }) {
    final planned = maxDuration * 60;
    final worked = done ? planned : seconds.clamp(0, planned);
    return DashboardTaskItem(
      id: id,
      title: title,
      percentage: planned > 0 ? worked * 100 / planned : 0,
      doneDuration: worked ~/ 60,
      maxDuration: maxDuration,
      durationText: durationText,
      // What the timer screen resumes from: it ignores this while the same
      // task is ticking, so only a stopped task needs it exact.
      elapsedSeconds: running ? elapsedSeconds : worked,
      isDone: done,
      isRunning: running && !done,
      timerStartedAt: running && !done ? timerStartedAt : null,
    );
  }

  final String id;
  final String title;
  final double percentage;
  final int doneDuration;
  final int maxDuration;
  final String durationText;

  /// Committed elapsed time, excluding a running interval (as the timer
  /// service expects it).
  final int elapsedSeconds;
  final bool isDone;

  /// Its timer is on right now.
  final bool isRunning;

  /// Started and stopped before the end: some time done, the timer off.
  bool get isPaused => !isDone && !isRunning && percentage > 0;

  bool get isNotStarted => !isDone && !isRunning && percentage <= 0;

  /// Minutes of the plan still ahead.
  int get remainingMinutes =>
      isDone ? 0 : (maxDuration - doneDuration).clamp(0, maxDuration);

  /// Also carries the keys [TaskTimerScreen] reads, so opening the timer
  /// from the dashboard uses the task's real duration and progress.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'percentage': percentage,
      'doneDuration': doneDuration,
      'maxDuration': maxDuration,
      'durationText': durationText,
      'durationSeconds': maxDuration * 60,
      'elapsedSeconds': elapsedSeconds,
      'status': isDone ? 'done' : 'pending',
    };
  }
}

class DashboardFailure implements Exception {
  const DashboardFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

const _consistencyQuery = r'''
query DashboardConsistency {
  consistencyStatus {
    level
    maxLevel
    countedToday
    plannedSeconds
    progressSeconds
    studiedSeconds
    minStudySeconds
    targetPercentage
    remainingSeconds
    fraction
  }
}
''';

const _getGoalsQuery = r'''
query GetDashboardGoals {
  getGoals {
    id
    title
    targetDate
    status
  }
}
''';

/// RFC 3339 with the device's UTC offset, so the server resolves the same
/// calendar day the user sees.
String _rfc3339Local(DateTime value) {
  final local = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  final offset = local.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final offsetMinutes = offset.inMinutes.abs();
  return '${local.year.toString().padLeft(4, '0')}-${two(local.month)}-${two(local.day)}'
      'T${two(local.hour)}:${two(local.minute)}:${two(local.second)}'
      '$sign${two(offsetMinutes ~/ 60)}:${two(offsetMinutes % 60)}';
}

const _getTasksQuery = r'''
query GetDashboardTasks($date: Time, $limit: Int, $offset: Int) {
  getTasks(
    date: $date
    limit: $limit
    offset: $offset
  ) {
    id
    title
    type
    date
    createdAt
    completedAt
    durationM
    elapsedSeconds
    timerStartedAt
    status
  }
}
''';