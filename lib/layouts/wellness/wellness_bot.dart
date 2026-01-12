import 'package:flutter/material.dart';

class WellnessChatPage extends StatefulWidget {
  const WellnessChatPage({super.key});

  @override
  State<WellnessChatPage> createState() => _WellnessChatPageState();
}

class _WellnessChatPageState extends State<WellnessChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isThinking = false;

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _controller.clear();
      _isThinking = true;
    });

    // Fake AI reply for demo — replace with real API later.
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _messages.add({
          'role': 'bot',
          'text':
              "I hear you 💜. It sounds like you’re processing a lot today. Want to tell me more about what’s on your mind?",
        });
        _isThinking = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0F1431);
    const bg2 = Color(0xFF181C3A);
    const accent = Color(0xFFB787FF);
    const userBubble = Color(0xFF2FE0C7);
    const aiBubble = Color(0xFF1E2248);
    const muted = Color(0xFFB7C0E0);
    const text = Color(0xFFE9ECFF);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Talk to Our Wellness Bot 💬",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: text,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [bg2, bg],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
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
                      return _buildTypingIndicator();
                    }
                    final message = _messages[index];
                    final isUser = message['role'] == 'user';
                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? userBubble : aiBubble,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: isUser
                                ? const Radius.circular(18)
                                : const Radius.circular(4),
                            bottomRight: isUser
                                ? const Radius.circular(4)
                                : const Radius.circular(18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isUser ? userBubble : accent).withOpacity(
                                0.2,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          message['text'] ?? '',
                          style: TextStyle(
                            color: isUser ? bg : text,
                            fontSize: 15,
                            height: 1.4,
                            fontWeight: isUser
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Input field
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2248),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2C315C)),
                ),
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: text),
                        decoration: const InputDecoration(
                          hintText: "Share your thoughts...",
                          hintStyle: TextStyle(color: muted),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: accent),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: const [
        SizedBox(width: 12),
        Text(
          "AetherWell is thinking",
          style: TextStyle(color: Color(0xFFB7C0E0)),
        ),
        SizedBox(width: 8),
        _Dot(),
        _Dot(delay: 200),
        _Dot(delay: 400),
      ],
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({this.delay = 0, super.key});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => Opacity(
        opacity: _animation.value,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            "•",
            style: TextStyle(color: Color(0xFFB787FF), fontSize: 22),
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
