import 'dart:convert';

import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/study_hall/hall_avatar.dart';

/// The three buildings are the profile's `studyTime`. The value names are
/// old (installed builds send them); since Nov 2026 they mean under 4 hours,
/// 4 to 8 and 8 to 14. On screen they are silver, gold and diamond, with the
/// hour range in small type next to the name.
enum HallBuilding {
  under4('UNDER_4_HOURS', 'نقره', 'زیر ۴ ساعت', 0xFFC9CED8),
  middle('BETWEEN_4_AND_7', 'طلا', '۴ تا ۸ ساعت', 0xFFE9B949),
  top('OVER_7_HOURS', 'الماس', '۸ تا ۱۴ ساعت', 0xFF8FD3F4);

  const HallBuilding(this.apiValue, this.name, this.range, this.color);
  final String apiValue;

  /// «نقره», «طلا», «الماس».
  final String name;

  /// The daily study range, shown small next to the name.
  final String range;
  final int color;

  /// «ساختمان طلا».
  String get title => 'ساختمان $name';

  /// Older call sites: the name, for sentences like «ساختمون طلا».
  String get label => name;

  static HallBuilding fromApi(Object? value) =>
      values.firstWhere((b) => b.apiValue == value, orElse: () => middle);

  HallBuilding? get next => index + 1 < values.length ? values[index + 1] : null;
}

/// One floor: a band of today's study. Nobody is ranked inside it.
class HallFloor {
  const HallFloor({
    required this.index,
    required this.isRoof,
    required this.fromMinutes,
    required this.toMinutes,
    required this.people,
    required this.studyingNow,
  });

  final int index;
  final bool isRoof;
  final int fromMinutes;

  /// Null on the roof.
  final int? toMinutes;
  final int people;
  final int studyingNow;

  factory HallFloor.fromJson(Map<String, dynamic> json) => HallFloor(
        index: (json['index'] as num).toInt(),
        isRoof: json['isRoof'] == true,
        fromMinutes: (json['fromMinutes'] as num).toInt(),
        toMinutes: (json['toMinutes'] as num?)?.toInt(),
        people: (json['people'] as num?)?.toInt() ?? 0,
        studyingNow: (json['studyingNow'] as num?)?.toInt() ?? 0,
      );

  bool get isGround => index == 0 && !isRoof;

  bool contains(int minutes) =>
      minutes >= fromMinutes && (toMinutes == null || minutes < toMinutes!);
}

/// Someone on your floor today (first name only).
class HallNeighbor {
  const HallNeighbor({required this.userId, required this.name, required this.avatar, required this.todaySeconds, required this.studyingNow});

  final String userId;
  final String name;

  /// Null until they made a character; the window then shows the default.
  final HallAvatar? avatar;
  final int todaySeconds;
  final bool studyingNow;

  factory HallNeighbor.fromJson(Map<String, dynamic> j) => HallNeighbor(
        userId: j['userID'] as String,
        name: (j['name'] as String?) ?? '',
        avatar: hallAvatarFromString(j['avatar'] as String?),
        todaySeconds: (j['todaySeconds'] as num?)?.toInt() ?? 0,
        studyingNow: j['studyingNow'] == true,
      );
}

HallAvatar? hallAvatarFromString(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    return HallAvatar.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}

class StudyHall {
  const StudyHall({
    required this.building,
    required this.dayStartedAt,
    required this.dayEndsAt,
    required this.todaySeconds,
    required this.yesterdaySeconds,
    required this.studyingNow,
    required this.capSeconds,
    required this.floors,
    required this.buildingPeople,
    this.studyingNowTotal = 0,
    this.neighbors = const [],
    this.myAvatar,
    this.bestDaySeconds = 0,
    this.recentDays = const [],
  });

  /// Most study in one day over the last year; unlocks character items.
  final int bestDaySeconds;

  /// Study for each of the 30 days before today, oldest first.
  final List<int> recentDays;

  /// People with a timer running now, in every building.
  final int studyingNowTotal;

  /// Up to nine others on your floor, never ranked.
  final List<HallNeighbor> neighbors;

  /// Your character as saved on the server.
  final HallAvatar? myAvatar;

  final HallBuilding building;
  final DateTime dayStartedAt;
  final DateTime dayEndsAt;
  final int todaySeconds;
  final int yesterdaySeconds;
  final bool studyingNow;
  final int capSeconds;

  /// Ground floor first; the roof, when the building has one, is last.
  final List<HallFloor> floors;
  final Map<HallBuilding, int> buildingPeople;

  bool get hasRoof => floors.isNotEmpty && floors.last.isRoof;

  /// Where [seconds] of study puts you in this building. The last band of
  /// the top building ends at the cap and stays the top floor past it.
  int floorFor(int seconds) {
    final minutes = seconds.clamp(0, capSeconds) ~/ 60;
    for (var i = floors.length - 1; i >= 0; i--) {
      if (minutes >= floors[i].fromMinutes) return i;
    }
    return 0;
  }

  factory StudyHall.fromJson(Map<String, dynamic> json) => StudyHall(
        building: HallBuilding.fromApi(json['building']),
        dayStartedAt: DateTime.parse(json['dayStartedAt'] as String).toLocal(),
        dayEndsAt: DateTime.parse(json['dayEndsAt'] as String).toLocal(),
        todaySeconds: (json['todaySeconds'] as num?)?.toInt() ?? 0,
        yesterdaySeconds: (json['yesterdaySeconds'] as num?)?.toInt() ?? 0,
        studyingNow: json['studyingNow'] == true,
        capSeconds: (json['capSeconds'] as num?)?.toInt() ?? 14 * 3600,
        floors: [
          for (final f in (json['floors'] as List? ?? const []))
            HallFloor.fromJson(f as Map<String, dynamic>),
        ],
        studyingNowTotal: (json['studyingNowTotal'] as num?)?.toInt() ?? 0,
        neighbors: [
          for (final n in (json['neighbors'] as List? ?? const [])) HallNeighbor.fromJson(n as Map<String, dynamic>),
        ],
        myAvatar: hallAvatarFromString(json['myAvatar'] as String?),
        bestDaySeconds: (json['bestDaySeconds'] as num?)?.toInt() ?? 0,
        recentDays: [for (final d in (json['recentDays'] as List? ?? const [])) (d as num).toInt()],
        buildingPeople: {
          for (final b in (json['buildings'] as List? ?? const []))
            HallBuilding.fromApi((b as Map<String, dynamic>)['studyTime']):
                (b['people'] as num?)?.toInt() ?? 0,
        },
      );
}

typedef HallRequest = Future<Map<String, dynamic>> Function({
  required String query,
  Map<String, dynamic> variables,
  bool requiresAuth,
});

/// rawRequest because lib/graphql/schema.graphql is stale.
class StudyHallRepository {
  StudyHallRepository(GraphQLRepository graphql) : _request = graphql.rawRequest;
  StudyHallRepository.withRequest(this._request);

  final HallRequest _request;

  static const _query = r'''
query StudyHall {
  studyHall {
    building dayStartedAt dayEndsAt todaySeconds yesterdaySeconds studyingNow capSeconds
    floors { index isRoof fromMinutes toMinutes people studyingNow }
    buildings { studyTime people }
    studyingNowTotal myAvatar bestDaySeconds recentDays
    neighbors { userID name avatar todaySeconds studyingNow }
  }
}
''';

  static const _floor = r'''
query StudyHallFloor($floor: Int!) {
  studyHallFloor(floor: $floor) { userID name avatar todaySeconds studyingNow }
}
''';

  static const _saveAvatar = r'''
mutation SetHallAvatar($avatar: String!) {
  setHallAvatar(avatar: $avatar)
}
''';

  /// The last answer, so the building opens at once and refreshes after.
  static StudyHall? cached;
  static DateTime? cachedAt;

  static const _move = r'''
mutation MoveStudyHallBuilding($input: UpdateProfileInput!) {
  updateProfile(input: $input) { id studyTime }
}
''';

  Future<StudyHall> load() async {
    final data = await _request(query: _query);
    final hall = StudyHall.fromJson(data['studyHall'] as Map<String, dynamic>);
    cached = hall;
    cachedAt = DateTime.now();
    return hall;
  }

  /// Everybody on one floor of your building today (you left out).
  Future<List<HallNeighbor>> floorPeople(int floor) async {
    final data = await _request(query: _floor, variables: {'floor': floor});
    return [
      for (final n in (data['studyHallFloor'] as List? ?? const [])) HallNeighbor.fromJson(n as Map<String, dynamic>),
    ];
  }

  Future<void> saveAvatar(HallAvatar avatar) async {
    await _request(query: _saveAvatar, variables: {'avatar': jsonEncode(avatar.toJson())});
  }

  /// Moving building is the same as changing the profile's study time.
  Future<void> move(HallBuilding to) async {
    await _request(query: _move, variables: {
      'input': {'studyTime': to.apiValue},
    });
  }
}

/// The desk plant. A day waters it when you reach the second سالن of your
/// building (1 h in silver, 2 h in gold, 4 h in diamond); every سالن above
/// that adds one more leaf. It looks at the last 30 days plus today, wilts
/// after a dry yesterday, and flowers at [flowerAt] leaves.
class HallPlant {
  const HallPlant({required this.days, required this.today, required this.waterSeconds});

  /// Leaves earned on each of the 30 days before today, oldest first.
  final List<int> days;

  /// Leaves earned so far today.
  final int today;

  /// Study that waters the plant today.
  final int waterSeconds;

  static const flowerAt = 20;

  factory HallPlant.of(StudyHall hall, int todaySeconds) {
    int leaves(int seconds) => hall.floorFor(seconds);
    return HallPlant(
      days: [for (final d in hall.recentDays) leaves(d)],
      today: leaves(todaySeconds),
      waterSeconds: hall.floors.length > 1 ? hall.floors[1].fromMinutes * 60 : 3600,
    );
  }

  int get leaves => days.fold(0, (a, b) => a + b) + today;
  bool get wateredToday => today > 0;

  /// Yesterday stayed dry and today has not watered it yet.
  bool get wilting => !wateredToday && (days.isEmpty || days.last == 0);
  bool get flowering => leaves >= flowerAt && !wilting;
}
