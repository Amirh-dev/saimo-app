import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/features/profile/profile_repository.dart';

void main() {
  test('getMe parses editable profile fields and statistics', () async {
    final repository = ProfileRepository.withRawRequest(({
      required String query,
      Map<String, dynamic> variables = const {},
      bool requiresAuth = true,
    }) async {
      expect(query, contains('query GetProfile'));
      expect(requiresAuth, isTrue);
      return {
        'getMe': {
          'id': 'user-1',
          'username': 'ali_rezaei',
          'phoneNumber': '09380619195',
          'fullName': 'علی رضایی',
          'birthDate': '2001-02-03T00:00:00.000Z',
          'studyTime': 'BETWEEN_4_AND_7',
          'simoCoins': 36,
          'score': 3,
          'isPremium': true,
        },
      };
    });

    final profile = await repository.getMe();

    expect(profile.id, 'user-1');
    expect(profile.username, 'ali_rezaei');
    expect(profile.phoneNumber, '09380619195');
    expect(profile.displayName, 'علی رضایی');
    expect(profile.birthDate, DateTime.utc(2001, 2, 3));
    expect(profile.simoCoins, 36);
    expect(profile.score, 3);
    expect(profile.isPremium, isTrue);
  });

  test('updateProfile sends normalized values and returns the updated user',
      () async {
    Map<String, dynamic>? sentVariables;
    final repository = ProfileRepository.withRawRequest(({
      required String query,
      Map<String, dynamic> variables = const {},
      bool requiresAuth = true,
    }) async {
      expect(query, contains('mutation UpdateProfile'));
      sentVariables = variables;
      return {
        'updateProfile': {
          'id': 'user-1',
          'username': 'new_name',
          'fullName': 'علی رضایی',
          'birthDate': '2001-02-03T00:00:00.000Z',
          'simoCoins': 36,
          'score': 3,
          'isPremium': true,
        },
      };
    });

    final profile = await repository.updateProfile(
      fullName: '  علی رضایی  ',
      username: '  new_name  ',
      birthDate: DateTime(2001, 2, 3, 18, 30),
    );

    expect(sentVariables, {
      'input': {
        'fullName': 'علی رضایی',
        'username': 'new_name',
        'birthDate': '2001-02-03T00:00:00.000Z',
      },
    });
    expect(profile.username, 'new_name');
  });

  test('getUserProfile loads public biography and interests by user id',
      () async {
    Map<String, dynamic>? sentVariables;
    final repository = ProfileRepository.withRawRequest(({
      required String query,
      Map<String, dynamic> variables = const {},
      bool requiresAuth = true,
    }) async {
      expect(query, contains('query GetUserProfile'));
      sentVariables = variables;
      return {
        'node': {
          'id': 'friend-1',
          'username': 'friend_user',
          'fullName': 'دوست سیمو',
          'bio': 'دانش آموز رشته ریاضی',
          'simoCoins': 21,
          'score': 4,
          'isPremium': true,
          'interests': [
            {'id': 'interest-1', 'name': 'ریاضی'},
            {'id': 'interest-2', 'name': 'هنر'},
          ],
        },
      };
    });

    final profile = await repository.getUserProfile('friend-1');

    expect(sentVariables, {'id': 'friend-1'});
    expect(profile.bio, 'دانش آموز رشته ریاضی');
    expect(profile.interests, ['ریاضی', 'هنر']);
  });
}
