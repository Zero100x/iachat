import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const LumaApp());
}

class LumaApp extends StatelessWidget {
  const LumaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Luma - Apoyo Emocional',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const ChatScreen(),
    );
  }
}
