import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/services/api_service.dart';
import 'package:lumora/services/chat_service.dart';

class FirstAidChatPage extends StatefulWidget {
  const FirstAidChatPage({super.key});

  @override
  State<FirstAidChatPage> createState() => _FirstAidChatPageState();
}

class _FirstAidChatPageState extends State<FirstAidChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final ApiService _api = ApiService();

  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _connectSocket();

    // Initial bot message with "connecting" status
    _messages.add(
      _ChatMessage.bot(
        "Hello! I'm your First Aid Assistant. Connecting to secure server...",
      ),
    );
  }

  /// Establishes the WebSocket connection and starts listening
  void _connectSocket() {
    _chatService.connect();
    _chatService.messages.listen(
      (rawData) => _handleIncomingStream(rawData),
      onError: (err) => print("📡 Socket Error: $err"),
      onDone: () => print("📡 Socket Closed"),
    );
  }

  /// Manages the incoming data stream from the WebSocket
  void _handleIncomingStream(dynamic rawData) {
    print("📥 RAW: $rawData");
    try {
      final data = jsonDecode(rawData);

      // 1. CAPTURE THE HANDSHAKE ID (connection_id)
      if (data.containsKey('connection_id')) {
        setState(() {
          _chatService.connectionId = data['connection_id'];
          // Update initial message to let user know we're ready
          if (_messages.isNotEmpty) {
            _messages[0].text =
                "Hello! I'm ready to help. Describe the situation or tap a quick prompt below.";
          }
        });
        return;
      }

      // 2. HANDLE STREAMING TEXT CHUNKS
      final String chunk = data['text'] ?? data['chunk'] ?? "";
      if (chunk.isEmpty) return;

      setState(() {
        _isTyping = false;
        // If the last message is from the bot, append the new chunk
        if (_messages.isNotEmpty && !_messages.last.isUser) {
          _messages.last.text += chunk;
        } else {
          _messages.add(_ChatMessage.bot(chunk));
        }
      });
      _scrollToBottom();
    } catch (e) {
      print("❌ Parse Error: $e");
    }
  }

  /// Sends the message via REST API and triggers the WebSocket stream
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _chatService.connectionId == null) return;

    setState(() {
      _messages.add(_ChatMessage.user(text));
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      // ✅ Hybrid Trigger: POST via HTTP, response comes back via WebSocket
      await _api.askBotQuestion(
        question: text,
        connectionId: _chatService.connectionId!,
        botType: "first_aid",
      );
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add(
          _ChatMessage.bot(
            "⚠️ Sorry, I couldn't reach the server. Please check your internet connection.",
          ),
        );
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    // 🔌 Disconnects the WebSocket automatically when switching pages
    _chatService.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isReady = _chatService.connectionId != null;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("First Aid Assistant", style: AppTheme.h2),
        iconTheme: const IconThemeData(color: AppTheme.primary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// 1. CHAT MESSAGE LIST
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == _messages.length) {
                    return const _TypingIndicator();
                  }
                  return _ChatBubble(message: _messages[index]);
                },
              ),
            ),

            /// 2. QUICK PROMPT CHIPS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  children:
                      [
                            "Bleeding",
                            "Burn",
                            "Choking",
                            "Faint",
                            "Bite / Sting",
                          ]
                          .map(
                            (label) => _QuickChip(
                              label,
                              onTap: isReady
                                  ? () => _sendMessage(label)
                                  : () {},
                            ),
                          )
                          .toList(),
                ),
              ),
            ),

            /// 3. INPUT BAR
            Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: AppTheme.radiusLarge,
                border: Border.all(
                  color: isReady
                      ? AppTheme.primary.withOpacity(0.4)
                      : AppTheme.borderSoft,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: isReady,
                      style: AppTheme.body,
                      decoration: InputDecoration(
                        hintText: isReady
                            ? "Describe the injury..."
                            : "Connecting...",
                        hintStyle: AppTheme.caption,
                        border: InputBorder.none,
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  if (!isReady)
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      LucideIcons.send,
                      color: isReady ? AppTheme.primary : Colors.grey,
                    ),
                    onPressed: isReady
                        ? () => _sendMessage(_controller.text)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* SUB-COMPONENTS                                                             */
/* -------------------------------------------------------------------------- */

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : AppTheme.cardBgAlt,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser
                ? const Radius.circular(0)
                : const Radius.circular(16),
            bottomLeft: isUser
                ? const Radius.circular(16)
                : const Radius.circular(0),
          ),
        ),
        child: MarkdownBody(
          data: message.text,
          styleSheet: MarkdownStyleSheet(
            p: AppTheme.body.copyWith(
              color: isUser ? AppTheme.bg : Colors.white,
              height: 1.4,
            ),
            listBullet: TextStyle(
              color: isUser ? AppTheme.bg : AppTheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip(this.label, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: AppTheme.caption),
      backgroundColor: AppTheme.cardBgAlt,
      side: const BorderSide(color: AppTheme.borderSoft),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: onTap,
    );
  }
}

class _ChatMessage {
  String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
  factory _ChatMessage.user(String text) =>
      _ChatMessage(text: text, isUser: true);
  factory _ChatMessage.bot(String text) =>
      _ChatMessage(text: text, isUser: false);
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(12),
    child: Text(
      "Assistant is thinking...",
      style: TextStyle(color: Colors.grey, fontSize: 12),
    ),
  );
}
