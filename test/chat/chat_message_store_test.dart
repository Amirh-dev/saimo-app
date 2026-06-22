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
      );
      final serverMessage = _message(
        id: 'server-1',
        content: 'same message',
        createdAt: '2026-01-01T10:00:01Z',
      );

      final result = upsertMessages([localMessage], [serverMessage]);

      expect(result, hasLength(1));
      expect(result.single.id, 'server-1');
    });
  });

  group('applyInboxEventToRoom', () {
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
  });
}

ChatMessage _message({
  required String id,
  String chatID = 'chat-a',
  String content = 'hello',
  String createdAt = '2026-01-01T10:00:00Z',
}) {
  return ChatMessage(
    id: id,
    content: content,
    type: 'TEXT',
    chatID: chatID,
    senderID: 'user-a',
    isDeleted: false,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}
