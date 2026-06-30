import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
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

  Future<void> connect({bool force = false, String source = 'app'}) {
    _logInbox('url=${_safeWebSocketUrl(endpoint)}');
    _logInbox('connect called source=$source');
    if (_disposed) {
      _logInbox('connect ignored client_disposed');
      return Future<void>.value();
    }
    _manuallyClosed = false;
    _disposed = false;

    if (!force) {
      final pendingConnect = _connectFuture;
      if (pendingConnect != null) {
        _logInbox('connection already in progress, reusing pending socket');
        return pendingConnect;
      }

      if (_currentStatus == InboxConnectionStatus.connected) {
        _logInbox('already connected, reusing existing socket');
        return Future<void>.value();
      }

      if (_currentStatus == InboxConnectionStatus.connecting) {
        _logInbox('connection already in progress, reusing pending socket');
        return Future<void>.value();
      }

      if (_currentStatus == InboxConnectionStatus.reconnecting &&
          _reconnectTimer != null) {
        _logInbox('reconnect already scheduled, reusing existing socket');
        return Future<void>.value();
      }
    } else if (_channel != null) {
      _logInbox('force reconnect replacing active socket');
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
    if (isReconnect) _logInbox('reconnect started');
    _logInbox('connecting');
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
        _logInbox('error missing_access_token');
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
        onDone: () => _handleSocketDone(channel: channel),
        onError: (Object error) {
          _logInbox('error message=${_safeLogText(error.runtimeType)}');
          _handleSocketDone(
            channel: channel,
            fallbackReason: error.runtimeType.toString(),
          );
        },
      );
      await channel.ready.timeout(const Duration(seconds: 10));
      if (_disposed || _manuallyClosed || _channel != channel) {
        await channel.sink.close();
        return;
      }
      _activeProtocol = channel.protocol ?? _transportGraphQLWsProtocol;
      _logInbox('connected protocol=$_activeProtocol');
      _startAckTimer();
      _logInbox('sending connection_init hasAuth=true');
      _send({
        'type': 'connection_init',
        'payload': {'Authorization': authorization},
      });
    } catch (error) {
      if (_disposed || _manuallyClosed) return;
      _logInbox('error message=${_safeLogText(error.runtimeType)}');
      _emitStatus(InboxConnectionStatus.error);
      _scheduleReconnect();
    }
  }

  void _handleSocketMessage(dynamic rawMessage) {
    if (rawMessage is! String) {
      _logInbox('error message=non_string_frame');
      return;
    }
    final decoded = _decodeJsonObject(rawMessage);
    if (decoded == null) {
      _logInbox('error message=invalid_json_frame');
      return;
    }
    final type = decoded['type']?.toString();
    _logInbox('raw frame type=${type ?? 'null'}');

    switch (type) {
      case 'connection_ack':
        _logInbox('received connection_ack');
        _ackTimer?.cancel();
        _retryAttempt = 0;
        _emitStatus(InboxConnectionStatus.connected);
        _logInbox('sending subscribe operation=Inbox');
        if (_send(_subscribeMessage())) {
          _logInbox('subscribed operation=Inbox');
        }
        break;
      case 'ka':
      case 'connection_keep_alive':
        break;
      case 'next':
      case 'data':
        final payload = decoded['payload'];
        final event = _inboxEventFromPayload(payload);
        _logInbox('raw event typename=${event?.typename ?? 'null'}');
        if (event != null) {
          _emitStatus(InboxConnectionStatus.connected);
          try {
            // Keep Ferry's normalized history current even when no chat room
            // is open. Active screens receive the same event just below and
            // run it through their ID-based state upsert as well.
            _chatRepository.applyInboxEventToCache(event);
          } catch (error) {
            _logInbox(
              'error message=cache_update_${_safeLogText(error.runtimeType)}',
            );
            // A cache conversion must never interrupt the live socket stream.
          }
          if (!_eventsController.isClosed) {
            _eventsController.add(event);
          }
        } else {
          final errorMessage = _payloadErrorMessage(payload);
          if (errorMessage != null) {
            _logInbox('error message=$errorMessage');
          }
        }
        break;
      case 'ping':
        _send({'type': 'pong'});
        break;
      case 'pong':
        break;
      case 'error':
      case 'connection_error':
        _logInbox(
          'error message=${_payloadErrorMessage(decoded['payload']) ?? type}',
        );
        _emitStatus(InboxConnectionStatus.error);
        _scheduleReconnect();
        break;
      case 'complete':
        _logInbox('subscription complete operation=Inbox');
        _emitStatus(InboxConnectionStatus.reconnecting);
        _scheduleReconnect();
        break;
    }
  }

  void _handleSocketDone({
    WebSocketChannel? channel,
    String? fallbackReason,
  }) {
    final closedChannel = channel ?? _channel;
    final code = closedChannel?.closeCode;
    final reason = closedChannel?.closeReason ?? fallbackReason ?? 'unknown';
    _logInbox(
      'closed code=${code ?? 'null'} reason=${_safeLogText(reason)}',
    );
    if (channel != null && !identical(_channel, channel)) {
      _logInbox('stale socket close ignored');
      return;
    }
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
    _logInbox('reconnect scheduled delaySeconds=$seconds');
    _reconnectTimer = Timer(Duration(seconds: seconds), () {
      _openSocket(isReconnect: true);
    });
  }

  void _startAckTimer() {
    _ackTimer?.cancel();
    _ackTimer = Timer(const Duration(seconds: 10), () {
      if (_disposed || _manuallyClosed) return;
      _logInbox('error message=connection_ack_timeout');
      _emitStatus(InboxConnectionStatus.reconnecting);
      _scheduleReconnect();
    });
  }

  bool _send(Map<String, dynamic> message) {
    if (_channel == null) {
      _logInbox('error message=send_without_active_socket');
      return false;
    }
    try {
      _channel!.sink.add(jsonEncode(message));
      return true;
    } catch (error) {
      _logInbox('error message=${_safeLogText(error.runtimeType)}');
      _handleSocketDone(fallbackReason: error.runtimeType.toString());
      return false;
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
    if (channel != null) {
      _logInbox(
        'closed code=${channel.closeCode ?? 'null'} reason=client_close',
      );
    }

    if (emitDisconnected && !_disposed) {
      _emitStatus(InboxConnectionStatus.disconnected);
    }
  }
}

void _logInbox(String message) {
  if (kDebugMode) debugPrint('[InboxWS] $message');
}

String _safeWebSocketUrl(String endpoint) {
  final uri = Uri.tryParse(endpoint);
  if (uri == null || uri.host.isEmpty) return 'invalid';
  final port = uri.hasPort ? ':${uri.port}' : '';
  return '${uri.scheme}://${uri.host}$port${uri.path}';
}

String _safeLogText(Object? value) {
  final text = value?.toString().replaceAll(RegExp(r'[\r\n]+'), ' ') ?? 'null';
  final withoutBearer = text.replaceAll(
    RegExp(r'Bearer\s+[^\s,}]+', caseSensitive: false),
    'Bearer ***',
  );
  return withoutBearer.length <= 160
      ? withoutBearer
      : '${withoutBearer.substring(0, 160)}…';
}

String? _payloadErrorMessage(Object? payload) {
  if (payload is Map<String, dynamic>) {
    final errors = payload['errors'];
    if (errors is List && errors.isNotEmpty) {
      final firstError = errors.first;
      if (firstError is Map) {
        return _safeLogText(firstError['message'] ?? 'graphql_error');
      }
      return _safeLogText(firstError);
    }
    if (payload['message'] != null) {
      return _safeLogText(payload['message']);
    }
  }
  if (payload is List && payload.isNotEmpty) {
    return _safeLogText(payload.first);
  }
  return null;
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
