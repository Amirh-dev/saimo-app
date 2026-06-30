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
      final matchingLocal = findMatchingPendingLocalMessage(
        byId.values,
        message,
      );
      if (matchingLocal != null) byId.remove(matchingLocal.id);
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

List<ChatMessage> replaceLocalMessage(
  List<ChatMessage> current, {
  required String localID,
  required ChatMessage serverMessage,
}) {
  ChatMessage? localMessage;
  final byId = <String, ChatMessage>{};
  for (final message in current) {
    if (message.id == localID) {
      localMessage = message;
    } else {
      byId[message.id] = message;
    }
  }

  if (serverMessage.id.isNotEmpty) {
    byId[serverMessage.id] = serverMessage.copyWith(
      replyTo: serverMessage.replyTo ?? localMessage?.replyTo,
      sender: serverMessage.sender ?? localMessage?.sender,
      isSending: false,
      isFailed: false,
    );
  }

  final messages = byId.values.toList();
  messages.sort(compareMessagesByCreatedAt);
  return messages;
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

ChatMessage? findMatchingPendingLocalMessage(
  Iterable<ChatMessage> messages,
  ChatMessage serverMessage,
) {
  ChatMessage? closestMatch;
  Duration? closestDelta;

  for (final message in messages) {
    if (!_isServerEchoOfLocalMessage(
      localMessage: message,
      serverMessage: serverMessage,
    )) {
      continue;
    }

    final delta = _createdAtDelta(message, serverMessage);
    if (closestMatch == null ||
        (delta != null && (closestDelta == null || delta < closestDelta))) {
      closestMatch = message;
      closestDelta = delta;
    }
  }

  return closestMatch;
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

ChatRoomInitialLoadResult applyInitialMessagesToRoom({
  required List<ChatMessage> messages,
  required Iterable<ChatMessage> fetchedMessages,
  required int pageSize,
}) {
  final fetched = fetchedMessages.toList();
  return ChatRoomInitialLoadResult(
    messages: upsertMessages(messages, fetched),
    offset: fetched.length,
    hasMore: fetched.length == pageSize,
  );
}

bool _isServerEchoOfLocalMessage({
  required ChatMessage localMessage,
  required ChatMessage serverMessage,
}) {
  if (!localMessage.isLocal || !localMessage.isSending) return false;
  if (serverMessage.isLocal) return false;
  if (localMessage.chatID != serverMessage.chatID) return false;
  if (localMessage.senderID != serverMessage.senderID) return false;
  if (localMessage.replyToID != serverMessage.replyToID) return false;
  if (localMessage.content != serverMessage.content) return false;

  final localCreatedAt = DateTime.tryParse(localMessage.createdAt);
  final serverCreatedAt = DateTime.tryParse(serverMessage.createdAt);
  if (localCreatedAt == null || serverCreatedAt == null) return false;

  final delta = localCreatedAt.difference(serverCreatedAt).abs();
  return delta <= const Duration(seconds: 15);
}

Duration? _createdAtDelta(ChatMessage a, ChatMessage b) {
  final aCreatedAt = DateTime.tryParse(a.createdAt);
  final bCreatedAt = DateTime.tryParse(b.createdAt);
  if (aCreatedAt == null || bCreatedAt == null) return null;
  return aCreatedAt.difference(bCreatedAt).abs();
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

class ChatRoomInitialLoadResult {
  const ChatRoomInitialLoadResult({
    required this.messages,
    required this.offset,
    required this.hasMore,
  });

  final List<ChatMessage> messages;
  final int offset;
  final bool hasMore;
}
