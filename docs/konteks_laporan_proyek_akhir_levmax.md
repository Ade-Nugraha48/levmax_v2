# PANDUAN DAN KONTEKS PENYUSUNAN LAPORAN PROYEK AKHIR LEVMAX

Dokumen ini disusun sebagai acuan kerja bersama (*shared context*) antara **Ade Nugraha** dan **Muhammad Ikram Mughni** dalam menyusun Laporan Proyek Akhir mata kuliah **Pemrograman Aplikasi Mobile**. Seluruh isi laporan harus berlandaskan fakta teknis dari basis kode (*source code*) aplikasi **LevMax** dan mematuhi format baku laporan akademik Program Studi S1 Sistem Informasi, UPN "Veteran" Yogyakarta.

---

## 1. IDENTITAS PROYEK & KELOMPOK

* **Judul Laporan:** 
  > LAPORAN PROYEK AKHIR PEMBUATAN APLIKASI MOBILE “LEVMAX” SEBAGAI PLATFORM GAMIFIED HABIT TRACKER DAN SELF-IMPROVEMENT
* **Aplikasi:** LevMax (*The Hunter Awakening System*)
* **Tim Penyusun:**
  1. **Ade Nugraha** — NIM: **124240190**
  2. **Muhammad Ikram Mughni** — NIM: **124240191**
* **Program Studi:** S1 Sistem Informasi
* **Jurusan / Fakultas:** Jurusan Informatika, Fakultas Teknik Industri
* **Perguruan Tinggi:** Universitas Pembangunan Nasional “Veteran” Yogyakarta
* **Tahun Akademik:** 2026
* **Dosen Pengampu:** Bagus Muhammad Akbar, S.ST., M.Kom. (NIP. 20001130014287)
* **Repositori GitHub:** [https://github.com/Ade-Nugraha48/levmax_v2](https://github.com/Ade-Nugraha48/levmax_v2)

---

## 2. RINGKASAN KONSEP & FITUR APLIKASI (LEVMAX)

LevMax adalah aplikasi pelacak kebiasaan (*habit tracker*) berbasis gamifikasi yang mengadaptasi sistem perkembangan karakter RPG terinspirasi dari fiksi *Solo Leveling* (*Shadow Monarch / Hunter System*). Aplikasi mengubah rutinitas nyata pengguna (olahraga fisik, fokus belajar, dan perawatan diri) menjadi misi harian yang memiliki timbal balik psikologis terukur.

### Mekanisme Game (*Game Mechanics*):
1. **Sistem Rank:** F (0–99 EXP) $\rightarrow$ E (100–299 EXP) $\rightarrow$ D (300–599 EXP) $\rightarrow$ C (600–999 EXP) $\rightarrow$ B (1000–1499 EXP) $\rightarrow$ A (1500–2499 EXP) $\rightarrow$ S (2500+ EXP).
2. **Sistem HP & Penalti:** Setiap pengguna dibekali maksimal 3 HP. Jika pengguna gagal menyelesaikan minimal 3 quest harian dalam satu hari, HP berkurang 1 pada login hari berikutnya. Apabila HP habis (0), diterapkan penalti penurunan 1 tingkatan *Rank* dan EXP direset ke batas bawah rank tersebut.
3. **Ekonomi Hunter (Gold):** Diperoleh dari penyelesaian quest dan mini-game. Digunakan untuk membeli item gelar (*Title/Border*) di halaman Shop.
4. **Verifikasi Sensor Nyata:** Quest kardio diverifikasi menggunakan sensor *accelerometer* (deteksi 50 guncangan fisik), dan mini-game melatih fokus menggunakan sensor *gyroscope* (keseimbangan bola mana core selama 5 detik).
5. **Eksplorasi Dunia Nyata (LBS):** Menampilkan peta OpenStreetMap dengan penanda titik *dungeon portal* di area kampus, yang dapat diklaim jika jarak fisik pengguna $< 100$ meter.

---

## 3. MATRIKS PEMENUHAN 13 SYARAT TUGAS AKHIR

Semua anggota tim wajib memahami pemetaan 13 kriteria evaluasi dosen ke dalam file kode program berikut:

| No | Syarat & Ketentuan Dosen | Status | Fitur di LevMax | Lokasi File Implementasi |
|:--:|:-------------------------|:------:|:----------------|:-------------------------|
| **1** | Konsep proyek akhir yang matang | Terpenuhi | RPG Hunter Awakening Habit Tracker (Rank F-S, EXP, HP, Gold, Daily Quests). | `lib/utils/constants.dart`, seluruh `lib/` |
| **2** | Login enkripsi (Non-Firebase) & sesi | Terpenuhi | Hashing SHA-256 pada password client-side, verifikasi Supabase, sesi lokal Hive. | `lib/services/hash_service.dart`<br>`lib/screens/auth/login_screen.dart`<br>`lib/services/supabase_service.dart` |
| **3** | Login Biometrik | Terpenuhi | Pemindaian sidik jari (*fingerprint*) via `local_auth` untuk bypass login. | `lib/screens/auth/login_screen.dart` |
| **4** | Koneksi Database Lokal & Online | Terpenuhi | • **Lokal:** Hive (`sessionBox`, `blockchainBox`, `questBox`).<br>• **Online:** Supabase PostgreSQL (`users`, `feedbacks`). | `lib/main.dart`<br>`lib/services/hive_service.dart`<br>`lib/services/supabase_service.dart` |
| **5** | Web Service/API & LBS sesuai tema | Terpenuhi | • **API:** Supabase REST, Gemini AI, Open Exchange Rates.<br>• **LBS:** OpenStreetMap via `flutter_map` + `geolocator` (klaim portal radius 100m). | `lib/screens/tabs/tab_map.dart`<br>`lib/services/gemini_service.dart` |
| **6** | Bottom Navigation (Profil, Saran/Kesan, Logout) | Terpenuhi | 5 Tab Menu (IndexedStack). Tab Profile berisi info rank, avatar, form pesan matkul, tombol logout. | `lib/screens/main_navigation.dart`<br>`lib/screens/tabs/tab_profile.dart` |
| **7** | Konversi Mata Uang (min. 3) & Waktu (WIB, WITA, WIT, London) | Terpenuhi | • **Waktu:** Jam server simultan WIB, WITA, WIT, London (GMT).<br>• **Uang:** Live API kurs Gold ke IDR, USD, EUR + kalkulator konversi. | `lib/screens/tabs/tab_home.dart`<br>`lib/screens/tabs/tab_shop.dart` |
| **8** | Minimal 2 Sensor Lanjutan | Terpenuhi | 1. **Accelerometer:** Quest Cardio Shake (deteksi guncangan 50x).<br>2. **Gyroscope:** Mini game Mana Core Balancer. | `lib/screens/features/quest_sensor.dart`<br>`lib/screens/tabs/tab_game.dart` |
| **9** | Fitur AI / LLM sesuai konsep | Terpenuhi | "Hunter AI Guide" untuk panduan nutrisi & kebugaran serta generator hidden quest via Gemini API. | `lib/services/gemini_service.dart`<br>`lib/screens/features/chat_ai_screen.dart` |
| **10** | Mini Game sederhana terkait konsep | Terpenuhi | "Gyro Balancer" mengendalikan bola mana ke titik tengah menggunakan sudut rotasi ponsel. | `lib/screens/tabs/tab_game.dart` |
| **11** | Fasilitas Pencarian dan Pemilihan | Terpenuhi | Search bar live query judul quest & dropdown filter kategori quest (Workout, Cardio, Appearance, Study). | `lib/screens/tabs/tab_home.dart` |
| **12** | Notifikasi Berbasis Mobile | Terpenuhi | Peringatan lokal pengingat quest harian via `flutter_local_notifications` dan alarm manager. | `lib/services/notif_service.dart`<br>`lib/services/alarm_service.dart` |
| **13** | Blockchain Sederhana | Terpenuhi | Buku besar (*ledger*) transaksi belanja title dengan hash berantai SHA-256 (`prev_hash` + data blok) di Hive. | `lib/services/hash_service.dart`<br>`lib/screens/tabs/tab_shop.dart` |

---

## 4. PEDOMAN GAYA PENULISAN AKADEMIS (*HUMAN-WRITTEN STYLE*)

Agar laporan diterima dengan baik oleh dosen penguji dan terbebas dari deteksi teks kecerdasan buatan (*AI-generated content*), ikuti aturan ketat berikut:

### A. Kaidah Bahasa
1. Gunakan bahasa Indonesia formal dan baku sesuai Pedoman Umum Ejaan Bahasa Indonesia (PUEBI).
2. Buat struktur kalimat bervariasi antara kalimat aktif dan pasif secara wajar, selayaknya tulisan ilmiah mahasiswa teknik.
3. Jelaskan logika program secara kronologis dan kausal (mengapa suatu fungsi dipanggil, data apa yang dikirim, dan bagaimana antarmuka memperbarui statusnya).

### B. Daftar Frasa yang DILARANG (Klise AI):
* ❌ *"Penting untuk diingat..."* / *"Penting untuk dicatat bahwa..."*
* ❌ *"Secara keseluruhan, sistem ini..."*
* ❌ *"Dapat disimpulkan bahwa..."*
* ❌ *"Dalam era digital yang serba cepat ini..."*
* ❌ *"Aplikasi ini menawarkan solusi komprehensif..."*
* ❌ *"Menghadirkan pengalaman pengguna yang mulus dan intuitif..."*

### C. Integritas Kode Sumber
* **Jangan mengarang fungsi atau library yang tidak ada di dalam folder proyek `lib/`**.
* Seluruh contoh listing kode dan variabel harus diambil persis dari file sumber yang ada di proyek.

---

## 5. STRUKTUR LENGKAP ISI LAPORAN

### BAGIAN AWAL
1. Halaman Sampul (Cover)
2. Halaman Pengesahan (Tanda tangan Dosen Pengampu)
3. Kata Pengantar
4. Daftar Isi
5. Daftar Tabel
6. Daftar Gambar
7. Daftar Listing *(Daftar seluruh potongan kode program)*

---

### BAB I PENDAHULUAN
* **1.1 Latar Belakang:** Fenomena prokrastinasi, kelemahan to-do list konvensional, efektivitas gamifikasi RPG (*Solo Leveling*), serta peluang integrasi sensor gerak, GPS, biometrik, dan AI pada perangkat bergerak.
* **1.2 Rumusan Masalah:** 5 butir pertanyaan penelitian/pengembangan sistem.
* **1.3 Batasan Masalah:** Batasan teknis (target Android API 21+, Flutter Dart, dual DB Hive & Supabase, 2 sensor fisik, OSM LBS radius 100m, live kurs 3 mata uang, waktu 4 zona, dan ledger SHA-256).
* **1.4 Tujuan Proyek:** Sasaran konkret yang dicapai aplikasi.
* **1.5 Manfaat Proyek:** Manfaat bagi pengguna, mahasiswa/pengembang, dan lingkungan akademik.

---

### BAB II TINJAUAN LITERATUR
* **2.1 Aplikasi Mobile:** Karakteristik sistem operasi seluler, arsitektur aplikasi native vs cross-platform.
* **2.2 Flutter Framework & Bahasa Pemrograman Dart:** Konsep deklaratif UI, *reactive widget tree*, manajemen state `StatefulWidget`, serta keunggulan kompilasi AOT (*Ahead-of-Time*).
* **2.3 Gamifikasi dalam Produktivitas (*Gamified Self-Improvement*):** Teori motivasi internal/eksternal, siklus *reward-penalty*, dan implementasi RPG pada pembentukan kebiasaan harian.
* **2.4 Sensor Seluler dan Layanan Berbasis Lokasi (*LBS*):** Cara kerja sensor akselerometer (sumbu $x, y, z$), giroskop (kecepatan sudut rotasi), dan geolokasi GPS berbasis lintang/bujur pada formula *Haversine*.
* **2.5 Integritas Data Menggunakan Kriptografi Hashing (*SHA-256 & Blockchain Sederhana*):** Fungsi hash satu arah (*one-way hash function*), konsep blok berantai (*hash chaining*), dan buku besar terdistribusi lokal.

---

### BAB III PERANCANGAN PROGRAM
* **3.1 Analisis Kebutuhan:**
  * **3.1.1 Kebutuhan Fungsional:** Daftar lengkap fitur sistem (Autentikasi, Biometrik, Daily Quests, Cardio Shake, Gyro Balancer, LBS Portal, Chatbot AI, Toko & Ledger, Multi-waktu & Kurs, Form Saran).
  * **3.1.2 Kebutuhan Non-Fungsional:** *Tabel 1 (Performance, Security, Reliability, Usability, Memory, Availability, Maintainability).*
* **3.2 Desain Sistem:**
  * **3.2.1 Use Case Diagram:** Aktor Hunter/Pengguna terhadap seluruh use case sistem beserta relasi `<<include>>` dan `<<extend>>`.
  * **3.2.2 Activity Diagram:** 6 diagram aktivitas alur utama (Login & Biometrik, Pengerjaan Quest Sensor Shake, Mini-Game Gyroscope, Navigasi Peta LBS, Percakapan Hunter AI, Pembelian Shop & Pencatatan Ledger).
  * **3.2.3 Class Diagram:** Struktur model data (`UserModel`, `QuestModel`, `AlarmModel`, `AIPersonaModel`) serta relasinya dengan service (`HiveService`, `SupabaseService`, `HashService`, `GeminiService`).
  * **3.2.4 Sequence Diagram:** 5 diagram sekuensial interaksi objek (Otentikasi & Sesi, Eksekusi Sensor Accelerometer & Update EXP, Validasi Jarak GPS LBS, Request LLM Gemini AI, Penandatanganan Hash Transaksi Toko).

---

### BAB IV IMPLEMENTASI PROGRAM (KODE & ANALISIS)
* **4.1 Lingkungan Pengembangan:** *Tabel 2 (VS Code, Android Studio, Flutter SDK 3.13+, Gradle, Perangkat Fisik).*
* **4.2 Technology Resources:** *Tabel 3 (Daftar seluruh paket dependencies pubspec.yaml beserta fungsi teknisnya).*
* **4.3 Struktur Folder dan File Program:** Diagram pohon direktori `lib/`.
* **4.4 Inisialisasi Database dan Model Data:**
  * *Listing 1:* Inisialisasi Hive Box & Supabase pada `main.dart`.
  * *Listing 2:* Deklarasi Model Data Quest dan Atribut Hunter pada `quest_model.dart`.
  * *Listing 3:* Operasi CRUD Lokal menggunakan Hive pada `hive_service.dart`.
* **4.5 Integrasi Layanan Eksternal & API:**
  * *Listing 4:* Integrasi Google Gemini Generative AI pada `gemini_service.dart`.
  * *Listing 5:* Integrasi OpenStreetMap dan Geolocator pada `tab_map.dart`.
  * *Listing 6:* Integrasi Cloud Database PostgreSQL pada `supabase_service.dart`.
* **4.6 Implementasi Fitur Utama (Source Code & Penjelasan):**
  * *Listing 7:* Hashing Password Klien SHA-256 (`hash_service.dart` & `login_screen.dart`).
  * *Listing 8:* Login Biometrik Fingerprint (`login_screen.dart`).
  * *Listing 9:* Perhitungan Jam Multi-Zona WIB, WITA, WIT, GMT (`tab_home.dart`).
  * *Listing 10:* Live API Kurs Forex & Valuasi Gold (`tab_shop.dart`).
  * *Listing 11:* Live Search & Filter Dropdown Quest (`tab_home.dart`).
  * *Listing 12:* Listener Accelerometer Sensor Cardio Shake (`quest_sensor.dart`).
  * *Listing 13:* Koordinat Gyroscope Sensor Mana Balancer Game (`tab_game.dart`).
  * *Listing 14:* Algoritma Hash Chaining Ledger Transaksi Toko (`tab_shop.dart`).
  * *Listing 15:* Penjadwalan Push Notifikasi Lokal (`notif_service.dart`).
  * *Listing 16:* Form Input Kesan & Pesan Mata Kuliah ke Supabase (`tab_profile.dart`).
* **4.7 Output Program:**
  * Screenshot antarmuka aplikasi Output 1 s.d. Output 16 (Login, Home, Sensor, Peta, Shop, Profil, dll).

---

### BAB V PENGUJIAN PERANGKAT LUNAK DAN EVALUASI
* **5.1 Jenis Pengujian:** Pengujian *Black-Box Testing* untuk verifikasi input dan output fungsionalitas antarmuka.
* **5.2 Ruang Lingkup Pengujian:** Menguji pemenuhan seluruh 13 kriteria mata kuliah.
* **5.3 User Acceptance Testing (UAT):**
  * *Tabel 4. Skenario Pengujian UAT (16+ skenario uji mendetail: Nomor, Modul, Langkah Pengujian, Data Input, Hasil yang Diharapkan, Status Keberhasilan).*
* **5.4 Hasil Pengujian:**
  * *Tabel 5. Rekapitulasi Pengujian per Modul (Modul, Kasus Uji, Berhasil, Gagal, Tingkat Keberhasilan 100%).*
* **5.5 Evaluasi Hasil Pengujian:** Analisis respon perangkat keras sensor, stabilitas operasi luring-daring, dan performa query database.

---

### BAB VI KESIMPULAN DAN SARAN
* **6.1 Kesimpulan:** Rangkuman keberhasilan realisasi aplikasi LevMax sesuai 13 syarat proyek akhir.
* **6.2 Saran:** Rencana pengembangan lanjutan (konektivitas jam pintar/smartwatch, multiplayer raid, dan machine vision untuk workout).

---

### BAGIAN AKHIR
* **DAFTAR PUSTAKA** (Format APA 7th Edition)
* **LAMPIRAN** (Tautan repositori GitHub proyek)

---

## 6. CARA PENGGUNAAN FILE INI
Simpan dan gunakan dokumen ini sebagai referensi utama saat berkolaborasi. Pengerjaan draf laporan dilakukan **secara bertahap bab per bab** agar setiap bab memiliki kedalaman analisis kode yang akurat dan memenuhi standar penulisan ilmiah.
