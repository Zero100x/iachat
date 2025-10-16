import 'package:supabase_flutter/supabase_flutter.dart';

class ChatStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> saveMessage(String message, bool isUser) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('chat_messages').insert({
      'user_id': user.id,
      'message': message,
      'is_user': isUser,
    });
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('chat_messages')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> clearMessages() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('chat_messages').delete().eq('user_id', user.id);
  }
}
