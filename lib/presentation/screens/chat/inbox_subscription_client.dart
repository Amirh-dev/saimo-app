import 'dart:async';
import 'dart:convert';

import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_endpoints.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'chat_models.dart';
import 'chat_repository.dart';
import 'websocket_channel_connector.dart';

const String _legacyGraphQLWsProtocol = 'graphql-ws';
const String _transportGraphQLWsProtocol = 'graphql-transport-ws';
const String _inboxSubscriptionID = 'inbox';

InboxEvent? inboxEventFromGraphQLSocketMessage(Object? rawMessage) {
  if (rawMessage is! String) return null;
  final decoded = _decodeJsonObject(rawMessage);
  if (decoded == null) return null;

  final type = decoded['type']?.toString();
  if (type != 'next' && type != 'data') return null;

  final payload = decoded['payload'];
  return _inboxEventFromPayload(payload);
}

class InboxSubscriptionClient {
  InboxSubscriptionClient({
    required GraphQLRepository graphqlRepository,
    required TokenStorage tokenStorage,
    this.endpoint = GraphQLEndpoints.websocket,
  })  : _graphqlRepository = graphqlRepository,
        _chatRepository = ChatRepository(graphqlRepository),
        _tokenStorage = tokenStorage;

  final GraphQLRepository _graphqlRepository;
  final ChatRepository _chatRepository;
  final TokenStorage _tokenStorage;
  final String endpoint;
  final _eventsController = StreamController<InboxEvent>.broadcast();
  final _statusController = StreamController<InboxConnectionStatus>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  Timer? _ackTimer;
  Future<void>? _connectFuture;
  bool _disposed = false;
  bool _manuallyClosed = false;
  int _retryAttempt = 0;
  var _currentStatus = InboxConnectionStatus.idle;
  String? _activeProtocol;

  Stream<InboxEvent> get events => _eventsController.stream;
  Stream<InboxConnectionStatus> get status => _statusController.stream;
  InboxConnectionStatus get currentStatus => _currentStatus;

  Future<void> connect({bool force = false}) {
    if (_disposed) return Future<void>.value();
    _manuallyClosed = false;
    _disposed = false;

    if (!force) {
      final pendingConnect = _connectFuture;
      if (pendingConnect != null) return pendingConnect;

      if (_currentStatus == InboxConnectionStatus.connected ||
          _currentStatus == InboxConnectionStatus.connecting) {
        return Future<void>.value();
      }

      if (_currentStatus == InboxConnectionStatus.reconnecting &&
          _reconnectTimer != null) {
        return Future<void>.value();
      }
    }

    late final Future<void> connectFuture;
    connectFuture = _openSocket(
      isReconnect: _currentStatus != InboxConnectionStatus.idle &&
          _currentStatus != InboxConnectionStatus.disconnected,
    ).whenComplete(() {
      if (_connectFuture == connectFuture) {
        _connectFuture = null;
      }
    });
    _connectFuture = connectFuture;
    return _connectFuture!;
  }

  Future<void> disconnect() async {
    _manuallyClosed = true;
    _retryAttempt = 0;
    _connectFuture = null;
    await _closeSocket(emitDisconnected: true);
  }

  Future<void> dispose() async {
    _disposed = true;
    _manuallyClosed = true;
    await _closeSocket(emitDisconnected: false);
    await _eventsController.close();
    await _statusController.close();
  }

  Future<void> _openSocket({required bool isReconnect}) async {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _emitStatus(
      isReconnect
          ? InboxConnectionStatus.reconnecting
          : InboxConnectionStatus.connecting,
    );

    try {
      await _graphqlRepository.ensureFreshToken();
      if (_disposed || _manuallyClosed) return;

      final token = _tokenStorage.currentAccessToken;
      if (token == null || token.isEmpty) {
        _emitStatus(InboxConnectionStatus.error);
        return;
      }

      await _closeSocket(emitDisconnected: false);
      if (_disposed || _manuallyClosed) return;

      final authorization = 'Bearer $token';
      final channel = connectAuthenticatedWebSocket(
        uri: Uri.parse(endpoint),
        authorization: authorization,
        protocols: const [
          _transportGraphQLWsProtocol,
          _legacyGraphQLWsProtocol,
        ],
      );
      _channel = channel;
      _subscription = channel.stream.listen(
        _handleSocketMessage,
        onDone: _handleSocketDone,
        onError: (_) => _handleSocketDone(),
      );
      await channel.ready.timeout(const Duration(seconds: 10));
      if (_disposed || _manuallyClosed || _channel != channel) {
        await channel.sink.close();
        return;
      }
      _activeProtocol = channel.protocol ?? _transportGraphQLWsProtocol;
      _startAckTimer();
      _send({
        'type': 'connection_init',
        'payload': {'Authorization': authorization},
      });
    } catch (_) {
      if (_disposed || _manuallyClosed) return;
      _emitStatus(InboxConnectionStatus.error);
      _scheduleReconnect();
    }
  }

  void _handleSocketMessage(dynamic rawMessage) {
    if (rawMessage is! String) return;
    final decoded = _decodeJsonObject(rawMessage);
    if (decoded == null) return;
    final type = decoded['type']?.toString();

    switch (type) {
      case 'connection_ack':
        _ackTimer?.cancel();
        _retryAttempt = 0;
        _emitStatus(InboxConnectionStatus.connected);
        _send(_subscribeMessage());
        break;
      case 'ka':
      case 'connection_keep_alive':
        break;
      case 'next':
      case 'data':
        final payload = decoded['payload'];
        final event = _inboxEventFromPayload(payload);
        if (event != null) {
          _emitStatus(InboxConnectionStatus.connected);
          try {
            // Keep Ferry's normalized history current even when no chat room
            // is open. Active screens receive the same event just below and
            // run it through their ID-based state upsert as well.
            _chatRepository.applyInboxEventToCache(event);
          } catch (_) {
            // A cache conversion must never interrupt the live socket stream.
          }
          if (!_eventsController.isClosed) {
            _eventsController.add(event);
          }
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
    _channel = null;
    _subscription = null;
    _activeProtocol = null;
    _ackTimer?.cancel();
    _emitStatus(InboxConnectionStatus.reconnecting);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || _manuallyClosed) return;
    _reconnectTimer?.cancel();
    _emitStatus(InboxConnectionStatus.reconnecting);
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
    try {
      _channel?.sink.add(jsonEncode(message));
    } catch (_) {
      _handleSocketDone();
    }
  }

  Map<String, dynamic> _subscribeMessage() {
    return {
      'id': _inboxSubscriptionID,
      'type': _activeProtocol == _transportGraphQLWsProtocol
          ? 'subscribe'
          : 'start',
      'payload': {'query': _inboxSubscriptionQuery},
    };
  }

  void _emitStatus(InboxConnectionStatus status) {
    _currentStatus = status;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  Future<void> _closeSocket({required bool emitDisconnected}) async {
    _reconnectTimer?.cancel();
    _ackTimer?.cancel();

    final subscription = _subscription;
    final channel = _channel;
    _subscription = null;
    _channel = null;

    await subscription?.cancel();
    await channel?.sink.close();

    if (emitDisconnected && !_disposed) {
      _emitStatus(InboxConnectionStatus.disconnected);
    }
  }
}

Map<String, dynamic>? _decodeJsonObject(String rawMessage) {
  try {
    final decoded = jsonDecode(rawMessage);
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}

InboxEvent? _inboxEventFromPayload(Object? payload) {
  final data = payload is Map<String, dynamic> ? payload['data'] : null;
  final inbox = data is Map<String, dynamic> ? data['inbox'] : null;
  if (inbox is! Map<String, dynamic>) return null;
  return InboxEvent.fromJson(inbox);
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
