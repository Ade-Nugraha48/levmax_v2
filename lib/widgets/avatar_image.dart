import 'dart:io';
import 'package:flutter/material.dart';

/// Widget pembungkus cerdas untuk merender avatar Hunter.
/// Mendukung network URL (Supabase Storage) dan local File path (offline fallback),
/// dengan fallback otomatis ke Icon bawaan jika URL null atau error saat dimuat.
class HunterAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double size;
  final Widget fallback;
  final BorderRadius? borderRadius;

  const HunterAvatar({
    super.key,
    required this.avatarUrl,
    required this.size,
    required this.fallback,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return fallback;
    }

    final url = avatarUrl!;
    Widget imageWidget;

    if (url.startsWith('http://') || url.startsWith('https://')) {
      imageWidget = Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    } else {
      final file = File(url);
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallback,
        );
      } else {
        return fallback;
      }
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return ClipOval(child: imageWidget);
  }
}
