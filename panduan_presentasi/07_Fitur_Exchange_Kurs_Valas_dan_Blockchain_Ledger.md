# 07. Fitur Exchange Kurs Valas & Toko Gelar Blockchain

---

## 1. Gambaran Singkat Fitur
Layar Toko Pertukaran (*Tab Shop / Exchange*) berfungsi sebagai pusat ekonomi Hunter untuk membelanjakan koin Gold hasil latihan menjadi gelar (*Title*) bergengsi. Fitur ini dilengkapi dengan **konversi kurs mata uang internasional secara langsung (*live API*)** serta pencatatan transaksi pembelian gelar ke dalam **buku besar Blockchain sederhana** dengan rantai enkripsi SHA-256 dan jaringan uji coba Web3 Ethereum Sepolia.

---

## 2. Konsep & Cara Pembuatannya
Fitur ini menggabungkan dua kriteria evaluasi tugas akhir sekaligus (Syarat No. 7 Konversi Mata Uang & Syarat No. 13 Blockchain Sederhana):
1. **Konversi Nilai Tukar Valuta Asing Nyata (*Live Exchange Rate API*):**
   - Aplikasi tidak menggunakan angka kurs palsu atau statis.
   - Menggunakan REST API dari penyedia valas dunia: `https://open.er-api.com/v6/latest/USD`.
   - Mengambil data nilai tukar mata uang terkini: **Rupiah (IDR)**, **Dolar Amerika (USD)**, dan **Euro (EUR)**.
   - Nilai 100 Gold dalam ekonomi game LevMax disetarakan dengan \$1.00 USD, sehingga pengguna bisa melihat valuasi kekayaan koin Gold mereka ke dalam Rupiah, Dollar, dan Euro secara akurat. Disediakan pula kalkulator konversi interaktif.
2. **Buku Besar Rantai Blok (*Simple Blockchain Ledger*):**
   - Setiap pembelian gelar di dalam toko tidak hanya sekadar mengurangi saldo, melainkan dicatat layaknya satu blok transaksi pada teknologi Blockchain.
   - **Mekanisme Rantai Hash (*Chaining Hash*):**
     - Setiap blok transaksi baru memiliki 4 data pokok: `item` (nama gelar), `timestamp` (waktu transaksi), `prev_hash` (kode hash blok sebelumnya), dan `current_hash` (kode hash blok saat ini).
     - Kode hash dihitung menggunakan algoritma SHA-256:
       $$\text{current\_hash} = \text{SHA-256}(\text{username} + \text{item} + \text{timestamp} + \text{prev\_hash})$$
     - Blok pertama (*Genesis Block*) diawali dengan hash 64-karakter nol. Blok berikutnya wajib mengunci hash dari blok sebelum dirinya, sehingga catatan transaksi menjadi kekal, saling bertaut, dan tidak bisa dipalsukan.
   - Disimpan secara persisten di dalam box khusus Hive: `blockchainBox`.
3. **Pencatatan Transaksi On-Chain Web3 (Ethereum Sepolia Testnet):**
   - Selain buku besar lokal, sistem juga terhubung ke jaringan uji coba Ethereum Sepolia menggunakan pustaka `web3dart`. Aplikasi membuat transaksi payload data ke alamat wallet sendiri dengan tanda tangan kunci privat (*private key*), sehingga menghasilkan kode *Transaction Hash* (Tx Hash) yang sah di penjelajah blok Sepolia Etherscan.

---

## 3. Alur Kerja dari Layar ke Backend (Step-by-Step)

### A. Alur Pengambilan Kurs Valas Live & Kalkulator:
1. **Inisialisasi Halaman:** Saat Tab Shop dibuka, fungsi `_fetchLiveExchangeRates()` otomatis menembak endpoint API `https://open.er-api.com/v6/latest/USD`.
2. **Penerimaan Respon API:** Server mengembalikan data JSON nilai tukar terbaru (misalnya \$1 USD = Rp 16.250 IDR dan €0.92 EUR).
3. **Kalkulator Valas:** Pengguna bisa menekan kartu konversi untuk membuka pop-up kalkulator. Pengguna dapat mengetik nominal koin Gold, dan aplikasi seketika menghitung nilainya dalam 3 mata uang simultan: Rupiah (Rp), Dollar (\$), dan Euro (€).

### B. Alur Pembelian Gelar & Pencatatan Blok Baru ke Blockchain:
1. **Di Layar Pengguna (UI):** Pengguna memilih salah satu gelar (misalnya *"Wolf Slayer"* seharga 200 Gold) dan menekan tombol **"PURCHASE TITLE"**.
2. **Validasi Saldo & Kepemilikan:**
   - Aplikasi mengecek apakah gelar sudah dimiliki atau belum.
   - Aplikasi memastikan apakah koin Gold pemain mencukupi (`currentGold >= price`).
3. **Pembuatan Transaksi Web3 (Ethereum Sepolia):**
   - Tombol berubah menjadi status loading.
   - Pustaka `web3dart` menandatangani transaksi berisi data `"Hunter membeli Title Wolf Slayer"` dan mengirimkannya ke RPC Node Sepolia. Dihasilkan satu string kode unik transaksi on-chain (`0x...`).
4. **Perangkaian Blok Baru di Hive Blockchain:**
   - Aplikasi mengambil kode hash dari transaksi sebelumnya via `HiveService.getLastBlockHash()`.
   - Menghitung kode hash transaksi baru via `HashService.createBlockchainHash()`.
   - Blok baru disimpan ke dalam `blockchainBox` Hive lengkap dengan timestamp, prev_hash, dan hash saat ini.
5. **Pembaruan Kepemilikan & Saldo:**
   - Koin Gold dipotong sesuai harga item, dan gelar baru dimasukkan ke dalam daftar inventaris `owned_titles`.
   - Data saldo dan inventaris disinkronkan ke Supabase dan Hive.
6. **Kembali ke Layar Pengguna:** Muncul dialog sukses berwarna emas Solo Leveling menampilkan kode *Transaction Hash* dan link Etherscan. Gelar yang baru dibeli kini bisa langsung dipasang (*equipped*) di halaman profil.

---

## 4. Peta Lokasi File Kode Terkait

| Nama File | Peran Utama di Aplikasi |
|:----------|:------------------------|
| `lib/screens/tabs/tab_shop.dart` | Antarmuka toko gelar (*catalog titles*), pemanggil live API kurs valas, kalkulator konversi Gold, dan alur transaksi Web3. |
| `lib/services/hash_service.dart` | Algoritma penghitung hash blok: `createBlockchainHash(username, item, timestamp, prevHash)`. |
| `lib/services/hive_service.dart` | Penyimpanan buku besar blockchain lokal (`saveBlockchainLog`, `getBlockchainLogs`, `getLastBlockHash`). |
| `lib/services/supabase_service.dart` | Sinkronisasi pengurangan saldo Gold setelah belanja gelar ke database cloud. |
| `lib/utils/constants.dart` | Nilai tukar referensi dasar (100 Gold = 1 USD = 0.95 EUR = Rp 15.000 IDR). |

---

## 5. Contekan Kalimat Presentasi (Siap Baca)
> *"Pada menu Hunter Exchange atau Toko Gelar, kami mengintegrasikan dua fitur penting: **Konversi Kurs Multi-Mata Uang** dan **Blockchain Sederhana**. Untuk konversi mata uang, kami menghubungkan aplikasi ke **Live Web Service API Open Exchange Rates** yang mengambil kurs pasar riil secara langsung untuk mengonversi koin Gold ke 3 mata uang utama yaitu Rupiah (IDR), Dolar Amerika (USD), dan Euro (EUR) dilengkapi kalkulator interaktif. Sementara itu, pada sistem belanja gelar (*Title*), setiap kali transaksi berhasil dilakukan, sistem tidak hanya memotong saldo pengguna melainkan mencatatnya ke dalam **buku besar Blockchain sederhana** di database lokal Hive. Blok transaksi tersebut mengikat data pembelian dengan **kode hash berantai SHA-256 (*previous hash* ke *current hash*)** serta mengeksekusi transaksi data on-chain ke jaringan uji coba **Ethereum Sepolia Testnet** melalui pustaka `web3dart`."*

