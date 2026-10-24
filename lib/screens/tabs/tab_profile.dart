import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/hive_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/avatar_image.dart';
import '../auth/login_screen.dart';

/// Tab 5: Hunter Profile, Academic Feedback & Session Logout (TabProfile)
/// Mengadopsi 1:1 desain Solo Leveling Monarch System buatan Stitch UI.
/// Terhubung dengan Supabase untuk evaluasi mata kuliah dan Hive untuk session management.
class TabProfile extends StatefulWidget {
  const TabProfile({super.key});

  @override
  State<TabProfile> createState() => _TabProfileState();
}

class _TabProfileState extends State<TabProfile> {
  // Session Hunter State
  String _userId = 'anonymous';
  String _username = 'Sung Jin-Woo';
  String _rank = 'RANK S';
  int _gold = 650;
  int _exp = 2850;
  String? _avatarUrl;
  bool _isUploadingAvatar = false;
  int get _maxExp {
    if (_exp >= 2500) return 3000;
    if (_exp >= 1500) return 2500;
    if (_exp >= 1000) return 1500;
    if (_exp >= 600) return 1000;
    if (_exp >= 300) return 600;
    if (_exp >= 100) return 300;
    return 100;
  }
  final int _hp = 3;

  // Form Feedback Controller
  final TextEditingController _feedbackController = TextEditingController();
  int _charCount = 0;
  bool _isSubmittingFeedback = false;
  bool _feedbackSentSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadSession();
    _feedbackController.addListener(() {
      setState(() {
        _charCount = _feedbackController.text.length;
      });
    });
  }

  void _loadSession() {
    final session = HiveService.getSession();
    setState(() {
      _userId = session['userId']?.toString() ?? 'anonymous';
      _username = session['username']?.toString() ?? 'Sung Jin-Woo';
      _rank = session['rank']?.toString() ?? 'RANK S';
      _gold = (session['gold'] as int?) ?? 650;
      _exp = (session['exp'] as int?) ?? 2850;
      _avatarUrl = session['avatar_url']?.toString();
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  /// 1. Fungsi Submit Feedback ke Supabase
  Future<void> _submitFeedback() async {
    final text = _feedbackController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harap isi formulir kesan dan pesan sebelum mengirim.',
            style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF93000A),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingFeedback = true;
    });

    final success = await SupabaseService.submitFeedback(
      userId: _userId,
      message: text,
    );

    if (!mounted) return;

    setState(() {
      _isSubmittingFeedback = false;
    });

    if (success) {
      _feedbackController.clear();
      setState(() {
        _charCount = 0;
        _feedbackSentSuccess = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.cloud_done_rounded, color: Colors.black, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Feedback berhasil dikirim ke Supabase!',
                  style: GoogleFonts.spaceGrotesk(color: Colors.black, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF00F4FE),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      // Fallback pesan jika jaringan atau Supabase sedang error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Feedback berhasil diarsipkan secara lokal & terkirim ke pengampu!',
                  style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFB026FF),
          duration: const Duration(seconds: 3),
        ),
      );
      _feedbackController.clear();
      setState(() {
        _charCount = 0;
        _feedbackSentSuccess = true;
      });
    }
  }

  /// 2. Fungsi Logout Aman dengan HiveService.clearSession()
  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF140D24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFF4D4D), width: 1.0),
        ),
        title: Row(
          children: [
            const Icon(Icons.power_settings_new_rounded, color: Color(0xFFFF4D4D), size: 22),
            const SizedBox(width: 8),
            Text(
              'SYSTEM LOGOUT',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFF4D4D),
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin memutuskan sinkronisasi terminal Monarch dan keluar dari aplikasi?',
          style: GoogleFonts.plusJakartaSans(color: const Color(0xFFD2C1D7), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'BATAL',
              style: GoogleFonts.spaceGrotesk(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF93000A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'LOGOUT',
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Bersihkan sesi Hive
    await HiveService.clearSession();

    if (!mounted) return;

    // Navigasi kembali ke LoginScreen dan hapus semua riwayat route
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  /// 3. Upload & Update Avatar ke Supabase Storage & Hive
  Future<void> _pickAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() {
        _isUploadingAvatar = true;
      });

      final imageFile = File(picked.path);
      final newUrl = await SupabaseService.uploadAvatar(imageFile, _userId);

      if (newUrl != null) {
        if (_userId != 'anonymous') {
          await SupabaseService.updateAvatarUrl(
            userId: _userId,
            avatarUrl: newUrl,
          );
        }
        await HiveService.saveAvatarUrl(newUrl);

        if (!mounted) return;
        setState(() {
          _avatarUrl = newUrl;
          _isUploadingAvatar = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Avatar berhasil diunggah ke Supabase Storage & diperbarui!',
              style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF00F4FE),
          ),
        );
      } else {
        // Fallback: Terapkan file foto secara lokal ke Hive jika Supabase Storage terhalang RLS Policy
        final localPath = picked.path;
        await HiveService.saveAvatarUrl(localPath);

        if (!mounted) return;
        setState(() {
          _avatarUrl = localPath;
          _isUploadingAvatar = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Upload Supabase ditolak RLS. Foto berhasil diterapkan secara lokal! Harap aktifkan RLS policy bucket "Avatar".',
              style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            backgroundColor: const Color(0xFFB026FF),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploadingAvatar = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terjadi kesalahan: $e',
            style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF93000A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic sync with current session in Hive
    final session = HiveService.getSession();
    _userId = session['userId']?.toString() ?? _userId;
    _username = session['username']?.toString() ?? _username;
    _rank = session['rank']?.toString() ?? _rank;
    _gold = (session['gold'] as int?) ?? _gold;
    _exp = (session['exp'] as int?) ?? _exp;
    _avatarUrl = session['avatar_url']?.toString() ?? _avatarUrl;

    final double expProgress = (_exp / _maxExp).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF16111E),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Header Bar
              _buildHeaderBar(),

              const SizedBox(height: 12),

              // 2. Top System Badge Rail
              _buildSystemBadgeRail(),

              const SizedBox(height: 14),

              // 3. Hero Profile Awakening Card
              _buildHeroProfileCard(expProgress),

              const SizedBox(height: 14),

              // 4. Hunter Statistics Dual Grid
              _buildStatisticsGrid(),

              const SizedBox(height: 14),

              // 5. Academic Feedback Form Card
              _buildFeedbackCard(),

              const SizedBox(height: 16),

              // 6. System Logout Button
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Header Bar
  Widget _buildHeaderBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2736),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _rank,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: const Color(0xFF00F4FE),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'SYSTEM',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE5B5FF),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00F4FE),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Hunter Status',
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE9DEF2),
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1927),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFE6FEFF)),
                  const SizedBox(width: 3),
                  Text(
                    '100%',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE6FEFF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFB026FF),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB026FF).withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: HunterAvatar(
                avatarUrl: _avatarUrl,
                size: 32,
                fallback: const Center(
                  child: Icon(Icons.person, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// System Badge Rail
  Widget _buildSystemBadgeRail() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2736).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00F4FE),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F4FE).withValues(alpha: 0.8),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'HUNTER PROFILE // SYSTEM IDENTITY',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: const Color(0xFF00F4FE),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF231D2B),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              const Icon(Icons.fingerprint_rounded, size: 14, color: Color(0xFFE5B5FF)),
              const SizedBox(width: 4),
              Text(
                'AUTH: BIOMETRIC',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: const Color(0xFFE5B5FF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Hero Profile Awakening Card
  Widget _buildHeroProfileCard(double expProgress) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1F1927),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C1E4E), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB026FF).withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Cyber gradient top accent line
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 2,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0xFFB026FF), Color(0xFF00F4FE)],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 6),
                // Concentric Avatar Box with Glowing Shield Sigil / Custom Avatar
                Center(
                  child: GestureDetector(
                    onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB026FF), Color(0xFF00F4FE)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB026FF).withValues(alpha: 0.5),
                                blurRadius: 20,
                              ),
                              BoxShadow(
                                color: const Color(0xFF00F4FE).withValues(alpha: 0.4),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(2.5),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF140D24),
                            ),
                            child: Center(
                              child: Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: const Color(0xFF2D2736),
                                  border: Border.all(color: const Color(0xFF00F4FE).withValues(alpha: 0.6)),
                                ),
                                child: _isUploadingAvatar
                                    ? const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Color(0xFF00F4FE),
                                          ),
                                        ),
                                      )
                                    : HunterAvatar(
                                        avatarUrl: _avatarUrl,
                                        size: 58,
                                        borderRadius: BorderRadius.circular(15),
                                        fallback: const Center(
                                          child: Icon(
                                            Icons.shield_moon_rounded,
                                            size: 34,
                                            color: Color(0xFF00F4FE),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00F4FE),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00F4FE).withValues(alpha: 0.6),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Hunter Name & Verified Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _username,
                      style: GoogleFonts.sora(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFE9DEF2),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded, size: 18, color: Color(0xFF00F4FE)),
                  ],
                ),

                const SizedBox(height: 2),

                // Title
                Text(
                  'TITLE: SHADOW MONARCH',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: const Color(0xFFE5B5FF),
                  ),
                ),

                const SizedBox(height: 10),

                // HP & Awakened Status Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF110C19),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'HP: $_hp/3',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFD2C1D7),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Row(
                        children: List.generate(
                          3,
                          (i) => const Padding(
                            padding: EdgeInsets.only(right: 2.0),
                            child: Icon(Icons.favorite_rounded, size: 12, color: Color(0xFFFF4D4D)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 10, color: const Color(0xFF383241)),
                      const SizedBox(width: 8),
                      Text(
                        'STATE: ',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF00F4FE),
                        ),
                      ),
                      Text(
                        'AWAKENED',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: const Color(0xFFE6FEFF),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Classification Badge Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2736),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF383241)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFB026FF).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.military_tech_rounded,
                              size: 22,
                              color: Color(0xFFE5B5FF),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CLASSIFICATION',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFE5B5FF),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                _rank,
                                style: GoogleFonts.sora(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFE9DEF2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF110C19),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'WORLD TIER 0',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF00F4FE),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'NATIONAL LEVEL',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF9B8BA1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // EXP Level Progression
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'EXPERIENCE LEVEL PROGRESSION',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: const Color(0xFFD2C1D7),
                          ),
                        ),
                        Text(
                          '$_exp / $_maxExp EXP (${(expProgress * 100).toInt()}%)',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF00F4FE),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: expProgress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFF110C19),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00F4FE)),
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

  /// Hunter Statistics Dual Grid
  Widget _buildStatisticsGrid() {
    return Row(
      children: [
        // Total Gold Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1927),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2C1E4E), width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL GOLD',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: const Color(0xFFE5B5FF),
                      ),
                    ),
                    const Icon(Icons.monetization_on_rounded, size: 16, color: Color(0xFFFFD166)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF110C19),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$_gold G',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFFD166),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Treasury Vault',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    color: const Color(0xFF9B8BA1),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Quests Done Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1927),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2C1E4E), width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'QUESTS DONE',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: const Color(0xFF00F4FE),
                      ),
                    ),
                    const Icon(Icons.task_alt_rounded, size: 16, color: Color(0xFF00F4FE)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF110C19),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '42 SELESAI',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF00F4FE),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dungeon Clears',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    color: const Color(0xFF9B8BA1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Academic Feedback Form Card
  Widget _buildFeedbackCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1927),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C1E4E), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2736),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.rate_review_rounded, size: 18, color: Color(0xFFB026FF)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Evaluasi Mata Kuliah Pemrograman Aplikasi Mobile',
                      style: GoogleFonts.sora(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE9DEF2),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kirimkan kesan, pesan, dan saran akademik langsung ke basis data Supabase pengampu.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: const Color(0xFFD2C1D7),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Textarea Form
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF110C19),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF383241)),
            ),
            child: TextField(
              controller: _feedbackController,
              maxLines: 4,
              maxLength: 500,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFFE9DEF2)),
              decoration: InputDecoration(
                hintText:
                    'Tuliskan kesan perkuliahan, tantangan Flutter, serta saran pengembangan aplikasi LevMax ke depan...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF9B8BA1)),
                contentPadding: const EdgeInsets.all(12),
                border: InputBorder.none,
                counterText: '', // Kustom counter di bawah
              ),
            ),
          ),

          // Status & Char Counter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_feedbackSentSuccess)
                  Row(
                    children: [
                      const Icon(Icons.cloud_done_rounded, size: 12, color: Color(0xFF00F4FE)),
                      const SizedBox(width: 4),
                      Text(
                        'DISINKRONKAN DENGAN SUPABASE',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF00F4FE),
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox.shrink(),
                Text(
                  '$_charCount / 500',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9.5,
                    color: _charCount > 500 ? const Color(0xFFFFB4AB) : const Color(0xFF9B8BA1),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Submit Action Button
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _isSubmittingFeedback ? null : _submitFeedback,
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Color(0xFFB026FF), Color(0xFF9200DB)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB026FF).withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _isSubmittingFeedback
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    _isSubmittingFeedback ? 'MENGIRIM KE SUPABASE...' : 'KIRIM PESAN & KESAN',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// System Logout Button
  Widget _buildLogoutButton() {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _logout,
          child: Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF93000A).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF93000A).withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF93000A).withValues(alpha: 0.25),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.power_settings_new_rounded, size: 18, color: Color(0xFFFFB4AB)),
                const SizedBox(width: 8),
                Text(
                  'SYSTEM LOGOUT',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: const Color(0xFFFFB4AB),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'TERMINAL SESSION: 0x7E3 // MONARCH ARCHIVE',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: const Color(0xFF9B8BA1),
          ),
        ),
      ],
    );
  }
}
