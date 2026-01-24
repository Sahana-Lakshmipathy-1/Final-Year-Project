import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatService {
  WebSocketChannel? _channel;
  final String _url =
      'wss://7tjkmiv1ii.execute-api.us-east-2.amazonaws.com/production/';

  String? connectionId; // 🔑 Fresh ID

  Stream get messages => _channel!.stream;

  void connect() {
    connectionId = null; // Clear stale ID
    _channel = WebSocketChannel.connect(Uri.parse(_url));

    // Send a dummy message to trigger the $default route just in case
    _channel!.sink.add(jsonEncode({"action": "init"}));

    print("🔌 WebSocket Attempting Connection...");
  }

  void dispose() {
    _channel?.sink.close();
    connectionId = null;
  }
}
