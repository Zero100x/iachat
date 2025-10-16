import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/ai_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_area.dart';
import 'login_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final _controller = TextEditingController();
  final _aiService = AIService();

  // ✅ Enviar mensaje al bot
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

  // ✅ Cerrar sesión
  Future<void> _signOut() async {
    final supabase = Supabase.instance.client;
    await supabase.auth.signOut();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ✅ Guardar conversación en Supabase Storage
  Future<void> _saveConversation() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final jsonData = _messages
          .map((msg) => {'text': msg['text'], 'isUser': msg['isUser']})
          .toList();

      final jsonString = jsonEncode(jsonData);
      final fileName = 'conversation_${DateTime.now().toIso8601String()}.json';

      final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));

      await supabase.storage.from('chat_histories').uploadBinary(
            'users/${user.id}/$fileName',
            bytes,
            fileOptions: const FileOptions(contentType: 'application/json'),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Conversación guardada en Supabase')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al guardar: $e')),
      );
    }
  }

  // ✅ Ver y seleccionar archivos guardados
  Future<void> _loadPreviousConversations() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final files = await supabase.storage
          .from('chat_histories')
          .list(path: 'users/${user.id}/');

      if (files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay conversaciones guardadas')),
        );
        return;
      }

      // Mostrar lista de archivos disponibles
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView(
            padding: const EdgeInsets.all(10),
            children: files.map((file) {
              return ListTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: Text(file.name),
                trailing: const Icon(Icons.download),
                onTap: () async {
                  Navigator.pop(context);
                  await _downloadConversation(file.name);
                },
              );
            }).toList(),
          );
        },
      );
    } catch (e) {
      print('Error cargando historial: $e');
    }
  }

  // ✅ Descargar conversación seleccionada
  Future<void> _downloadConversation(String fileName) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase.storage
          .from('chat_histories')
          .download('users/${user.id}/$fileName');

      final jsonString = utf8.decode(data);
      final List<dynamic> jsonData = jsonDecode(jsonString);

      setState(() {
        _messages
          ..clear()
          ..addAll(jsonData.map((msg) => {
                'text': msg['text'],
                'isUser': msg['isUser'],
              }));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('📂 Conversación "$fileName" cargada.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al cargar conversación: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text(
          "Luma 💬 - Apoyo Emocional",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // 👈 hace visibles los íconos
        actionsIconTheme:
            const IconThemeData(color: Colors.white), // 👈 también para los botones
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Guardar conversación',
            onPressed: _saveConversation,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Ver historial',
            onPressed: _loadPreviousConversations,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      "✨ Escribe un mensaje para comenzar a hablar con Luma 💖",
                      style: TextStyle(
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: InputArea(
              controller: _controller,
              onSend: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
