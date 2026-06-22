import 'package:simo_learn/data/graphql/graphql_repository.dart';

import 'chat_models.dart';

class ChatRepository {
  ChatRepository(this._graphql);

  final GraphQLRepository _graphql;

  Future<String> getCurrentUserID() async {
    final data = await _graphql.rawRequest(query: _getMeQuery);
    final getMe = data['getMe'];
    if (getMe is Map<String, dynamic>) {
      final id = getMe['id']?.toString();
      if (id != null && id.isNotEmpty) return id;
    }
    throw const GraphQLRawException('دریافت اطلاعات کاربر ناموفق بود');
  }

  Future<List<ChatContact>> getFriends(String currentUserID) async {
    final data = await _graphql.rawRequest(
      query: _getFriendsQuery,
      variables: const {'limit': 20, 'offset': 0},
    );
    final rawFriends = data['getFriends'];
    if (rawFriends is! List) return const [];

    return rawFriends
        .whereType<Map<String, dynamic>>()
        .map((json) => _contactFromFriendJson(json, currentUserID))
        .whereType<ChatContact>()
        .toList();
  }

  Future<String> createDirectChat(String targetUserID) async {
    final data = await _graphql.rawRequest(
      query: _createDirectChatMutation,
      variables: {'targetUserID': targetUserID},
    );
    final chat = data['createDirectChat'];
    if (chat is Map<String, dynamic>) {
      final id = chat['id']?.toString();
      if (id != null && id.isNotEmpty) return id;
    }
    throw const GraphQLRawException('ایجاد گفتگو ناموفق بود');
  }

  Future<List<ChatMessage>> getChatMessages({
    required String chatID,
    int limit = 30,
    int offset = 0,
  }) async {
    final data = await _graphql.rawRequest(
      query: _getChatMessagesQuery,
      variables: {
        'chatID': chatID,
        'limit': limit,
        'offset': offset,
      },
    );
    final rawMessages = data['getChatMessages'];
    if (rawMessages is! List) return const [];
    final messages = rawMessages
        .whereType<Map<String, dynamic>>()
        .map(ChatMessage.fromJson)
        .where((message) => message.id.isNotEmpty)
        .toList();
    messages.sort((a, b) {
      final aDate = DateTime.tryParse(a.createdAt);
      final bDate = DateTime.tryParse(b.createdAt);
      if (aDate == null || bDate == null) return 0;
      return aDate.compareTo(bDate);
    });
    return messages;
  }

  Future<ChatMessage> sendMessage({
    required String chatID,
    required String content,
    String? replyToID,
  }) async {
    final data = await _graphql.rawRequest(
      query: _sendMessageMutation,
      variables: {
        'chatID': chatID,
        'content': content,
        'replyToID': replyToID,
      },
    );
    final rawMessage = data['sendMessage'];
    if (rawMessage is Map<String, dynamic>) {
      return ChatMessage.fromJson(rawMessage);
    }
    throw const GraphQLRawException('ارسال پیام ناموفق بود');
  }

  Future<ChatMessage> deleteMessage(String messageID) async {
    final data = await _graphql.rawRequest(
      query: _deleteMessageMutation,
      variables: {'messageID': messageID},
    );
    final rawMessage = data['deleteMessage'];
    if (rawMessage is Map<String, dynamic>) {
      return ChatMessage.fromJson(rawMessage);
    }
    throw const GraphQLRawException('حذف پیام ناموفق بود');
  }

  ChatContact? _contactFromFriendJson(
    Map<String, dynamic> json,
    String currentUserID,
  ) {
    final requesterID = json['requesterID']?.toString();
    final receiverID = json['receiverID']?.toString();
    final requester = json['requester'];
    final receiver = json['receiver'];
    final requesterMap =
        requester is Map<String, dynamic> ? requester : <String, dynamic>{};
    final receiverMap =
        receiver is Map<String, dynamic> ? receiver : <String, dynamic>{};
    final fallbackRequesterID =
        requesterMap.isNotEmpty ? requesterMap['id']?.toString() : requesterID;
    final fallbackReceiverID =
        receiverMap.isNotEmpty ? receiverMap['id']?.toString() : receiverID;

    final isRequester = currentUserID == fallbackRequesterID;
    final targetUserID = currentUserID == fallbackRequesterID
        ? fallbackReceiverID
        : fallbackRequesterID;
    if (targetUserID == null || targetUserID.isEmpty) return null;
    final targetUser = isRequester ? receiverMap : requesterMap;

    final status = json['status']?.toString() ?? '';
    return ChatContact(
      friendshipID: json['id']?.toString() ?? targetUserID,
      targetUserID: targetUserID,
      status: status,
      isPending: status.toUpperCase() != 'ACCEPTED',
      targetFullName: targetUser['fullName']?.toString(),
      targetPhoneNumber: targetUser['phoneNumber']?.toString(),
    );
  }
}

const String _getMeQuery = r'''
query GetMe {
  getMe {
    id
  }
}
''';

const String _getFriendsQuery = r'''
query GetFriends($limit: Int, $offset: Int) {
  getFriends(limit: $limit, offset: $offset) {
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
  }
}
''';

const String _createDirectChatMutation = r'''
mutation CreateDirectChat($targetUserID: UUID!) {
  createDirectChat(input: {
    targetUserID: $targetUserID
  }) {
    id
  }
}
''';

const String _getChatMessagesQuery = r'''
query GetChatMessages($chatID: UUID!, $limit: Int, $offset: Int) {
  getChatMessages(chatID: $chatID, limit: $limit, offset: $offset) {
    id
    content
    type
    chatID
    senderID
    replyToID
    isDeleted
    deletedAt
    createdAt
    updatedAt
    replyTo {
      id
      content
      senderID
      createdAt
    }
    sender {
      id
    }
  }
}
''';

const String _sendMessageMutation = r'''
mutation SendMessage($chatID: ID!, $content: String!, $replyToID: ID) {
  sendMessage(input: {
    chatID: $chatID
    content: $content
    replyToID: $replyToID
  }) {
    id
    content
    type
    chatID
    senderID
    replyToID
    isDeleted
    deletedAt
    createdAt
    updatedAt
    replyTo {
      id
      content
      senderID
      createdAt
    }
    sender {
      id
    }
  }
}
''';

const String _deleteMessageMutation = r'''
mutation DeleteMessage($messageID: UUID!) {
  deleteMessage(messageID: $messageID) {
    id
    content
    type
    chatID
    senderID
    replyToID
    isDeleted
    deletedAt
    createdAt
    updatedAt
  }
}
''';
