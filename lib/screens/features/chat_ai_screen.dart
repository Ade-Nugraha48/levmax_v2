import 'package:flutter/material.dart';

/// Halaman / Modal Konsultasi Hunter AI berbasis Google Generative AI (Boilerplate)
class ChatAiScreen extends StatefulWidget {
  const ChatAiScreen({super.key});

  @override
  State<ChatAiScreen> createState() => _ChatAiScreenState();
}

class _ChatAiScreenState extends State<ChatAiScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Hunter AI Consultation Screen'),
        ),
      ),
    );
  }
}
