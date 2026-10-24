import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:hive/hive.dart';
import '../../services/hive_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/avatar_image.dart';

/// TabMap: Tab 2 - Dungeon Radar LBS (Map UI)
/// Desain bertema Solo Leveling Monarch System dengan integrasi FlutterMap,
/// OpenStreetMap Dark Mode Tile Layer, dan real-time GPS tracking via Geolocator.
class TabMap extends StatefulWidget {
  const TabMap({super.key});

  @override
  State<TabMap> createState() => _TabMapState();
}

class _TabMapState extends State<TabMap> with SingleTickerProviderStateMixin {
  // 1. Koordinat Target Dungeon Gate (UPN Veteran Yogyakarta)
  final LatLng _targetGate = const LatLng(-7.7613, 110.4090);

  // 2. State Lokasi & GPS
  LatLng? userLocation;
  double distance = 0.0;
  bool hasClaimed = false;
  bool _isLocating = true;
  String _gpsStatus = 'GPS: 3D';
  bool _isFirstFix = true;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;

  // 3. Map Controller & Animasi Sweep
  final MapController _mapController = MapController();
  late final AnimationController _sweepAnimController;

  // 4. State Hunter dari Hive Session
  String _hunterName = 'HUNTER SUNG';
  String _rank = 'RANK S';
  int _currentExp = 150;
  int _gold = 250;
  final int _maxExp = 300;
  final int _currentHp = 3;

  // 5. System Clock (WIB, WITA, WIT, GMT)
  Timer? _serverClockTimer;
  String _wibTime = '14:32';
  String _witaTime = '15:32';
  String _witTime = '16:32';
  String _gmtTime = '07:32';

  @override
  void initState() {
    super.initState();
    _loadHunterSession();
    _initServerClock();
    _initAnimation();
    _initLocationService();
  }

  void _initAnimation() {
    _sweepAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  void _loadHunterSession() {
    final session = HiveService.getSession();
    setState(() {
      _hunterName = session['username']?.toString().toUpperCase() ?? 'HUNTER SUNG';
      _rank = session['rank']?.toString().toUpperCase() ?? 'RANK S';
      _currentExp = session['exp'] as int? ?? 150;
      _gold = session['gold'] as int? ?? 250;
    });
  }

  void _initServerClock() {
    _updateClockTimes();
    _serverClockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateClockTimes();
    });
  }

  void _updateClockTimes() {
    final nowUtc = DateTime.now().toUtc();
    final timeFormat = DateFormat('HH:mm');

    final wib = nowUtc.add(const Duration(hours: 7));
    final wita = nowUtc.add(const Duration(hours: 8));
    final wit = nowUtc.add(const Duration(hours: 9));

    setState(() {
      _wibTime = timeFormat.format(wib);
      _witaTime = timeFormat.format(wita);
      _witTime = timeFormat.format(wit);
      _gmtTime = timeFormat.format(nowUtc);
    });
  }

  /// Memulai pemantauan GPS real-time dengan Geolocator
  Future<void> _initLocationService() async {
    setState(() {
      _isLocating = true;
    });

    try {
      // 1. Pantau status aktif/nonaktif GPS perangkat secara reaktif
      _serviceStatusSubscription?.cancel();
      _serviceStatusSubscription = Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
        if (status == ServiceStatus.enabled) {
          _refreshGpsPosition();
        } else {
          if (mounted) {
            setState(() {
              _isLocating = false;
              _gpsStatus = 'GPS OFF';
            });
          }
        }
      });

      // 2. Cek apakah layanan GPS aktif di perangkat
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isLocating = false;
            _gpsStatus = 'GPS OFF';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Layanan Lokasi (GPS) nonaktif. Aktifkan GPS untuk akurasi posisi Hunter.',
                style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              action: SnackBarAction(
                label: 'AKTIFKAN',
                textColor: const Color(0xFF00F4FE),
                onPressed: () => Geolocator.openLocationSettings(),
              ),
              backgroundColor: const Color(0xFF1F1927),
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // 3. Cek dan minta izin lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _isLocating = false;
              _gpsStatus = 'DENIED';
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Izin lokasi ditolak. Aktifkan izin agar radar dapat melacak posisi Anda.',
                  style: GoogleFonts.spaceGrotesk(color: Colors.white),
                ),
                backgroundColor: const Color(0xFF93000A),
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isLocating = false;
            _gpsStatus = 'BLOCKED';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Izin lokasi diblokir. Harap buka pengaturan aplikasi untuk mengizinkan lokasi.',
                style: GoogleFonts.spaceGrotesk(color: Colors.white),
              ),
              action: SnackBarAction(
                label: 'PENGATURAN',
                textColor: const Color(0xFF00F4FE),
                onPressed: () => Geolocator.openAppSettings(),
              ),
              backgroundColor: const Color(0xFF93000A),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      // 4. Ambil posisi terakhir yang diketahui secara instan
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null && mounted) {
          _updatePosition(lastKnown, moveCamera: _isFirstFix);
          _isFirstFix = false;
        }
      } catch (e) {
        debugPrint('getLastKnownPosition error: $e');
      }

      // 5. Mulai stream posisi real-time tanpa menunggu
      _startPositionStream();

      // 6. Request posisi satelit presisi tinggi saat ini
      try {
        final current = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 10),
          ),
        );
        if (mounted) {
          _updatePosition(current, moveCamera: _isFirstFix);
          _isFirstFix = false;
        }
      } catch (e) {
        debugPrint('getCurrentPosition timeout or error: $e');
      }
    } catch (e) {
      debugPrint('Location service initialization error: $e');
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  void _startPositionStream() {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1, // Update setiap perubahan 1 meter
      ),
    ).listen(
      (Position pos) {
        _updatePosition(pos, moveCamera: _isFirstFix);
        _isFirstFix = false;
      },
      onError: (err) {
        debugPrint('Position stream error: $err');
      },
    );
  }

  Future<void> _refreshGpsPosition() async {
    if (!mounted) return;
    setState(() {
      _isLocating = true;
    });
    try {
      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 8),
        ),
      );
      if (mounted) {
        _updatePosition(current, moveCamera: true);
      }
    } catch (_) {
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null && mounted) {
          _updatePosition(lastKnown, moveCamera: true);
        }
      } catch (_) {}
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  void _updatePosition(Position pos, {bool moveCamera = false}) {
    final newLocation = LatLng(pos.latitude, pos.longitude);
    final calculatedDistance = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      _targetGate.latitude,
      _targetGate.longitude,
    );

    if (!mounted) return;
    setState(() {
      userLocation = newLocation;
      distance = calculatedDistance;
      _isLocating = false;
      _gpsStatus = 'GPS: 3D';
    });

    if (moveCamera) {
      _mapController.move(newLocation, 16.5);
    }
  }

  String _calculateRank(int exp) {
    if (exp >= 2500) return 'RANK S';
    if (exp >= 1500) return 'RANK A';
    if (exp >= 1000) return 'RANK B';
    if (exp >= 600) return 'RANK C';
    if (exp >= 300) return 'RANK D';
    if (exp >= 100) return 'RANK E';
    return 'RANK F';
  }

  /// Fungsi klaim reward jika hunter berada dalam radius <= 100 meter
  void _claimDungeonReward() {
    if (hasClaimed) return;
    if (distance > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Radius terlalu jauh! Anda berada ${distance.toStringAsFixed(0)} meter dari Gate (Maks 100m).',
            style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF93000A),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final newRank = _calculateRank(_currentExp + 50);

    final session = HiveService.getSession();
    final currentGold = (session['gold'] as int?) ?? _gold;
    final updatedGold = currentGold + 100;

    setState(() {
      hasClaimed = true;
      _currentExp += 50;
      _gold = updatedGold;
      _rank = newRank;
    });

    // Simpan hasil raid ke Hive sessionBox agar real-time listener (Shop) langsung terpicu
    Hive.box('sessionBox').put('gold', updatedGold);

    // Simpan hasil raid ke Hive & Supabase
    final userId = session['userId']?.toString() ?? 'anonymous';
    final username = session['username']?.toString() ?? _hunterName;

    HiveService.saveSession(
      userId: userId,
      username: username,
      rank: newRank,
      exp: _currentExp,
      gold: updatedGold,
      hp: _currentHp,
    );

    if (userId != 'anonymous') {
      SupabaseService.updateUserStats(
        userId: userId,
        exp: _currentExp,
        gold: _gold,
        rank: newRank,
      );
      SupabaseService.recordQuestCompleted(
        userId: userId,
        questId: 'dungeon_gate_upn',
      );
      final currentCount = HiveService.getQuestsCount() ?? 0;
      HiveService.saveQuestsCount(currentCount + 1);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Colors.black, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Dungeon Cleared! +50 EXP & +100 Gold Terverifikasi!',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00F4FE),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _recenterMap() async {
    final target = userLocation ?? _targetGate;
    _mapController.move(target, 16.5);
    await _refreshGpsPosition();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _serviceStatusSubscription?.cancel();
    _serverClockTimer?.cancel();
    _sweepAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sinkronkan data sesi Hunter secara dinamis
    final session = HiveService.getSession();
    _hunterName = session['username']?.toString() ?? _hunterName;
    _gold = (session['gold'] as int?) ?? _gold;
    _currentExp = (session['exp'] as int?) ?? _currentExp;
    _rank = session['rank']?.toString() ?? _rank;

    return Scaffold(
      backgroundColor: const Color(0xFF16111E), // Background Solo Leveling Abyss
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Hunter Status Header Bar
            _buildHunterHeader(),

            // 2. Interactive Radar Map Canvas Area
            Expanded(
              child: Stack(
                children: [
                  // Layer A: FlutterMap dengan OpenStreetMap Dark Cyberpunk Mode
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _targetGate,
                      initialZoom: 16.5,
                      minZoom: 12.0,
                      maxZoom: 19.0,
                    ),
                    children: [
                      // OpenStreetMap Dark Theme Tile Layer (Tanpa API Key, Bebas Watermark)
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.levmax_v2',
                        tileBuilder: darkModeTileBuilder,
                      ),

                      // Dotted Line antara Hunter dan Dungeon Gate
                      if (userLocation != null)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: [userLocation!, _targetGate],
                              strokeWidth: 2.0,
                              color: const Color(0xFF00F4FE).withValues(alpha: 0.75),
                              pattern: StrokePattern.dashed(segments: const [6, 6]),
                            ),
                          ],
                        ),

                      // Marker Layer: Gate & Hunter
                      MarkerLayer(
                        markers: [
                          // 1. Gate Target Marker (UPN Veteran)
                          Marker(
                            point: _targetGate,
                            width: 170,
                            height: 140,
                            child: _buildGateMarker(),
                          ),

                          // 2. Hunter User Marker
                          if (userLocation != null)
                            Marker(
                              point: userLocation!,
                              width: 120,
                              height: 80,
                              child: _buildHunterMarker(),
                            ),
                        ],
                      ),
                    ],
                  ),

                  // Layer B: Cybernetic Radar HUD Overlay (Crosshairs & Rotating Beam)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _buildRadarCyberOverlay(),
                    ),
                  ),

                  // Layer C: Top Radar HUD Tracking Panel
                  Positioned(
                    top: 10,
                    left: 12,
                    right: 12,
                    child: _buildRadarTrackingBanner(),
                  ),

                  // Layer D: Floating Map Controls (Recenter & North)
                  Positioned(
                    top: 80,
                    right: 12,
                    child: _buildMapControls(),
                  ),

                  // Layer E: Bottom Action Panel (Dungeon Proximity Mission Card)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildBottomMissionCard(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Top Hunter Status Header Bar
  Widget _buildHunterHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF110C19).withValues(alpha: 0.95),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF2C1E4E), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Name, Rank, Hearts, Gold, Avatar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Hunter Name & Hearts/Gold
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _hunterName,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: const Color(0xFFE9DEF2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB026FF).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFFB026FF).withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB026FF).withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          _rank,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: const Color(0xFFE5B5FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      // 3 Hearts
                      Row(
                        children: List.generate(
                          3,
                          (i) => const Padding(
                            padding: EdgeInsets.only(right: 2.0),
                            child: Icon(Icons.favorite_rounded, size: 13, color: Color(0xFFFF4D4D)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('•', style: TextStyle(color: Colors.grey.shade700, fontSize: 10)),
                      const SizedBox(width: 6),
                      // Gold Badge
                      Row(
                        children: [
                          const Icon(Icons.monetization_on_rounded, size: 12.5, color: Color(0xFFFFD166)),
                          const SizedBox(width: 3),
                          Text(
                            '+$_gold G',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFFD166),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              // Avatar Circle
              Builder(
                builder: (context) {
                  final avatarUrl = HiveService.getSession()['avatar_url']?.toString();
                  return Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFB026FF),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB026FF).withValues(alpha: 0.45),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: HunterAvatar(
                      avatarUrl: avatarUrl,
                      size: 34,
                      fallback: const Center(
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Row 2: EXP Recovery Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EXP RECOVERY',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: const Color(0xFF9B8BA1),
                ),
              ),
              Text(
                '$_currentExp/$_maxExp EXP',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: const Color(0xFFE5B5FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentExp / _maxExp).clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: const Color(0xFF2D2736),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00F4FE)),
            ),
          ),

          const SizedBox(height: 4),

          // Row 3: System Time (WIB | WITA | WIT | GMT)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  'SYS.TIME: WIB $_wibTime  •  WITA $_witaTime  •  WIT $_witTime  •  GMT $_gmtTime',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: const Color(0xFF7E7287),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Radar Tracking Banner (Top Overlay)
  Widget _buildRadarTrackingBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF110C19).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00F4FE).withValues(alpha: 0.5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F4FE).withValues(alpha: 0.25),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Pulsing Cyan Dot
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00F4FE),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00F4FE),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'DUNGEON RADAR ACTIVE',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: const Color(0xFF00F4FE),
                      shadows: [
                        Shadow(
                          color: const Color(0xFF00F4FE).withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _isLocating ? 'SEARCHING SATELLITE LOCK...' : 'LBS PROTOCOL • REAL-TIME SATELLITE LOCK',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: const Color(0xFFDCB8FC),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // GPS Status Pill Badge (Tappable to re-check)
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _initLocationService,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2736).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF383241), width: 0.8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.satellite_alt_rounded, size: 13, color: Color(0xFF00F4FE)),
                  const SizedBox(width: 4),
                  Text(
                    _gpsStatus,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: const Color(0xFFE9DEF2),
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

  /// 3. Cyber Radar HUD Overlay (Crosshairs, Compass, Concentric Rings)
  Widget _buildRadarCyberOverlay() {
    return Stack(
      children: [
        // Compass Tick Labels
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Text(
              'N 000°',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: const Color(0xFF00F4FE).withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 180),
            child: Text(
              'S 180°',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: const Color(0xFF00F4FE).withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              'W 270°',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: const Color(0xFF00F4FE).withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              'E 090°',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: const Color(0xFF00F4FE).withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 4. Map Floating Controls (Recenter & Reset North)
  Widget _buildMapControls() {
    return Column(
      children: [
        // Recenter Button
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _recenterMap,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2736).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF00F4FE).withValues(alpha: 0.4), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00F4FE).withValues(alpha: 0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.my_location_rounded, color: Color(0xFF00F4FE), size: 19),
          ),
        ),
        const SizedBox(height: 8),

        // North Pointer
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _mapController.rotate(0),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2736).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFB026FF).withValues(alpha: 0.4), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB026FF).withValues(alpha: 0.25),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'N',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFF4D4D),
                  ),
                ),
                const Icon(Icons.navigation_rounded, color: Color(0xFF9B8BA1), size: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Marker Gate Dungeon (Pill + Cyclone Vortex + Lat/Lng)
  Widget _buildGateMarker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Gate Status Pill: RANK E BLUE GATE
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF110C19).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00F4FE), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F4FE).withValues(alpha: 0.5),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00F4FE),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'RANK E BLUE GATE',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: const Color(0xFF00F4FE),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Awakened Gate Portal Vortex Box
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF00F4FE), Color(0xFFB026FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F4FE).withValues(alpha: 0.6),
                blurRadius: 20,
              ),
            ],
          ),
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0A0514),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: RotationTransition(
                turns: _sweepAnimController,
                child: const Icon(
                  Icons.cyclone_rounded,
                  color: Color(0xFF00F4FE),
                  size: 32,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 3),

        // Coordinates Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF110C19).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'LAT: -7.7613 // LNG: 110.4090',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 7.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF9B8BA1),
            ),
          ),
        ),
      ],
    );
  }

  /// Marker Hunter Position (User Ping Pulse + Label)
  Widget _buildHunterMarker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulse Ping Circle
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00F4FE).withValues(alpha: 0.2),
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00F4FE).withValues(alpha: 0.45),
              ),
            ),
            Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00F4FE),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00F4FE),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 3),

        // HUNTER (YOU) Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
          decoration: BoxDecoration(
            color: const Color(0xFF110C19).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF00F4FE), width: 0.8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F4FE).withValues(alpha: 0.35),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            'HUNTER (YOU)',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: const Color(0xFF00F4FE),
            ),
          ),
        ),
      ],
    );
  }

  /// 5. Bottom Action Panel (Dungeon Proximity Mission Card)
  Widget _buildBottomMissionCard() {
    final bool canClaim = userLocation != null && distance <= 100 && !hasClaimed;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F1927),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF00F4FE).withValues(alpha: 0.6),
            width: 1.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
          BoxShadow(
            color: const Color(0xFF00F4FE).withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Center Drag Bar
          Container(
            width: 38,
            height: 3.5,
            decoration: BoxDecoration(
              color: const Color(0xFF383241),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 10),

          // Details Grid: Target Info & Gate Reward
          Row(
            children: [
              // Target & Distance Cluster (Tap to view Gate)
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _mapController.move(_targetGate, 16.5),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF110C19).withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2C1E4E), width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.near_me_rounded, color: Color(0xFF00F4FE), size: 16),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TARGET LOCK',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: const Color(0xFFDCB8FC),
                                  ),
                                ),
                                Text(
                                  'Area Kampus Terpadu',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFE9DEF2),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.only(top: 6),
                          decoration: const BoxDecoration(
                            border: Border(top: BorderSide(color: Color(0xFF2D2736), width: 0.8)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.radar_rounded, color: Color(0xFF9B8BA1), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Jarak:',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: const Color(0xFF9B8BA1),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00F4FE).withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _isLocating && userLocation == null
                                      ? 'Mencari...'
                                      : (distance >= 1000
                                          ? '${(distance / 1000).toStringAsFixed(2)} KM'
                                          : '${distance.toStringAsFixed(0)} Meter'),
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: const Color(0xFF00F4FE),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Gate Reward Module
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF110C19).withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2C1E4E), width: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD166).withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'GATE REWARD',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: const Color(0xFFFFD166),
                            ),
                          ),
                          const Icon(Icons.stars_rounded, color: Color(0xFFFFD166), size: 16),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '+50 EXP',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: const Color(0xFFFFD166),
                        ),
                      ),
                      Text(
                        '+100 GOLD',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: const Color(0xFFFFD166),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Primary Action Button: Klaim Hadiah Dungeon
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: canClaim ? _claimDungeonReward : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: hasClaimed
                    ? null
                    : (canClaim
                        ? const LinearGradient(
                            colors: [Color(0xFF00F4FE), Color(0xFF00DCE5), Color(0xFF008389)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : null),
                color: hasClaimed
                    ? const Color(0xFF140D28)
                    : (canClaim ? null : const Color(0xFF2D2736)),
                border: hasClaimed
                    ? Border.all(color: const Color(0xFF00F4FE).withValues(alpha: 0.6), width: 1.0)
                    : (canClaim ? null : Border.all(color: const Color(0xFF383241), width: 1.0)),
                boxShadow: canClaim && !hasClaimed
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00F4FE).withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasClaimed
                        ? Icons.task_alt_rounded
                        : (canClaim ? Icons.verified_user_rounded : Icons.lock_outline_rounded),
                    color: hasClaimed
                        ? const Color(0xFF00F4FE)
                        : (canClaim ? Colors.black : const Color(0xFF7E7287)),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasClaimed
                        ? 'GATE BERHASIL DIBERSIHKAN!'
                        : (canClaim
                            ? 'KLAIM HADIAH DUNGEON'
                            : (userLocation == null
                                ? (_isLocating ? 'MENCARI SINYAL GPS...' : 'GPS DIBUTUHKAN')
                                : 'RADIUS > 100M (${distance >= 1000 ? "${(distance / 1000).toStringAsFixed(1)} KM" : "${distance.toStringAsFixed(0)} M"})')),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: hasClaimed
                          ? const Color(0xFF00F4FE)
                          : (canClaim ? Colors.black : const Color(0xFF7E7287)),
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
}
