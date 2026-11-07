# 10. Fitur Profil Hunter, Kesan Pesan & Logout

---

## 1. Gambaran Singkat Fitur
Layar Status Profil (*Tab 5 / Profile*) berfungsi untuk menampilkan kartu identitas lengkap Hunter (Rank, EXP, Gold, Gelar terpasang), mengubah dan memotong foto avatar profil, mengirimkan formulir evaluasi kesan dan pesan perkuliahan ke database cloud, mengelola proteksi biometrik, serta memutuskan sesi aplikasi (*logout*) secara aman.

---

## 2. Konsep & Cara Pembuatannya
Fitur ini dirancang untuk memenuhi kelengkapan kriteria evaluasi dosen (Syarat No. 6: Profil, Saran/Kesan, dan Logout):
1. **Kartu Status Identitas Hunter:**
   - Menampilkan ringkasan status perkembangan karakter: Avatar, Username, Rank Badge (warna sesuai level F sampai S), persentase bar EXP menuju pangkat berikutnya, dan total quest yang telah dituntaskan sepanjang masa.
2. **Penggantian Foto Profil Interaktif (*Crop & S3 Upload*):**
   - Pengguna memilih foto dari galeri ponsel.
   - Sebelum diunggah, foto ditampilkan pada dialog penyesuaian khusus (`AvatarAdjustDialog`). Pengguna bisa mencubit (*pinch-to-zoom*), menggeser posisi (*pan*), dan memutar 90 derajat (*rotate*).
   - Tampilan kotak tersebut dirender menjadi gambar baru beresolusi tinggi (rasio 2.5x) menggunakan teknik `RenderRepaintBoundary`, lalu diunggah ke *Storage Bucket S3* Supabase secara asynchronous.
3. **Formulir Kesan & Pesan Mata Kuliah (*Course Feedback*):**
   - Disediakan form teks khusus bagi mahasiswa untuk menyampaikan kesan, pesan, dan saran terhadap mata kuliah Pemrograman Aplikasi Mobile.
   - Formulir terhubung langsung dengan tabel `feedbacks` di cloud Supabase dan dicadangkan secara lokal di Hive.
4. **Manajemen Keamanan Biometrik:**
   - Menyediakan saklar (*toggle switch*) untuk mengaktifkan atau menonaktifkan login cepat via sidik jari maupun mendaftarkan wajah baru (*enroll face*).
5. **Mekanisme Logout Aman (*Safe Logout*):**
   - Menghapus seluruh token autentikasi, sandi, dan data sesi dari Hive lokal tanpa menghapus catatan kepemilikan inventaris di server.
   - Menghapus tumpukan riwayat halaman (*routing stack*) dan mengembalikan pengguna ke layar login awal.

---

## 3. Alur Kerja dari Layar ke Backend (Step-by-Step)

### A. Alur Mengubah dan Mengunggah Foto Profil:
1. **Di Layar Pengguna (UI):** Pengguna menekan ikon kamera di atas foto profilnya.
2. **Pemilihan & Penyesuaian:** Pengguna memilih gambar dari galeri. Muncul pop-up `AvatarAdjustDialog`. Pengguna mengatur posisi wajah agar pas di tengah retikel 1:1 dan menekan tombol centang.
3. **Perekaman Piksel Gambar:** Widget mengambil tangkapan layar area crop menggunakan `RenderRepaintBoundary.toImage(pixelRatio: 2.5)` dan menyimpannya sebagai berkas PNG tajam di memori sementara.
4. **Pengunggahan ke Cloud Storage (Supabase S3):** Fungsi `SupabaseService.uploadAvatar()` mengunggah file biner ke cloud storage bucket Supabase dan menghasilkan URL publik.
5. **Pembaruan Database & Layar:** URL baru disimpan ke tabel `users` di Supabase dan `sessionBox` di Hive. Foto profil di seluruh tab aplikasi seketika berubah.

### B. Alur Pengiriman Pesan Kesan Mata Kuliah:
1. **Di Layar Pengguna (UI):** Pengguna mengetik ulasan atau kesan perkuliahan pada kolom textarea (misal: *"Mata kuliah ini sangat seru, menantang, dan kami banyak belajar integrasi sensor dan cloud..."*) lalu menekan tombol **"SUBMIT ACADEMIC FEEDBACK"**.
2. **Validasi Input:** Aplikasi memastikan kolom tidak kosong.
3. **Pengiriman ke Supabase:** Aplikasi memanggil fungsi `SupabaseService.submitFeedback(userId, message)`. Data dikirim ke tabel `feedbacks` dengan timestamp waktu server.
4. **Pencadangan di Hive:** Pesan dan waktu pengiriman juga disimpan ke Hive `sessionBox` sebagai cache offline.
5. **Pembaruan Status UI:** Tombol berubah menjadi status sukses hijau. Di bawah form, muncul kartu riwayat feedback bertuliskan *"PESAN TERSINKRONISASI KE SUPABASE"* lengkap dengan tanggal pengiriman.

### C. Alur Logout Aplikasi:
1. **Di Layar Pengguna (UI):** Pengguna menekan tombol merah **"SYSTEM LOGOUT"** di bagian paling bawah.
2. **Dialog Konfirmasi:** Muncul dialog peringatan merah: *"Apakah Anda yakin ingin memutuskan sinkronisasi terminal Monarch?"*.
3. **Pembersihan Sesi Lokal:** Jika pengguna memilih "LOGOUT", fungsi `HiveService.clearSession()` langsung menghapus kunci `isLoggedIn`, `userId`, `active_password`, dan token sesi dari Hive.
4. **Navigasi Bersih:** Aplikasi menjalankan perintah `Navigator.pushAndRemoveUntil` menuju `LoginScreen`. Seluruh riwayat halaman sebelumnya dibersihkan sehingga tombol back ponsel tidak bisa membuka kembali halaman beranda tanpa login ulang.

---

## 4. Peta Lokasi File Kode Terkait

| Nama File | Peran Utama di Aplikasi |
|:----------|:------------------------|
| `lib/screens/tabs/tab_profile.dart` | Antarmuka tab profil, penampil statistik Hunter, form kesan pesan, saklar biometrik, dan alur konfirmasi logout. |
| `lib/services/supabase_service.dart` | Fungsi pengiriman pesan (`submitFeedback`), pengambilan pesan terakhir (`getLatestFeedback`), dan upload avatar (`uploadAvatar`). |
| `lib/services/hive_service.dart` | Pengambilan dan pembersihan sesi lokal (`getSession`, `clearSession`, `saveFeedback`). |
| `lib/widgets/avatar_adjust_dialog.dart` | Dialog manipulasi foto (zoom, pan, rotasi) dan pemotongan kanvas via `RenderRepaintBoundary`. |
| `lib/widgets/avatar_image.dart` | Widget penampil avatar polimorfik (otomatis menyesuaikan apakah sumbernya URL jaringan, file lokal, atau fallback icon). |
| `lib/screens/auth/login_screen.dart` | Rute tujuan akhir setelah proses logout selesai dieksekusi. |

---

## 5. Contekan Kalimat Presentasi (Siap Baca)
> *"Pada tab terakhir yaitu Tab Status Profil, kami mengimplementasikan pemenuhan syarat tugas akhir terkait informasi profil pengguna, formulir saran dan kesan mata kuliah, serta fitur logout yang aman. Pengguna dapat memantau akumulasi seluruh quest yang pernah diselesaikan serta mengganti foto profil dengan fitur penyesuaian cropping 1 banding 1 dan rotasi yang kami bangun menggunakan `RenderRepaintBoundary` sebelum diunggah ke cloud storage Supabase. Selain itu, kami menyediakan **Formulir Kesan dan Pesan Akademik** yang tersinkronisasi langsung ke tabel `feedbacks` di remote database Supabase PostgreSQL. Terakhir, pada **Fitur Logout**, sistem menerapkan mekanisme pembersihan sesi lokal Hive secara menyeluruh dan mereset tumpukan navigasi rute aplikasi untuk menjamin privasi akun pengguna."*

