import 'dart:async';
import 'dart:convert';

import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_endpoints.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
// ignore: depend_on_referenced_packages
import 'package:web_socket_channel/web_socket_channel.dart';

import 'chat_models.dart';

class InboxSubscriptionClient {
  InboxSubscriptionClient({
    required GraphQLRepository graphqlRepository,
    required TokenStorage tokenStorage,
    this.endpoint = GraphQLEndpoints.websocket,
  })  : _graphqlRepository = graphqlRepository,
        _tokenStorage = tokenStorage;

  final GraphQLRepository _graphqlRepository;
  final TokenStorage _tokenStorage;
  final String endpoint;
  final _eventsController = StreamController<InboxEvent>.broadcast();
  final _statusController = StreamController<InboxConnectionStatus>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  Timer? _ackTimer;
  bool _disposed = false;
  bool _manuallyClosed = false;
  int _retryAttempt = 0;

  Stream<InboxEvent> get events => _eventsController.stream;
  Stream<InboxConnectionStatus> get status => _statusController.stream;

  Future<void> connect() async {
    _manuallyClosed = false;
    _disposed = false;
    await _openSocket(isReconnect: _retryAttempt > 0);
  }

  Future<void> dispose() async {
    _disposed = true;
    _manuallyClosed = true;
    _reconnectTimer?.cancel();
    _ackTimer?.cancel();
    await _subscription?.cancel();
    await _channel?.sink.close();
    await _eventsController.close();
    await _statusController.close();
  }

  Future<void> _openSocket({required bool isReconnect}) async {
    if (_disposed) return;
    _emitStatus(
      isReconnect
          ? InboxConnectionStatus.reconnecting
          : InboxConnectionStatus.connecting,
    );

    try {
      await _graphqlRepository.ensureFreshToken();
      final token = _tokenStorage.currentAccessToken;
      if (token == null || token.isEmpty) {
        _emitStatus(InboxConnectionStatus.error);
        return;
      }

      await _subscription?.cancel();
      await _channel?.sink.close();
      _channel = WebSocketChannel.connect(
        Uri.parse(endpoint),
        protocols: const ['graphql-transport-ws'],
      );
      _subscription = _channel!.stream.listen(
        _handleSocketMessage,
        onDone: _handleSocketDone,
        onError: (_) => _handleSocketDone(),
      );
      _startAckTimer();
      _send({
        'type': 'connection_init',
        'payload': {'Authorization': 'Bearer $token'},
      });
    } catch (_) {
      _emitStatus(InboxConnectionStatus.error);
      _scheduleReconnect();
    }
  }

  void _handleSocketMessage(dynamic rawMessage) {
    if (rawMessage is! String) return;
    final Object? decoded;
    try {
      decoded = jsonDecode(rawMessage);
    } catch (_) {
      return;
    }
    if (decoded is! Map<String, dynamic>) return;
    final type = decoded['type']?.toString();

    switch (type) {
      case 'connection_ack':
        _ackTimer?.cancel();
        _retryAttempt = 0;
        _emitStatus(InboxConnectionStatus.connected);
        _send({
          'id': '1',
          'type': 'subscribe',
          'payload': {'query': _inboxSubscriptionQuery},
        });
        break;
      case 'next':
        final payload = decoded['payload'];
        final data = payload is Map<String, dynamic> ? payload['data'] : null;
        final inbox = data is Map<String, dynamic> ? data['inbox'] : null;
        if (inbox is Map<String, dynamic>) {
          _eventsController.add(InboxEvent.fromJson(inbox));
        }
        break;
      case 'ping':
        _send({'type': 'pong'});
        break;
      case 'error':
      case 'connection_error':
        _emitStatus(InboxConnectionStatus.error);
        _scheduleReconnect();
        break;
      case 'complete':
        _emitStatus(InboxConnectionStatus.reconnecting);
        _scheduleReconnect();
        break;
    }
  }

  void _handleSocketDone() {
    if (_disposed || _manuallyClosed) {
      _emitStatus(InboxConnectionStatus.disconnected);
      return;
    }
    _ackTimer?.cancel();
    _emitStatus(InboxConnectionStatus.reconnecting);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || _manuallyClosed) return;
    _reconnectTimer?.cancel();
    _retryAttempt += 1;
    final seconds = _retryAttempt.clamp(1, 8).toInt();
    _reconnectTimer = Timer(Duration(seconds: seconds), () {
      _openSocket(isReconnect: true);
    });
  }

  void _startAckTimer() {
    _ackTimer?.cancel();
    _ackTimer = Timer(const Duration(seconds: 10), () {
      if (_disposed || _manuallyClosed) return;
      _emitStatus(InboxConnectionStatus.reconnecting);
      _scheduleReconnect();
    });
  }

  void _send(Map<String, dynamic> message) {
    _channel?.sink.add(jsonEncode(message));
  }

  void _emitStatus(InboxConnectionStatus status) {
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }
}

const String _inboxSubscriptionQuery = r'''
subscription Inbox {
  inbox {
    __typename
    ... on NewMessageEvent {
      message {
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
    ... on MessageDeletedEvent {
      messageID
      chatID
    }
    ... on UserActivityEvent {
      userID
      isOnline
      currentTaskName
    }
  }
}
''';
