# Product Requirements Document (PRD) - LevMax

## 1. Ikhtisar Proyek
**Nama Aplikasi:** LevMax
**Platform:** Mobile (Android & iOS) via Flutter
**Kategori:** Gamified Self-Improvement & Habit Tracker
**Tujuan Proyek:** Memenuhi tugas akhir mata kuliah Pemrograman Aplikasi Mobile dengan mengintegrasikan berbagai fitur spesifik (Biometrik, Sensor, LBS, AI/LLM, Blockchain sederhana, Supabase + Hive) dalam batas waktu pengerjaan 1 hari.
**Pendekatan State Management:** `StatefulWidget` murni (tanpa GetX, Provider, atau Riverpod) untuk mempercepat development.

## 2. Tech Stack & Dependencies Utama
- **Framework:** Flutter
- **Remote Database & Auth:** Supabase (Backend-as-a-Service)
- **Local Storage & Session:** Hive (Key-Value database yang sangat cepat)
- **Maps / LBS:** `flutter_map` (OpenStreetMap) + `geolocator`
- **Biometric:** `local_auth`
- **Sensors:** `sensors_plus` (Accelerometer & Gyroscope)
- **AI/LLM:** `google_generative_ai` (Gemini API untuk Chat AI & Hidden Quest Generator)
- **Blockchain Web3:** `web3dart`, `http`, `url_launcher` (Ethereum Sepolia Testnet on-chain)
- **Valas Real-Time:** API Open Exchange Rates (`https://open.er-api.com/v6/latest/USD`)
- **Notifikasi:** `flutter_local_notifications`
- **Keamanan (Hashing):** `crypto` (untuk hashing password manual SHA-256)

## 3. Struktur Database
### 3.1 Hive (Local Storage)
- **Box `sessionBox`:** 
  - `isLoggedIn` (bool)
  - `userId` (String)
  - `username` (String)
- **Box `blockchainBox`:** 
  - Menyimpan List dari Map/JSON berisi transaksi pembelian item. Key: `id_transaksi`, Value: `{item_name, timestamp, prev_hash, current_hash}`.

### 3.2 Supabase (Remote Database)
- **Table `users`:** `id` (UUID), `username` (String), `password_hash` (String, di-hash dengan SHA-256 dari sisi client sebelum dikirim untuk memenuhi syarat enkripsi manual), `exp` (Int), `gold` (Int), `rank` (String).
- **Table `feedbacks`:** `id` (UUID), `user_id` (UUID), `message` (String, untuk menampung kesan pesan matkul).

---

## 4. Arsitektur UI & Fitur Utama (Berdasarkan Syarat Tugas)

### 4.1 Modul Autentikasi (Registrasi & Login)
- **Registrasi:** Input Username dan Password. Password di-enkripsi menggunakan SHA-256 sebelum di-insert ke Supabase table `users`.
- **Login:** 
  - Validasi ke Supabase (cocokkan Username dan Hash Password).
  - Jika sukses, simpan sesi di Hive `sessionBox`.
- **Biometric Login:** Terdapat tombol sidik jari di layar Login menggunakan `local_auth`. Jika user sudah pernah login sebelumnya (cek device), bypass login screen.

### 4.2 Navigasi Utama (Bottom Navigation Bar)
Terdiri dari 5 Tab Menu Utama:
1. **Home** (Daftar Quest & Dashboard)
2. **LBS / Map** (Pencarian Titik Hadiah)
3. **Game** (Mini Game Sensor)
4. **Shop** (Toko Item & Blockchain)
5. **Profile** (Statistik & Pengaturan)

---

### 4.3 Detail Halaman per Tab

#### Tab 1: Home (Quest & Dashboard)
- **Header Informasi:**
  - Menampilkan Username, Rank saat ini (E, D, C, B, A, S berdasarkan rentang EXP), EXP bar, dan jumlah Gold.
  - **Syarat Konversi Waktu:** Banner teks statis berjalan (Marquee) atau diletakkan di bawah profil: *"Waktu Server: [Jam WIB] WIB | [Jam WITA] WITA | [Jam WIT] WIT | [Jam London] GMT"*. (Gunakan library `intl` dan kalkulasi offset zona waktu).
- **Fitur Pencarian & Pemilihan:**
  - `TextField` untuk mencari nama quest.
  - `Dropdown` untuk filter kategori (All, Workout, Study, Appearance).
- **Daftar Quest (ListTile / Card):**
  - **Quest Biasa:** Checkbox mandiri (Self-report). Jika dicentang, `setState` tambah EXP dan Gold.
  - **Quest Sensor (Syarat Accelerometer):** Quest "Cardio Shake". Ketika diklik, buka pop-up. User harus mengocok HP 50 kali (menggunakan package `sensors_plus` accelerometer). Jika terpenuhi, quest selesai otomatis.
  - **Fitur LLM Hidden Quest Generator:** Tombol "SCAN HIDDEN DUNGEON" berdesain neon di bawah daftar quest harian. Memanggil Gemini Generative AI secara dinamis berdasarkan Rank dan EXP Hunter untuk menghasilkan narasi misi rahasia Solo Leveling maksimal 3 kalimat `[JUDUL MISI]`.
- **Floating Action Button (AI LLM & Notifikasi):**
  - **Tombol Chat (Kanan Bawah):** Membuka modal/halaman baru untuk *Chat AI*. Menggunakan Gemini API dengan *System Prompt*: "Kamu adalah asisten LevMax. Berikan jawaban singkat terkait tips pengembangan diri, olahraga, dan nutrisi."
  - **Tombol Alarm/Notifikasi (Kiri Bawah):** Memicu `flutter_local_notifications` untuk mengirim push notification lokal "Waktunya menyelesaikan quest harian Anda!".

#### Tab 2: LBS (Location Based Service)
- **Tampilan:** Menampilkan peta menggunakan `flutter_map` (gratis, tanpa API Key Google).
- **Fungsi:** 
  - Mendapatkan titik lokasi user saat ini (`geolocator`).
  - Terdapat 2 atau 3 *Marker* statis di sekitar area kampus (hardcoded lat/long). 
  - Tombol "Check-in Area". Jika jarak user dengan marker < 100 meter (hitung pakai `Geolocator.distanceBetween`), user mendapatkan bonus 50 Gold.

#### Tab 3: Mini Game (Syarat Sensor Gyroscope)
- **Nama Game:** Gyro Balancer.
- **Tampilan:** Sebuah bola (Container bentuk lingkaran) di dalam kotak pembatas.
- **Mekanik:** Menggunakan `sensors_plus` (Gyroscope event). User memiringkan layar untuk menggerakkan bola. 
- **Goal:** Menjaga bola berada di area tengah (zona hijau) selama 5 detik penuh. 
- **Reward:** Jika menang mendapat 100 Gold (Cukup batasi dengan state boolean `hasPlayedToday` = true).

#### Tab 4: Shop, Valuasi Valas Real-Time & Blockchain Web3
- **Toko Item:** Daftar Title prestise Hunter (*Shadow Monarch*, *Demon Slayer*, *Necromancer*, *Monarch King*) yang dibeli menggunakan Gold dan terekam on-chain.
- **Valuasi Kurs Valas Real-Time:** 
  - Card Hunter Exchange yang terhubung langsung ke API `https://open.er-api.com/v6/latest/USD`.
  - Mengonversi saldo Hunter ke IDR (Rupiah), USD (Dollar), dan EUR (Euro) secara live, disertai modal kalkulator konversi interaktif.
- **Public Blockchain Ethereum Sepolia Testnet:**
  - Setiap pembelian Title ditandatangani menggunakan Private Key pengguna melalui package `web3dart` dan disiarkan ke jaringan publik Ethereum Sepolia (Chain ID 11155111).
  - Menyisipkan data payload pembelian ke blockchain dan mengonsumsi Sepolia Gas Fee.
  - **Verifikasi 100% Full Online di Etherscan:** Tombol *"Lihat Bukti di Etherscan"* membuka transaksi asli publik di `https://sepolia.etherscan.io/tx/<hash>` dengan status Success. Seluruh pengecekan offline telah dihapus.
  - **Fitur Penunjang:** Tombol *"Salin Hash"*, Blockchain Ledger berstatus `SEPOLIA ONLINE`, dan tombol *"RESET"* inventori untuk kemudahan pengujian.

#### Tab 5: Profile (Kesan Matkul & Logout)
- **Visual:** Foto Profil (bisa pakai `image_picker` atau avatar default asset).
- **Statistik:** Ringkasan level, exp, gold.
- **Syarat Kesan & Saran Matkul:**
  - `TextField` multi-line dan tombol "Submit".
  - Saat disubmit, data di-push ke table `feedbacks` di Supabase.
- **Logout:** 
  - Tombol Logout akan membersihkan `sessionBox` di Hive.
  - Arahkan navigator kembali ke halaman Login (menggunakan `Navigator.pushAndRemoveUntil`).
