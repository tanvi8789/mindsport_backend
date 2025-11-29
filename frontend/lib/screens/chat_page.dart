import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_provider.dart';
import '../models/chat_message_model.dart';
import '../main.dart'; // Import theme colors

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _handleSend() {
    if (_textController.text.trim().isEmpty) return;

    // Send message via provider
    Provider.of<ChatProvider>(context, listen: false).sendMessage(_textController.text);
    _textController.clear();

    // Scroll to bottom after a slight delay to allow the new widget to build
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when chat state changes
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      // App bar matches the rest of the app
      appBar: AppBar(
        title: const Text('Wellness Companion'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MindSportTheme.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // --- 1. THE CALM BACKGROUND ---
          CustomPaint(
            painter: _BackgroundPainter(),
            size: Size.infinite,
          ),

          // --- 2. THE CHAT CONTENT ---
          Column(
            children: [
              // Message List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: chatProvider.messages.length + (chatProvider.isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show "Typing..." indicator as the last item if active
                    if (chatProvider.isTyping && index == chatProvider.messages.length) {
                      return const _TypingIndicator();
                    }

                    final msg = chatProvider.messages[index];
                    return _ChatBubble(message: msg);
                  },
                ),
              ),

              // Input Area
              _buildInputArea(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // Slightly transparent glass effect
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Text Input
            Expanded(
              child: TextField(
                controller: _textController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: const Color(0xFFF2F0EC), // Light beige background for input
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            const SizedBox(width: 12),

            // Send Button
            GestureDetector(
              onTap: _handleSend,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: MindSportTheme.primaryGreen,
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET: Chat Bubble ---
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    // Align right for user, left for bot
    final alignment = message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    // Colors: Green for user, White/Soft Lavender for bot
    final color = message.isUser
        ? MindSportTheme.primaryGreen
        : Colors.white.withOpacity(0.85);

    final textColor = message.isUser ? Colors.white : MindSportTheme.darkText;

    // Rounded corners: "Speech bubble" effect
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: message.isUser ? const Radius.circular(20) : const Radius.circular(0),
      bottomRight: message.isUser ? const Radius.circular(0) : const Radius.circular(20),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: color,
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET: Typing Indicator ---
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const Text(
              "Typing...",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

// --- We copy the BackgroundPainter to keep the file self-contained ---
class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double blurSigma = 45.0;

    final paint1 = Paint()
      ..color = MindSportTheme.softPeach.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);

    final paint2 = Paint()
      ..color = MindSportTheme.softLavender.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);

    final paint3 = Paint()
      ..color = MindSportTheme.softGreen.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);

    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.1), 150, paint1);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.3), 200, paint2);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 180, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}