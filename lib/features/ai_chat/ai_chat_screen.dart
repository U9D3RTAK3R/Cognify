import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatController extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() {
    return [ChatMessage(text: "Hello! I am the Oracle.", isUser: false)];
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    state = [...state, ChatMessage(text: text, isUser: true)];
    Future.delayed(const Duration(seconds: 1), () {
      state = [...state, ChatMessage(text: "I sense great potential.", isUser: false)];
    });
  }
}

final chatProvider = NotifierProvider<ChatController, List<ChatMessage>>(ChatController.new);

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        title: Text("AI Oracle", style: AppTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? AppTheme.primaryCyan.withOpacity(0.2)
                          : Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(message.text, style: AppTheme.bodyMedium),
                  ),
                ).animate().fadeIn(duration: 300.ms);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.cardColor,
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
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (value) {
                      ref.read(chatProvider.notifier).sendMessage(value);
                      _controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.primaryCyan),
                  onPressed: () {
                    ref.read(chatProvider.notifier).sendMessage(_controller.text);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
