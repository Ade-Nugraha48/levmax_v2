# Environment & Resource Constraints - LevMax

Dokumen ini mendefinisikan *resource* pengembangan dan perangkat pengujian (testing devices) yang digunakan selama pembuatan aplikasi LevMax. Karena pengerjaan (dan mungkin kompilasi) dilakukan langsung melalui perangkat mobile dengan AI Antigravity, efisiensi kode dan kompatibilitas adalah prioritas utama.

## 1. Perangkat Pengujian (Testing Devices)

Aplikasi **wajib** bisa di-build, dibuka, dan berjalan lancar tanpa error *RenderFlex overflow* (layar terpotong) atau *Out of Memory* di dua perangkat berikut:

### Device A: OPPO A5 2020
* **Chipset / RAM:** Snapdragon 665 / 3GB atau 4GB RAM (Termasuk low-to-mid end, sangat sensitif terhadap memori/animasi berat).
* **Resolusi Layar:** 720 x 1600 pixels (Layar lebih kecil/sempit).
* **OS:** Android 9.0 (Pie), dapat di-upgrade hingga Android 11.
* **Fitur Hardware Terkait:** Fingerprint (Rear-mounted), Accelerometer, Gyroscope, GPS.

### Device B: Samsung Galaxy M31
* **Chipset / RAM:** Exynos 9611 / 6GB RAM (Mid-range).
* **Resolusi Layar:** 1080 x 2340 pixels (Layar lebih tajam dan panjang).
* **OS:** Android 10, dapat di-upgrade hingga Android 12.
* **Fitur Hardware Terkait:** Fingerprint (Rear-mounted), Accelerometer, Gyroscope, GPS.

## 2. Aturan Koding UI & Responsivitas (Untuk AI Generator)

Mengingat perbedaan resolusi (720p vs 1080p), AI **dilarang keras** membuat UI dengan pendekatan berikut:
1. **Dilarang menggunakan *hardcoded* width/height yang besar.** (Contoh: `Container(height: 800)`).
2. **Wajib menggunakan layout fleksibel:** Selalu manfaatkan `MediaQuery.of(context).size`, `Expanded`, `Flexible`, `SafeArea`, dan `SingleChildScrollView` untuk menghindari error *Bottom Overflowed by XXX pixels* di Oppo A5 2020.
3. **Optimasi Asset:** Jika menggunakan gambar profil atau asset, gunakan ukuran wajar (jangan memuat gambar 4K) agar tidak menghabiskan RAM Oppo A5 2020.

## 3. Konfigurasi Sistem (Android Permissions)

Karena kedua device menargetkan OS Android 9 hingga 12, pastikan AndroidManifest.xml (`android/app/src/main/AndroidManifest.xml`) dikonfigurasi dengan *permissions* yang kompatibel untuk device lawas dan baru:

```xml
<!-- Wajib untuk koneksi Supabase & API Gemini -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Wajib untuk LBS (Location Based Service) -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Wajib untuk fitur Biometrik (Fingerprint Oppo A5 & Samsung M31) -->
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
```

## 4. Constraint Sensor (Accelerometer & Gyroscope)

* Hardware Gyroscope dan Accelerometer di perangkat kelas menengah (terutama Oppo A5) terkadang memiliki sedikit *delay* atau *noise*.
* **Instruksi untuk AI:** Saat membuat logika "Cardio Shake" (Accelerometer) atau "Gyro Balancer" (Gyroscope), tambahkan sedikit toleransi (`threshold`) pada perhitungan sumbu X, Y, Z agar game/quest tidak terlalu sulit diselesaikan karena *sensor noise* dari HP.

## 5. Kinerja & State Management

* **Tetap Gunakan `StatefulWidget`:** Sesuai PRD, jangan gunakan state manager eksternal. Gunakan `setState()` dengan bijak. Jangan panggil `setState()` di dalam *loop* sensor yang berjalan setiap milidetik (misal di sensor Gyroscope) tanpa *throttling* (pembatasan frekuensi update), karena akan membuat Oppo A5 2020 nge-lag parah. Gunakan timer atau cek interval minimal 100ms untuk update UI di mini-game.