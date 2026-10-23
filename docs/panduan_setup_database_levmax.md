# Panduan Lengkap Setup Database LevMax (Supabase & Hive)

Dokumen ini berisi langkah-langkah dari nol untuk mengatur backend (Supabase) dan local storage (Hive) untuk proyek LevMax.

---

## BAGIAN 1: Setup Supabase (Remote Database)

Supabase akan digunakan untuk menyimpan data User dan Kesan Pesan (Feedback).

### Langkah 1: Buat Project di Supabase
1. Buka browser dan pergi ke [https://supabase.com/](https://supabase.com/)
2. Klik **Start your project** dan Login menggunakan akun GitHub atau Email.
3. Klik tombol **New Project**.
4. Pilih *Organization* (buat baru jika belum ada), masukkan **Name** (contoh: `LevMaxDB`), dan buat **Database Password** yang kuat (simpan password ini, jangan sampai lupa).
5. Pilih *Region* terdekat (misal: Singapore) dan klik **Create New Project**.
6. Tunggu sekitar 2-3 menit sampai project selesai di-setup oleh Supabase.

### Langkah 2: Ambil API Key dan URL
Agar Flutter bisa terkoneksi ke Supabase, kamu butuh 2 hal:
1. Di dashboard Supabase kamu, lihat menu sebelah kiri, klik ikon **Settings** (Roda Gigi) -> **API**.
2. Copy dan simpan **Project URL**.
3. Copy dan simpan **Project API Keys (anon / public)**.
*(Kedua nilai ini nanti akan dimasukkan ke dalam `main.dart` Flutter kamu).*

### Langkah 3: Membuat Tabel menggunakan SQL Editor
Cara paling cepat membuat tabel adalah menggunakan SQL Editor, bukan manual klik-klik GUI.
1. Di menu kiri, klik ikon **SQL Editor** (ikon tanda kurung siku `>_`).
2. Klik **New Query**.
3. *Copy-Paste* kode SQL di bawah ini ke dalam editor, lalu klik tombol **Run** (atau tekan `Cmd/Ctrl + Enter`):

```sql
-- 1. Membuat tabel 'users'
CREATE TABLE users (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  exp INT DEFAULT 0,
  gold INT DEFAULT 0,
  rank TEXT DEFAULT 'E',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Membuat tabel 'feedbacks' (Untuk Kesan Pesan Matkul)
CREATE TABLE feedbacks (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Langkah 4: Matikan RLS (PENTING UNTUK DEADLINE CEPAT)
Secara default, Supabase memblokir semua operasi baca/tulis dari aplikasi. Karena kita berpacu dengan waktu (1 hari) dan password di-hash secara manual di aplikasi, kita akan matikan (disable) Row Level Security (RLS) agar Flutter bisa langsung Insert/Select tanpa error *403 Forbidden*.
1. Masih di **SQL Editor**, buka *New Query* lagi.
2. *Copy-Paste* dan **Run** kode ini:
```sql
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE feedbacks DISABLE ROW LEVEL SECURITY;
```
*(Catatan: Ini hanya disarankan untuk tugas kuliah/prototype cepat. Untuk production sungguhan, RLS harus diaktifkan).*

---

## BAGIAN 2: Setup Hive (Local Database)

Hive tidak butuh website atau server, semuanya murni berjalan di dalam aplikasi Flutter (disimpan di memori HP). Kita akan menyimpan Session Login dan Log Blockchain di sini.

### Langkah 1: Tambahkan Dependencies
Di project Flutter kamu, buka file `pubspec.yaml` dan tambahkan package berikut di bawah `dependencies:`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Supabase
  supabase_flutter: ^2.5.0
  
  # Hive & Path Provider
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.2
```
Jalankan `flutter pub get` di terminal.

### Langkah 2: Inisialisasi Database di `main.dart`
Buka file `lib/main.dart` kamu. Ubah fungsi `main()` menjadi seperti ini untuk menginisialisasi Hive dan Supabase secara bersamaan saat aplikasi dibuka:

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Wajib untuk binding sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Hive
  await Hive.initFlutter();
  
  // 2. Buka Box (Tabel/Koleksi) yang dibutuhkan
  await Hive.openBox('sessionBox');
  await Hive.openBox('blockchainBox');

  // 3. Inisialisasi Supabase (Ganti dengan URL dan Anon Key milikmu dari Langkah 2 Supabase)
  await Supabase.initialize(
    url: 'https://xyzcompany.supabase.co', // GANTI INI
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR...', // GANTI INI
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LevMax',
      theme: ThemeData.dark(), // Tema gelap ala Solo Leveling
      home: const LoginScreen(), // Nanti arahkan ke halaman loginmu
    );
  }
}
```

### Langkah 3: Cara Menggunakan Hive di Aplikasi (Cheat Sheet)
Nanti saat membuat fitur, kamu atau AI bisa menggunakan fungsi ini untuk berinteraksi dengan Hive:

**Menyimpan Session Login (Setelah berhasil cek password ke Supabase):**
```dart
var session = Hive.box('sessionBox');
session.put('isLoggedIn', true);
session.put('userId', userSupabaseId); // ID dari tabel users supabase
session.put('username', inputUsername);
```

**Mengecek apakah user sudah login (Bisa ditaruh di Splash Screen):**
```dart
var session = Hive.box('sessionBox');
bool isLoggedIn = session.get('isLoggedIn', defaultValue: false);
if (isLoggedIn) {
  // Arahkan ke Home Navigation
} else {
  // Arahkan ke Login
}
```

**Menyimpan Transaksi Blockchain (Untuk syarat Dosen):**
```dart
var blockchain = Hive.box('blockchainBox');
// Simpan map data. Pakai timestamp sebagai key agar unik
blockchain.put(DateTime.now().millisecondsSinceEpoch.toString(), {
  'item': 'Title Awakened',
  'timestamp': DateTime.now().toIso8601String(),
  'prev_hash': previousHashString,
  'current_hash': newlyCalculatedHash,
});
```