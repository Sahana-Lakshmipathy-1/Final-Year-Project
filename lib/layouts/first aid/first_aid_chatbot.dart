import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:lumora/theme/app_theme.dart';

class FirstAidChatPage extends StatefulWidget {
  const FirstAidChatPage({super.key});

  @override
  State<FirstAidChatPage> createState() => _FirstAidChatPageState();
}

class _FirstAidChatPageState extends State<FirstAidChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();

    // Initial bot message
    _messages.add(
      _ChatMessage.bot(
        "I can help with basic first aid steps.\n\n"
        "Tell me what happened, or choose a category below.\n\n"
        "⚠️ This does not replace professional medical care.",
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage.user(text));
      _isTyping = true;
    });

    _controller.clear();

    // Simulated response (AI later)
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _messages.add(
          _ChatMessage.bot(
            "Thanks for sharing.\n\n"
            "Here are some general first-aid steps:\n"
            "• Stay calm\n"
            "• Remove yourself from danger\n"
            "• Apply basic care if safe\n\n"
            "If symptoms worsen, seek medical help immediately.",
          ),
        );
        _isTyping = false;
      });
    });
  }

  void _quickPrompt(String label) {
    _sendMessage(label);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("First Aid Assistant", style: AppTheme.h2),
        iconTheme: IconThemeData(color: AppTheme.primary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// ------------------------------------------------------------
            /// CHAT
            /// ------------------------------------------------------------
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == _messages.length) {
                    return const _TypingIndicator();
                  }
                  return _ChatBubble(message: _messages[index]);
                },
              ),
            ),

            /// ------------------------------------------------------------
            /// QUICK PROMPTS
            /// ------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuickChip("Cut / Bleeding"),
                  _QuickChip("Burn"),
                  _QuickChip("Sprain"),
                  _QuickChip("Bite / Sting"),
                  _QuickChip("Poisoning"),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// ------------------------------------------------------------
            /// INPUT BAR
            /// ------------------------------------------------------------
            Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
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
                        hintText: "Describe the situation…",
                        hintStyle: AppTheme.caption,
                        border: InputBorder.none,
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      LucideIcons.send,
                      color: AppTheme.primary,
                    ),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ],
              ),
            ),

            /// ------------------------------------------------------------
            /// EMERGENCY CTA
            /// ------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(LucideIcons.phoneCall),
                  label: const Text("Call Emergency Contact"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                    foregroundColor: AppTheme.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusMedium,
                    ),
                  ),
                  onPressed: () {
                    // TODO: Call saved emergency contact
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                              CHAT MODELS                                   */
/* -------------------------------------------------------------------------- */

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage._(this.text, this.isUser);

  factory _ChatMessage.user(String text) => _ChatMessage._(text, true);
  factory _ChatMessage.bot(String text) => _ChatMessage._(text, false);
}

/* -------------------------------------------------------------------------- */
/*                              CHAT BUBBLE                                   */
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
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : AppTheme.cardBgAlt,
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
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                             QUICK CHIPS                                    */
/* -------------------------------------------------------------------------- */

class _QuickChip extends StatelessWidget {
  final String label;
  const _QuickChip(this.label);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context
          .findAncestorStateOfType<_FirstAidChatPageState>()
          ?._quickPrompt(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardBgAlt,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.borderSoft),
        ),
        child: Text(label, style: AppTheme.caption),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                          TYPING INDICATOR                                   */
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
          Text("First Aid Assistant is typing", style: AppTheme.caption),
          const SizedBox(width: 8),
          Text("• • •", style: AppTheme.caption),
        ],
      ),
    );
  }
}
