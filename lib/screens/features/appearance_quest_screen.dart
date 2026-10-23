import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppearanceQuestScreen
/// Layar penuh / modal detail Protokol Penampilan (Appearance Protocol)
/// Bertema Solo Leveling (Shadow Awakening HUD).
/// Sesuai PRD LevMax: 5 Sub-Quest perawatan diri dengan checkbox kustom bercahaya neon.
class AppearanceQuestScreen extends StatefulWidget {
  const AppearanceQuestScreen({super.key});

  @override
  State<AppearanceQuestScreen> createState() => _AppearanceQuestScreenState();
}

class _AppearanceQuestScreenState extends State<AppearanceQuestScreen> {
  // 5 Variabel boolean state untuk masing-masing fase sub-quest
  bool isPhase1Done = false;
  bool isPhase2Done = false;
  bool isPhase3Done = false;
  bool isPhase4Done = false;
  bool isPhase5Done = false;

  /// Getter menghitung progress penyelesaian sub-quest secara dinamis
  int get completedCount => [
        isPhase1Done,
        isPhase2Done,
        isPhase3Done,
        isPhase4Done,
        isPhase5Done,
      ].where((e) => e).length;

  static const int totalCount = 5;

  bool _isPhaseDone(int index) {
    switch (index) {
      case 0:
        return isPhase1Done;
      case 1:
        return isPhase2Done;
      case 2:
        return isPhase3Done;
      case 3:
        return isPhase4Done;
      case 4:
        return isPhase5Done;
      default:
        return false;
    }
  }

  void _togglePhase(int index) {
    setState(() {
      switch (index) {
        case 0:
          isPhase1Done = !isPhase1Done;
          break;
        case 1:
          isPhase2Done = !isPhase2Done;
          break;
        case 2:
          isPhase3Done = !isPhase3Done;
          break;
        case 3:
          isPhase4Done = !isPhase4Done;
          break;
        case 4:
          isPhase5Done = !isPhase5Done;
          break;
      }
    });
  }

  final List<Map<String, dynamic>> _checklistPhases = [
    {
      'phase': 'FASE I • PAGI',
      'title': 'Cuci Muka Pagi',
      'desc': 'Bersihkan sebum dan akumulasi kotoran malam hari',
      'icon': Icons.wb_sunny_rounded,
    },
    {
      'phase': 'FASE II • HIDRASI',
      'title': 'Pakai Moisturizer Pagi',
      'desc': 'Pertahankan hidrasi dan perkuat skin barrier aktif',
      'icon': Icons.water_drop_rounded,
    },
    {
      'phase': 'FASE III • MANA SHIELD',
      'title': 'Pakai Sunscreen Pagi',
      'desc': 'Perisai radiasi UV SPF 50+ & PA++++ penangkal debu dungeon',
      'icon': Icons.shield_rounded,
    },
    {
      'phase': 'FASE IV • PURIFIKASI',
      'title': 'Cuci Muka Malam',
      'desc': 'Netralisasi polusi, keringat, dan residu kotoran harian',
      'icon': Icons.nightlight_round,
    },
    {
      'phase': 'FASE V • REGENERASI',
      'title': 'Pakai Moisturizer Malam',
      'desc': 'Regenerasi sel kulit dan recovery mana saat terlelap istirahat',
      'icon': Icons.spa_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final int currentDone = completedCount;
    final bool isAllCompleted = currentDone == totalCount;

    return Scaffold(
      backgroundColor: const Color(0xFF08050E), // Deep Abyss Black #08050E
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Top System App Bar (Header)
            _buildTopSystemAppBar(context),

            // 2. Main Protocol Container (Body Scrollable)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF110C19), // Background #110C19
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  border: const Border(
                    top: BorderSide(
                      color: Color(0xFFB026FF), // Garis neon tipis di atasnya
                      width: 1.5,
                    ),
                    left: BorderSide(color: Color(0xFF24193F), width: 1.0),
                    right: BorderSide(color: Color(0xFF24193F), width: 1.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB026FF).withValues(alpha: 0.35), // Shadow ungu #B026FF
                      blurRadius: 28,
                      spreadRadius: 2,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drag Indicator Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 6),
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF382956),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    // Scrollable Content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 3. Header Quest & Reward Box
                            _buildHeaderQuestAndReward(currentDone, totalCount),

                            const SizedBox(height: 18),

                            // Subtitle Guide Banner
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                color: const Color(0xFF160E2A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF2C1E4E),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 15,
                                    color: Color(0xFF00F4FE),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'SYSTEM MANDATE: Selesaikan seluruh fase perawatan diri untuk memperkuat Physical Aura & Dermal Defense.',
                                      style: GoogleFonts.sora(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                        height: 1.35,
                                        color: const Color(0xFFD8B4F8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 4. 5 Sub-Quest Checklist (Phase I - V)
                            ..._checklistPhases.asMap().entries.map((entry) {
                              final int index = entry.key;
                              final Map<String, dynamic> item = entry.value;
                              return _buildSubQuestChecklistItem(index, item);
                            }),

                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    // 5. Sticky Submit Button di bagian paling bawah
                    _buildStickySubmitButton(context, isAllCompleted, currentDone, totalCount),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Top System App Bar (Header)
  Widget _buildTopSystemAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Back (Kiri)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF160F2B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2C1E4E),
                width: 1.0,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: const Color(0xFFD8B4F8),
              iconSize: 18,
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Teks "SYSTEM HUD" dengan titik pulse cyan, dan "HUNTER STATUS WINDOW"
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF00F4FE), // Cyan Pulse Point
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF00F4FE),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SYSTEM HUD',
                    style: GoogleFonts.sora(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: const Color(0xFF00F4FE),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'HUNTER STATUS WINDOW',
                style: GoogleFonts.sora(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: const Color(0xFF8B829E),
                ),
              ),
            ],
          ),

          // Kanan: Badge "RANK: S" (cyan border) dan ikon Profil (background ungu)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge RANK: S dengan Cyan Border
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E1A29),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF00F4FE),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F4FE).withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  'RANK: S',
                  style: GoogleFonts.sora(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: const Color(0xFF00F4FE),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Ikon Profil dengan Background Ungu
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7B2CBF),
                  border: Border.all(
                    color: const Color(0xFFB026FF),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB026FF).withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 3. Header Quest & Reward Box
  Widget _buildHeaderQuestAndReward(int completedCount, int totalCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Info Row: "DAILY SYSTEM QUEST" & Indikator dinamis "X / 5 SELESAI"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DAILY SYSTEM QUEST',
              style: GoogleFonts.sora(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                color: const Color(0xFFB026FF),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1133),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFB026FF).withValues(alpha: 0.6),
                  width: 1.0,
                ),
              ),
              child: Text(
                '$completedCount / $totalCount SELESAI',
                style: GoogleFonts.sora(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: const Color(0xFFF3EFF5),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Judul Besar: "PROTOKOL PENAMPILAN" (Warna Cyan / efek glow)
        Text(
          'PROTOKOL PENAMPILAN',
          style: GoogleFonts.sora(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.2,
            color: const Color(0xFF00F4FE), // Cyan
            shadows: const [
              Shadow(
                color: Color(0xFF00F4FE),
                blurRadius: 16,
              ),
              Shadow(
                color: Color(0xFF0096C7),
                blurRadius: 28,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Kotak Reward: Background #1F1927. Menampilkan "+30 EXP" (ungu) dan "+20 GOLD" (emas/kuning)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1F1927), // Background #1F1927
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF33254C),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.military_tech_rounded,
                    size: 20,
                    color: Color(0xFFD8B4F8),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'REWARD PROTOKOL',
                    style: GoogleFonts.sora(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: const Color(0xFFD8B4F8),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Reward EXP (Ungu)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF150B24),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFB026FF).withValues(alpha: 0.5),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      '+30 EXP',
                      style: GoogleFonts.sora(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        color: const Color(0xFFB026FF), // Ungu #B026FF
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Reward GOLD (Emas / Kuning)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1706),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFFD166).withValues(alpha: 0.5),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      '+20 GOLD',
                      style: GoogleFonts.sora(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        color: const Color(0xFFFFD166), // Emas / Kuning #FFD166
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 4. 5 Sub-Quest Checklist (Phase I - V) dengan Checkbox Kustom & Efek Teks LineThrough
  Widget _buildSubQuestChecklistItem(int index, Map<String, dynamic> item) {
    final bool isChecked = _isPhaseDone(index);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _togglePhase(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isChecked ? const Color(0xFF18112D) : const Color(0xFF0F0A1C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isChecked
                    ? const Color(0xFFB026FF).withValues(alpha: 0.85)
                    : const Color(0xFF23183D),
                width: 1.2,
              ),
              boxShadow: isChecked
                  ? [
                      BoxShadow(
                        color: const Color(0xFFB026FF).withValues(alpha: 0.2),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Ikon Fase Perawatan
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF160F2C),
                    border: Border.all(
                      color: isChecked
                          ? const Color(0xFF00F4FE).withValues(alpha: 0.6)
                          : const Color(0xFF332454),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    size: 19,
                    color: isChecked ? const Color(0xFF00F4FE) : const Color(0xFF8B829E),
                  ),
                ),

                const SizedBox(width: 12),

                // Teks Judul & Deskripsi dengan Efek LineThrough & Opacity jika Checked
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['phase'] as String,
                        style: GoogleFonts.sora(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: isChecked ? const Color(0xFF6B6280) : const Color(0xFF8B829E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['title'] as String,
                        style: GoogleFonts.sora(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                          decorationColor: const Color(0xFF8B829E),
                          decorationThickness: 1.8,
                          color: isChecked
                              ? const Color(0xFF8B829E) // Opacity diturunkan
                              : const Color(0xFFF3EFF5),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['desc'] as String,
                        style: GoogleFonts.sora(
                          fontSize: 9.5,
                          height: 1.3,
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                          decorationColor: const Color(0xFF5D5373),
                          color: isChecked
                              ? const Color(0xFF5D5373) // Opacity diturunkan
                              : const Color(0xFF706785),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Checkbox Kustom: Container kotak. Jika checked: background ungu #B026FF + glow + ikon check putih.
                // Jika unchecked: background abu-abu gelap, ikon transparan.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isChecked ? const Color(0xFFB026FF) : const Color(0xFF1E172E),
                    border: Border.all(
                      color: isChecked ? const Color(0xFFD8B4F8) : const Color(0xFF4C386D),
                      width: 1.4,
                    ),
                    boxShadow: isChecked
                        ? [
                            BoxShadow(
                              color: const Color(0xFFB026FF).withValues(alpha: 0.85),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: const Color(0xFF00F4FE).withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: isChecked ? Colors.white : Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 5. Sticky Submit Button: Di bagian paling bawah dengan warna ungu #8A2BE2 terang dan glow shadow ungu
  Widget _buildStickySubmitButton(
    BuildContext context,
    bool isAllCompleted,
    int completedCount,
    int totalCount,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 14.0,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom + 10.0
            : 20.0,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF110C19),
        border: Border(
          top: BorderSide(
            color: Color(0xFF24193F),
            width: 1.0,
          ),
        ),
      ),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isAllCompleted
              ? const LinearGradient(
                  colors: [Color(0xFF8A2BE2), Color(0xFFB026FF)], // Ungu #8A2BE2 terang
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFF4D1D80), Color(0xFF7B2CBF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8A2BE2).withValues(alpha: isAllCompleted ? 0.65 : 0.4),
              blurRadius: 22,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // Validasi: Wajib 5 sub-quest selesai sebelum reward diklaim
              if (completedCount == 5) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Protokol Penampilan Selesai! Reward +30 EXP & +20 Gold berhasil diklaim!',
                      style: GoogleFonts.sora(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: const Color(0xFFB026FF),
                    duration: const Duration(seconds: 2),
                  ),
                );
                // Return true ke pemanggil (tab_home)
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Selesaikan semua protokol terlebih dahulu!',
                      style: GoogleFonts.sora(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: const Color(0xFF93000A), // Red error
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SUBMIT PROTOCOL',
                    style: GoogleFonts.sora(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
