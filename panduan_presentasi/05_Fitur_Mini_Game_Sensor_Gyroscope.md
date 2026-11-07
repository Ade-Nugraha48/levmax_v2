# 05. Fitur Mini Game Sensor Gyroscope (Mana Balancer)

---

## 1. Gambaran Singkat Fitur
Fitur ini adalah permainan mini (*mini-game*) bertajuk **"Mana Core Balancer"** yang menguji fokus dan ketenangan tangan pengguna, di mana pemain harus menyeimbangkan bola energi mana agar tetap berada di lingkaran tengah arena dengan memiringkan badan ponsel fisik secara hati-hati selama 30 detik penuh.

---

## 2. Konsep & Cara Pembuatannya
Untuk menciptakan pengalaman bermain yang realistis dan ramah perangkat:
1. **Pemanfaatan Sensor Rotasi Fisik (*Gyroscope Hardware*):**
   - Menggunakan stream data sensor giroskop dari pustaka `sensors_plus`. Berbeda dengan akselerometer yang membaca tarikan dorongan, giroskop membaca kecepatan sudut perputaran (*angular velocity*) saat ponsel dimiringkan ke depan-belakang (*Pitch*) dan kiri-kanan (*Roll*).
2. **Fisika Pergerakan Bola di Arena 2D:**
   - Arena permainan berukuran $300\times300$ piksel, dengan titik tengah persis di koordinat $(150, 150)$. Bola energi memiliki ukuran $40\times40$ piksel.
   - Posisi bola $(X, Y)$ diperbarui berdasarkan sudut kemiringan sensor yang dikalikan dengan faktor sensitivitas tinggi ($22.0$) tanpa peredam (*frictionless*), sehingga bola terasa sangat lincah, licin, dan menantang untuk dikendalikan.
3. **Deteksi Jarak Euclidean ke Titik Tengah:**
   - Setiap saat, aplikasi menghitung jarak titik tengah bola ke pusat arena menggunakan rumus jarak Euclidean:
     $$\text{Jarak} = \sqrt{(X_{\text{bola}} - 150)^2 + (Y_{\text{bola}} - 150)^2}$$
   - Selama jarak bola $\le 35\text{ piksel}$, bola dinyatakan berada di zona aman (*Safe Target Zone*). Jika jarak melebihi 35 piksel, misi langsung dinyatakan **Gagal (*Protocol Failed*)**.
4. **Optimasi Performa Ringan (*Memory-Safe Throttling*):**
   - Karena sensor giroskop mengirim data ratusan kali per detik yang bisa membuat ponsel cepat panas atau lag, aplikasi membatasi pembaruan antarmuka (*throttling*) pada interval **30 milidetik** (setara $\sim 33\text{ FPS}$). Ini menjaga konsumsi baterai tetap hemat dan performa stabil bahkan di ponsel berspesifikasi rendah.
5. **Aturan Main & Batas Harian:**
   - Pemain harus bertahan selama **30 detik countdown**.
   - Hadiah kemenangan adalah **+50 Gold** dan hanya dapat diklaim **1 kali per hari** berdasarkan tanggal server WIB (direset setiap jam 00:00 tengah malam).

---

## 3. Alur Kerja dari Layar ke Backend (Step-by-Step)

### A. Alur Memulai Permainan:
1. **Di Layar Pengguna (UI):** Pengguna membuka Tab 3 ("MANA") pada menu navigasi bawah. Layar menampilkan arena lingkaran bercahaya neon ungu dengan bola cyan di tengah.
2. **Pengecekan Kuota Harian:** Aplikasi mengecek `HiveService.getGameRewardDate()`. Jika tanggal hari ini sudah pernah diklaim, tombol "IN MEMORY SAFE MODE" dinonaktifkan dengan status *Protocol Completed Today*.
3. **Memulai Sesi:** Pengguna menekan tombol **"START STABILIZATION"**. Timer survival 30 detik mulai berjalan mundur, dan status permainan berubah menjadi `isPlaying = true`.

### B. Alur Interaksi Sensor & Fisika Bola:
1. **Miringkan Ponsel:** Pengguna memiringkan ponsel ke kiri, kanan, atas, atau bawah.
2. **Kalkulasi Posisi:** Sensor giroskop menangkap perputaran sudut dan menggeser koordinat `ballX` dan `ballY` secara instan.
3. **Pengecekan Lingkaran Aman:** Fungsi `_checkTargetZone()` mengevaluasi jarak bola.
   - Jika bola tetap di tengah: Cincin reaktor tetap memancarkan cahaya hijau/cyan stabil.
   - Jika ponsel dimiringkan terlalu tajam sehingga bola terlempar keluar dari radius 35 piksel: Permainan seketika terhenti, timer dibatalkan, dan muncul dialog merah *"CORE INSTABILITY // PROTOCOL FAILED"*. Pemain dipersilakan mencoba ulang kapan saja.

### C. Alur Kemenangan & Pencatatan Hadiah:
1. **Bertahan Hingga 0 Detik:** Jika pemain berhasil menjaga bola di dalam zona tengah sampai timer 30 detik habis, fungsi `_handleGameVictory()` otomatis dieksekusi.
2. **Kunci Tanggal Server WIB:** Tanggal hari ini (format `YYYY-MM-DD` waktu WIB) dicatat ke dalam Hive agar pemain tidak bisa mengulang klaim hadiah koin di hari yang sama.
3. **Pemberian Hadiah:**
   - Saldo koin bertambah **+50 Gold** secara instan di memori Hive `sessionBox`.
   - Data saldo baru disinkronkan ke cloud Supabase melalui `SupabaseService.updateUserStats()`.
4. **Respon Visual di Layar:** Muncul dialog kemenangan Solo Leveling berwarna emas dengan partikel cahaya *"STABILIZATION SUCCESSFUL! +50 GOLD SECURED"*, dan saldo Gold di bar atas langsung bertambah.

---

## 4. Peta Lokasi File Kode Terkait

| Nama File | Peran Utama di Aplikasi |
|:----------|:------------------------|
| `lib/screens/tabs/tab_game.dart` | Antarmuka arena visual 300x300, pembaca stream sensor `gyroscopeEventStream()`, kalkulasi jarak Euclidean, throttling 30ms, dan aturan survival 30 detik. |
| `lib/services/hive_service.dart` | Menyimpan tanggal klaim hadiah harian (`saveGameRewardDate`, `getGameRewardDate`) dan saldo Gold. |
| `lib/services/supabase_service.dart` | Menyinkronkan saldo Gold hasil kemenangan game ke tabel `users` di database cloud. |
| `lib/utils/constants.dart` | Konstanta durasi game (`gyroHoldSeconds`) dan palet warna neon mana reaktor. |

---

## 5. Contekan Kalimat Presentasi (Siap Baca)
> *"Sebagai pemenuhan syarat sensor fisik kedua sekaligus syarat mini-game interaktif, kami mengembangkan fitur **Mini Game Mana Core Balancer** berbasis **sensor Gyroscope fisik bawaan ponsel**. Mini-game ini menuntut pemain menjaga keseimbangan bola energi mana pada arena 2 dimensi menggunakan orientasi rotasi kemiringan ponsel (*pitch dan roll*). Sistem memvalidasi koordinat bola secara real-time dengan menghitung **jarak Euclidean** ke pusat arena beradius aman 35 piksel. Agar konsumsi daya baterai efisien dan lancar pada perangkat berspesifikasi standar, kami menerapkan **pembatasan pembaruan (*throttling*) pada interval 30 milidetik**. Pemain yang sukses bertahan menyeimbangkan bola selama 30 detik penuh dianugerahi hadiah 50 Gold dengan sistem penguncian tanggal server WIB agar hanya dapat diklaim satu kali per hari."*

