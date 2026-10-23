import 'package:flutter/material.dart';

/// Tab 1: Dashboard Hunter, Daftar Quest, Waktu Server 4 Zona (Boilerplate)
class TabHome extends StatefulWidget {
  const TabHome({super.key});

  @override
  State<TabHome> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text('Tab 1: Home Dashboard & Quests'),
      ),
    );
  }
}
