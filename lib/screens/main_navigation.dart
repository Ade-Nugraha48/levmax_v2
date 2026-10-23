import 'package:flutter/material.dart';
import 'package:levmax_v2/screens/tabs/tab_home.dart';
import 'package:levmax_v2/screens/tabs/tab_map.dart';
import 'package:levmax_v2/screens/tabs/tab_game.dart';
import 'package:levmax_v2/screens/tabs/tab_shop.dart';
import 'package:levmax_v2/screens/tabs/tab_profile.dart';

/// Induk navigasi 5 Tab utama LevMax menggunakan IndexedStack dan StatefulWidget murni
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    TabHome(),
    TabMap(),
    TabGame(),
    TabShop(),
    TabProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Portal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports_outlined),
            activeIcon: Icon(Icons.sports_esports),
            label: 'Game',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
