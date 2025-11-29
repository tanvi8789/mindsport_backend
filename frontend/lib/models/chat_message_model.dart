class ChatMessage {
  final String text;
  final bool isUser; // true if sent by user, false if bot
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}