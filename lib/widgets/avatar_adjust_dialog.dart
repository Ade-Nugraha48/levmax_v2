import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

/// Dialog interaktif untuk menyesuaikan foto avatar Hunter sebelum diunggah.
/// Mendukung pan, pinch-to-zoom, rotasi 90 derajat, dan reset posisi,
/// lalu memotong (crop) tepat sesuai frame 1:1 kotak Solo Leveling System.
class AvatarAdjustDialog extends StatefulWidget {
  final File imageFile;

  const AvatarAdjustDialog({super.key, required this.imageFile});

  @override
  State<AvatarAdjustDialog> createState() => _AvatarAdjustDialogState();
}

class _AvatarAdjustDialogState extends State<AvatarAdjustDialog> {
  final GlobalKey _cropKey = GlobalKey();
  final TransformationController _transformController = TransformationController();
  int _quarterTurns = 0;
  bool _isProcessing = false;

  void _rotateClockwise() {
    setState(() {
      _quarterTurns = (_quarterTurns + 1) % 4;
    });
  }

  void _rotateCounterClockwise() {
    setState(() {
      _quarterTurns = (_quarterTurns + 3) % 4;
    });
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
    setState(() {
      _quarterTurns = 0;
    });
  }

  Future<void> _applyCrop() async {
    setState(() => _isProcessing = true);
    try {
      final boundary = _cropKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      // Render crisp 2.5x pixel ratio for high quality avatar (approx 650x650)
      final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final croppedFile = File('${tempDir.path}/avatar_cropped_${DateTime.now().millisecondsSinceEpoch}.png');
      await croppedFile.writeAsBytes(pngBytes);

      if (mounted) {
        Navigator.pop(context, croppedFile);
      }
    } catch (e) {
      debugPrint('Error cropping avatar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyesuaikan foto: $e', style: GoogleFonts.spaceGrotesk()),
            backgroundColor: const Color(0xFF93000A),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double viewportSize = (MediaQuery.of(context).size.width - 64).clamp(240.0, 300.0);

    return Dialog(
      backgroundColor: const Color(0xFF140D24),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF2C1E4E), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.crop_rotate_rounded, color: Color(0xFF00F4FE), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'ADJUST HUNTER AVATAR',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: const Color(0xFF00F4FE),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF9B8BA1), size: 20),
                  onPressed: () => Navigator.pop(context, null),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Cubit untuk zoom, geser posisi foto, dan sesuaikan dalam frame kotak.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                color: const Color(0xFF9B8BA1),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),

            // Square Viewport Area
            Container(
              width: viewportSize,
              height: viewportSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB026FF).withValues(alpha: 0.25),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Captured Cropped Area
                  RepaintBoundary(
                    key: _cropKey,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: viewportSize,
                        height: viewportSize,
                        color: const Color(0xFF0A0514),
                        child: InteractiveViewer(
                          transformationController: _transformController,
                          minScale: 0.5,
                          maxScale: 4.5,
                          boundaryMargin: const EdgeInsets.all(120),
                          clipBehavior: Clip.hardEdge,
                          child: Center(
                            child: RotatedBox(
                              quarterTurns: _quarterTurns,
                              child: Image.file(
                                widget.imageFile,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Cyberpunk Outer Frame Overlay (Outside RepaintBoundary so not burned into image)
                  IgnorePointer(
                    child: Container(
                      width: viewportSize,
                      height: viewportSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF00F4FE).withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // 4 Corner neon markers
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Color(0xFF00F4FE), width: 3),
                                  left: BorderSide(color: Color(0xFF00F4FE), width: 3),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Color(0xFF00F4FE), width: 3),
                                  right: BorderSide(color: Color(0xFF00F4FE), width: 3),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFF00F4FE), width: 3),
                                  left: BorderSide(color: Color(0xFF00F4FE), width: 3),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFF00F4FE), width: 3),
                                  right: BorderSide(color: Color(0xFF00F4FE), width: 3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Controls Row (Rotate Left, Reset, Rotate Right)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildToolButton(
                  icon: Icons.rotate_left_rounded,
                  label: 'Putar Kiri',
                  onTap: _rotateCounterClockwise,
                ),
                const SizedBox(width: 12),
                _buildToolButton(
                  icon: Icons.restart_alt_rounded,
                  label: 'Reset',
                  onTap: _resetZoom,
                ),
                const SizedBox(width: 12),
                _buildToolButton(
                  icon: Icons.rotate_right_rounded,
                  label: 'Putar Kanan',
                  onTap: _rotateClockwise,
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Bottom Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : () => Navigator.pop(context, null),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFF383241)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'BATAL',
                      style: GoogleFonts.spaceGrotesk(
                        color: const Color(0xFF9B8BA1),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _applyCrop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00F4FE),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                      shadowColor: const Color(0xFF00F4FE).withValues(alpha: 0.5),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : Text(
                            'TERAPKAN & SIMPAN',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 0.6,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1927),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF383241), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: const Color(0xFF00F4FE)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE9DEF2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
