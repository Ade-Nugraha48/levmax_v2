import 'package:flutter/material.dart';

/// Tab 3: Mini Game Gyroscope "Balance the Mana Core" (Boilerplate)
class TabGame extends StatefulWidget {
  const TabGame({super.key});

  @override
  State<TabGame> createState() => _TabGameState();
}

class _TabGameState extends State<TabGame> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text('Tab 3: Gyroscope Mini Game'),
      ),
    );
  }
}
