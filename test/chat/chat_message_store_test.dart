import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/screens/chat/chat_message_store.dart';
import 'package:simo_learn/presentation/screens/chat/chat_models.dart';

void main() {
  group('upsertMessages', () {
    test('deduplicates by id and keeps oldest-to-newest ordering', () {
      final first = _message(
        id: '1',
        content: 'first',
        createdAt: '2026-01-01T10:00:00Z',
      );
      final second = _message(
        id: '2',
        content: 'second',
        createdAt: '2026-01-01T10:02:00Z',
      );
      final updatedFirst = _message(
        id: '1',
        content: 'updated',
        createdAt: '2026-01-01T10:00:00Z',
      );

      final result = upsertMessages([second, first], [updatedFirst]);

      expect(result.map((message) => message.id), ['1', '2']);
      expect(result.first.content, 'updated');
    });

    test('replaces a matching optimistic local message with server copy', () {
      final localMessage = _message(
        id: 'local-1',
        content: 'same message',
        createdAt: '2026-01-01T10:00:00Z',
      ).copyWith(isSending: true);
      final serverMessage = _message(
        id: 'server-1',
        content: 'same message',
        createdAt: '2026-01-01T10:00:01Z',
      );

      final result = upsertMessages([localMessage], [serverMessage]);

      expect(result, hasLength(1));
      expect(result.single.id, 'server-1');
    });

    test('does not drop same-content live message from another sender', () {
      final localMessage = _message(
        id: 'local-1',
        content: 'same message',
        senderID: 'current-user',
        createdAt: '2026-01-01T10:00:00Z',
      ).copyWith(isSending: true);
      final incomingMessage = _message(
        id: 'server-1',
        content: 'same message',
        senderID: 'other-user',
        createdAt: '2026-01-01T10:00:02Z',
      );

      final result = upsertMessages([localMessage], [incomingMessage]);

      expect(result, hasLength(2));
      expect(result.map((message) => message.id), ['local-1', 'server-1']);
    });

    test('one server event replaces only one matching pending message', () {
      final firstLocal = _message(
        id: 'local-1',
        content: 'same message',
        createdAt: '2026-01-01T10:00:00Z',
      ).copyWith(isSending: true);
      final secondLocal = _message(
        id: 'local-2',
        content: 'same message',
        createdAt: '2026-01-01T10:00:04Z',
      ).copyWith(isSending: true);
      final serverEcho = _message(
        id: 'server-1',
        content: 'same message',
        createdAt: '2026-01-01T10:00:01Z',
      );

      final result = upsertMessages([firstLocal, secondLocal], [serverEcho]);

      expect(result, hasLength(2));
      expect(result.map((message) => message.id), ['server-1', 'local-2']);
    });

    test('keeps two distinct messages from the same sender', () {
      final first = _message(
        id: 'server-1',
        content: 'first',
        createdAt: '2026-01-01T10:00:00Z',
      );
      final second = _message(
        id: 'server-2',
        content: 'second',
        createdAt: '2026-01-01T10:00:30Z',
      );

      final result = upsertMessages([first], [second]);

      expect(result.map((message) => message.id), ['server-1', 'server-2']);
    });
  });

  group('replaceLocalMessage', () {
    test('scalar-only mutation response preserves optimistic reply preview',
        () {
      const reply = ChatReplyMessage(
        id: 'reply-1',
        content: 'original message',
        senderID: 'other-user',
        createdAt: '2026-01-01T09:59:00Z',
      );
      final localMessage = _message(
        id: 'local-1',
        content: 'reply text',
        replyToID: reply.id,
        replyTo: reply,
      ).copyWith(isSending: true);
      final scalarServerMessage = _message(
        id: 'server-1',
        content: 'reply text',
        replyToID: reply.id,
      );

      final result = replaceLocalMessage(
        [localMessage],
        localID: localMessage.id,
        serverMessage: scalarServerMessage,
      );

      expect(result, hasLength(1));
      expect(result.single.id, 'server-1');
      expect(result.single.replyTo?.id, reply.id);
      expect(result.single.isSending, isFalse);
    });
  });

  group('applyInboxEventToRoom', () {
    test('inserts incoming NewMessageEvent from another sender', () {
      final incomingMessage = _message(
        id: 'live-1',
        senderID: 'other-user',
      );

      final result = applyInboxEventToRoom(
        messages: const [],
        activityByUserID: const {},
        event: NewMessageInboxEvent(message: incomingMessage),
        chatID: 'chat-a',
      );

      expect(result.messages, [incomingMessage]);
    });

    test('inserts matching new messages without duplicating existing ones', () {
      final message = _message(id: '1', chatID: 'chat-a');
      final initial = [message];

      final result = applyInboxEventToRoom(
        messages: initial,
        activityByUserID: const {},
        event: NewMessageInboxEvent(message: message.copyWith(content: 'new')),
        chatID: 'chat-a',
      );

      expect(result.messages, hasLength(1));
      expect(result.messages.single.content, 'new');
    });

    test('ignores new and deleted message events for other chats', () {
      final message = _message(id: '1', chatID: 'chat-a');

      final newMessageResult = applyInboxEventToRoom(
        messages: [message],
        activityByUserID: const {},
        event: NewMessageInboxEvent(
          message: _message(id: '2', chatID: 'chat-b'),
        ),
        chatID: 'chat-a',
      );

      final deleteResult = applyInboxEventToRoom(
        messages: newMessageResult.messages,
        activityByUserID: const {},
        event: const MessageDeletedInboxEvent(messageID: '1', chatID: 'chat-b'),
        chatID: 'chat-a',
      );

      expect(deleteResult.messages, hasLength(1));
      expect(deleteResult.messages.single.id, '1');
      expect(deleteResult.messages.single.isDeleted, isFalse);
    });

    test('marks matching deleted message events locally', () {
      final result = applyInboxEventToRoom(
        messages: [_message(id: '1', chatID: 'chat-a')],
        activityByUserID: const {},
        event: const MessageDeletedInboxEvent(messageID: '1', chatID: 'chat-a'),
        chatID: 'chat-a',
      );

      expect(result.messages.single.isDeleted, isTrue);
      expect(result.messages.single.content, isEmpty);
    });

    test('marks existing sent messages up to MessageSeenEvent read watermark',
        () {
      const readAt = '2026-01-01T10:02:30Z';
      final firstSent = _message(
        id: 'sent-1',
        senderID: 'current-user',
        createdAt: '2026-01-01T10:00:00Z',
      );
      final secondSent = _message(
        id: 'sent-2',
        senderID: 'current-user',
        createdAt: '2026-01-01T10:02:00Z',
      );
      final afterWatermark = _message(
        id: 'sent-3',
        senderID: 'current-user',
        createdAt: '2026-01-01T10:03:00Z',
      );
      final incomingFromReader = _message(
        id: 'incoming-1',
        senderID: 'other-user',
        createdAt: '2026-01-01T10:01:00Z',
      );

      final result = applyInboxEventToRoom(
        messages: [
          firstSent,
          secondSent,
          afterWatermark,
          incomingFromReader,
        ],
        activityByUserID: const {},
        event: const MessageSeenInboxEvent(
          chatID: 'chat-a',
          userID: 'other-user',
          readAt: readAt,
        ),
        chatID: 'chat-a',
      );

      expect(result.messages, hasLength(4));
      expect(
        result.messages.firstWhere((message) => message.id == 'sent-1').seenAt,
        readAt,
      );
      expect(
        result.messages.firstWhere((message) => message.id == 'sent-2').seenAt,
        readAt,
      );
      expect(
        result.messages
            .firstWhere((message) => message.id == 'incoming-1')
            .seenAt,
        isNull,
      );
      expect(
        result.messages.firstWhere((message) => message.id == 'sent-3').seenAt,
        isNull,
      );
    });

    test('ignores MessageSeenEvent for another chat', () {
      final sent = _message(id: 'sent-1', senderID: 'current-user');

      final result = applyInboxEventToRoom(
        messages: [sent],
        activityByUserID: const {},
        event: const MessageSeenInboxEvent(
          chatID: 'chat-b',
          userID: 'other-user',
          readAt: '2026-01-01T10:02:00Z',
        ),
        chatID: 'chat-a',
      );

      expect(result.messages, hasLength(1));
      expect(result.messages.single.id, 'sent-1');
      expect(result.messages.single.seenAt, isNull);
    });

    test('does not insert a message for MessageSeenEvent', () {
      final sent = _message(id: 'sent-1', senderID: 'current-user');

      final result = applyInboxEventToRoom(
        messages: [sent],
        activityByUserID: const {},
        event: const MessageSeenInboxEvent(
          chatID: 'chat-a',
          userID: 'other-user',
          readAt: '2026-01-01T10:02:00Z',
        ),
        chatID: 'chat-a',
      );

      expect(result.messages.map((message) => message.id), ['sent-1']);
    });

    test('does not mark pending local temp messages seen', () {
      final pendingLocal = _message(
        id: 'local-1',
        senderID: 'current-user',
      ).copyWith(isSending: true);

      final result = applyInboxEventToRoom(
        messages: [pendingLocal],
        activityByUserID: const {},
        event: const MessageSeenInboxEvent(
          chatID: 'chat-a',
          userID: 'other-user',
          readAt: '2026-01-01T10:02:00Z',
        ),
        chatID: 'chat-a',
      );

      expect(result.messages.single.id, 'local-1');
      expect(result.messages.single.isSending, isTrue);
      expect(result.messages.single.seenAt, isNull);
    });

    test('marks only current sender messages with sender read watermark', () {
      const readAt = '2026-01-01T10:02:00Z';
      final sent = _message(
        id: 'sent-1',
        senderID: 'current-user',
        createdAt: '2026-01-01T10:01:00Z',
      );
      final incoming = _message(
        id: 'incoming-1',
        senderID: 'other-user',
        createdAt: '2026-01-01T10:01:00Z',
      );
      final pendingLocal = _message(
        id: 'local-1',
        senderID: 'current-user',
        createdAt: '2026-01-01T10:01:00Z',
      ).copyWith(isSending: true);

      final result = markMessagesSeenForSender(
        [sent, incoming, pendingLocal],
        chatID: 'chat-a',
        senderID: 'current-user',
        readAt: readAt,
      );

      expect(
        result.firstWhere((message) => message.id == 'sent-1').seenAt,
        readAt,
      );
      expect(
        result.firstWhere((message) => message.id == 'incoming-1').seenAt,
        isNull,
      );
      expect(
        result.firstWhere((message) => message.id == 'local-1').seenAt,
        isNull,
      );
    });

    test('sender watermark supports MessageSeenEvent userID matching sender',
        () {
      const readAt = '2026-01-01T10:02:00Z';
      final sent = _message(
        id: 'sent-1',
        senderID: 'current-user',
        createdAt: '2026-01-01T10:01:00Z',
      );

      final result = markMessagesSeenForSender(
        [sent],
        chatID: 'chat-a',
        senderID: 'current-user',
        readAt: readAt,
      );

      expect(result.single.seenAt, readAt);
    });

    test('stores user activity events', () {
      final result = applyInboxEventToRoom(
        messages: const [],
        activityByUserID: const {},
        event: const UserActivityInboxEvent(
          userID: 'user-a',
          isOnline: true,
          currentTaskName: 'ریاضی',
        ),
        chatID: 'chat-a',
      );

      expect(result.activityByUserID['user-a']?.isOnline, isTrue);
      expect(result.activityByUserID['user-a']?.currentTaskName, 'ریاضی');
    });

    test('still applies WebSocket event when an optimistic send has failed',
        () {
      final failedLocal = _message(
        id: 'local-failed',
        content: 'failed send',
        senderID: 'current-user',
      ).copyWith(isFailed: true);
      final incomingMessage = _message(
        id: 'live-1',
        content: 'live message',
        senderID: 'other-user',
        createdAt: '2026-01-01T10:00:01Z',
      );

      final result = applyInboxEventToRoom(
        messages: [failedLocal],
        activityByUserID: const {},
        event: NewMessageInboxEvent(message: incomingMessage),
        chatID: 'chat-a',
      );

      expect(result.messages.map((message) => message.id), [
        'local-failed',
        'live-1',
      ]);
    });
  });

  group('applyInitialMessagesToRoom', () {
    test('keeps live messages that arrived while the first page was loading',
        () {
      final liveMessage = _message(
        id: 'live-1',
        content: 'from socket',
        createdAt: '2026-01-01T10:03:00Z',
      );
      final fetchedMessage = _message(
        id: 'fetched-1',
        content: 'from api',
        createdAt: '2026-01-01T10:00:00Z',
      );

      final result = applyInitialMessagesToRoom(
        messages: [liveMessage],
        fetchedMessages: [fetchedMessage],
        pageSize: 30,
      );

      expect(result.messages.map((message) => message.id), [
        'fetched-1',
        'live-1',
      ]);
      expect(result.offset, 1);
      expect(result.hasMore, isFalse);
    });
  });
}

ChatMessage _message({
  required String id,
  String chatID = 'chat-a',
  String content = 'hello',
  String senderID = 'user-a',
  String? replyToID,
  ChatReplyMessage? replyTo,
  String createdAt = '2026-01-01T10:00:00Z',
  String? seenAt,
}) {
  return ChatMessage(
    id: id,
    content: content,
    type: 'TEXT',
    chatID: chatID,
    senderID: senderID,
    replyToID: replyToID,
    isDeleted: false,
    createdAt: createdAt,
    updatedAt: createdAt,
    replyTo: replyTo,
    seenAt: seenAt,
  );
}
