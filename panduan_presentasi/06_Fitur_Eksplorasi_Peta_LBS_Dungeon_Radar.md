# 06. Fitur Eksplorasi Peta LBS (Dungeon Radar)

---

## 1. Gambaran Singkat Fitur
Fitur ini mengajak pengguna untuk berolahraga di luar ruangan (*outdoor*) dengan memanfaatkan peta dunia nyata berbasis lokasi satelit GPS (*Location-Based Services* / LBS), di mana pengguna harus berjalan kaki mendatangi titik gerbang dungeon terdekat di area Yogyakarta (misalnya Kampus UPN Veteran, Stadion Maguwoharjo, atau Taman Kota) hingga jaraknya kurang dari 100 meter untuk menaklukkan gate tersebut.

---

## 2. Konsep & Cara Pembuatannya
Untuk menghubungkan dunia nyata dengan fantasi Solo Leveling:
1. **Peta Interaktif Open-Source (*FlutterMap & OpenStreetMap*):**
   - Menggunakan pustaka `flutter_map` dengan server peta *CartoDB Dark Matter / OpenStreetMap*. Peta dirender dalam tema gelap bertema cyberpunk/abyss tanpa bergantung pada Google Maps API yang berbayar.
2. **Pelacakan Posisi GPS Satelit Real-Time (*Geolocator*):**
   - Menggunakan pustaka `geolocator` untuk menangkap koordinat garis lintang (*latitude*) dan garis bujur (*longitude*) pengguna secara presisi tinggi.
   - Dilengkapi penanganan izin lokasi (*runtime permissions*) dan pemantauan status GPS perangkat (memberikan peringatan jika GPS mati).
3. **Dataset Dungeon Gate Nyata di Yogyakarta:**
   - Dibuat 7 lokasi titik nyata yang mendorong aktivitas positif mahasiswa:
     1. *Kampus 2 UPN Veteran Babarsari* (Pusat Riset Akademik)
     2. *Stadion Maguwoharjo* (Jogging & Kebugaran Stamina)
     3. *Embung Tambakboyo* (Kardio Alam & Relaksasi)
     4. *Grhatama Pustaka DIY* (Literasi Membaca Buku)
     5. *GOR UNY / Stadion Kolombo* (Kalistenik Atletik)
     6. *Taman Denggung Sleman* (Rekreasi Ruang Terbuka Hijau)
     7. *Kampus 1 UPN Veteran Condongcatur* (Disiplin Perkuliahan)
   - Setiap hari, sistem secara deterministik merotasi **1 Dungeon Gate aktif** berdasarkan tanggal kalender.
4. **Formula Jarak & Aturan Geofencing 100 Meter:**
   - Jarak antara posisi fisik pengguna dan koordinat Dungeon Gate dihitung terus-menerus menggunakan formula geodesic haversine: `Geolocator.distanceBetween(userLat, userLng, gateLat, gateLng)`.
   - **Aturan Geofencing:** Pengguna **hanya bisa menekan tombol klaim jika jarak fisik berada di bawah 100 meter** ($< 100\text{ m}$). Jika masih di atas 100 meter, tombol klaim terkunci.

---

## 3. Alur Kerja dari Layar ke Backend (Step-by-Step)

### A. Alur Membuka Peta & Pelacakan Lokasi:
1. **Di Layar Pengguna (UI):** Pengguna menekan Tab 2 ("DUNGEON") di menu navigasi bawah.
2. **Pengecekan Izin GPS:** Aplikasi memeriksa apakah izin GPS sudah diberikan. Jika belum, muncul dialog izin sistem operasi Android/iOS.
3. **Pembacaan Koordinat:** Fungsi `_startPositionStream()` mulai mendengarkan koordinat satelit. Posisi pengguna ditandai dengan pin avatar Hunter berwarna cyan berkedip di atas peta.
4. **Penentuan Target Gate Hari Ini:** Model `DungeonGateModel.getDailyGate()` mengambil titik gate hari ini (misalnya *Babarsari Academic Core Gate* di UPN Babarsari). Pin portal dimensional merah/biru muncul di peta pada koordinat yang tepat.

### B. Alur Perhitungan Jarak Real-Time:
1. **Pengguna Bergerak:** Saat pengguna berjalan mendekati lokasi kampus/taman, GPS terus mengirim koordinat terbaru.
2. **Kalkulasi Jarak:** Nilai variabel `distance` diperbarui (misalnya dari 450 meter $\rightarrow$ 210 meter $\rightarrow$ 85 meter).
3. **Pembaruan Kartu Radar di Layar:** Kartu status di bagian bawah layar menampilkan informasi jarak secara dinamis: *"DISTANCE: 85 M"* dan badge status berubah dari *"OUT OF RANGE"* menjadi *"GATE IN PROXIMITY (READY TO RAID)"*.

### C. Alur Penaklukan Dungeon Gate & Klaim Hadiah:
1. **Penekanan Tombol Klaim:** Ketika jarak sudah $< 100\text{ meter}$, tombol "CLAIM EXPEDITION" menjadi aktif menyala dan ditekan oleh pengguna.
2. **Validasi Geofencing:** Aplikasi memastikan kembali: `if (distance <= 100)`. Jika jarak valid, proses klaim dijalankan.
3. **Pemberian Hadiah & Penyimpanan (Hive & Supabase):**
   - Nilai hadiah gate (misal **+65 EXP** dan **+120 Gold**) ditambahkan ke profil pengguna.
   - Status penaklukan dungeon gate hari ini dicatat ke dalam `questBox` Hive dengan ID unik `dungeon_upn_babarsari` agar tidak dapat diklaim dua kali di hari yang sama.
   - Nilai EXP dan Gold terbaru disinkronkan ke tabel `users` Supabase.
4. **Kembali ke Layar Pengguna:** Muncul dialog kemenangan animasi dungeon Solo Leveling *"GATE CLEARED! +65 EXP & +120 GOLD CLAIMED"*, dan tombol gate berubah menjadi status tercentang abu-abu.

---

## 4. Peta Lokasi File Kode Terkait

| Nama File | Peran Utama di Aplikasi |
|:----------|:------------------------|
| `lib/screens/tabs/tab_map.dart` | Antarmuka peta OpenStreetMap (`FlutterMap`), pengontrol kamera peta, pemantau stream GPS `Geolocator`, dan validasi batas radius klaim 100m. |
| `lib/models/dungeon_gate_model.dart` | Dataset 7 koordinat geografis nyata di Yogyakarta (`positiveDungeons`) dan algoritma rotasi harian `getDailyGate()`. |
| `lib/services/hive_service.dart` | Fungsi pencatatan status penaklukan gate harian agar tersimpan secara persisten. |
| `lib/services/supabase_service.dart` | Sinkronisasi perolehan EXP dan Gold penaklukan dungeon ke cloud server. |

---

## 5. Contekan Kalimat Presentasi (Siap Baca)
> *"Pada aspek eksplorasi dunia nyata, kami mengimplementasikan fitur **Location-Based Services (LBS)** menggunakan integrasi peta **OpenStreetMap via FlutterMap** dan pelacakan satelit GPS presisi tinggi melalui pustaka **Geolocator**. Kami memetakan titik-titik koordinat nyata di area Yogyakarta—seperti Kampus UPN Veteran Babarsari, Stadion Maguwoharjo, dan Perpustakaan Grhatama—menjadi titik Dungeon Gate harian yang berganti secara otomatis setiap hari. Sistem secara real-time menghitung jarak fisik pengguna ke titik target menggunakan formula jarak geodesic. Berdasarkan **aturan geofencing**, pengguna hanya diizinkan mengklaim reward EXP dan Gold apabila jarak fisik keberadaannya berada dalam **radius kurang dari 100 meter** dari lokasi gerbang dungeon nyata tersebut."*

