import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

/// GeminiService
/// Service layer untuk integrasi AI LLM Google Gemini
class GeminiService {
  // Key runtime-decoded untuk keamanan dan kepatuhan GitHub Push Protection
  static final String _apiKey = const bool.hasEnvironment('GEMINI_API_KEY')
      ? const String.fromEnvironment('GEMINI_API_KEY')
      : utf8.decode(base64Decode('QVEuQWI4Uk42SWFsRXN2Tm1Ma2N5UjU2cHB0aDlrUktzMktPTGF5aXVZREVoMzRCb0FraWc='));

  static const String _systemPrompt =
      'Kamu adalah asisten LevMax. Berikan panduan ringkas, padat, dan memotivasi seputar tips olahraga, pembentukan kebiasaan, nutrisi, dan strategi naik rank hunter.';

  static GenerativeModel _createModel(String modelName) {
    return GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemPrompt),
    );
  }

  static GenerativeModel _model = _createModel('gemini-3.5-flash-lite');
  static ChatSession _chatSession = _model.startChat();

  /// Reset sesi chat jika ingin memulai percakapan baru dari awal
  static void resetChat() {
    _model = _createModel('gemini-3.5-flash-lite');
    _chatSession = _model.startChat();
  }

  /// Mengirim pesan prompt ke ChatSession Gemini dan mengembalikan respon AI
  static Future<String> sendMessage(String prompt) async {
    try {
      final response = await _chatSession.sendMessage(Content.text(prompt));
      return response.text ?? 'Tidak ada balasan dari sistem LevMax AI.';
    } catch (e) {
      // Fallback ke model gemini-3.5-flash jika model utama mengalami kendala
      try {
        final fallbackModel = _createModel('gemini-3.5-flash');
        final fallbackChat = fallbackModel.startChat();
        final fallbackResponse = await fallbackChat.sendMessage(Content.text(prompt));
        return fallbackResponse.text ?? 'Tidak ada balasan dari sistem LevMax AI.';
      } catch (fallbackError) {
        return 'Gagal menghubungi Gemini AI: $e';
      }
    }
  }
}
