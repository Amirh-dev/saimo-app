import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/utils/username.dart';

import 'friendship_models.dart';

typedef RawGraphQLRequest = Future<Map<String, dynamic>> Function({
  required String query,
  Map<String, dynamic> variables,
  bool requiresAuth,
});

class FriendshipRepository {
  FriendshipRepository(GraphQLRepository graphql)
      : _rawRequest = graphql.rawRequest;

  FriendshipRepository.withRawRequest(this._rawRequest);

  final RawGraphQLRequest _rawRequest;

  Future<CurrentFriendshipUser> getCurrentUser() async {
    final data = await _rawRequest(query: _getMeForFriendsQuery);
    final getMe = data['getMe'];
    if (getMe is Map<String, dynamic>) {
      final user = CurrentFriendshipUser.fromJson(getMe);
      if (user.id.isNotEmpty) return user;
    }
    throw const GraphQLRawException('دریافت اطلاعات کاربر ناموفق بود');
  }

  Future<List<FriendshipItem>> getFriendships(String currentUserID) async {
    final data = await _rawRequest(
      query: _getFriendshipsQuery,
      variables: const {'limit': 50, 'offset': 0},
    );
    final byID = <String, FriendshipItem>{};

    void addItems(Object? rawItems) {
      if (rawItems is! List) return;
      for (final rawItem in rawItems.whereType<Map<String, dynamic>>()) {
        final item = FriendshipItem.fromJson(
          rawItem,
          currentUserID: currentUserID,
        );
        if (item.targetUserID.isEmpty ||
            item.status == 'REJECTED' ||
            item.status == 'BLOCKED') {
          continue;
        }
        byID[item.id] = item;
      }
    }

    addItems(data['getFriends']);
    addItems(data['getPendingFriendRequests']);

    final items = byID.values.toList();
    items.sort((a, b) {
      final relationSort = _relationSort(a).compareTo(_relationSort(b));
      if (relationSort != 0) return relationSort;
      return a.targetUser.displayName.compareTo(b.targetUser.displayName);
    });
    return items;
  }

  Future<UsernameSearchUser?> findUserByUsername(String username) async {
    final normalizedUsername = username.trim();
    if (!hasValidUsernameCharacters(normalizedUsername)) return null;

    final data = await _rawRequest(
      query: _findUserByUsernameQuery,
      variables: {'username': normalizedUsername},
    );
    final rawUser = data['findUserByUsername'];
    if (rawUser is! Map<String, dynamic>) return null;

    final user = UsernameSearchUser.fromJson(rawUser);
    return user.id.isEmpty || user.username.isEmpty ? null : user;
  }

  Future<List<UsernameSearchUser>> searchUsersByUsername({
    required String query,
    int? limit,
    int? offset,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.length < 3 ||
        !hasValidUsernameCharacters(normalizedQuery)) {
      return const [];
    }
    if (limit != null && limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'must be greater than zero');
    }
    if (offset != null && offset < 0) {
      throw ArgumentError.value(offset, 'offset', 'must not be negative');
    }

    final data = await _rawRequest(
      query: _searchUsersByUsernameQuery,
      variables: {
        'query': normalizedQuery,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      },
    );
    final rawUsers = data['searchUsersByUsername'];
    if (rawUsers is! List) return const [];

    return rawUsers
        .whereType<Map<String, dynamic>>()
        .map(UsernameSearchUser.fromJson)
        .where((user) => user.id.isNotEmpty && user.username.isNotEmpty)
        .toList(growable: false);
  }

  Future<FriendshipItem> sendFriendRequest({
    required String currentUserID,
    required String targetUserID,
  }) async {
    final data = await _rawRequest(
      query: _sendFriendRequestMutation,
      variables: {'targetUserID': targetUserID},
    );
    final rawFriendship = data['sendFriendRequest'];
    if (rawFriendship is Map<String, dynamic>) {
      return FriendshipItem.fromJson(
        rawFriendship,
        currentUserID: currentUserID,
      );
    }
    throw const GraphQLRawException('ارسال درخواست دوستی ناموفق بود');
  }

  Future<FriendshipItem> acceptFriendRequest({
    required String currentUserID,
    required String targetUserID,
  }) async {
    final data = await _rawRequest(
      query: _acceptFriendRequestMutation,
      variables: {'targetUserID': targetUserID},
    );
    final rawFriendship = data['acceptFriendRequest'];
    if (rawFriendship is Map<String, dynamic>) {
      return FriendshipItem.fromJson(
        rawFriendship,
        currentUserID: currentUserID,
      );
    }
    throw const GraphQLRawException('تایید درخواست دوستی ناموفق بود');
  }

  Future<void> rejectFriendRequest(String targetUserID) {
    return _booleanMutation(
      query: _rejectFriendRequestMutation,
      fieldName: 'rejectFriendRequest',
      targetUserID: targetUserID,
      failureMessage: 'رد درخواست دوستی ناموفق بود',
    );
  }

  Future<void> cancelFriendRequest(String targetUserID) {
    return _booleanMutation(
      query: _cancelFriendRequestMutation,
      fieldName: 'cancelFriendRequest',
      targetUserID: targetUserID,
      failureMessage: 'لغو درخواست دوستی ناموفق بود',
    );
  }

  Future<void> removeFriend(String targetUserID) {
    return _booleanMutation(
      query: _removeFriendMutation,
      fieldName: 'removeFriend',
      targetUserID: targetUserID,
      failureMessage: 'حذف دوست ناموفق بود',
    );
  }

  Future<void> _booleanMutation({
    required String query,
    required String fieldName,
    required String targetUserID,
    required String failureMessage,
  }) async {
    final data = await _rawRequest(
      query: query,
      variables: {'targetUserID': targetUserID},
    );
    if (data[fieldName] == true) return;
    throw GraphQLRawException(failureMessage);
  }

  int _relationSort(FriendshipItem item) {
    return switch (item.relation) {
      FriendshipRelation.incomingPending => 0,
      FriendshipRelation.accepted => 1,
      FriendshipRelation.outgoingPending => 2,
    };
  }
}

const String _friendshipFields = r'''
id
status
requesterID
receiverID
userLowID
userHighID
requester {
  id
  fullName
  username
}
receiver {
  id
  fullName
  username
}
''';

const String _getMeForFriendsQuery = r'''
query GetMeForFriends {
  getMe {
    id
    fullName
    username
  }
}
''';

const String _getFriendshipsQuery = '''
query GetFriendshipsForProfile(\$limit: Int, \$offset: Int) {
  getFriends(limit: \$limit, offset: \$offset) {
    $_friendshipFields
  }
  getPendingFriendRequests(limit: \$limit, offset: \$offset) {
    $_friendshipFields
  }
}
''';

const String _usernameSearchUserFields = r'''
id
username
fullName
''';

const String _findUserByUsernameQuery = '''
query FindUserByUsername(\$username: String!) {
  findUserByUsername(username: \$username) {
    $_usernameSearchUserFields
  }
}
''';

const String _searchUsersByUsernameQuery = '''
query SearchUsersByUsername(\$query: String!, \$limit: Int, \$offset: Int) {
  searchUsersByUsername(query: \$query, limit: \$limit, offset: \$offset) {
    $_usernameSearchUserFields
  }
}
''';

const String _sendFriendRequestMutation = '''
mutation SendFriendRequest(\$targetUserID: UUID!) {
  sendFriendRequest(targetUserID: \$targetUserID) {
    $_friendshipFields
  }
}
''';

const String _acceptFriendRequestMutation = '''
mutation AcceptFriendRequest(\$targetUserID: UUID!) {
  acceptFriendRequest(targetUserID: \$targetUserID) {
    $_friendshipFields
  }
}
''';

const String _rejectFriendRequestMutation = r'''
mutation RejectFriendRequest($targetUserID: UUID!) {
  rejectFriendRequest(targetUserID: $targetUserID)
}
''';

const String _cancelFriendRequestMutation = r'''
mutation CancelFriendRequest($targetUserID: UUID!) {
  cancelFriendRequest(targetUserID: $targetUserID)
}
''';

const String _removeFriendMutation = r'''
mutation RemoveFriend($targetUserID: UUID!) {
  removeFriend(targetUserID: $targetUserID)
}
''';
