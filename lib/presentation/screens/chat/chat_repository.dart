import 'package:ferry/ferry.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/graphql/mutations/__generated__/create_direct_chat.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/delete_message.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/send_message.req.gql.dart';
import 'package:simo_learn/graphql/queries/__generated__/get_chat_messages.data.gql.dart';
import 'package:simo_learn/graphql/queries/__generated__/get_chat_messages.req.gql.dart';
import 'package:simo_learn/graphql/queries/__generated__/get_friends.req.gql.dart';
import 'package:simo_learn/graphql/queries/__generated__/get_me.req.gql.dart';

import 'chat_message_store.dart';
import 'chat_models.dart';

/// Chat data access built entirely on the typed Ferry client.
///
/// Every operation goes through [GraphQLRepository], so it shares the app's
/// auth link, logging, normalized Ferry cache and UTF-8 transport. Generated
/// data is converted to the existing domain models, keeping one message-upsert
/// path for cache, network, mutation and subscription results.
class ChatRepository {
  ChatRepository(this._graphql);

  final GraphQLRepository _graphql;

  Future<String> getCurrentUserID() async {
    final response = await _graphql.requestOnce(GGetMeReq());
    _throwOnErrors(response, 'دریافت اطلاعات کاربر ناموفق بود');
    final id = response.data?.getMe.id;
    if (id != null && id.isNotEmpty) return id;
    throw const GraphQLRawException('دریافت اطلاعات کاربر ناموفق بود');
  }

  Future<List<ChatContact>> getFriends(
    String currentUserID, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _graphql.requestOnce(
      GGetFriendsReq(
        (b) => b.vars
          ..limit = limit
          ..offset = offset,
      ),
    );
    _throwOnErrors(response, 'دریافت دوستان ناموفق بود');

    final friends = response.data?.getFriends;
    if (friends == null) return const [];

    return friends
        .map((friend) => _contactFromFriendJson(friend.toJson(), currentUserID))
        .whereType<ChatContact>()
        .where((contact) => contact.status.toUpperCase() == 'ACCEPTED')
        .toList();
  }

  Future<String> createDirectChat(String targetUserID) async {
    final response = await _graphql.requestOnce(
      GCreateDirectChatReq(
        (b) => b.vars.input.targetUserID.value = targetUserID,
      ),
    );
    _throwOnErrors(response, 'ایجاد گفتگو ناموفق بود');

    final id = response.data?.createDirectChat.id;
    if (id != null && id.isNotEmpty) return id;
    throw const GraphQLRawException('ایجاد گفتگو ناموفق بود');
  }

  Stream<ChatMessageBatch> getInitialChatMessages({
    required String chatID,
    int limit = 30,
    int offset = 0,
  }) async* {
    final request = _chatMessagesRequest(
      chatID: chatID,
      limit: limit,
      offset: offset,
      fetchPolicy: FetchPolicy.CacheAndNetwork,
    );

    await for (final response in _graphql.request(request)) {
      _throwOnErrors(response, 'دریافت پیام‌ها ناموفق بود');
      yield ChatMessageBatch(
        messages: _messagesFromData(response.data),
        source: response.dataSource,
      );

      // CacheAndNetwork continues watching the cache after the network result.
      // Initial loading only needs the cached result and one fresh response.
      if (response.dataSource == DataSource.Link) return;
    }
  }

  Future<List<ChatMessage>> getChatMessagesFromNetwork({
    required String chatID,
    int limit = 30,
    int offset = 0,
  }) async {
    final response = await _graphql.requestOnce(
      _chatMessagesRequest(
        chatID: chatID,
        limit: limit,
        offset: offset,
        fetchPolicy: FetchPolicy.NetworkOnly,
      ),
    );
    _throwOnErrors(response, 'دریافت پیام‌ها ناموفق بود');

    return _messagesFromData(response.data);
  }

  List<ChatMessage> _messagesFromData(GGetChatMessagesData? data) {
    final rawMessages = data?.getChatMessages;
    if (rawMessages == null) return const [];

    return rawMessages
        .map((message) => ChatMessage.fromJson(message.toJson()))
        .where((message) => message.id.isNotEmpty)
        .toList()
      ..sort(compareMessagesByCreatedAt);
  }

  Future<ChatMessage> sendMessage({
    required String chatID,
    required String content,
    String? replyToID,
  }) async {
    final response = await _graphql.requestOnce(
      GSendMessageReq((b) {
        b.fetchPolicy = FetchPolicy.NetworkOnly;
        b.vars.input
          ..chatID = chatID
          ..content = content;
        if (replyToID != null && replyToID.isNotEmpty) {
          b.vars.input.replyToID = replyToID;
        }
      }),
    );
    _throwOnErrors(response, 'ارسال پیام ناموفق بود');

    final sent = response.data?.sendMessage;
    if (sent != null) {
      final message = ChatMessage.fromJson(sent.toJson());
      upsertMessagesInCache(
        chatID: chatID,
        incoming: [message],
      );
      return message;
    }
    throw const GraphQLRawException('ارسال پیام ناموفق بود');
  }

  Future<ChatMessage> deleteMessage(String messageID) async {
    final response = await _graphql.requestOnce(
      GDeleteMessageReq((b) {
        b
          ..fetchPolicy = FetchPolicy.NetworkOnly
          ..vars.messageID.value = messageID;
      }),
    );
    _throwOnErrors(response, 'حذف پیام ناموفق بود');

    final deleted = response.data?.deleteMessage;
    if (deleted != null) {
      final message = ChatMessage.fromJson(deleted.toJson());
      upsertMessagesInCache(
        chatID: message.chatID,
        incoming: [message],
        addMissingToFirstPage: false,
      );
      return message;
    }
    throw const GraphQLRawException('حذف پیام ناموفق بود');
  }

  void applyInboxEventToCache(
    InboxEvent event, {
    int limit = 30,
    Iterable<int> cachedPageOffsets = const [0],
  }) {
    switch (event) {
      case NewMessageInboxEvent(:final message):
        upsertMessagesInCache(
          chatID: message.chatID,
          incoming: [message],
          limit: limit,
          cachedPageOffsets: cachedPageOffsets,
        );
        break;
      case MessageDeletedInboxEvent(:final messageID, :final chatID):
        for (final offset in cachedPageOffsets.toSet()) {
          final request = _chatMessagesRequest(
            chatID: chatID,
            limit: limit,
            offset: offset,
          );
          final cachedMessages = _messagesFromData(_graphql.readCache(request));
          final deletedMessages = cachedMessages
              .where((message) => message.id == messageID)
              .map(
                (message) => message.copyWith(
                  isDeleted: true,
                  content: '',
                  deletedAt: DateTime.now().toUtc().toIso8601String(),
                ),
              )
              .toList();
          if (deletedMessages.isEmpty) continue;
          upsertMessagesInCache(
            chatID: chatID,
            incoming: deletedMessages,
            limit: limit,
            cachedPageOffsets: [offset],
            addMissingToFirstPage: false,
          );
        }
        break;
      case UserActivityInboxEvent():
      case UnknownInboxEvent():
        break;
    }
  }

  void upsertMessagesInCache({
    required String chatID,
    required Iterable<ChatMessage> incoming,
    int limit = 30,
    Iterable<int> cachedPageOffsets = const [0],
    bool addMissingToFirstPage = true,
  }) {
    final validIncoming = incoming
        .where((message) => message.id.isNotEmpty && message.chatID == chatID)
        .toList();
    if (validIncoming.isEmpty) return;

    for (final offset in cachedPageOffsets.toSet()) {
      final request = _chatMessagesRequest(
        chatID: chatID,
        limit: limit,
        offset: offset,
      );
      final cachedData = _graphql.readCache(request);
      final current = _messagesFromData(cachedData);
      final currentIDs = current.map((message) => message.id).toSet();
      final shouldAddMissing = offset == 0 && addMissingToFirstPage;
      final relevantIncoming = shouldAddMissing
          ? validIncoming
          : validIncoming
              .where((message) => currentIDs.contains(message.id))
              .toList();
      if (relevantIncoming.isEmpty) continue;

      var merged = upsertMessages(current, relevantIncoming);
      if (offset == 0 && merged.length > limit) {
        merged = merged.sublist(merged.length - limit);
      }

      final nextData = GGetChatMessagesData.fromJson({
        '__typename': 'Query',
        'getChatMessages': [
          for (final message in merged) message.toJson(),
        ],
      });
      if (nextData != null) {
        _graphql.writeCache(request, nextData);
      }
    }
  }

  GGetChatMessagesReq _chatMessagesRequest({
    required String chatID,
    required int limit,
    required int offset,
    FetchPolicy? fetchPolicy,
  }) {
    return GGetChatMessagesReq((b) {
      b.vars
        ..chatID.value = chatID
        ..limit = limit
        ..offset = offset;
      b.fetchPolicy = fetchPolicy;
    });
  }

  void _throwOnErrors<TData, TVars>(
    OperationResponse<TData, TVars> response,
    String fallbackMessage,
  ) {
    if (!response.hasErrors) return;
    final message = graphQLResponseErrorMessage(response);
    throw GraphQLRawException(message.isEmpty ? fallbackMessage : message);
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

class ChatMessageBatch {
  const ChatMessageBatch({
    required this.messages,
    required this.source,
  });

  final List<ChatMessage> messages;
  final DataSource source;
}
