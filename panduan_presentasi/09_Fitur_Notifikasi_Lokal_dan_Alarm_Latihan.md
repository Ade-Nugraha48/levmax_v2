# 09. Fitur Notifikasi Mobile & Alarm Latihan Fisik

---

## 1. Gambaran Singkat Fitur
Fitur ini berfungsi sebagai pengingat setia di saku pengguna agar tidak melewatkan jadwal rutinitas harian, yang terdiri dari **5 skenario notifikasi push otomatis** berbasis zona waktu sistem serta **alarm latihan fisik bersuara kencang** yang terus berdering berulang (*looping*) hingga pengguna membuka aplikasi dan mematikannya.

---

## 2. Konsep & Cara Pembuatannya
Untuk memastikan kedisiplinan tanpa membebani kuota internet pengguna:
1. **Notifikasi Berbasis Waktu Nyata (*Timezone-Aware Local Notifications*):**
   - Menggunakan pustaka `flutter_local_notifications` dan `timezone`.
   - Bekerja secara murni di sisi perangkat (*offline push notification*) tanpa perlu menyewa server notifikasi berbayar.
   - Mengamankan izin resmi sistem operasi Android 13+ (`POST_NOTIFICATIONS`) dan izin alarm presisi (*Exact Alarm*).
2. **5 Skenario Notifikasi Otomatis Sepanjang Hari:**
   - **Skenario 1 (Pukul 00:00 Malam):** *Reset Jam Server* $\rightarrow$ Memberitahu Hunter bahwa quest harian dan dungeon gate telah diperbarui.
   - **Skenario 2 (Pukul 14:00 Siang):** *Aktivitas Tertunda* $\rightarrow$ Mengingatkan jika quest fisik, dungeon radar, atau mini game belum disentuh.
   - **Skenario 3 (Berkala Tiap 3 Jam):** *Peringatan 3 Jam* $\rightarrow$ Dijadwalkan otomatis pada jam 09:00, 12:00, 15:00, 18:00, dan 21:00 untuk mencegah pemain terkena penalti HP.
   - **Skenario 4 (Pukul 19:30 Malam):** *Sapaan Kangen AI Guide* $\rightarrow$ Notifikasi personal yang memanggil nama kustom asisten AI (misal: *"💬 [BERU]: Hunter, aku menunggumu di sistem latihan..."*).
   - **Skenario 5 (Pukul 23:00 Malam):** *Peringatan Kritis Akhir Hari* $\rightarrow$ Peringatan darurat bahwa hari tersisa 1 jam lagi sebelum penalti eksekusi pengurangan HP aktif.
3. **Alarm Latihan Fisik & Audio Looping (*AlarmService*):**
   - Menggunakan `audioplayers` dengan pengaturan saluran audio khusus alarm (`AndroidUsageType.alarm`).
   - Mendukung nada dering kustom format MP3 dari penyimpanan memori ponsel maupun suara sirine bawaan sistem (*system alarm WAV*).
   - Dilengkapi pengaturan volume suara (0% sampai 100%) dan getaran (*vibrate*).
   - Menggunakan mode notifikasi *ongoing* (tidak bisa digeser atau di-swipe hilang dari panel status bar) sehingga pengguna dipaksa sadar dan bangun untuk berolahraga.

---

## 3. Alur Kerja dari Layar ke Backend (Step-by-Step)

### A. Alur Penjadwalan 5 Notifikasi Otomatis:
1. **Inisialisasi Saat Aplikasi Pertama Kali Dibuka:** Di dalam `main.dart`, aplikasi memanggil fungsi `NotifService.init()`.
2. **Pendaftaran Jadwal ke Sistem Operasi:** Fungsi `scheduleAllAutomatedNotifications()` menghitung jam target menggunakan `tz.TZDateTime` dan mendaftarkan 5 slot jadwal ke sistem alarm Android/iOS dengan mode `matchDateTimeComponents: DateTimeComponents.time`.
3. **Pemicu Tanpa Internet:** Walaupun layar ponsel mati atau jaringan internet terputus, sistem operasi Android akan otomatis membunyikan notifikasi bersuara tepat pada jam-jam yang telah ditentukan.

### B. Alur Pengaturan & Dering Alarm Latihan:
1. **Di Layar Pengguna (UI):** Pengguna menekan kartu jam alarm di halaman Beranda. Pengguna menyetel jam dan menit (misal 06:00 pagi), memilih nada dering MP3, mengatur penggeser volume (*slider*), dan mengaktifkan saklar (*switch*).
2. **Penyimpanan Konfigurasi:** Data disimpan ke Hive sebagai objek JSON melalui `HiveService.saveAlarm(alarm)`.
3. **Penyusunan Alarm Ganda (Dual-Layer):**
   - *Layer Foreground:* Timer internal Dart untuk mengantisipasi saat aplikasi sedang aktif dibuka.
   - *Layer Background:* Jadwal `AndroidScheduleMode.alarmClock` pada level kernel Android, sehingga alarm tetap berbunyi tepat waktu meskipun aplikasi sudah dimatikan total (*cleared from recent apps*).
4. **Saat Waktu Alarm Tiba:**
   - Ponsel mulai memutar audio nada dering berputar terus-menerus (`ReleaseMode.loop`) pada volume yang ditentukan.
   - Muncul notifikasi darurat layar penuh bertuliskan *"HUNTER AWAKENING // WAKTU LATIHAN TIBA!"*.
   - Jika pengguna sedang membuka aplikasi, muncul dialog pop-up merah darurat dengan tombol besar **"STOP ALARM"**.
5. **Mematikan Alarm:** Saat tombol stop ditekan, suara berhenti, notifikasi hilang, dan sistem otomatis menjadwalkan ulang alarm tersebut untuk keesokan paginya secara mandiri.

---

## 4. Peta Lokasi File Kode Terkait

| Nama File | Peran Utama di Aplikasi |
|:----------|:------------------------|
| `lib/services/notif_service.dart` | Pengelola notifikasi lokal, inisialisasi timezone, saluran *Hunter System Channel*, dan scheduler 5 skenario otomatis. |
| `lib/services/alarm_service.dart` | Pengontrol pemutaran audio (`AudioPlayer`), looping nada dering MP3, pengaturan volume, dan integrasi notifikasi AlarmClock OS. |
| `lib/models/alarm_model.dart` | Struktur data model konfigurasi alarm (jam, menit, status aktif, nada dering, volume, getar). |
| `lib/services/hive_service.dart` | Penyimpanan konfigurasi alarm dan identitas persona AI di Hive `sessionBox`. |
| `lib/screens/tabs/tab_home.dart` | Kartu UI pengaturan alarm, pendengar status dering `onAlarmStateChanged`, dan dialog interaktif matikan alarm. |

---

## 5. Contekan Kalimat Presentasi (Siap Baca)
> *"Pada aspek notifikasi mobile dan pengingat kebiasaan, kami mengimplementasikan dua subsistem: **Push Notification Lokal Otomatis** dan **Layanan Alarm Latihan**. Notifikasi kami bangun menggunakan pustaka `flutter_local_notifications` yang dijadwalkan secara otomatis ke dalam **5 skenario sepanjang hari**—mulai dari reset server tengah malam, pengingat berkala setiap 3 jam, hingga sapaan personal dari asisten AI pada jam 19:30 malam—yang berjalan murni tanpa ketergantungan internet. Sementara untuk alarm latihan pagi, kami merancang layanan **AlarmService** dengan pemutaran audio looping bersuara kencang, kontrol intensitas volume, dan integrasi ke tingkat sistem operasi Android AlarmClock, sehingga alarm dijamin tetap berbunyi keras tepat waktu meskipun aplikasi sedang dalam kondisi tertutup."*

