# 04. Fitur Sensor Kardio Accelerometer (Cardio Shake)

---

## 1. Gambaran Singkat Fitur
Fitur ini berfungsi untuk memverifikasi latihan kardio lari atau jalan cepat pengguna di dunia nyata, dengan memanfaatkan sensor gerak fisik akselerometer di dalam ponsel untuk mendeteksi dan menghitung 50 kali guncangan langkah fisik hingga misi dinyatakan tuntas.

---

## 2. Konsep & Cara Pembuatannya
Untuk memastikan pengguna benar-benar bergerak dan tidak memanipulasi aplikasi hanya dengan menyentuh layar:
1. **Pemanfaatan Sensor Gerak Fisik (*Accelerometer Hardware*):**
   - Menggunakan pustaka `sensors_plus` yang membaca pergerakan akselerasi ponsel pada 3 sumbu ruang: sumbu X (kiri-kanan), sumbu Y (atas-bawah), dan sumbu Z (maju-mundur).
2. **Formula Magnitudo Akselerasi & G-Force:**
   - Aplikasi menghitung gaya dorong gabungan menggunakan rumus pythagoras 3 dimensi:
     $$\text{Magnitudo} = \sqrt{X^2 + Y^2 + Z^2}$$
   - Nilai gaya gravitasi bumi normal adalah sekitar $9.8\text{ m/s}^2$ (setara 1.0 G-Force).
3. **Filter Ambang Batas (*Threshold*) & Pencegah Dobel Hitung (*Debounce Cooldown*):**
   - Agar getaran kecil (misal getaran meja atau mobil lewat) tidak terhitung sebagai lari, ditetapkan ambang batas: selisih akselerasi ($\Delta$) harus melebihi $15\text{ m/s}^2$ di atas gravitasi normal.
   - Diterapkan jeda pengaman (*debounce*) sebesar **320 milidetik**. Artinya, dalam kurun waktu 0,3 detik, ponsel hanya akan menghitung 1 kali ayunan langkah lari, sehingga tidak terjadi hitungan beruntun (*spamming*).
4. **Klasifikasi Intensitas Real-Time:**
   - Aplikasi memetakan ritme gerak pengguna menjadi status visual HUD yang keren: **STANDBY** (diam), **OPTIMAL** (ritme stabil), **MAKSIMAL** (sprint kencang di atas 2.4 G), hingga **MENURUN** (jika pemain berhenti lebih dari 2.5 detik).

---

## 3. Alur Kerja dari Layar ke Backend (Step-by-Step)

### A. Alur Memulai Latihan Kardio:
1. **Di Layar Pengguna (UI):** Pengguna menekan kartu misi "Cardio Distance Run" di beranda.
2. **Inisialisasi Sensor & Timer:** Layar `QuestSensorScreen` terbuka. Di balik layar, fungsi `_startAccelerometerSubscription()` langsung membuka saluran (*stream*) data sensor, dan timer hitung mundur 3 menit mulai berdetik.
3. **Gerakan Pengguna:** Pengguna mengantongi ponsel dan mulai berlari atau mengayunkan ponsel.

### B. Alur Pemrosesan Guncangan Langkah:
1. **Pembacaan Sensor:** Setiap kali ada sentakan ayunan kaki, sensor akselerometer mengirimkan koordinat $(X, Y, Z)$ baru.
2. **Validasi Ambang Batas:** Aplikasi mengecek:
   - *"Apakah $(\text{Magnitudo} - 9.8) > 15\text{ m/s}^2$?"*
   - *"Apakah waktu guncangan ini berjarak lebih dari 320ms dari guncangan sebelumnya?"*
3. **Peningkatan Angka:** Jika kedua syarat terpenuhi, variabel `_shakeCount` bertambah 1 poin (misal dari 14 ke 15) dan persentase sinkronisasi bertambah secara dinamis menuju target 50.
4. **Visualisasi di Layar:** Angka counter di tengah layar membesar dengan warna cyan menyala, bar persentase memanjang, dan grafik gelombang frekuensi bergerak aktif.

### C. Alur Penyelesaian Misi & Klaim Hadiah:
1. **Pencapaian Target:** Saat hitungan menyentuh tepat **50 guncangan**, fungsi `_handleProtocolComplete()` langsung dipanggil.
2. **Penutupan Sensor Aman:** Aliran data sensor akselerometer dan timer hitung mundur segera dihentikan (`subscription.cancel()`) untuk mencegah kebocoran memori (*memory leak*) dan menghemat baterai.
3. **Penyimpanan Reward (Dual-Database):**
   - Poin **+20 EXP** dan **+15 Gold** langsung ditambahkan ke sesi lokal Hive.
   - Status penyelesaian quest dicatat ke dalam `questBox` Hive dengan kunci `userId_cardio` dan tanggal hari ini.
   - Jika pengguna terhubung online, data statistik baru langsung dikirim ke tabel `users` dan `user_quests` di Supabase.
4. **Kembali ke Beranda:** Muncul notifikasi suara dan SnackBar hijau neon *"Protocol Complete! +20 EXP & +15 Gold"*, lalu layar otomatis kembali ke Beranda dengan status misi tercentang selesai.

---

## 4. Peta Lokasi File Kode Terkait

| Nama File | Peran Utama di Aplikasi |
|:----------|:------------------------|
| `lib/screens/features/quest_sensor.dart` | Seluruh antarmuka HUD Cardio Shake Protocol, pembaca stream sensor `accelerometerEventStream()`, dan logika filter threshold. |
| `lib/models/quest_model.dart` | Definisi master quest 'cardio' dengan kategori 'CARDIO' dan reward 20 EXP serta 15 Gold. |
| `lib/services/hive_service.dart` | Fungsi penyimpanan status penyelesaian quest offline (`saveQuestCompletion`, `isQuestCompletedToday`). |
| `lib/services/supabase_service.dart` | Fungsi pencatatan riwayat quest ke cloud (`recordQuestCompleted`, `updateUserStats`). |

---

## 5. Contekan Kalimat Presentasi (Siap Baca)
> *"Untuk memenuhi syarat penggunaan sensor fisik perangkat, kami mengimplementasikan **sensor Accelerometer lanjutan** pada quest Cardio Shake. Fitur ini memverifikasi aktivitas fisik nyata pengguna dengan menghitung magnitudo akselerasi total pada ketiga sumbu gerak tiga dimensi ($X, Y, Z$). Agar hitungan akurat dan tidak dapat dimanipulasi dengan getaran pasif, sistem kami lengkapi dengan **filter ambang batas gerak delta di atas 15 m/s²** serta **debounce cooldown sebesar 320 milidetik** per langkah. Begitu pengguna berhasil mencapai target 50 kali guncangan kardio sebelum batas waktu 3 menit berakhir, sistem secara otomatis menghentikan aliran sensor untuk mencegah kebocoran memori (*memory leak*), mengkreditkan reward 20 EXP dan 15 Gold, serta memperbarui status quest di database Hive dan Supabase."*

