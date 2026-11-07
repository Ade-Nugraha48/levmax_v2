# 02. Fitur Gamifikasi RPG & Sistem Penalti HP

---

## 1. Gambaran Singkat Fitur
Fitur ini adalah nyawa utama dari LevMax yang menyulap rutinitas produktif pengguna menjadi permainan peran (RPG) mirip dunia *Solo Leveling*, di mana pemain memiliki tingkat pangkat (*Hunter Rank* dari F sampai S), poin pengalaman (*EXP*), pundi koin emas (*Gold*), serta nyawa kesehatan (*HP*) yang bisa berkurang jika pengguna malas menjalankan misi harian.

---

## 2. Konsep & Cara Pembuatannya
Untuk menciptakan efek psikologis kedisiplinan yang menyenangkan sekaligus menegangkan:
1. **Sistem Tingkatan Pangkat (*Rank Progression*):**
   - Rank dihitung secara matematis dari akumulasi poin pengalaman (EXP) yang dikumpulkan pengguna:
     - **Rank F:** 0 – 99 EXP *(Hunter Pemula)*
     - **Rank E:** 100 – 299 EXP
     - **Rank D:** 300 – 599 EXP
     - **Rank C:** 600 – 999 EXP
     - **Rank B:** 1000 – 1499 EXP
     - **Rank A:** 1500 – 2499 EXP
     - **Rank S:** 2500+ EXP *(Sovereign Shadow Monarch)*
2. **Sistem HP & Aturan Penalti Harian (*Penalty Mechanics*):**
   - Setiap Hunter dibekali modal **3 HP (Health Points)**.
   - Setiap hari, Hunter diwajibkan menuntaskan **minimal 3 misi (quest)**.
   - Aplikasi mencatat tanggal terakhir pengguna login dan jumlah quest yang diselesaikan hari itu. Jika pengguna membuka aplikasi di hari berikutnya dan ditemukan bahwa misi hari kemarin kurang dari 3, maka sistem otomatis mengeksekusi penalti: **HP berkurang 1**.
   - Jika HP sampai menyentuh angka **0 (habis total)**, pemain terkena hukuman berat: **diturunkan 1 tingkat Rank**, dan EXP direset ke batas bawah pangkat tersebut, sementara HP dipulihkan kembali ke 3 sebagai kesempatan kedua.
3. **Ekonomi Koin Emas (*Hunter Gold*):**
   - Pengguna memperoleh koin Gold dari setiap quest yang berhasil diselesaikan dan dari memenangkan mini game harian.
   - Gold ini bisa dibelanjakan di toko pertukaran (*Tab Shop*) untuk membeli gelar prestisius (*Title*).

---

## 3. Alur Kerja dari Layar ke Backend (Step-by-Step)

### A. Alur Kenaikan EXP & Rank Saat Misi Diselesaikan:
1. **Di Layar Pengguna (UI):** Pengguna menekan tombol "LATIHAN SELESAI" pada salah satu misi (misalnya Push-Up atau Pomodoro Belajar).
2. **Pemrosesan di Balik Layar:** Aplikasi mengambil nilai reward dari misi tersebut (misalnya +10 EXP dan +5 Gold). Poin baru langsung ditambahkan ke total EXP dan Gold pemain.
3. **Pengecekan Algoritma Rank:** Aplikasi memanggil fungsi logika `AppConstants.calculateRank(totalExpBaru)`. Jika total EXP melewati ambang batas rank berikutnya (misalnya dari 95 EXP menjadi 105 EXP, menembus batas 100 EXP), status Rank otomatis naik dari 'F' menjadi 'E'.
4. **Penyimpanan Ganda (Dual-Save):**
   - Nilai baru langsung ditulis ke memori lokal Hive `sessionBox` agar tampilan antarmuka seketika ter-update tanpa menunggu loading.
   - Secara bersamaan, aplikasi mengirim pembaruan ke tabel `users` di cloud Supabase melalui fungsi `SupabaseService.updateUserStats()`.
5. **Kembali ke Layar Pengguna:** EXP bar di halaman utama langsung bergerak memanjang dengan warna ungu menyala, saldo koin bertambah, dan lencana Rank berganti warna sesuai levelnya.

### B. Alur Pengecekan Pergantian Hari & Hukuman Penalti HP:
1. **Pemicu Otomatis:** Begitu pengguna membuka aplikasi (di fungsi `initState` pada `TabHome`), aplikasi langsung menjalankan fungsi `_checkDailyHpPenalty()`.
2. **Pengecekan Kalender:** Aplikasi membandingkan tanggal hari ini dengan `last_login_date` yang tersimpan di Hive.
3. **Evaluasi Disiplin:**
   - Jika terdeteksi tanggal sudah berganti (hari baru): aplikasi memeriksa `completed_quests_today_count` hari sebelumnya.
   - Jika quest kemarin $\ge 3$: Hunter dinyatakan disiplin, HP tetap utuh (3/3).
   - Jika quest kemarin $< 3$: Hunter melanggar protokol! Variabel HP langsung dipotong: `newHp = currentHp - 1`.
4. **Penyimpanan & Notifikasi Sistem:** Nilai HP baru disimpan ke Hive dan Supabase. Layar langsung memunculkan pop-up dialog merah peringatan bernada darurat: *"PENALTY APPLIED: Kemarin Anda hanya menyelesaikan X quest. HP berkurang 1!"*. Jika HP menjadi 0, terjadi proses penurunan Rank secara dramatis.

---

## 4. Peta Lokasi File Kode Terkait

| Nama File | Peran Utama di Aplikasi |
|:----------|:------------------------|
| `lib/utils/constants.dart` | Menyimpan konstanta game: Max HP (3), minimal quest (3), ambang batas EXP setiap Rank, dan fungsi `calculateRank()`. |
| `lib/screens/tabs/tab_home.dart` | Menampilkan indikator HP berupa 3 hati neon, EXP progression bar, Rank badge, dan fungsi evaluasi penalti harian `_checkDailyHpPenalty()`. |
| `lib/models/user_model.dart` | Model data pengguna yang menampung atribut `exp`, `gold`, `rank`, dan `hp`. |
| `lib/services/hive_service.dart` | Menyimpan dan mengambil histori tanggal login, sisa HP, dan counter quest hari ini di lokal memori. |
| `lib/services/supabase_service.dart` | Menyinkronkan nilai EXP, Gold, Rank, dan HP terbaru ke tabel `users` di database cloud Supabase. |

---

## 5. Contekan Kalimat Presentasi (Siap Baca)
> *"Pada aspek gamifikasi RPG, LevMax mengadopsi mekanisme perkembangan karakter Solo Leveling untuk membangun motivasi intrinsik pengguna. Pengguna diklasifikasikan ke dalam 7 tingkatan **Hunter Rank** mulai dari Rank F hingga Rank S berdasarkan akumulasi **EXP** yang diperoleh dari penyelesaian quest. Untuk menuntut komitmen harian, kami merancang **Sistem Penalti HP**: setiap pengguna memiliki batas maksimal 3 HP dan diwajibkan menyelesaikan minimal 3 misi per hari. Setiap kali aplikasi dibuka pada hari baru, sistem secara otomatis mengevaluasi rekam jejak hari sebelumnya; apabila pengguna gagal memenuhi target minimal, HP akan dipotong 1 poin. Jika HP sampai habis ke angka nol, pengguna akan dijatuhi penalti penurunan rank dan EXP direset. Seluruh status gamifikasi ini disinkronkan secara langsung ke database lokal Hive dan cloud Supabase."*

