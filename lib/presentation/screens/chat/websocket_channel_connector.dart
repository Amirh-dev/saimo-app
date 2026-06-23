import 'package:web_socket_channel/web_socket_channel.dart';

import 'websocket_channel_connector_stub.dart'
    if (dart.library.io) 'websocket_channel_connector_io.dart'
    if (dart.library.js_interop) 'websocket_channel_connector_web.dart'
    as connector;

WebSocketChannel connectAuthenticatedWebSocket({
  required Uri uri,
  required String authorization,
  required Iterable<String> protocols,
}) {
  return connector.connectAuthenticatedWebSocket(
    uri: uri,
    authorization: authorization,
    protocols: protocols,
  );
}
