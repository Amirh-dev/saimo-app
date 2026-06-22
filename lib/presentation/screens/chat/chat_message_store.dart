import 'chat_models.dart';

List<ChatMessage> upsertMessages(
  List<ChatMessage> current,
  Iterable<ChatMessage> incoming,
) {
  final byId = <String, ChatMessage>{
    for (final message in current) message.id: message,
  };

  for (final message in incoming) {
    if (message.id.isEmpty) continue;
    if (!message.isLocal) {
      byId.removeWhere((_, localMessage) {
        return _isServerEchoOfLocalMessage(
          localMessage: localMessage,
          serverMessage: message,
        );
      });
    }
    byId[message.id] = message;
  }

  final messages = byId.values.toList();
  messages.sort(compareMessagesByCreatedAt);
  return messages;
}

List<ChatMessage> removeLocalMessage(
  List<ChatMessage> current,
  String localID,
) {
  return [
    for (final message in current)
      if (message.id != localID) message,
  ];
}

List<ChatMessage> markMessageDeleted(
  List<ChatMessage> current,
  String messageID, {
  String? deletedAt,
}) {
  return [
    for (final message in current)
      if (message.id == messageID)
        message.copyWith(
          isDeleted: true,
          content: '',
          deletedAt: deletedAt ?? DateTime.now().toUtc().toIso8601String(),
        )
      else
        message,
  ];
}

List<ChatMessage> markMessageFailed(
  List<ChatMessage> current,
  String messageID,
) {
  return [
    for (final message in current)
      if (message.id == messageID)
        message.copyWith(isSending: false, isFailed: true)
      else
        message,
  ];
}

bool hasServerEchoOfLocalMessage(
  List<ChatMessage> messages,
  ChatMessage localMessage,
) {
  return messages.any((message) {
    return _isServerEchoOfLocalMessage(
      localMessage: localMessage,
      serverMessage: message,
    );
  });
}

ChatRoomEventResult applyInboxEventToRoom({
  required List<ChatMessage> messages,
  required Map<String, UserActivity> activityByUserID,
  required InboxEvent event,
  required String chatID,
}) {
  final nextActivity = Map<String, UserActivity>.of(activityByUserID);
  var nextMessages = List<ChatMessage>.of(messages);

  switch (event) {
    case NewMessageInboxEvent(:final message):
      if (message.chatID == chatID) {
        nextMessages = upsertMessages(nextMessages, [message]);
      }
      break;
    case MessageDeletedInboxEvent(:final messageID, chatID: final eventChatID):
      if (eventChatID == chatID) {
        nextMessages = markMessageDeleted(nextMessages, messageID);
      }
      break;
    case UserActivityInboxEvent(
      :final userID,
      :final isOnline,
      :final currentTaskName,
    ):
      if (userID.isNotEmpty) {
        nextActivity[userID] = UserActivity(
          isOnline: isOnline,
          currentTaskName: currentTaskName,
        );
      }
      break;
    case UnknownInboxEvent():
      break;
  }

  return ChatRoomEventResult(
    messages: nextMessages,
    activityByUserID: nextActivity,
  );
}

bool _isServerEchoOfLocalMessage({
  required ChatMessage localMessage,
  required ChatMessage serverMessage,
}) {
  if (!localMessage.isLocal || serverMessage.isLocal) return false;
  if (localMessage.chatID != serverMessage.chatID) return false;
  if (localMessage.senderID != serverMessage.senderID) return false;
  if (localMessage.content.trim() != serverMessage.content.trim()) return false;
  if (localMessage.replyToID != serverMessage.replyToID) return false;

  final localCreatedAt = DateTime.tryParse(localMessage.createdAt);
  final serverCreatedAt = DateTime.tryParse(serverMessage.createdAt);
  if (localCreatedAt == null || serverCreatedAt == null) return true;

  return localCreatedAt.difference(serverCreatedAt).abs() <=
      const Duration(seconds: 90);
}

int compareMessagesByCreatedAt(ChatMessage a, ChatMessage b) {
  final aDate = DateTime.tryParse(a.createdAt);
  final bDate = DateTime.tryParse(b.createdAt);
  if (aDate == null && bDate == null) return a.id.compareTo(b.id);
  if (aDate == null) return -1;
  if (bDate == null) return 1;
  final result = aDate.compareTo(bDate);
  if (result != 0) return result;
  return a.id.compareTo(b.id);
}

class ChatRoomEventResult {
  const ChatRoomEventResult({
    required this.messages,
    required this.activityByUserID,
  });

  final List<ChatMessage> messages;
  final Map<String, UserActivity> activityByUserID;
}
