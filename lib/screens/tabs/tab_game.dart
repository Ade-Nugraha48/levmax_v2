import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// Tab 3: Mini Game Mana Balancer (Sensor Gyroscope)
class TabGame extends StatefulWidget {
  const TabGame({super.key});

  @override
  State<TabGame> createState() => _TabGameState();
}

class _TabGameState extends State<TabGame> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0713),
      body: SafeArea(
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
                      color: AppColors.neonViolet.withOpacity(0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonViolet.withOpacity(0.25),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.sports_esports_rounded,
                      size: 36,
                      color: AppColors.neonViolet,
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
                  child: const Text(
                    'SYSTEM PROTOCOL • STANDBY',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Color(0xFFD8B4F8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'MANA BALANCER (MINI GAME)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Color(0xFFF3EFF5),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Latihan Fokus Mana dengan Sensor Gyroscope',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 11.5,
                    color: Color(0xFF8B829E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
