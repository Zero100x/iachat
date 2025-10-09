import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_area.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final _controller = TextEditingController();
  final _aiService = AIService();

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _controller.clear();
    });

    final reply = await _aiService.sendMessage(text);
    setState(() {
      _messages.add({'text': reply, 'isUser': false});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text("Luma 💬 - Apoyo Emocional"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return MessageBubble(
                  text: msg['text'],
                  isUser: msg['isUser'],
                );
              },
            ),
          ),
          InputArea(controller: _controller, onSend: _sendMessage),
        ],
      ),
    );
  }
}
