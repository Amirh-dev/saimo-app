import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel connectAuthenticatedWebSocket({
  required Uri uri,
  required String authorization,
  required Iterable<String> protocols,
}) {
  return IOWebSocketChannel.connect(
    uri,
    protocols: protocols,
    headers: {'Authorization': authorization},
  );
}
