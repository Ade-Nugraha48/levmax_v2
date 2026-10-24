import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import 'tabs/tab_home.dart';
import 'tabs/tab_map.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // 5 Tab Screens disiapkan dengan IndexedStack agar state tidak reload
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const TabHome(),
      const TabMap(),
      const _PlaceholderTab(
        title: 'MANA BALANCER (MINI GAME)',
        subtitle: 'Latihan Fokus Mana dengan Sensor Gyroscope',
        icon: Icons.screen_rotation_outlined,
        accentColor: AppColors.neonViolet,
      ),
      const _PlaceholderTab(
        title: 'HUNTER SHOP & LEDGER',
        subtitle: 'Toko Item Title, Kurs Mata Uang & Blockchain Hive',
        icon: Icons.token_outlined,
        accentColor: AppColors.goldAccent,
      ),
      const _PlaceholderTab(
        title: 'HUNTER PROFILE & DOSEN FEEDBACK',
        subtitle: 'Statistik Akun, Kesan Pesan Matkul, & Sesi Logout',
        icon: Icons.shield_outlined,
        accentColor: AppColors.textLavender,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16111E), // Deep Abyss Surface
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF110C19), // Midnight Abyss Bar (#110C19)
          border: const Border(
            top: BorderSide(
              color: Color(0xFF2C1E4E),
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  label: 'QUESTS',
                  icon: Icons.space_dashboard_outlined,
                  activeIcon: Icons.space_dashboard_rounded,
                ),
                _buildNavItem(
                  index: 1,
                  label: 'DUNGEON',
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore_rounded,
                ),
                _buildNavItem(
                  index: 2,
                  label: 'MANA',
                  icon: Icons.screen_rotation_outlined,
                  activeIcon: Icons.screen_rotation_rounded,
                ),
                _buildNavItem(
                  index: 3,
                  label: 'EXCHANGE',
                  icon: Icons.token_outlined,
                  activeIcon: Icons.token_rounded,
                ),
                _buildNavItem(
                  index: 4,
                  label: 'STATUS',
                  icon: Icons.shield_outlined,
                  activeIcon: Icons.shield_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon dengan Glow Neon Ungu (#B026FF) jika aktif
            Stack(
              alignment: Alignment.center,
              children: [
                if (isSelected)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB026FF).withValues(alpha: 0.65),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 22,
                  color: isSelected
                      ? const Color(0xFFE5B5FF)
                      : const Color(0xFF6E6485),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.8,
                color: isSelected
                    ? const Color(0xFFE5B5FF)
                    : const Color(0xFF6E6485),
                shadows: isSelected
                    ? [
                        Shadow(
                          color: const Color(0xFFB026FF).withValues(alpha: 0.8),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder elegan untuk Tab selain Home yang akan diimplementasikan pada tahap selanjutnya
class _PlaceholderTab extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const _PlaceholderTab({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF120D24),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 36,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF160F2C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2C1E4E)),
                ),
                child: Text(
                  'SYSTEM PROTOCOL • STANDBY',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: const Color(0xFFD8B4F8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: const Color(0xFFF3EFF5),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: const Color(0xFF8B829E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
