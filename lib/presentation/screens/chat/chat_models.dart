enum InboxConnectionStatus {
  idle,
  connecting,
  connected,
  reconnecting,
  disconnected,
  error,
}

class ChatUser {
  const ChatUser({
    required this.id,
  });

  final String id;

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(id: json['id']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() => {
        '__typename': 'User',
        'id': id,
      };
}

class ChatReplyMessage {
  const ChatReplyMessage({
    required this.id,
    required this.content,
    required this.senderID,
    required this.createdAt,
  });

  final String id;
  final String content;
  final String senderID;
  final String createdAt;

  factory ChatReplyMessage.fromJson(Map<String, dynamic> json) {
    return ChatReplyMessage(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      senderID: json['senderID']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '__typename': 'Message',
        'id': id,
        'content': content,
        'senderID': senderID,
        'createdAt': createdAt,
      };
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.chatID,
    required this.senderID,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.replyToID,
    this.deletedAt,
    this.replyTo,
    this.sender,
    this.isSending = false,
    this.isFailed = false,
    this.seenAt,
  });

  final String id;
  final String content;
  final String type;
  final String chatID;
  final String senderID;
  final String? replyToID;
  final bool isDeleted;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;
  final ChatReplyMessage? replyTo;
  final ChatUser? sender;
  final bool isSending;
  final bool isFailed;
  final String? seenAt;

  bool get isLocal => id.startsWith('local-');

  ChatMessage copyWith({
    String? id,
    String? content,
    String? type,
    String? chatID,
    String? senderID,
    String? replyToID,
    bool? isDeleted,
    String? deletedAt,
    String? createdAt,
    String? updatedAt,
    ChatReplyMessage? replyTo,
    ChatUser? sender,
    bool? isSending,
    bool? isFailed,
    String? seenAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      chatID: chatID ?? this.chatID,
      senderID: senderID ?? this.senderID,
      replyToID: replyToID ?? this.replyToID,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replyTo: replyTo ?? this.replyTo,
      sender: sender ?? this.sender,
      isSending: isSending ?? this.isSending,
      isFailed: isFailed ?? this.isFailed,
      seenAt: seenAt ?? this.seenAt,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final replyToJson = json['replyTo'];
    final senderJson = json['sender'];
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      chatID: json['chatID']?.toString() ?? '',
      senderID: json['senderID']?.toString() ?? '',
      replyToID: json['replyToID']?.toString(),
      isDeleted: json['isDeleted'] == true,
      deletedAt: json['deletedAt']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      replyTo: replyToJson is Map<String, dynamic>
          ? ChatReplyMessage.fromJson(replyToJson)
          : null,
      sender: senderJson is Map<String, dynamic>
          ? ChatUser.fromJson(senderJson)
          : null,
      seenAt: json['seenAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        '__typename': 'Message',
        'id': id,
        'content': content,
        'type': type,
        'chatID': chatID,
        'senderID': senderID,
        'replyToID': replyToID,
        'isDeleted': isDeleted,
        'deletedAt': deletedAt,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'replyTo': replyTo?.toJson(),
        // GetChatMessages selects a non-null sender. Delete events only carry
        // IDs, so retain a normalizable User reference from senderID.
        'sender': (sender ?? ChatUser(id: senderID)).toJson(),
      };
}

class ChatContact {
  const ChatContact({
    required this.friendshipID,
    required this.targetUserID,
    required this.status,
    required this.isPending,
    this.targetFullName,
    this.targetUsername,
  });

  final String friendshipID;
  final String targetUserID;
  final String status;
  final bool isPending;
  final String? targetFullName;
  final String? targetUsername;

  bool get hasFullName => targetFullName?.trim().isNotEmpty == true;

  String? get usernameLabel {
    final username = targetUsername?.trim();
    return username == null || username.isEmpty ? null : '@$username';
  }

  String get displayName {
    final fullName = targetFullName?.trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;

    final username = usernameLabel;
    if (username != null) return username;

    return 'کاربر سیمو';
  }

  String get subtitle {
    if (isPending) return 'در انتظار تایید درخواست';
    return 'برای شروع گفتگو لمس کنید';
  }
}

sealed class InboxEvent {
  const InboxEvent(this.typename);

  final String typename;

  factory InboxEvent.fromJson(Map<String, dynamic> json) {
    final typename = json['__typename']?.toString() ?? '';
    return switch (typename) {
      'NewMessageEvent' => NewMessageInboxEvent(
          message: ChatMessage.fromJson(
            (json['message'] as Map?)?.cast<String, dynamic>() ??
                const <String, dynamic>{},
          ),
        ),
      'MessageDeletedEvent' => MessageDeletedInboxEvent(
          messageID: json['messageID']?.toString() ?? '',
          chatID: json['chatID']?.toString() ?? '',
        ),
      'MessageSeenEvent' => MessageSeenInboxEvent(
          chatID: json['chatID']?.toString() ?? '',
          userID: json['userID']?.toString() ?? '',
          readAt: json['readAt']?.toString() ?? '',
        ),
      'UserActivityEvent' => UserActivityInboxEvent(
          userID: json['userID']?.toString() ?? '',
          isOnline: json['isOnline'] == true,
          currentTaskName: json['currentTaskName']?.toString(),
        ),
      _ => UnknownInboxEvent(typename),
    };
  }
}

class NewMessageInboxEvent extends InboxEvent {
  const NewMessageInboxEvent({
    required this.message,
  }) : super('NewMessageEvent');

  final ChatMessage message;
}

class MessageDeletedInboxEvent extends InboxEvent {
  const MessageDeletedInboxEvent({
    required this.messageID,
    required this.chatID,
  }) : super('MessageDeletedEvent');

  final String messageID;
  final String chatID;
}

class MessageSeenInboxEvent extends InboxEvent {
  const MessageSeenInboxEvent({
    required this.chatID,
    required this.userID,
    required this.readAt,
  }) : super('MessageSeenEvent');

  final String chatID;
  final String userID;
  final String readAt;
}

class UserActivityInboxEvent extends InboxEvent {
  const UserActivityInboxEvent({
    required this.userID,
    required this.isOnline,
    this.currentTaskName,
  }) : super('UserActivityEvent');

  final String userID;
  final bool isOnline;
  final String? currentTaskName;
}

class UnknownInboxEvent extends InboxEvent {
  const UnknownInboxEvent(super.typename);
}

class UserActivity {
  const UserActivity({
    required this.isOnline,
    this.currentTaskName,
  });

  final bool isOnline;
  final String? currentTaskName;
}
