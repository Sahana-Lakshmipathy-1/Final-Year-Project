import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class WellnessChatPage extends StatefulWidget {
  const WellnessChatPage({super.key});

  @override
  State<WellnessChatPage> createState() => _WellnessChatPageState();
}

class _WellnessChatPageState extends State<WellnessChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isThinking = false;

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage.user(text));
      _controller.clear();
      _isThinking = true;
    });

    // Simulated AI response (replace later)
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _messages.add(
          _ChatMessage.bot(
            "I’m here with you 💜\n\nIt sounds like you’re carrying a lot today. "
            "Do you want to talk about what’s been weighing on you?",
          ),
        );
        _isThinking = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Wellness Coach",
          style: AppTheme.h2,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _messages.length + (_isThinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isThinking && index == _messages.length) {
                    return const _TypingIndicator();
                  }

                  final msg = _messages[index];
                  return _ChatBubble(message: msg);
                },
              ),
            ),

            /// INPUT BAR
            Container(
              margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: AppTheme.radiusLarge,
                border: Border.all(color: AppTheme.borderSoft),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: AppTheme.body,
                      decoration: InputDecoration(
                        hintText: "Share what’s on your mind…",
                        hintStyle: AppTheme.caption,
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: AppTheme.primary,
                    ),
                    onPressed: _sendMessage,
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
/*                               CHAT MODELS                                  */
/* -------------------------------------------------------------------------- */

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage._(this.text, this.isUser);

  factory _ChatMessage.user(String text) => _ChatMessage._(text, true);
  factory _ChatMessage.bot(String text) => _ChatMessage._(text, false);
}

/* -------------------------------------------------------------------------- */
/*                               CHAT BUBBLE                                  */
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? AppTheme.primary.withOpacity(0.9)
              : AppTheme.cardBgAlt,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isUser
                ? const Radius.circular(18)
                : const Radius.circular(6),
            bottomRight: isUser
                ? const Radius.circular(6)
                : const Radius.circular(18),
          ),
        ),
        child: Text(
          message.text,
          style: AppTheme.body.copyWith(
            color: isUser ? AppTheme.bg : AppTheme.textWhite,
            height: 1.4,
            fontWeight: isUser ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                             TYPING INDICATOR                               */
/* -------------------------------------------------------------------------- */

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Text(
            "Wellness Coach is thinking",
            style: AppTheme.caption,
          ),
          const SizedBox(width: 8),
          _Dot(),
          _Dot(delay: 200),
          _Dot(delay: 400),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({this.delay = 0});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          "•",
          style: TextStyle(
            color: AppTheme.primary,
            fontSize: 22,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
