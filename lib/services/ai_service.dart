import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  final _model = GenerativeModel(
    model: 'gemini-2.5-flash-lite',
    apiKey: 'AIzaSyBiX9abR7Eq8R8f41R_hUre-11W1mPn0Q0', // 👈 pon aquí tu API Key de Google AI
  );

  Future<String> sendMessage(String message) async {
    try {
      final response = await _model.generateContent([Content.text(message)]);
      return response.text ?? "Lo siento, no pude entenderte 😔";
    } catch (e) {
      return "Error al conectar con la IA: $e";
    }
  }
}
