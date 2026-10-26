# Struktur Folder & Arsitektur LevMax

Dokumen ini adalah panduan mutlak bagi AI Code Generator (Anti Gravity/Cursor) untuk menyusun struktur direktori proyek Flutter LevMax. Karena proyek ini **wajib** menggunakan `StatefulWidget` dan `setState()` murni tanpa state management eksternal (seperti GetX/Provider), pemisahan antara UI (Tampilan) dan Services (Logika Data) harus sangat ketat.

## 1. Pohon Direktori (Directory Tree)

Semua pengerjaan difokuskan pada folder `lib/`. Berikut adalah struktur baku yang harus diikuti:

```text
lib/
│
├── main.dart                  # Entry point, inisialisasi Hive & Supabase, konfigurasi Tema.
│
├── models/                    # Class cetakan data (Data Classes)
│   ├── user_model.dart        # Model untuk data User (id, username, exp, gold, rank)
│   └── quest_model.dart       # Model untuk list Quest lokal
│
├── screens/                   # Seluruh UI / Halaman Aplikasi (StatefulWidget)
│   ├── auth/                  
│   │   ├── login_screen.dart    # UI Login + Tombol Biometric
│   │   └── register_screen.dart # UI Registrasi
│   │
│   ├── main_navigation.dart   # File krusial: Berisi Scaffold dengan BottomNavigationBar (5 Tab)
│   │
│   ├── tabs/                  # 5 Halaman utama dari Bottom Navigation
│   │   ├── tab_home.dart      # Tab 1: Dashboard, Daftar Quest, Waktu Server
│   │   ├── tab_map.dart       # Tab 2: LBS (flutter_map & geolocator)
│   │   ├── tab_game.dart      # Tab 3: Mini Game Gyroscope
│   │   ├── tab_shop.dart      # Tab 4: Shop Item, Valuasi Valas Real-time, Web3 Sepolia Testnet Blockchain
│   │   └── tab_profile.dart   # Tab 5: Profil, Kesan Pesan Matkul, Logout
│   │
│   └── features/              # Halaman UI tambahan yang dipanggil dari Tab
│       ├── chat_ai_screen.dart  # Modal/Halaman Chat dengan Gemini API
│       └── quest_sensor.dart    # Modal khusus untuk Quest "Cardio Shake" (Accelerometer)
│
├── services/                  # Logika Bisnis & Koneksi (Tidak boleh ada UI di sini)
│   ├── supabase_service.dart  # Fungsi CRUD ke Supabase (Auth, Update EXP/Gold, Insert Feedback)
│   ├── hive_service.dart      # Fungsi simpan/ambil Session Login dan Log Blockchain
│   ├── gemini_service.dart    # Pemanggilan API Google Generative AI (Chat AI & Hidden Quest Generator)
│   ├── notif_service.dart     # Logika flutter_local_notifications
│   └── hash_service.dart      # Algoritma crypto (SHA-256) untuk Enkripsi Password Client
│
└── utils/                     # Konstanta, Helper, dan Tema
    └── constants.dart         # Warna (Hitam/Hijau), Ukuran, TextStyles standar aplikasi
```

## 2. Aturan Arsitektur & Alur Data (Data Flow Rule)

Agar file UI (`screens/`) tidak membengkak ribuan baris, AI harus mematuhi pola alur data berikut:

### Aturan 1: UI Hanya untuk Tampilan dan `setState`
File di dalam folder `screens/` **hanya** bertugas merender Widget dan menyimpan State lokal (seperti `isLoading`, `isObscure`, list data). Jangan menaruh logika kalkulasi panjang atau *query database* langsung di dalam `build()`.

### Aturan 2: Delegasikan ke `services/`
Semua pemanggilan API, Database (Supabase/Hive), Sensor, atau Location harus dibuat dalam bentuk **fungsi asinkron (Future)** di dalam folder `services/`.

**Contoh Alur yang Benar (Login):**
1. User menekan tombol login di `login_screen.dart`.
2. UI memanggil `setState(() { isLoading = true; })`.
3. UI memanggil fungsi `await SupabaseService.login(username, password)`.
4. Jika berhasil, fungsi service akan otomatis memanggil `HiveService.saveSession()`.
5. UI memanggil `setState(() { isLoading = false; })` lalu melakukan navigasi (`Navigator.pushReplacement`).

### Aturan 3: Manajemen Sensor & Controller
Khusus untuk halaman yang menggunakan Sensor (`sensors_plus`) seperti `tab_game.dart` (Gyroscope) dan `quest_sensor.dart` (Accelerometer):
* Sensor stream WAJIB diinisialisasi pada `initState()`.
* Stream subscription WAJIB dihentikan/dibatalkan (`cancel()`) pada `dispose()` agar tidak menyebabkan kebocoran memori (memory leak) di HP *testing* (Oppo A5 & Samsung M31).

### Aturan 4: Navigasi dan Modul Pusat
File `main_navigation.dart` bertindak sebagai "Induk" dari kelima Tab utama. State index yang aktif (0 sampai 4) diatur murni menggunakan `setState` pada variabel `_currentIndex`. Gunakan `IndexedStack` di bagian `body` agar *state* halaman (seperti peta LBS atau form input) tidak ter-reset saat pengguna berpindah antar Tab.