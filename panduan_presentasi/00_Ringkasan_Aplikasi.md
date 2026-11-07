# 00. Ringkasan & Arsitektur Aplikasi LevMax

---

## 1. Gambaran Singkat Aplikasi
**LevMax (*The Hunter Awakening System*)** adalah aplikasi pelacak kebiasaan harian (*habit tracker*) berbasis gamifikasi RPG yang terinspirasi dari serial fiksi *Solo Leveling*. Aplikasi ini mengubah aktivitas nyata pengguna—mulai dari olahraga fisik, fokus belajar, perawatan diri, hingga jalan sehat keliling kampus—menjadi misi harian dengan timbal balik status karakter (Rank F sampai S, EXP, HP, dan Gold).

---

## 2. Konsep & Arsitektur Dasar Pembuatan
Aplikasi ini dibangun menggunakan arsitektur modular pada Flutter dengan pendekatan **Dual Database System (Lokal & Cloud)**:
1. **Penyimpanan Lokal (Offline-First dengan Hive):**
   - Berfungsi seperti lemari penyimpanan instan di dalam memori ponsel.
   - Menyimpan data sesi login aktif, riwayat buku besar (*ledger*) blockchain belanja gelar, pengaturan jam alarm, personifikasi asisten AI, dan pencatatan quest hari ini.
   - Keunggulannya: Aplikasi tetap berjalan mulus, cepat, dan bisa mencatat quest walau tanpa koneksi internet sama sekali.
2. **Penyimpanan Cloud (Online dengan Supabase Backend-as-a-Service):**
   - Berfungsi sebagai server pusat berbasis PostgreSQL di awan (*cloud*).
   - Menyimpan data akun pengguna (username & sandi terenkripsi SHA-256), sinkronisasi statistik RPG (EXP, Gold, Rank, HP), galeri avatar profil pada penyimpanan S3, serta pesan kesan/saran mata kuliah.
3. **Integrasi Sensor Fisik Perangkat:**
   - Membaca perangkat keras bawaan ponsel cerdas secara langsung: sensor *Accelerometer* (deteksi guncangan kardio), sensor *Gyroscope* (keseimbangan bola mana), modul GPS (*Geolocator* untuk radar lokasi dungeon), serta kamera depan (*Face Scan* biometrik wajah).
4. **Konektivitas Layanan Luar (Web Service / API):**
   - Google Gemini AI (konsultasi kebugaran & generator misi rahasia).
   - Open Exchange Rates API (kurs nilai tukar live mata uang internasional).
   - OpenStreetMap Tile Service (peta visual satelit/jalanan).

---

## 3. Matriks 13 Syarat Tugas Akhir & Pemetaannya di LevMax

| No | Kriteria Evaluasi Dosen | Implementasi Nyata di LevMax | Lokasi File Panduan |
|:--:|:-------------------------|:-----------------------------|:--------------------|
| **1** | Konsep Proyek Akhir Matang | Sistem RPG Hunter Solo Leveling (Rank F-S, EXP, 3 HP, Gold, Daily Quests). | `02_Gamifikasi_RPG_dan_Penalti_HP.md` |
| **2** | Login Enkripsi (Non-Firebase) | Hashing password client-side dengan SHA-256, verifikasi Supabase, dan sesi lokal Hive. | `01_Autentikasi_Enkripsi_dan_Biometrik.md` |
| **3** | Login Biometrik | Pemindaian sidik jari (*fingerprint*) via `local_auth` & verifikasi wajah via kamera depan. | `01_Autentikasi_Enkripsi_dan_Biometrik.md` |
| **4** | Dual Database (Lokal & Online) | • **Lokal:** Hive (sessionBox, blockchainBox, questBox).<br>• **Online:** Supabase PostgreSQL (users, feedbacks). | `01_Autentikasi_Enkripsi_dan_Biometrik.md`<br>`10_Profil_Hunter_Kesan_Pesan_dan_Logout.md` |
| **5** | Web Service / API & LBS | • **API:** Supabase REST, Gemini AI, Open Exchange Rates live kurs.<br>• **LBS:** OpenStreetMap + Geolocator klaim gate radius < 100m. | `06_Eksplorasi_Peta_LBS_Dungeon_Radar.md`<br>`07_Exchange_Kurs_Valas_dan_Blockchain_Ledger.md` |
| **6** | Bottom Navigation (5 Tab) | 5 Menu Utama (Quests, Dungeon, Mana, Exchange, Status) + Profil, Form Masukan Dosen, Logout. | `03_Dashboard_Quest_Pencarian_dan_Waktu.md`<br>`10_Profil_Hunter_Kesan_Pesan_dan_Logout.md` |
| **7** | Konversi Mata Uang & Waktu | • **Mata Uang:** Live API kurs Gold ke IDR, USD, EUR + kalkulator.<br>• **Waktu:** Jam server simultan 4 zona (WIB, WITA, WIT, London GMT). | `03_Dashboard_Quest_Pencarian_dan_Waktu.md`<br>`07_Exchange_Kurs_Valas_dan_Blockchain_Ledger.md` |
| **8** | Minimal 2 Sensor Lanjutan | 1. **Accelerometer:** Quest Cardio Shake (hitung 50 guncangan fisik).<br>2. **Gyroscope:** Mini game Mana Core Balancer (keseimbangan rotasi). | `04_Sensor_Kardio_Accelerometer.md`<br>`05_Mini_Game_Sensor_Gyroscope.md` |
| **9** | Fitur AI / LLM Sesuai Konsep | Asisten AI konsultasi kebugaran dengan kepribadian dinamis & generator Hidden Quest otomatis via Google Gemini API. | `08_Asisten_AI_Hunter_Guide_Gemini.md` |
| **10** | Mini Game Terkait Konsep | Mini game "Mana Core Balancer" menahan bola energi di titik tengah dengan kemiringan fisik ponsel. | `05_Mini_Game_Sensor_Gyroscope.md` |
| **11** | Fasilitas Pencarian & Filter | Search bar pencarian live teks judul quest & tombol dropdown filter 4 kategori quest. | `03_Dashboard_Quest_Pencarian_dan_Waktu.md` |
| **12** | Notifikasi Berbasis Mobile | Push notification lokal 5 skenario otomatis (reset harian, pengingat 3 jam, sapaan AI, dll) + sistem alarm latihan audio looping. | `09_Notifikasi_Lokal_dan_Alarm_Latihan.md` |
| **13** | Blockchain Sederhana | Buku besar (*ledger*) transaksi belanja title dengan hash berantai SHA-256 (`prev_hash` + data transaksi) di Hive & on-chain Web3 Sepolia. | `07_Exchange_Kurs_Valas_dan_Blockchain_Ledger.md` |

---

## 4. Peta Struktur File Proyek (`lib/`)

```
lib/
├── main.dart                          -> Entry point, inisialisasi Hive, Supabase, Notifikasi, dan Tema Global
├── models/
│   ├── ai_persona_model.dart          -> Struktur data kustomisasi asisten AI Gemini
│   ├── alarm_model.dart               -> Struktur data konfigurasi jam alarm & nada dering
│   ├── dungeon_gate_model.dart        -> Titik koordinat GPS dungeon nyata di Yogyakarta
│   ├── quest_model.dart               -> Struktur data misi harian & master quest bawaan
│   └── user_model.dart                -> Struktur data profil Hunter (EXP, Gold, Rank, HP)
├── screens/
│   ├── splash_screen.dart             -> Layar pembuka animasi reaktor mana 5 detik
│   ├── main_navigation.dart           -> Navigasi bawah (Bottom Navigation 5 Tab dengan IndexedStack)
│   ├── auth/
│   │   ├── login_screen.dart          -> Layar login sandi hash SHA-256 & bypass biometrik
│   │   └── register_screen.dart       -> Layar pendaftaran akun baru & upload foto awal
│   ├── features/
│   │   ├── quest_sensor.dart          -> Layar sensor kardio accelerometer (50 shakes)
│   │   ├── chat_ai_screen.dart        -> Layar chat konsultasi AI Gemini dengan markdown
│   │   ├── study_focus_screen.dart    -> Timer Pomodoro fokus belajar 30 menit
│   │   ├── workout_hub_screen.dart    -> Panduan biomekanik latihan (Pushup, Pullup, Situp, Squat)
│   │   └── appearance_quest_screen.dart-> Checklist 5 fase protokol grooming/perawatan diri
│   └── tabs/
│       ├── tab_home.dart              -> Tab 1: Dashboard Quest, jam 4 zona, dan search filter
│       ├── tab_map.dart               -> Tab 2: Peta OpenStreetMap radar LBS radius 100m
│       ├── tab_game.dart              -> Tab 3: Mini Game keseimbangan gyro ball
│       ├── tab_shop.dart              -> Tab 4: Toko Title, konversi kurs valas live, dan Blockchain Ledger
│       └── tab_profile.dart           -> Tab 5: Profil, pesan kesan matkul ke Supabase, dan Logout
├── services/
│   ├── hash_service.dart              -> Enkripsi password SHA-256 & hashing berantai blockchain
│   ├── hive_service.dart              -> Pengelolaan database lokal NoSQL Hive (Session, Ledger, Quest)
│   ├── supabase_service.dart          -> Komunikasi remote database cloud PostgreSQL Supabase
│   ├── gemini_service.dart            -> Integrasi Google Generative AI LLM Gemini
│   ├── face_recognition_service.dart  -> Pemrosesan Computer Vision biometrik wajah (Z-score & dHash)
│   ├── s3_storage_service.dart        -> Protokol AWS S3 SigV4 untuk upload gambar avatar ke cloud
│   ├── notif_service.dart             -> Pengelolaan push notification lokal berjadwal
│   └── alarm_service.dart             -> Pemutar audio alarm looping dan integrasi OS alarm clock
├── utils/
│   └── constants.dart                 -> Tema warna Solo Leveling, formula hitung Rank, dan batas EXP
└── widgets/
    ├── avatar_adjust_dialog.dart      -> Dialog pemotongan (crop) & rotasi foto profil 1:1
    ├── avatar_image.dart              -> Widget penampil foto profil fleksibel (URL / File / Icon)
    └── face_scan_dialog.dart          -> Antarmuka HUD pemindai wajah kamera depan real-time
```

---

## 5. Contekan Kalimat Pembuka Presentasi (Siap Baca)
> *"Selamat pagi/siang Bapak Dosen Penguji. Pada kesempatan kali ini, kami mempresentasikan proyek aplikasi mobile bernama **LevMax**, sebuah platform habit tracker berbasis gamifikasi yang mengadaptasi sistem perkembangan karakter RPG terinspirasi dari Solo Leveling. Aplikasi ini kami bangun untuk mengatasi masalah prokrastinasi dengan mengubah rutinitas nyata sehari-hari—mulai dari olahraga fisik, fokus belajar, perawatan diri, hingga eksplorasi kampus—menjadi misi harian dengan timbal balik status karakter yang nyata. Aplikasi ini telah mengintegrasikan dual database lokal dan cloud, 2 sensor fisik perangkat yaitu accelerometer dan gyroscope, pelacakan lokasi berbasis GPS LBS, asisten kecerdasan buatan Gemini AI, konversi multi mata uang serta 4 zona waktu, hingga buku besar transaksi berbasis blockchain sederhana."*

