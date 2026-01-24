import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/services/api_service.dart';
import 'package:lumora/services/chat_service.dart';

class WellnessChatPage extends StatefulWidget {
  const WellnessChatPage({super.key});

  @override
  State<WellnessChatPage> createState() => _WellnessChatPageState();
}

class _WellnessChatPageState extends State<WellnessChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Services
  final ChatService _chatService = ChatService();
  final ApiService _api = ApiService();

  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _connectSocket();

    // Initial Warm Welcome
    _messages.add(
      _ChatMessage.bot(
        "Hi there. I'm your Wellness Companion. 💜\n\n"
        "I'm here to listen and support you. How are you feeling in this moment?",
      ),
    );
  }

  void _connectSocket() {
    _chatService.connect();
    _chatService.messages.listen(
      (rawData) => _handleIncomingStream(rawData),
      onError: (err) => print("📡 Wellness Socket Error: $err"),
      onDone: () => print("📡 Wellness Socket Closed"),
    );
  }

  void _handleIncomingStream(dynamic rawData) {
    try {
      final data = jsonDecode(rawData);

      // 🔑 Capture the connection_id for the HTTP trigger
      if (data.containsKey('connection_id')) {
        setState(() {
          _chatService.connectionId = data['connection_id'];
        });
        return;
      }

      // 📝 Handle streaming text chunks
      final String chunk = data['text'] ?? data['chunk'] ?? "";
      if (chunk.isEmpty) return;

      setState(() {
        _isTyping = false;
        // Append to last bot message if it exists, otherwise create new one
        if (_messages.isNotEmpty && !_messages.last.isUser) {
          _messages.last.text += chunk;
        } else {
          _messages.add(_ChatMessage.bot(chunk));
        }
      });
      _scrollToBottom();
    } catch (e) {
      print("❌ Wellness Parse Error: $e");
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _chatService.connectionId == null) return;

    setState(() {
      _messages.add(_ChatMessage.user(text));
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      // ✅ Trigger AI via HTTP POST with the 'wellness' bot_type
      await _api.askBotQuestion(
        question: text,
        connectionId: _chatService.connectionId!,
        botType: "wellness",
      );
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add(
          _ChatMessage.bot(
            "⚠️ I'm having a little trouble connecting. Could you try sharing that again?",
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
    // 🔌 Cleanly disconnects WebSocket when switching pages
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
        title: Text("Wellness Companion", style: AppTheme.h2),
        iconTheme: const IconThemeData(color: AppTheme.primary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// 1. CHAT MESSAGES
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

            /// 2. WELLNESS PROMPT CHIPS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                            "Feeling Anxious",
                            "Daily Vent",
                            "Stress Relief",
                            "Sleep Help",
                            "Affirmations",
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
                            ? "Share your thoughts..."
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
/* UI SUB-COMPONENTS                                                          */
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
      "Companion is thinking...",
      style: TextStyle(color: Colors.grey, fontSize: 12),
    ),
  );
}
