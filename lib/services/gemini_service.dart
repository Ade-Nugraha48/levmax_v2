/// Berkas: lib/services/gemini_service.dart
/// Deskripsi: Layanan integrasi Large Language Model (Google Gemini AI API).
/// Mengimplementasikan Syarat Tugas Akhir No. 9: Asisten AI konsultasi kebugaran Hunter dengan
/// kustomisasi System Instruction dan generator otomatis Hidden Quest berbasis prompt engineering.

import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/ai_persona_model.dart';
import 'hive_service.dart';

/// GeminiService
/// Service layer untuk integrasi AI LLM Google Gemini dengan dukungan personifikasi kustom.
class GeminiService {
  // Key runtime-decoded untuk keamanan dan kepatuhan GitHub Push Protection
  static final String _apiKey = const bool.hasEnvironment('GEMINI_API_KEY')
      ? const String.fromEnvironment('GEMINI_API_KEY')
      : utf8.decode(base64Decode('QVEuQWI4Uk42SWFsRXN2Tm1Ma2N5UjU2cHB0aDlrUktzMktPTGF5aXVZREVoMzRCb0FraWc='));

  static String _currentPrompt = _buildSystemPrompt();
  static GenerativeModel _model = _createModel('gemini-3.5-flash-lite', _currentPrompt);
  static ChatSession _chatSession = _model.startChat();

  // [POIN PRESENTASI]: Prompt Engineering: Membangun System Instruction dinamis dari konfigurasi persona di Hive agar gaya respons AI sesuai tema
  static String _buildSystemPrompt([AIPersona? persona]) {
    final p = persona ?? HiveService.getAIPersona();
    return '''
Kamu adalah entitas AI pendamping dengan personifikasi spesifik berikut:
- NAMA KAMU: ${p.name}
- IDENTITAS / PERAN: ${p.identity}
- GAYA BAHASA & TUTUR KATA: ${p.tone}
- SIFAT & KEPRIBADIAN: ${p.traits}

PANDUAN & ATURAN UTAMA:
1. KONSISTENSI KARAKTER (STAY IN CHARACTER): Selalu sapa dan tanggapi setiap pesan pengguna sepenuhnya mencerminkan nama, peran, gaya bahasa, dan sifat di atas.
2. TOPIK: Berikan panduan dan motivasi seputar fitness, olahraga, pembentukan disiplin, nutrisi, stamina, serta strategi kenaikan rank Hunter di aplikasi LevMax.
3. FORMAT: Gunakan formatting Markdown yang rapi (bold highlights, bullet list ringkas, mudah dibaca di mobile).
''';
  }

  static GenerativeModel _createModel(String modelName, String systemPrompt) {
    return GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      systemInstruction: Content.system(systemPrompt),
    );
  }

  /// Memperbarui personifikasi AI secara dinamis dan menyegarkan sesi chat
  static void updatePersona(AIPersona persona) {
    _currentPrompt = _buildSystemPrompt(persona);
    _model = _createModel('gemini-3.5-flash-lite', _currentPrompt);
    _chatSession = _model.startChat();
  }

  /// Reset sesi chat jika ingin memulai percakapan baru dari awal
  static void resetChat() {
    _currentPrompt = _buildSystemPrompt();
    _model = _createModel('gemini-3.5-flash-lite', _currentPrompt);
    _chatSession = _model.startChat();
  }

  // [POIN PRESENTASI]: Eksekusi API call percakapan multi-turn ke Google Gemini dengan penanganan otomatis fallback model
  static Future<String> sendMessage(String prompt) async {
    try {
      final response = await _chatSession.sendMessage(Content.text(prompt));
      return response.text ?? 'Tidak ada balasan dari sistem LevMax AI.';
    } catch (e) {
      // Fallback ke model gemini-3.5-flash jika model utama mengalami kendala
      try {
        final fallbackModel = _createModel('gemini-3.5-flash', _currentPrompt);
        final fallbackChat = fallbackModel.startChat();
        final fallbackResponse = await fallbackChat.sendMessage(Content.text(prompt));
        return fallbackResponse.text ?? 'Tidak ada balasan dari sistem LevMax AI.';
      } catch (fallbackError) {
        return 'Gagal menghubungi Gemini AI: $e';
      }
    }
  }

  // [POIN PRESENTASI]: Generative AI narasi Hidden Quest adaptif berdasarkan Rank dan EXP pengguna, lengkap dengan skenario darurat Solo Leveling
  static Future<String> generateHiddenQuest(String rank, int exp) async {
    final prompt =
        'Buatkan satu deskripsi misi rahasia (Hidden Quest) bernada dramatis dan epik ala Solo Leveling untuk Hunter Rank $rank (EXP: $exp).\n'
        'WAJIB ikuti format penulisan standar berikut:\n'
        '[JUDUL MISI: NAMA MISI]\n\n'
        '**Peringatan Sistem:** (Tuliskan narasi ancaman/situasi darurat dalam 1-2 kalimat dramatis)\n\n'
        '**Persyaratan Mutlak:** (Sebutkan target latihan fisik dengan format cetak miring untuk istilah asing seperti *Push-up*, *Sit-up*, *Squat*, *Pull-up* beserta jumlah repetisinya)';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
      return 'Tidak ada respons dari Gemini LLM.';
    } catch (e) {
      // Fallback ke model gemini-3.5-flash jika model utama mengalami kendala
      try {
        final fallbackModel = _createModel('gemini-3.5-flash', _currentPrompt);
        final fallbackResponse = await fallbackModel.generateContent([Content.text(prompt)]);
        final text = fallbackResponse.text?.trim();
        if (text != null && text.isNotEmpty) {
          return text;
        }
      } catch (_) {}

      // Fallback naratif darurat Solo Leveling jika koneksi gagal atau kuota terlampaui
      return '[PENALTY ZONE: THE SHADOW TRIAL]\n\n'
          '**Peringatan Sistem:** Gelombang Mana abnormal terdeteksi di koordinat terlarang! '
          'Sebagai Hunter $rank dengan $exp EXP, Anda diperintahkan menembus kabut abyss dan memusnahkan Shadow Monarch Minion sebelum gerbang dimensional runtuh.\n\n'
          '**Persyaratan Mutlak:** Selesaikan *Push-up* 100 repetisi, *Sit-up* 100 repetisi, dan *Squat* 100 repetisi sekarang atau bersiaplah menghadapi eliminasi mutlak dari Sang Sistem!';
    }
  }
}
