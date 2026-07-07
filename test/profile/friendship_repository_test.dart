import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/screens/profile/friendship_repository.dart';

void main() {
  group('searchUsersByUsername', () {
    test('does not call the API for queries shorter than three characters',
        () async {
      var requestCount = 0;
      final repository = FriendshipRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async {
        requestCount += 1;
        return const {};
      });

      final users = await repository.searchUsersByUsername(query: 'al');

      expect(users, isEmpty);
      expect(requestCount, 0);
    });

    test('does not send non-Latin username queries to the API', () async {
      var requestCount = 0;
      final repository = FriendshipRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async {
        requestCount += 1;
        return const {};
      });

      final users = await repository.searchUsersByUsername(query: 'علی');

      expect(users, isEmpty);
      expect(requestCount, 0);
    });

    test('trims the query and omits optional pagination variables', () async {
      Map<String, dynamic>? sentVariables;
      final repository = FriendshipRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async {
        sentVariables = variables;
        expect(query, contains('searchUsersByUsername'));
        return {
          'searchUsersByUsername': [
            {'id': 'user-1', 'username': 'alireza', 'fullName': 'Ali Reza'},
            {'id': '', 'username': 'invalid'},
          ],
        };
      });

      final users = await repository.searchUsersByUsername(query: ' ali ');

      expect(sentVariables, {'query': 'ali'});
      expect(users, hasLength(1));
      expect(users.single.username, 'alireza');
    });

    test('passes pagination when supplied', () async {
      Map<String, dynamic>? sentVariables;
      final repository = FriendshipRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async {
        sentVariables = variables;
        return const {'searchUsersByUsername': []};
      });

      await repository.searchUsersByUsername(
        query: 'ali',
        limit: 20,
        offset: 40,
      );

      expect(sentVariables, {'query': 'ali', 'limit': 20, 'offset': 40});
    });

    test('rejects invalid pagination locally', () async {
      final repository = FriendshipRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async =>
          const {});

      await expectLater(
        repository.searchUsersByUsername(query: 'ali', limit: 0),
        throwsArgumentError,
      );
      await expectLater(
        repository.searchUsersByUsername(query: 'ali', offset: -1),
        throwsArgumentError,
      );
    });
  });

  test('findUserByUsername returns the exact user response', () async {
    Map<String, dynamic>? sentVariables;
    final repository = FriendshipRepository.withRawRequest(({
      required String query,
      Map<String, dynamic> variables = const {},
      bool requiresAuth = true,
    }) async {
      expect(query, contains('findUserByUsername'));
      sentVariables = variables;
      return {
        'findUserByUsername': {
          'id': 'user-1',
          'username': 'ali',
          'fullName': 'Ali',
        },
      };
    });

    final user = await repository.findUserByUsername(' ali ');

    expect(sentVariables, {'username': 'ali'});
    expect(user?.id, 'user-1');
    expect(user?.username, 'ali');
  });

  test('sendFriendRequest uses the selected user id', () async {
    Map<String, dynamic>? sentVariables;
    final repository = FriendshipRepository.withRawRequest(({
      required String query,
      Map<String, dynamic> variables = const {},
      bool requiresAuth = true,
    }) async {
      expect(query, contains('sendFriendRequest(targetUserID:'));
      sentVariables = variables;
      return {
        'sendFriendRequest': {
          'id': 'friendship-1',
          'status': 'PENDING',
          'requesterID': 'current-user',
          'receiverID': 'target-user',
          'requester': {'id': 'current-user', 'username': 'me'},
          'receiver': {'id': 'target-user', 'username': 'ali'},
        },
      };
    });

    final friendship = await repository.sendFriendRequest(
      currentUserID: 'current-user',
      targetUserID: 'target-user',
    );

    expect(sentVariables, {'targetUserID': 'target-user'});
    expect(friendship.targetUserID, 'target-user');
    expect(friendship.targetUser.username, 'ali');
  });
}
