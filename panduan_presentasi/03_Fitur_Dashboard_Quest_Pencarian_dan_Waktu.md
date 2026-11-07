# 03. Fitur Dashboard Quest, Pencarian & Jam 4 Zona Waktu

---

## 1. Gambaran Singkat Fitur
Layar Beranda (*Tab Home*) berfungsi sebagai pusat kendali harian bagi Hunter untuk memilih misi yang ingin dikerjakan, memantau kemajuan level dan sisa nyawa, mencari misi tertentu secara cepat lewat kolom pencarian dan tombol kategori, serta melihat jam operasional server yang berjalan serentak dalam 4 zona waktu dunia.

---

## 2. Konsep & Cara Pembuatannya
Fitur ini dirancang untuk memberikan kemudahan navigasi sekaligus memenuhi syarat kurikulum tugas akhir:
1. **Penyusunan 4 Pilar Misi (*Quest Categories*):**
   - Misi dikelompokkan ke dalam 4 pilar gaya hidup sehat: **WORKOUT** (latihan beban fisik), **CARDIO** (latihan jantung/stamina), **APPEARANCE** (perawatan diri dan kebersihan wajah), dan **STUDY** (fokus belajar Pomodoro).
2. **Pencarian Live & Filter Kategori (*Live Query Filtering*):**
   - Dibuat tanpa memerlukan tombol "Submit" atau "Enter".
   - Begitu pengguna mengetik satu huruf di kolom pencarian atau mengeklik salah satu tombol kategori (*chips*), daftar kartu misi di layar langsung tersaring secara instan berkat mekanisme pemfilteran reaktif di Flutter.
3. **Jam Digital 4 Zona Waktu Simultan (*Multi-Timezone Server Clock*):**
   - Menggunakan jam internal perangkat yang distandarkan ke waktu dunia (*UTC/GMT*).
   - Dari patokan UTC tersebut, aplikasi menghitung selisih waktu secara matematis:
     - **WIB (Waktu Indonesia Barat):** UTC + 7 Jam *(Waktu Acuan Server)*
     - **WITA (Waktu Indonesia Tengah):** UTC + 8 Jam
     - **WIT (Waktu Indonesia Timur):** UTC + 9 Jam
     - **London (GMT):** UTC + 0 Jam *(Waktu Internasional)*
   - Timer diperbarui setiap 1 detik sekali secara mulus di latar belakang.

---

## 3. Alur Kerja dari Layar ke Backend (Step-by-Step)

### A. Alur Pencarian dan Pemilihan Kategori:
1. **Di Layar Pengguna (UI):** Pengguna mengetik kata kunci di kolom pencarian (misal mengetik *"push"*) atau menekan tombol kategori *"WORKOUT"*.
2. **Pemrosesan di Balik Layar:** Variabel `_searchController.text` dan `_selectedCategory` diperbarui.
3. **Logika Filter Data:** Fungsi perulangan memeriksa daftar master quest bawaan:
   - *"Apakah kategori quest cocok dengan kategori yang dipilih (atau apakah modenya ALL)?"*
   - *"Apakah judul atau deskripsi quest mengandung teks yang diketikkan pengguna?"*
4. **Pengembalian ke Layar:** Widget `ListView` langsung merender ulang hanya kartu-kartu misi yang lolos kedua syarat di atas. Jika tidak ada yang cocok, layar menampilkan pesan ramah bahwa misi tidak ditemukan.

### B. Alur Jam 4 Zona Waktu:
1. **Inisialisasi Jam:** Saat tab dibuka, fungsi `_startServerClock()` mengaktifkan `Timer.periodic` berdurasi 1 detik.
2. **Kalkulasi Offset Waktu:**
   - Aplikasi mengambil waktu sistem: `final nowUtc = DateTime.now().toUtc()`.
   - Menghitung masing-masing zona: `wib = nowUtc.add(Duration(hours: 7))`, `wita = nowUtc.add(Duration(hours: 8))`, `wit = nowUtc.add(Duration(hours: 9))`, dan `gmt = nowUtc`.
3. **Format & Render:** Objek waktu diubah menjadi format jam-menit digital yang rapi menggunakan `DateFormat('HH:mm')` dari pustaka `intl`.
4. **Pengecekan Pergantian Tengah Malam:** Jika jam menunjukkan pukul 00:00 (reset tengah malam), sistem otomatis memicu fungsi penyegaran status quest harian.

---

## 4. Peta Lokasi File Kode Terkait

| Nama File | Peran Utama di Aplikasi |
|:----------|:------------------------|
| `lib/screens/tabs/tab_home.dart` | Layar dashboard beranda, kontroler search bar, pemilih tombol kategori, dan kalkulator jam 4 zona waktu simultan. |
| `lib/models/quest_model.dart` | Struktur data master misi harian (`defaultQuests`) beserta reward EXP, koin Gold, dan kategorinya. |
| `lib/screens/main_navigation.dart` | Navigasi bawah (*Bottom Navigation*) yang menampung Tab Home menggunakan `IndexedStack` agar posisi scroll dan pencarian tidak hilang saat berpindah tab. |
| `lib/utils/constants.dart` | Format styling teks, kartu bernuansa neon Solo Leveling, dan palet warna status. |

---

## 5. Contekan Kalimat Presentasi (Siap Baca)
> *"Pada halaman Beranda atau Dashboard utama, kami menyediakan pusat aktivitas harian yang dilengkapi dengan **fasilitas pencarian teks (*live query search*)** dan **filter kategori misi** (Workout, Cardio, Appearance, dan Study) yang menyaring daftar quest secara langsung tanpa jeda reload. Selain itu, untuk memenuhi syarat konversi waktu, kami mengimplementasikan **Jam Server Simultan 4 Zona Waktu** yang menghitung dan menampilkan waktu secara real-time untuk Waktu Indonesia Barat (WIB UTC+7), Waktu Indonesia Tengah (WITA UTC+8), Waktu Indonesia Timur (WIT UTC+9), serta Kota London (GMT UTC+0) secara akurat berdasarkan sinkronisasi detik."*

