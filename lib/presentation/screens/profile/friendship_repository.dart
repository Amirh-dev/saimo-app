import 'package:simo_learn/data/graphql/graphql_repository.dart';

import 'friendship_models.dart';

class FriendRequestByPhoneUnavailableException implements Exception {
  const FriendRequestByPhoneUnavailableException();

  @override
  String toString() =>
      'افزودن دوست با شماره موبایل هنوز از سمت سرور فعال نشده است.';
}

class FriendshipRepository {
  FriendshipRepository(this._graphql);

  final GraphQLRepository _graphql;

  Future<CurrentFriendshipUser> getCurrentUser() async {
    final data = await _graphql.rawRequest(query: _getMeForFriendsQuery);
    final getMe = data['getMe'];
    if (getMe is Map<String, dynamic>) {
      final user = CurrentFriendshipUser.fromJson(getMe);
      if (user.id.isNotEmpty) return user;
    }
    throw const GraphQLRawException('دریافت اطلاعات کاربر ناموفق بود');
  }

  Future<List<FriendshipItem>> getFriendships(String currentUserID) async {
    final data = await _graphql.rawRequest(
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

  Future<FriendshipItem> sendFriendRequestByPhone({
    required String currentUserID,
    required String phoneNumber,
  }) async {
    try {
      final data = await _graphql.rawRequest(
        query: _sendFriendRequestByPhoneMutation,
        variables: {'phoneNumber': phoneNumber},
      );
      final rawFriendship = data['sendFriendRequestByPhone'];
      if (rawFriendship is Map<String, dynamic>) {
        return FriendshipItem.fromJson(
          rawFriendship,
          currentUserID: currentUserID,
        );
      }
      throw const GraphQLRawException('ارسال درخواست دوستی ناموفق بود');
    } on GraphQLRawException catch (error) {
      final message = error.message.toLowerCase();
      if (message.contains('sendfriendrequestbyphone') &&
          (message.contains('cannot query field') ||
              message.contains('unknown field') ||
              message.contains('not found'))) {
        // TODO(backend): Add sendFriendRequestByPhone(phoneNumber: String!).
        throw const FriendRequestByPhoneUnavailableException();
      }
      rethrow;
    }
  }

  Future<FriendshipItem> acceptFriendRequest({
    required String currentUserID,
    required String targetUserID,
  }) async {
    final data = await _graphql.rawRequest(
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
    final data = await _graphql.rawRequest(
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
  phoneNumber
}
receiver {
  id
  fullName
  phoneNumber
}
''';

const String _getMeForFriendsQuery = r'''
query GetMeForFriends {
  getMe {
    id
    fullName
    phoneNumber
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

const String _sendFriendRequestByPhoneMutation = '''
mutation SendFriendRequestByPhone(\$phoneNumber: String!) {
  sendFriendRequestByPhone(phoneNumber: \$phoneNumber) {
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
