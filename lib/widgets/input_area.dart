import 'package:flutter/material.dart';

class InputArea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const InputArea({super.key, required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Escribe cómo te sientes...",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.pinkAccent),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
