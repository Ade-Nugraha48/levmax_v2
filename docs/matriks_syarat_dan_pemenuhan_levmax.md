# Matriks Syarat & Pemenuhan Tugas Akhir - LevMax

Dokumen ini mendokumentasikan pemetaan 13 syarat dan ketentuan penilaian mata kuliah **Pemrograman Aplikasi Mobile** terhadap arsitektur, fitur, dan implementasi teknis aplikasi **LevMax**.

---

## 1. Ringkasan Eksekutif & Status Pemenuhan

* **Nama Proyek:** LevMax (Gamified Self-Improvement & Habit Tracker)
* **Framework:** Flutter (Android & iOS)
* **Pendekatan Arsitektur:** `StatefulWidget` & `setState()` murni (Tanpa GetX, Provider, atau Riverpod)
* **Status Total Pemenuhan:** **13 dari 13 Syarat Terpenuhi (100%)**

---

## 2. Tabel Matriks Pemenuhan Syarat

| No | Syarat & Ketentuan Dosen | Status | Fitur & Konsep Terkait | Stack / Library | Lokasi File Implementasi |
| :---: | :--- | :---: | :--- | :--- | :--- |
| **1** | **Memiliki konsep projek akhir** | **TERPENUHI** | RPG Self-Improvement ala *Solo Leveling* (Rank F ke S, Daily Quest, EXP, Gold, HP System, Penalti Rank). | Native Flutter UI | Seluruh direktori `lib/` |
| **2** | **Login dengan enkripsi (no Firebase) & session** | **TERPENUHI** | Autentikasi remote via Supabase (PostgreSQL), password di-hash manual SHA-256 dari client, sesi disimpan di lokal. | `supabase_flutter`, `crypto`, `hive` | `lib/screens/auth/login_screen.dart`<br>`lib/services/supabase_service.dart`<br>`lib/services/hash_service.dart`<br>`lib/services/hive_service.dart` |
| **3** | **Memiliki login biometric** | **TERPENUHI** | Bypass login menggunakan sensor sidik jari (fingerprint) jika sesi/kredensial lokal valid. | `local_auth` | `lib/screens/auth/login_screen.dart` |
| **4** | **Terkoneksi database lokal & online** | **TERPENUHI** | • **Online:** Supabase (tabel `users`, `feedbacks`).<br>• **Lokal:** Hive Box (`sessionBox`, `blockchainBox`). | `supabase_flutter`, `hive_flutter` | `lib/services/supabase_service.dart`<br>`lib/services/hive_service.dart`<br>`lib/main.dart` |
| **5** | **Web Service/API, Multiplatform & LBS terkait tema** | **TERPENUHI** | • **API:** Supabase REST & Gemini AI API.<br>• **LBS:** Peta OpenStreetMap dengan marker *"Dungeon Portal"* di sekitar kampus, tombol check-in reward jika jarak < 100m. | `flutter_map`, `geolocator`, `latlong2` | `lib/screens/tabs/tab_map.dart` |
| **6** | **Bottom Navigation (Profil + Gambar, Kesan/Saran, Logout)** | **TERPENUHI** | 5 Tab Menu (IndexedStack). Tab Profile berisi: Avatar RPG, Form Feedback multiline ke Supabase, dan Tombol Logout (reset Hive session). | Native Flutter (`IndexedStack`, `BottomNavigationBar`) | `lib/screens/main_navigation.dart`<br>`lib/screens/tabs/tab_profile.dart` |
| **7** | **Konversi mata uang (min. 3) & waktu (WIB, WIT, WITA, London)** | **TERPENUHI** | • **Waktu:** Banner Server Time real-time (WIB, WITA, WIT, London GMT).<br>• **Uang:** Valuasi kurs valas real-time dari API `open.er-api.com` (IDR, USD, EUR) & kalkulator konversi interaktif. | `http`, `intl`, Dart `DateTime` | `lib/screens/tabs/tab_home.dart`<br>`lib/screens/tabs/tab_shop.dart` |
| **8** | **Minimal 2 sensor sesuai konsep lanjutan** | **TERPENUHI** | 1. **Accelerometer:** Quest "Cardio Shake" (shake HP 50x).<br>2. **Gyroscope:** Mini game "Balance the Mana Core" (tahan bola di tengah 5 detik). | `sensors_plus` | `lib/screens/features/quest_sensor.dart`<br>`lib/screens/tabs/tab_game.dart` |
| **9** | **Fitur AI / LLM sesuai konsep tema** | **TERPENUHI** | 1. **Chatbot "Hunter AI Guide"** (`chat_ai_screen.dart`).<br>2. **LLM "Hidden Quest Generator"** ("SCAN HIDDEN DUNGEON" di `tab_home.dart`) menghasilkan misi rahasia epik dinamis via Gemini API. | `google_generative_ai` | `lib/screens/features/chat_ai_screen.dart`<br>`lib/screens/tabs/tab_home.dart`<br>`lib/services/gemini_service.dart` |
| **10** | **Mini game sederhana terkait konsep** | **TERPENUHI** | "Gyro Balancer / Balance the Mana Core" melatih fokus mana hunter menggunakan sensor gyroscope berhadiah Gold harian. | `sensors_plus`, Canvas/Container math | `lib/screens/tabs/tab_game.dart` |
| **11** | **Fasilitas pencarian dan pemilihan** | **TERPENUHI** | Fitur di Tab Home:<br>• **Search:** `TextField` live search nama quest.<br>• **Filter/Select:** `DropdownButton` kategori quest (Workout, Cardio, Appearance, Study). | Native Flutter Widgets | `lib/screens/tabs/tab_home.dart` |
| **12** | **Notifikasi berbasis mobile sesuai konsep** | **TERPENUHI** | Pengiriman push notification lokal pengingat quest hunter harian agar user tidak terkena pinalti HP/Rank. | `flutter_local_notifications` | `lib/services/notif_service.dart`<br>`lib/screens/tabs/tab_home.dart` |
| **13** | **Blockchain sederhana & Web3** | **TERPENUHI** | Pembelian Title on-chain di **Ethereum Sepolia Testnet** via `web3dart`, ditandatangani private key, tervalidasi 100% online di Etherscan Sepolia (`https://sepolia.etherscan.io/tx/<hash>`), fitur salin hash, dan buku besar lokal Hive. | `web3dart`, `http`, `url_launcher`, `hive` | `lib/screens/tabs/tab_shop.dart`<br>`lib/services/hive_service.dart` |

---

## 3. Rincian Teknis Implementasi per Poin

### Syarat 1: Konsep Projek Akhir
* Aplikasi mengangkat tema **Solo Leveling / Hunter System**.
* Habit tracker biasa diubah menjadi *gamified dungeon quest*. Pengguna memiliki level EXP, Rank (F, E, D, C, B, A, S), Gold untuk belanja, serta HP (Health Point) yang berkurang jika lalai menyelesaikan quest harian, disertai penalti penurunan rank.

### Syarat 2: Autentikasi, Enkripsi, dan Sesi
* **Backend:** Menggunakan Supabase (PostgreSQL) menggantikan Firebase.
* **Keamanan:** Password pengguna tidak pernah dikirim dalam bentuk *plain text*. Sebelum request dikirim, password dienkripsi:
  $$\text{Hash} = \text{SHA-256}(\text{plain\_password})$$
* **Sesi:** Begitu login valid, Hive menyimpan `isLoggedIn: true`, `userId`, dan `username` di `sessionBox` sehingga saat aplikasi ditutup dan dibuka kembali, pengguna langsung masuk ke dashboard.

### Syarat 3: Login Biometrik
* Di halaman login disediakan tombol otentikasi biometrik via `local_auth`.
* Mengakses sensor Fingerprint / Biometrik bawaan HP. Jika sidik jari terverifikasi dan perangkat menyimpan sesi pengguna sebelumnya, form login di-*bypass*.

### Syarat 4: Database Lokal & Online
* **Online (Supabase):**
  * Tabel `users`: Menyimpan profil, hash password, status EXP, Gold, dan Rank.
  * Tabel `feedbacks`: Menampung data kesan dan pesan mata kuliah dari mahasiswa.
* **Lokal (Hive):**
  * Box `sessionBox`: Manajemen status sesi login cepat tanpa latency jaringan.
  * Box `blockchainBox`: Penyimpanan buku besar (*ledger*) transaksi lokal yang desentralistik di perangkat.

### Syarat 5: Web Service / API & LBS (Location Based Service)
* **API Service:** Integrasi REST API Supabase dan REST API Google Gemini Generative AI.
* **LBS:**
  * Peta dirender menggunakan `flutter_map` (OpenStreetMap) tanpa perlu Google Maps API Key berbayar.
  * Mendeteksi lokasi user via `geolocator`.
  * Terdapat koordinat statis *Dungeon Spot* (area kampus).
  * Menghitung jarak menggunakan formula `Geolocator.distanceBetween()`. Jika radius $\le 100$ meter, tombol "Klaim Titik" aktif dan memberikan reward Gold + EXP.

### Syarat 6: Bottom Navigation & Menu Profil, Saran/Kesan, Logout
* Menggunakan `BottomNavigationBar` dengan 5 tab: **Home**, **LBS**, **Game**, **Shop**, dan **Profile**.
* Dibungkus dengan `IndexedStack` agar state tiap tab tidak ter-reload saat navigasi berpindah.
* **Tab Profile memuat:**
  1. Avatar profil (visual hunter).
  2. Ringkasan statistik (Rank, EXP bar, total Gold).
  3. Form saran dan kesan mata kuliah Pemrograman Aplikasi Mobile (multi-line input langsung ke Supabase).
  4. Tombol Logout (menghapus Hive session dan mengarahkan kembali ke `LoginScreen`).

### Syarat 7: Konversi Waktu & Konversi Mata Uang
* **Konversi Waktu (Tab Home):**
  * Menampilkan bar waktu server berkonsep RPG reset time.
  * Menampilkan waktu lokal yang dikonversi ke 4 zona:
    * **WIB:** UTC + 7
    * **WITA:** UTC + 8
    * **WIT:** UTC + 9
    * **London (GMT):** UTC + 0
* **Konversi Mata Uang (Tab Shop):**
  * Terhubung secara live ke REST API Open Exchange Rates (`https://open.er-api.com/v6/latest/USD`).
  * Valuasi kekayaan Hunter dihitung secara dinamis dan real-time ke dalam:
    * **IDR:** Rupiah Indonesia (kurs live)
    * **USD:** US Dollar (basis valas)
    * **EUR:** Euro Uni Eropa (kurs live)
  * Dilengkapi modal kalkulator konversi interaktif dengan opsi preset kustom.

### Syarat 8 & 10: Sensor (2 Sensor) & Mini Game
* Menggunakan package resmi `sensors_plus`:
  1. **Sensor Accelerometer:** Quest "Cardio Shake" di `quest_sensor.dart`. Mendeteksi percepatan gerak HP pada sumbu X, Y, Z. Pengguna harus mengocok perangkat sebanyak 50 kali untuk menyelesaikan quest kardio.
  2. **Sensor Gyroscope:** Mini Game "Balance the Mana Core" di `tab_game.dart`. Membaca sudut kemiringan HP untuk menggerakkan bola energi di layar. Pemain harus menstabilkan bola di zona tengah hijau selama 5 detik penuh.
* **Optimasi:** Dilengkapi *throttling* pembaruan UI (interval $\ge 100$ms) dan *stream cancellation* pada `dispose()` agar tidak lag di perangkat low-end.

### Syarat 9: Fitur AI & LLM (Gemini API)
* Mengintegrasikan package `google_generative_ai` dengan 2 fitur utama:
  1. **Chatbot Hunter AI Guide (`chat_ai_screen.dart`):** Layar chat interaktif yang didukung *System Instruction* asisten LevMax seputar kebugaran, pola makan, dan leveling hunter.
  2. **LLM Hidden Quest Generator (`tab_home.dart`):** Tombol *"SCAN HIDDEN DUNGEON"* yang secara asinkron memicu fungsi `generateHiddenQuest(rank, exp)` di `gemini_service.dart`. Model menghasilkan satu narasi misi rahasia epik Solo Leveling maksimal 3 kalimat berformat `[JUDUL MISI]` disesuaikan dengan Rank dan EXP pemain.

### Syarat 11: Pencarian & Pemilihan
* Terletak di Tab Home:
  * **Pencarian:** `TextField` untuk mencari quest berdasarkan kata kunci nama latihan/aktivitas secara instan.
  * **Pemilihan:** `DropdownButton` untuk memilih filter kategori quest (*All*, *Workout*, *Cardio*, *Appearance*, *Study*).

### Syarat 12: Notifikasi Mobile
* Menggunakan package `flutter_local_notifications`.
* Tersedia tombol lonceng/alarm di Tab Home yang memicu notifikasi lokal instan / terjadwal dengan pesan pengingat menyelesaikan quest harian hunter.

### Syarat 13: Blockchain Sederhana & Web3
* Peningkatan sistem transaksi belanja Title di Halaman Shop ke **Public Blockchain Ethereum Sepolia Testnet**:
  * Menggunakan package `web3dart`, `http`, dan `url_launcher`.
  * Transaksi ditandatangani dengan kredensial Ethereum Private Key pengguna dan disiarkan ke jaringan Sepolia publik (Chain ID 11155111).
  * Payload transaksi pembelian disematkan ke dalam blok melalui data bytes `utf8.encode`.
  * **Verifikasi 100% Full Online di Sepolia Etherscan:** Tombol *"Lihat Bukti di Etherscan"* membuka transaksi riil di `https://sepolia.etherscan.io/tx/<hash>` yang terkonfirmasi status `Success` (seluruh simulasi offline telah dihilangkan).
  * Dilengkapi tombol *"Salin Hash"*, Blockchain Ledger berstatus `SEPOLIA ONLINE`, dan tombol *"RESET"* inventori untuk pengujian.

---

## 4. Kepatuhan Khusus Terhadap Batasan Perangkat & Arsitektur

1. **State Management Tanpa Eksternal:**
   * Sepenuhnya menggunakan `StatefulWidget` dan `setState()`.
   * Logika data, kalkulasi sensor, dan pemanggilan database diisolasi di folder `services/`.
2. **Kompatibilitas Layar 720p (OPPO A5 2020) & 1080p (Samsung Galaxy M31):**
   * Tidak ada penggunaan hardcoded tinggi/lebar berlebih.
   * Seluruh tampilan dibungkus dengan `SingleChildScrollView`, `SafeArea`, `Expanded`, dan `Flexible` untuk mengeliminasi potensi error *RenderFlex overflow*.
3. **Pencegahan Kebocoran Memori (Memory Leak):**
   * Semua *StreamSubscription* sensor (`accelerometer` & `gyroscope`) dibatalkan pada `dispose()`.
