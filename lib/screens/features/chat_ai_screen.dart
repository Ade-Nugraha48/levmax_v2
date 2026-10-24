import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/ai_persona_model.dart';
import '../../services/gemini_service.dart';
import '../../services/hive_service.dart';
import '../../widgets/avatar_image.dart';

/// ChatAiScreen
/// Layar percakapan System Guide (AI Chat) bergaya Solo Leveling Monarch System.
/// Terhubung dengan GeminiService dan mendukung Custom Avatar AI serta Personifikasi AI Kustom via Hive.
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
  late AIPersona _persona;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadAIPersona();
    _initializeDefaultMessage();
  }

  /// Memuat avatar kustom dan data personifikasi AI yang tersimpan di Hive
  void _loadAIPersona() {
    _persona = HiveService.getAIPersona();
    _aiAvatarPath = _persona.avatarPath;
  }

  /// Pesan sambutan awal dari AI Advisor sesuai identitasnya
  void _initializeDefaultMessage() {
    _messages.add({
      'role': 'model',
      'text':
          'Salam, Hunter. Saya ${_persona.name} (${_persona.identity}). Sistem siap menganalisis data kekuatan, form biomekanik latihan, serta strategi menaikkan Rank Anda hari ini. Apa instruksi pertama Anda?',
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Membuka Modal Pengaturan Personifikasi & Profile Picture AI
  void _openPersonaSettingsDialog(BuildContext context) {
    final nameController = TextEditingController(text: _persona.name);
    final identityController = TextEditingController(text: _persona.identity);
    final toneController = TextEditingController(text: _persona.tone);
    final traitsController = TextEditingController(text: _persona.traits);
    String? tempAvatarPath = _persona.avatarPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (dialogCtx, setModalState) {
            return Container(
              height: MediaQuery.of(dialogCtx).size.height * 0.88,
              decoration: const BoxDecoration(
                color: Color(0xFF110C19),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(color: Color(0xFF00F4FE), width: 1.5),
                  left: BorderSide(color: Color(0xFF2C1E4E), width: 1.0),
                  right: BorderSide(color: Color(0xFF2C1E4E), width: 1.0),
                ),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF383241),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00F4FE).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF00F4FE).withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Icon(
                                Icons.psychology_rounded,
                                color: Color(0xFF00F4FE),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI PERSONA & AVATAR SETTINGS',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: const Color(0xFF00F4FE),
                                  ),
                                ),
                                Text(
                                  'Kustomisasi Nama, Peran, Gaya Bahasa & Sifat AI',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF9B8BA1),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF9B8BA1), size: 20),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Color(0xFF2C1E4E), height: 1),

                  // Body Form Scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: 18,
                        right: 18,
                        top: 14,
                        bottom: MediaQuery.of(dialogCtx).viewInsets.bottom + 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. SECTION: AVATAR AI
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 82,
                                  height: 82,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF00F4FE),
                                      width: 2.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00F4FE).withValues(alpha: 0.35),
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _buildAvatarImageWidget(tempAvatarPath),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildAvatarActionButton(
                                      icon: Icons.photo_library_rounded,
                                      label: 'Galeri',
                                      onTap: () async {
                                        final XFile? file = await _imagePicker.pickImage(
                                          source: ImageSource.gallery,
                                          maxWidth: 512,
                                          maxHeight: 512,
                                          imageQuality: 85,
                                        );
                                        if (file != null) {
                                          setModalState(() {
                                            tempAvatarPath = file.path;
                                          });
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    _buildAvatarActionButton(
                                      icon: Icons.camera_alt_rounded,
                                      label: 'Kamera',
                                      onTap: () async {
                                        final XFile? file = await _imagePicker.pickImage(
                                          source: ImageSource.camera,
                                          maxWidth: 512,
                                          maxHeight: 512,
                                          imageQuality: 85,
                                        );
                                        if (file != null) {
                                          setModalState(() {
                                            tempAvatarPath = file.path;
                                          });
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    _buildAvatarActionButton(
                                      icon: Icons.restart_alt_rounded,
                                      label: 'Default',
                                      onTap: () {
                                        setModalState(() {
                                          tempAvatarPath = null;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // 2. SECTION: NAMA AI
                          _buildDialogField(
                            label: 'NAMA AI // CODENAME',
                            controller: nameController,
                            hint: 'Contoh: SYSTEM GUIDE, BERU, IGRIS...',
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              'SYSTEM GUIDE',
                              'BERU',
                              'IGRIS',
                              'KAISEL',
                              'BELLION',
                              'ASHBORN',
                            ].map((preset) {
                              return _buildPresetChip(
                                label: preset,
                                isSelected: nameController.text == preset,
                                onTap: () {
                                  setModalState(() {
                                    nameController.text = preset;
                                  });
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 16),

                          // 3. SECTION: IDENTITAS & PERAN AI
                          _buildDialogField(
                            label: 'IDENTITAS // PERAN SISTEM',
                            controller: identityController,
                            hint: 'Contoh: HUNTER SUPPORT AI, PANGLIMA BAYANGAN...',
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              'HUNTER SUPPORT AI',
                              'PANGLIMA BAYANGAN',
                              'PERSONAL TRAINER',
                              'PENASIHAT TAKTIS',
                            ].map((preset) {
                              return _buildPresetChip(
                                label: preset,
                                isSelected: identityController.text == preset,
                                onTap: () {
                                  setModalState(() {
                                    identityController.text = preset;
                                  });
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 16),

                          // 4. SECTION: GAYA BAHASA (TONE OF VOICE)
                          _buildDialogField(
                            label: 'GAYA BAHASA & TUTUR KATA',
                            controller: toneController,
                            maxLines: 2,
                            hint: 'Bagaimana AI harus bertutur kata saat membalas pesan...',
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              MapEntry('Formal & Militer',
                                  'Formal, dingin, dan berwibawa layaknya perwira militer sistem Solo Leveling.'),
                              MapEntry('Santai & Gaul',
                                  'Santai, akrab, menggunakan bahasa gaul layaknya teman gym seperjuangan.'),
                              MapEntry('Tsundere & Tegas',
                                  'Tsundere, cerewet jika malas, tapi peduli dan menuntut kedisiplinan tinggi.'),
                              MapEntry('Penyemangat Ceria',
                                  'Sangat enerjik, positif, penuh antusiasme dan membakar api semangat!'),
                              MapEntry('Bijak & Tenang',
                                  'Bijak, tenang, filosofis, memandu dengan kata-kata penuh motivasi mendalam.'),
                            ].map((entry) {
                              return _buildPresetChip(
                                label: entry.key,
                                isSelected: toneController.text == entry.value,
                                onTap: () {
                                  setModalState(() {
                                    toneController.text = entry.value;
                                  });
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 16),

                          // 5. SECTION: SIFAT & KEPRIBADIAN (TRAITS)
                          _buildDialogField(
                            label: 'SIFAT & KEPRIBADIAN (TRAITS)',
                            controller: traitsController,
                            maxLines: 2,
                            hint: 'Sifat dominan dan kepribadian karakter AI...',
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              MapEntry('Setia & Protektif',
                                  'Sangat loyal dan protektif kepada Hunter, mengutamakan keselamatan dan progres fisik.'),
                              MapEntry('Dingin & Analitis',
                                  'Dingin, fokus murni pada kalkulasi angka, biomekanik, repetisi, dan efisiensi logis.'),
                              MapEntry('Sarkastik Cerdas',
                                  'Sarkastik halus, suka menyindir dengan cerdas jika latihan kurang keras, namun solutif.'),
                              MapEntry('Penuh Ambisi',
                                  'Ambisius, pantang menyerah, selalu mendorong Hunter melampaui batas Rank S.'),
                            ].map((entry) {
                              return _buildPresetChip(
                                label: entry.key,
                                isSelected: traitsController.text == entry.value,
                                onTap: () {
                                  setModalState(() {
                                    traitsController.text = entry.value;
                                  });
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 24),

                          // ACTION BUTTONS: RESET & SIMPAN
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  final def = AIPersona.defaultPersona;
                                  setModalState(() {
                                    nameController.text = def.name;
                                    identityController.text = def.identity;
                                    toneController.text = def.tone;
                                    traitsController.text = def.traits;
                                    tempAvatarPath = null;
                                  });
                                },
                                child: Text(
                                  'RESET DEFAULT',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF9B8BA1),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () async {
                                  final newPersona = AIPersona(
                                    name: nameController.text.trim().isEmpty
                                        ? 'SYSTEM GUIDE'
                                        : nameController.text.trim(),
                                    identity: identityController.text.trim().isEmpty
                                        ? 'HUNTER SUPPORT AI'
                                        : identityController.text.trim(),
                                    tone: toneController.text.trim().isEmpty
                                        ? _persona.tone
                                        : toneController.text.trim(),
                                    traits: traitsController.text.trim().isEmpty
                                        ? _persona.traits
                                        : traitsController.text.trim(),
                                    avatarPath: tempAvatarPath,
                                  );

                                  final messenger = ScaffoldMessenger.of(sheetContext);
                                  final nav = Navigator.of(sheetContext);

                                  await HiveService.saveAIPersona(newPersona);
                                  GeminiService.updatePersona(newPersona);

                                  if (!mounted) return;
                                  setState(() {
                                    _persona = newPersona;
                                    _aiAvatarPath = newPersona.avatarPath;
                                  });

                                  nav.pop();

                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded, color: Colors.black, size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Personifikasi [${newPersona.name}] berhasil diterapkan!',
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
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF00F4FE), Color(0xFF00B4D8)],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00F4FE).withValues(alpha: 0.5),
                                        blurRadius: 14,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.save_rounded, color: Color(0xFF08050E), size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        'SIMPAN PERSONIFIKASI',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                          color: const Color(0xFF08050E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Tombol aksi cepat untuk avatar (Galeri, Kamera, Default)
  Widget _buildAvatarActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1927),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF2C1E4E),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: const Color(0xFF00F4FE)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE5B5FF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper TextField khusus dialog pengaturan persona
  Widget _buildDialogField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: const Color(0xFF00F4FE),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF181126),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF2C1E4E),
              width: 1.0,
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: const Color(0xFFF1E9F7),
            ),
            cursorColor: const Color(0xFF00F4FE),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF5D5373),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  /// Helper chip pilihan preset cepat
  Widget _buildPresetChip({
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00F4FE).withValues(alpha: 0.18)
              : const Color(0xFF140D24),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: isSelected ? const Color(0xFF00F4FE) : const Color(0xFF2C1E4E),
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? const Color(0xFF00F4FE) : const Color(0xFFB5A8C8),
          ),
        ),
      ),
    );
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
                        _persona.name.toUpperCase(),
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
                    _persona.identity.toUpperCase(),
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

          // Tombol Avatar & Kustomisasi Persona AI di Kanan
          Row(
            children: [
              GestureDetector(
                onTap: () => _openPersonaSettingsDialog(context),
                child: Tooltip(
                  message: 'Kustomisasi Avatar & Personifikasi AI',
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
                tooltip: 'Kustomisasi Personifikasi AI',
                icon: const Icon(
                  Icons.tune_rounded,
                  color: Color(0xFF00F4FE),
                  size: 20,
                ),
                onPressed: () => _openPersonaSettingsDialog(context),
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
                    border: Border.all(
                      color: const Color(0xFF2C1E4E),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      topLeft: Radius.circular(4),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Garis aksen cyan vertikal di sebelah kiri
                          Container(
                            width: 3.5,
                            color: const Color(0xFF00F4FE),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header Tag: NAMA // PERAN
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
                                      Flexible(
                                        child: Text(
                                          '${_persona.name.toUpperCase()} // ${_persona.identity.toUpperCase()}',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.8,
                                            color: const Color(0xFF00F4FE),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Isi Pesan Teks Terformat Markdown (Bold, Lists, Italic, Code, dll)
                                  MarkdownBody(
                                    data: text,
                                    selectable: true,
                                    styleSheet: _buildAiMarkdownStyleSheet(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                  child: MarkdownBody(
                    data: text,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        height: 1.45,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      strong: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        height: 1.45,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      em: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        height: 1.45,
                        color: const Color(0xFFF4D9FF),
                        fontStyle: FontStyle.italic,
                      ),
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
          Builder(
            builder: (context) {
              final avatarUrl = HiveService.getSession()['avatar_url']?.toString();
              return Container(
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
                child: HunterAvatar(
                  avatarUrl: avatarUrl,
                  size: 40,
                  borderRadius: BorderRadius.circular(10),
                  fallback: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Helper untuk merender gambar avatar AI (File jika kustom ada, Network fallback jika default)
  Widget _buildAvatarImageWidget([String? customPath]) {
    final path = customPath ?? _aiAvatarPath;
    if (path != null && path.isNotEmpty) {
      final file = File(path);
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

  /// Helper untuk styling Markdown pada pesan AI agar terlihat rapi dan berstandar chat modern
  MarkdownStyleSheet _buildAiMarkdownStyleSheet() {
    return MarkdownStyleSheet(
      p: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        height: 1.55,
        color: const Color(0xFFE9DEF2),
      ),
      strong: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        height: 1.55,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF00F4FE), // Neon cyan highlight untuk kata berbobot / bold!
      ),
      em: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        height: 1.55,
        fontStyle: FontStyle.italic,
        color: const Color(0xFFDCB8FC),
      ),
      h1: GoogleFonts.sora(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF00F4FE),
      ),
      h2: GoogleFonts.sora(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF00F4FE),
      ),
      h3: GoogleFonts.sora(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF63F7FF),
      ),
      listBullet: GoogleFonts.spaceGrotesk(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF00F4FE),
      ),
      listIndent: 22.0,
      code: GoogleFonts.spaceGrotesk(
        fontSize: 11.5,
        color: const Color(0xFF00F4FE),
        backgroundColor: const Color(0xFF140D28),
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF140D28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF2C1E4E),
          width: 0.8,
        ),
      ),
      codeblockPadding: const EdgeInsets.all(10),
      blockquoteDecoration: BoxDecoration(
        color: const Color(0xFF140D28),
        borderRadius: BorderRadius.circular(4),
        border: const Border(
          left: BorderSide(
            color: Color(0xFF00F4FE),
            width: 3.0,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      blockquote: GoogleFonts.plusJakartaSans(
        fontSize: 12.5,
        fontStyle: FontStyle.italic,
        color: const Color(0xFFDCB8FC),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: const Color(0xFF2C1E4E),
            width: 1.0,
          ),
        ),
      ),
      blockSpacing: 10.0,
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

  /// 6. Cyberpunk Input Dock (Multiline and Scrollable if long)
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Input Capsule yang memanjang ke bawah dan scrollable saat panjang
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1927),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF383241),
                  width: 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 9.0),
                    child: Icon(
                      Icons.psychology_rounded,
                      size: 20,
                      color: Color(0xFF00F4FE),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 120, // Scrollable vertikal jika teks melebihi ~5 baris
                      ),
                      child: Scrollbar(
                        child: TextField(
                          controller: _textController,
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 5,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: const Color(0xFFE9DEF2),
                          ),
                          cursorColor: const Color(0xFF00F4FE),
                          decoration: InputDecoration(
                            hintText: 'Tanyakan strategi pada ${_persona.name}...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF5D5373),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: IconButton(
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
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Tombol Kirim Cyan Glowing 44x44 (tetap tertambat di kanan bawah)
          Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: GestureDetector(
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
          ),
        ],
      ),
    );
  }
}
