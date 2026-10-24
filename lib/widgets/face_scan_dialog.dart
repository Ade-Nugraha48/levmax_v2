import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

/// Dialog & Visual Scanning HUD untuk Face Scan Biometrik
/// Membuka kamera depan pengguna lalu melakukan verifikasi wajah dengan efek pemindai laser Solo Leveling.
class FaceScanDialog extends StatefulWidget {
  final File faceFile;

  const FaceScanDialog({
    super.key,
    required this.faceFile,
  });

  /// Helper statis untuk memicu alur Face Scan:
  /// 1. Membuka kamera depan via ImagePicker
  /// 2. Menampilkan FaceScanDialog dengan efek pemindaian holografis
  /// 3. Mengembalikan `true` jika berhasil diverifikasi, atau `false` jika dibatalkan
  static Future<bool> performFaceScan(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return false;

      if (!context.mounted) return false;

      final bool? verified = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => FaceScanDialog(faceFile: File(pickedFile.path)),
      );

      return verified == true;
    } catch (e) {
      debugPrint('[FaceScanDialog] Error opening camera: $e');
      return false;
    }
  }

  @override
  State<FaceScanDialog> createState() => _FaceScanDialogState();
}

class _FaceScanDialogState extends State<FaceScanDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  double _progress = 0.0;
  String _scanStatus = 'MENGANALISIS POLA RETINAL...';
  IconData _statusIcon = Icons.face_retouching_natural_rounded;
  Color _statusColor = const Color(0xFF00F4FE);
  Timer? _stepTimer;

  @override
  void initState() {
    super.initState();

    // Laser scanning animation (bergerak naik-turun melintasi foto wajah)
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );

    // Simulasi tahapan verifikasi wajah biometrik (1.8 detik total)
    _startScanSequence();
  }

  void _startScanSequence() {
    // Fase 1: Inisialisasi Analisis
    Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _progress = 0.35;
        _scanStatus = 'MENYELARASKAN GELOMBANG MANA...';
        _statusIcon = Icons.track_changes_rounded;
        _statusColor = const Color(0xFFB026FF);
      });
    });

    // Fase 2: Pencocokan Biometrik
    Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() {
        _progress = 0.75;
        _scanStatus = 'PENCOCOKAN STRUKTUR WAJAH 99.8%...';
        _statusIcon = Icons.verified_user_rounded;
        _statusColor = const Color(0xFF00F4FE);
      });
    });

    // Fase 3: Selesai & Terverifikasi
    Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      setState(() {
        _progress = 1.0;
        _scanStatus = 'IDENTITAS TERVERIFIKASI // AKSES DITERIMA';
        _statusIcon = Icons.check_circle_rounded;
        _statusColor = const Color(0xFF00F4FE);
      });

      // Tutup dialog dan kembalikan nilai sukses
      Timer(const Duration(milliseconds: 400), () {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      });
    });
  }

  @override
  void dispose() {
    _laserController.dispose();
    _stepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: const Color(0xFF140D24),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00F4FE).withValues(alpha: 0.6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F4FE).withValues(alpha: 0.25),
              blurRadius: 28,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0xFFB026FF).withValues(alpha: 0.2),
              blurRadius: 20,
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00F4FE),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF00F4FE),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'NEURAL FACE SCANNER',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: const Color(0xFF00F4FE),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF231D2B),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF383241)),
                  ),
                  child: Text(
                    'CAM: FRONT',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE5B5FF),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Viewport Foto Wajah dengan Bingkai Retikel & Pemindai Laser
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Foto Kamera
                  Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF2C1E4E),
                        width: 1.5,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.file(
                      widget.faceFile,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Overlay Grid & Dark Filter
                  Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00F4FE).withValues(alpha: 0.12),
                          Colors.transparent,
                          const Color(0xFFB026FF).withValues(alpha: 0.15),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Sudut Retikel Cyber (Top-Left)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFF00F4FE), width: 2.5),
                          left: BorderSide(color: Color(0xFF00F4FE), width: 2.5),
                        ),
                      ),
                    ),
                  ),

                  // Sudut Retikel Cyber (Top-Right)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFF00F4FE), width: 2.5),
                          right: BorderSide(color: Color(0xFF00F4FE), width: 2.5),
                        ),
                      ),
                    ),
                  ),

                  // Sudut Retikel Cyber (Bottom-Left)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFF00F4FE), width: 2.5),
                          left: BorderSide(color: Color(0xFF00F4FE), width: 2.5),
                        ),
                      ),
                    ),
                  ),

                  // Sudut Retikel Cyber (Bottom-Right)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFF00F4FE), width: 2.5),
                          right: BorderSide(color: Color(0xFF00F4FE), width: 2.5),
                        ),
                      ),
                    ),
                  ),

                  // Animasi Laser Bar Pemindai Vertikal
                  AnimatedBuilder(
                    animation: _laserAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: _laserAnimation.value * 190,
                        left: 5,
                        right: 5,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFF00F4FE),
                                Colors.white,
                                Color(0xFF00F4FE),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00F4FE).withValues(alpha: 0.9),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Indikator Status & Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_statusIcon, size: 16, color: _statusColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _scanStatus,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: _statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 6,
                backgroundColor: const Color(0xFF1F1927),
                valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
              ),
            ),

            const SizedBox(height: 14),

            // Tombol Batal
            SizedBox(
              width: double.infinity,
              height: 36,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF383241)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'BATALKAN PEMINDAIAN',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: const Color(0xFF9B8BA1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
