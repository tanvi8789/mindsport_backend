import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';

class ChatProvider with ChangeNotifier {
  // Initial welcome message
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I'm your Mindsport companion. How are you feeling right now?",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  bool _isTyping = false;

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  // Function to send a message
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Add User Message
    _messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isTyping = true; // Show loading indicator
    notifyListeners();

    // 2. Simulate Network Delay (Mocking the API call)
    await Future.delayed(const Duration(seconds: 2));

    // 3. Add Bot Response (Mock)
    // TODO: Replace this with your actual API call later
    _messages.add(ChatMessage(
      text: "I hear you. Dealing with that can be tough. Have you tried doing a quick breathing exercise?",
      isUser: false,
      timestamp: DateTime.now(),
    ));

    _isTyping = false; // Hide loading
    notifyListeners();
  }
}