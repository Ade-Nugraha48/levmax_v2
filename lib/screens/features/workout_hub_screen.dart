import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Model Checklist Standar Akurasi Biomekanik Hunter
class FormCheckpoint {
  final String title;
  final String desc;
  const FormCheckpoint({required this.title, required this.desc});
}

/// Model Protokol Latihan Biomekanik Solo Leveling
class WorkoutProtocol {
  final String id;
  final String title;
  final String tabLabel;
  final String tabSub;
  final IconData tabIcon;
  final String tag;
  final String cadencePill;
  final String activation;
  final int targetReps;
  final int defaultReps;
  final int sets;
  final String muscles;
  final String musclesSub;
  final int burnKcal;
  final int expReward;
  final int goldReward;
  final List<FormCheckpoint> checkpoints;
  final String mistake;
  final String cadence;

  const WorkoutProtocol({
    required this.id,
    required this.title,
    required this.tabLabel,
    required this.tabSub,
    required this.tabIcon,
    required this.tag,
    required this.cadencePill,
    required this.activation,
    required this.targetReps,
    required this.defaultReps,
    required this.sets,
    required this.muscles,
    required this.musclesSub,
    required this.burnKcal,
    required this.expReward,
    required this.goldReward,
    required this.checkpoints,
    required this.mistake,
    required this.cadence,
  });
}

/// WorkoutHubScreen
/// Layar interaktif Workout Hub & Guide dengan animasi vektor biomekanik Solo Leveling
/// (Push Up, Pull Up, Sit Up, Squat) berbasis CustomPaint dan state lokal murni.
class WorkoutHubScreen extends StatefulWidget {
  final String initialExercise;

  const WorkoutHubScreen({
    super.key,
    this.initialExercise = 'pushup',
  });

  @override
  State<WorkoutHubScreen> createState() => _WorkoutHubScreenState();
}

class _WorkoutHubScreenState extends State<WorkoutHubScreen>
    with SingleTickerProviderStateMixin {
  // 1. Database Protokol Latihan (Translasi Javascript protocolsData dari Stitch HTML)
  static final Map<String, WorkoutProtocol> _protocolsData = {
    'pushup': const WorkoutProtocol(
      id: 'pushup',
      title: 'PUSH UP PROTOCOL',
      tabLabel: 'PUSH UP',
      tabSub: '20 Reps',
      tabIcon: Icons.fitness_center_rounded,
      tag: 'ACTIVE VISUALIZER: PUSH UP PROTOCOL',
      cadencePill: 'CADENCE 2-1-2s',
      activation: 'MUSCLE FOCUS: CHEST & TRICEPS',
      targetReps: 20,
      defaultReps: 14,
      sets: 3,
      muscles: 'Upper Torso',
      musclesSub: 'CHEST/ARMS',
      burnKcal: 45,
      expReward: 10,
      goldReward: 5,
      checkpoints: [
        FormCheckpoint(
          title: 'Elbow Angle 45°',
          desc: 'Hindari posisi membentang 90° untuk cegah stres bahu.',
        ),
        FormCheckpoint(
          title: 'Core & Spine Locked',
          desc: 'Garis lurus dari tumit hingga kepala tanpa melengkung.',
        ),
        FormCheckpoint(
          title: 'Chest to Deck',
          desc: 'Turunkan tubuh hingga dada hampir menyentuh lantai.',
        ),
        FormCheckpoint(
          title: 'Full Range Lockout',
          desc: 'Dorong penuh ke atas tanpa mengunci sendi siku keras.',
        ),
      ],
      mistake: 'Hindari siku terbuka melebar menyerupai huruf T.',
      cadence: 'Tempo Ideal: 2 Detik Turun, 1 Detik Jeda, 2 Detik Naik.',
    ),
    'pullup': const WorkoutProtocol(
      id: 'pullup',
      title: 'PULL UP PROTOCOL',
      tabLabel: 'PULL UP',
      tabSub: '10 Reps',
      tabIcon: Icons.vertical_align_top_rounded,
      tag: 'ACTIVE VISUALIZER: PULL UP PROTOCOL',
      cadencePill: 'CADENCE 2-1-2s',
      activation: 'MUSCLE FOCUS: BACK & LATS',
      targetReps: 10,
      defaultReps: 6,
      sets: 3,
      muscles: 'Lats / Back',
      musclesSub: 'LATS/BICEPS',
      burnKcal: 55,
      expReward: 15,
      goldReward: 10,
      checkpoints: [
        FormCheckpoint(
          title: 'Full Dead Hang',
          desc: 'Mulai dari lengan lurus sempurna sebelum menarik tubuh.',
        ),
        FormCheckpoint(
          title: 'Chin Over Bar',
          desc: 'Tarik siku mengarah ke bawah hingga dagu melewati bar.',
        ),
        FormCheckpoint(
          title: 'Controlled Descent',
          desc: 'Turun terkontrol tanpa menjatuhkan tubuh mendadak.',
        ),
        FormCheckpoint(
          title: 'No Kicking/Kipping',
          desc: 'Kunci kaki rapat untuk isolasi kekuatan murni hunter.',
        ),
      ],
      mistake: 'Hindari mengayunkan panggul (kipping) untuk rep bersih.',
      cadence: 'Tempo Ideal: 2 Detik Tarik, 1 Detik Tahan Puncak, 2 Detik Turun.',
    ),
    'situp': const WorkoutProtocol(
      id: 'situp',
      title: 'SIT UP PROTOCOL',
      tabLabel: 'SIT UP',
      tabSub: '20 Reps',
      tabIcon: Icons.self_improvement_rounded,
      tag: 'ACTIVE VISUALIZER: SIT UP PROTOCOL',
      cadencePill: 'CADENCE 2-1-2s',
      activation: 'MUSCLE FOCUS: CORE & ABS',
      targetReps: 20,
      defaultReps: 12,
      sets: 3,
      muscles: 'Core / Abs',
      musclesSub: 'RECTUS ABD.',
      burnKcal: 40,
      expReward: 10,
      goldReward: 5,
      checkpoints: [
        FormCheckpoint(
          title: 'Knees Bent 90°',
          desc: 'Pertahankan telapak kaki menempel kokoh di lantai.',
        ),
        FormCheckpoint(
          title: 'Abdominal Flexion',
          desc: 'Gulung tulang belakang ke atas dengan kontraksi perut.',
        ),
        FormCheckpoint(
          title: 'No Neck Pulling',
          desc: 'Ujung jari menyentuh pelipis, jangan menarik leher.',
        ),
        FormCheckpoint(
          title: 'Spine Control',
          desc: 'Turun vertebra demi vertebra secara bertahap.',
        ),
      ],
      mistake: 'Hindari menarik leher ke depan dengan kedua tangan.',
      cadence: 'Tempo Ideal: 2 Detik Angkat Dada, 1 Detik Kontraksi, 2 Detik Rebah.',
    ),
    'squat': const WorkoutProtocol(
      id: 'squat',
      title: 'SQUAT PROTOCOL',
      tabLabel: 'SQUAT',
      tabSub: '30 Reps',
      tabIcon: Icons.directions_run_rounded,
      tag: 'ACTIVE VISUALIZER: SQUAT PROTOCOL',
      cadencePill: 'CADENCE 3-1-1s',
      activation: 'MUSCLE FOCUS: QUADS & GLUTES',
      targetReps: 30,
      defaultReps: 18,
      sets: 3,
      muscles: 'Quads/Glutes',
      musclesSub: 'LEGS/CORE',
      burnKcal: 60,
      expReward: 10,
      goldReward: 5,
      checkpoints: [
        FormCheckpoint(
          title: 'Hip Crease Below Knee',
          desc: 'Capai kedalaman squat paralel penuh (full depth).',
        ),
        FormCheckpoint(
          title: 'Chest Up & Tall',
          desc: 'Jaga dada tegap dan pandangan lurus ke depan.',
        ),
        FormCheckpoint(
          title: 'Knees Track With Toes',
          desc: 'Dorong lutut ke arah luar selaras ujung jari kaki.',
        ),
        FormCheckpoint(
          title: 'Heels Planted Firm',
          desc: 'Beban bertumpu merata di tengah kaki dan tumit.',
        ),
      ],
      mistake: 'Hindari lutut menekuk ke dalam (knee valgus) saat naik.',
      cadence: 'Tempo Ideal: 3 Detik Turun, 1 Detik Dasar, 1 Detik Bangkit.',
    ),
  };

  // 2. State Lokal (Dimulai kosongan dari awal: 0 Reps & 0 Sets)
  late String _activeExercise;
  int _currentReps = 0;
  List<bool> _setsCompleted = [false, false, false];
  bool _isClaimed = false;

  // 3. Controller Animasi Biomekanik Canvas
  late AnimationController _animController;
  late Animation<double> _animation;

  WorkoutProtocol get _currentProtocol => _protocolsData[_activeExercise]!;

  /// Jumlah set yang telah diselesaikan (0 - 3)
  int get _completedSetsCount => _setsCompleted.where((e) => e).length;

  /// Aturan Validasi Selesai: Semua 3 sets telah dicentang DAN repetisi mencapai target protokol
  bool get _isProtocolReady {
    final bool allSetsDone = _setsCompleted.length == 3 && _setsCompleted.every((done) => done);
    final bool repsReached = _currentReps >= _currentProtocol.targetReps;
    return allSetsDone && repsReached;
  }

  @override
  void initState() {
    super.initState();
    _activeExercise = widget.initialExercise;
    _currentReps = 0; // Kosongan dari awal (0 repetisi)
    _setsCompleted = [false, false, false]; // Kosongan dari awal (belum ada set selesai)

    // Animasi perulangan biomekanik halus (2.4 detik cycle dengan bolak-balik)
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Mengganti latihan aktif dan mereset nilai repetisi & set ke kosongan
  // ignore: unused_element
  void _selectExercise(String key) {
    if (_activeExercise == key) return;
    setState(() {
      _activeExercise = key;
      _currentReps = 0; // Reset ke 0
      _setsCompleted = [false, false, false]; // Reset ke kosongan
      _isClaimed = false;
    });
  }

  /// Menambah repetisi (+1 biasa, atau +5 dengan long press)
  void _incrementReps({int count = 1}) {
    if (_currentReps < _currentProtocol.targetReps) {
      setState(() {
        _currentReps = min(_currentReps + count, _currentProtocol.targetReps);
      });
    }
  }

  /// Mengurangi repetisi (-1 biasa, atau -5 dengan long press)
  void _decrementReps({int count = 1}) {
    if (_currentReps > 0) {
      setState(() {
        _currentReps = max(_currentReps - count, 0);
      });
    }
  }

  /// Men-toggle checklist Set
  void _toggleSet(int index) {
    setState(() {
      _setsCompleted[index] = !_setsCompleted[index];
    });
  }

  /// Menyelesaikan protokol dan mengirim reward ke pemanggil hanya jika rules terpenuhi
  void _handleCompleteProtocol() {
    final protocol = _currentProtocol;

    // Validasi Mutlak: User baru bisa menyelesaikan ketika sets dan reps benar-benar selesai semua
    if (!_isProtocolReady) {
      final int remainingSets = 3 - _completedSetsCount;
      final int remainingReps = protocol.targetReps - _currentReps;
      String warningMsg;
      if (remainingSets > 0 && remainingReps > 0) {
        warningMsg = 'Hunter! Selesaikan $remainingSets set lagi dan capai ${protocol.targetReps} repetisi ($remainingReps lagi)!';
      } else if (remainingSets > 0) {
        warningMsg = 'Hunter! Selesaikan $remainingSets set lagi untuk menyelesaikan protokol!';
      } else {
        warningMsg = 'Hunter! Tambah repetisi hingga mencapai target ${protocol.targetReps} ($remainingReps lagi)!';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  warningMsg,
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF93000A),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isClaimed = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${protocol.title} Completed! +${protocol.expReward} EXP, +${protocol.goldReward} Gold!',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00F4FE),
        duration: const Duration(milliseconds: 1400),
      ),
    );

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        Navigator.pop(context, {
          'exp': protocol.expReward,
          'gold': protocol.goldReward,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final protocol = _currentProtocol;

    return Scaffold(
      backgroundColor: const Color(0xFF08050E), // Background #08050E
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar Header
            _buildHeader(context),

            // Konten Scrollable
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 2. Sub-Header Status: QUEST LOG // PROTOCOL: DAILY QUEST
                    _buildSubHeaderStatus(),

                    const SizedBox(height: 10),

                    // 3. Tab Selector 4 Latihan (Push Up, Pull Up, Sit Up, Squat)
                    _buildProtocolTabsRow(),

                    const SizedBox(height: 14),

                    // 4. Animated Biomechanical Visualizer Box
                    _buildVisualizerBox(protocol),

                    const SizedBox(height: 14),

                    // 5. 4 Column Protocol Specs Infographic
                    _buildProtocolSpecsGrid(protocol),

                    const SizedBox(height: 14),

                    // 6. Hunter Form Checkpoints
                    _buildFormCheckpointsSection(protocol),

                    const SizedBox(height: 14),

                    // 7. System Tactical Guidance & Mistakes
                    _buildTacticalGuidanceSection(protocol),

                    const SizedBox(height: 14),

                    // 8. Gamified Self-Report Session Log (Sets & Reps Stepper)
                    _buildSelfReportTracker(protocol),

                    const SizedBox(height: 16),

                    // 9. Tombol Utama Claim Reward
                    _buildClaimRewardButton(protocol),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Top Bar Header
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF08050E).withValues(alpha: 0.95),
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFF2C1E4E),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF120D24),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF383241),
                      width: 1.0,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFFE9DEF2),
                      size: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF00E5FF),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF00E5FF),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'PROTOCOL: QUEST HUB',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: const Color(0xFF00E5FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Workout Hub & Guide',
                    style: GoogleFonts.sora(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: const Color(0xFFE9DEF2),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Avatar Profil Kanan
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE5B5FF),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB026FF).withValues(alpha: 0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                size: 20,
                color: Color(0xFF4E0078),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Sub-Header Status
  Widget _buildSubHeaderStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'QUEST LOG // PROTOCOL: DAILY QUEST',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: const Color(0xFFCBD5E1).withValues(alpha: 0.75),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Rank Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF120D24),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFB026FF).withValues(alpha: 0.4),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB026FF).withValues(alpha: 0.2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shield_rounded,
                size: 12,
                color: Color(0xFFE5B5FF),
              ),
              const SizedBox(width: 4),
              Text(
                'RANK: E AWAKENING',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: const Color(0xFFE5B5FF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 3. Tab Selector (Extracted to separate quest items on main list)
  Widget _buildProtocolTabsRow() {
    return const SizedBox.shrink();
  }

  /// 4. Animated Biomechanical Visualizer Box
  Widget _buildVisualizerBox(WorkoutProtocol protocol) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF120D24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2C1E4E),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFFB026FF).withValues(alpha: 0.08),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Ambient Glow Background
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFB026FF).withValues(alpha: 0.12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB026FF).withValues(alpha: 0.15),
                    blurRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                    blurRadius: 60,
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                // Header Bar dalam Visualizer: Protocol Tag & Cadence Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF00E5FF),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF00E5FF),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              protocol.tag,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: const Color(0xFF00E5FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2736),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFB026FF).withValues(alpha: 0.4),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        protocol.cadencePill,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: const Color(0xFFE5B5FF),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Area Animasi Biomekanik CustomPaint
                SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Tactical Grid Background
                      Opacity(
                        opacity: 0.15,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFB026FF),
                              width: 0.8,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      // Canvas Animasi Biomekanik
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(240, 170),
                            painter: _BiomechanicalWorkoutPainter(
                              exercise: _activeExercise,
                              progress: _animation.value,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Footer Bar dalam Visualizer: Muscle Activation Tag & Looping Rep
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F1927),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFB026FF).withValues(alpha: 0.35),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF00E5FF),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            protocol.activation,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: const Color(0xFF00E5FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F1927),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF383241),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sync_rounded,
                            size: 12,
                            color: Color(0xFFE5B5FF),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'LOOPING REP',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: const Color(0xFF9B8BA1),
                            ),
                          ),
                        ],
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
  }

  /// 5. 4 Column Protocol Specs Infographic
  Widget _buildProtocolSpecsGrid(WorkoutProtocol protocol) {
    return Row(
      children: [
        // Spec 1: TARGET
        Expanded(
          child: _buildSpecCard(
            icon: Icons.flag_rounded,
            iconColor: const Color(0xFF00E5FF),
            label: 'TARGET',
            value: '${protocol.targetReps} Reps',
            subValue: '${protocol.sets} SETS',
            subColor: const Color(0xFF00E5FF),
          ),
        ),
        const SizedBox(width: 6),

        // Spec 2: MUSCLES
        Expanded(
          child: _buildSpecCard(
            icon: Icons.sports_martial_arts_rounded,
            iconColor: const Color(0xFFE5B5FF),
            label: 'MUSCLES',
            value: protocol.muscles,
            subValue: protocol.musclesSub,
            subColor: const Color(0xFFD2C1D7),
          ),
        ),
        const SizedBox(width: 6),

        // Spec 3: BURN
        Expanded(
          child: _buildSpecCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFFF7A85),
            label: 'BURN',
            value: '${protocol.burnKcal} KCAL',
            subValue: 'MANA COST',
            subColor: const Color(0xFFFF7A85),
          ),
        ),
        const SizedBox(width: 6),

        // Spec 4: REWARD
        Expanded(
          child: _buildSpecCard(
            icon: Icons.military_tech_rounded,
            iconColor: const Color(0xFFFFD166),
            label: 'REWARD',
            value: '+${protocol.expReward} EXP',
            subValue: '+${protocol.goldReward} GOLD',
            subColor: const Color(0xFFFFD166),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subValue,
    required Color subColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF120D24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2C1E4E),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: const Color(0xFF9B8BA1),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.sora(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            subValue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: subColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 6. Hunter Form Checkpoints
  Widget _buildFormCheckpointsSection(WorkoutProtocol protocol) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF120D24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF2C1E4E),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Checkpoint
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1927),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.checklist_rounded,
                        size: 16,
                        color: Color(0xFF00E5FF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hunter Form Checkpoints',
                        style: GoogleFonts.sora(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'BIOMECHANICAL ACCURACY STANDARD',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: const Color(0xFF9B8BA1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFB026FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFB026FF).withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  'RANK: ESSENTIAL',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE5B5FF),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 2x2 Grid Checklist
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.55,
            ),
            itemCount: protocol.checkpoints.length,
            itemBuilder: (context, index) {
              final cp = protocol.checkpoints[index];
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF08050E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF383241).withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 15,
                      color: Color(0xFF00E5FF),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cp.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFE9DEF2),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Expanded(
                            child: Text(
                              cp.desc,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                height: 1.25,
                                color: const Color(0xFF9B8BA1),
                              ),
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
        ],
      ),
    );
  }

  /// 7. System Tactical Guidance & Mistakes
  Widget _buildTacticalGuidanceSection(WorkoutProtocol protocol) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF120D24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF2C1E4E),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 17,
                color: Color(0xFFFF7A85),
              ),
              const SizedBox(width: 6),
              Text(
                'System Tactical Guidance & Mistakes',
                style: GoogleFonts.sora(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Card 1: Fatal Flaw
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2B0A12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFF7A85).withValues(alpha: 0.4),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.cancel_rounded,
                  size: 16,
                  color: Color(0xFFFF7A85),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    protocol.mistake,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFFFDAD6),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'FATAL FLAW',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: const Color(0xFFFF7A85),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Card 2: Cadence
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF08050E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: Color(0xFF00E5FF),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    protocol.cadence,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFE9DEF2),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'CADENCE',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 8. Gamified Self-Report Session Log (Sets & Reps Stepper)
  Widget _buildSelfReportTracker(WorkoutProtocol protocol) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF120D24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFB026FF).withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB026FF).withValues(alpha: 0.12),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.fact_check_rounded,
                    size: 17,
                    color: Color(0xFFE5B5FF),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Self-Report Session Log',
                    style: GoogleFonts.sora(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1927),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$_currentReps / ${protocol.targetReps} REPS LOGGED',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: const Color(0xFF00E5FF),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 3 Set Pills (Set 1, Set 2, Set 3)
          Row(
            children: List.generate(3, (index) {
              final isDone = _setsCompleted[index];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 3,
                    right: index == 2 ? 0 : 3,
                  ),
                  child: GestureDetector(
                    onTap: () => _toggleSet(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isDone
                            ? const Color(0xFF00F4FE).withValues(alpha: 0.1)
                            : const Color(0xFF08050E),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDone
                              ? const Color(0xFF00F4FE).withValues(alpha: 0.6)
                              : const Color(0xFF383241),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'STAGE',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF9B8BA1),
                                ),
                              ),
                              Text(
                                'SET ${index + 1}',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isDone ? const Color(0xFF00F4FE) : Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 16,
                            color: isDone ? const Color(0xFF00F4FE) : const Color(0xFF5D5373),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 10),

          // Rep Counter Stepper
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF08050E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2C1E4E),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Repetitions',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9B8BA1),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$_currentReps',
                          style: GoogleFonts.sora(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF00E5FF),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ ${protocol.targetReps}',
                          style: GoogleFonts.sora(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF9B8BA1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Tombol Stepper - dan + (Mendukung Tap +1 & Long Press +5)
                Row(
                  children: [
                    GestureDetector(
                      onTap: _decrementReps,
                      onLongPress: () => _decrementReps(count: 5),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F1927),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF383241),
                            width: 1.0,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.remove_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _incrementReps,
                      onLongPress: () => _incrementReps(count: 5),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB026FF),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB026FF).withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
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
  }

  /// 9. Tombol Utama Claim Reward (Terkunci sampai Reps & Sets benar-benar selesai sesuai rules)
  Widget _buildClaimRewardButton(WorkoutProtocol protocol) {
    final bool isReady = _isProtocolReady;

    String buttonText;
    IconData buttonIcon;

    if (_isClaimed) {
      buttonText = 'PROTOCOL COMPLETED! REWARD GRANTED ✓';
      buttonIcon = Icons.verified_rounded;
    } else if (isReady) {
      buttonText = 'COMPLETE PROTOCOL & CLAIM REWARD (+${protocol.expReward} EXP, +${protocol.goldReward} GOLD)';
      buttonIcon = Icons.check_circle_rounded;
    } else {
      final int remainingSets = 3 - _completedSetsCount;
      final int remainingReps = protocol.targetReps - _currentReps;
      if (remainingSets > 0 && remainingReps > 0) {
        buttonText = 'SELESAIKAN $remainingSets SET & $remainingReps REPS LAGI';
      } else if (remainingSets > 0) {
        buttonText = 'SELESAIKAN $remainingSets SET LAGI (CENTANG SET)';
      } else {
        buttonText = 'CAPAI TARGET REPETISI ($remainingReps REPS LAGI)';
      }
      buttonIcon = Icons.lock_outline_rounded;
    }

    return GestureDetector(
      onTap: _isClaimed ? null : _handleCompleteProtocol,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: _isClaimed
              ? const Color(0xFF00F4FE)
              : isReady
                  ? null
                  : const Color(0xFF16111E),
          gradient: _isClaimed || !isReady
              ? null
              : const LinearGradient(
                  colors: [
                    Color(0xFF7000A8),
                    Color(0xFFB026FF),
                    Color(0xFF00F4FE),
                  ],
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isClaimed
                ? const Color(0xFF00F4FE)
                : isReady
                    ? const Color(0xFF00F4FE).withValues(alpha: 0.8)
                    : const Color(0xFF383241),
            width: isReady ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (isReady && !_isClaimed)
              BoxShadow(
                color: const Color(0xFFB026FF).withValues(alpha: 0.5),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            if (_isClaimed)
              BoxShadow(
                color: const Color(0xFF00F4FE).withValues(alpha: 0.5),
                blurRadius: 16,
              ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  buttonIcon,
                  size: 19,
                  color: _isClaimed
                      ? Colors.black
                      : isReady
                          ? Colors.white
                          : const Color(0xFF9B8BA1),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    buttonText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: isReady ? 10.5 : 10.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: _isClaimed
                          ? Colors.black
                          : isReady
                              ? Colors.white
                              : const Color(0xFF9B8BA1),
                    ),
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

/// CustomPainter Biomekanik Solo Leveling
/// Menggambar animasi garis neon (Push Up, Pull Up, Sit Up, Squat)
/// Mengadopsi koordinat anatomis 240x170 persis Stitch HTML keyframes.
class _BiomechanicalWorkoutPainter extends CustomPainter {
  final String exercise;
  final double progress; // 0.0 (up/start) s/d 1.0 (bottom/peak)

  _BiomechanicalWorkoutPainter({
    required this.exercise,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Skala kanvas agar sesuai rasio 240x170
    final double scaleX = size.width / 240.0;
    final double scaleY = size.height / 170.0;
    final double scale = min(scaleX, scaleY);

    canvas.save();
    canvas.translate(
      (size.width - 240 * scale) / 2,
      (size.height - 170 * scale) / 2,
    );
    canvas.scale(scale);

    switch (exercise) {
      case 'pushup':
        _paintPushup(canvas);
        break;
      case 'pullup':
        _paintPullup(canvas);
        break;
      case 'situp':
        _paintSitup(canvas);
        break;
      case 'squat':
        _paintSquat(canvas);
        break;
    }

    canvas.restore();
  }

  /// 1. PUSH UP: Torso berotasi dari tumpuan jari kaki (50, 150), bahu turun mendekati lantai,
  /// lengan melipat 45 derajat ke belakang, telapak tangan terkunci di (185, 150).
  void _paintPushup(Canvas canvas) {
    // Lantai
    final floorPaint = Paint()
      ..color = const Color(0xFF383241)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(20, 150), const Offset(220, 150), floorPaint);

    // Aura lantai
    final auraPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.18 + 0.1 * sin(progress * pi))
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(120, 154), width: 170, height: 18),
      auraPaint,
    );

    // Tumpuan Telapak Tangan di Lantai (Dead Locked di 185, 150)
    final palmAnchorPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(177, 150), const Offset(193, 150), palmAnchorPaint);
    canvas.drawCircle(const Offset(185, 150), 4.5, Paint()..color = const Color(0xFF00E5FF));

    // Tumpuan Ujung Kaki di Lantai (Dead Locked Pivot di 50, 150)
    canvas.drawCircle(const Offset(50, 150), 4.5, Paint()..color = const Color(0xFF00E5FF));

    // Koordinat interpolasi gerakan biomekanik
    final Offset shoulder = Offset.lerp(const Offset(185, 102), const Offset(188, 140), progress)!;
    final Offset elbow = Offset.lerp(const Offset(177, 126), const Offset(158, 138), progress)!;
    final Offset core = Offset.lerp(const Offset(104, 131), const Offset(104, 146), progress)!;
    final Offset head = Offset.lerp(const Offset(212, 91), const Offset(215, 135), progress)!;
    final Offset neck = Offset.lerp(const Offset(204, 95), const Offset(207, 138), progress)!;

    // A. Lengan: Bahu -> Siku -> Telapak Tangan
    final armPath = Path()
      ..moveTo(shoulder.dx, shoulder.dy)
      ..lineTo(elbow.dx, elbow.dy)
      ..lineTo(185, 150);

    // Shadow Lengan
    final armShadowPaint = Paint()
      ..color = const Color(0xFF231D2B)
      ..strokeWidth = 7.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(armPath, armShadowPaint);

    // Glow Lengan Cyan
    final armGlowPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0);
    canvas.drawPath(armPath, armGlowPaint);

    // Titik Sendi Siku
    canvas.drawCircle(elbow, 3.5, Paint()..color = const Color(0xFFE5B5FF));

    // B. Batang Tubuh Plank Kaku: Ujung Kaki (50, 150) ke Bahu
    final spineShadow = Paint()
      ..color = const Color(0xFF231D2B)
      ..strokeWidth = 11.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(50, 150), shoulder, spineShadow);

    final spineGlow = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB026FF), Color(0xFF00E5FF), Color(0xFFE5B5FF)],
      ).createShader(Rect.fromPoints(const Offset(50, 150), shoulder))
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2.5);
    canvas.drawLine(const Offset(50, 150), shoulder, spineGlow);

    // Node Core / Pelvis
    canvas.drawCircle(
      core,
      4.0,
      Paint()
        ..color = const Color(0xFFB026FF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0),
    );

    // Node Sendi Bahu
    canvas.drawCircle(shoulder, 5.0, Paint()..color = const Color(0xFF00E5FF));

    // C. Leher dan Kepala
    final neckPaint = Paint()
      ..color = const Color(0xFF231D2B)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(shoulder, neck, neckPaint);

    canvas.drawCircle(
      head,
      8.5,
      Paint()
        ..color = const Color(0xFF120D24)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      head,
      8.5,
      Paint()
        ..color = const Color(0xFFE5B5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Sorot Mata Hunter Cyan
    canvas.drawLine(
      Offset(head.dx + 2, head.dy),
      Offset(head.dx + 7, head.dy - 1),
      Paint()
        ..color = const Color(0xFF00E5FF)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
  }

  /// 2. PULL UP: Bar horizontal statis di atas (y=22), tangan terkunci,
  /// tubuh tertarik ke atas (chin over bar) saat progress=1.0.
  void _paintPullup(Canvas canvas) {
    // Overhead Pull Up Bar Frame
    final barShadow = Paint()
      ..color = const Color(0xFF4F4255)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(45, 22), const Offset(195, 22), barShadow);

    final barGlow = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0);
    canvas.drawLine(const Offset(50, 22), const Offset(190, 22), barGlow);

    // Tiang Vertikal Penyangga Bar
    final postPaint = Paint()
      ..color = const Color(0xFF231D2B)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(48, 6), const Offset(48, 40), postPaint);
    canvas.drawLine(const Offset(192, 6), const Offset(192, 40), postPaint);

    // Hand Grips Terkunci di Bar (102, 22) dan (138, 22)
    final gripPaint = Paint()..color = const Color(0xFFFFD166);
    canvas.drawCircle(const Offset(102, 22), 4.5, gripPaint);
    canvas.drawCircle(const Offset(138, 22), 4.5, gripPaint);

    // Pergerakan vertikal tubuh:
    // progress = 0.0 (Dead Hang, y turun +32)
    // progress = 1.0 (Chin over bar, y naik -8)
    final double bodyY = 64.0 - (progress * 40.0); // dari 64 ke 24

    // Posisi Sendi Bahu & Siku
    final Offset leftShoulder = Offset(110, bodyY);
    final Offset rightShoulder = Offset(130, bodyY);

    // Siku menekuk keluar saat tubuh naik
    final Offset leftElbow = Offset(
      105 - (progress * 23), // dari 105 ke 82
      45 - (progress * 7),   // dari 45 ke 38
    );
    final Offset rightElbow = Offset(
      135 + (progress * 23), // dari 135 ke 158
      45 - (progress * 7),
    );

    // Lengan Kiri (Grip -> Siku -> Bahu)
    final leftArmPath = Path()
      ..moveTo(102, 22)
      ..lineTo(leftElbow.dx, leftElbow.dy)
      ..lineTo(leftShoulder.dx, leftShoulder.dy);

    // Lengan Kanan (Grip -> Siku -> Bahu)
    final rightArmPath = Path()
      ..moveTo(138, 22)
      ..lineTo(rightElbow.dx, rightElbow.dy)
      ..lineTo(rightShoulder.dx, rightShoulder.dy);

    final armBg = Paint()
      ..color = const Color(0xFF231D2B)
      ..strokeWidth = 7.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final armFg = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2.5);

    canvas.drawPath(leftArmPath, armBg);
    canvas.drawPath(leftArmPath, armFg);
    canvas.drawPath(rightArmPath, armBg);
    canvas.drawPath(rightArmPath, armFg);

    // Garis Bahu Menghubungkan Lengan Kiri & Kanan
    canvas.drawLine(leftShoulder, rightShoulder, armBg..strokeWidth = 8.0);
    canvas.drawLine(leftShoulder, rightShoulder, armFg..strokeWidth = 4.0);

    // Torso / Tulang Punggung Lats V-Taper
    final double torsoBottom = bodyY + 42.0;
    final torsoBg = Paint()
      ..color = const Color(0xFF231D2B)
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(120, bodyY), Offset(120, torsoBottom), torsoBg);

    final torsoGlow = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB026FF), Color(0xFF00E5FF)],
      ).createShader(Rect.fromPoints(Offset(120, bodyY), Offset(120, torsoBottom)))
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0);
    canvas.drawLine(Offset(120, bodyY), Offset(120, torsoBottom), torsoGlow);

    // Node Sayap Lats
    canvas.drawCircle(Offset(112, bodyY + 12), 3.5, Paint()..color = const Color(0xFFB026FF));
    canvas.drawCircle(Offset(128, bodyY + 12), 3.5, Paint()..color = const Color(0xFFB026FF));

    // Kepala (Melewati Bar saat progress mendekati 1.0)
    final double headY = bodyY - 12.0;
    canvas.drawLine(
      Offset(120, bodyY),
      Offset(120, headY),
      Paint()
        ..color = const Color(0xFF231D2B)
        ..strokeWidth = 5.0,
    );
    canvas.drawCircle(
      Offset(120, headY),
      8.0,
      Paint()..color = const Color(0xFF120D24),
    );
    canvas.drawCircle(
      Offset(120, headY),
      8.0,
      Paint()
        ..color = const Color(0xFFE5B5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(Offset(120, headY), 2.0, Paint()..color = const Color(0xFF00E5FF));

    // Kaki Terkunci Lurus ke Bawah
    final double feetY = torsoBottom + 36.0;
    canvas.drawLine(
      Offset(120, torsoBottom),
      Offset(120, feetY),
      Paint()
        ..color = const Color(0xFFB026FF)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(120, feetY), 3.5, Paint()..color = const Color(0xFF00E5FF));
  }

  /// 3. SIT UP: Matras di lantai, lutut ditekuk 90 derajat, kaki terpasak di lantai (175, 118).
  /// Torso melengkung naik dari sudut 0 derajat ke -55 derajat dari poros pinggul (105, 115).
  void _paintSitup(Canvas canvas) {
    // Matras Lantai
    final matPaint = Paint()..color = const Color(0xFF2D2736);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(35, 118, 170, 4), const Radius.circular(2)),
      matPaint,
    );

    // Kaki Bawah Statis Terkunci
    // Poros Panggul: (105, 115)
    canvas.drawCircle(const Offset(105, 115), 4.5, Paint()..color = const Color(0xFFB026FF));

    // Paha: Panggul ke Lutut (105, 115) -> (145, 82)
    final thighPaint = Paint()
      ..color = const Color(0xFFB026FF)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(105, 115), const Offset(145, 82), thighPaint);
    canvas.drawCircle(const Offset(145, 82), 4.0, Paint()..color = const Color(0xFF00E5FF));

    // Betis: Lutut ke Telapak Kaki (145, 82) -> (175, 118)
    final calfPaint = Paint()
      ..color = const Color(0xFFB026FF)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(145, 82), const Offset(175, 118), calfPaint);
    canvas.drawCircle(const Offset(175, 118), 4.0, Paint()..color = const Color(0xFF00E5FF));

    // Rotasi Torso dari Poros Panggul (105, 115)
    // Sudut 0 deg (rebah di lantai) ke -55 deg (bangkit menekuk ke lutut)
    final double angleRad = -progress * 55.0 * (pi / 180.0);

    // Panjang torso ~50px
    final double shoulderX = 105.0 - 49.0 * cos(angleRad);
    final double shoulderY = 115.0 + 49.0 * sin(angleRad);
    final Offset shoulder = Offset(shoulderX, shoulderY);

    // Tulang Torso
    final torsoShadow = Paint()
      ..color = const Color(0xFF231D2B)
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(105, 115), shoulder, torsoShadow);

    final torsoGlow = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB026FF), Color(0xFF00E5FF)],
      ).createShader(Rect.fromPoints(const Offset(105, 115), shoulder))
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2.5);
    canvas.drawLine(const Offset(105, 115), shoulder, torsoGlow);

    // Node Abdominal Core (Pusat Kontraksi Perut)
    final Offset core = Offset.lerp(const Offset(105, 115), shoulder, 0.45)!;
    canvas.drawCircle(
      core,
      4.5,
      Paint()
        ..color = const Color(0xFF00E5FF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.5),
    );

    // Tangan Menyentuh Sisi Pelipis / Dada
    final Offset handElbow = Offset(shoulder.dx - 6, shoulder.dy - 12);
    final handPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(shoulder, handElbow, handPaint);

    // Kepala Hunter
    final double headX = shoulderX - 14.0 * cos(angleRad);
    final double headY = shoulderY + 14.0 * sin(angleRad);
    final Offset head = Offset(headX, headY);

    canvas.drawCircle(head, 8.5, Paint()..color = const Color(0xFF120D24));
    canvas.drawCircle(
      head,
      8.5,
      Paint()
        ..color = const Color(0xFFE5B5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(head, 2.0, Paint()..color = const Color(0xFF00E5FF));
  }

  /// 4. SQUAT: Kaki menapak di tanah (106, 122) dan (134, 122).
  /// Panggul turun ke bawah (30px), lutut menekuk keluar (parallel depth),
  /// dada tegap, tangan menjulur lurus ke depan untuk keseimbangan.
  void _paintSquat(Canvas canvas) {
    // Aura dasar lantai
    final auraPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(120, 122), width: 130, height: 16),
      auraPaint,
    );

    // Telapak Kaki Terpasang Kokoh di Lantai
    canvas.drawCircle(const Offset(106, 122), 4.0, Paint()..color = const Color(0xFF00E5FF));
    canvas.drawCircle(const Offset(134, 122), 4.0, Paint()..color = const Color(0xFF00E5FF));

    // Pergerakan panggul: dari y=76 ke y=106 (+30px saat jongkok penuh)
    final double hipY = 76.0 + (progress * 30.0);
    final Offset hip = Offset(120, hipY);

    // Lutut Kiri dan Kanan menekuk keluar saat squat
    final Offset leftKnee = Offset(
      112 - (progress * 26), // dari 112 ke 86
      99 + (progress * 13),  // dari 99 ke 112
    );
    final Offset rightKnee = Offset(
      128 + (progress * 26), // dari 128 ke 154
      99 + (progress * 13),
    );

    // Kaki Kiri: Panggul -> Lutut Kiri -> Kaki Kiri (106, 122)
    final legLeftPath = Path()
      ..moveTo(hip.dx - 8, hip.dy)
      ..lineTo(leftKnee.dx, leftKnee.dy)
      ..lineTo(106, 122);

    // Kaki Kanan: Panggul -> Lutut Kanan -> Kaki Kanan (134, 122)
    final legRightPath = Path()
      ..moveTo(hip.dx + 8, hip.dy)
      ..lineTo(rightKnee.dx, rightKnee.dy)
      ..lineTo(134, 122);

    final legBg = Paint()
      ..color = const Color(0xFF231D2B)
      ..strokeWidth = 9.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final legLeftFg = Paint()
      ..color = const Color(0xFFB026FF)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final legRightFg = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2.5);

    canvas.drawPath(legLeftPath, legBg);
    canvas.drawPath(legLeftPath, legLeftFg);
    canvas.drawPath(legRightPath, legBg);
    canvas.drawPath(legRightPath, legRightFg);

    // Node Pinggul / Glutes & Quads
    canvas.drawCircle(
      hip,
      4.5,
      Paint()
        ..color = const Color(0xFFFFD166)
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0),
    );

    // Torso Tegak: Panggul ke Bahu (Panjang 32px ke atas)
    final Offset shoulder = Offset(120, hipY - 32.0);
    final torsoBg = Paint()
      ..color = const Color(0xFF231D2B)
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(hip, shoulder, torsoBg);

    final torsoGlow = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB026FF), Color(0xFF00E5FF), Color(0xFFE5B5FF)],
      ).createShader(Rect.fromPoints(hip, shoulder))
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2.5);
    canvas.drawLine(hip, shoulder, torsoGlow);

    // Lengan Menjulur Lurus ke Depan (Counter-balance)
    final Offset elbow = Offset(shoulder.dx + 22, shoulder.dy + 2);
    final Offset hand = Offset(shoulder.dx + 42, shoulder.dy + 4);
    final armPath = Path()
      ..moveTo(shoulder.dx, shoulder.dy + 2)
      ..lineTo(elbow.dx, elbow.dy)
      ..lineTo(hand.dx, hand.dy);

    final armPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(armPath, armPaint);
    canvas.drawCircle(hand, 3.0, Paint()..color = const Color(0xFF00E5FF));

    // Kepala
    final Offset head = Offset(120, shoulder.dy - 10.0);
    canvas.drawCircle(head, 8.5, Paint()..color = const Color(0xFF120D24));
    canvas.drawCircle(
      head,
      8.5,
      Paint()
        ..color = const Color(0xFFE5B5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawLine(
      Offset(head.dx + 1, head.dy),
      Offset(head.dx + 5, head.dy),
      Paint()
        ..color = const Color(0xFF00E5FF)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _BiomechanicalWorkoutPainter oldDelegate) {
    return oldDelegate.exercise != exercise || oldDelegate.progress != progress;
  }
}
