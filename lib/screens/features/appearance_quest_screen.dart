import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/hive_service.dart';
import '../../widgets/avatar_image.dart';

/// AppearanceQuestScreen
/// Layar Protokol Penampilan (Solo Leveling HUD Aesthetic)
/// Mengimplementasikan 5 Sub-Quest harian dengan validasi state dinamis
/// serta desain visual 1:1 persis referensi visual Solo Leveling / Stitch.
class AppearanceQuestScreen extends StatefulWidget {
  final String? currentRank;

  const AppearanceQuestScreen({
    super.key,
    this.currentRank,
  });

  @override
  State<AppearanceQuestScreen> createState() => _AppearanceQuestScreenState();
}

class _AppearanceQuestScreenState extends State<AppearanceQuestScreen> {
  String get _displayRank {
    final raw = widget.currentRank ?? HiveService.getSession()['rank']?.toString();
    if (raw == null || raw.trim().isEmpty) return 'F';
    final clean = raw.replaceAll(RegExp(r'^Rank\s*', caseSensitive: false), '').trim();
    return clean.isEmpty ? 'F' : clean;
  }
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
      backgroundColor: const Color(0xFF16111E), // Background #16111E
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // 1. Top System App Bar (Header #16111E)
                _buildTopSystemAppBar(context),

                // 2. Main Protocol Container (Body #110C19 dengan border atas bulat)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF110C19), // Midnight Abyss Inner Card
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      border: Border.all(
                        color: const Color(0xFF2C1E4E),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB026FF).withValues(alpha: 0.2),
                          blurRadius: 24,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Drag Indicator Handle
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10, bottom: 8),
                            width: 42,
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
                            padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 115.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Hero Quest Title & Mandate Box
                                _buildHeroQuestSection(currentDone),

                                const SizedBox(height: 14),

                                // System Mandate Container
                                _buildMandateBox(),

                                const SizedBox(height: 14),

                                // Reward Card
                                _buildRewardCard(),

                                const SizedBox(height: 20),

                                // Header List Protokol Fase
                                _buildProtocolListHeader(),

                                const SizedBox(height: 12),

                                // List Protokol Fase (5 Sub-Quest)
                                ..._checklistPhases.asMap().entries.map((entry) {
                                  final int index = entry.key;
                                  final Map<String, dynamic> item = entry.value;
                                  return _buildSubQuestItem(index, item);
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 5. Sticky Execution Footer
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildStickyFooter(context, isAllCompleted, currentDone),
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
          // Tombol Back Kiri
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
                  color: Color(0xFFE9DEF2),
                  size: 16,
                ),
              ),
            ),
          ),

          // Judul Tengah: SYSTEM HUD & HUNTER STATUS WINDOW
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SYSTEM HUD',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: const Color(0xFF00F4FE),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 5,
                    height: 5,
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
                ],
              ),
              const SizedBox(height: 1),
              Text(
                'HUNTER STATUS...',
                style: GoogleFonts.sora(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // Kanan: Badge RANK: S dan Avatar Profil
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge RANK: S dengan Cyan Accent & Bolt Icon
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF141E2D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF00F4FE).withValues(alpha: 0.7),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 13,
                      color: Color(0xFF00F4FE),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'RANK: $_displayRank',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: const Color(0xFF00F4FE),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Avatar Profil bundar ungu muda
              Builder(
                builder: (context) {
                  final avatarUrl = HiveService.getSession()['avatar_url']?.toString();
                  return Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD8B4F8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB026FF).withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: HunterAvatar(
                      avatarUrl: avatarUrl,
                      size: 34,
                      fallback: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: Color(0xFF1A1228),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 2. Hero Quest Title Section
  Widget _buildHeroQuestSection(int currentDone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Baris Atas: Titik Ungu Berkedip + "DAILY SYSTEM QUEST" & Pill "X / 5 SELESAI"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFB026FF),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFB026FF),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'DAILY SYSTEM QUEST',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: const Color(0xFFE5B5FF),
                  ),
                ),
              ],
            ),
            // Pill Indikator Dinamis
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1927),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF383241),
                  width: 1.0,
                ),
              ),
              child: Text(
                '$currentDone / $totalCount SELESAI',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: const Color(0xFFE9DEF2),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Judul Besar: "PROTOKOL PENAMPILAN" (Cyan dengan Shadow Glow)
        Text(
          'PROTOKOL PENAMPILAN',
          style: GoogleFonts.sora(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
            color: const Color(0xFF00F4FE),
            shadows: [
              Shadow(
                color: const Color(0xFF00F4FE).withValues(alpha: 0.8),
                blurRadius: 16,
              ),
              Shadow(
                color: const Color(0xFF0096C7).withValues(alpha: 0.5),
                blurRadius: 26,
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Subjudul: "DUNGEON ID: SEC-709 • CLASS: S-TIER BUFF"
        Text(
          'DUNGEON ID: SEC-709 • CLASS: S-TIER BUFF',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: const Color(0xFF9B8BA1),
          ),
        ),
      ],
    );
  }

  /// System Mandate Container
  Widget _buildMandateBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1927),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF383241),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1.0),
            child: Icon(
              Icons.auto_awesome,
              size: 18,
              color: Color(0xFF00F4FE),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  height: 1.45,
                  color: const Color(0xFFD2C1D7),
                ),
                children: [
                  TextSpan(
                    text: 'SYSTEM MANDATE: ',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00F4FE),
                    ),
                  ),
                  const TextSpan(
                    text: 'Selesaikan seluruh fase perawatan diri untuk memperkuat ',
                  ),
                  TextSpan(
                    text: 'Physical Aura',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE5B5FF),
                    ),
                  ),
                  const TextSpan(
                    text: ' & ',
                  ),
                  TextSpan(
                    text: 'Dermal Defense',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00F4FE),
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Reward Card
  Widget _buildRewardCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1927),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF383241),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB026FF).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ikon Medali di Kotak Ungu
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2D164D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFB026FF).withValues(alpha: 0.4),
                width: 1.0,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.military_tech_rounded,
                size: 24,
                color: Color(0xFFE5B5FF),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Label "CLEAR REWARD" & Teks "Reward Protokol"
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CLEAR REWARD',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: const Color(0xFF9B8BA1),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Reward Protokol',
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE9DEF2),
                  ),
                ),
              ],
            ),
          ),

          // Badge Kanan: +30 EXP (ungu) dan +20 GOLD (cyan)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D164D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFB026FF).withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  '+30 EXP',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE5B5FF),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2730),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF00F4FE).withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  '+20 GOLD',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00F4FE),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Header List Protokol Fase
  Widget _buildProtocolListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'PROTOKOL FASE (5)',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: const Color(0xFF9B8BA1),
          ),
        ),
        Text(
          'LIVE SYNC ACTIVE',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: const Color(0xFF00F4FE),
          ),
        ),
      ],
    );
  }

  /// 4. Sub-Quest Item (List Protokol Fase)
  Widget _buildSubQuestItem(int index, Map<String, dynamic> item) {
    final bool isChecked = _isPhaseDone(index);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        onTap: () => _togglePhase(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1F1927),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isChecked
                  ? const Color(0xFF00F4FE).withValues(alpha: 0.45)
                  : const Color(0xFF383241),
              width: 1.0,
            ),
            boxShadow: isChecked
                ? [
                    BoxShadow(
                      color: const Color(0xFFB026FF).withValues(alpha: 0.15),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Ikon Kotak Bundar di Kiri (Glowing Cyan jika Checked, Muted jika belum)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isChecked ? const Color(0xFF0A2730) : const Color(0xFF16111E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isChecked
                        ? const Color(0xFF00F4FE).withValues(alpha: 0.6)
                        : const Color(0xFF2C223A),
                    width: 1.0,
                  ),
                  boxShadow: isChecked
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00F4FE).withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    item['icon'] as IconData,
                    size: 22,
                    color: isChecked ? const Color(0xFF00F4FE) : const Color(0xFF6B6280),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Bagian Tengah: Tag Fase, Judul, Deskripsi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag Fase (Cyan jika aktif, abu-abu jika belum)
                    Text(
                      item['phase'] as String,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: isChecked ? const Color(0xFF00F4FE) : const Color(0xFF9B8BA1),
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Judul Sub-Quest (Strikethrough jika checked)
                    Text(
                      item['title'] as String,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.sora(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        decoration: isChecked ? TextDecoration.lineThrough : null,
                        decorationColor: const Color(0xFF9B8BA1),
                        decorationThickness: 1.8,
                        color: isChecked
                            ? const Color(0xFF9B8BA1).withValues(alpha: 0.6)
                            : const Color(0xFFE9DEF2),
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Deskripsi Sub-Quest (Strikethrough jika checked)
                    Text(
                      item['desc'] as String,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        decoration: isChecked ? TextDecoration.lineThrough : null,
                        decorationColor: const Color(0xFF6B6280),
                        color: isChecked
                            ? const Color(0xFF6B6280).withValues(alpha: 0.5)
                            : const Color(0xFF9B8BA1),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Checkbox Kanan: Ungu #B026FF jika checked, Abu-abu gelap jika belum
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isChecked ? const Color(0xFFB026FF) : const Color(0xFF16111E),
                  border: Border.all(
                    color: isChecked ? const Color(0xFFD8B4F8) : const Color(0xFF383241),
                    width: 1.4,
                  ),
                  boxShadow: isChecked
                      ? [
                          BoxShadow(
                            color: const Color(0xFFB026FF).withValues(alpha: 0.7),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 19,
                    color: isChecked ? Colors.white : Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 5. Sticky Execution Footer
  Widget _buildStickyFooter(
    BuildContext context,
    bool isAllCompleted,
    int currentDone,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 12.0,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom + 6.0
            : 16.0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF16111E),
        border: const Border(
          top: BorderSide(
            color: Color(0xFF24193F),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tombol SUBMIT PROTOCOL Besar
          Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: isAllCompleted
                  ? const LinearGradient(
                      colors: [Color(0xFF7B2CBF), Color(0xFFB026FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF5A1E8F), Color(0xFF7B2CBF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB026FF).withValues(alpha: isAllCompleted ? 0.65 : 0.35),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  // Validasi 5 sub-quest
                  if (currentDone == 5) {
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
                        backgroundColor: const Color(0xFF93000A),
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
                        Icons.verified_user_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SUBMIT PROTOCOL',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
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

          const SizedBox(height: 8),

          // Teks di bawah tombol: "• AUTO-SYNC WITH DUNGEON CORE"
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'AUTO-SYNC WITH DUNGEON CORE',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: const Color(0xFF9B8BA1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
