import 'package:flutter/material.dart';
import '../../services/gemini_service.dart';

/// ChatAiScreen
/// Layar Chat Dummy murni untuk pengujian fungsionalitas integrasi Gemini AI LLM.
class ChatAiScreen extends StatefulWidget {
  const ChatAiScreen({super.key});

  @override
  State<ChatAiScreen> createState() => _ChatAiScreenState();
}

class _ChatAiScreenState extends State<ChatAiScreen> {
  // 1. State Daftar Pesan ('role': 'user' | 'model', 'text': String)
  final List<Map<String, String>> _messages = [];

  // 2. State Loading & Controller
  bool _isLoading = false;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Mengirim pesan ke GeminiService dan menambahkan respon AI ke UI
  Future<void> _handleSendMessage() async {
    final String prompt = _textController.text.trim();
    if (prompt.isEmpty || _isLoading) return;

    // Tambahkan pesan user ke list
    setState(() {
      _messages.add({
        'role': 'user',
        'text': prompt,
      });
      _isLoading = true;
    });

    _textController.clear();
    _scrollToBottom();

    // Panggil GeminiService
    final String reply = await GeminiService.sendMessage(prompt);

    if (!mounted) return;

    // Tambahkan balasan AI ke list
    setState(() {
      _messages.add({
        'role': 'model',
        'text': reply,
      });
      _isLoading = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LevMax Hunter AI (Dummy Chat)'),
        actions: [
          IconButton(
            tooltip: 'Reset Sesi Chat',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              GeminiService.resetChat();
              setState(() {
                _messages.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sesi chat berhasil di-reset.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Daftar Pesan (ListView.builder)
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada percakapan.\nKetik pertanyaan seputar olahraga, nutrisi, atau strategi hunter!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12.0),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final bool isUser = msg['role'] == 'user';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar Kotak Statis Abu-abu
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isUser ? Colors.blueGrey : Colors.grey.shade700,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    isUser ? 'U' : 'AI',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Teks Pesan
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isUser ? 'Hunter (User)' : 'LevMax Assistant (AI)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isUser ? Colors.blue : Colors.purpleAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      msg['text'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Indikator Loading saat menunggu balasan AI
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'LevMax AI sedang merespon...',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

            const Divider(height: 1),

            // Input TextField dan Tombol Kirim di Bawah
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Tanyakan sesuatu pada LevMax AI...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: (_) => _handleSendMessage(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.send_rounded),
                    color: Theme.of(context).primaryColor,
                    onPressed: _isLoading ? null : _handleSendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
