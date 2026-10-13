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

  /// The day the cached tasks belong to; they are dropped on any other day.
  static const _tasksDayKey = 'dashboard_cache.tasks_day';

  /// Bumped by [clearCache]; a fetch started before it does not write back.
  int _epoch = 0;

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

  /// What the last fetches left on disk; a section is null when nothing
  /// usable is there.
  Future<DashboardCache> readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profile = _decodeMap(prefs.getString(_profileKey));
      final goals = _decodeList(prefs.getString(_goalsKey));
      final tasksAreToday =
          prefs.getString(_tasksDayKey) == _dayKey(DateTime.now());
      final tasks =
          tasksAreToday ? _decodeList(prefs.getString(_tasksKey)) : null;
      return DashboardCache(
        profile: profile == null ? null : ProfileUser.fromJson(profile),
        goals: goals?.map(DashboardGoal.fromJson).toList(growable: false),
        tasks: tasks?.map(DashboardTask.fromJson).toList(growable: false),
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
  const DashboardCache({this.profile, this.goals, this.tasks});

  final ProfileUser? profile;
  final List<DashboardGoal>? goals;
  final List<DashboardTask>? tasks;
}

class DashboardGoal {
  const DashboardGoal({
    required this.id,
    required this.title,
    this.targetDate,
  });

  final String id;
  final String title;
  final DateTime? targetDate;

  factory DashboardGoal.fromJson(
      Map<String, dynamic> json,
      ) {
    return DashboardGoal(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      targetDate: DateTime.tryParse(
        json['targetDate']?.toString() ?? '',
      ),
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
  });

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