# PANDUAN LIVE CHALLENGE: UBAH WARNA & KOMPONEN UI LEVMAX
**Dokumen:** `11_Panduan_Live_Challenge_Ubah_Warna_dan_UI.md`  
**Tujuan:** Panduan taktis dan cepat saat sesi live challenge presentasi/UAS jika dosen penguji meminta perubahan warna (AppBar, Background Scaffold, Tombol Utama, Teks Judul, Card, Dialog, atau Icon) secara langsung.  
**Total Penanda:** 529 penanda `// [UBAH_WARNA: ...]` di 18 file UI aplikasi.

---

## 1. TIPS STRATEGIS SAAT LIVE CHALLENGE
1. **Pencarian Cepat Global (VS Code / Android Studio):**
   - Tekan `Ctrl + Shift + F` (Find in Files).
   - Masukkan kata kunci: `[UBAH_WARNA: nama_komponen]` atau cukup `[UBAH_WARNA:` untuk melihat semua pilihan.
2. **Pencarian Cepat di File Terbuka:**
   - Buka file yang diminta, tekan `Ctrl + F`, ketik `[UBAH_WARNA:`.
3. **Terapkan Perubahan dengan Cepat:**
   - Ganti nilainya langsung, contoh: `Color(0xFF00F4FE)` diganti `Colors.amber` atau `Colors.redAccent`.
   - Simpan file (`Ctrl + S`).
4. **Hot Reload Instan:**
   - Buka terminal tempat Flutter berjalan, lalu tekan tombol **`r`** (Hot Reload).
   - Layar perangkat Android akan langsung berganti warna dalam waktu < 1 detik tanpa me-restart aplikasi!

---

## 2. JALUR PINTAS PALING AMPUH: UBAH TEMA GLOBAL (`lib/utils/constants.dart`)
Jika penguji berkata: *"Coba ubah warna tema aplikasi secara keseluruhan dari Cyan/Ungu menjadi Emas/Merah/Hijau"*, Anda **TIDAK PERLU** mengubah satu per satu screen! Cukup buka `lib/utils/constants.dart` dan ubah konstanta utama:

- `AppColors.primaryNeonCyan` -> Warna neon utama (default: `0xFF00F4FE`)
- `AppColors.primaryNeonPurple` -> Warna neon kedua / ungu (default: `0xFFB026FF`)
- `AppColors.surfaceDark` -> Background layar Scaffold gelap (default: `0xFF0F131D` / `0xFF16111E`)
- `AppColors.cardSurface` -> Background kartu card HUD (default: `0xFF161C2A` / `0xFF1F1927`)
- `AppColors.accentGold` -> Warna emas reward / koin (default: `0xFFFFB800`)
- `AppColors.hpRed` -> Warna merah darah / penalti (default: `0xFFFF4D4D`)

---

## 3. TEMA GLOBAL & KONSTANTA WARNA

### File: `lib/utils/constants.dart` (Konstanta Warna Global (AppColors & AppTheme))
**Total Penanda:** 80 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L11` | `// [UBAH_WARNA: GLOBAL - Ungu Utama / Primary Brand]` | `static const Color primary = Color(0xFF8A2BE2); // [UBAH_WARNA: GLOBAL - Ungu...` |
| 2 | `L12` | `// [UBAH_WARNA: GLOBAL - Ungu Neon / Accent Glow]` | `static const Color neonViolet = Color(0xFFB026FF); // [UBAH_WARNA: GLOBAL - U...` |
| 3 | `L13` | `// [UBAH_WARNA: GLOBAL - Lavender Aksen]` | `static const Color accent = Color(0xFFC084FC); // [UBAH_WARNA: GLOBAL - Laven...` |
| 4 | `L14` | `// [UBAH_WARNA: GLOBAL - Dasar Indigo Surface]` | `static const Color indigoGlow = Color(0xFF160F2C); // [UBAH_WARNA: GLOBAL - D...` |
| 5 | `L15` | `// [UBAH_WARNA: GLOBAL - Cyan Biru Mana]` | `static const Color manaBlue = Color(0xFF38BDF8); // [UBAH_WARNA: GLOBAL - Cya...` |
| 6 | `L18` | `// [UBAH_WARNA: GLOBAL - Latar Belakang Hitam Pekat / Abyss]` | `static const Color abyssBlack = Color(0xFF08050E); // [UBAH_WARNA: GLOBAL - L...` |
| 7 | `L19` | `// [UBAH_WARNA: GLOBAL - Latar Surface Gelap]` | `static const Color abyssSurface = Color(0xFF0D0818); // [UBAH_WARNA: GLOBAL -...` |
| 8 | `L20` | `// [UBAH_WARNA: GLOBAL - Warna Kartu Gelap]` | `static const Color cardDark = Color(0xFF120D24); // [UBAH_WARNA: GLOBAL - War...` |
| 9 | `L21` | `// [UBAH_WARNA: GLOBAL - Warna Kartu Terangkat]` | `static const Color cardElevated = Color(0xFF191230); // [UBAH_WARNA: GLOBAL -...` |
| 10 | `L22` | `// [UBAH_WARNA: GLOBAL - Border Kartu Ungu Glow]` | `static const Color cardGlowBorder = Color(0xFF2C1E4E); // [UBAH_WARNA: GLOBAL...` |
| 11 | `L23` | `// [UBAH_WARNA: GLOBAL - Highlight Border]` | `static const Color borderHighlight = Color(0xFF8A2BE2); // [UBAH_WARNA: GLOBA...` |
| 12 | `L24` | `// [UBAH_WARNA: GLOBAL - Ungu Elektrik]` | `static const Color electricPurple = Color(0xFF8A2BE2); // [UBAH_WARNA: GLOBAL...` |
| 13 | `L25` | `// [UBAH_WARNA: GLOBAL - Cyan Terang Mana]` | `static const Color manaCyan = Color(0xFF00E5FF); // [UBAH_WARNA: GLOBAL - Cya...` |
| 14 | `L26` | `// [UBAH_WARNA: GLOBAL - Emas Cerah]` | `static const Color goldAccent = Color(0xFFFFD166); // [UBAH_WARNA: GLOBAL - E...` |
| 15 | `L27` | `// [UBAH_WARNA: GLOBAL - Merah Darah HP]` | `static const Color healthRed = Color(0xFFFF4D6D); // [UBAH_WARNA: GLOBAL - Me...` |
| 16 | `L28` | `// [UBAH_WARNA: GLOBAL - Warna Isi EXP Bar]` | `static const Color expBarFill = Color(0xFF9D4EDD); // [UBAH_WARNA: GLOBAL - W...` |
| 17 | `L29` | `// [UBAH_WARNA: GLOBAL - Teks Putih Perak]` | `static const Color textBrightSilver = Color(0xFFF3EFF5); // [UBAH_WARNA: GLOB...` |
| 18 | `L30` | `// [UBAH_WARNA: GLOBAL - Teks Lavender]` | `static const Color textLavender = Color(0xFFD8B4F8); // [UBAH_WARNA: GLOBAL -...` |
| 19 | `L31` | `// [UBAH_WARNA: GLOBAL - Teks Hint Redup]` | `static const Color textDarkHint = Color(0xFF5D5373); // [UBAH_WARNA: GLOBAL -...` |
| 20 | `L34` | `// [UBAH_WARNA: GLOBAL - Background Utama Aplikasi]` | `static const Color background = Color(0xFF0B0713); // [UBAH_WARNA: GLOBAL - B...` |
| 21 | `L35` | `// [UBAH_WARNA: GLOBAL - Surface Kontainer]` | `static const Color surface = Color(0xFF160F2C); // [UBAH_WARNA: GLOBAL - Surf...` |
| 22 | `L36` | `// [UBAH_WARNA: GLOBAL - Surface Terangkat]` | `static const Color surfaceElevated = Color(0xFF1E153B); // [UBAH_WARNA: GLOBA...` |
| 23 | `L37` | `// [UBAH_WARNA: GLOBAL - Surface Sorotan]` | `static const Color surfaceHighlight = Color(0xFF2A1C52); // [UBAH_WARNA: GLOB...` |
| 24 | `L40` | `// [UBAH_WARNA: GLOBAL - Garis Border Default]` | `static const Color border = Color(0xFF2E2256); // [UBAH_WARNA: GLOBAL - Garis...` |
| 25 | `L41` | `// [UBAH_WARNA: GLOBAL - Garis Border Fokus / Glow]` | `static const Color borderGlow = Color(0xFFB026FF); // [UBAH_WARNA: GLOBAL - G...` |
| 26 | `L42` | `// [UBAH_WARNA: GLOBAL - Garis Pembatas Divider]` | `static const Color divider = Color(0xFF241A42); // [UBAH_WARNA: GLOBAL - Gari...` |
| 27 | `L45` | `// [UBAH_WARNA: GLOBAL - Teks Utama Putih]` | `static const Color textPrimary = Color(0xFFF8FAFC); // [UBAH_WARNA: GLOBAL - ...` |
| 28 | `L46` | `// [UBAH_WARNA: GLOBAL - Teks Sekunder Abu Slate]` | `static const Color textSecondary = Color(0xFFA5B4CB); // [UBAH_WARNA: GLOBAL ...` |
| 29 | `L47` | `// [UBAH_WARNA: GLOBAL - Teks Bantuan Muted]` | `static const Color textMuted = Color(0xFF6B7280); // [UBAH_WARNA: GLOBAL - Te...` |
| 30 | `L48` | `// [UBAH_WARNA: GLOBAL - Teks Nonaktif]` | `static const Color textDisabled = Color(0xFF4B5563); // [UBAH_WARNA: GLOBAL -...` |
| 31 | `L51` | `// [UBAH_WARNA: GLOBAL - Nyawa HP & Warning Merah]` | `static const Color hpRed = Color(0xFFFF3366); // [UBAH_WARNA: GLOBAL - Nyawa ...` |
| 32 | `L52` | `// [UBAH_WARNA: GLOBAL - Merah Gelap HP]` | `static const Color hpRedDark = Color(0xFF990026); // [UBAH_WARNA: GLOBAL - Me...` |
| 33 | `L53` | `// [UBAH_WARNA: GLOBAL - Koin Emas Hunter]` | `static const Color gold = Color(0xFFFFD700); // [UBAH_WARNA: GLOBAL - Koin Em...` |
| 34 | `L54` | `// [UBAH_WARNA: GLOBAL - Emas Gelap]` | `static const Color goldDark = Color(0xFFB8860B); // [UBAH_WARNA: GLOBAL - Ema...` |
| 35 | `L55` | `// [UBAH_WARNA: GLOBAL - Batang Progres EXP]` | `static const Color expBar = Color(0xFF8A2BE2); // [UBAH_WARNA: GLOBAL - Batan...` |
| 36 | `L56` | `// [UBAH_WARNA: GLOBAL - Cahaya Glow Bar EXP]` | `static const Color expBarGlow = Color(0xFFB026FF); // [UBAH_WARNA: GLOBAL - C...` |
| 37 | `L57` | `// [UBAH_WARNA: GLOBAL - Warna Peringatan Warning]` | `static const Color warning = Color(0xFFF59E0B); // [UBAH_WARNA: GLOBAL - Warn...` |
| 38 | `L58` | `// [UBAH_WARNA: GLOBAL - Warna Sukses Berhasil]` | `static const Color success = Color(0xFF10B981); // [UBAH_WARNA: GLOBAL - Warn...` |
| 39 | `L61` | `// [UBAH_WARNA: GLOBAL - Badge Rank F / Silver]` | `static const Color rankF = Color(0xFF9CA3AF); // [UBAH_WARNA: GLOBAL - Badge ...` |
| 40 | `L62` | `// [UBAH_WARNA: GLOBAL - Badge Rank E / Hijau]` | `static const Color rankE = Color(0xFF10B981); // [UBAH_WARNA: GLOBAL - Badge ...` |
| 41 | `L63` | `// [UBAH_WARNA: GLOBAL - Badge Rank D / Cyan]` | `static const Color rankD = Color(0xFF06B6D4); // [UBAH_WARNA: GLOBAL - Badge ...` |
| 42 | `L64` | `// [UBAH_WARNA: GLOBAL - Badge Rank C / Biru]` | `static const Color rankC = Color(0xFF3B82F6); // [UBAH_WARNA: GLOBAL - Badge ...` |
| 43 | `L65` | `// [UBAH_WARNA: GLOBAL - Badge Rank B / Ungu]` | `static const Color rankB = Color(0xFF8B5CF6); // [UBAH_WARNA: GLOBAL - Badge ...` |
| 44 | `L66` | `// [UBAH_WARNA: GLOBAL - Badge Rank A / Magenta]` | `static const Color rankA = Color(0xFFD946EF); // [UBAH_WARNA: GLOBAL - Badge ...` |
| 45 | `L67` | `// [UBAH_WARNA: GLOBAL - Badge Rank S / Neon Violet]` | `static const Color rankS = Color(0xFFB026FF); // [UBAH_WARNA: GLOBAL - Badge ...` |
| 46 | `L304` | `// [UBAH_WARNA: GLOBAL - Latar Belakang Scaffold Tema]` | `scaffoldBackgroundColor: AppColors.background, // [UBAH_WARNA: GLOBAL - Latar...` |
| 47 | `L305` | `// [UBAH_WARNA: GLOBAL - Warna Primer Utama Tema]` | `primaryColor: AppColors.primary, // [UBAH_WARNA: GLOBAL - Warna Primer Utama ...` |
| 48 | `L307` | `// [UBAH_WARNA: GLOBAL - Warna Skema Primer]` | `primary: AppColors.primary, // [UBAH_WARNA: GLOBAL - Warna Skema Primer]` |
| 49 | `L308` | `// [UBAH_WARNA: GLOBAL - Teks di Atas Warna Primer]` | `onPrimary: Colors.white, // [UBAH_WARNA: GLOBAL - Teks di Atas Warna Primer]` |
| 50 | `L309` | `// [UBAH_WARNA: GLOBAL - Warna Sekunder Aksen]` | `secondary: AppColors.neonViolet, // [UBAH_WARNA: GLOBAL - Warna Sekunder Aksen]` |
| 51 | `L311` | `// [UBAH_WARNA: GLOBAL - Permukaan Kartu / Container]` | `surface: AppColors.surface, // [UBAH_WARNA: GLOBAL - Permukaan Kartu / Contai...` |
| 52 | `L312` | `// [UBAH_WARNA: GLOBAL - Teks di Atas Permukaan]` | `onSurface: AppColors.textPrimary, // [UBAH_WARNA: GLOBAL - Teks di Atas Permu...` |
| 53 | `L313` | `// [UBAH_WARNA: GLOBAL - Warna Status Error / HP]` | `error: AppColors.hpRed, // [UBAH_WARNA: GLOBAL - Warna Status Error / HP]` |
| 54 | `L317` | `// [UBAH_WARNA: GLOBAL - Latar Belakang AppBar]` | `backgroundColor: AppColors.background, // [UBAH_WARNA: GLOBAL - Latar Belakan...` |
| 55 | `L321` | `// [UBAH_WARNA: GLOBAL - Ikon AppBar]` | `iconTheme: IconThemeData(color: AppColors.textPrimary), // [UBAH_WARNA: GLOBA...` |
| 56 | `L325` | `// [UBAH_WARNA: GLOBAL - Teks Judul AppBar]` | `color: AppColors.textPrimary, // [UBAH_WARNA: GLOBAL - Teks Judul AppBar]` |
| 57 | `L330` | `// [UBAH_WARNA: GLOBAL - Latar Belakang Card]` | `color: AppColors.surface, // [UBAH_WARNA: GLOBAL - Latar Belakang Card]` |
| 58 | `L334` | `// [UBAH_WARNA: GLOBAL - Garis Tepi Card]` | `side: const BorderSide(color: AppColors.border, width: 1), // [UBAH_WARNA: GL...` |
| 59 | `L340` | `// [UBAH_WARNA: GLOBAL - Latar Belakang Tombol Elevated]` | `backgroundColor: AppColors.primary, // [UBAH_WARNA: GLOBAL - Latar Belakang T...` |
| 60 | `L341` | `// [UBAH_WARNA: GLOBAL - Teks Tombol Elevated]` | `foregroundColor: Colors.white, // [UBAH_WARNA: GLOBAL - Teks Tombol Elevated]` |
| 61 | `L358` | `// [UBAH_WARNA: GLOBAL - Teks Tombol Outlined]` | `foregroundColor: AppColors.neonViolet, // [UBAH_WARNA: GLOBAL - Teks Tombol O...` |
| 62 | `L359` | `// [UBAH_WARNA: GLOBAL - Garis Border Tombol Outlined]` | `side: const BorderSide(color: AppColors.neonViolet, width: 1.2), // [UBAH_WAR...` |
| 63 | `L372` | `// [UBAH_WARNA: GLOBAL - Latar Belakang Input Text Field]` | `fillColor: AppColors.surface, // [UBAH_WARNA: GLOBAL - Latar Belakang Input T...` |
| 64 | `L374` | `// [UBAH_WARNA: GLOBAL - Teks Hint Input]` | `hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14), // [UBA...` |
| 65 | `L375` | `// [UBAH_WARNA: GLOBAL - Teks Label Input]` | `labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14), //...` |
| 66 | `L376` | `// [UBAH_WARNA: GLOBAL - Ikon Prefix Input]` | `prefixIconColor: AppColors.textSecondary, // [UBAH_WARNA: GLOBAL - Ikon Prefi...` |
| 67 | `L377` | `// [UBAH_WARNA: GLOBAL - Ikon Suffix Input]` | `suffixIconColor: AppColors.textSecondary, // [UBAH_WARNA: GLOBAL - Ikon Suffi...` |
| 68 | `L380` | `// [UBAH_WARNA: GLOBAL - Garis Border Input Normal]` | `borderSide: const BorderSide(color: AppColors.border, width: 1), // [UBAH_WAR...` |
| 69 | `L384` | `// [UBAH_WARNA: GLOBAL - Garis Border Input Fokus]` | `borderSide: const BorderSide(color: AppColors.neonViolet, width: 1.5), // [UB...` |
| 70 | `L388` | `// [UBAH_WARNA: GLOBAL - Garis Border Input Error]` | `borderSide: const BorderSide(color: AppColors.hpRed, width: 1), // [UBAH_WARN...` |
| 71 | `L392` | `// [UBAH_WARNA: GLOBAL - Garis Border Input Error Fokus]` | `borderSide: const BorderSide(color: AppColors.hpRed, width: 1.5), // [UBAH_WA...` |
| 72 | `L396` | `// [UBAH_WARNA: GLOBAL - Latar Belakang Bottom Navigation Tema]` | `backgroundColor: AppColors.surface, // [UBAH_WARNA: GLOBAL - Latar Belakang B...` |
| 73 | `L397` | `// [UBAH_WARNA: GLOBAL - Item Terpilih Bottom Navigation]` | `selectedItemColor: AppColors.neonViolet, // [UBAH_WARNA: GLOBAL - Item Terpil...` |
| 74 | `L398` | `// [UBAH_WARNA: GLOBAL - Item Tidak Terpilih Bottom Navigation]` | `unselectedItemColor: AppColors.textMuted, // [UBAH_WARNA: GLOBAL - Item Tidak...` |
| 75 | `L405` | `// [UBAH_WARNA: GLOBAL - Latar Belakang SnackBar Toast]` | `backgroundColor: AppColors.surfaceElevated, // [UBAH_WARNA: GLOBAL - Latar Be...` |
| 76 | `L407` | `// [UBAH_WARNA: GLOBAL - Teks Pesan SnackBar]` | `color: AppColors.textPrimary, // [UBAH_WARNA: GLOBAL - Teks Pesan SnackBar]` |
| 77 | `L413` | `// [UBAH_WARNA: GLOBAL - Garis Border SnackBar]` | `side: const BorderSide(color: AppColors.neonViolet, width: 1), // [UBAH_WARNA...` |
| 78 | `L418` | `// [UBAH_WARNA: GLOBAL - Latar Belakang Modal Dialog]` | `backgroundColor: AppColors.surface, // [UBAH_WARNA: GLOBAL - Latar Belakang M...` |
| 79 | `L422` | `// [UBAH_WARNA: GLOBAL - Garis Border Modal Dialog]` | `side: const BorderSide(color: AppColors.border, width: 1), // [UBAH_WARNA: GL...` |
| 80 | `L428` | `// [UBAH_WARNA: GLOBAL - Garis Pembatas Divider Tema]` | `color: AppColors.divider, // [UBAH_WARNA: GLOBAL - Garis Pembatas Divider Tema]` |

---

### File: `lib/main.dart` (Root Application Theme)
**Total Penanda:** 2 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L48` | `// [UBAH_WARNA: Konfigurasi Tema Utama Aplikasi]` | `theme: AppTheme.darkTheme, // [UBAH_WARNA: Konfigurasi Tema Utama Aplikasi]` |
| 2 | `L49` | `// [UBAH_WARNA: Mode Tema Global (Dark Mode)]` | `themeMode: ThemeMode.dark, // [UBAH_WARNA: Mode Tema Global (Dark Mode)]` |

---

## 4. NAVIGASI UTAMA & SPLASH SCREEN

### File: `lib/screens/main_navigation.dart` (Bottom Navigation Bar & Frame HUD)
**Total Penanda:** 9 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L53` | `// [UBAH_WARNA: Latar Belakang Scaffold Utama Navigation]` | `backgroundColor: const Color(0xFF16111E), // [UBAH_WARNA: Latar Belakang Scaf...` |
| 2 | `L60` | `// [UBAH_WARNA: Latar Belakang Bottom Navigation Bar]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Latar Belakang Bottom Navigat...` |
| 3 | `L63` | `// [UBAH_WARNA: Garis Border Atas Bottom Navigation Bar]` | `color: Color(0xFF2C1E4E), // [UBAH_WARNA: Garis Border Atas Bottom Navigation...` |
| 4 | `L156` | `// [UBAH_WARNA: Cahaya Glow Ikon Navigasi Aktif]` | `color: const Color(0xFFB026FF).withValues(alpha: 0.65), // [UBAH_WARNA: Cahay...` |
| 5 | `L167` | `// [UBAH_WARNA: Ikon Menu Navigasi Aktif]` | `? const Color(0xFFE5B5FF) // [UBAH_WARNA: Ikon Menu Navigasi Aktif]` |
| 6 | `L168` | `// [UBAH_WARNA: Ikon Menu Navigasi Tidak Aktif]` | `: const Color(0xFF6E6485), // [UBAH_WARNA: Ikon Menu Navigasi Tidak Aktif]` |
| 7 | `L180` | `// [UBAH_WARNA: Teks Label Navigasi Aktif]` | `? const Color(0xFFE5B5FF) // [UBAH_WARNA: Teks Label Navigasi Aktif]` |
| 8 | `L181` | `// [UBAH_WARNA: Teks Label Navigasi Tidak Aktif]` | `: const Color(0xFF6E6485), // [UBAH_WARNA: Teks Label Navigasi Tidak Aktif]` |
| 9 | `L185` | `// [UBAH_WARNA: Bayangan Teks Navigasi Aktif]` | `color: const Color(0xFFB026FF).withValues(alpha: 0.8), // [UBAH_WARNA: Bayang...` |

---

### File: `lib/screens/splash_screen.dart` (Splash Screen & Initial Awakening Reactor)
**Total Penanda:** 22 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L28` | `// [UBAH_WARNA: Indikator Status RPC Splash]` | `Color _rpcColor = const Color(0xFF00F0FF); // [UBAH_WARNA: Indikator Status R...` |
| 2 | `L110` | `// [UBAH_WARNA: Latar Belakang Layar Splash]` | `backgroundColor: const Color(0xFF08050E), // [UBAH_WARNA: Latar Belakang Laya...` |
| 3 | `L120` | `// [UBAH_WARNA: Aura Ungu Inti Reaktor Splash]` | `Color(0xFF2B1148), // [UBAH_WARNA: Aura Ungu Inti Reaktor Splash]` |
| 4 | `L169` | `// [UBAH_WARNA: Kartu Bar Atas Splash]` | `color: const Color(0xFF0F091A).withValues(alpha: 0.85), // [UBAH_WARNA: Kartu...` |
| 5 | `L172` | `// [UBAH_WARNA: Border Kartu Bar Atas Splash]` | `color: const Color(0xFF2C1E4E), // [UBAH_WARNA: Border Kartu Bar Atas Splash]` |
| 6 | `L194` | `// [UBAH_WARNA: Titik Status Dot Bar Atas Splash]` | `color: Color(0xFF00F0FF), // [UBAH_WARNA: Titik Status Dot Bar Atas Splash]` |
| 7 | `L211` | `// [UBAH_WARNA: Teks Label Bar Atas Splash]` | `color: const Color(0xFFCBD5E1), // [UBAH_WARNA: Teks Label Bar Atas Splash]` |
| 8 | `L303` | `// [UBAH_WARNA: Teks Header Status Sinkronisasi]` | `color: const Color(0xFFD8B4F8), // [UBAH_WARNA: Teks Header Status Sinkronisasi]` |
| 9 | `L343` | `// [UBAH_WARNA: Teks Judul Status Sinkronisasi Splash]` | `color: const Color(0xFFD8B4F8), // [UBAH_WARNA: Teks Judul Status Sinkronisas...` |
| 10 | `L358` | `// [UBAH_WARNA: Teks Subjudul Status Sinkronisasi Splash]` | `color: const Color(0xFF8B829E), // [UBAH_WARNA: Teks Subjudul Status Sinkroni...` |
| 11 | `L378` | `// [UBAH_WARNA: Latar Belakang Progress Bar]` | `color: const Color(0xFF140D24), // [UBAH_WARNA: Latar Belakang Progress Bar]` |
| 12 | `L381` | `// [UBAH_WARNA: Garis Border Progress Bar]` | `color: const Color(0xFF2C1E4E), // [UBAH_WARNA: Garis Border Progress Bar]` |
| 13 | `L393` | `// [UBAH_WARNA: Gradien Progress Bar Ungu]` | `Color(0xFFB026FF), // [UBAH_WARNA: Gradien Progress Bar Ungu]` |
| 14 | `L394` | `// [UBAH_WARNA: Gradien Progress Bar Cyan]` | `Color(0xFF00F0FF), // [UBAH_WARNA: Gradien Progress Bar Cyan]` |
| 15 | `L400` | `// [UBAH_WARNA: Cahaya Glow Progress Bar]` | `color: Color(0xFF00F0FF), // [UBAH_WARNA: Cahaya Glow Progress Bar]` |
| 16 | `L418` | `// [UBAH_WARNA: Teks Persentase Progress Bar]` | `color: const Color(0xFF00F0FF), // [UBAH_WARNA: Teks Persentase Progress Bar]` |
| 17 | `L595` | `// [UBAH_WARNA: Kotak Status Konsol Bawah Splash]` | `color: const Color(0xFF0D0818).withValues(alpha: 0.9), // [UBAH_WARNA: Kotak ...` |
| 18 | `L598` | `// [UBAH_WARNA: Border Konsol Bawah Splash]` | `color: const Color(0xFF2C1E4E), // [UBAH_WARNA: Border Konsol Bawah Splash]` |
| 19 | `L620` | `// [UBAH_WARNA: Titik Status Dot Konsol Bawah]` | `color: Color(0xFFB026FF), // [UBAH_WARNA: Titik Status Dot Konsol Bawah]` |
| 20 | `L636` | `// [UBAH_WARNA: Teks Label Konsol Bawah]` | `color: const Color(0xFFCBD5E1), // [UBAH_WARNA: Teks Label Konsol Bawah]` |
| 21 | `L654` | `// [UBAH_WARNA: Status Sensor Biometrik Hijau]` | `color: Color(0xFF00FF88), // [UBAH_WARNA: Status Sensor Biometrik Hijau]` |
| 22 | `L677` | `// [UBAH_WARNA: Teks Versi Footer Splash]` | `color: const Color(0xFF6E6485), // [UBAH_WARNA: Teks Versi Footer Splash]` |

---

## 5. AUTENTIKASI & IDENTITAS HUNTER

### File: `lib/screens/auth/login_screen.dart` (Layar Login Hunter)
**Total Penanda:** 38 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L324` | `// [UBAH_WARNA: Latar Belakang Layar Login]` | `backgroundColor: const Color(0xFF16111E), // [UBAH_WARNA: Latar Belakang Laya...` |
| 2 | `L392` | `// [UBAH_WARNA: Header System Window Card]` | `color: const Color(0xFF110C19).withValues(alpha: 0.80), // [UBAH_WARNA: Heade...` |
| 3 | `L403` | `// [UBAH_WARNA: Dot Status System Window]` | `color: Color(0xFF00F4FE), // [UBAH_WARNA: Dot Status System Window]` |
| 4 | `L420` | `// [UBAH_WARNA: Teks Title System Window]` | `color: const Color(0xFFE6FEFF), // [UBAH_WARNA: Teks Title System Window]` |
| 5 | `L434` | `// [UBAH_WARNA: Judul Utama LEVMAX]` | `color: Color(0xFFE5B5FF), // [UBAH_WARNA: Judul Utama LEVMAX]` |
| 6 | `L443` | `// [UBAH_WARNA: Teks Subtitle Login]` | `color: const Color(0xFFD2C1D7), // [UBAH_WARNA: Teks Subtitle Login]` |
| 7 | `L532` | `// [UBAH_WARNA: Background Card Form Login]` | `color: const Color(0xFF1F1927).withValues(alpha: 0.95), // [UBAH_WARNA: Backg...` |
| 8 | `L596` | `// [UBAH_WARNA: Label Input Username]` | `color: const Color(0xFFE5B5FF), // [UBAH_WARNA: Label Input Username]` |
| 9 | `L608` | `// [UBAH_WARNA: Background Input Username]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Background Input Username]` |
| 10 | `L614` | `// [UBAH_WARNA: Warna Teks Input Username]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Warna Teks Input Username]` |
| 11 | `L622` | `// [UBAH_WARNA: Hint Input Username]` | `color: const Color(0xFF9B8BA1).withValues(alpha: 0.40), // [UBAH_WARNA: Hint ...` |
| 12 | `L627` | `// [UBAH_WARNA: Ikon Input Username]` | `color: Color(0xFF9B8BA1), // [UBAH_WARNA: Ikon Input Username]` |
| 13 | `L670` | `// [UBAH_WARNA: Box Security Cipher]` | `color: const Color(0xFF2D2736), // [UBAH_WARNA: Box Security Cipher]` |
| 14 | `L681` | `// [UBAH_WARNA: Dot Status SHA-256]` | `color: Color(0xFF00F4FE), // [UBAH_WARNA: Dot Status SHA-256]` |
| 15 | `L691` | `// [UBAH_WARNA: Teks Hash SHA-256]` | `color: const Color(0xFFE6FEFF), // [UBAH_WARNA: Teks Hash SHA-256]` |
| 16 | `L706` | `// [UBAH_WARNA: Background Input Password]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Background Input Password]` |
| 17 | `L713` | `// [UBAH_WARNA: Warna Teks Input Password]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Warna Teks Input Password]` |
| 18 | `L722` | `// [UBAH_WARNA: Hint Input Password]` | `color: const Color(0xFF9B8BA1).withValues(alpha: 0.40), // [UBAH_WARNA: Hint ...` |
| 19 | `L728` | `// [UBAH_WARNA: Ikon Input Password]` | `color: Color(0xFF9B8BA1), // [UBAH_WARNA: Ikon Input Password]` |
| 20 | `L741` | `// [UBAH_WARNA: Ikon Mata Password]` | `color: const Color(0xFF9B8BA1), // [UBAH_WARNA: Ikon Mata Password]` |
| 21 | `L773` | `// [UBAH_WARNA: Kotak Checkbox Stay Synchronized]` | `color: _staySynchronized // [UBAH_WARNA: Kotak Checkbox Stay Synchronized]` |
| 22 | `L791` | `// [UBAH_WARNA: Label Stay Synchronized]` | `color: const Color(0xFFD2C1D7), // [UBAH_WARNA: Label Stay Synchronized]` |
| 23 | `L813` | `// [UBAH_WARNA: Link Forgot Password]` | `color: const Color(0xFFDCB8FC), // [UBAH_WARNA: Link Forgot Password]` |
| 24 | `L830` | `// [UBAH_WARNA: Tombol Login Awaken - Gradien Ungu Gelap]` | `Color(0xFF7B2CBF), // [UBAH_WARNA: Tombol Login Awaken - Gradien Ungu Gelap]` |
| 25 | `L831` | `// [UBAH_WARNA: Tombol Login Awaken - Gradien Ungu Sedang]` | `Color(0xFF9D4EDD), // [UBAH_WARNA: Tombol Login Awaken - Gradien Ungu Sedang]` |
| 26 | `L832` | `// [UBAH_WARNA: Tombol Login Awaken - Gradien Ungu Terang]` | `Color(0xFFB026FF), // [UBAH_WARNA: Tombol Login Awaken - Gradien Ungu Terang]` |
| 27 | `L839` | `// [UBAH_WARNA: Glow Tombol Awaken]` | `color: const Color(0xFFB026FF).withValues(alpha: 0.45), // [UBAH_WARNA: Glow ...` |
| 28 | `L865` | `// [UBAH_WARNA: Ikon Tombol Login Awaken]` | `color: Color(0xFF00F4FE), // [UBAH_WARNA: Ikon Tombol Login Awaken]` |
| 29 | `L875` | `// [UBAH_WARNA: Teks Tombol Login Awaken]` | `color: const Color(0xFFFFFDFF), // [UBAH_WARNA: Teks Tombol Login Awaken]` |
| 30 | `L893` | `// [UBAH_WARNA: Garis Pemisah Divider Kiri]` | `color: const Color(0xFF383241), // [UBAH_WARNA: Garis Pemisah Divider Kiri]` |
| 31 | `L896` | `// [UBAH_WARNA: Garis Pemisah Divider Kanan]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Garis Pemisah Divider Kanan]` |
| 32 | `L907` | `// [UBAH_WARNA: Teks Pemisah Biometric]` | `color: const Color(0xFF9B8BA1), // [UBAH_WARNA: Teks Pemisah Biometric]` |
| 33 | `L972` | `// [UBAH_WARNA: Teks Belum Punya Akun]` | `color: const Color(0xFFD2C1D7), // [UBAH_WARNA: Teks Belum Punya Akun]` |
| 34 | `L980` | `// [UBAH_WARNA: Link Register Awakened]` | `color: const Color(0xFFE5B5FF), // [UBAH_WARNA: Link Register Awakened]` |
| 35 | `L1046` | `// [UBAH_WARNA: Pod Biometrik Outer]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Pod Biometrik Outer]` |
| 36 | `L1063` | `// [UBAH_WARNA: Pod Biometrik Inner]` | `color: const Color(0xFF231D2B), // [UBAH_WARNA: Pod Biometrik Inner]` |
| 37 | `L1087` | `// [UBAH_WARNA: Judul Pod Biometrik]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Judul Pod Biometrik]` |
| 38 | `L1095` | `// [UBAH_WARNA: Subtitle Pod Biometrik]` | `color: const Color(0xFF9B8BA1), // [UBAH_WARNA: Subtitle Pod Biometrik]` |

---

### File: `lib/screens/auth/register_screen.dart` (Layar Registrasi Hunter)
**Total Penanda:** 29 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L163` | `// [UBAH_WARNA: Latar Belakang Layar Register]` | `backgroundColor: const Color(0xFF16111E), // [UBAH_WARNA: Latar Belakang Laya...` |
| 2 | `L251` | `// [UBAH_WARNA: Tombol Kembali Background]` | `color: const Color(0xFF2D2736), // [UBAH_WARNA: Tombol Kembali Background]` |
| 3 | `L257` | `// [UBAH_WARNA: Tombol Kembali Icon]` | `color: Color(0xFFE5B5FF), // [UBAH_WARNA: Tombol Kembali Icon]` |
| 4 | `L268` | `// [UBAH_WARNA: Protocol Header Background]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Protocol Header Background]` |
| 5 | `L279` | `// [UBAH_WARNA: Protocol Header Status Dot]` | `color: Color(0xFF00F4FE), // [UBAH_WARNA: Protocol Header Status Dot]` |
| 6 | `L296` | `// [UBAH_WARNA: Protocol Header Title]` | `color: const Color(0xFFE6FEFF), // [UBAH_WARNA: Protocol Header Title]` |
| 7 | `L348` | `// [UBAH_WARNA: Avatar Circle Background]` | `color: const Color(0xFF2D2736), // [UBAH_WARNA: Avatar Circle Background]` |
| 8 | `L349` | `// [UBAH_WARNA: Avatar Circle Border]` | `border: Border.all(color: const Color(0xFFB026FF), width: 2.0), // [UBAH_WARN...` |
| 9 | `L386` | `// [UBAH_WARNA: Badge Kamera Background]` | `color: const Color(0xFFB026FF), // [UBAH_WARNA: Badge Kamera Background]` |
| 10 | `L399` | `// [UBAH_WARNA: Badge Kamera Icon]` | `color: Colors.white, // [UBAH_WARNA: Badge Kamera Icon]` |
| 11 | `L414` | `// [UBAH_WARNA: Judul Awaken New Hunter]` | `color: const Color(0xFFDCB8FC), // [UBAH_WARNA: Judul Awaken New Hunter]` |
| 12 | `L427` | `// [UBAH_WARNA: Subtitle System Init]` | `color: const Color(0xFF00DCE5), // [UBAH_WARNA: Subtitle System Init]` |
| 13 | `L440` | `// [UBAH_WARNA: Teks Instruksi Registrasi]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Teks Instruksi Registrasi]` |
| 14 | `L464` | `// [UBAH_WARNA: Background Form Card]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Background Form Card]` |
| 15 | `L467` | `// [UBAH_WARNA: Border Form Card]` | `color: const Color(0xFF383241), // [UBAH_WARNA: Border Form Card]` |
| 16 | `L565` | `// [UBAH_WARNA: Tombol Register - Gradien Ungu]` | `colors: [Color(0xFF7B2CBF), Color(0xFFB026FF)], // [UBAH_WARNA: Tombol Regist...` |
| 17 | `L571` | `// [UBAH_WARNA: Glow Tombol Register]` | `color: const Color(0xFFB026FF).withValues(alpha: 0.35), // [UBAH_WARNA: Glow ...` |
| 18 | `L607` | `// [UBAH_WARNA: Teks Tombol Register]` | `color: Colors.white, // [UBAH_WARNA: Teks Tombol Register]` |
| 19 | `L683` | `// [UBAH_WARNA: Background Input Field]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Background Input Field]` |
| 20 | `L686` | `// [UBAH_WARNA: Border Input Field]` | `color: const Color(0xFF383241), // [UBAH_WARNA: Border Input Field]` |
| 21 | `L695` | `// [UBAH_WARNA: Warna Teks Input Field]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Warna Teks Input Field]` |
| 22 | `L707` | `// [UBAH_WARNA: Hint Input Field]` | `color: const Color(0xFF6E6078), // [UBAH_WARNA: Hint Input Field]` |
| 23 | `L714` | `// [UBAH_WARNA: Icon Prefix Input Field]` | `color: const Color(0xFF9B8BA1), // [UBAH_WARNA: Icon Prefix Input Field]` |
| 24 | `L734` | `// [UBAH_WARNA: Container Biometrik]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Container Biometrik]` |
| 25 | `L758` | `// [UBAH_WARNA: Ikon Face Biometrik]` | `color: Color(0xFFB026FF), // [UBAH_WARNA: Ikon Face Biometrik]` |
| 26 | `L778` | `// [UBAH_WARNA: Judul Biometrik Enroll]` | `color: const Color(0xFFE5B5FF), // [UBAH_WARNA: Judul Biometrik Enroll]` |
| 27 | `L788` | `// [UBAH_WARNA: Subtitle Biometrik Enroll]` | `color: const Color(0xFFD2C1D7), // [UBAH_WARNA: Subtitle Biometrik Enroll]` |
| 28 | `L821` | `// [UBAH_WARNA: Teks Already Awakened]` | `color: const Color(0xFFD2C1D7), // [UBAH_WARNA: Teks Already Awakened]` |
| 29 | `L834` | `// [UBAH_WARNA: Link Login Screen]` | `color: const Color(0xFFE6FEFF), // [UBAH_WARNA: Link Login Screen]` |

---

## 6. LIMA TAB UTAMA DASHBOARD SOLO LEVELING

### File: `lib/screens/tabs/tab_home.dart` (Tab 1: Home Dashboard Matrix & Daily Quests)
**Total Penanda:** 53 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L510` | `// [UBAH_WARNA: Latar Belakang Layar Dashboard Tab Home]` | `backgroundColor: const Color(0xFF16111E), // [UBAH_WARNA: Latar Belakang Laya...` |
| 2 | `L586` | `// [UBAH_WARNA: Banner Awakening Header Background]` | `color: const Color(0xFF140D28), // [UBAH_WARNA: Banner Awakening Header Backg...` |
| 3 | `L589` | `// [UBAH_WARNA: Banner Awakening Header Border]` | `color: const Color(0xFF2C1E4E), // [UBAH_WARNA: Banner Awakening Header Border]` |
| 4 | `L604` | `// [UBAH_WARNA: Dot Status Sistem Header]` | `color: Color(0xFF00F4FE), // [UBAH_WARNA: Dot Status Sistem Header]` |
| 5 | `L625` | `// [UBAH_WARNA: Teks Tag Hunter Header]` | `color: Color(0xFF00F4FE), // [UBAH_WARNA: Teks Tag Hunter Header]` |
| 6 | `L632` | `// [UBAH_WARNA: Teks Greeting Hunter]` | `color: Color(0xFFE9DEF2), // [UBAH_WARNA: Teks Greeting Hunter]` |
| 7 | `L653` | `// [UBAH_WARNA: Card Hunter Matrix Background]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Card Hunter Matrix Background]` |
| 8 | `L656` | `// [UBAH_WARNA: Card Hunter Matrix Border]` | `color: const Color(0xFF2C1E4E), // [UBAH_WARNA: Card Hunter Matrix Border]` |
| 9 | `L682` | `// [UBAH_WARNA: Avatar Frame Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Avatar Frame Background]` |
| 10 | `L685` | `// [UBAH_WARNA: Avatar Frame Border]` | `color: const Color(0xFF00F4FE).withValues(alpha: 0.6), // [UBAH_WARNA: Avatar...` |
| 11 | `L716` | `// [UBAH_WARNA: Tombol Edit Avatar Background]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Tombol Edit Avatar Background]` |
| 12 | `L732` | `// [UBAH_WARNA: Tombol Edit Avatar Icon]` | `color: Colors.black, // [UBAH_WARNA: Tombol Edit Avatar Icon]` |
| 13 | `L757` | `// [UBAH_WARNA: Teks Nama Hunter]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Teks Nama Hunter]` |
| 14 | `L765` | `// [UBAH_WARNA: Ikon Verified Hunter]` | `color: Color(0xFF00F4FE), // [UBAH_WARNA: Ikon Verified Hunter]` |
| 15 | `L776` | `// [UBAH_WARNA: Teks Subtitle Rank Hunter]` | `color: const Color(0xFF9B8BA1), // [UBAH_WARNA: Teks Subtitle Rank Hunter]` |
| 16 | `L787` | `// [UBAH_WARNA: Badge Rank Hunter Background]` | `color: const Color(0xFF2D164D), // [UBAH_WARNA: Badge Rank Hunter Background]` |
| 17 | `L790` | `// [UBAH_WARNA: Badge Rank Hunter Border]` | `color: const Color(0xFFB026FF).withValues(alpha: 0.5), // [UBAH_WARNA: Badge ...` |
| 18 | `L806` | `// [UBAH_WARNA: Ikon Badge Rank Hunter]` | `color: Color(0xFFE5B5FF), // [UBAH_WARNA: Ikon Badge Rank Hunter]` |
| 19 | `L815` | `// [UBAH_WARNA: Teks Badge Rank Hunter]` | `color: const Color(0xFFE5B5FF), // [UBAH_WARNA: Teks Badge Rank Hunter]` |
| 20 | `L845` | `// [UBAH_WARNA: Ikon HP Heart Hunter]` | `color: i <= _currentHp ? const Color(0xFFFF5252) : const Color(0xFF5A4A63), /...` |
| 21 | `L865` | `// [UBAH_WARNA: Pill Gold Hunter Background]` | `color: const Color(0xFF0C242B), // [UBAH_WARNA: Pill Gold Hunter Background]` |
| 22 | `L868` | `// [UBAH_WARNA: Pill Gold Hunter Border]` | `color: const Color(0xFF00F4FE).withValues(alpha: 0.4), // [UBAH_WARNA: Pill G...` |
| 23 | `L877` | `// [UBAH_WARNA: Ikon Pill Gold Hunter]` | `color: Color(0xFF00F4FE), // [UBAH_WARNA: Ikon Pill Gold Hunter]` |
| 24 | `L886` | `// [UBAH_WARNA: Teks Jumlah Gold Hunter]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Teks Jumlah Gold Hunter]` |
| 25 | `L927` | `// [UBAH_WARNA: Track EXP Bar Hunter]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Track EXP Bar Hunter]` |
| 26 | `L941` | `// [UBAH_WARNA: Glow Fill EXP Bar Hunter]` | `color: const Color(0xFF00F4FE).withValues(alpha: 0.5), // [UBAH_WARNA: Glow F...` |
| 27 | `L961` | `// [UBAH_WARNA: Banner Server Time Background]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Banner Server Time Background]` |
| 28 | `L964` | `// [UBAH_WARNA: Banner Server Time Border]` | `color: const Color(0xFF2C1E4E), // [UBAH_WARNA: Banner Server Time Border]` |
| 29 | `L976` | `// [UBAH_WARNA: Ikon Dunia Server Time]` | `color: Color(0xFF00F4FE), // [UBAH_WARNA: Ikon Dunia Server Time]` |
| 30 | `L1059` | `// [UBAH_WARNA: Teks Jam London Server Time]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Teks Jam London Server Time]` |
| 31 | `L1078` | `// [UBAH_WARNA: Latar Belakang Kolom Pencarian Quest]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Latar Belakang Kolom Pencaria...` |
| 32 | `L1081` | `// [UBAH_WARNA: Garis Border Kolom Pencarian Quest]` | `color: const Color(0xFF2C1E4E), // [UBAH_WARNA: Garis Border Kolom Pencarian ...` |
| 33 | `L1090` | `// [UBAH_WARNA: Warna Teks Input Cari Quest]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Warna Teks Input Cari Quest]` |
| 34 | `L1098` | `// [UBAH_WARNA: Warna Hint Cari Quest]` | `color: const Color(0xFF5D5373), // [UBAH_WARNA: Warna Hint Cari Quest]` |
| 35 | `L1102` | `// [UBAH_WARNA: Ikon Search Quest]` | `color: Color(0xFF8B829E), // [UBAH_WARNA: Ikon Search Quest]` |
| 36 | `L1137` | `// [UBAH_WARNA: Background Filter Chip Quest]` | `color: isSelected ? const Color(0xFFB026FF) : const Color(0xFF1F1927), // [UB...` |
| 37 | `L1189` | `// [UBAH_WARNA: Ikon Api Daily Quests Header]` | `color: Color(0xFFFF7A00), // [UBAH_WARNA: Ikon Api Daily Quests Header]` |
| 38 | `L1200` | `// [UBAH_WARNA: Judul Daily Quests Header]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Judul Daily Quests Header]` |
| 39 | `L1471` | `// [UBAH_WARNA: Background Card Quest]` | `color: isDone ? const Color(0xFF16121D) : const Color(0xFF1F1927), // [UBAH_W...` |
| 40 | `L1474` | `// [UBAH_WARNA: Border Card Quest]` | `color: isDone ? const Color(0xFF2C2436) : const Color(0xFF383241), // [UBAH_W...` |
| 41 | `L1520` | `// [UBAH_WARNA: Judul Card Quest]` | `color: isDone ? const Color(0xFF7E728C) : const Color(0xFFE9DEF2), // [UBAH_W...` |
| 42 | `L1679` | `// [UBAH_WARNA: Border Tombol Scan Hidden Dungeon]` | `color: const Color(0xFFFF0055).withValues(alpha: 0.8), // [UBAH_WARNA: Border...` |
| 43 | `L1728` | `// [UBAH_WARNA: Ikon Tombol Scan Hidden Dungeon]` | `color: Colors.white, // [UBAH_WARNA: Ikon Tombol Scan Hidden Dungeon]` |
| 44 | `L1747` | `// [UBAH_WARNA: Judul Tombol Scan Hidden Dungeon]` | `color: const Color(0xFFFF2A6D), // [UBAH_WARNA: Judul Tombol Scan Hidden Dung...` |
| 45 | `L2044` | `// [UBAH_WARNA: Background Card Nearby Gate]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Background Card Nearby Gate]` |
| 46 | `L2047` | `// [UBAH_WARNA: Border Card Nearby Gate]` | `color: const Color(0xFF383241), // [UBAH_WARNA: Border Card Nearby Gate]` |
| 47 | `L2062` | `// [UBAH_WARNA: Ikon Radar Nearby Gate]` | `color: Color(0xFF00F4FE), // [UBAH_WARNA: Ikon Radar Nearby Gate]` |
| 48 | `L2101` | `// [UBAH_WARNA: Tombol Enter Gate Background]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Tombol Enter Gate Background]` |
| 49 | `L2118` | `// [UBAH_WARNA: Tombol Enter Gate Icon]` | `color: Colors.black, // [UBAH_WARNA: Tombol Enter Gate Icon]` |
| 50 | `L2127` | `// [UBAH_WARNA: Tombol Enter Gate Teks]` | `color: Colors.black, // [UBAH_WARNA: Tombol Enter Gate Teks]` |
| 51 | `L2148` | `// [UBAH_WARNA: FAB Tombol Alarm Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: FAB Tombol Alarm Background]` |
| 52 | `L3921` | `// [UBAH_WARNA: FAB Hunter AI Brain Background]` | `color: const Color(0xFFB026FF), // [UBAH_WARNA: FAB Hunter AI Brain Background]` |
| 53 | `L3934` | `// [UBAH_WARNA: FAB Hunter AI Brain Icon]` | `color: Colors.white, // [UBAH_WARNA: FAB Hunter AI Brain Icon]` |

---

### File: `lib/screens/tabs/tab_map.dart` (Tab 2: LBS Map & Radar Gate)
**Total Penanda:** 29 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L474` | `// [UBAH_WARNA: Latar Belakang Layar Peta LBS Dungeon Radar]` | `backgroundColor: const Color(0xFF16111E), // [UBAH_WARNA: Latar Belakang Laya...` |
| 2 | `L582` | `// [UBAH_WARNA: Background Header Top Bar Peta]` | `color: const Color(0xFF110C19).withValues(alpha: 0.95), // [UBAH_WARNA: Backg...` |
| 3 | `L584` | `// [UBAH_WARNA: Border Bottom Header Peta]` | `bottom: BorderSide(color: Color(0xFF2C1E4E), width: 1.0), // [UBAH_WARNA: Bor...` |
| 4 | `L613` | `// [UBAH_WARNA: Teks Hunter Name Header Peta]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Teks Hunter Name Header Peta]` |
| 5 | `L639` | `// [UBAH_WARNA: Teks Badge Rank Header Peta]` | `color: const Color(0xFFE5B5FF), // [UBAH_WARNA: Teks Badge Rank Header Peta]` |
| 6 | `L654` | `// [UBAH_WARNA: Ikon HP Header Peta]` | `child: Icon(Icons.favorite_rounded, size: 13, color: Color(0xFFFF4D4D)), // [...` |
| 7 | `L671` | `// [UBAH_WARNA: Teks Gold Header Peta]` | `color: const Color(0xFFFFD166), // [UBAH_WARNA: Teks Gold Header Peta]` |
| 8 | `L777` | `// [UBAH_WARNA: Background Radar HUD Peta]` | `color: const Color(0xFF110C19).withValues(alpha: 0.85), // [UBAH_WARNA: Backg...` |
| 9 | `L780` | `// [UBAH_WARNA: Border Radar HUD Peta]` | `color: const Color(0xFF00F4FE).withValues(alpha: 0.5), // [UBAH_WARNA: Border...` |
| 10 | `L801` | `// [UBAH_WARNA: Blip Center Radar Peta]` | `color: Color(0xFF00F4FE), // [UBAH_WARNA: Blip Center Radar Peta]` |
| 11 | `L822` | `// [UBAH_WARNA: Ring Radar Peta]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Ring Radar Peta]` |
| 12 | `L837` | `// [UBAH_WARNA: Teks Koordinat Radar Peta]` | `color: const Color(0xFFDCB8FC), // [UBAH_WARNA: Teks Koordinat Radar Peta]` |
| 13 | `L852` | `// [UBAH_WARNA: Pill GPS Accuracy Background]` | `color: const Color(0xFF2D2736).withValues(alpha: 0.9), // [UBAH_WARNA: Pill G...` |
| 14 | `L858` | `// [UBAH_WARNA: Ikon Satelit GPS Peta]` | `const Icon(Icons.satellite_alt_rounded, size: 13, color: Color(0xFF00F4FE)), ...` |
| 15 | `L1395` | `// [UBAH_WARNA: Pill Jarak Gate Background]` | `color: const Color(0xFF2D2736).withValues(alpha: 0.9), // [UBAH_WARNA: Pill J...` |
| 16 | `L1413` | `// [UBAH_WARNA: Teks Jarak Gate Peta]` | `color: const Color(0xFFFF4D4D), // [UBAH_WARNA: Teks Jarak Gate Peta]` |
| 17 | `L1585` | `// [UBAH_WARNA: FAB Recenter GPS Background]` | `color: const Color(0xFF110C19).withValues(alpha: 0.92), // [UBAH_WARNA: FAB R...` |
| 18 | `L1587` | `// [UBAH_WARNA: FAB Recenter GPS Border]` | `border: Border.all(color: const Color(0xFF00F4FE), width: 0.8), // [UBAH_WARN...` |
| 19 | `L1601` | `// [UBAH_WARNA: FAB Recenter GPS Icon]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: FAB Recenter GPS Icon]` |
| 20 | `L1615` | `// [UBAH_WARNA: Bottom Sheet Panel Ekspedisi Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Bottom Sheet Panel Ekspedisi ...` |
| 21 | `L1666` | `// [UBAH_WARNA: Card Target Gate Panel]` | `color: const Color(0xFF110C19).withValues(alpha: 0.65), // [UBAH_WARNA: Card ...` |
| 22 | `L1675` | `// [UBAH_WARNA: Ikon Target Gate Panel]` | `const Icon(Icons.near_me_rounded, color: Color(0xFF00F4FE), size: 16), // [UB...` |
| 23 | `L1687` | `// [UBAH_WARNA: Teks Rank Target Gate Panel]` | `color: const Color(0xFFDCB8FC), // [UBAH_WARNA: Teks Rank Target Gate Panel]` |
| 24 | `L1695` | `// [UBAH_WARNA: Teks Nama Target Gate Panel]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Teks Nama Target Gate Panel]` |
| 25 | `L1759` | `// [UBAH_WARNA: Card Mystery Gift Box]` | `color: const Color(0xFF110C19).withValues(alpha: 0.65), // [UBAH_WARNA: Card ...` |
| 26 | `L1781` | `// [UBAH_WARNA: Teks Judul Mystery Gift]` | `color: const Color(0xFFFFD166), // [UBAH_WARNA: Teks Judul Mystery Gift]` |
| 27 | `L1784` | `// [UBAH_WARNA: Ikon Bintang Mystery Gift]` | `const Icon(Icons.stars_rounded, color: Color(0xFFFFD166), size: 16), // [UBAH...` |
| 28 | `L1925` | `// [UBAH_WARNA: Tombol Klaim Dungeon Expedition - Gradien Cyan]` | `colors: [Color(0xFF00F4FE), Color(0xFF00DCE5), Color(0xFF008389)], // [UBAH_W...` |
| 29 | `L1971` | `// [UBAH_WARNA: Teks Tombol Klaim Mystery Gift]` | `color: hasClaimed // [UBAH_WARNA: Teks Tombol Klaim Mystery Gift]` |

---

### File: `lib/screens/tabs/tab_game.dart` (Tab 3: Gyroscope Mana Core Mini Game)
**Total Penanda:** 29 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L314` | `// [UBAH_WARNA: Dialog Menang Background]` | `backgroundColor: const Color(0xFF140D24), // [UBAH_WARNA: Dialog Menang Backg...` |
| 2 | `L317` | `// [UBAH_WARNA: Dialog Menang Border]` | `side: const BorderSide(color: Color(0xFF00F4FE), width: 1.5), // [UBAH_WARNA:...` |
| 3 | `L393` | `// [UBAH_WARNA: Tombol Klaim Hadiah Dialog]` | `backgroundColor: const Color(0xFF00F4FE), // [UBAH_WARNA: Tombol Klaim Hadiah...` |
| 4 | `L421` | `// [UBAH_WARNA: Dialog Kalah Background]` | `backgroundColor: const Color(0xFF140D24), // [UBAH_WARNA: Dialog Kalah Backgr...` |
| 5 | `L424` | `// [UBAH_WARNA: Dialog Kalah Border]` | `side: const BorderSide(color: Color(0xFFFF4D4D), width: 1.5), // [UBAH_WARNA:...` |
| 6 | `L493` | `// [UBAH_WARNA: Tombol Coba Lagi Dialog]` | `backgroundColor: const Color(0xFFFF4D4D), // [UBAH_WARNA: Tombol Coba Lagi Di...` |
| 7 | `L561` | `// [UBAH_WARNA: Latar Belakang Layar Mini Game Mana Core]` | `backgroundColor: const Color(0xFF16111E), // [UBAH_WARNA: Latar Belakang Laya...` |
| 8 | `L618` | `// [UBAH_WARNA: Background Header Top Bar Game]` | `color: const Color(0xFF110C19).withValues(alpha: 0.95), // [UBAH_WARNA: Backg...` |
| 9 | `L795` | `// [UBAH_WARNA: Pill Sensor Gyroscope Background]` | `color: const Color(0xFF2D2736).withValues(alpha: 0.85), // [UBAH_WARNA: Pill ...` |
| 10 | `L811` | `// [UBAH_WARNA: Dot Status Gyroscope]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Dot Status Gyroscope]` |
| 11 | `L899` | `// [UBAH_WARNA: Banner Instruksi Mini Game Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Banner Instruksi Mini Game Ba...` |
| 12 | `L905` | `// [UBAH_WARNA: Ikon Rotasi Instruksi]` | `const Icon(Icons.screen_rotation_rounded, color: Color(0xFF00F4FE), size: 18)...` |
| 13 | `L952` | `// [UBAH_WARNA: Arena Gyroscope Background]` | `color: const Color(0xFF120D24), // [UBAH_WARNA: Arena Gyroscope Background]` |
| 14 | `L1070` | `// [UBAH_WARNA: Lingkaran Safe Zone Target]` | `color: _isInCenter // [UBAH_WARNA: Lingkaran Safe Zone Target]` |
| 15 | `L1125` | `// [UBAH_WARNA: Bola Mana Core Glow Ungu]` | `color: const Color(0xFFB026FF).withValues(alpha: 0.8), // [UBAH_WARNA: Bola M...` |
| 16 | `L1130` | `// [UBAH_WARNA: Bola Mana Core Glow Cyan]` | `color: const Color(0xFF00F4FE).withValues(alpha: 0.8), // [UBAH_WARNA: Bola M...` |
| 17 | `L1135` | `// [UBAH_WARNA: Bola Mana Core Inti]` | `color: Colors.white, // [UBAH_WARNA: Bola Mana Core Inti]` |
| 18 | `L1168` | `// [UBAH_WARNA: Box Pitch Tilt Meter]` | `color: const Color(0xFF2D2736).withValues(alpha: 0.7), // [UBAH_WARNA: Box Pi...` |
| 19 | `L1202` | `// [UBAH_WARNA: Box Roll Tilt Meter]` | `color: const Color(0xFF2D2736).withValues(alpha: 0.7), // [UBAH_WARNA: Box Ro...` |
| 20 | `L1254` | `// [UBAH_WARNA: Card Status Game Timer Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Card Status Game Timer Backgr...` |
| 21 | `L1312` | `// [UBAH_WARNA: Teks Display Timer Game]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Teks Display Timer Game]` |
| 22 | `L1356` | `// [UBAH_WARNA: Track Progress Bar Timer]` | `backgroundColor: const Color(0xFF110C19), // [UBAH_WARNA: Track Progress Bar ...` |
| 23 | `L1372` | `// [UBAH_WARNA: Card Reward Gold Game Background]` | `color: const Color(0xFF1B1406), // [UBAH_WARNA: Card Reward Gold Game Backgro...` |
| 24 | `L1375` | `// [UBAH_WARNA: Card Reward Gold Game Border]` | `color: const Color(0xFFFFD166).withValues(alpha: 0.35), // [UBAH_WARNA: Card ...` |
| 25 | `L1411` | `// [UBAH_WARNA: Teks Nilai Reward Gold]` | `color: const Color(0xFFFFD166), // [UBAH_WARNA: Teks Nilai Reward Gold]` |
| 26 | `L1454` | `// [UBAH_WARNA: Banner Daily Reward Claimed Background]` | `color: const Color(0xFF1E1728), // [UBAH_WARNA: Banner Daily Reward Claimed B...` |
| 27 | `L1546` | `// [UBAH_WARNA: Tombol Mini Game Retry - Merah Gagal]` | `? [const Color(0xFF93000A), const Color(0xFFFF5449)] // [UBAH_WARNA: Tombol M...` |
| 28 | `L1547` | `// [UBAH_WARNA: Tombol Mini Game Start - Ungu Aktif]` | `: [const Color(0xFF7B2CBF), const Color(0xFFB026FF)], // [UBAH_WARNA: Tombol ...` |
| 29 | `L1577` | `// [UBAH_WARNA: Teks Tombol Mainkan Game]` | `color: Colors.white, // [UBAH_WARNA: Teks Tombol Mainkan Game]` |

---

### File: `lib/screens/tabs/tab_shop.dart` (Tab 4: Monarch Treasury & DEX Valuation)
**Total Penanda:** 32 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L329` | `// [UBAH_WARNA: Dialog Kalkulator Kurs Background]` | `color: const Color(0xFF140D24), // [UBAH_WARNA: Dialog Kalkulator Kurs Backgr...` |
| 2 | `L334` | `// [UBAH_WARNA: Dialog Kalkulator Kurs Border]` | `border: Border.all(color: const Color(0xFF00F4FE).withValues(alpha: 0.5), wid...` |
| 3 | `L385` | `// [UBAH_WARNA: Input Nilai Gold Kalkulator]` | `color: const Color(0xFFFFD166), // [UBAH_WARNA: Input Nilai Gold Kalkulator]` |
| 4 | `L548` | `// [UBAH_WARNA: Dialog Top-Up Gold Background]` | `color: const Color(0xFF140D24), // [UBAH_WARNA: Dialog Top-Up Gold Background]` |
| 5 | `L550` | `// [UBAH_WARNA: Dialog Top-Up Gold Border]` | `border: Border.all(color: const Color(0xFF00F4FE).withValues(alpha: 0.6), wid...` |
| 6 | `L721` | `// [UBAH_WARNA: Tombol Top-Up Saldo Confirm]` | `backgroundColor: const Color(0xFF00F4FE), // [UBAH_WARNA: Tombol Top-Up Saldo...` |
| 7 | `L1596` | `// [UBAH_WARNA: Latar Belakang Layar Tab Shop]` | `backgroundColor: const Color(0xFF16111E), // [UBAH_WARNA: Latar Belakang Laya...` |
| 8 | `L1670` | `// [UBAH_WARNA: Pill Rank Header Shop Background]` | `color: const Color(0xFF2D2736), // [UBAH_WARNA: Pill Rank Header Shop Backgro...` |
| 9 | `L1679` | `// [UBAH_WARNA: Pill Rank Header Shop Teks]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Pill Rank Header Shop Teks]` |
| 10 | `L1714` | `// [UBAH_WARNA: Judul Header Monarch Treasury]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Judul Header Monarch Treasury]` |
| 11 | `L1726` | `// [UBAH_WARNA: Pill Status DEX Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Pill Status DEX Background]` |
| 12 | `L1738` | `// [UBAH_WARNA: Pill Status DEX Teks]` | `color: const Color(0xFFE6FEFF), // [UBAH_WARNA: Pill Status DEX Teks]` |
| 13 | `L1785` | `// [UBAH_WARNA: Chip Protokol Live Market Background]` | `color: const Color(0xFF2D2736), // [UBAH_WARNA: Chip Protokol Live Market Bac...` |
| 14 | `L1801` | `// [UBAH_WARNA: Dot Indikator Market Live]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Dot Indikator Market Live]` |
| 15 | `L1826` | `// [UBAH_WARNA: Chip Vault Balance Background]` | `color: const Color(0xFF2D2736), // [UBAH_WARNA: Chip Vault Balance Background]` |
| 16 | `L1848` | `// [UBAH_WARNA: Teks Gold Vault Balance]` | `color: const Color(0xFFFFD166), // [UBAH_WARNA: Teks Gold Vault Balance]` |
| 17 | `L1961` | `// [UBAH_WARNA: Card Kurs Valuasi Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Card Kurs Valuasi Background]` |
| 18 | `L1963` | `// [UBAH_WARNA: Card Kurs Valuasi Border]` | `border: Border.all(color: const Color(0xFF2C1E4E), width: 0.8), // [UBAH_WARN...` |
| 19 | `L1973` | `// [UBAH_WARNA: Ikon Kurs Valuasi Header]` | `const Icon(Icons.currency_exchange_rounded, size: 16, color: Color(0xFF00F4FE...` |
| 20 | `L1981` | `// [UBAH_WARNA: Judul Kurs Valuasi Header]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Judul Kurs Valuasi Header]` |
| 21 | `L2057` | `// [UBAH_WARNA: Teks Total Wealth Hunter]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Teks Total Wealth Hunter]` |
| 22 | `L2068` | `// [UBAH_WARNA: Tombol Kalkulator Kurs Background]` | `color: const Color(0xFFB026FF).withValues(alpha: 0.2), // [UBAH_WARNA: Tombol...` |
| 23 | `L2081` | `// [UBAH_WARNA: Tombol Kalkulator Kurs Teks]` | `color: const Color(0xFFE5B5FF), // [UBAH_WARNA: Tombol Kalkulator Kurs Teks]` |
| 24 | `L2245` | `// [UBAH_WARNA: Card Item Gelar Shop Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Card Item Gelar Shop Background]` |
| 25 | `L2275` | `// [UBAH_WARNA: Well Ikon Item Gelar]` | `color: const Color(0xFF2D2736), // [UBAH_WARNA: Well Ikon Item Gelar]` |
| 26 | `L2302` | `// [UBAH_WARNA: Nama Item Gelar Shop]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Nama Item Gelar Shop]` |
| 27 | `L2338` | `// [UBAH_WARNA: Harga Item Gelar Gold]` | `color: const Color(0xFFFFD166), // [UBAH_WARNA: Harga Item Gelar Gold]` |
| 28 | `L2363` | `// [UBAH_WARNA: Tombol Beli Title - Gradien Cyan Ungu]` | `colors: [Color(0xFF00F4FE), Color(0xFFB026FF)], // [UBAH_WARNA: Tombol Beli T...` |
| 29 | `L2420` | `// [UBAH_WARNA: Teks Tombol Beli Gelar]` | `color: isOwned ? const Color(0xFF00F4FE) : Colors.black, // [UBAH_WARNA: Teks...` |
| 30 | `L2599` | `// [UBAH_WARNA: Tombol Blockchain Explorer Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Tombol Blockchain Explorer Ba...` |
| 31 | `L2616` | `// [UBAH_WARNA: Ikon Tombol Blockchain Explorer]` | `child: const Icon(Icons.hub_rounded, size: 18, color: Color(0xFF00F4FE)), // ...` |
| 32 | `L2625` | `// [UBAH_WARNA: Teks Tombol Blockchain Explorer]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Teks Tombol Blockchain Explorer]` |

---

### File: `lib/screens/tabs/tab_profile.dart` (Tab 5: Hunter Profile & Course Feedback Form)
**Total Penanda:** 37 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L261` | `// [UBAH_WARNA: Dialog Logout Background]` | `backgroundColor: const Color(0xFF140D24), // [UBAH_WARNA: Dialog Logout Backg...` |
| 2 | `L264` | `// [UBAH_WARNA: Dialog Logout Border]` | `side: const BorderSide(color: Color(0xFFFF4D4D), width: 1.0), // [UBAH_WARNA:...` |
| 3 | `L294` | `// [UBAH_WARNA: Tombol Konfirmasi Logout Background]` | `backgroundColor: const Color(0xFF93000A), // [UBAH_WARNA: Tombol Konfirmasi L...` |
| 4 | `L430` | `// [UBAH_WARNA: Latar Belakang Layar Tab Profile]` | `backgroundColor: const Color(0xFF16111E), // [UBAH_WARNA: Latar Belakang Laya...` |
| 5 | `L487` | `// [UBAH_WARNA: Header Rank Pill Background]` | `color: const Color(0xFF2D2736), // [UBAH_WARNA: Header Rank Pill Background]` |
| 6 | `L496` | `// [UBAH_WARNA: Header Rank Pill Teks]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Header Rank Pill Teks]` |
| 7 | `L531` | `// [UBAH_WARNA: Header Judul Profil]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Header Judul Profil]` |
| 8 | `L660` | `// [UBAH_WARNA: Card Hunter ID Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Card Hunter ID Background]` |
| 9 | `L662` | `// [UBAH_WARNA: Card Hunter ID Border]` | `border: Border.all(color: const Color(0xFF2C1E4E), width: 0.8), // [UBAH_WARN...` |
| 10 | `L761` | `// [UBAH_WARNA: Tombol Ganti Avatar Mini Background]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Tombol Ganti Avatar Mini Back...` |
| 11 | `L797` | `// [UBAH_WARNA: Nama Hunter Profile]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Nama Hunter Profile]` |
| 12 | `L802` | `// [UBAH_WARNA: Ikon Verified Hunter Profile]` | `const Icon(Icons.verified_rounded, size: 18, color: Color(0xFF00F4FE)), // [U...` |
| 13 | `L956` | `// [UBAH_WARNA: Box Classification Badge Background]` | `color: const Color(0xFF2D2736), // [UBAH_WARNA: Box Classification Badge Back...` |
| 14 | `L958` | `// [UBAH_WARNA: Box Classification Badge Border]` | `border: Border.all(color: const Color(0xFF383241)), // [UBAH_WARNA: Box Class...` |
| 15 | `L1009` | `// [UBAH_WARNA: Tier Badge World Background]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Tier Badge World Background]` |
| 16 | `L1017` | `// [UBAH_WARNA: Tier Badge World Teks]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Tier Badge World Teks]` |
| 17 | `L1093` | `// [UBAH_WARNA: Card Total Gold Profile Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Card Total Gold Profile Backg...` |
| 18 | `L1095` | `// [UBAH_WARNA: Card Total Gold Profile Border]` | `border: Border.all(color: const Color(0xFF2C1E4E), width: 0.8), // [UBAH_WARN...` |
| 19 | `L1112` | `// [UBAH_WARNA: Ikon Total Gold Profile]` | `const Icon(Icons.monetization_on_rounded, size: 16, color: Color(0xFFFFD166))...` |
| 20 | `L1131` | `// [UBAH_WARNA: Teks Nilai Total Gold Profile]` | `color: const Color(0xFFFFD166), // [UBAH_WARNA: Teks Nilai Total Gold Profile]` |
| 21 | `L1156` | `// [UBAH_WARNA: Card Quests Done Profile Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Card Quests Done Profile Back...` |
| 22 | `L1158` | `// [UBAH_WARNA: Card Quests Done Profile Border]` | `border: Border.all(color: const Color(0xFF2C1E4E), width: 0.8), // [UBAH_WARN...` |
| 23 | `L1175` | `// [UBAH_WARNA: Ikon Quests Done Profile]` | `const Icon(Icons.task_alt_rounded, size: 16, color: Color(0xFF00F4FE)), // [U...` |
| 24 | `L1204` | `// [UBAH_WARNA: Teks Nilai Quests Done Profile]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Teks Nilai Quests Done Profile]` |
| 25 | `L1688` | `// [UBAH_WARNA: Switch Fingerprint Aktif]` | `activeTrackColor: const Color(0xFFB026FF), // [UBAH_WARNA: Switch Fingerprint...` |
| 26 | `L1759` | `// [UBAH_WARNA: Switch Face Scan Aktif]` | `activeTrackColor: const Color(0xFF00F4FE), // [UBAH_WARNA: Switch Face Scan A...` |
| 27 | `L1884` | `// [UBAH_WARNA: Label Tipe Penyimpanan Feedback]` | `color: const Color(0xFF9B8BA1), // [UBAH_WARNA: Label Tipe Penyimpanan Feedback]` |
| 28 | `L1986` | `// [UBAH_WARNA: Background Input Saran Kesan]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Background Input Saran Kesan]` |
| 29 | `L1988` | `// [UBAH_WARNA: Border Input Saran Kesan]` | `border: Border.all(color: const Color(0xFF383241)), // [UBAH_WARNA: Border In...` |
| 30 | `L1994` | `// [UBAH_WARNA: Warna Teks Input Saran Kesan]` | `style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFFE9DEF...` |
| 31 | `L1999` | `// [UBAH_WARNA: Hint Input Saran Kesan]` | `hintStyle: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF9...` |
| 32 | `L2053` | `// [UBAH_WARNA: Tombol Submit Feedback]` | `colors: [Color(0xFFB026FF), Color(0xFF9200DB)], // [UBAH_WARNA: Tombol Submit...` |
| 33 | `L2077` | `// [UBAH_WARNA: Teks Tombol Submit Feedback]` | `color: Colors.white, // [UBAH_WARNA: Teks Tombol Submit Feedback]` |
| 34 | `L2111` | `// [UBAH_WARNA: Tombol Logout Background]` | `color: const Color(0xFF93000A).withValues(alpha: 0.2), // [UBAH_WARNA: Tombol...` |
| 35 | `L2113` | `// [UBAH_WARNA: Tombol Logout Border]` | `border: Border.all(color: const Color(0xFF93000A).withValues(alpha: 0.6)), //...` |
| 36 | `L2124` | `// [UBAH_WARNA: Ikon Tombol Logout]` | `const Icon(Icons.power_settings_new_rounded, size: 18, color: Color(0xFFFFB4A...` |
| 37 | `L2132` | `// [UBAH_WARNA: Teks Tombol Logout]` | `color: const Color(0xFFFFB4AB), // [UBAH_WARNA: Teks Tombol Logout]` |

---

## 7. FITUR SPESIFIK & SENSOR PROTOKOL

### File: `lib/screens/features/appearance_quest_screen.dart` (Appearance Quest (21:00 Night Skincare Routine))
**Total Penanda:** 23 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L130` | `// [UBAH_WARNA: Latar Belakang Layar Appearance Protocol]` | `backgroundColor: const Color(0xFF16111E), // [UBAH_WARNA: Latar Belakang Laya...` |
| 2 | `L144` | `// [UBAH_WARNA: Box System Header Appearance]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Box System Header Appearance]` |
| 3 | `L248` | `// [UBAH_WARNA: Card Judul Appearance Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Card Judul Appearance Backgro...` |
| 4 | `L278` | `// [UBAH_WARNA: Ikon Night Window Appearance]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Ikon Night Window Appearance]` |
| 5 | `L306` | `// [UBAH_WARNA: Teks Judul Appearance Quest]` | `color: Colors.white, // [UBAH_WARNA: Teks Judul Appearance Quest]` |
| 6 | `L320` | `// [UBAH_WARNA: Badge Waktu Malam Background]` | `color: const Color(0xFF141E2D), // [UBAH_WARNA: Badge Waktu Malam Background]` |
| 7 | `L342` | `// [UBAH_WARNA: Teks Status Waktu Malam]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Teks Status Waktu Malam]` |
| 8 | `L431` | `// [UBAH_WARNA: Card Progress Indicator Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Card Progress Indicator Backg...` |
| 9 | `L460` | `// [UBAH_WARNA: Fill Bar Progress Appearance]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Fill Bar Progress Appearance]` |
| 10 | `L495` | `// [UBAH_WARNA: Banner Peringatan Waktu 21:00 Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Banner Peringatan Waktu 21:00...` |
| 11 | `L510` | `// [UBAH_WARNA: Ikon Jam Peringatan Waktu]` | `color: Color(0xFF00F4FE), // [UBAH_WARNA: Ikon Jam Peringatan Waktu]` |
| 12 | `L565` | `// [UBAH_WARNA: Card Reward Protokol Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Card Reward Protokol Background]` |
| 13 | `L649` | `// [UBAH_WARNA: Teks Reward EXP Appearance]` | `color: const Color(0xFFE5B5FF), // [UBAH_WARNA: Teks Reward EXP Appearance]` |
| 14 | `L669` | `// [UBAH_WARNA: Teks Reward Gold Appearance]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Teks Reward Gold Appearance]` |
| 15 | `L719` | `// [UBAH_WARNA: Tile Checklist Item Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Tile Checklist Item Background]` |
| 16 | `L766` | `// [UBAH_WARNA: Nomor Langkah Checklist]` | `color: isChecked ? const Color(0xFF00F4FE) : const Color(0xFF6B6280), // [UBA...` |
| 17 | `L802` | `// [UBAH_WARNA: Judul Langkah Checklist]` | `color: isChecked // [UBAH_WARNA: Judul Langkah Checklist]` |
| 18 | `L837` | `// [UBAH_WARNA: Kotak Checkbox Appearance]` | `color: isChecked ? const Color(0xFFB026FF) : const Color(0xFF16111E), // [UBA...` |
| 19 | `L856` | `// [UBAH_WARNA: Ikon Centang Checkbox]` | `color: isChecked ? Colors.white : Colors.transparent, // [UBAH_WARNA: Ikon Ce...` |
| 20 | `L883` | `// [UBAH_WARNA: Bottom Bar CTA Appearance Background]` | `color: const Color(0xFF16111E), // [UBAH_WARNA: Bottom Bar CTA Appearance Bac...` |
| 21 | `L908` | `// [UBAH_WARNA: Tombol Selesai Appearance - Ungu Aktif]` | `colors: [Color(0xFF7B2CBF), Color(0xFFB026FF)], // [UBAH_WARNA: Tombol Selesa...` |
| 22 | `L913` | `// [UBAH_WARNA: Tombol Selesai Appearance - Ungu Belum Selesai]` | `colors: [Color(0xFF5A1E8F), Color(0xFF7B2CBF)], // [UBAH_WARNA: Tombol Selesa...` |
| 23 | `L970` | `// [UBAH_WARNA: Teks Tombol Submit Appearance]` | `color: Colors.white, // [UBAH_WARNA: Teks Tombol Submit Appearance]` |

---

### File: `lib/screens/features/chat_ai_screen.dart` (Hunter AI Chat Assistant (Gemini 2.5 Flash))
**Total Penanda:** 25 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L712` | `// [UBAH_WARNA: Latar Belakang Layar Chat AI]` | `backgroundColor: const Color(0xFF110C19), // [UBAH_WARNA: Latar Belakang Laya...` |
| 2 | `L755` | `// [UBAH_WARNA: Header App Bar Chat AI]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Header App Bar Chat AI]` |
| 3 | `L758` | `// [UBAH_WARNA: Header App Bar Chat AI Border]` | `color: Color(0xFF2C1E4E), // [UBAH_WARNA: Header App Bar Chat AI Border]` |
| 4 | `L782` | `// [UBAH_WARNA: Tombol Kembali Chat AI]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Tombol Kembali Chat AI]` |
| 5 | `L811` | `// [UBAH_WARNA: Teks Judul Hunter Assistant]` | `color: const Color(0xFF63F7FF), // [UBAH_WARNA: Teks Judul Hunter Assistant]` |
| 6 | `L831` | `// [UBAH_WARNA: Dot Online Status Chat AI]` | `color: Color(0xFF00F4FE), // [UBAH_WARNA: Dot Online Status Chat AI]` |
| 7 | `L875` | `// [UBAH_WARNA: Tombol Konfigurasi Persona Background]` | `color: const Color(0xFF00F4FE).withValues(alpha: 0.6), // [UBAH_WARNA: Tombol...` |
| 8 | `L916` | `// [UBAH_WARNA: Chip Persona Aktif Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Chip Persona Aktif Background]` |
| 9 | `L946` | `// [UBAH_WARNA: Teks Nama Persona Aktif]` | `color: const Color(0xFF63F7FF), // [UBAH_WARNA: Teks Nama Persona Aktif]` |
| 10 | `L997` | `// [UBAH_WARNA: Avatar AI Chat Bubble]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Avatar AI Chat Bubble]` |
| 11 | `L1023` | `// [UBAH_WARNA: Background Bubble Pesan AI]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Background Bubble Pesan AI]` |
| 12 | `L1031` | `// [UBAH_WARNA: Border Bubble Pesan AI]` | `color: const Color(0xFF2C1E4E), // [UBAH_WARNA: Border Bubble Pesan AI]` |
| 13 | `L1056` | `// [UBAH_WARNA: Tag Pengirim Bubble Pesan AI]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Tag Pengirim Bubble Pesan AI]` |
| 14 | `L1155` | `// [UBAH_WARNA: Bubble Pesan User Gradien Ungu]` | `gradient: const LinearGradient( // [UBAH_WARNA: Bubble Pesan User Gradien Ungu]` |
| 15 | `L1182` | `// [UBAH_WARNA: Teks Pesan Bubble User]` | `color: Colors.white, // [UBAH_WARNA: Teks Pesan Bubble User]` |
| 16 | `L1238` | `// [UBAH_WARNA: Avatar User Chat Bubble]` | `color: const Color(0xFFB026FF), // [UBAH_WARNA: Avatar User Chat Bubble]` |
| 17 | `L1285` | `// [UBAH_WARNA: Background Block Code Chat AI]` | `color: const Color(0xFF140D28), // [UBAH_WARNA: Background Block Code Chat AI]` |
| 18 | `L1310` | `// [UBAH_WARNA: Teks Highlight Bold Pesan AI]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Teks Highlight Bold Pesan AI]` |
| 19 | `L1435` | `// [UBAH_WARNA: Container Bar Input Chat AI]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Container Bar Input Chat AI]` |
| 20 | `L1458` | `// [UBAH_WARNA: Background Box Input Chat AI]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Background Box Input Chat AI]` |
| 21 | `L1461` | `// [UBAH_WARNA: Border Box Input Chat AI]` | `color: const Color(0xFF383241), // [UBAH_WARNA: Border Box Input Chat AI]` |
| 22 | `L1490` | `// [UBAH_WARNA: Warna Teks Input Chat AI]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Warna Teks Input Chat AI]` |
| 23 | `L1497` | `// [UBAH_WARNA: Warna Hint Input Chat AI]` | `color: const Color(0xFF5D5373), // [UBAH_WARNA: Warna Hint Input Chat AI]` |
| 24 | `L1541` | `// [UBAH_WARNA: Tombol Kirim Pesan Chat AI]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Tombol Kirim Pesan Chat AI]` |
| 25 | `L1554` | `// [UBAH_WARNA: Ikon Send Pesan Chat AI]` | `color: Color(0xFF08050E), // [UBAH_WARNA: Ikon Send Pesan Chat AI]` |

---

### File: `lib/screens/features/quest_sensor.dart` (Cardio Shake Exercise (Accelerometer Sensor))
**Total Penanda:** 29 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L148` | `// [UBAH_WARNA: Intensitas Maksimal Ungu]` | `return const Color(0xFFB026FF); // [UBAH_WARNA: Intensitas Maksimal Ungu]` |
| 2 | `L151` | `// [UBAH_WARNA: Intensitas Optimal / Lengkap Cyan]` | `return const Color(0xFF00F4FE); // [UBAH_WARNA: Intensitas Optimal / Lengkap ...` |
| 3 | `L153` | `// [UBAH_WARNA: Intensitas Rendah Ungu Muda]` | `return const Color(0xFFD8B4F8); // [UBAH_WARNA: Intensitas Rendah Ungu Muda]` |
| 4 | `L155` | `// [UBAH_WARNA: Intensitas Menurun Merah Warning]` | `return const Color(0xFFFF7A85); // [UBAH_WARNA: Intensitas Menurun Merah Warn...` |
| 5 | `L158` | `// [UBAH_WARNA: Intensitas Standby Abu-abu]` | `return const Color(0xFF9B8BA1); // [UBAH_WARNA: Intensitas Standby Abu-abu]` |
| 6 | `L262` | `// [UBAH_WARNA: Latar Belakang Layar Cardio Shake]` | `backgroundColor: const Color(0xFF16111E), // [UBAH_WARNA: Latar Belakang Laya...` |
| 7 | `L384` | `// [UBAH_WARNA: Card Header Sensor Cardio Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Card Header Sensor Cardio Bac...` |
| 8 | `L414` | `// [UBAH_WARNA: Ikon Detak Jantung Header]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Ikon Detak Jantung Header]` |
| 9 | `L442` | `// [UBAH_WARNA: Judul Layar Cardio Shake]` | `color: Colors.white, // [UBAH_WARNA: Judul Layar Cardio Shake]` |
| 10 | `L455` | `// [UBAH_WARNA: Badge Sensor Live Background]` | `color: const Color(0xFF141E2D), // [UBAH_WARNA: Badge Sensor Live Background]` |
| 11 | `L477` | `// [UBAH_WARNA: Teks Sensor Live Status]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Teks Sensor Live Status]` |
| 12 | `L530` | `// [UBAH_WARNA: Card Target Shake Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Card Target Shake Background]` |
| 13 | `L533` | `// [UBAH_WARNA: Card Target Shake Border]` | `color: const Color(0xFF00F4FE).withValues(alpha: 0.3), // [UBAH_WARNA: Card T...` |
| 14 | `L568` | `// [UBAH_WARNA: Angka Hitungan Shake Utama]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Angka Hitungan Shake Utama]` |
| 15 | `L613` | `// [UBAH_WARNA: Angka Target Goal Shake]` | `color: const Color(0xFFB026FF), // [UBAH_WARNA: Angka Target Goal Shake]` |
| 16 | `L663` | `// [UBAH_WARNA: Pill Reward Gold Shake Background]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Pill Reward Gold Shake Backgr...` |
| 17 | `L691` | `// [UBAH_WARNA: Teks Nilai Gold Shake]` | `color: const Color(0xFFFFD166), // [UBAH_WARNA: Teks Nilai Gold Shake]` |
| 18 | `L782` | `// [UBAH_WARNA: Dial Lingkaran Sensor Viewfinder]` | `color: const Color(0xFF16111E), // [UBAH_WARNA: Dial Lingkaran Sensor Viewfin...` |
| 19 | `L785` | `// [UBAH_WARNA: Border Lingkaran Sensor Viewfinder]` | `color: const Color(0xFF00F4FE).withValues(alpha: 0.6), // [UBAH_WARNA: Border...` |
| 20 | `L799` | `// [UBAH_WARNA: Ikon Lari Sensor Shake]` | `color: Color(0xFF00F4FE), // [UBAH_WARNA: Ikon Lari Sensor Shake]` |
| 21 | `L816` | `// [UBAH_WARNA: Teks Repetisi Sensor Dial]` | `color: Colors.white, // [UBAH_WARNA: Teks Repetisi Sensor Dial]` |
| 22 | `L841` | `// [UBAH_WARNA: Teks Persentase Sensor Dial]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Teks Persentase Sensor Dial]` |
| 23 | `L889` | `// [UBAH_WARNA: Track Bar Progress Shake]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Track Bar Progress Shake]` |
| 24 | `L923` | `// [UBAH_WARNA: Card Telemetri Akselerometer Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Card Telemetri Akselerometer ...` |
| 25 | `L941` | `// [UBAH_WARNA: Dot Indikator Akselerometer]` | `color: Color(0xFF00F4FE), // [UBAH_WARNA: Dot Indikator Akselerometer]` |
| 26 | `L1019` | `// [UBAH_WARNA: Box Status Intensitas Shake]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Box Status Intensitas Shake]` |
| 27 | `L1084` | `// [UBAH_WARNA: Box Sync Rate Shake]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Box Sync Rate Shake]` |
| 28 | `L1153` | `// [UBAH_WARNA: Tombol Batal Sensor Background]` | `color: const Color(0xFF2D121B), // [UBAH_WARNA: Tombol Batal Sensor Background]` |
| 29 | `L1182` | `// [UBAH_WARNA: Teks Tombol Batal Sensor]` | `color: const Color(0xFFFF4D6D), // [UBAH_WARNA: Teks Tombol Batal Sensor]` |

---

### File: `lib/screens/features/study_focus_screen.dart` (Pomodoro Study Focus (Sensor Postur Belajar))
**Total Penanda:** 21 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L144` | `// [UBAH_WARNA: Latar Belakang Layar Study Focus]` | `backgroundColor: const Color(0xFF16111E), // [UBAH_WARNA: Latar Belakang Laya...` |
| 2 | `L192` | `// [UBAH_WARNA: Header Top Bar Study Focus]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Header Top Bar Study Focus]` |
| 3 | `L218` | `// [UBAH_WARNA: Tombol Kembali Study Focus]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Tombol Kembali Study Focus]` |
| 4 | `L268` | `// [UBAH_WARNA: Judul Layar Study Focus]` | `color: const Color(0xFF63F7FF), // [UBAH_WARNA: Judul Layar Study Focus]` |
| 5 | `L290` | `// [UBAH_WARNA: Tombol Ambient Sound Background]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Tombol Ambient Sound Background]` |
| 6 | `L351` | `// [UBAH_WARNA: Banner Postur Belajar Background]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Banner Postur Belajar Backgro...` |
| 7 | `L354` | `// [UBAH_WARNA: Banner Postur Belajar Border]` | `color: const Color(0xFF2C1E4E), // [UBAH_WARNA: Banner Postur Belajar Border]` |
| 8 | `L376` | `// [UBAH_WARNA: Ikon Postur Mata Header]` | `color: Color(0xFF00F4FE), // [UBAH_WARNA: Ikon Postur Mata Header]` |
| 9 | `L434` | `// [UBAH_WARNA: Lingkaran Luar Timer Pomodoro]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Lingkaran Luar Timer Pomodoro]` |
| 10 | `L482` | `// [UBAH_WARNA: Piringan Dalam Timer Pomodoro]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Piringan Dalam Timer Pomodoro]` |
| 11 | `L514` | `// [UBAH_WARNA: Teks Target Goal Pomodoro]` | `color: Color(0xFFF4D9FF), // [UBAH_WARNA: Teks Target Goal Pomodoro]` |
| 12 | `L529` | `// [UBAH_WARNA: Angka Jam Digital Pomodoro]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Angka Jam Digital Pomodoro]` |
| 13 | `L550` | `// [UBAH_WARNA: Dot Status Timer Berjalan]` | `color: isRunning ? const Color(0xFF00F4FE) : const Color(0xFFFFAA00), // [UBA...` |
| 14 | `L682` | `// [UBAH_WARNA: Card Ambient Preset Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Card Ambient Preset Background]` |
| 15 | `L748` | `// [UBAH_WARNA: Tombol Timer Pomodoro - Ungu Neon]` | `Color(0xFFB026FF), // [UBAH_WARNA: Tombol Timer Pomodoro - Ungu Neon]` |
| 16 | `L749` | `// [UBAH_WARNA: Tombol Timer Pomodoro - Ungu Gelap]` | `Color(0xFF8A00D4), // [UBAH_WARNA: Tombol Timer Pomodoro - Ungu Gelap]` |
| 17 | `L769` | `// [UBAH_WARNA: Ikon Tombol Start Timer]` | `color: Colors.white, // [UBAH_WARNA: Ikon Tombol Start Timer]` |
| 18 | `L779` | `// [UBAH_WARNA: Teks Tombol Start Timer]` | `color: Colors.white, // [UBAH_WARNA: Teks Tombol Start Timer]` |
| 19 | `L797` | `// [UBAH_WARNA: Tombol Reset Timer Background]` | `color: const Color(0xFF93000A).withValues(alpha: 0.28), // [UBAH_WARNA: Tombo...` |
| 20 | `L809` | `// [UBAH_WARNA: Ikon Tombol Reset Timer]` | `color: Color(0xFFFFB4AB), // [UBAH_WARNA: Ikon Tombol Reset Timer]` |
| 21 | `L819` | `// [UBAH_WARNA: Teks Tombol Reset Timer]` | `color: const Color(0xFFFFB4AB), // [UBAH_WARNA: Teks Tombol Reset Timer]` |

---

### File: `lib/screens/features/workout_hub_screen.dart` (Workout Hub 4 Latihan Fisik (Pose Detection Gateway))
**Total Penanda:** 28 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L434` | `// [UBAH_WARNA: Latar Belakang Layar Workout Hub]` | `backgroundColor: const Color(0xFF08050E), // [UBAH_WARNA: Latar Belakang Laya...` |
| 2 | `L501` | `// [UBAH_WARNA: Header Top Bar Workout Hub]` | `color: const Color(0xFF08050E).withValues(alpha: 0.95), // [UBAH_WARNA: Heade...` |
| 3 | `L504` | `// [UBAH_WARNA: Header Top Bar Workout Hub Border]` | `color: Color(0xFF2C1E4E), // [UBAH_WARNA: Header Top Bar Workout Hub Border]` |
| 4 | `L522` | `// [UBAH_WARNA: Tombol Kembali Workout Hub]` | `color: const Color(0xFF120D24), // [UBAH_WARNA: Tombol Kembali Workout Hub]` |
| 5 | `L572` | `// [UBAH_WARNA: Teks Status Header Workout Hub]` | `color: const Color(0xFF00E5FF), // [UBAH_WARNA: Teks Status Header Workout Hub]` |
| 6 | `L588` | `// [UBAH_WARNA: Judul Header Workout Hub]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Judul Header Workout Hub]` |
| 7 | `L659` | `// [UBAH_WARNA: Tombol Reset Workout Hub]` | `color: const Color(0xFF120D24), // [UBAH_WARNA: Tombol Reset Workout Hub]` |
| 8 | `L706` | `// [UBAH_WARNA: Card System Quest Workout Background]` | `color: const Color(0xFF120D24), // [UBAH_WARNA: Card System Quest Workout Bac...` |
| 9 | `L709` | `// [UBAH_WARNA: Card System Quest Workout Border]` | `color: const Color(0xFF2C1E4E), // [UBAH_WARNA: Card System Quest Workout Bor...` |
| 10 | `L848` | `// [UBAH_WARNA: Judul Misi Workout System]` | `color: const Color(0xFFB026FF), // [UBAH_WARNA: Judul Misi Workout System]` |
| 11 | `L911` | `// [UBAH_WARNA: Teks Reward Gold Workout]` | `color: const Color(0xFF00E5FF), // [UBAH_WARNA: Teks Reward Gold Workout]` |
| 12 | `L942` | `// [UBAH_WARNA: Teks Reward EXP Workout]` | `color: const Color(0xFF9B8BA1), // [UBAH_WARNA: Teks Reward EXP Workout]` |
| 13 | `L1030` | `// [UBAH_WARNA: Box Metrik Statistik Workout]` | `color: const Color(0xFF120D24), // [UBAH_WARNA: Box Metrik Statistik Workout]` |
| 14 | `L1062` | `// [UBAH_WARNA: Nilai Angka Metrik Workout]` | `color: Colors.white, // [UBAH_WARNA: Nilai Angka Metrik Workout]` |
| 15 | `L1091` | `// [UBAH_WARNA: Box Peringatan Penalti Workout]` | `color: const Color(0xFF120D24), // [UBAH_WARNA: Box Peringatan Penalti Workout]` |
| 16 | `L1250` | `// [UBAH_WARNA: Box Critical Penalty Notice]` | `color: const Color(0xFF120D24), // [UBAH_WARNA: Box Critical Penalty Notice]` |
| 17 | `L1386` | `// [UBAH_WARNA: Card Rutinitas Latihan Background]` | `color: const Color(0xFF120D24), // [UBAH_WARNA: Card Rutinitas Latihan Backgr...` |
| 18 | `L1389` | `// [UBAH_WARNA: Card Rutinitas Latihan Border]` | `color: const Color(0xFFB026FF).withValues(alpha: 0.4), // [UBAH_WARNA: Card R...` |
| 19 | `L1418` | `// [UBAH_WARNA: Judul Rutinitas 4 Latihan Fisik]` | `color: Colors.white, // [UBAH_WARNA: Judul Rutinitas 4 Latihan Fisik]` |
| 20 | `L1435` | `// [UBAH_WARNA: Teks Progress Rutinitas Latihan]` | `color: const Color(0xFF00E5FF), // [UBAH_WARNA: Teks Progress Rutinitas Latihan]` |
| 21 | `L1545` | `// [UBAH_WARNA: Bottom Bar Item Latihan Fisik]` | `color: const Color(0xFF08050E), // [UBAH_WARNA: Bottom Bar Item Latihan Fisik]` |
| 22 | `L1602` | `// [UBAH_WARNA: Box Counter Target Repetisi]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Box Counter Target Repetisi]` |
| 23 | `L1626` | `// [UBAH_WARNA: Tombol Buka Kamera Deteksi Pose]` | `color: const Color(0xFFB026FF), // [UBAH_WARNA: Tombol Buka Kamera Deteksi Pose]` |
| 24 | `L1696` | `// [UBAH_WARNA: Tombol Selesaikan Latihan - Ungu Gelap]` | `Color(0xFF7000A8), // [UBAH_WARNA: Tombol Selesaikan Latihan - Ungu Gelap]` |
| 25 | `L1697` | `// [UBAH_WARNA: Tombol Selesaikan Latihan - Ungu Terang]` | `Color(0xFFB026FF), // [UBAH_WARNA: Tombol Selesaikan Latihan - Ungu Terang]` |
| 26 | `L1698` | `// [UBAH_WARNA: Tombol Selesaikan Latihan - Cyan Aksen]` | `Color(0xFF00F4FE), // [UBAH_WARNA: Tombol Selesaikan Latihan - Cyan Aksen]` |
| 27 | `L1736` | `// [UBAH_WARNA: Ikon Tombol Selesaikan Latihan]` | `? Colors.white // [UBAH_WARNA: Ikon Tombol Selesaikan Latihan]` |
| 28 | `L1751` | `// [UBAH_WARNA: Teks Tombol Selesaikan Latihan]` | `? Colors.white // [UBAH_WARNA: Teks Tombol Selesaikan Latihan]` |

---

## 8. DIALOG & POPUP INTERAKTIF

### File: `lib/widgets/avatar_adjust_dialog.dart` (Dialog Pengaturan & Crop Avatar)
**Total Penanda:** 18 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L96` | `// [UBAH_WARNA: Latar Belakang Dialog Adjust Avatar]` | `backgroundColor: const Color(0xFF140D24), // [UBAH_WARNA: Latar Belakang Dial...` |
| 2 | `L100` | `// [UBAH_WARNA: Garis Border Dialog Adjust Avatar]` | `side: const BorderSide(color: Color(0xFF2C1E4E), width: 1.2), // [UBAH_WARNA:...` |
| 3 | `L113` | `// [UBAH_WARNA: Ikon Header Adjust Avatar]` | `const Icon(Icons.crop_rotate_rounded, color: Color(0xFF00F4FE), size: 18), //...` |
| 4 | `L121` | `// [UBAH_WARNA: Teks Judul Adjust Avatar]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Teks Judul Adjust Avatar]` |
| 5 | `L127` | `// [UBAH_WARNA: Ikon Close Dialog]` | `icon: const Icon(Icons.close_rounded, color: Color(0xFF9B8BA1), size: 20), //...` |
| 6 | `L139` | `// [UBAH_WARNA: Teks Deskripsi Dialog Adjust Avatar]` | `color: const Color(0xFF9B8BA1), // [UBAH_WARNA: Teks Deskripsi Dialog Adjust ...` |
| 7 | `L168` | `// [UBAH_WARNA: Latar Belakang Viewport Crop Avatar]` | `color: const Color(0xFF0A0514), // [UBAH_WARNA: Latar Belakang Viewport Crop ...` |
| 8 | `L197` | `// [UBAH_WARNA: Garis Border Viewport Crop]` | `color: const Color(0xFF00F4FE).withValues(alpha: 0.6), // [UBAH_WARNA: Garis ...` |
| 9 | `L212` | `// [UBAH_WARNA: Sudut Retikel Viewport Crop]` | `top: BorderSide(color: Color(0xFF00F4FE), width: 3), // [UBAH_WARNA: Sudut Re...` |
| 10 | `L304` | `// [UBAH_WARNA: Garis Border Tombol Batal]` | `side: const BorderSide(color: Color(0xFF383241)), // [UBAH_WARNA: Garis Borde...` |
| 11 | `L310` | `// [UBAH_WARNA: Teks Tombol Batal Crop]` | `color: const Color(0xFF9B8BA1), // [UBAH_WARNA: Teks Tombol Batal Crop]` |
| 12 | `L323` | `// [UBAH_WARNA: Tombol Terapkan & Simpan Crop Avatar]` | `backgroundColor: const Color(0xFF00F4FE), // [UBAH_WARNA: Tombol Terapkan & S...` |
| 13 | `L327` | `// [UBAH_WARNA: Bayangan Tombol Terapkan Crop]` | `shadowColor: const Color(0xFF00F4FE).withValues(alpha: 0.5), // [UBAH_WARNA: ...` |
| 14 | `L338` | `// [UBAH_WARNA: Teks Tombol Terapkan Crop Avatar]` | `color: Colors.black, // [UBAH_WARNA: Teks Tombol Terapkan Crop Avatar]` |
| 15 | `L365` | `// [UBAH_WARNA: Latar Belakang Tool Button Crop]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Latar Belakang Tool Button Crop]` |
| 16 | `L367` | `// [UBAH_WARNA: Border Tool Button Crop]` | `border: Border.all(color: const Color(0xFF383241), width: 0.8), // [UBAH_WARN...` |
| 17 | `L372` | `// [UBAH_WARNA: Ikon Tool Button Crop]` | `Icon(icon, size: 15, color: const Color(0xFF00F4FE)), // [UBAH_WARNA: Ikon To...` |
| 18 | `L379` | `// [UBAH_WARNA: Teks Tool Button Crop]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Teks Tool Button Crop]` |

---

### File: `lib/widgets/face_scan_dialog.dart` (Dialog Biometrik Face Recognition Scanner)
**Total Penanda:** 25 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L331` | `// [UBAH_WARNA: Face Scan Status Sukses / Cocok]` | `return const Color(0xFF00FFA3); // [UBAH_WARNA: Face Scan Status Sukses / Cocok]` |
| 2 | `L333` | `// [UBAH_WARNA: Face Scan Status Gagal / Ditolak]` | `return const Color(0xFFFF0055); // [UBAH_WARNA: Face Scan Status Gagal / Dito...` |
| 3 | `L335` | `// [UBAH_WARNA: Face Scan Status Memproses]` | `return const Color(0xFFB026FF); // [UBAH_WARNA: Face Scan Status Memproses]` |
| 4 | `L337` | `// [UBAH_WARNA: Face Scan Status Error]` | `return const Color(0xFFFF5252); // [UBAH_WARNA: Face Scan Status Error]` |
| 5 | `L340` | `// [UBAH_WARNA: Face Scan Retikel Scanning Cyan]` | `return const Color(0xFF00F4FE); // [UBAH_WARNA: Face Scan Retikel Scanning Cyan]` |
| 6 | `L366` | `// [UBAH_WARNA: Latar Belakang Dialog Face Scan]` | `color: const Color(0xFF140D24), // [UBAH_WARNA: Latar Belakang Dialog Face Scan]` |
| 7 | `L369` | `// [UBAH_WARNA: Garis Border Dialog Face Scan]` | `color: currentAccent.withValues(alpha: 0.7), // [UBAH_WARNA: Garis Border Dia...` |
| 8 | `L427` | `// [UBAH_WARNA: Badge Mode Kamera Face Scan]` | `color: const Color(0xFF231D2B), // [UBAH_WARNA: Badge Mode Kamera Face Scan]` |
| 9 | `L461` | `// [UBAH_WARNA: Latar Belakang Viewfinder Kamera]` | `color: const Color(0xFF0A0612), // [UBAH_WARNA: Latar Belakang Viewfinder Kam...` |
| 10 | `L475` | `// [UBAH_WARNA: Ikon Kamera Error Face Scan]` | `size: 48, color: Color(0xFFFF5252)) // [UBAH_WARNA: Ikon Kamera Error Face Scan]` |
| 11 | `L619` | `// [UBAH_WARNA: Overlay Sukses Wajah Cocok]` | `color: const Color(0xFF00FFA3).withValues(alpha: 0.25), // [UBAH_WARNA: Overl...` |
| 12 | `L626` | `// [UBAH_WARNA: Ikon Centang Sukses Verifikasi Wajah]` | `color: Color(0xFF00FFA3), // [UBAH_WARNA: Ikon Centang Sukses Verifikasi Wajah]` |
| 13 | `L636` | `// [UBAH_WARNA: Overlay Gagal Wajah Ditolak]` | `color: const Color(0xFFFF0055).withValues(alpha: 0.3), // [UBAH_WARNA: Overla...` |
| 14 | `L643` | `// [UBAH_WARNA: Ikon Silang Gagal Verifikasi Wajah]` | `color: Color(0xFFFF0055), // [UBAH_WARNA: Ikon Silang Gagal Verifikasi Wajah]` |
| 15 | `L684` | `// [UBAH_WARNA: Kotak Peringatan Wajah Tidak Cocok]` | `color: const Color(0xFF280B15), // [UBAH_WARNA: Kotak Peringatan Wajah Tidak ...` |
| 16 | `L687` | `// [UBAH_WARNA: Border Peringatan Wajah Tidak Cocok]` | `color: const Color(0xFFFF0055).withValues(alpha: 0.5)), // [UBAH_WARNA: Borde...` |
| 17 | `L694` | `// [UBAH_WARNA: Teks Peringatan Wajah Tidak Cocok]` | `color: const Color(0xFFFFB4AB), // [UBAH_WARNA: Teks Peringatan Wajah Tidak C...` |
| 18 | `L711` | `// [UBAH_WARNA: Garis Border Tombol Batal Face Scan]` | `side: const BorderSide(color: Color(0xFF383241)), // [UBAH_WARNA: Garis Borde...` |
| 19 | `L722` | `// [UBAH_WARNA: Teks Tombol Batal Face Scan]` | `color: const Color(0xFF9B8BA1), // [UBAH_WARNA: Teks Tombol Batal Face Scan]` |
| 20 | `L731` | `// [UBAH_WARNA: Tombol Tindakan Utama Face Scan (Pindai Ulang)]` | `backgroundColor: currentAccent, // [UBAH_WARNA: Tombol Tindakan Utama Face Sc...` |
| 21 | `L732` | `// [UBAH_WARNA: Teks Tombol Tindakan Face Scan]` | `foregroundColor: Colors.black, // [UBAH_WARNA: Teks Tombol Tindakan Face Scan]` |
| 22 | `L757` | `// [UBAH_WARNA: Garis Border Tombol Batalkan Face Scan]` | `side: const BorderSide(color: Color(0xFF383241)), // [UBAH_WARNA: Garis Borde...` |
| 23 | `L768` | `// [UBAH_WARNA: Teks Tombol Batalkan Face Scan]` | `color: const Color(0xFF9B8BA1), // [UBAH_WARNA: Teks Tombol Batalkan Face Scan]` |
| 24 | `L778` | `// [UBAH_WARNA: Tombol Rekam Wajah / Pindai Sekarang]` | `backgroundColor: currentAccent, // [UBAH_WARNA: Tombol Rekam Wajah / Pindai S...` |
| 25 | `L779` | `// [UBAH_WARNA: Teks Tombol Rekam Wajah]` | `foregroundColor: Colors.black, // [UBAH_WARNA: Teks Tombol Rekam Wajah]` |

---

## 9. CHEAT-SHEET SKENARIO TANTANGAN PENGUJI

| Jika Penguji Meminta... | Buka File | Cari Tag (`Ctrl + F`) | Ganti Menjadi Contoh |
|:---|:---|:---|:---|
| Ubah Warna Background Dashboard Tab Home | `tab_home.dart` | `[UBAH_WARNA: Latar Belakang Layar Dashboard Tab Home]` | `Colors.black` / `Color(0xFF0A0F1D)` |
| Ubah Warna Kartu Hunter Matrix di Home | `tab_home.dart` | `[UBAH_WARNA: Card Hunter Matrix Background]` | `Colors.blueGrey.shade900` |
| Ubah Warna HP Heart Player | `tab_home.dart` | `[UBAH_WARNA: Ikon HP Heart Hunter]` | `Colors.purpleAccent` |
| Ubah Warna Background Bottom Navigation Bar | `main_navigation.dart` | `[UBAH_WARNA: Nav - Background Bar]` | `Colors.deepPurple.shade900` |
| Ubah Warna Ikon Tab Aktif di Navigasi | `main_navigation.dart` | `[UBAH_WARNA: Nav - Ikon Tab Aktif]` | `Colors.amber` |
| Ubah Warna Tombol Login Awaken | `login_screen.dart` | `[UBAH_WARNA: Tombol Login Awaken` | `Colors.cyan` / `Colors.teal` |
| Ubah Warna Input Username & Password | `login_screen.dart` | `[UBAH_WARNA: Background Input Username]` | `Color(0xFF221133)` |
| Ubah Warna Bola Mana Core Mini Game | `tab_game.dart` | `[UBAH_WARNA: Bola Mana Core Glow Cyan]` | `Colors.redAccent` |
| Ubah Warna Radar Sweep Peta LBS | `tab_map.dart` | `[UBAH_WARNA: Ring Radar Peta]` | `Colors.greenAccent` |
| Ubah Warna Tombol Klaim Hadiah Peta | `tab_map.dart` | `[UBAH_WARNA: Tombol Klaim Mystery Gift` | `Colors.orange` |
| Ubah Warna Timer Pomodoro Belajar | `study_focus_screen.dart` | `[UBAH_WARNA: Tombol Timer Pomodoro` | `Colors.green` |
| Ubah Warna Bubble Chat AI | `chat_ai_screen.dart` | `[UBAH_WARNA: Background Bubble Pesan AI]` | `Color(0xFF0F2B38)` |
| Ubah Warna Tombol Kirim Chat AI | `chat_ai_screen.dart` | `[UBAH_WARNA: Tombol Kirim Pesan Chat AI]` | `Colors.purpleAccent` |
| Ubah Warna Tombol Logout di Profil | `tab_profile.dart` | `[UBAH_WARNA: Tombol Logout Background]` | `Colors.red` |
| Ubah Warna Tombol Selesai Latihan Workout | `workout_hub_screen.dart` | `[UBAH_WARNA: Tombol Selesaikan Latihan` | `Colors.deepOrange` |

> **CATATAN PENTING:** Selalu simpan file (`Ctrl + S`) dan tekan **`r`** di terminal yang menjalankan Flutter untuk langsung melihat efeknya di layar perangkat secara instan!