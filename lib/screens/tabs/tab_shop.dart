import 'package:flutter/material.dart';

/// Tab 4: Shop Item, Konversi Mata Uang, Log Transaksi Blockchain (Boilerplate)
class TabShop extends StatefulWidget {
  const TabShop({super.key});

  @override
  State<TabShop> createState() => _TabShopState();
}

class _TabShopState extends State<TabShop> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text('Tab 4: Shop & Blockchain Ledger'),
      ),
    );
  }
}
