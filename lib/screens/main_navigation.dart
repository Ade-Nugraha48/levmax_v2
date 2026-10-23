import 'package:flutter/material.dart';
import 'tabs/tab_home.dart';
import 'tabs/tab_map.dart';
import 'tabs/tab_game.dart';
import 'tabs/tab_shop.dart';
import 'tabs/tab_profile.dart';

/// Induk navigasi 5 Tab utama LevMax menggunakan IndexedStack dan StatefulWidget murni
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
    _tabs = const [
      TabHome(),
      TabMap(),
      TabGame(),
      TabShop(),
      TabProfile(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0713), // Deep Abyss Black
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F0A1C), // Midnight Abyss Bar
          border: const Border(
            top: BorderSide(
              color: Color(0xFF2C1E4E),
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  label: 'Home',
                  icon: Icons.dashboard_customize_rounded,
                ),
                _buildNavItem(
                  index: 1,
                  label: 'Radar LBS',
                  icon: Icons.explore_rounded,
                ),
                _buildNavItem(
                  index: 2,
                  label: 'Mana Game',
                  icon: Icons.videogame_asset_rounded,
                ),
                _buildNavItem(
                  index: 3,
                  label: 'Shop',
                  icon: Icons.shopping_bag_outlined,
                ),
                _buildNavItem(
                  index: 4,
                  label: 'Profile',
                  icon: Icons.shield_moon_rounded,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E1338) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: const Color(0xFF8A2BE2).withValues(alpha: 0.5),
                  width: 1.0,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFB026FF).withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: isSelected
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB026FF).withValues(alpha: 0.6),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    )
                  : null,
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? const Color(0xFFB026FF) : const Color(0xFF6E6485),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                letterSpacing: 0.2,
                color: isSelected ? const Color(0xFFF3EFF5) : const Color(0xFF6E6485),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
