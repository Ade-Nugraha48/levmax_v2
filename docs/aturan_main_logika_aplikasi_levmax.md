# Aturan Main & Logika Aplikasi (Game Mechanics) - LevMax

Dokumen ini mengatur seluruh angka, perhitungan, dan logika utama yang berjalan di dalam aplikasi LevMax. Logika ini dirancang statis (hardcoded) agar mudah dan cepat diimplementasikan menggunakan `setState`.

## 1. Sistem Rank & Experience (EXP)

Rank menentukan tingkat *user*. Rank akan otomatis naik jika akumulasi EXP mencapai batas tertentu.

*   **Rank F:** 0 - 99 EXP (Rank Awal)
*   **Rank E:** 100 - 299 EXP
*   **Rank D:** 300 - 599 EXP
*   **Rank C:** 600 - 999 EXP
*   **Rank B:** 1000 - 1499 EXP
*   **Rank A:** 1500 - 2499 EXP
*   **Rank S:** 2500+ EXP (Rank Maksimal)

*Catatan untuk AI Generator:* Buat fungsi `checkRankUp(int currentExp)` yang dipanggil setiap kali user mendapatkan EXP. Jika batas tercapai, berikan notifikasi `SnackBar` "Level Up!".

## 2. Sistem Mata Uang & Status

*   **Gold:** Didapat dari menyelesaikan Quest dan Mini Game. Digunakan untuk membeli Item (Title/Border) di Halaman Shop.
*   **HP (Health Points):** Setiap user memiliki maksimal **3 HP**. 
    *   Jika dalam 1 hari user tidak menyelesaikan *Quest Wajib Harian* minimal 3 buah, maka keesokan harinya saat login, HP berkurang 1.
    *   Jika HP mencapai 0, maka ada **Pinalti Berat**: Rank user akan diturunkan 1 tingkat (misal dari D kembali ke E), EXP direset ke batas bawah rank tersebut, dan HP kembali penuh menjadi 3.

## 3. Daftar & Logika Quest Utama

Quest di-reset setiap jam 00:00 waktu lokal (Pengecekan dilakukan saat aplikasi dibuka dengan membandingkan `lastLoginDate` di Hive). 

Berikut adalah kategori dan *reward* Quest:

### A. Kategori: Workout (Fisik)
Sistem penyelesaian: *Self-reported* (User menekan tombol "Selesai" berbentuk Checkbox).
*   **Push Up (20 Reps):** +10 EXP, +5 Gold
*   **Sit Up (20 Reps):** +10 EXP, +5 Gold
*   **Pull Up (10 Reps):** +15 EXP, +10 Gold
*   **Squat (30 Reps):** +10 EXP, +5 Gold

### B. Kategori: Cardio
*   **Lari (2 KM):** *Self-reported* -> +20 EXP, +15 Gold
*   **Jalan (Quest Sensor Accelerometer):** 
    *   *Logika:* Menggunakan package `sensors_plus`. User harus masuk ke halaman khusus dan "mengocok/shake" HP sebanyak 50 kali untuk menyimulasikan langkah/langkah cepat.
    *   *Reward:* +20 EXP, +15 Gold.

### C. Kategori: Appearance (Penampilan)
Saat kartu quest ini diklik, akan muncul **Modal Bottom Sheet**. User harus mencentang *semua* sub-quest di bawah ini untuk bisa menekan tombol "Submit" dan mendapatkan reward.
*   *Sub-quest:* 
    1. Cuci muka pagi
    2. Pakai moisturizer pagi
    3. Pakai sunscreen pagi
    4. Cuci muka malam
    5. Pakai moisturizer malam
*   *Reward (Total):* +30 EXP, +20 Gold

### D. Kategori: Study (Belajar)
*   **Fokus 30 Menit / Baca Materi:** *Self-reported*. 
*   *Reward:* +15 EXP, +10 Gold.

### E. Misi Rahasia: Hidden Quest Generator (LLM Gemini)
*   **Tombol Pemicu:** Tombol neon merah/ungu "SCAN HIDDEN DUNGEON" di bawah daftar quest harian Tab Home.
*   **Logika Dinamis:** Memanggil fungsi `generateHiddenQuest(rank, exp)` di `gemini_service.dart`. Prompt dibuat dinamis menyesuaikan Rank dan EXP Hunter yang sedang aktif.
*   **Format Output:** Menghasilkan 1 misi rahasia bernada dramatis dan epik ala *Solo Leveling* maksimal 3 kalimat diawali dengan `[JUDUL MISI]`.
*   **Atmosfer Game:** UI murni bertema dungeon hunter tanpa menampilkan istilah teknis AI / LLM / Gemini untuk menjaga imersi pengguna.

## 4. Logika Mini Game (Gyroscope)
*   **Nama:** Gyro Balancer (Tab 3).
*   **Aturan:** User memiringkan HP untuk menahan bola di tengah layar selama 5 detik.
*   **Limitasi:** Game ini bisa dimainkan berkali-kali, TAPI *reward* Gold hanya diberikan untuk **1 kali kemenangan pertama per hari**.
*   **Reward:** +50 Gold.

## 5. Logika Halaman LBS (Map)
*   **Aturan:** Terdapat 1 atau 2 titik lokasi statis (misal dikoordinatkan di area kampus). 
*   **Mekanisme:** User membuka Tab LBS, menekan tombol "Klaim Titik". Sistem menghitung jarak koordinat user dengan koordinat titik sasaran. Jika jarak < 100 meter, klaim berhasil.
*   **Reward:** +50 EXP, +100 Gold (Hanya bisa diklaim 1 kali per minggu).

## 6. Logika Konversi & Blockchain Web3 (Shop)
*   **Konversi Waktu (UI):** Ditampilkan di Dashboard. Jam saat ini dikonversi manual: WIB (UTC+7), WITA (UTC+8), WIT (UTC+9), London (UTC+0).
*   **Valuasi Mata Uang Real-Time:** Di halaman Shop, kurs diambil secara live dari REST API `https://open.er-api.com/v6/latest/USD`. Saldo Hunter secara dinamis dikonversikan ke IDR, USD, dan EUR serta disediakan modal kalkulator konversi interaktif.
*   **Sistem Blockchain Web3 On-Chain:**
    *   Transaksi pembelian title ditandatangani menggunakan Private Key Ethereum pengguna via `web3dart`.
    *   Transaksi disiarkan ke publik di **Ethereum Sepolia Testnet** (Chain ID 11155111) dengan payload string terenkripsi bytes (`utf8.encode`) dan mengonsumsi saldo Sepolia ETH untuk gas fee.
    *   **Verifikasi 100% Full Online:** Transaksi terverifikasi langsung secara publik di **Sepolia Etherscan** (`https://sepolia.etherscan.io/tx/<hash>`) dengan status `Success`.
    *   Seluruh pengecekan offline telah dihapus. Disediakan tombol Salin Hash, status SEPOLIA ONLINE di buku besar lokal Hive, serta tombol Reset Inventori untuk kemudahan pengujian.