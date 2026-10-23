import 'package:flutter/material.dart';

/// Palet warna utama LevMax dengan tema visual Solo Leveling (Shadow Monarch System).
/// Karakteristik visual: Black Deep Void, Shadow Monarch Purple, Neon Violet, dan Indigo Glow.
class AppColors {
  // Brand & Monarch Glow Colors
  static const Color primary = Color(0xFF8A2BE2); // Shadow Monarch Purple (BlueViolet)
  static const Color neonViolet = Color(0xFFB026FF); // Neon Violet Electric Glow
  static const Color accent = Color(0xFFC084FC); // Light Monarch Lavender
  static const Color indigoGlow = Color(0xFF160F2C); // Indigo Glow Ambient Base
  static const Color manaBlue = Color(0xFF38BDF8); // Cyan Mana Glow

  // Dark Void Backgrounds & Surfaces
  static const Color background = Color(0xFF0B0713); // Black Deep Void
  static const Color surface = Color(0xFF160F2C); // Indigo Glow Surface
  static const Color surfaceElevated = Color(0xFF1E153B); // Elevated Monarch Surface
  static const Color surfaceHighlight = Color(0xFF2A1C52); // Highlighted Container

  // Borders & Glow Strokes
  static const Color border = Color(0xFF2E2256); // Subtle Indigo Border
  static const Color borderGlow = Color(0xFFB026FF); // Active / Focused Neon Glow
  static const Color divider = Color(0xFF241A42);

  // Typography Colors
  static const Color textPrimary = Color(0xFFF8FAFC); // Crisp System White
  static const Color textSecondary = Color(0xFFA5B4CB); // Muted Indigo Slate
  static const Color textMuted = Color(0xFF6B7280); // Darker Helper Gray
  static const Color textDisabled = Color(0xFF4B5563);

  // Status & Mechanics Colors
  static const Color hpRed = Color(0xFFFF3366); // Health Points / Penalty Crimson
  static const Color hpRedDark = Color(0xFF990026);
  static const Color gold = Color(0xFFFFD700); // Hunter Gold
  static const Color goldDark = Color(0xFFB8860B);
  static const Color expBar = Color(0xFF8A2BE2); // EXP Progression Purple
  static const Color expBarGlow = Color(0xFFB026FF);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);

  // Rank Colors (F -> E -> D -> C -> B -> A -> S)
  static const Color rankF = Color(0xFF9CA3AF); // Gray / Silver
  static const Color rankE = Color(0xFF10B981); // Emerald Green
  static const Color rankD = Color(0xFF06B6D4); // Cyan
  static const Color rankC = Color(0xFF3B82F6); // Royal Blue
  static const Color rankB = Color(0xFF8B5CF6); // Purple
  static const Color rankA = Color(0xFFD946EF); // Magenta Pink
  static const Color rankS = Color(0xFFB026FF); // Sovereign Neon Violet

  // Gradients Solo Leveling System
  static const LinearGradient monarchGradient = LinearGradient(
    colors: [Color(0xFF8A2BE2), Color(0xFFB026FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF160F2C), Color(0xFF0B0713)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient portalGradient = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFF8A2BE2), Color(0xFFB026FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Tipografi khas sistem Solo Leveling / Game HUD
class AppTextStyles {
  // System Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // System Notification / Quest Title
  static const TextStyle systemTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.neonViolet,
    letterSpacing: 0.8,
  );

  // Body Texts
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.35,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.2,
  );

  // Monospaced for Blockchain Hash, Coordinates, Timers
  static const TextStyle mono = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle monoAccent = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w700,
    color: AppColors.neonViolet,
  );

  // Rank Display Badge
  static const TextStyle rankBadge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.2,
  );
}

/// Konstanta Aturan Main & Game Mechanics LevMax
class AppConstants {
  // App Identifiers
  static const String appName = 'LevMax';
  static const String appTagline = 'The Hunter Awakening System';

  // Hive Box Names
  static const String sessionBox = 'sessionBox';
  static const String blockchainBox = 'blockchainBox';
  static const String questBox = 'questBox';

  // Game Limits
  static const int maxHp = 3;
  static const int minDailyQuests = 3;
  static const int gyroHoldSeconds = 5;
  static const double portalClaimRadiusMeters = 100.0;

  // Currency Conversions (100 Gold Reference)
  static const int goldReferenceUnit = 100;
  static const int goldToIdrRate = 15000;
  static const double goldToUsdRate = 1.00;
  static const double goldToEurRate = 0.95;

  // Rank Thresholds (EXP)
  static const int expRankE = 100;
  static const int expRankD = 300;
  static const int expRankC = 600;
  static const int expRankB = 1000;
  static const int expRankA = 1500;
  static const int expRankS = 2500;

  /// Helper untuk kalkulasi Rank berdasarkan total akumulasi EXP
  static String calculateRank(int exp) {
    if (exp >= expRankS) return 'S';
    if (exp >= expRankA) return 'A';
    if (exp >= expRankB) return 'B';
    if (exp >= expRankC) return 'C';
    if (exp >= expRankD) return 'D';
    if (exp >= expRankE) return 'E';
    return 'F';
  }

  /// Warna badge berdasarkan Rank
  static Color getRankColor(String rank) {
    switch (rank.toUpperCase()) {
      case 'S':
        return AppColors.rankS;
      case 'A':
        return AppColors.rankA;
      case 'B':
        return AppColors.rankB;
      case 'C':
        return AppColors.rankC;
      case 'D':
        return AppColors.rankD;
      case 'E':
        return AppColors.rankE;
      case 'F':
      default:
        return AppColors.rankF;
    }
  }

  /// Batas EXP dasar Rank saat ini
  static int getRankBaseExp(String rank) {
    switch (rank.toUpperCase()) {
      case 'S':
        return expRankS;
      case 'A':
        return expRankA;
      case 'B':
        return expRankB;
      case 'C':
        return expRankC;
      case 'D':
        return expRankD;
      case 'E':
        return expRankE;
      case 'F':
      default:
        return 0;
    }
  }

  /// Target batas EXP untuk promosi ke Rank selanjutnya
  static int getNextRankExp(String rank) {
    switch (rank.toUpperCase()) {
      case 'F':
        return expRankE;
      case 'E':
        return expRankD;
      case 'D':
        return expRankC;
      case 'C':
        return expRankB;
      case 'B':
        return expRankA;
      case 'A':
        return expRankS;
      case 'S':
      default:
        return expRankS;
    }
  }

  // Layout Dimensions & Paddings
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusPill = 999.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Box Shadow Glow Effect bertema Solo Leveling Shadow Monarch
  static List<BoxShadow> monarchGlow({
    Color color = AppColors.neonViolet,
    double blurRadius = 14,
    double spreadRadius = 1,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.35),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
  }
}

/// Konfigurasi ThemeData Resmi LevMax (Solo Leveling Dark-Purple Theme)
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.neonViolet,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.hpRed,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.surfaceElevated,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.neonViolet,
          side: const BorderSide(color: AppColors.neonViolet, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: AppColors.neonViolet, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: AppColors.hpRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          borderSide: const BorderSide(color: AppColors.hpRed, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.neonViolet,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          side: const BorderSide(color: AppColors.neonViolet, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        titleTextStyle: AppTextStyles.heading2,
        contentTextStyle: AppTextStyles.body,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
