import 'package:flutter/material.dart';

/// Tab 2: LBS Map & Portal Spot Klaim Hadiah (Boilerplate)
class TabMap extends StatefulWidget {
  const TabMap({super.key});

  @override
  State<TabMap> createState() => _TabMapState();
}

class _TabMapState extends State<TabMap> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text('Tab 2: LBS Map & Portal Spot'),
      ),
    );
  }
}
