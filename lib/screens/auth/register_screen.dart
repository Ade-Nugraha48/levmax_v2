import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/hash_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isObscure = true;
  bool _isConfirmObscure = true;
  bool _isLoading = false;

  // State untuk Foto Profil Kustom
  File? _selectedAvatar;

  // State untuk Toggle Biometrik (UI Visual)
  bool _fingerprintEnroll = true;
  bool _faceScanEnroll = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _selectedAvatar = File(picked.path);
        });
      }
    } catch (e) {
      debugPrint('[RegisterAvatar] Error: $e');
    }
  }

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hunter Codename & Passcode wajib diisi!'),
          backgroundColor: AppColors.hpRed,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi Passcode tidak cocok!'),
          backgroundColor: AppColors.hpRed,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passcode minimal 6 karakter!'),
          backgroundColor: AppColors.hpRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Hash password di sisi client menggunakan SHA-256
      final passwordHash = HashService.hashSha256(password);

      // 2. Insert ke tabel users via SupabaseService dengan exp: 0, gold: 0, rank: 'F', hp: 3
      final result = await SupabaseService.register(
        username: username,
        passwordHash: passwordHash,
        hp: 3,
      );

      if (!mounted) return;

      if (result != null) {
        final userId = result['id'].toString();

        // 3. JIKA user memilih foto: upload ke Supabase bucket 'Avatar' lalu update tabel users
        if (_selectedAvatar != null) {
          final avatarUrl = await SupabaseService.uploadAvatar(_selectedAvatar!, userId);
          if (avatarUrl != null) {
            await SupabaseService.updateAvatarUrl(userId: userId, avatarUrl: avatarUrl);
          }
        }

        if (!mounted) return;
        setState(() => _isLoading = false);

        // 4. Notifikasi SnackBar sukses dan kembali ke LoginScreen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hunter $username berhasil terdaftar! Silakan login.'),
            backgroundColor: AppColors.neonViolet,
          ),
        );
        Navigator.pop(context);
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi gagal. Username mungkin sudah digunakan.'),
            backgroundColor: AppColors.hpRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: AppColors.hpRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16111E), // Dark Abyss Surface
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient Shadow Portal Aura (Top center glow)
            Positioned(
              top: -30,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFB026FF).withValues(alpha: 0.22),
                          const Color(0xFF8868A6).withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Main Content Area
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Top System Status Bar: Back Button & Node Pill
                      _buildTopBar(),

                      const SizedBox(height: 12),

                      // 2. Awakening Portal Crest & System Header
                      _buildHeader(),

                      const SizedBox(height: 14),

                      // 3. Registration HUD Terminal Card
                      _buildTerminalCard(),

                      const SizedBox(height: 10),

                      // 4. Monarch Directive Lore Banner
                      _buildMonarchBanner(),

                      const SizedBox(height: 12),

                      // 5. Footer: Login Redirection & Security Tag
                      _buildFooter(),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Top Bar: Chevron Left & NODE: NEW-RECORD Pill
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2736),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFFE5B5FF),
                size: 22,
              ),
            ),
          ),
        ),

        // Node Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
          decoration: BoxDecoration(
            color: const Color(0xFF110C19),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00F4FE),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00F4FE),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'NODE: NEW-RECORD',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: const Color(0xFFE6FEFF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 2. Awakening Portal Crest & System Header
  Widget _buildHeader() {
    return Column(
      children: [
        // Center Hunter Crest Avatar Picker with Purple Border & Camera Badge
        GestureDetector(
          onTap: _pickAvatar,
          child: SizedBox(
            width: 74,
            height: 74,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow Backdrop
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFFB026FF),
                        Color(0xFF00F4FE),
                        Colors.transparent,
                      ],
                      stops: [0.2, 0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB026FF).withValues(alpha: 0.45),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                // Outer Ring with Purple Border
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2D2736),
                    border: Border.all(color: const Color(0xFFB026FF), width: 2.0),
                  ),
                  child: Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF110C19),
                      ),
                      child: _selectedAvatar != null
                          ? ClipOval(
                              child: Image.file(
                                _selectedAvatar!,
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.add_a_photo_rounded,
                                color: Color(0xFFE5B5FF),
                                size: 24,
                              ),
                            ),
                    ),
                  ),
                ),
                // Camera Action Badge at bottom right
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFB026FF),
                      border: Border.all(color: const Color(0xFF110C19), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _selectedAvatar != null ? 'FOTO TERPILIH (KETUK UNTUK GANTI)' : 'PILIH FOTO PROFIL (OPSIONAL)',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: const Color(0xFFDCB8FC),
          ),
        ),

        const SizedBox(height: 8),

        // [ SYSTEM AWAKENING ]
        Text(
          '[ SYSTEM AWAKENING ]',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: const Color(0xFF00DCE5),
          ),
        ),

        const SizedBox(height: 3),

        // SYSTEM REGISTRATION
        Text(
          'SYSTEM REGISTRATION',
          style: GoogleFonts.sora(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: const Color(0xFFE9DEF2),
          ),
        ),

        const SizedBox(height: 3),

        // Subtext
        Text(
          'Register New Hunter Credentials to bind Mana Core',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFDCB8FC),
          ),
        ),
      ],
    );
  }

  /// 3. Registration HUD Terminal Card (Inputs + Biometrics + Action Button)
  Widget _buildTerminalCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F1927),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF383241),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top HUD Accent Bar (LinearGradient)
            Container(
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xFFB026FF),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Field 1: Hunter Codename
                  _buildInputLabel(
                    icon: Icons.person_rounded,
                    iconColor: const Color(0xFFE5B5FF),
                    label: 'HUNTER CODENAME',
                    badge: 'UNIQUE IDENTIFIER',
                    badgeColor: const Color(0xFF9B8BA1),
                  ),
                  const SizedBox(height: 5),
                  _buildTextField(
                    controller: _usernameController,
                    hint: 'e.g. SungJinwoo_99',
                    prefixIcon: Icons.fingerprint_rounded,
                  ),

                  const SizedBox(height: 11),

                  // Field 2: Create Security Cipher
                  _buildInputLabel(
                    icon: Icons.lock_rounded,
                    iconColor: const Color(0xFFE5B5FF),
                    label: 'CREATE SECURITY CIPHER',
                    badge: 'MIN. 8 RUNES',
                    badgeColor: const Color(0xFF9B8BA1),
                  ),
                  const SizedBox(height: 5),
                  _buildTextField(
                    controller: _passwordController,
                    hint: '••••••••••••',
                    prefixIcon: Icons.key_rounded,
                    isPassword: true,
                    isObscured: _isObscure,
                    onToggleVisibility: () => setState(() => _isObscure = !_isObscure),
                  ),

                  const SizedBox(height: 11),

                  // Field 3: Confirm Security Cipher
                  _buildInputLabel(
                    icon: Icons.verified_user_rounded,
                    iconColor: const Color(0xFF00DCE5),
                    label: 'CONFIRM CIPHER',
                    badge: 'CORE SYNC',
                    badgeColor: const Color(0xFF00DCE5),
                  ),
                  const SizedBox(height: 5),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hint: '••••••••••••',
                    prefixIcon: Icons.shield_rounded,
                    isPassword: true,
                    isObscured: _isConfirmObscure,
                    onToggleVisibility: () => setState(() => _isConfirmObscure = !_isConfirmObscure),
                  ),

                  const SizedBox(height: 13),

                  // Section Header: Otentikasi Biometrik
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.security_rounded,
                            size: 13,
                            color: Color(0xFFE5B5FF),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'OTENTIKASI BIOMETRIK',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                              color: const Color(0xFF9B8BA1),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'OPSIONAL • MULTI-LAYER',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: const Color(0xFFDCB8FC),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Biometric Toggle 1: Fingerprint
                  _buildBiometricBox(
                    icon: Icons.fingerprint_rounded,
                    iconColor: const Color(0xFFB026FF),
                    iconBgColor: const Color(0xFF1F1638),
                    borderColor: const Color(0xFFB026FF).withValues(alpha: 0.35),
                    title: 'Pindai Sidik Jari (Fingerprint)',
                    badgeText: 'SIAP DIDAFTARKAN',
                    badgeBgColor: const Color(0xFFB026FF).withValues(alpha: 0.20),
                    badgeTextColor: const Color(0xFFE5B5FF),
                    badgeBorderColor: const Color(0xFFB026FF).withValues(alpha: 0.40),
                    subtitle: 'Daftarkan sidik jari perangkat untuk autentika...',
                    switchValue: _fingerprintEnroll,
                    activeTrackColor: const Color(0xFFB026FF),
                    onChanged: (val) => setState(() => _fingerprintEnroll = val),
                  ),

                  const SizedBox(height: 7),

                  // Biometric Toggle 2: Face Scan
                  _buildBiometricBox(
                    icon: Icons.face_rounded,
                    iconColor: const Color(0xFF00F4FE),
                    iconBgColor: const Color(0xFF0A2730),
                    borderColor: const Color(0xFF00F4FE).withValues(alpha: 0.35),
                    title: 'Pengenalan Wajah (Face Scan)',
                    badgeText: 'KAMERA DEPAN',
                    badgeBgColor: const Color(0xFF00F4FE).withValues(alpha: 0.20),
                    badgeTextColor: const Color(0xFF00DCE5),
                    badgeBorderColor: const Color(0xFF00F4FE).withValues(alpha: 0.40),
                    subtitle: 'Daftarkan biometrik wajah via kamera depan',
                    switchValue: _faceScanEnroll,
                    activeTrackColor: const Color(0xFF00F4FE),
                    onChanged: (val) => setState(() => _faceScanEnroll = val),
                  ),

                  const SizedBox(height: 12),

                  // Submit Button: DAFTAR SEKARANG (REGISTER)
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B2CBF), Color(0xFFB026FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB026FF).withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: _isLoading ? null : _handleRegister,
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.bolt_rounded,
                                      color: Colors.white,
                                      size: 19,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'DAFTAR SEKARANG (REGISTER)',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 17,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget Helper: Label + Badge di atas TextFormField
  Widget _buildInputLabel({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String badge,
    required Color badgeColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: const Color(0xFFD2C1D7),
              ),
            ),
          ],
        ),
        Text(
          badge,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: badgeColor,
          ),
        ),
      ],
    );
  }

  /// Widget Helper: Styled TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF110C19),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF383241),
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? isObscured : false,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: const Color(0xFFE9DEF2),
        ),
        cursorColor: const Color(0xFFB026FF),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: const Color(0xFF4F4255),
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: const Color(0xFF6E6078),
            size: 18,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: const Color(0xFF9B8BA1),
                    size: 18,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
      ),
    );
  }

  /// Widget Helper: Biometric Toggle Box
  Widget _buildBiometricBox({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color borderColor,
    required String title,
    required String badgeText,
    required Color badgeBgColor,
    required Color badgeTextColor,
    required Color badgeBorderColor,
    required String subtitle,
    required bool switchValue,
    required Color activeTrackColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF110C19),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor,
                width: 1.0,
              ),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),

          const SizedBox(width: 8),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE9DEF2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: badgeBorderColor, width: 0.8),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w700,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    color: const Color(0xFF9B8BA1),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          // Switch
          SizedBox(
            height: 28,
            width: 40,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Switch(
                value: switchValue,
                onChanged: onChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: activeTrackColor,
                inactiveThumbColor: const Color(0xFF9B8BA1),
                inactiveTrackColor: const Color(0xFF383241),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Monarch Directive Lore Banner
  Widget _buildMonarchBanner() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1927),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF383241),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Thumbnail Image
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF383241),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/monarch_directive.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFB026FF),
                  size: 20,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MONARCH DIRECTIVE',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: const Color(0xFFE5B5FF),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '"You have been chosen as a System Player. Do not fall."',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: const Color(0xFFD2C1D7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          const Icon(
            Icons.auto_awesome,
            size: 16,
            color: Color(0xFF9B8BA1),
          ),
        ],
      ),
    );
  }

  /// 5. Footer: Login Link & Security Info
  Widget _buildFooter() {
    return Column(
      children: [
        // Portal Login Link
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sudah punya akun? ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFFD2C1D7),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Masuk di sini (Portal Login)',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE6FEFF),
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFFE6FEFF),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.north_east_rounded,
                      size: 13,
                      color: Color(0xFFE6FEFF),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Security Tag
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'GATE SECURE // RSA-4096',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9,
                  letterSpacing: 1.2,
                  color: const Color(0xFF9B8BA1),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF9B8BA1),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'VER 4.12.0',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9,
                  letterSpacing: 1.2,
                  color: const Color(0xFF9B8BA1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
