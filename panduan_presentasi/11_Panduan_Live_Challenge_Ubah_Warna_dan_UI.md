# PANDUAN LIVE CHALLENGE: UBAH WARNA & KOMPONEN UI LEVMAX
**Dokumen:** `11_Panduan_Live_Challenge_Ubah_Warna_dan_UI.md`  
**Tujuan:** Panduan taktis dan cepat saat sesi live challenge presentasi/UAS jika dosen penguji meminta perubahan warna (AppBar, Background Scaffold, Tombol Utama, Teks Judul, Card, Dialog, atau Icon) secara langsung.  
**Total Penanda:** 527 penanda `// [UBAH_WARNA: ...]` di 18 file UI aplikasi.

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

## 4. DAFTAR LENGKAP LOKASI UBAH WARNA PER FILE UI (SCREEN & WIDGET)

### File: `lib/main.dart` (Theme Root / MaterialApp Configuration)
**Total Penanda:** 2 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L49` | `// [UBAH_WARNA: Konfigurasi Tema Utama Aplikasi]` | `AppTheme.darkTheme, // [UBAH_WARNA: Konfigurasi Tema Utama Aplikasi]` |
| 2 | `L50` | `// [UBAH_WARNA: Mode Tema Global (Dark Mode)]` | `themeMode: ThemeMode.dark, // [UBAH_WARNA: Mode Tema Global (Dark Mode)]` |
---

### File: `lib/screens/splash_screen.dart` (Splash Screen & System Booting)
**Total Penanda:** 22 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L33` | `// [UBAH_WARNA: Indikator Status RPC Splash]` | `); // [UBAH_WARNA: Indikator Status RPC Splash]` |
| 2 | `L119` | `// [UBAH_WARNA: Latar Belakang Layar Splash]` | `), // [UBAH_WARNA: Latar Belakang Layar Splash]` |
| 3 | `L129` | `// [UBAH_WARNA: Aura Ungu Inti Reaktor Splash]` | `Color(0xFF2B1148), // [UBAH_WARNA: Aura Ungu Inti Reaktor Splash]` |
| 4 | `L179` | `// [UBAH_WARNA: Kartu Bar Atas Splash]` | `.withValues(alpha: 0.85), // [UBAH_WARNA: Kartu Bar Atas Splash]` |
| 5 | `L184` | `// [UBAH_WARNA: Border Kartu Bar Atas Splash]` | `), // [UBAH_WARNA: Border Kartu Bar Atas Splash]` |
| 6 | `L208` | `// [UBAH_WARNA: Titik Status Dot Bar Atas Splash]` | `), // [UBAH_WARNA: Titik Status Dot Bar Atas Splash]` |
| 7 | `L227` | `// [UBAH_WARNA: Teks Label Bar Atas Splash]` | `), // [UBAH_WARNA: Teks Label Bar Atas Splash]` |
| 8 | `L316` | `// [UBAH_WARNA: Teks Header Status Sinkronisasi]` | `), // [UBAH_WARNA: Teks Header Status Sinkronisasi]` |
| 9 | `L358` | `// [UBAH_WARNA: Teks Judul Status Sinkronisasi Splash]` | `), // [UBAH_WARNA: Teks Judul Status Sinkronisasi Splash]` |
| 10 | `L375` | `// [UBAH_WARNA: Teks Subjudul Status Sinkronisasi Splash]` | `), // [UBAH_WARNA: Teks Subjudul Status Sinkronisasi Splash]` |
| 11 | `L397` | `// [UBAH_WARNA: Latar Belakang Progress Bar]` | `), // [UBAH_WARNA: Latar Belakang Progress Bar]` |
| 12 | `L402` | `// [UBAH_WARNA: Garis Border Progress Bar]` | `), // [UBAH_WARNA: Garis Border Progress Bar]` |
| 13 | `L416` | `// [UBAH_WARNA: Gradien Progress Bar Ungu]` | `), // [UBAH_WARNA: Gradien Progress Bar Ungu]` |
| 14 | `L419` | `// [UBAH_WARNA: Gradien Progress Bar Cyan]` | `), // [UBAH_WARNA: Gradien Progress Bar Cyan]` |
| 15 | `L427` | `// [UBAH_WARNA: Cahaya Glow Progress Bar]` | `), // [UBAH_WARNA: Cahaya Glow Progress Bar]` |
| 16 | `L447` | `// [UBAH_WARNA: Teks Persentase Progress Bar]` | `), // [UBAH_WARNA: Teks Persentase Progress Bar]` |
| 17 | `L624` | `// [UBAH_WARNA: Kotak Status Konsol Bawah Splash]` | `), // [UBAH_WARNA: Kotak Status Konsol Bawah Splash]` |
| 18 | `L629` | `// [UBAH_WARNA: Border Konsol Bawah Splash]` | `), // [UBAH_WARNA: Border Konsol Bawah Splash]` |
| 19 | `L653` | `// [UBAH_WARNA: Titik Status Dot Konsol Bawah]` | `), // [UBAH_WARNA: Titik Status Dot Konsol Bawah]` |
| 20 | `L671` | `// [UBAH_WARNA: Teks Label Konsol Bawah]` | `), // [UBAH_WARNA: Teks Label Konsol Bawah]` |
| 21 | `L691` | `// [UBAH_WARNA: Status Sensor Biometrik Hijau]` | `), // [UBAH_WARNA: Status Sensor Biometrik Hijau]` |
| 22 | `L716` | `// [UBAH_WARNA: Teks Versi Footer Splash]` | `), // [UBAH_WARNA: Teks Versi Footer Splash]` |
---

### File: `lib/screens/auth/login_screen.dart` (Login Hunter (Password & Biometrics))
**Total Penanda:** 38 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L345` | `// [UBAH_WARNA: Latar Belakang Layar Login]` | `), // [UBAH_WARNA: Latar Belakang Layar Login]` |
| 2 | `L421` | `// [UBAH_WARNA: Header System Window Card]` | `), // [UBAH_WARNA: Header System Window Card]` |
| 3 | `L434` | `// [UBAH_WARNA: Dot Status System Window]` | `), // [UBAH_WARNA: Dot Status System Window]` |
| 4 | `L453` | `// [UBAH_WARNA: Teks Title System Window]` | `), // [UBAH_WARNA: Teks Title System Window]` |
| 5 | `L469` | `// [UBAH_WARNA: Judul Utama LEVMAX]` | `), // [UBAH_WARNA: Judul Utama LEVMAX]` |
| 6 | `L480` | `// [UBAH_WARNA: Teks Subtitle Login]` | `), // [UBAH_WARNA: Teks Subtitle Login]` |
| 7 | `L581` | `// [UBAH_WARNA: Background Card Form Login]` | `), // [UBAH_WARNA: Background Card Form Login]` |
| 8 | `L650` | `// [UBAH_WARNA: Label Input Username]` | `color: const Color(0xFFE5B5FF), // [UBAH_WARNA: Label Input Username]` |
| 9 | `L662` | `// [UBAH_WARNA: Background Input Username]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Background Input Username]` |
| 10 | `L670` | `// [UBAH_WARNA: Warna Teks Input Username]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Warna Teks Input Username]` |
| 11 | `L680` | `// [UBAH_WARNA: Hint Input Username]` | `.withValues(alpha: 0.40), // [UBAH_WARNA: Hint Input Username]` |
| 12 | `L685` | `// [UBAH_WARNA: Ikon Input Username]` | `color: Color(0xFF9B8BA1), // [UBAH_WARNA: Ikon Input Username]` |
| 13 | `L732` | `// [UBAH_WARNA: Box Security Cipher]` | `color: const Color(0xFF2D2736), // [UBAH_WARNA: Box Security Cipher]` |
| 14 | `L745` | `// [UBAH_WARNA: Dot Status SHA-256]` | `color: Color(0xFF00F4FE), // [UBAH_WARNA: Dot Status SHA-256]` |
| 15 | `L759` | `// [UBAH_WARNA: Teks Hash SHA-256]` | `), // [UBAH_WARNA: Teks Hash SHA-256]` |
| 16 | `L774` | `// [UBAH_WARNA: Background Input Password]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Background Input Password]` |
| 17 | `L783` | `// [UBAH_WARNA: Warna Teks Input Password]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Warna Teks Input Password]` |
| 18 | `L797` | `// [UBAH_WARNA: Hint Input Password]` | `.withValues(alpha: 0.40), // [UBAH_WARNA: Hint Input Password]` |
| 19 | `L803` | `// [UBAH_WARNA: Ikon Input Password]` | `color: Color(0xFF9B8BA1), // [UBAH_WARNA: Ikon Input Password]` |
| 20 | `L817` | `// [UBAH_WARNA: Ikon Mata Password]` | `color: const Color(0xFF9B8BA1), // [UBAH_WARNA: Ikon Mata Password]` |
| 21 | `L853` | `// [UBAH_WARNA: Kotak Checkbox Stay Synchronized]` | `_staySynchronized // [UBAH_WARNA: Kotak Checkbox Stay Synchronized]` |
| 22 | `L881` | `// [UBAH_WARNA: Label Stay Synchronized]` | `), // [UBAH_WARNA: Label Stay Synchronized]` |
| 23 | `L906` | `// [UBAH_WARNA: Link Forgot Password]` | `color: const Color(0xFFDCB8FC), // [UBAH_WARNA: Link Forgot Password]` |
| 24 | `L925` | `// [UBAH_WARNA: Tombol Login Awaken - Gradien Ungu Gelap]` | `Color(0xFF7B2CBF), // [UBAH_WARNA: Tombol Login Awaken - Gradien Ungu Gelap]` |
| 25 | `L926` | `// [UBAH_WARNA: Tombol Login Awaken - Gradien Ungu Sedang]` | `Color(0xFF9D4EDD), // [UBAH_WARNA: Tombol Login Awaken - Gradien Ungu Sedang]` |
| 26 | `L927` | `// [UBAH_WARNA: Tombol Login Awaken - Gradien Ungu Terang]` | `Color(0xFFB026FF), // [UBAH_WARNA: Tombol Login Awaken - Gradien Ungu Terang]` |
| 27 | `L935` | `// [UBAH_WARNA: Glow Tombol Awaken]` | `.withValues(alpha: 0.45), // [UBAH_WARNA: Glow Tombol Awaken]` |
| 28 | `L970` | `// [UBAH_WARNA: Ikon Tombol Login Awaken]` | `), // [UBAH_WARNA: Ikon Tombol Login Awaken]` |
| 29 | `L989` | `// [UBAH_WARNA: Teks Tombol Login Awaken]` | `), // [UBAH_WARNA: Teks Tombol Login Awaken]` |
| 30 | `L1007` | `// [UBAH_WARNA: Garis Pemisah Divider Kiri]` | `color: const Color(0xFF383241), // [UBAH_WARNA: Garis Pemisah Divider Kiri]` |
| 31 | `L1010` | `// [UBAH_WARNA: Garis Pemisah Divider Kanan]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Garis Pemisah Divider Kanan]` |
| 32 | `L1021` | `// [UBAH_WARNA: Teks Pemisah Biometric]` | `color: const Color(0xFF9B8BA1), // [UBAH_WARNA: Teks Pemisah Biometric]` |
| 33 | `L1102` | `// [UBAH_WARNA: Teks Belum Punya Akun]` | `color: const Color(0xFFD2C1D7), // [UBAH_WARNA: Teks Belum Punya Akun]` |
| 34 | `L1110` | `// [UBAH_WARNA: Link Register Awakened]` | `color: const Color(0xFFE5B5FF), // [UBAH_WARNA: Link Register Awakened]` |
| 35 | `L1176` | `// [UBAH_WARNA: Pod Biometrik Outer]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Pod Biometrik Outer]` |
| 36 | `L1195` | `// [UBAH_WARNA: Pod Biometrik Inner]` | `), // [UBAH_WARNA: Pod Biometrik Inner]` |
| 37 | `L1215` | `// [UBAH_WARNA: Judul Pod Biometrik]` | `), // [UBAH_WARNA: Judul Pod Biometrik]` |
| 38 | `L1225` | `// [UBAH_WARNA: Subtitle Pod Biometrik]` | `), // [UBAH_WARNA: Subtitle Pod Biometrik]` |
---

### File: `lib/screens/auth/register_screen.dart` (Registrasi Hunter Baru & Avatar Upload)
**Total Penanda:** 29 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L178` | `// [UBAH_WARNA: Latar Belakang Layar Register]` | `), // [UBAH_WARNA: Latar Belakang Layar Register]` |
| 2 | `L271` | `// [UBAH_WARNA: Tombol Kembali Background]` | `), // [UBAH_WARNA: Tombol Kembali Background]` |
| 3 | `L277` | `// [UBAH_WARNA: Tombol Kembali Icon]` | `color: Color(0xFFE5B5FF), // [UBAH_WARNA: Tombol Kembali Icon]` |
| 4 | `L290` | `// [UBAH_WARNA: Protocol Header Background]` | `), // [UBAH_WARNA: Protocol Header Background]` |
| 5 | `L303` | `// [UBAH_WARNA: Protocol Header Status Dot]` | `), // [UBAH_WARNA: Protocol Header Status Dot]` |
| 6 | `L322` | `// [UBAH_WARNA: Protocol Header Title]` | `), // [UBAH_WARNA: Protocol Header Title]` |
| 7 | `L376` | `// [UBAH_WARNA: Avatar Circle Background]` | `), // [UBAH_WARNA: Avatar Circle Background]` |
| 8 | `L380` | `// [UBAH_WARNA: Avatar Circle Border]` | `), // [UBAH_WARNA: Avatar Circle Border]` |
| 9 | `L419` | `// [UBAH_WARNA: Badge Kamera Background]` | `), // [UBAH_WARNA: Badge Kamera Background]` |
| 10 | `L435` | `// [UBAH_WARNA: Badge Kamera Icon]` | `color: Colors.white, // [UBAH_WARNA: Badge Kamera Icon]` |
| 11 | `L454` | `// [UBAH_WARNA: Judul Awaken New Hunter]` | `), // [UBAH_WARNA: Judul Awaken New Hunter]` |
| 12 | `L469` | `// [UBAH_WARNA: Subtitle System Init]` | `), // [UBAH_WARNA: Subtitle System Init]` |
| 13 | `L484` | `// [UBAH_WARNA: Teks Instruksi Registrasi]` | `), // [UBAH_WARNA: Teks Instruksi Registrasi]` |
| 14 | `L508` | `// [UBAH_WARNA: Background Form Card]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Background Form Card]` |
| 15 | `L511` | `// [UBAH_WARNA: Border Form Card]` | `color: const Color(0xFF383241), // [UBAH_WARNA: Border Form Card]` |
| 16 | `L614` | `// [UBAH_WARNA: Tombol Register - Gradien Ungu]` | `], // [UBAH_WARNA: Tombol Register - Gradien Ungu]` |
| 17 | `L622` | `// [UBAH_WARNA: Glow Tombol Register]` | `), // [UBAH_WARNA: Glow Tombol Register]` |
| 18 | `L658` | `// [UBAH_WARNA: Teks Tombol Register]` | `color: Colors.white, // [UBAH_WARNA: Teks Tombol Register]` |
| 19 | `L734` | `// [UBAH_WARNA: Background Input Field]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Background Input Field]` |
| 20 | `L737` | `// [UBAH_WARNA: Border Input Field]` | `color: const Color(0xFF383241), // [UBAH_WARNA: Border Input Field]` |
| 21 | `L748` | `// [UBAH_WARNA: Warna Teks Input Field]` | `), // [UBAH_WARNA: Warna Teks Input Field]` |
| 22 | `L760` | `// [UBAH_WARNA: Hint Input Field]` | `color: const Color(0xFF6E6078), // [UBAH_WARNA: Hint Input Field]` |
| 23 | `L771` | `// [UBAH_WARNA: Icon Prefix Input Field]` | `), // [UBAH_WARNA: Icon Prefix Input Field]` |
| 24 | `L792` | `// [UBAH_WARNA: Container Biometrik]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Container Biometrik]` |
| 25 | `L813` | `// [UBAH_WARNA: Ikon Face Biometrik]` | `color: Color(0xFFB026FF), // [UBAH_WARNA: Ikon Face Biometrik]` |
| 26 | `L835` | `// [UBAH_WARNA: Judul Biometrik Enroll]` | `), // [UBAH_WARNA: Judul Biometrik Enroll]` |
| 27 | `L847` | `// [UBAH_WARNA: Subtitle Biometrik Enroll]` | `), // [UBAH_WARNA: Subtitle Biometrik Enroll]` |
| 28 | `L878` | `// [UBAH_WARNA: Teks Already Awakened]` | `), // [UBAH_WARNA: Teks Already Awakened]` |
| 29 | `L893` | `// [UBAH_WARNA: Link Login Screen]` | `), // [UBAH_WARNA: Link Login Screen]` |
---

### File: `lib/screens/main_navigation.dart` (Bottom Navigation Bar Utama)
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

### File: `lib/screens/tabs/tab_home.dart` (Tab 1: Quests & Daily Status HUD)
**Total Penanda:** 53 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L549` | `// [UBAH_WARNA: Latar Belakang Layar Dashboard Tab Home]` | `), // [UBAH_WARNA: Latar Belakang Layar Dashboard Tab Home]` |
| 2 | `L619` | `// [UBAH_WARNA: Banner Awakening Header Background]` | `), // [UBAH_WARNA: Banner Awakening Header Background]` |
| 3 | `L624` | `// [UBAH_WARNA: Banner Awakening Header Border]` | `), // [UBAH_WARNA: Banner Awakening Header Border]` |
| 4 | `L641` | `// [UBAH_WARNA: Dot Status Sistem Header]` | `), // [UBAH_WARNA: Dot Status Sistem Header]` |
| 5 | `L664` | `// [UBAH_WARNA: Teks Tag Hunter Header]` | `), // [UBAH_WARNA: Teks Tag Hunter Header]` |
| 6 | `L673` | `// [UBAH_WARNA: Teks Greeting Hunter]` | `), // [UBAH_WARNA: Teks Greeting Hunter]` |
| 7 | `L696` | `// [UBAH_WARNA: Card Hunter Matrix Background]` | `), // [UBAH_WARNA: Card Hunter Matrix Background]` |
| 8 | `L701` | `// [UBAH_WARNA: Card Hunter Matrix Border]` | `), // [UBAH_WARNA: Card Hunter Matrix Border]` |
| 9 | `L729` | `// [UBAH_WARNA: Avatar Frame Background]` | `), // [UBAH_WARNA: Avatar Frame Background]` |
| 10 | `L734` | `// [UBAH_WARNA: Avatar Frame Border]` | `), // [UBAH_WARNA: Avatar Frame Border]` |
| 11 | `L768` | `// [UBAH_WARNA: Tombol Edit Avatar Background]` | `), // [UBAH_WARNA: Tombol Edit Avatar Background]` |
| 12 | `L782` | `// [UBAH_WARNA: Tombol Edit Avatar Icon]` | `.black, // [UBAH_WARNA: Tombol Edit Avatar Icon]` |
| 13 | `L809` | `// [UBAH_WARNA: Teks Nama Hunter]` | `), // [UBAH_WARNA: Teks Nama Hunter]` |
| 14 | `L819` | `// [UBAH_WARNA: Ikon Verified Hunter]` | `), // [UBAH_WARNA: Ikon Verified Hunter]` |
| 15 | `L832` | `// [UBAH_WARNA: Teks Subtitle Rank Hunter]` | `), // [UBAH_WARNA: Teks Subtitle Rank Hunter]` |
| 16 | `L848` | `// [UBAH_WARNA: Badge Rank Hunter Background]` | `), // [UBAH_WARNA: Badge Rank Hunter Background]` |
| 17 | `L853` | `// [UBAH_WARNA: Badge Rank Hunter Border]` | `), // [UBAH_WARNA: Badge Rank Hunter Border]` |
| 18 | `L871` | `// [UBAH_WARNA: Ikon Badge Rank Hunter]` | `), // [UBAH_WARNA: Ikon Badge Rank Hunter]` |
| 19 | `L882` | `// [UBAH_WARNA: Teks Badge Rank Hunter]` | `), // [UBAH_WARNA: Teks Badge Rank Hunter]` |
| 20 | `L918` | `// [UBAH_WARNA: Ikon HP Heart Hunter]` | `), // [UBAH_WARNA: Ikon HP Heart Hunter]` |
| 21 | `L943` | `// [UBAH_WARNA: Pill Gold Hunter Background]` | `), // [UBAH_WARNA: Pill Gold Hunter Background]` |
| 22 | `L948` | `// [UBAH_WARNA: Pill Gold Hunter Border]` | `), // [UBAH_WARNA: Pill Gold Hunter Border]` |
| 23 | `L960` | `// [UBAH_WARNA: Ikon Pill Gold Hunter]` | `), // [UBAH_WARNA: Ikon Pill Gold Hunter]` |
| 24 | `L979` | `// [UBAH_WARNA: Teks Jumlah Gold Hunter]` | `), // [UBAH_WARNA: Teks Jumlah Gold Hunter]` |
| 25 | `L1024` | `// [UBAH_WARNA: Track EXP Bar Hunter]` | `), // [UBAH_WARNA: Track EXP Bar Hunter]` |
| 26 | `L1040` | `// [UBAH_WARNA: Glow Fill EXP Bar Hunter]` | `), // [UBAH_WARNA: Glow Fill EXP Bar Hunter]` |
| 27 | `L1062` | `// [UBAH_WARNA: Banner Server Time Background]` | `), // [UBAH_WARNA: Banner Server Time Background]` |
| 28 | `L1067` | `// [UBAH_WARNA: Banner Server Time Border]` | `), // [UBAH_WARNA: Banner Server Time Border]` |
| 29 | `L1079` | `// [UBAH_WARNA: Ikon Dunia Server Time]` | `color: Color(0xFF00F4FE), // [UBAH_WARNA: Ikon Dunia Server Time]` |
| 30 | `L1164` | `// [UBAH_WARNA: Teks Jam London Server Time]` | `), // [UBAH_WARNA: Teks Jam London Server Time]` |
| 31 | `L1185` | `// [UBAH_WARNA: Latar Belakang Kolom Pencarian Quest]` | `), // [UBAH_WARNA: Latar Belakang Kolom Pencarian Quest]` |
| 32 | `L1190` | `// [UBAH_WARNA: Garis Border Kolom Pencarian Quest]` | `), // [UBAH_WARNA: Garis Border Kolom Pencarian Quest]` |
| 33 | `L1201` | `// [UBAH_WARNA: Warna Teks Input Cari Quest]` | `), // [UBAH_WARNA: Warna Teks Input Cari Quest]` |
| 34 | `L1211` | `// [UBAH_WARNA: Warna Hint Cari Quest]` | `), // [UBAH_WARNA: Warna Hint Cari Quest]` |
| 35 | `L1215` | `// [UBAH_WARNA: Ikon Search Quest]` | `color: Color(0xFF8B829E), // [UBAH_WARNA: Ikon Search Quest]` |
| 36 | `L1260` | `// [UBAH_WARNA: Background Filter Chip Quest]` | `), // [UBAH_WARNA: Background Filter Chip Quest]` |
| 37 | `L1317` | `// [UBAH_WARNA: Ikon Api Daily Quests Header]` | `), // [UBAH_WARNA: Ikon Api Daily Quests Header]` |
| 38 | `L1330` | `// [UBAH_WARNA: Judul Daily Quests Header]` | `), // [UBAH_WARNA: Judul Daily Quests Header]` |
| 39 | `L1605` | `// [UBAH_WARNA: Background Card Quest]` | `), // [UBAH_WARNA: Background Card Quest]` |
| 40 | `L1612` | `// [UBAH_WARNA: Border Card Quest]` | `), // [UBAH_WARNA: Border Card Quest]` |
| 41 | `L1669` | `// [UBAH_WARNA: Judul Card Quest]` | `), // [UBAH_WARNA: Judul Card Quest]` |
| 42 | `L1849` | `// [UBAH_WARNA: Border Tombol Scan Hidden Dungeon]` | `), // [UBAH_WARNA: Border Tombol Scan Hidden Dungeon]` |
| 43 | `L1896` | `// [UBAH_WARNA: Ikon Tombol Scan Hidden Dungeon]` | `.white, // [UBAH_WARNA: Ikon Tombol Scan Hidden Dungeon]` |
| 44 | `L1915` | `// [UBAH_WARNA: Judul Tombol Scan Hidden Dungeon]` | `color: const Color(0xFFFF2A6D), // [UBAH_WARNA: Judul Tombol Scan Hidden Dung...` |
| 45 | `L2465` | `// [UBAH_WARNA: Background Card Nearby Gate]` | `), // [UBAH_WARNA: Background Card Nearby Gate]` |
| 46 | `L2470` | `// [UBAH_WARNA: Border Card Nearby Gate]` | `), // [UBAH_WARNA: Border Card Nearby Gate]` |
| 47 | `L2487` | `// [UBAH_WARNA: Ikon Radar Nearby Gate]` | `), // [UBAH_WARNA: Ikon Radar Nearby Gate]` |
| 48 | `L2528` | `// [UBAH_WARNA: Tombol Enter Gate Background]` | `), // [UBAH_WARNA: Tombol Enter Gate Background]` |
| 49 | `L2545` | `// [UBAH_WARNA: Tombol Enter Gate Icon]` | `color: Colors.black, // [UBAH_WARNA: Tombol Enter Gate Icon]` |
| 50 | `L2555` | `// [UBAH_WARNA: Tombol Enter Gate Teks]` | `Colors.black, // [UBAH_WARNA: Tombol Enter Gate Teks]` |
| 51 | `L2578` | `// [UBAH_WARNA: FAB Tombol Alarm Background]` | `), // [UBAH_WARNA: FAB Tombol Alarm Background]` |
| 52 | `L4639` | `// [UBAH_WARNA: FAB Hunter AI Brain Background]` | `), // [UBAH_WARNA: FAB Hunter AI Brain Background]` |
| 53 | `L4652` | `// [UBAH_WARNA: FAB Hunter AI Brain Icon]` | `color: Colors.white, // [UBAH_WARNA: FAB Hunter AI Brain Icon]` |
---

### File: `lib/screens/tabs/tab_map.dart` (Tab 2: Dungeon Radar & Mystery Gate (LBS))
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
| 15 | `L1425` | `// [UBAH_WARNA: Pill Jarak Gate Background]` | `color: const Color(0xFF2D2736).withValues(alpha: 0.9), // [UBAH_WARNA: Pill J...` |
| 16 | `L1443` | `// [UBAH_WARNA: Teks Jarak Gate Peta]` | `color: const Color(0xFFFF4D4D), // [UBAH_WARNA: Teks Jarak Gate Peta]` |
| 17 | `L1615` | `// [UBAH_WARNA: FAB Recenter GPS Background]` | `color: const Color(0xFF110C19).withValues(alpha: 0.92), // [UBAH_WARNA: FAB R...` |
| 18 | `L1617` | `// [UBAH_WARNA: FAB Recenter GPS Border]` | `border: Border.all(color: const Color(0xFF00F4FE), width: 0.8), // [UBAH_WARN...` |
| 19 | `L1631` | `// [UBAH_WARNA: FAB Recenter GPS Icon]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: FAB Recenter GPS Icon]` |
| 20 | `L1645` | `// [UBAH_WARNA: Bottom Sheet Panel Ekspedisi Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Bottom Sheet Panel Ekspedisi ...` |
| 21 | `L1696` | `// [UBAH_WARNA: Card Target Gate Panel]` | `color: const Color(0xFF110C19).withValues(alpha: 0.65), // [UBAH_WARNA: Card ...` |
| 22 | `L1705` | `// [UBAH_WARNA: Ikon Target Gate Panel]` | `const Icon(Icons.near_me_rounded, color: Color(0xFF00F4FE), size: 16), // [UB...` |
| 23 | `L1717` | `// [UBAH_WARNA: Teks Rank Target Gate Panel]` | `color: const Color(0xFFDCB8FC), // [UBAH_WARNA: Teks Rank Target Gate Panel]` |
| 24 | `L1725` | `// [UBAH_WARNA: Teks Nama Target Gate Panel]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Teks Nama Target Gate Panel]` |
| 25 | `L1789` | `// [UBAH_WARNA: Card Mystery Gift Box]` | `color: const Color(0xFF110C19).withValues(alpha: 0.65), // [UBAH_WARNA: Card ...` |
| 26 | `L1811` | `// [UBAH_WARNA: Teks Judul Mystery Gift]` | `color: const Color(0xFFFFD166), // [UBAH_WARNA: Teks Judul Mystery Gift]` |
| 27 | `L1814` | `// [UBAH_WARNA: Ikon Bintang Mystery Gift]` | `const Icon(Icons.stars_rounded, color: Color(0xFFFFD166), size: 16), // [UBAH...` |
| 28 | `L1955` | `// [UBAH_WARNA: Tombol Klaim Dungeon Expedition - Gradien Cyan]` | `colors: [Color(0xFF00F4FE), Color(0xFF00DCE5), Color(0xFF008389)], // [UBAH_W...` |
| 29 | `L2001` | `// [UBAH_WARNA: Teks Tombol Klaim Mystery Gift]` | `color: hasClaimed // [UBAH_WARNA: Teks Tombol Klaim Mystery Gift]` |
---

### File: `lib/screens/tabs/tab_game.dart` (Tab 3: Mana Core & Gyroscope Calibration Minigame)
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
| 21 | `L1331` | `// [UBAH_WARNA: Teks Display Timer Game]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Teks Display Timer Game]` |
| 22 | `L1375` | `// [UBAH_WARNA: Track Progress Bar Timer]` | `backgroundColor: const Color(0xFF110C19), // [UBAH_WARNA: Track Progress Bar ...` |
| 23 | `L1391` | `// [UBAH_WARNA: Card Reward Gold Game Background]` | `color: const Color(0xFF1B1406), // [UBAH_WARNA: Card Reward Gold Game Backgro...` |
| 24 | `L1394` | `// [UBAH_WARNA: Card Reward Gold Game Border]` | `color: const Color(0xFFFFD166).withValues(alpha: 0.35), // [UBAH_WARNA: Card ...` |
| 25 | `L1430` | `// [UBAH_WARNA: Teks Nilai Reward Gold]` | `color: const Color(0xFFFFD166), // [UBAH_WARNA: Teks Nilai Reward Gold]` |
| 26 | `L1473` | `// [UBAH_WARNA: Banner Daily Reward Claimed Background]` | `color: const Color(0xFF1E1728), // [UBAH_WARNA: Banner Daily Reward Claimed B...` |
| 27 | `L1569` | `// [UBAH_WARNA: Tombol Mini Game Retry - Merah Gagal]` | `? [const Color(0xFF93000A), const Color(0xFFFF5449)] // [UBAH_WARNA: Tombol M...` |
| 28 | `L1570` | `// [UBAH_WARNA: Tombol Mini Game Start - Ungu Aktif]` | `: [const Color(0xFF7B2CBF), const Color(0xFFB026FF)], // [UBAH_WARNA: Tombol ...` |
| 29 | `L1600` | `// [UBAH_WARNA: Teks Tombol Mainkan Game]` | `color: Colors.white, // [UBAH_WARNA: Teks Tombol Mainkan Game]` |
---

### File: `lib/screens/tabs/tab_shop.dart` (Tab 4: Exchange Shop & DEX Token Valuation)
**Total Penanda:** 30 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L357` | `// [UBAH_WARNA: Dialog Kalkulator Kurs Background]` | `color: const Color(0xFF140D24), // [UBAH_WARNA: Dialog Kalkulator Kurs Backgr...` |
| 2 | `L362` | `// [UBAH_WARNA: Dialog Kalkulator Kurs Border]` | `border: Border.all(color: const Color(0xFF00F4FE).withValues(alpha: 0.5), wid...` |
| 3 | `L413` | `// [UBAH_WARNA: Input Nilai Gold Kalkulator]` | `color: const Color(0xFFFFD166), // [UBAH_WARNA: Input Nilai Gold Kalkulator]` |
| 4 | `L576` | `// [UBAH_WARNA: Dialog Top-Up Gold Background]` | `color: const Color(0xFF140D24), // [UBAH_WARNA: Dialog Top-Up Gold Background]` |
| 5 | `L578` | `// [UBAH_WARNA: Dialog Top-Up Gold Border]` | `border: Border.all(color: const Color(0xFF00F4FE).withValues(alpha: 0.6), wid...` |
| 6 | `L749` | `// [UBAH_WARNA: Tombol Top-Up Saldo Confirm]` | `backgroundColor: const Color(0xFF00F4FE), // [UBAH_WARNA: Tombol Top-Up Saldo...` |
| 7 | `L1625` | `// [UBAH_WARNA: Latar Belakang Layar Tab Shop]` | `backgroundColor: const Color(0xFF16111E), // [UBAH_WARNA: Latar Belakang Laya...` |
| 8 | `L1699` | `// [UBAH_WARNA: Pill Rank Header Shop Background]` | `color: const Color(0xFF2D2736), // [UBAH_WARNA: Pill Rank Header Shop Backgro...` |
| 9 | `L1708` | `// [UBAH_WARNA: Pill Rank Header Shop Teks]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Pill Rank Header Shop Teks]` |
| 10 | `L1743` | `// [UBAH_WARNA: Judul Header Monarch Treasury]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Judul Header Monarch Treasury]` |
| 11 | `L1790` | `// [UBAH_WARNA: Chip Protokol Live Market Background]` | `color: const Color(0xFF2D2736), // [UBAH_WARNA: Chip Protokol Live Market Bac...` |
| 12 | `L1806` | `// [UBAH_WARNA: Dot Indikator Market Live]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Dot Indikator Market Live]` |
| 13 | `L1831` | `// [UBAH_WARNA: Chip Vault Balance Background]` | `color: const Color(0xFF2D2736), // [UBAH_WARNA: Chip Vault Balance Background]` |
| 14 | `L1853` | `// [UBAH_WARNA: Teks Gold Vault Balance]` | `color: const Color(0xFFFFD166), // [UBAH_WARNA: Teks Gold Vault Balance]` |
| 15 | `L1966` | `// [UBAH_WARNA: Card Kurs Valuasi Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Card Kurs Valuasi Background]` |
| 16 | `L1968` | `// [UBAH_WARNA: Card Kurs Valuasi Border]` | `border: Border.all(color: const Color(0xFF2C1E4E), width: 0.8), // [UBAH_WARN...` |
| 17 | `L1978` | `// [UBAH_WARNA: Ikon Kurs Valuasi Header]` | `const Icon(Icons.currency_exchange_rounded, size: 16, color: Color(0xFF00F4FE...` |
| 18 | `L1986` | `// [UBAH_WARNA: Judul Kurs Valuasi Header]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Judul Kurs Valuasi Header]` |
| 19 | `L2062` | `// [UBAH_WARNA: Teks Total Wealth Hunter]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Teks Total Wealth Hunter]` |
| 20 | `L2073` | `// [UBAH_WARNA: Tombol Kalkulator Kurs Background]` | `color: const Color(0xFFB026FF).withValues(alpha: 0.2), // [UBAH_WARNA: Tombol...` |
| 21 | `L2086` | `// [UBAH_WARNA: Tombol Kalkulator Kurs Teks]` | `color: const Color(0xFFE5B5FF), // [UBAH_WARNA: Tombol Kalkulator Kurs Teks]` |
| 22 | `L2250` | `// [UBAH_WARNA: Card Item Gelar Shop Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Card Item Gelar Shop Background]` |
| 23 | `L2280` | `// [UBAH_WARNA: Well Ikon Item Gelar]` | `color: const Color(0xFF2D2736), // [UBAH_WARNA: Well Ikon Item Gelar]` |
| 24 | `L2307` | `// [UBAH_WARNA: Nama Item Gelar Shop]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Nama Item Gelar Shop]` |
| 25 | `L2343` | `// [UBAH_WARNA: Harga Item Gelar Gold]` | `color: const Color(0xFFFFD166), // [UBAH_WARNA: Harga Item Gelar Gold]` |
| 26 | `L2368` | `// [UBAH_WARNA: Tombol Beli Title - Gradien Cyan Ungu]` | `colors: [Color(0xFF00F4FE), Color(0xFFB026FF)], // [UBAH_WARNA: Tombol Beli T...` |
| 27 | `L2425` | `// [UBAH_WARNA: Teks Tombol Beli Gelar]` | `color: isOwned ? const Color(0xFF00F4FE) : Colors.black, // [UBAH_WARNA: Teks...` |
| 28 | `L2604` | `// [UBAH_WARNA: Tombol Blockchain Explorer Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Tombol Blockchain Explorer Ba...` |
| 29 | `L2621` | `// [UBAH_WARNA: Ikon Tombol Blockchain Explorer]` | `child: const Icon(Icons.hub_rounded, size: 18, color: Color(0xFF00F4FE)), // ...` |
| 30 | `L2630` | `// [UBAH_WARNA: Teks Tombol Blockchain Explorer]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Teks Tombol Blockchain Explorer]` |
---

### File: `lib/screens/tabs/tab_profile.dart` (Tab 5: Hunter Status & Kesan Pesan)
**Total Penanda:** 37 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L304` | `// [UBAH_WARNA: Dialog Logout Background]` | `), // [UBAH_WARNA: Dialog Logout Background]` |
| 2 | `L310` | `// [UBAH_WARNA: Dialog Logout Border]` | `), // [UBAH_WARNA: Dialog Logout Border]` |
| 3 | `L352` | `// [UBAH_WARNA: Tombol Konfirmasi Logout Background]` | `), // [UBAH_WARNA: Tombol Konfirmasi Logout Background]` |
| 4 | `L502` | `// [UBAH_WARNA: Latar Belakang Layar Tab Profile]` | `), // [UBAH_WARNA: Latar Belakang Layar Tab Profile]` |
| 5 | `L561` | `// [UBAH_WARNA: Header Rank Pill Background]` | `), // [UBAH_WARNA: Header Rank Pill Background]` |
| 6 | `L572` | `// [UBAH_WARNA: Header Rank Pill Teks]` | `), // [UBAH_WARNA: Header Rank Pill Teks]` |
| 7 | `L609` | `// [UBAH_WARNA: Header Judul Profil]` | `), // [UBAH_WARNA: Header Judul Profil]` |
| 8 | `L726` | `// [UBAH_WARNA: Card Hunter ID Background]` | `), // [UBAH_WARNA: Card Hunter ID Background]` |
| 9 | `L731` | `// [UBAH_WARNA: Card Hunter ID Border]` | `), // [UBAH_WARNA: Card Hunter ID Border]` |
| 10 | `L836` | `// [UBAH_WARNA: Tombol Ganti Avatar Mini Background]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Tombol Ganti Avatar Mini Back...` |
| 11 | `L875` | `// [UBAH_WARNA: Nama Hunter Profile]` | `), // [UBAH_WARNA: Nama Hunter Profile]` |
| 12 | `L884` | `// [UBAH_WARNA: Ikon Verified Hunter Profile]` | `), // [UBAH_WARNA: Ikon Verified Hunter Profile]` |
| 13 | `L1064` | `// [UBAH_WARNA: Box Classification Badge Background]` | `), // [UBAH_WARNA: Box Classification Badge Background]` |
| 14 | `L1068` | `// [UBAH_WARNA: Box Classification Badge Border]` | `), // [UBAH_WARNA: Box Classification Badge Border]` |
| 15 | `L1125` | `// [UBAH_WARNA: Tier Badge World Background]` | `), // [UBAH_WARNA: Tier Badge World Background]` |
| 16 | `L1135` | `// [UBAH_WARNA: Tier Badge World Teks]` | `), // [UBAH_WARNA: Tier Badge World Teks]` |
| 17 | `L1215` | `// [UBAH_WARNA: Card Total Gold Profile Background]` | `), // [UBAH_WARNA: Card Total Gold Profile Background]` |
| 18 | `L1220` | `// [UBAH_WARNA: Card Total Gold Profile Border]` | `), // [UBAH_WARNA: Card Total Gold Profile Border]` |
| 19 | `L1241` | `// [UBAH_WARNA: Ikon Total Gold Profile]` | `), // [UBAH_WARNA: Ikon Total Gold Profile]` |
| 20 | `L1267` | `// [UBAH_WARNA: Teks Nilai Total Gold Profile]` | `), // [UBAH_WARNA: Teks Nilai Total Gold Profile]` |
| 21 | `L1294` | `// [UBAH_WARNA: Card Quests Done Profile Background]` | `), // [UBAH_WARNA: Card Quests Done Profile Background]` |
| 22 | `L1299` | `// [UBAH_WARNA: Card Quests Done Profile Border]` | `), // [UBAH_WARNA: Card Quests Done Profile Border]` |
| 23 | `L1320` | `// [UBAH_WARNA: Ikon Quests Done Profile]` | `), // [UBAH_WARNA: Ikon Quests Done Profile]` |
| 24 | `L1363` | `// [UBAH_WARNA: Teks Nilai Quests Done Profile]` | `), // [UBAH_WARNA: Teks Nilai Quests Done Profile]` |
| 25 | `L1900` | `// [UBAH_WARNA: Switch Fingerprint Aktif]` | `), // [UBAH_WARNA: Switch Fingerprint Aktif]` |
| 26 | `L1979` | `// [UBAH_WARNA: Switch Face Scan Aktif]` | `), // [UBAH_WARNA: Switch Face Scan Aktif]` |
| 27 | `L2120` | `// [UBAH_WARNA: Label Tipe Penyimpanan Feedback]` | `color: const Color(0xFF9B8BA1), // [UBAH_WARNA: Label Tipe Penyimpanan Feedback]` |
| 28 | `L2234` | `// [UBAH_WARNA: Background Input Saran Kesan]` | `), // [UBAH_WARNA: Background Input Saran Kesan]` |
| 29 | `L2238` | `// [UBAH_WARNA: Border Input Saran Kesan]` | `), // [UBAH_WARNA: Border Input Saran Kesan]` |
| 30 | `L2247` | `// [UBAH_WARNA: Warna Teks Input Saran Kesan]` | `), // [UBAH_WARNA: Warna Teks Input Saran Kesan]` |
| 31 | `L2255` | `// [UBAH_WARNA: Hint Input Saran Kesan]` | `), // [UBAH_WARNA: Hint Input Saran Kesan]` |
| 32 | `L2318` | `// [UBAH_WARNA: Tombol Submit Feedback]` | `], // [UBAH_WARNA: Tombol Submit Feedback]` |
| 33 | `L2347` | `// [UBAH_WARNA: Teks Tombol Submit Feedback]` | `color: Colors.white, // [UBAH_WARNA: Teks Tombol Submit Feedback]` |
| 34 | `L2385` | `// [UBAH_WARNA: Tombol Logout Background]` | `), // [UBAH_WARNA: Tombol Logout Background]` |
| 35 | `L2389` | `// [UBAH_WARNA: Tombol Logout Border]` | `), // [UBAH_WARNA: Tombol Logout Border]` |
| 36 | `L2404` | `// [UBAH_WARNA: Ikon Tombol Logout]` | `), // [UBAH_WARNA: Ikon Tombol Logout]` |
| 37 | `L2414` | `// [UBAH_WARNA: Teks Tombol Logout]` | `), // [UBAH_WARNA: Teks Tombol Logout]` |
---

### File: `lib/screens/features/appearance_quest_screen.dart` (Appearance / Skincare Quest Time-Locked)
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

### File: `lib/screens/features/workout_hub_screen.dart` (Workout Hub / Camera ML-Kit Pose Detection)
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
| 19 | `L1422` | `// [UBAH_WARNA: Judul Rutinitas 4 Latihan Fisik]` | `color: Colors.white, // [UBAH_WARNA: Judul Rutinitas 4 Latihan Fisik]` |
| 20 | `L1442` | `// [UBAH_WARNA: Teks Progress Rutinitas Latihan]` | `color: const Color(0xFF00E5FF), // [UBAH_WARNA: Teks Progress Rutinitas Latihan]` |
| 21 | `L1552` | `// [UBAH_WARNA: Bottom Bar Item Latihan Fisik]` | `color: const Color(0xFF08050E), // [UBAH_WARNA: Bottom Bar Item Latihan Fisik]` |
| 22 | `L1609` | `// [UBAH_WARNA: Box Counter Target Repetisi]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Box Counter Target Repetisi]` |
| 23 | `L1633` | `// [UBAH_WARNA: Tombol Buka Kamera Deteksi Pose]` | `color: const Color(0xFFB026FF), // [UBAH_WARNA: Tombol Buka Kamera Deteksi Pose]` |
| 24 | `L1703` | `// [UBAH_WARNA: Tombol Selesaikan Latihan - Ungu Gelap]` | `Color(0xFF7000A8), // [UBAH_WARNA: Tombol Selesaikan Latihan - Ungu Gelap]` |
| 25 | `L1704` | `// [UBAH_WARNA: Tombol Selesaikan Latihan - Ungu Terang]` | `Color(0xFFB026FF), // [UBAH_WARNA: Tombol Selesaikan Latihan - Ungu Terang]` |
| 26 | `L1705` | `// [UBAH_WARNA: Tombol Selesaikan Latihan - Cyan Aksen]` | `Color(0xFF00F4FE), // [UBAH_WARNA: Tombol Selesaikan Latihan - Cyan Aksen]` |
| 27 | `L1743` | `// [UBAH_WARNA: Ikon Tombol Selesaikan Latihan]` | `? Colors.white // [UBAH_WARNA: Ikon Tombol Selesaikan Latihan]` |
| 28 | `L1758` | `// [UBAH_WARNA: Teks Tombol Selesaikan Latihan]` | `? Colors.white // [UBAH_WARNA: Teks Tombol Selesaikan Latihan]` |
---

### File: `lib/screens/features/quest_sensor.dart` (Sensor Calibration & Accelerometer HUD)
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

### File: `lib/screens/features/study_focus_screen.dart` (Study Focus / Pomodoro Hunter Timer)
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

### File: `lib/screens/features/chat_ai_screen.dart` (System Guide AI & Chat Assistant)
**Total Penanda:** 25 titik visual

| No | Baris | Tag Pencarian (`Ctrl + F`) | Potongan Kode Asli |
|:---:|:---:|:---|:---|
| 1 | `L717` | `// [UBAH_WARNA: Latar Belakang Layar Chat AI]` | `backgroundColor: const Color(0xFF110C19), // [UBAH_WARNA: Latar Belakang Laya...` |
| 2 | `L760` | `// [UBAH_WARNA: Header App Bar Chat AI]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Header App Bar Chat AI]` |
| 3 | `L763` | `// [UBAH_WARNA: Header App Bar Chat AI Border]` | `color: Color(0xFF2C1E4E), // [UBAH_WARNA: Header App Bar Chat AI Border]` |
| 4 | `L787` | `// [UBAH_WARNA: Tombol Kembali Chat AI]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Tombol Kembali Chat AI]` |
| 5 | `L816` | `// [UBAH_WARNA: Teks Judul Hunter Assistant]` | `color: const Color(0xFF63F7FF), // [UBAH_WARNA: Teks Judul Hunter Assistant]` |
| 6 | `L836` | `// [UBAH_WARNA: Dot Online Status Chat AI]` | `color: Color(0xFF00F4FE), // [UBAH_WARNA: Dot Online Status Chat AI]` |
| 7 | `L880` | `// [UBAH_WARNA: Tombol Konfigurasi Persona Background]` | `color: const Color(0xFF00F4FE).withValues(alpha: 0.6), // [UBAH_WARNA: Tombol...` |
| 8 | `L921` | `// [UBAH_WARNA: Chip Persona Aktif Background]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Chip Persona Aktif Background]` |
| 9 | `L951` | `// [UBAH_WARNA: Teks Nama Persona Aktif]` | `color: const Color(0xFF63F7FF), // [UBAH_WARNA: Teks Nama Persona Aktif]` |
| 10 | `L1002` | `// [UBAH_WARNA: Avatar AI Chat Bubble]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Avatar AI Chat Bubble]` |
| 11 | `L1028` | `// [UBAH_WARNA: Background Bubble Pesan AI]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Background Bubble Pesan AI]` |
| 12 | `L1036` | `// [UBAH_WARNA: Border Bubble Pesan AI]` | `color: const Color(0xFF2C1E4E), // [UBAH_WARNA: Border Bubble Pesan AI]` |
| 13 | `L1061` | `// [UBAH_WARNA: Tag Pengirim Bubble Pesan AI]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Tag Pengirim Bubble Pesan AI]` |
| 14 | `L1160` | `// [UBAH_WARNA: Bubble Pesan User Gradien Ungu]` | `gradient: const LinearGradient( // [UBAH_WARNA: Bubble Pesan User Gradien Ungu]` |
| 15 | `L1187` | `// [UBAH_WARNA: Teks Pesan Bubble User]` | `color: Colors.white, // [UBAH_WARNA: Teks Pesan Bubble User]` |
| 16 | `L1243` | `// [UBAH_WARNA: Avatar User Chat Bubble]` | `color: const Color(0xFFB026FF), // [UBAH_WARNA: Avatar User Chat Bubble]` |
| 17 | `L1290` | `// [UBAH_WARNA: Background Block Code Chat AI]` | `color: const Color(0xFF140D28), // [UBAH_WARNA: Background Block Code Chat AI]` |
| 18 | `L1315` | `// [UBAH_WARNA: Teks Highlight Bold Pesan AI]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Teks Highlight Bold Pesan AI]` |
| 19 | `L1440` | `// [UBAH_WARNA: Container Bar Input Chat AI]` | `color: const Color(0xFF110C19), // [UBAH_WARNA: Container Bar Input Chat AI]` |
| 20 | `L1463` | `// [UBAH_WARNA: Background Box Input Chat AI]` | `color: const Color(0xFF1F1927), // [UBAH_WARNA: Background Box Input Chat AI]` |
| 21 | `L1466` | `// [UBAH_WARNA: Border Box Input Chat AI]` | `color: const Color(0xFF383241), // [UBAH_WARNA: Border Box Input Chat AI]` |
| 22 | `L1495` | `// [UBAH_WARNA: Warna Teks Input Chat AI]` | `color: const Color(0xFFE9DEF2), // [UBAH_WARNA: Warna Teks Input Chat AI]` |
| 23 | `L1502` | `// [UBAH_WARNA: Warna Hint Input Chat AI]` | `color: const Color(0xFF5D5373), // [UBAH_WARNA: Warna Hint Input Chat AI]` |
| 24 | `L1546` | `// [UBAH_WARNA: Tombol Kirim Pesan Chat AI]` | `color: const Color(0xFF00F4FE), // [UBAH_WARNA: Tombol Kirim Pesan Chat AI]` |
| 25 | `L1559` | `// [UBAH_WARNA: Ikon Send Pesan Chat AI]` | `color: Color(0xFF08050E), // [UBAH_WARNA: Ikon Send Pesan Chat AI]` |
---

### File: `lib/widgets/avatar_adjust_dialog.dart` (Dialog Pengatur Posisi Avatar)
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

### File: `lib/widgets/face_scan_dialog.dart` (Dialog Simulasi Biometrik Face Scan)
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
