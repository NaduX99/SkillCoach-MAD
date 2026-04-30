import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/widgets/aesthetic_background.dart';
import '../../../../core/models/chat_message.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
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
    final chatState = ref.watch(chatProvider);
    final messages = chatState.messages;
    final isTyping = chatState.isTyping;

    return Scaffold(
      body: AestheticBackground(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length) {
                    return _buildTypingIndicator();
                  }
                  return _ChatBubble(message: messages[index]);
                },
              ),
            ),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 20, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF312E81).withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(PhosphorIcons.robot(PhosphorIconsStyle.fill), color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LIVE AI COACH',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E1B4B),
                  letterSpacing: 1.5,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'SYSTEM ONLINE',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => ref.read(chatProvider.notifier).clearHistory(),
            icon: Icon(PhosphorIcons.trash(), color: const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _controller,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Ask your AI Coach...',
                  hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8)),
                  border: InputBorder.none,
                ),
                onSubmitted: (val) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF312E81).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(PhosphorIcons.paperPlaneTilt(PhosphorIconsStyle.fill), color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(chatProvider.notifier).sendMessage(text);
    _controller.clear();
    _scrollToBottom();
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF312E81).withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Analyzing...',
              style: GoogleFonts.orbitron(
                fontSize: 10,
                color: const Color(0xFF312E81),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
             CircleAvatar(
               radius: 16,
               backgroundColor: const Color(0xFF312E81),
               child: Icon(PhosphorIcons.robot(), color: Colors.white, size: 16),
             ),
             const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: message.isUser ? null : const LinearGradient(
                  colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                color: message.isUser ? const Color(0xFFF1F5F9) : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(message.isUser ? 24 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 24),
                ),
                boxShadow: message.isUser ? [] : [
                  BoxShadow(
                    color: const Color(0xFF312E81).withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: message.isUser ? const Color(0xFF1E293B) : Colors.white,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: message.isUser ? const Color(0xFF94A3B8) : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
             const SizedBox(width: 8),
             CircleAvatar(
               radius: 16,
               backgroundColor: const Color(0xFFE2E8F0),
               child: Icon(PhosphorIcons.user(), color: const Color(0xFF64748B), size: 16),
             ),
          ],
        ],
      ),
    );
  }
}
