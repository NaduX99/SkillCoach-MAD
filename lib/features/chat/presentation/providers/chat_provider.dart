import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/chat_message.dart';
import '../../../../core/services/ai_service.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;

  ChatState({required this.messages, this.isTyping = false});

  ChatState copyWith({List<ChatMessage>? messages, bool? isTyping}) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatState(
    messages: [
      ChatMessage(
        text: "HELLO LEARNER. SYSTEM ONLINE. I am your SkillCoachR AI Coach. How can I help you optimize your career roadmap today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ],
  ));

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );
    
    try {
      final response = await AIService.getChatResponse(state.messages);
      final aiMsg = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isTyping: false,
      );
    } catch (e) {
      final errMsg = ChatMessage(
        text: "Communication error: Could not connect to AI satellite. Please try again.",
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errMsg],
        isTyping: false,
      );
    }
  }

  void clearHistory() {
    state = ChatState(
      messages: [
        ChatMessage(
          text: "SESSION RESET. SYSTEM REBOOTED. How can I assist you now?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
      isTyping: false,
    );
  }
}
