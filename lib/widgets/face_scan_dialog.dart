import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:levmax_v2/services/face_recognition_service.dart';
import 'package:levmax_v2/services/hive_service.dart';

/// Mode pemindaian wajah biometrik
enum FaceScanMode {
  /// Mendaftarkan wajah baru sebagai basis biometrik dan disimpan ke Hive
  enroll,

  /// Memverifikasi wajah kandidat real-time terhadap basis wajah yang ada di Hive
  verify,
}

/// Status visual antarmuka pemindai wajah
enum _ScannerVisualState {
  initializing,
  scanning,
  processing,
  matched,
  mismatched,
  error,
}

/// Dialog & Visual Scanning HUD untuk Face Scan Biometrik Real-Time
/// Menampilkan live camera feed kamera depan di dalam retikel cyber Solo Leveling
/// dan melakukan pencocokan biometrik berbasis data Hive.
class FaceScanDialog extends StatefulWidget {
  final FaceScanMode mode;

  const FaceScanDialog({
    super.key,
    required this.mode,
  });

  /// Helper statis utama untuk memicu pemindaian wajah real-time
  static Future<bool> startFaceScan(
    BuildContext context, {
    required FaceScanMode mode,
  }) async {
    final bool? verified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => FaceScanDialog(mode: mode),
    );
    return verified == true;
  }

  /// Kompatibilitas mundur dengan pemanggilan lama
  static Future<bool> performFaceScan(BuildContext context) async {
    final hasBaseline = HiveService.hasEnrolledFace();
    return startFaceScan(
      context,
      mode: hasBaseline ? FaceScanMode.verify : FaceScanMode.enroll,
    );
  }

  @override
  State<FaceScanDialog> createState() => _FaceScanDialogState();
}

class _FaceScanDialogState extends State<FaceScanDialog>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  _ScannerVisualState _visualState = _ScannerVisualState.initializing;

  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  Timer? _autoScanTimer;
  String _statusText = 'MENGHUBUNGKAN SENSOR OPTIK DEPAN...';
  String _errorMessage = '';
  double? _lastScore;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    // Animasi pergerakan laser pemindai naik-turun
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    setState(() {
      _visualState = _ScannerVisualState.initializing;
      _statusText = 'MENGHUBUNGKAN SENSOR OPTIK DEPAN...';
      _errorMessage = '';
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _visualState = _ScannerVisualState.error;
          _errorMessage = 'Tidak ditemukan modul kamera pada perangkat.';
        });
        return;
      }

      // Pilih kamera depan (front lens)
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      controller.addListener(() {
        if (mounted) setState(() {});
      });

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _visualState = _ScannerVisualState.scanning;
        _statusText = widget.mode == FaceScanMode.enroll
            ? 'POSISIKAN WAJAH DI DALAM RETIKEL...'
            : 'MEMINDAI WAJAH SECARA REAL-TIME...';
      });

      // Jadwalkan pemindaian otomatis setelah user stabil menatap kamera (2.2 detik)
      _scheduleAutoScan();
    } catch (e) {
      debugPrint('[FaceScanDialog] Gagal inisialisasi kamera: $e');
      if (mounted) {
        final errStr = e.toString();
        final isPluginUnregistered = errStr.contains('channel-error') ||
            errStr.contains('ProcessCameraProvider') ||
            errStr.contains('MissingPluginException');
        setState(() {
          _visualState = _ScannerVisualState.error;
          _errorMessage = isPluginUnregistered
              ? 'Plugin kamera baru memerlukan restart aplikasi penuh: silakan Stop aplikasi dan jalankan ulang "flutter run".'
              : 'Gagal mengakses kamera: $e';
        });
      }
    }
  }

  void _scheduleAutoScan() {
    _autoScanTimer?.cancel();
    _autoScanTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted &&
          _visualState == _ScannerVisualState.scanning &&
          !_isProcessing) {
        _executeScan();
      }
    });
  }

  Future<void> _executeScan() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _visualState = _ScannerVisualState.processing;
      _statusText = widget.mode == FaceScanMode.enroll
          ? 'MEREKAM STRUKTUR POLA WAJAH...'
          : 'MENCOCOKKAN FITUR BIOMETRIK KE HIVE...';
    });

    try {
      // Ambil frame real-time dari stream kamera depan
      final XFile imageFile = await _cameraController!.takePicture();
      final Uint8List imageBytes = await imageFile.readAsBytes();

      if (!mounted) return;

      if (widget.mode == FaceScanMode.enroll) {
        // Mode ENROLL: Ekstraksi fitur dan simpan ke Hive
        final FaceTemplate? template =
            FaceRecognitionService.extractTemplate(imageBytes);

        if (template == null) {
          setState(() {
            _visualState = _ScannerVisualState.mismatched;
            _statusText = 'WAJAH TIDAK TERDETEKSI JELAS';
            _errorMessage =
                'Pastikan wajah Anda tepat di tengah dan pencahayaan ruangan cukup terang.';
            _isProcessing = false;
          });
          HapticFeedback.vibrate();
          return;
        }

        // Simpan template JSON dan thumbnail ke Hive
        await HiveService.saveEnrolledFace(
          templateJson: template.serialize(),
          thumbnailBase64: template.thumbnailBase64,
        );

        setState(() {
          _visualState = _ScannerVisualState.matched;
          _statusText = 'BASIS BIOMETRIK BERHASIL DISIMPAN KE HIVE!';
          _lastScore = 100.0;
        });

        HapticFeedback.mediumImpact();

        Timer(const Duration(milliseconds: 900), () {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        });
      } else {
        // Mode VERIFY: Periksa kecocokan terhadap basis di Hive
        final String? enrolledJson = HiveService.getEnrolledFaceTemplate();

        if (enrolledJson == null || enrolledJson.isEmpty) {
          setState(() {
            _visualState = _ScannerVisualState.error;
            _errorMessage =
                'Belum ada basis wajah terdaftar di Hive. Daftarkan di Profil terlebih dahulu.';
            _isProcessing = false;
          });
          return;
        }

        final FaceComparisonResult result =
            FaceRecognitionService.compareBytesWithTemplate(
          imageBytes,
          enrolledJson,
        );

        _lastScore = result.score;

        if (result.isMatch) {
          // Wajah Cocok -> AKSES DITERIMA
          setState(() {
            _visualState = _ScannerVisualState.matched;
            _statusText =
                'AKSES DITERIMA // HUNTER TERVERIFIKASI (${result.score.toStringAsFixed(1)}%)';
          });

          HapticFeedback.lightImpact();

          Timer(const Duration(milliseconds: 800), () {
            if (mounted) {
              Navigator.of(context).pop(true);
            }
          });
        } else {
          // Wajah Beda / Tidak Cocok -> AKSES DITOLAK
          setState(() {
            _visualState = _ScannerVisualState.mismatched;
            _statusText =
                'AKSES DITOLAK: WAJAH TIDAK COCOK (${result.score.toStringAsFixed(1)}%)';
            _errorMessage =
                'Wajah yang terdeteksi berbeda dari data Hunter terdaftar di Hive (Min. 70.0%).';
            _isProcessing = false;
          });

          HapticFeedback.heavyImpact();
        }
      }
    } catch (e) {
      debugPrint('[FaceScanDialog] Error running scan: $e');
      if (mounted) {
        setState(() {
          _visualState = _ScannerVisualState.error;
          _errorMessage = 'Terjadi kesalahan saat memproses frame: $e';
          _isProcessing = false;
        });
      }
    }
  }

  void _retryScan() {
    _autoScanTimer?.cancel();
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _initCamera();
      return;
    }
    setState(() {
      _visualState = _ScannerVisualState.scanning;
      _errorMessage = '';
      _isProcessing = false;
      _lastScore = null;
      _statusText = widget.mode == FaceScanMode.enroll
          ? 'POSISIKAN WAJAH DI DALAM RETIKEL...'
          : 'MEMINDAI WAJAH SECARA REAL-TIME...';
    });
    _scheduleAutoScan();
  }

  @override
  void dispose() {
    _autoScanTimer?.cancel();
    _laserController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Color get _accentColor {
    switch (_visualState) {
      case _ScannerVisualState.matched:
        return const Color(0xFF00FFA3); // Neon Green / Mint Hunter
      case _ScannerVisualState.mismatched:
        return const Color(0xFFFF0055); // Crimson Red Alert
      case _ScannerVisualState.processing:
        return const Color(0xFFB026FF); // Neon Purple
      case _ScannerVisualState.error:
        return const Color(0xFFFF5252);
      case _ScannerVisualState.initializing:
      case _ScannerVisualState.scanning:
        return const Color(0xFF00F4FE); // Neon Cyan
    }
  }

  double get _cameraScale {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return 1.0;
    }
    const double containerAspect = 220.0 / 260.0;
    var scale = containerAspect * controller.value.aspectRatio;
    if (scale < 1.0) scale = 1.0 / scale;
    return scale;
  }

  @override
  Widget build(BuildContext context) {
    final Color currentAccent = _accentColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: const Color(0xFF140D24),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: currentAccent.withValues(alpha: 0.7),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: currentAccent.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 2,
            ),
            const BoxShadow(
              color: Color(0xFF0B0714),
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
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentAccent,
                        boxShadow: [
                          BoxShadow(
                            color: currentAccent,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.mode == FaceScanMode.enroll
                          ? 'FACE BIOMETRIC ENROLLMENT'
                          : 'REAL-TIME FACE SCANNER',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: currentAccent,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF231D2B),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: currentAccent.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    widget.mode == FaceScanMode.enroll
                        ? 'SAVE: HIVE'
                        : 'CAM: LIVE',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: currentAccent,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Live Viewfinder Reticle
            SizedBox(
              width: 230,
              height: 270,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Live Camera Stream atau Loading/Error Placeholder
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 220,
                      height: 260,
                      color: const Color(0xFF0A0612),
                      child: (_cameraController != null &&
                              _cameraController!.value.isInitialized)
                          ? ClipRect(
                              child: Transform.scale(
                                scale: _cameraScale,
                                child: Center(
                                  child: CameraPreview(_cameraController!),
                                ),
                              ),
                            )
                          : Center(
                              child: _visualState == _ScannerVisualState.error
                                  ? const Icon(Icons.videocam_off_rounded,
                                      size: 48, color: Color(0xFFFF5252))
                                  : CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          currentAccent),
                                    ),
                            ),
                    ),
                  ),

                  // Overlay Hologram Tint
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 220,
                      height: 260,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            currentAccent.withValues(alpha: 0.12),
                            Colors.transparent,
                            const Color(0xFFB026FF).withValues(alpha: 0.12),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Oval Face Guide Reticle
                  IgnorePointer(
                    child: Container(
                      width: 175,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(90),
                        border: Border.all(
                          color: currentAccent.withValues(alpha: 0.65),
                          width: 1.8,
                        ),
                      ),
                    ),
                  ),

                  // Corner Brackets
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: currentAccent, width: 3),
                          left: BorderSide(color: currentAccent, width: 3),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: currentAccent, width: 3),
                          right: BorderSide(color: currentAccent, width: 3),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: currentAccent, width: 3),
                          left: BorderSide(color: currentAccent, width: 3),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: currentAccent, width: 3),
                          right: BorderSide(color: currentAccent, width: 3),
                        ),
                      ),
                    ),
                  ),

                  // Animasi Laser Scan Line
                  if (_visualState == _ScannerVisualState.scanning ||
                      _visualState == _ScannerVisualState.processing)
                    AnimatedBuilder(
                      animation: _laserAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: 15 + (_laserAnimation.value * 230),
                          left: 15,
                          right: 15,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  currentAccent,
                                  Colors.white,
                                  currentAccent,
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: currentAccent.withValues(alpha: 0.95),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  // State Indicator Icon Overlay (Matched / Mismatched)
                  if (_visualState == _ScannerVisualState.matched)
                    Container(
                      width: 220,
                      height: 260,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FFA3).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.verified_rounded,
                          size: 72,
                          color: Color(0xFF00FFA3),
                        ),
                      ),
                    ),

                  if (_visualState == _ScannerVisualState.mismatched)
                    Container(
                      width: 220,
                      height: 260,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0055).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.gpp_bad_rounded,
                          size: 72,
                          color: Color(0xFFFF0055),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Telemetri Status Wajah
            Text(
              _statusText,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: currentAccent,
              ),
            ),

            if (_lastScore != null) ...[
              const SizedBox(height: 4),
              Text(
                'SKOR KECOCOKAN: ${_lastScore!.toStringAsFixed(1)}% (SYARAT: >= 70.0%)',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _lastScore! >= 70.0
                      ? const Color(0xFF00FFA3)
                      : const Color(0xFFFF0055),
                ),
              ),
            ],

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF280B15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFFFF0055).withValues(alpha: 0.5)),
                ),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9.5,
                    color: const Color(0xFFFFB4AB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Tombol Aksi
            if (_visualState == _ScannerVisualState.mismatched ||
                _visualState == _ScannerVisualState.error) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF383241)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'BATAL',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9B8BA1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _retryScan,
                      child: Text(
                        _visualState == _ScannerVisualState.error
                            ? 'COBA LAGI'
                            : 'PINDAI ULANG',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF383241)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'BATALKAN',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9B8BA1),
                        ),
                      ),
                    ),
                  ),
                  if (_visualState == _ScannerVisualState.scanning) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _executeScan,
                        child: Text(
                          widget.mode == FaceScanMode.enroll
                              ? 'REKAM WAJAH'
                              : 'PINDAI SEKARANG',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
