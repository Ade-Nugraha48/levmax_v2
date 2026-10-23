import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/gemini_service.dart';
import '../../services/hive_service.dart';

/// ChatAiScreen
/// Layar percakapan System Guide (AI Chat) bergaya Solo Leveling Monarch System.
/// Terhubung dengan GeminiService dan mendukung Custom Avatar AI dari galeri via Hive.
class ChatAiScreen extends StatefulWidget {
  const ChatAiScreen({super.key});

  @override
  State<ChatAiScreen> createState() => _ChatAiScreenState();
}

class _ChatAiScreenState extends State<ChatAiScreen> {
  // 1. URL Default Avatar Shadow Knight
  static const String _defaultShadowKnightUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuASSArz2k9B3wvWu5BTZGq66bo4BIRRpIflbiCMMx4O0KRhJBfs2YsezpfBXf91irLCoP1pxwxMZCvd3CAujclWtWaJ-Xvqzzr3fc7fvd9SFhA3kUYXdizKcL-83xmxyugbFbqtpFj9l4DSYK2GIAm8EYe6PzvX-C8vTKVl6Ol2ABCJaBFfXIr9dBQbmgpYC3T4-ZF62_J3yT9HYJKy49UbOUeQ7-zIXkGKpovF43mDqRgmNa2C1T-Y2otzIzoNjQ6MAw';

  // 2. State Pesan ('role': 'user' | 'model', 'text': String)
  final List<Map<String, String>> _messages = [];

  // 3. State Controller & Status
  bool _isLoading = false;
  String? _aiAvatarPath;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCustomAvatar();
    _initializeDefaultMessage();
  }

  /// Memuat avatar kustom AI yang tersimpan di Hive
  void _loadCustomAvatar() {
    final savedPath = HiveService.getAIAvatar();
    if (savedPath != null && savedPath.isNotEmpty) {
      final file = File(savedPath);
      if (file.existsSync()) {
        setState(() {
          _aiAvatarPath = savedPath;
        });
      }
    }
  }

  /// Pesan sambutan awal dari Shadow Monarch Advisor
  void _initializeDefaultMessage() {
    _messages.add({
      'role': 'model',
      'text':
          'Salam, Hunter. Sistem siap menganalisis data kekuatan, form biomekanik latihan, serta strategi menaikkan Rank Anda hari ini. Apa instruksi pertama Anda?',
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Memilih foto kustom dari galeri pengguna untuk dijadikan avatar AI
  Future<void> _pickAIAvatar() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await HiveService.saveAIAvatar(pickedFile.path);
        if (!mounted) return;
        setState(() {
          _aiAvatarPath = pickedFile.path;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.black, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Avatar AI berhasil dimutakhirkan dari galeri!',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF00F4FE),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  /// Mengirim pesan ke Gemini AI dan memperbarui riwayat chat
  Future<void> _handleSendMessage() async {
    final String prompt = _textController.text.trim();
    if (prompt.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'text': prompt,
      });
      _isLoading = true;
    });

    _textController.clear();
    _scrollToBottom();

    // Panggil GeminiService
    final String reply = await GeminiService.sendMessage(prompt);

    if (!mounted) return;

    setState(() {
      _messages.add({
        'role': 'model',
        'text': reply,
      });
      _isLoading = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF110C19), // Dark Surface Background
      body: SafeArea(
        child: Column(
          children: [
            // 1. App Bar Header dengan tombol Ganti Avatar
            _buildAppBar(context),

            // 2. Encrypted Monarch Channel Notice Banner
            _buildNoticeBanner(),

            // 3. Chat Log Stream
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final bool isUser = msg['role'] == 'user';
                  final String text = msg['text'] ?? '';

                  return isUser ? _buildUserMessage(text) : _buildAiMessage(text);
                },
              ),
            ),

            // 4. Loading Indicator: "SYSTEM IS CALCULATING TACTICAL PROTOCOL..."
            if (_isLoading) _buildLoadingIndicator(),

            // 5. Cyberpunk Input Dock
            _buildInputDock(),
          ],
        ),
      ),
    );
  }

  /// 1. App Bar Header
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF110C19),
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFF2C1E4E),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Tombol Back
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1927),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF2C1E4E),
                      width: 1.0,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFFE5B5FF),
                      size: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SYSTEM GUIDE',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: const Color(0xFF63F7FF),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2736),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFF00F4FE).withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              size: 11,
                              color: Color(0xFF00F4FE),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'LIVE',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF00F4FE),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'HUNTER SUPPORT AI',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: const Color(0xFF9B8BA1),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Tombol Ganti Avatar AI di Kanan
          Row(
            children: [
              GestureDetector(
                onTap: _pickAIAvatar,
                child: Tooltip(
                  message: 'Ganti Avatar AI dari Galeri',
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00F4FE).withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F4FE).withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildAvatarImageWidget(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Ganti Foto Avatar AI',
                icon: const Icon(
                  Icons.tune_rounded,
                  color: Color(0xFF9B8BA1),
                  size: 20,
                ),
                onPressed: _pickAIAvatar,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 2. Encrypted Monarch Channel Notice Banner
  Widget _buildNoticeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF110C19),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1927),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF2C1E4E),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lock_rounded,
                  size: 13,
                  color: Color(0xFF00F4FE),
                ),
                const SizedBox(width: 6),
                Text(
                  'ENCRYPTED MONARCH CHANNEL // GEMINI AKTIF',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: const Color(0xFF63F7FF),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF00F4FE),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF00F4FE),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'SYNCED',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: const Color(0xFF9B8BA1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 3. Bubble AI (Kiri) dengan aksen garis Cyan dan Avatar Box
  Widget _buildAiMessage(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar AI Kotak 40x40 dengan shadow glow cyan
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF110C19),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF00F4FE).withValues(alpha: 0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00F4FE).withValues(alpha: 0.25),
                  blurRadius: 10,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildAvatarImageWidget(),
          ),

          const SizedBox(width: 10),

          // Bubble AI
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1927),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      topLeft: Radius.circular(4),
                    ),
                    border: const Border(
                      left: BorderSide(
                        color: Color(0xFF00F4FE),
                        width: 3.5,
                      ),
                      top: BorderSide(color: Color(0xFF2C1E4E), width: 0.8),
                      right: BorderSide(color: Color(0xFF2C1E4E), width: 0.8),
                      bottom: BorderSide(color: Color(0xFF2C1E4E), width: 0.8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Tag: SYSTEM CORE // ADVISOR
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF00F4FE),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'SYSTEM CORE // ADVISOR',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: const Color(0xFF00F4FE),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Isi Pesan Teks
                      Text(
                        text,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          height: 1.45,
                          color: const Color(0xFFE9DEF2),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // Sub-Footer: RESPONSE VERIFIED
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 12,
                      color: Color(0xFFDCB8FC),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'RESPONSE VERIFIED',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: const Color(0xFFDCB8FC),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Bubble User (Kanan) dengan gradient ungu dan Avatar Kotak
  Widget _buildUserMessage(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bubble User
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB026FF), Color(0xFF7000A8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(4),
                      topRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB026FF).withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    text,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // Sub-Footer: HUNTER // TRANSMITTED
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'HUNTER // TRANSMITTED',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: const Color(0xFFE5B5FF),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.done_all_rounded,
                      size: 13,
                      color: Color(0xFFE5B5FF),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Avatar User Kotak Ungu 40x40
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFB026FF),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB026FF).withValues(alpha: 0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper untuk merender gambar avatar AI (File jika kustom ada, Network fallback jika default)
  Widget _buildAvatarImageWidget() {
    if (_aiAvatarPath != null && _aiAvatarPath!.isNotEmpty) {
      final file = File(_aiAvatarPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
        );
      }
    }

    return Image.network(
      _defaultShadowKnightUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFF140D28),
          child: const Center(
            child: Icon(
              Icons.smart_toy_rounded,
              color: Color(0xFF00F4FE),
              size: 22,
            ),
          ),
        );
      },
    );
  }

  /// 5. Indikator Loading "SYSTEM IS CALCULATING TACTICAL PROTOCOL..."
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF1F1927),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF00F4FE).withValues(alpha: 0.5),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F4FE).withValues(alpha: 0.2),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00F4FE)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SYSTEM IS CALCULATING TACTICAL PROTOCOL...',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: const Color(0xFF00F4FE),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 6. Cyberpunk Input Dock
  Widget _buildInputDock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF110C19),
        border: const Border(
          top: BorderSide(
            color: Color(0xFF2C1E4E),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Input Capsule
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1927),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF383241),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.psychology_rounded,
                    size: 20,
                    color: Color(0xFF00F4FE),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFFE9DEF2),
                      ),
                      cursorColor: const Color(0xFF00F4FE),
                      decoration: InputDecoration(
                        hintText: 'Tanyakan strategi pada sistem...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF5D5373),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: (_) => _handleSendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.mic_rounded,
                      size: 19,
                      color: Color(0xFF8B829E),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Voice command interface siap digunakan pada pembaruan mendatang.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Tombol Kirim Cyan Glowing 46x46
          GestureDetector(
            onTap: _isLoading ? null : _handleSendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF00F4FE),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F4FE).withValues(alpha: 0.6),
                    blurRadius: 14,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.send_rounded,
                  color: Color(0xFF08050E),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
