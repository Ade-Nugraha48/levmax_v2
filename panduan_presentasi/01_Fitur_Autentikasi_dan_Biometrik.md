# 01. Fitur Autentikasi Enkripsi & Login Biometrik

---

## 1. Gambaran Singkat Fitur
Fitur ini berfungsi untuk mengamankan akun pengguna saat mendaftar dan masuk ke aplikasi, dengan memberikan perlindungan kata sandi yang diacak menggunakan sandi kriptografi SHA-256 di perangkat pengguna, serta menyediakan jalan pintas masuk instan menggunakan sidik jari (*fingerprint*) maupun pemindaian wajah (*face recognition*).

---

## 2. Konsep & Cara Pembuatannya
Untuk membangun sistem autentikasi yang aman tanpa bergantung pada layanan Firebase:
1. **Enkripsi Sisi Klien (*Client-Side Hashing*):**
   - Aplikasi tidak pernah mengirim kata sandi polos (*plain text*) melalui jaringan internet.
   - Sebelum dikirim ke database Supabase, kata sandi diubah terlebih dahulu menjadi deretan 64 karakter acak menggunakan algoritma **SHA-256**. Jadi, siapapun yang mengintip jaringan atau bahkan pemilik database tidak akan bisa mengetahui kata sandi asli pengguna.
2. **Manajemen Sesi Lokal (*Hive Session*):**
   - Setelah server menyatakan kata sandi cocok, identitas pengguna (ID, username, Rank, EXP, Gold, dan sisa HP) disimpan ke dalam penyimpanan lokal **Hive (`sessionBox`)**.
   - Dengan begini, saat pengguna menutup aplikasi dan membukanya kembali, aplikasi langsung tahu siapa yang sedang login tanpa perlu mengetik ulang sandi.
3. **Sensor Biometrik Sidik Jari (*Fingerprint*):**
   - Memanfaatkan modul perangkat keras bawaan ponsel melalui pustaka `local_auth`. Ponsel memverifikasi sidik jari secara langsung pada tingkat sistem operasi Android/iOS.
4. **Sensor Biometrik Wajah (*Face Recognition* Murni Dart):**
   - Dibuat menggunakan kamera depan ponsel. Kamera mengambil gambar wajah, memotong area tengah, mengubahnya menjadi hitam-putih (*grayscale*), menstandarkan pencahayaan (*Z-Score Normalization*), lalu mencocokkan pola garis wajah (*Difference Hash*) dengan data wajah yang didaftarkan di Hive.

---

## 3. Alur Kerja dari Layar ke Backend (Step-by-Step)

### A. Alur Pendaftaran Akun Baru (Register):
1. **Di Layar Pengguna (UI):** Pengguna memasukkan username, kata sandi (minimal 6 karakter), konfirmasi kata sandi, dan memilih foto profil dari galeri (opsional), lalu menekan tombol **"AWAKEN AS HUNTER"**.
2. **Pemrosesan di Balik Layar:** Aplikasi memeriksa apakah data sudah lengkap dan konfirmasi sandi cocok. Jika valid, kata sandi langsung di-hash menggunakan fungsi `HashService.hashSha256(password)`.
3. **Penyimpanan ke Database (Supabase Cloud):** Aplikasi menghubungi Supabase melalui `SupabaseService.register()` dan menyisipkan baris data baru ke tabel `users` dengan nilai awal: Rank 'F', EXP 0, Gold 0, dan HP 3. Jika pengguna memilih foto profil, berkas diunggah ke *storage bucket* Supabase.
4. **Kembali ke Layar Pengguna:** Muncul pemberitahuan sukses (SnackBar berwarna ungu khas Solo Leveling) dan layar otomatis berpindah kembali ke halaman Login.

### B. Alur Masuk Manual (Login):
1. **Di Layar Pengguna (UI):** Pengguna mengetik username dan sandi, lalu menekan tombol **"AUTHORIZE LOGIN"**.
2. **Pemrosesan di Balik Layar:** Aplikasi kembali mengubah kata sandi input menjadi hash SHA-256.
3. **Pengecekan ke Database (Supabase Cloud):** Aplikasi mengecek ke tabel `users` di Supabase: *"Apakah ada baris data yang username dan password_hash-nya sama persis?"*.
4. **Penyimpanan Sesi & Pengembalian ke Layar:** 
   - Jika cocok: Data profil Hunter ditarik dari Supabase, disimpan ke dalam Hive lokal (`sessionBox`), dan pengguna langsung dialihkan ke Halaman Utama (*Main Navigation*).
   - Jika salah: Muncul pesan error berwarna merah bahwa kredensial tidak valid.

### C. Alur Masuk Cepat Biometrik (Sidik Jari / Wajah):
1. **Di Layar Pengguna (UI):** Pengguna menekan ikon sidik jari atau tombol pemindai wajah di bawah form login.
2. **Pengecekan Sesi Lokal:** Aplikasi mengecek ke Hive apakah pengguna sudah pernah mengaktifkan fitur biometrik dan mendaftarkan wajahnya.
3. **Verifikasi Sensor Fisik:**
   - **Untuk Sidik Jari:** Muncul pop-up resmi dari sistem Android yang meminta jari ditempelkan ke sensor.
   - **Untuk Wajah:** Muncul dialog animasi HUD kamera depan Solo Leveling. Kamera mengambil foto wajah dan algoritma `FaceRecognitionService` menghitung tingkat kemiripan fitur wajah dengan basis data di Hive.
4. **Login Otomatis:** Begitu sensor menyatakan identitas cocok (skor kemiripan wajah $\ge 70\%$), kredensial yang tersimpan di Hive langsung diautentikasi otomatis ke Supabase dan pengguna langsung masuk tanpa mengetik satu huruf pun.

---

## 4. Peta Lokasi File Kode Terkait

| Nama File | Peran Utama di Aplikasi |
|:----------|:------------------------|
| `lib/screens/auth/login_screen.dart` | Antarmuka halaman login, pengontrol form, pemicu login biometrik fingerprint dan tombol pemindai wajah. |
| `lib/screens/auth/register_screen.dart` | Antarmuka pembuatan akun Hunter, validasi form, pemilihan foto avatar, dan pemanggilan register Supabase. |
| `lib/services/hash_service.dart` | Fungsi matematika enkripsi SHA-256 client-side (`hashSha256`). |
| `lib/services/supabase_service.dart` | Fungsi penghubung cloud Supabase (`login`, `register`, `uploadAvatar`). |
| `lib/services/hive_service.dart` | Fungsi penyimpanan sesi lokal (`saveSession`, `getSession`, `saveBiometricCredentials`). |
| `lib/services/face_recognition_service.dart` | Algoritma pemrosesan citra wajah murni (Normalisasi Z-Score, dHash, Cosine Similarity & Hamming Distance). |
| `lib/widgets/face_scan_dialog.dart` | Widget pop-up kamera depan real-time dengan retikel pemindai wajah bernuansa Solo Leveling. |

---

## 5. Contekan Kalimat Presentasi (Siap Baca)
> *"Pada fitur autentikasi, kami menerapkan standar keamanan **non-Firebase** dengan enkripsi sisi klien (*client-side*). Setiap kali pengguna mendaftar atau login, kata sandi diacak terlebih dahulu menggunakan algoritma **SHA-256** sebelum dikirim ke remote database Supabase PostgreSQL, sehingga kata sandi asli pengguna tidak pernah bocor di jaringan. Setelah login berhasil, status sesi disimpan di database lokal **Hive** agar aplikasi dapat langsung dibuka secara offline. Selain login manual, kami juga melengkapinya dengan **dua jenis autentikasi biometrik**: pertama, pemindai sidik jari menggunakan sensor bawaan perangkat via pustaka `local_auth`; dan kedua, pemindai wajah (*face recognition*) real-time melalui kamera depan yang kami bangun secara mandiri menggunakan algoritma normalisasi pencahayaan Z-Score dan Difference Hash dengan batas toleransi kecocokan 70%."*

