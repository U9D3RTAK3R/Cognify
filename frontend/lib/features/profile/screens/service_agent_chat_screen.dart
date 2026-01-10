import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class ChatAgentMessage {
  final String text;
  final bool isAgent;
  final DateTime timestamp;

  ChatAgentMessage({
    required this.text,
    required this.isAgent,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ServiceAgentChatNotifier extends Notifier<List<ChatAgentMessage>> {
  @override
  List<ChatAgentMessage> build() {
    return [
      ChatAgentMessage(
        text: "Hello! I'm Sarah, your support agent. How can I help you today?",
        isAgent: true,
      ),
    ];
  }

  bool isTyping = false;

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    state = [...state, ChatAgentMessage(text: text, isAgent: false)];
    _generateAgentResponse(text);
  }

  Future<void> _generateAgentResponse(String userMessage) async {
    isTyping = true;
    ref.notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    final responses = [
      "I understand your concern. Let me look into that for you.",
      "That's a great question! Here's what you need to know...",
      "I can definitely help you with that. One moment please.",
      "Thank you for reaching out. I'll resolve this for you right away.",
      "I see. Let me check our system and get back to you.",
      "No worries! This is a common issue. Here's the solution...",
    ];

    final response = responses[DateTime.now().millisecond % responses.length];
    state = [...state, ChatAgentMessage(text: response, isAgent: true)];
    isTyping = false;
    ref.notifyListeners();
  }
}

final serviceAgentChatProvider =
    NotifierProvider<ServiceAgentChatNotifier, List<ChatAgentMessage>>(
      ServiceAgentChatNotifier.new,
    );

class ServiceAgentChatScreen extends ConsumerStatefulWidget {
  const ServiceAgentChatScreen({super.key});

  @override
  ConsumerState<ServiceAgentChatScreen> createState() =>
      _ServiceAgentChatScreenState();
}

class _ServiceAgentChatScreenState
    extends ConsumerState<ServiceAgentChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    final messages = ref.watch(serviceAgentChatProvider);
    final notifier = ref.read(serviceAgentChatProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.teal],
                ),
              ),
              child: const Center(
                child: Text('👩‍💼', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sarah', style: AppTheme.bodyLarge),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      notifier.isTyping ? 'Typing...' : 'Online',
                      style: TextStyle(
                        color: notifier.isTyping
                            ? AppTheme.primaryCyan
                            : Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (notifier.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && notifier.isTyping) {
                  return _buildTypingIndicator();
                }
                final msg = messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: AppTheme.textGrey),
                      filled: true,
                      fillColor: AppTheme.bgBlack,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (text) {
                      notifier.sendMessage(text);
                      _controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    notifier.sendMessage(_controller.text);
                    _controller.clear();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatAgentMessage msg) {
    return Align(
      alignment: msg.isAgent ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: msg.isAgent ? AppTheme.cardColor : Colors.green.shade700,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(msg.isAgent ? 4 : 20),
            bottomRight: Radius.circular(msg.isAgent ? 20 : 4),
          ),
          border: msg.isAgent
              ? Border.all(color: Colors.green.withOpacity(0.3))
              : null,
        ),
        child: Text(msg.text, style: const TextStyle(color: Colors.white)),
      ),
    ).animate().fadeIn().slideX(begin: msg.isAgent ? -0.1 : 0.1, end: 0);
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(3, (i) {
              return Container(
                    margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .fadeIn(delay: (i * 200).ms)
                  .fadeOut(delay: 400.ms);
            }),
          ],
        ),
      ),
    );
  }
}
