import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/screens/chat/chat_models.dart';
import 'package:simo_learn/presentation/screens/chat/inbox_subscription_client.dart';

void main() {
  group('inboxEventFromGraphQLSocketMessage', () {
    test('parses legacy graphql-ws data frames from GraphQL Playground', () {
      final event = inboxEventFromGraphQLSocketMessage(
        _messageFrame(type: 'data'),
      );

      expect(event, isA<NewMessageInboxEvent>());
      final messageEvent = event as NewMessageInboxEvent;
      expect(messageEvent.message.id, 'message-1');
      expect(messageEvent.message.chatID, 'chat-1');
      expect(messageEvent.message.content, 'hello from socket');
    });

    test('parses graphql-transport-ws next frames', () {
      final event = inboxEventFromGraphQLSocketMessage(
        _messageFrame(type: 'next'),
      );

      expect(event, isA<NewMessageInboxEvent>());
      expect((event as NewMessageInboxEvent).message.senderID, 'user-2');
    });

    test('parses message data even when the payload has field errors', () {
      final event = inboxEventFromGraphQLSocketMessage(
        _messageFrame(
          type: 'data',
          errors: [
            {'message': 'field resolver failed'},
          ],
        ),
      );

      expect(event, isA<NewMessageInboxEvent>());
      expect((event as NewMessageInboxEvent).message.id, 'message-1');
    });

    test('ignores keep-alive and error-only payload frames', () {
      expect(
        inboxEventFromGraphQLSocketMessage(jsonEncode({'type': 'ka'})),
        isNull,
      );
      expect(
        inboxEventFromGraphQLSocketMessage(
          jsonEncode({
            'type': 'data',
            'payload': {
              'errors': [
                {'message': 'unauthorized'},
              ],
            },
          }),
        ),
        isNull,
      );
    });
  });
}

String _messageFrame({
  required String type,
  List<Map<String, String>> errors = const [],
}) {
  return jsonEncode({
    'id': 'inbox',
    'type': type,
    'payload': {
      if (errors.isNotEmpty) 'errors': errors,
      'data': {
        'inbox': {
          '__typename': 'NewMessageEvent',
          'message': {
            'id': 'message-1',
            'content': 'hello from socket',
            'type': 'TEXT',
            'chatID': 'chat-1',
            'senderID': 'user-2',
            'replyToID': null,
            'isDeleted': false,
            'deletedAt': null,
            'createdAt': '2026-01-01T10:00:00Z',
            'updatedAt': '2026-01-01T10:00:00Z',
            'replyTo': null,
          },
        },
      },
    },
  });
}
