import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/profile/profile_repository.dart';

class DashboardRepository {
  DashboardRepository(this._graphql)
      : _profileRepository = ProfileRepository(_graphql);

  final GraphQLRepository _graphql;
  final ProfileRepository _profileRepository;

  Future<DashboardPayload> load() async {
    final results = await Future.wait<Object?>([
      _profileRepository.getMe(),
      _getGoals(),
      _getTasks(),
    ]);

    return DashboardPayload(
      profile: results[0] as ProfileUser,
      goals: results[1] as List<DashboardGoal>,
      tasks: results[2] as List<DashboardTask>,
    );
  }

  Future<List<DashboardGoal>> _getGoals() async {
    final data = await _graphql.rawRequest(
      query: _getGoalsQuery,
    );

    final value = data['getGoals'];

    if (value is! List) {
      throw const DashboardFailure(
        'دریافت اهداف ناموفق بود.',
      );
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map(DashboardGoal.fromJson)
        .toList(growable: false);
  }

  Future<List<DashboardTask>> _getTasks() async {
    final data = await _graphql.rawRequest(
      query: _getTasksQuery,
      variables: {
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

    return value
        .whereType<Map<String, dynamic>>()
        .map(DashboardTask.fromJson)
        .toList(growable: false);
  }
}

class DashboardPayload {
  const DashboardPayload({
    required this.profile,
    required this.goals,
    required this.tasks,
  });

  final ProfileUser profile;
  final List<DashboardGoal> goals;
  final List<DashboardTask>  tasks;
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
    required this.title,
    required this.percentage,
    required this.doneDuration,
    required this.maxDuration,
    required this.durationText,
  });

  final String title;
  final double percentage;
  final int doneDuration;
  final int maxDuration;
  final String durationText;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'percentage': percentage,
      'doneDuration': doneDuration,
      'maxDuration': maxDuration,
      'durationText': durationText,
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

const _getTasksQuery = r'''
query GetDashboardTasks($limit: Int, $offset: Int) {
  getTasks(
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