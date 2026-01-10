import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatController extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() {
    return [
      ChatMessage(
        text:
            "Greetings, seeker of knowledge. I am the Oracle, your AI guide through the realm of learning. Ask me anything!",
        isUser: false,
      ),
    ];
  }

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    state = [...state, ChatMessage(text: text, isUser: true)];
    _isTyping = true;
    ref.notifyListeners();

    // Simulate AI response with delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      _isTyping = false;
      final responses = [
        "Interesting question! Let me enlighten you...",
        "The ancient scrolls speak of this...",
        "Ah, a curious mind! Here's what I know...",
        "Your pursuit of knowledge is admirable. Consider this...",
        "The Oracle sees great potential in you. The answer lies within...",
      ];
      final response = responses[(state.length) % responses.length];
      state = [...state, ChatMessage(text: response, isUser: false)];
    });
  }
}

final chatProvider = NotifierProvider<ChatController, List<ChatMessage>>(
  ChatController.new,
);

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestions = [
    "Explain Flutter widgets",
    "Quiz me on Dart",
    "Tips for learning faster",
    "What is state management?",
  ];

  void _sendMessage(String text) {
    ref.read(chatProvider.notifier).sendMessage(text);
    _controller.clear();
    _scrollToBottom();
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
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    final controller = ref.read(chatProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.accentPurple.withOpacity(0.3),
                              AppTheme.primaryCyan.withOpacity(0.3),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.accentPurple.withOpacity(0.5),
                          ),
                        ),
                        child: const Text("🔮", style: TextStyle(fontSize: 24)),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .shimmer(duration: 2.seconds),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("AI Oracle", style: AppTheme.headlineMedium),
                        Text(
                          controller.isTyping
                              ? "Typing..."
                              : "Online • Ready to assist",
                          style: TextStyle(
                            color: controller.isTyping
                                ? AppTheme.primaryCyan
                                : AppTheme.textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.go('/dashboard'),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryCyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.home_rounded,
                        color: AppTheme.primaryCyan,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.2, end: 0),

            // Quick Suggestions
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return GestureDetector(
                        onTap: () => _sendMessage(_suggestions[index]),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentPurple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.accentPurple.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            _suggestions[index],
                            style: TextStyle(
                              color: AppTheme.accentPurple,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: (100 * index).ms)
                      .slideX(begin: 0.2, end: 0);
                },
              ),
            ),

            const SizedBox(height: 16),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: messages.length + (controller.isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length && controller.isTyping) {
                    return _buildTypingIndicator();
                  }
                  final message = messages[index];
                  return _buildMessageBubble(message, index);
                },
              ),
            ),

            // Input Area
            GlassContainer(
              height: 80,
              width: double.infinity,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              borderColor: Colors.white.withOpacity(0.1),
              blur: 20,
              frostedOpacity: 0.1,
              color: AppTheme.cardColor.withOpacity(0.8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Ask the Oracle...",
                          hintStyle: TextStyle(color: AppTheme.textGrey),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _sendMessage(_controller.text),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primaryCyan,
                              AppTheme.accentPurple,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ).animate().scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isUser = message.isUser;
    return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              gradient: isUser
                  ? const LinearGradient(
                      colors: [AppTheme.primaryCyan, Color(0xFF00A893)],
                    )
                  : LinearGradient(
                      colors: [
                        AppTheme.accentPurple.withOpacity(0.3),
                        AppTheme.cardColor,
                      ],
                    ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                bottomRight: isUser ? Radius.zero : const Radius.circular(16),
              ),
              border: isUser
                  ? null
                  : Border.all(color: AppTheme.accentPurple.withOpacity(0.3)),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: isUser ? 0.1 : -0.1, end: 0);
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: AppTheme.accentPurple.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _typingDot(0),
            const SizedBox(width: 4),
            _typingDot(100),
            const SizedBox(width: 4),
            _typingDot(200),
          ],
        ),
      ),
    );
  }

  Widget _typingDot(int delayMs) {
    return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.accentPurple,
            shape: BoxShape.circle,
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(delay: delayMs.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
          duration: 400.ms,
        );
  }
}
