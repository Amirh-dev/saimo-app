import 'package:ferry/ferry.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/graphql/mutations/__generated__/create_direct_chat.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/delete_message.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/send_message.req.gql.dart';
import 'package:simo_learn/graphql/queries/__generated__/get_chat_messages.req.gql.dart';
import 'package:simo_learn/graphql/queries/__generated__/get_friends.req.gql.dart';
import 'package:simo_learn/graphql/queries/__generated__/get_me.req.gql.dart';

import 'chat_message_store.dart';
import 'chat_models.dart';

/// Chat data access built entirely on the typed Ferry client.
///
/// Every operation goes through [GraphQLRepository.requestOnce], so it shares
/// the app's auth link, logging and (correct) UTF-8 transport. The generated
/// data objects are converted with `toJson()` and fed into the existing domain
/// mappers, keeping [ChatMessage]/[ChatContact] and the message-store logic
/// stable.
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

  Future<List<ChatMessage>> getChatMessages({
    required String chatID,
    int limit = 30,
    int offset = 0,
  }) async {
    final response = await _graphql.requestOnce(
      GGetChatMessagesReq(
        (b) => b.vars
          ..chatID.value = chatID
          ..limit = limit
          ..offset = offset,
      ),
    );
    _throwOnErrors(response, 'دریافت پیام‌ها ناموفق بود');

    final rawMessages = response.data?.getChatMessages;
    if (rawMessages == null) return const [];

    final messages = rawMessages
        .map((message) => ChatMessage.fromJson(message.toJson()))
        .where((message) => message.id.isNotEmpty)
        .toList()
      ..sort(compareMessagesByCreatedAt);
    return messages;
  }

  Future<ChatMessage> sendMessage({
    required String chatID,
    required String content,
    String? replyToID,
  }) async {
    final response = await _graphql.requestOnce(
      GSendMessageReq((b) {
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
    if (sent != null) return ChatMessage.fromJson(sent.toJson());
    throw const GraphQLRawException('ارسال پیام ناموفق بود');
  }

  Future<ChatMessage> deleteMessage(String messageID) async {
    final response = await _graphql.requestOnce(
      GDeleteMessageReq((b) => b.vars.messageID.value = messageID),
    );
    _throwOnErrors(response, 'حذف پیام ناموفق بود');

    final deleted = response.data?.deleteMessage;
    if (deleted != null) return ChatMessage.fromJson(deleted.toJson());
    throw const GraphQLRawException('حذف پیام ناموفق بود');
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
