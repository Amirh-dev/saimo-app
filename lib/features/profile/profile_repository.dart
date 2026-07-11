import 'package:simo_learn/data/graphql/graphql_repository.dart';

typedef ProfileGraphQLRequest = Future<Map<String, dynamic>> Function({
  required String query,
  Map<String, dynamic> variables,
  bool requiresAuth,
});

class ProfileUser {
  const ProfileUser({
    required this.id,
    required this.username,
    required this.simoCoins,
    required this.score,
    required this.isPremium,
    this.fullName,
    this.birthDate,
    this.studyTime,
    this.major,
    this.bio,
    this.interests = const [],
  });

  final String id;
  final String username;
  final String? fullName;
  final DateTime? birthDate;
  final String? studyTime;
  final String? major;
  final String? bio;
  final List<String> interests;
  final int simoCoins;
  final int score;
  final bool isPremium;

  String get displayName {
    final name = fullName?.trim();
    return name == null || name.isEmpty ? 'کاربر سیمو' : name;
  }

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
      birthDate: DateTime.tryParse(json['birthDate']?.toString() ?? ''),
      studyTime: json['studyTime']?.toString(),
      major: json['major']?.toString(),
      bio: json['bio']?.toString(),
      interests: (json['interests'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((interest) => interest['name']?.toString().trim() ?? '')
              .where((name) => name.isNotEmpty)
              .toList(growable: false) ??
          const [],
      simoCoins: (json['simoCoins'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toInt() ?? 0,
      isPremium: json['isPremium'] == true,
    );
  }
}

class ProfileRepository {
  ProfileRepository(GraphQLRepository graphql) : _request = graphql.rawRequest;

  ProfileRepository.withRawRequest(this._request);

  final ProfileGraphQLRequest _request;

  Future<ProfileUser> getMe() async {
    final data = await _request(query: _getProfileQuery);
    return _parseProfile(data['getMe'], 'دریافت پروفایل ناموفق بود');
  }

  Future<ProfileUser> getUserProfile(String userID) async {
    final data = await _request(
      query: _getUserProfileQuery,
      variables: {'id': userID},
    );
    return _parseProfile(data['node'], 'دریافت پروفایل کاربر ناموفق بود');
  }

  Future<ProfileUser> updateProfile({
    required String fullName,
    required String username,
    required DateTime birthDate,
  }) async {
    final dateOnly = DateTime.utc(
      birthDate.year,
      birthDate.month,
      birthDate.day,
    );
    final data = await _request(
      query: _updateProfileMutation,
      variables: {
        'input': {
          'fullName': fullName.trim(),
          'username': username.trim(),
          'birthDate': dateOnly.toIso8601String(),
        },
      },
    );
    return _parseProfile(
      data['updateProfile'],
      'ذخیره مشخصات ناموفق بود',
    );
  }

  ProfileUser _parseProfile(Object? value, String errorMessage) {
    if (value is! Map<String, dynamic>) {
      throw GraphQLRawException(errorMessage);
    }
    final profile = ProfileUser.fromJson(value);
    if (profile.id.isEmpty || profile.username.isEmpty) {
      throw GraphQLRawException(errorMessage);
    }
    return profile;
  }
}

const _profileFields = r'''
id
username
fullName
birthDate
studyTime
major
bio
simoCoins
score
isPremium
interests {
  id
  name
}
''';

const _getProfileQuery = '''
query GetProfile {
  getMe {
    $_profileFields
  }
}
''';

const _updateProfileMutation = '''
mutation UpdateProfile(\$input: UpdateProfileInput!) {
  updateProfile(input: \$input) {
    $_profileFields
  }
}
''';

const _getUserProfileQuery = '''
query GetUserProfile(\$id: ID!) {
  node(id: \$id) {
    ... on User {
      $_profileFields
    }
  }
}
''';
