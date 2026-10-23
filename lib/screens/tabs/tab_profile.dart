import 'package:flutter/material.dart';

/// Tab 5: Profil Hunter, Form Kesan & Pesan Kuliah, Logout (Boilerplate)
class TabProfile extends StatefulWidget {
  const TabProfile({super.key});

  @override
  State<TabProfile> createState() => _TabProfileState();
}

class _TabProfileState extends State<TabProfile> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text('Tab 5: Profile & Feedback'),
      ),
    );
  }
}
