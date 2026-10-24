import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/hash_service.dart';
import '../../services/hive_service.dart';
import '../../services/supabase_service.dart';

/// Tab 4: Hunter Exchange & Blockchain Store (TabShop)
/// Desain bertema Solo Leveling Monarch System mengadopsi 1:1 Stitch UI
/// Dilengkapi sistem pembelian title berbasis SHA-256 Blockchain Ledger lokal.
class TabShop extends StatefulWidget {
  const TabShop({super.key});

  @override
  State<TabShop> createState() => _TabShopState();
}

class _TabShopState extends State<TabShop> {
  // Hunter Session
  String _userId = 'anonymous';
  String _username = 'HUNTER SUNG';
  String _rank = 'RANK S';
  int _gold = 650;
  int _exp = 150;
  int _hp = 3;

  // Daftar Title yang sudah dimiliki
  final Set<String> _ownedTitles = {'Wolf Slayer'};

  @override
  void initState() {
    super.initState();
    _loadSessionAndLedger();
  }

  void _loadSessionAndLedger() {
    final session = HiveService.getSession();
    final logs = HiveService.getBlockchainLogs();

    setState(() {
      _userId = session['userId']?.toString() ?? 'anonymous';
      _username = session['username']?.toString() ?? 'HUNTER SUNG';
      _rank = session['rank']?.toString() ?? 'RANK S';
      _gold = (session['gold'] as int?) ?? 650;
      _exp = (session['exp'] as int?) ?? 150;
      _hp = (session['hp'] as int?) ?? 3;

      // Masukkan item dari transaksi blockchain ke daftar milik user
      for (final log in logs) {
        if (log['item'] != null) {
          _ownedTitles.add(log['item'].toString());
        }
      }
    });
  }

  /// 1. Logika Pembelian Item & Penambahan Blok ke Rantai Blok (Blockchain)
  Future<void> _buyTitle({
    required String itemName,
    required int price,
    required String rarity,
  }) async {
    // 1. Cek apakah title sudah dimiliki
    if (_ownedTitles.contains(itemName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFF63F7FF), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Title "$itemName" sudah Anda miliki dalam arsip Hunter!',
                  style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF231D2B),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // 2. Cek apakah Gold user mencukupi
    if (_gold < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB4AB), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gold tidak mencukupi! Dibutuhkan $price Gold (Milikmu: $_gold G).',
                  style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF93000A),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // 3. Algoritma Blockchain Lokal
    // Ambil previous_hash dari transaksi terakhir di blockchainBox Hive
    final String prevHash = HiveService.getLastBlockHash();
    final String timestamp = DateTime.now().toIso8601String();

    // Gabungkan string data: userId + itemName + timestamp + previous_hash
    final String currentHash = HashService.createBlockchainHash(
      username: _userId,
      item: itemName,
      timestamp: timestamp,
      prevHash: prevHash,
    );

    // Simpan data transaksi dan hash baru ke blockchainBox Hive
    await HiveService.saveBlockchainLog(
      item: itemName,
      prevHash: prevHash,
      currentHash: currentHash,
      timestamp: timestamp,
    );

    // 4. Update Gold lokal & sesi Hive
    setState(() {
      _gold -= price;
      _ownedTitles.add(itemName);
    });

    await HiveService.saveSession(
      userId: _userId,
      username: _username,
      rank: _rank,
      exp: _exp,
      gold: _gold,
      hp: _hp,
    );

    // Sinkronisasi ke Supabase jika bukan anonymous
    if (_userId != 'anonymous') {
      await SupabaseService.updateUserStats(
        userId: _userId,
        gold: _gold,
      );
    }

    // 5. Tampilkan konfirmasi sukses dengan hash SHA-256
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_rounded, color: Colors.black, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Title "$itemName" ($rarity) Berhasil Diakuisisi!',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Blok SHA-256: ${currentHash.substring(0, 16)}...${currentHash.substring(currentHash.length - 8)}',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00F4FE),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// 2. Menampilkan BottomSheet Ledger Riwayat Transaksi Blockchain
  void _showBlockchainLedger() {
    final List<Map<String, dynamic>> logs = HiveService.getBlockchainLogs().reversed.toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.75,
        decoration: BoxDecoration(
          color: const Color(0xFF140D24),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border.all(color: const Color(0xFF00F4FE).withValues(alpha: 0.6), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
            BoxShadow(
              color: const Color(0xFF00F4FE).withValues(alpha: 0.2),
              blurRadius: 24,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF383241),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00F4FE).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.hub_rounded, color: Color(0xFF00F4FE), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BLOCKCHAIN LEDGER',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: const Color(0xFFE9DEF2),
                          ),
                        ),
                        Text(
                          'Desentralisasi Hive SHA-256 Proof',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            color: const Color(0xFF9B8BA1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F4FE).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00F4FE).withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '${logs.length} BLOK',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF00F4FE),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Info baris integritas
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1927),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2C1E4E)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: Color(0xFF63F7FF), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Seluruh transaksi tercatat berantai menggunakan SHA-256 cryptographic linkage.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        color: const Color(0xFFD2C1D7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Daftar Blok Transaksi
            Expanded(
              child: logs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade700),
                          const SizedBox(height: 10),
                          Text(
                            'Belum ada transaksi di Blockchain Ledger',
                            style: GoogleFonts.spaceGrotesk(color: const Color(0xFF9B8BA1), fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Beli title di atas untuk mencetak blok transaksi pertamamu!',
                            style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade600, fontSize: 11),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: logs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (ctx, index) {
                        final log = logs[index];
                        final String item = log['item']?.toString() ?? 'Unknown Title';
                        final String prevHash = log['prev_hash']?.toString() ?? '0000000000000000';
                        final String currentHash = log['current_hash']?.toString() ?? '0000000000000000';
                        final String timestamp = log['timestamp']?.toString() ?? '';
                        String formattedTime = timestamp;
                        try {
                          final dt = DateTime.parse(timestamp);
                          formattedTime = DateFormat('dd MMM yyyy, HH:mm:ss').format(dt);
                        } catch (_) {}

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1829),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFB026FF).withValues(alpha: 0.35),
                              width: 0.8,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.token_rounded, color: Color(0xFFFFD166), size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        item,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFFE9DEF2),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'BLOK #${logs.length - index}',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF00F4FE),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                formattedTime,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: const Color(0xFF9B8BA1),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF110C19),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'PREV: ',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFFB026FF),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            prevHash,
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 9,
                                              color: const Color(0xFFD2C1D7),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'HASH: ',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF00F4FE),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            currentHash,
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF63F7FF),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sinkronkan data sesi Hunter secara dinamis
    final session = HiveService.getSession();
    _userId = session['userId']?.toString() ?? _userId;
    _username = session['username']?.toString() ?? _username;
    _gold = (session['gold'] as int?) ?? _gold;
    _rank = session['rank']?.toString() ?? _rank;

    return Scaffold(
      backgroundColor: const Color(0xFF16111E),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Bar
              _buildHeaderBar(),

              const SizedBox(height: 12),

              // 2. Protocol DEX Bar & Vault Balance
              _buildProtocolBar(),

              const SizedBox(height: 14),

              // 3. Vault & Treasury Hero Banner
              _buildHeroBanner(),

              const SizedBox(height: 14),

              // 4. Real-time Currency Valuation Card
              _buildValuationCard(),

              const SizedBox(height: 18),

              // 5. Exclusive Titles Section Header
              _buildTitlesSectionHeader(),

              const SizedBox(height: 12),

              // Title 1: Shadow Monarch (300 Gold - Mythic)
              _buildTitleCard(
                title: 'Shadow Monarch',
                subtitle: 'TITLE: THE LORD OF SHADOWS',
                rarity: 'MYTHIC',
                price: 300,
                perk: '+15% Mana Resonance & Dark Aura',
                icon: Icons.shield_moon_rounded,
                rarityColor: const Color(0xFFB026FF),
                accentColor: const Color(0xFF00F4FE),
              ),

              const SizedBox(height: 14),

              // Title 2: Wolf Slayer (150 Gold - Rare)
              _buildTitleCard(
                title: 'Wolf Slayer',
                subtitle: 'TITLE: RAZOR FANG DESTROYER',
                rarity: 'RARE',
                price: 150,
                perk: '+8% Agility in Dungeon Radar',
                icon: Icons.pets_rounded,
                rarityColor: const Color(0xFF00DCE5),
                accentColor: const Color(0xFF63F7FF),
              ),

              const SizedBox(height: 14),

              // Title 3: Sovereign Commander (500 Gold - Ancient)
              _buildTitleCard(
                title: 'Sovereign Commander',
                subtitle: 'TITLE: SUPREME GUILD LEADER',
                rarity: 'ANCIENT',
                price: 500,
                perk: '+25% EXP Multiplier from Daily Quests',
                icon: Icons.workspace_premium_rounded,
                rarityColor: const Color(0xFFFFD166),
                accentColor: const Color(0xFFE5B5FF),
              ),

              const SizedBox(height: 16),

              // 6. Blockchain Ledger Explorer Button
              _buildBlockchainLedgerButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Header Bar
  Widget _buildHeaderBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2736),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _rank,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: const Color(0xFF00F4FE),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'SYSTEM',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE5B5FF),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00F4FE),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Exchange Shop',
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE9DEF2),
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1927),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFE6FEFF)),
                  const SizedBox(width: 3),
                  Text(
                    '100%',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE6FEFF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Builder(
              builder: (context) {
                final avatarUrl = HiveService.getSession()['avatar_url']?.toString();
                return Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFB026FF),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB026FF).withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            avatarUrl,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.person, size: 18, color: Colors.white),
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.person_rounded, size: 18, color: Colors.white),
                        ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Top Protocol Bar & Vault Balance
  Widget _buildProtocolBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2736),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00F4FE),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F4FE).withValues(alpha: 0.8),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'PROTOCOL: DEX_V2.4',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: const Color(0xFF00F4FE),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2736),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD166).withValues(alpha: 0.15),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.monetization_on_rounded, size: 14, color: Color(0xFFFFD166)),
              const SizedBox(width: 4),
              Text(
                '$_gold GOLD',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFFD166),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Hero Banner
  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF110C19),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C1E4E), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB026FF).withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.currency_exchange_rounded, size: 16, color: Color(0xFF00F4FE)),
              const SizedBox(width: 6),
              Text(
                'VAULT & TREASURY PROTOCOL',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: const Color(0xFF00F4FE),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'HUNTER EXCHANGE',
            style: GoogleFonts.sora(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: const Color(0xFFF4D9FF),
              shadows: [
                Shadow(
                  color: const Color(0xFFB026FF).withValues(alpha: 0.5),
                  blurRadius: 16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Akuisisi Gelar Kehormatan & pantau kurs konversi multi-mata uang terdesentralisasi secara real-time.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFFD2C1D7),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INDEX STABILITY',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF9B8BA1),
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    '99.98% OPTIMAL',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF63F7FF),
                    ),
                  ),
                ],
              ),
              // Sparkline chart
              SizedBox(
                width: 110,
                height: 26,
                child: CustomPaint(
                  painter: _SparklinePainter(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Real-Time Valuation Card
  Widget _buildValuationCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1927),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2C1E4E), width: 0.8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.query_stats_rounded, size: 15, color: Color(0xFFDCB8FC)),
                  const SizedBox(width: 6),
                  Text(
                    'KURS VALUASI REAL-TIME',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: const Color(0xFFE9DEF2),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00F4FE).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sync_rounded, size: 10, color: Color(0xFF00F4FE)),
                    const SizedBox(width: 3),
                    Text(
                      'SYNCED',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF00F4FE),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF110C19),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '100 GOLD = Rp 15.000 • \$1.00 USD • €0.95 EUR',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: const Color(0xFF00F4FE),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildCurrencyPod('IDR (RUPIAH)', 'Rp 150', '/ 1 Gold'),
              const SizedBox(width: 8),
              _buildCurrencyPod('USD (DOLLAR)', '\$0.01', '/ 1 Gold'),
              const SizedBox(width: 8),
              _buildCurrencyPod('EUR (EURO)', '€0.0095', '/ 1 Gold'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyPod(String currency, String rate, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF231D2B),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              currency,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9B8BA1),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              rate,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFE9DEF2),
              ),
            ),
            Text(
              unit,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 8,
                color: const Color(0xFF63F7FF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section Header: Exclusive Titles & Relics
  Widget _buildTitlesSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.military_tech_rounded, size: 18, color: Color(0xFFE5B5FF)),
            const SizedBox(width: 6),
            Text(
              'EXCLUSIVE TITLES & RELICS',
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: const Color(0xFFE9DEF2),
              ),
            ),
          ],
        ),
        Text(
          '3 AVAILABLE',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: const Color(0xFFE5B5FF),
          ),
        ),
      ],
    );
  }

  /// Single Title Card with Relic preview & Acquire Button
  Widget _buildTitleCard({
    required String title,
    required String subtitle,
    required String rarity,
    required int price,
    required String perk,
    required IconData icon,
    required Color rarityColor,
    required Color accentColor,
  }) {
    final bool isOwned = _ownedTitles.contains(title);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1927),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOwned
              ? const Color(0xFF00F4FE).withValues(alpha: 0.3)
              : rarityColor.withValues(alpha: 0.35),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: rarityColor.withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row Header: Icon + Name + Rarity & Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2736),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: rarityColor.withValues(alpha: 0.4)),
                    ),
                    child: Icon(icon, size: 24, color: rarityColor),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subtitle,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: rarityColor,
                        ),
                      ),
                      Text(
                        title,
                        style: GoogleFonts.sora(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE9DEF2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: rarityColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      rarity,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: rarityColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$price GOLD',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFFD166),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Perk Badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF110C19),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2C1E4E)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, size: 14, color: accentColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    perk,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD2C1D7),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Action Button
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: isOwned
                ? null
                : () => _buyTitle(itemName: title, price: price, rarity: rarity),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: isOwned
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF00F4FE), Color(0xFFB026FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                color: isOwned ? const Color(0xFF2D2736) : null,
                border: isOwned
                    ? Border.all(color: const Color(0xFF00F4FE).withValues(alpha: 0.5))
                    : null,
                boxShadow: isOwned
                    ? null
                    : [
                        BoxShadow(
                          color: const Color(0xFF00F4FE).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOwned ? Icons.check_circle_rounded : Icons.verified_rounded,
                    size: 16,
                    color: isOwned ? const Color(0xFF00F4FE) : Colors.black,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOwned
                        ? 'TITLE ACQUIRED (OWNED)'
                        : 'ACQUIRE TITLE • $price GOLD',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: isOwned ? const Color(0xFF00F4FE) : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Blockchain Ledger Explorer Button
  Widget _buildBlockchainLedgerButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _showBlockchainLedger,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF00F4FE), Color(0xFFB026FF), Color(0xFF00F4FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F4FE).withValues(alpha: 0.25),
              blurRadius: 18,
            ),
          ],
        ),
        padding: const EdgeInsets.all(1.5),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F1927),
            borderRadius: BorderRadius.circular(10.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2736),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.hub_rounded, size: 18, color: Color(0xFF00F4FE)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Lihat Log Transaksi Blockchain (Ledger)',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE9DEF2),
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFF00F4FE)),
            ],
          ),
        ),
      ),
    );
  }
}

/// CustomPainter untuk grafik sparkline stabilitas indeks
class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(2, size.height * 0.7);
    path.lineTo(size.width * 0.15, size.height * 0.65);
    path.lineTo(size.width * 0.3, size.height * 0.8);
    path.lineTo(size.width * 0.45, size.height * 0.4);
    path.lineTo(size.width * 0.6, size.height * 0.5);
    path.lineTo(size.width * 0.75, size.height * 0.25);
    path.lineTo(size.width * 0.88, size.height * 0.45);
    path.lineTo(size.width, size.height * 0.1);

    final strokePaint = Paint()
      ..color = const Color(0xFF00F4FE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(2, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x4D00F4FE), Color(0x0000F4FE)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
