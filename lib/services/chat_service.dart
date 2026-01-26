import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatService {
  WebSocketChannel? _channel;
  final String _url = dotenv.env['WEBSOCKET_URL'] ?? "";

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
