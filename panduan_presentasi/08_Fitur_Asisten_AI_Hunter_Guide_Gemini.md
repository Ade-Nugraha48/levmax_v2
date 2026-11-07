# 08. Fitur Asisten AI Hunter Guide (Google Gemini LLM)

---

## 1. Gambaran Singkat Fitur
Fitur ini menyediakan asisten kecerdasan buatan (*Artificial Intelligence* / AI) interaktif berbasis model bahasa besar (*Large Language Model* / LLM) Google Gemini, yang bertindak sebagai pemandu pribadi Hunter (*System Guide*) untuk memberikan konsultasi seputar latihan fisik, nutrisi, pembentukan disiplin, serta mampu menciptakan narasi misi rahasia (*Hidden Quest*) dramatis secara otomatis.

---

## 2. Konsep & Cara Pembuatannya
Untuk memberikan pengalaman AI yang benar-benar menyatu dengan tema Solo Leveling:
1. **Integrasi Model LLM Google Gemini:**
   - Menggunakan pustaka resmi `google_generative_ai`.
   - Menggunakan model performa cepat dan hemat memori: `gemini-3.5-flash-lite`, dilengkapi mekanisme pengalihan otomatis (*fallback*) ke `gemini-3.5-flash` apabila model utama mengalami antrean atau kendala kuota.
2. **Kustomisasi Persona AI Dinamis (*Prompt Engineering via Hive*):**
   - Pengguna tidak hanya mengobrol dengan bot kaku yang biasa. Pengguna dapat mengubah kepribadian asisten AI sesuka hati melalui menu setelan:
     - **Nama:** (Contoh: *SYSTEM GUIDE*, *BERU*, *IGRIS*, *COACH ARDI*)
     - **Identitas / Peran:** (*HUNTER SUPPORT AI*, *PANGLIMA BAYANGAN*, *PERSONAL TRAINER*)
     - **Gaya Bahasa / Tone:** (*Formal & Dingin*, *Santai & Gaul*, *Tsundere & Tegas*, *Penyemangat Ceria*)
     - **Sifat & Karakter:** (*Tegas, analitis, perhatian pada form gerakan, dll*)
     - **Foto Avatar AI:** Bisa diganti menggunakan gambar custom dari galeri ponsel.
   - Konfigurasi ini disimpan persisten di Hive dan dirangkai secara dinamis menjadi **Instruksi Sistem (*System Instruction / System Prompt*)** sebelum percakapan dikirim ke Gemini.
3. **Generator Misi Rahasia Otomatis (*Hidden Quest Generator*):**
   - Di halaman Beranda, ada tombol AI untuk men-generate misi rahasia dadakan.
   - Prompt AI dirancang khusus untuk membaca status Rank dan EXP pemain saat ini, lalu menyusun narasi misi darurat bertema *Solo Leveling Penalty Zone* yang unik dan dramatis.

---

## 3. Alur Kerja dari Layar ke Backend (Step-by-Step)

### A. Alur Mengubah Kepribadian Persona AI:
1. **Di Layar Pengguna (UI):** Pengguna menekan ikon otak/setelan di pojok kanan atas layar chat.
2. **Pengisian Form:** Muncul modal dialog bertema neon. Pengguna bisa memilih preset yang sudah disediakan (misal gaya bicara "Tsundere" atau "Militer Dingin") atau mengetik kepribadian sendiri, lalu menekan **"SAVE PERSONA"**.
3. **Penyimpanan ke Hive:** Data disimpan ke Hive melalui `HiveService.saveAIPersona()`.
4. **Penyusunan Ulang Prompt Sistem:** Fungsi `GeminiService.updatePersona()` langsung membangun ulang kalimat *System Instruction* dan menginisialisasi sesi obrolan baru (`startChat()`) dengan memori kepribadian yang baru.

### B. Alur Mengirim Pesan & Konsultasi Kebugaran:
1. **Di Layar Pengguna (UI):** Pengguna mengetik pertanyaan di kolom chat (misalnya: *"Bagaimana menu makanan tinggi protein untuk pemula setelah latihan kardio?"*) lalu menekan tombol kirim.
2. **Pemrosesan di Balik Layar:** Pesan pengguna langsung ditempelkan ke daftar gelembung chat layar agar antarmuka responsif, dan indikator titik tiga animasi (*typing indicator*) menyala.
3. **Pengiriman ke Google Gemini Server:**
   - Aplikasi memanggil `GeminiService.sendMessage(prompt)`.
   - Google Gemini membaca instruksi kepribadian sistem + pertanyaan pengguna, lalu mengolah jawaban dengan gaya bicara yang sudah diatur (misal jika diatur dingin/militer, AI akan membalas dengan gaya komandan Solo Leveling yang tegas).
4. **Pengembalian Respon ke Layar:** Respon diterima dalam format teks terstruktur (Markdown) yang rapi lengkap dengan poin-poin tebal (*bold bullet points*), lalu dirender indah menggunakan widget `MarkdownBody`.

### C. Alur Pembuatan Misi Rahasia (Hidden Quest):
1. **Di Layar Beranda (UI):** Pengguna menekan tombol "GENERATE HIDDEN QUEST (AI)".
2. **Pemrosesan Prompt:** Aplikasi mengambil variabel `_rank` dan `_currentExp`, lalu menyusun prompt tersembunyi ke Gemini: *"Buatkan satu deskripsi misi rahasia epik ala Solo Leveling untuk Hunter Rank X dengan Y EXP..."*.
3. **Tampilan Pop-Up:** Muncul pop-up dialog dramatis berwarna merah/ungu bertuliskan *[EMERGENCY SYSTEM ALERT]* berisi skenario misi rahasia khusus yang dibuat langsung oleh kecerdasan buatan.

---

## 4. Peta Lokasi File Kode Terkait

| Nama File | Peran Utama di Aplikasi |
|:----------|:------------------------|
| `lib/screens/features/chat_ai_screen.dart` | Antarmuka obrolan (*Chat UI*), modal pengaturan personifikasi AI, dan perender balasan Markdown. |
| `lib/services/gemini_service.dart` | Logika integrasi SDK Gemini, perakit *System Instruction*, eksekusi multi-turn chat, fallback model, dan generator *Hidden Quest*. |
| `lib/models/ai_persona_model.dart` | Model data kepribadian AI (nama, identitas, nada, sifat, avatar) dan fungsi serialisasi JSON. |
| `lib/services/hive_service.dart` | Fungsi penyimpanan konfigurasi persona AI ke database lokal Hive. |
| `lib/screens/tabs/tab_home.dart` | Pemicu eksekusi generator Hidden Quest dari halaman beranda. |

---

## 5. Contekan Kalimat Presentasi (Siap Baca)
> *"Pada aspek integrasi Kecerdasan Buatan (AI/LLM), kami memanfaatkan **Google Gemini API** yang kami implementasikan ke dalam dua fitur utama: **Asisten Konsultasi Kebugaran Hunter** dan **Generator Misi Rahasia (*Hidden Quest*)**. Yang membuat implementasi AI kami unggul adalah adanya **fitur kustomisasi kepribadian (*Persona AI*)**: pengguna dapat mengatur nama, peran, gaya bahasa (seperti formal militer, santai, maupun tegas), serta sifat asisten yang disimpan di database lokal Hive. Sistem kami secara dinamis merekayasa prompt instruksi sistem (*System Instruction*) sebelum pesan dikirim ke LLM Gemini, sehingga asisten selalu membalas konsisten dengan persona karakternya menggunakan format Markdown yang rapi."*

