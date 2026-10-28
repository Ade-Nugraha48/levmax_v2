# Referensi & Arsitektur Class Diagram - LevMax

Dokumen ini menyajikan spesifikasi arsitektur berbasis objek (**Object-Oriented Architecture**) dan referensi **UML Class Diagram** lengkap untuk aplikasi **LevMax**. Dokumentasi ini dirancang agar dapat digunakan secara langsung sebagai acuan penyusunan diagram teknis, laporan tugas akhir, maupun pengujian integritas perangkat lunak.

---

## 1. Ikhtisar Arsitektur Perangkat Lunak

Aplikasi **LevMax** mengadopsi pola **Layered Architecture (Arsitektur Berlapis)** dengan pemisahan tanggung jawab (*Separation of Concerns*) yang ketat antara antarmuka pengguna (*UI Presentation*), model data (*Data/Domain Layer*), penyedia layanan logika bisnis (*Services Layer*), serta utilitas pendukung (*Utilities & Widgets*):

1. **Presentation Layer (`lib/screens/` & `lib/widgets/`):**
   * Menggunakan pendekatan `StatefulWidget` & `State<T>` murni tanpa library state management eksternal (GetX/Provider/Riverpod).
   * Bertanggung jawab murni pada siklus hidup widget, render tampilan (*responsive layout*), serta interaksi pengguna.
2. **Domain & Data Model Layer (`lib/models/`):**
   * Berisi struktur data murni (*Data Transfer Objects* & *Immutable Models*) yang dilengkapi serialisasi/deserialisasi (`toMap`, `fromMap`, `toJson`, `fromJson`, `copyWith`).
3. **Services & Business Logic Layer (`lib/services/`):**
   * Menerapkan *Facade Pattern* menggunakan static class/methods asinkron (`Future`, `Stream`) untuk menangani komunikasi jaringan remote (Supabase, S3 SigV4, Gemini AI, Web3 Sepolia Testnet), sensor perangkat (`sensors_plus`, `geolocator`), keamanan (`crypto`, `local_auth`), dan penyimpanan lokal (`hive`).
4. **Core Utilities Layer (`lib/utils/`):**
   * Menyediakan konstanta sistem (`AppConstants`), palet warna visual Solo Leveling (`AppColors`), tipografi (`AppTextStyles`), dan tema global (`AppTheme`).

---

## 2. Diagram Kelas UML Lengkap (Mermaid Class Diagram)

Berikut adalah diagram kelas UML interaktif yang memetakan seluruh kelas, atribut, metode, visibilitas, dan relasi antar-komponen di dalam proyek:

```mermaid
classDiagram
    direction TB

    %% ==========================================
    %% DOMAIN & DATA MODELS LAYER
    %% ==========================================
    class UserModel {
        +String id
        +String username
        +int exp
        +int gold
        +String rank
        +int hp
        +UserModel(id, username, exp, gold, rank, hp)
        +Map~String, dynamic~ toMap()
        +UserModel fromMap(Map~String, dynamic~ map)$
    }

    class QuestModel {
        +String id
        +String title
        +String category
        +int expReward
        +int goldReward
        +bool isCompleted
        +QuestModel(id, title, category, expReward, goldReward, isCompleted)
        +QuestModel copyWith(bool? isCompleted)
        +List~QuestModel~ defaultQuests$
    }

    class AlarmModel {
        +int id
        +int hour
        +int minute
        +bool isEnabled
        +String label
        +String ringtoneName
        +String? ringtonePath
        +double volume
        +bool vibrate
        +String formattedTime
        +AlarmModel defaultAlarm$
        +AlarmModel copyWith(...)
        +Map~String, dynamic~ toJson()
        +AlarmModel fromJson(Map~String, dynamic~ json)$
    }

    class AIPersona {
        +String name
        +String identity
        +String tone
        +String traits
        +String? avatarPath
        +AIPersona defaultPersona$
        +AIPersona copyWith(...)
        +Map~String, dynamic~ toJson()
        +AIPersona fromJson(Map~String, dynamic~ json)$
    }

    class FaceTemplate {
        +List~double~ vector
        +String dHash
        +String dHashV
        +String? thumbnailBase64
        +String createdAt
        +Map~String, dynamic~ toJson()
        +FaceTemplate fromJson(Map~String, dynamic~ json)$
        +String serialize()
        +FaceTemplate? deserialize(String jsonString)$
    }

    class FaceComparisonResult {
        +bool isMatch
        +double score
        +double cosineSimilarity
        +double dHashSimilarity
        +String message
    }

    %% ==========================================
    %% SERVICES LAYER
    %% ==========================================
    class SupabaseService {
        +SupabaseClient client$
        +Future~String?~ uploadAvatar(File imageFile, String userId)$
        +Future~bool~ updateAvatarUrl(String userId, String avatarUrl)$
        +Future~Map~String, dynamic~?~ register(String username, String passwordHash, int hp, String? avatarUrl)$
        +Future~Map~String, dynamic~?~ login(String username, String passwordHash)$
        +Future~bool~ updateUserStats(String userId, int? exp, int? gold, String? rank, int? hp)$
        +Future~bool~ submitFeedback(String userId, String message)$
    }

    class HiveService {
        +Box sessionBox$
        +Box blockchainBox$
        +Box questBox$
        +Future~void~ saveSession(...)$
        +Map~String, dynamic~ getSession()$
        +String? getActivePassword()$
        +Future~void~ saveAvatarUrl(String url)$
        +Future~void~ clearSession(bool clearBiometrics)$
        +Future~void~ saveBiometricCredentials(...)$
        +Map~String, String~? getBiometricCredentials()$
        +bool isBiometricEnabled()$
        +bool isFingerprintEnabled()$
        +bool isFaceScanEnabled()$
        +Future~void~ clearBiometricCredentials()$
        +Future~void~ saveEnrolledFace(String templateJson, String? thumbnailBase64)$
        +String? getEnrolledFaceTemplate()$
        +String? getEnrolledFaceThumbnail()$
        +bool hasEnrolledFace()$
        +Future~void~ clearEnrolledFace()$
        +Future~void~ saveBlockchainLog(String item, String prevHash, String currentHash, String? timestamp)$
        +List~Map~String, dynamic~~ getBlockchainLogs()$
        +String getLastBlockHash()$
        +Future~void~ saveAIAvatar(String path)$
        +String? getAIAvatar()$
        +Future~void~ saveAIPersona(AIPersona persona)$
        +AIPersona getAIPersona()$
        +Future~void~ saveAlarm(AlarmModel alarm)$
        +AlarmModel getAlarm()$
        +Future~void~ saveCompletedQuestsTodayCount(int count)$
        +int getCompletedQuestsTodayCount()$
        +List~String~ getOwnedTitles(String? userId)$
        +Future~void~ addOwnedTitle(String title, String? userId)$
        +String getEquippedTitle(String? userId)$
        +Future~void~ setEquippedTitle(String title, String? userId)$
    }

    class GeminiService {
        -String _apiKey$
        -String _currentPrompt$
        -GenerativeModel _model$
        -ChatSession _chatSession$
        -String _buildSystemPrompt(AIPersona? persona)$
        -GenerativeModel _createModel(String modelName, String systemPrompt)$
        +void updatePersona(AIPersona persona)$
        +void resetChat()$
        +Future~String~ sendMessage(String prompt)$
        +Future~String~ generateHiddenQuest(String rank, int exp)$
    }

    class HashService {
        +String hashSha256(String input)$
        +String createBlockchainHash(String username, String item, String timestamp, String prevHash)$
    }

    class NotifService {
        +Future~void~ init()$
        +Future~void~ showInstantNotification(String title, String body, int id)$
        +Future~void~ scheduleNotification(String title, String body, DateTime scheduledDate, int id)$
        +Future~void~ cancelNotification(int id)$
    }

    class AlarmService {
        +Future~void~ init()$
        +Future~void~ setAlarm(AlarmModel alarm)$
        +Future~void~ cancelAlarm(int id)$
        +Future~void~ playAlarmSound(String? ringtonePath)$
        +Future~void~ stopAlarmSound()$
    }

    class FaceRecognitionService {
        +Future~FaceTemplate?~ extractTemplateFromBytes(Uint8List bytes)$
        +FaceComparisonResult compareTemplates(FaceTemplate enrolled, FaceTemplate sample)$
        -List~double~ _extractVector(img.Image image)$
        -String _computeDHash(img.Image image)$
        -double _cosineSimilarity(List~double~ a, List~double~ b)$
    }

    class S3StorageService {
        +String accessKey$
        +String secretKey$
        +String host$
        +String region$
        +String bucket$
        +Future~String?~ uploadFile(String path, Uint8List bytes, String contentType)$
        -List~int~ _hmacSha256(List~int~ key, List~int~ data)$
        -List~int~ _getSignatureKey(String key, String dateStamp, String region, String service)$
    }

    %% ==========================================
    %% PRESENTATION & SCREENS LAYER
    %% ==========================================
    class LevMaxApp {
        +Widget build(BuildContext context)
    }

    class SplashScreen {
        +State~SplashScreen~ createState()
    }
    class _SplashScreenState {
        +void initState()
        -Future~void~ _checkSessionAndRoute()
        +Widget build(BuildContext context)
    }

    class MainNavigation {
        +int initialIndex
        +State~MainNavigation~ createState()
    }
    class _MainNavigationState {
        -int _currentIndex
        -List~Widget~ _tabs
        +void initState()
        +Widget build(BuildContext context)
    }

    class LoginScreen {
        +State~LoginScreen~ createState()
    }
    class _LoginScreenState {
        -TextEditingController _usernameController
        -TextEditingController _passwordController
        -bool _isLoading
        -bool _isObscure
        -Future~void~ _handleLogin()
        -Future~void~ _handleBiometricLogin()
        -Future~void~ _handleFaceScanLogin()
        +Widget build(BuildContext context)
    }

    class RegisterScreen {
        +State~RegisterScreen~ createState()
    }
    class _RegisterScreenState {
        -TextEditingController _usernameController
        -TextEditingController _passwordController
        -TextEditingController _confirmPasswordController
        -File? _selectedAvatar
        -bool _isLoading
        -Future~void~ _handleRegister()
        +Widget build(BuildContext context)
    }

    class TabHome {
        +State~TabHome~ createState()
    }
    class _TabHomeState {
        -String _username
        -String _rank
        -int _exp
        -int _gold
        -int _hp
        -List~QuestModel~ _quests
        -String _selectedCategory
        -String _searchQuery
        -void _loadUserData()
        -void _checkRankUp(int exp)
        -Future~void~ _scanHiddenDungeon()
        +Widget build(BuildContext context)
    }

    class TabMap {
        +State~TabMap~ createState()
    }
    class _TabMapState {
        -Position? _currentPosition
        -bool _isLoadingLocation
        -List~Marker~ _markers
        -Future~void~ _getCurrentLocation()
        -Future~void~ _claimPortalReward(LatLng portalCoord)
        +Widget build(BuildContext context)
    }

    class TabGame {
        +State~TabGame~ createState()
    }
    class _TabGameState {
        -StreamSubscription? _gyroscopeSubscription
        -double _ballX
        -double _ballY
        -double _targetZoneTime
        -bool _isPlaying
        -bool _hasWonToday
        -void _startListeningGyroscope()
        -void _checkGameWin()
        +Widget build(BuildContext context)
    }

    class TabShop {
        +State~TabShop~ createState()
    }
    class _TabShopState {
        -int _gold
        -List~String~ _ownedTitles
        -Map~String, String~ _itemTxHashes
        -double _usdToIdr
        -double _usdToEur
        -String? _purchasingItem
        -void _loadSessionAndLedger()
        -Future~void~ _fetchLiveExchangeRates()
        -Future~Web3Client~ _getWorkingWeb3Client(String defaultRpc)
        -Future~void~ _buyTitle(String itemName, int price, String rarity)
        -Future~void~ _openEtherscan(String txHash)
        -void _showBlockchainLedger()
        -void _showPrivateKeyConfigDialog()
        -Future~void~ _executeResetPurchases(bool silent)
        +Widget build(BuildContext context)
    }

    class TabProfile {
        +State~TabProfile~ createState()
    }
    class _TabProfileState {
        -String _username
        -String _rank
        -String? _avatarUrl
        -TextEditingController _feedbackController
        -bool _isSubmittingFeedback
        -Future~void~ _loadProfile()
        -Future~void~ _pickAndUploadAvatar()
        -Future~void~ _submitFeedback()
        -Future~void~ _logout()
        +Widget build(BuildContext context)
    }

    class ChatAIScreen {
        +State~ChatAIScreen~ createState()
    }
    class _ChatAIScreenState {
        -List~Map~String, String~~ _messages
        -TextEditingController _textController
        -bool _isSending
        -AIPersona _currentPersona
        -Future~void~ _sendMessage()
        -void _showPersonaSettingsDialog()
        +Widget build(BuildContext context)
    }

    class QuestSensorScreen {
        +State~QuestSensorScreen~ createState()
    }
    class _QuestSensorScreenState {
        -StreamSubscription? _accelerometerSubscription
        -int _shakeCount
        -double _lastMagnitude
        -void _startAccelerometer()
        -void _completeSensorQuest()
        +Widget build(BuildContext context)
    }

    class WorkoutHubScreen {
        +State~WorkoutHubScreen~ createState()
    }
    class _WorkoutHubScreenState {
        -int _selectedTab
        -bool _cameraPoseDetectionActive
        +Widget build(BuildContext context)
    }

    class AppearanceQuestScreen {
        +State~AppearanceQuestScreen~ createState()
    }
    class _AppearanceQuestScreenState {
        -List~bool~ _checklistValues
        -Future~void~ _submitProtocol()
        +Widget build(BuildContext context)
    }

    class StudyFocusScreen {
        +State~StudyFocusScreen~ createState()
    }
    class _StudyFocusScreenState {
        -int _remainingSeconds
        -bool _isRunning
        -Timer? _timer
        -void _startTimer()
        -void _finishStudySession()
        +Widget build(BuildContext context)
    }

    %% ==========================================
    %% REUSABLE WIDGETS & DIALOGS
    %% ==========================================
    class AvatarImage {
        +String? avatarUrl
        +double radius
        +Widget build(BuildContext context)
    }

    class AvatarAdjustDialog {
        +File imageFile
        +State~AvatarAdjustDialog~ createState()
    }
    class _AvatarAdjustDialogState {
        -double _scale
        -Offset _offset
        -Future~Uint8List~ _cropAndExport()
        +Widget build(BuildContext context)
    }

    class FaceScanDialog {
        +bool isEnrollmentMode
        +State~FaceScanDialog~ createState()
    }
    class _FaceScanDialogState {
        -CameraController? _cameraController
        -bool _isProcessing
        -Future~void~ _captureAndProcessFace()
        +Widget build(BuildContext context)
    }

    %% ==========================================
    %% UTILITIES & DESIGN SYSTEM
    %% ==========================================
    class AppConstants {
        +String appName$
        +String sessionBox$
        +String blockchainBox$
        +String questBox$
        +double radiusSmall$
        +double radiusMedium$
        +double radiusLarge$
    }

    class AppColors {
        +Color primary$
        +Color neonViolet$
        +Color accent$
        +Color background$
        +Color surface$
        +Color gold$
        +Color hpRed$
        +Color manaCyan$
        +LinearGradient monarchGradient$
    }

    class AppTheme {
        +ThemeData darkTheme$
    }

    %% ==========================================
    %% RELATIONSHIPS & ASSOCIATIONS
    %% ==========================================
    %% Inheritance / State Binding
    SplashScreen ..> _SplashScreenState : creates
    MainNavigation ..> _MainNavigationState : creates
    LoginScreen ..> _LoginScreenState : creates
    RegisterScreen ..> _RegisterScreenState : creates
    TabHome ..> _TabHomeState : creates
    TabMap ..> _TabMapState : creates
    TabGame ..> _TabGameState : creates
    TabShop ..> _TabShopState : creates
    TabProfile ..> _TabProfileState : creates
    ChatAIScreen ..> _ChatAIScreenState : creates
    QuestSensorScreen ..> _QuestSensorScreenState : creates
    WorkoutHubScreen ..> _WorkoutHubScreenState : creates
    AppearanceQuestScreen ..> _AppearanceQuestScreenState : creates
    StudyFocusScreen ..> _StudyFocusScreenState : creates
    AvatarAdjustDialog ..> _AvatarAdjustDialogState : creates
    FaceScanDialog ..> _FaceScanDialogState : creates

    %% Main Navigation Composition
    _MainNavigationState *-- TabHome
    _MainNavigationState *-- TabMap
    _MainNavigationState *-- TabGame
    _MainNavigationState *-- TabShop
    _MainNavigationState *-- TabProfile

    %% Screen Navigation & Invocations
    _SplashScreenState ..> LoginScreen : navigates
    _SplashScreenState ..> MainNavigation : navigates
    _SplashScreenState ..> HiveService : checks session
    _LoginScreenState ..> RegisterScreen : navigates
    _LoginScreenState ..> MainNavigation : navigates
    _LoginScreenState ..> SupabaseService : calls login
    _LoginScreenState ..> HashService : hashes password
    _LoginScreenState ..> HiveService : saves session & reads bio
    _LoginScreenState ..> FaceScanDialog : opens
    _RegisterScreenState ..> SupabaseService : calls register
    _RegisterScreenState ..> HashService : hashes password
    _RegisterScreenState ..> S3StorageService : uploads avatar
    _RegisterScreenState ..> AvatarAdjustDialog : opens

    %% Tab Features Invocations
    _TabHomeState *-- QuestModel : manages
    _TabHomeState ..> ChatAIScreen : routes to
    _TabHomeState ..> WorkoutHubScreen : routes to
    _TabHomeState ..> QuestSensorScreen : routes to
    _TabHomeState ..> AppearanceQuestScreen : routes to
    _TabHomeState ..> StudyFocusScreen : routes to
    _TabHomeState ..> GeminiService : invokes generateHiddenQuest
    _TabHomeState ..> HiveService : reads/writes user stats
    _TabHomeState ..> NotifService : schedules daily reminder
    _TabHomeState ..> AlarmService : triggers hunter alarm

    _TabMapState ..> HiveService : reads/writes location reward
    _TabMapState ..> SupabaseService : syncs gold & exp
    _TabGameState ..> HiveService : reads/writes daily win

    _TabShopState ..> HiveService : reads/writes titles & ledger
    _TabShopState ..> SupabaseService : syncs purchase gold
    _TabShopState ..> AlarmService : references

    _TabProfileState ..> SupabaseService : submits feedback & updates avatar
    _TabProfileState ..> S3StorageService : uploads custom avatar
    _TabProfileState ..> HiveService : reads stats & clears session
    _TabProfileState ..> LoginScreen : routes on logout
    _TabProfileState ..> AvatarAdjustDialog : opens
    _TabProfileState ..> FaceScanDialog : opens enrollment

    %% Feature Screen Dependencies
    _ChatAIScreenState ..> GeminiService : sends prompts
    _ChatAIScreenState ..> HiveService : reads/writes persona
    _ChatAIScreenState *-- AIPersona : holds
    _FaceScanDialogState ..> FaceRecognitionService : calls extract & compare
    FaceRecognitionService ..> FaceTemplate : produces
    FaceRecognitionService ..> FaceComparisonResult : produces

    %% Service & Model Dependencies
    GeminiService ..> AIPersona : uses
    AlarmService ..> AlarmModel : configures
    HiveService ..> AlarmModel : serializes
    HiveService ..> AIPersona : serializes
    SupabaseService ..> UserModel : maps to
    _TabProfileState ..> AvatarImage : renders
```

---

## 3. Rincian Komponen per Layer

### 3.1 Domain & Data Models (`lib/models/`)

Lapisan model mendefinisikan entitas data utama yang bersifat deterministik dan *immutable*:

| Kelas Model | Atribut Utama | Metode Utama | Deskripsi / Peran |
| :--- | :--- | :--- | :--- |
| **`UserModel`** | `id`, `username`, `exp`, `gold`, `rank`, `hp` | `toMap()`, `fromMap()` | DTO profil Hunter yang bersinkronisasi dengan tabel `users` di remote Supabase. |
| **`QuestModel`** | `id`, `title`, `category`, `expReward`, `goldReward`, `isCompleted` | `copyWith()`, `defaultQuests` | Entitas tugas leveling harian (Workout, Cardio, Appearance, Study). |
| **`AlarmModel`** | `id`, `hour`, `minute`, `isEnabled`, `label`, `ringtoneName`, `ringtonePath`, `volume`, `vibrate` | `formattedTime`, `copyWith()`, `toJson()`, `fromJson()`, `defaultAlarm` | Konfigurasi alarm jadwal bangun & latihan Hunter (*Hunter Awakening Siren*). |
| **`AIPersona`** | `name`, `identity`, `tone`, `traits`, `avatarPath` | `copyWith()`, `toJson()`, `fromJson()`, `defaultPersona` | Kustomisasi kepribadian, gaya bahasa, dan identitas asisten AI (Gemini). |
| **`FaceTemplate`** | `vector` (128-dim), `dHash`, `dHashV`, `thumbnailBase64`, `createdAt` | `toJson()`, `fromJson()`, `serialize()`, `deserialize()` | Representasi vektor fitur biometrik wajah Hunter untuk otentikasi cepat. |
| **`FaceComparisonResult`** | `isMatch`, `score`, `cosineSimilarity`, `dHashSimilarity`, `message` | Konstruktor | Objek evaluasi kecocokan wajah hasil perbandingan Cosine & Hamming distance. |

---

### 3.2 Services Layer (`lib/services/`)

Lapisan logika bisnis dan gateway infrastruktur eksternal:

| Kelas Service | Tanggung Jawab Utama | Dependencies / Stack Terkait |
| :--- | :--- | :--- |
| **`SupabaseService`** | Operasi CRUD tabel `users`, autentikasi registrasi & login, mutasi EXP & Gold, serta pengiriman kesan pesan (`feedbacks`). | `supabase_flutter`, PostgreSQL Remote |
| **`HiveService`** | Penyimpanan lokal NoSQL ultra-cepat: `sessionBox` (sesi pengguna, kredensial biometrik, state title), `blockchainBox` (buku besar transaksi), dan `questBox`. | `hive`, `hive_flutter` |
| **`GeminiService`** | Integrasi AI Google Gemini (`gemini-3.5-flash-lite` dengan failover ke `gemini-3.5-flash`). Menangani Chat AI edukatif dan generator misi rahasia (*Hidden Quest*). | `google_generative_ai` |
| **`HashService`** | Algoritma enkripsi kriptografis SHA-256 untuk hashing password sebelum dikirim ke remote server. | `crypto`, `dart:convert` |
| **`NotifService`** | Pengaturan push notification lokal di Android/iOS untuk pengingat disiplin quest harian. | `flutter_local_notifications` |
| **`AlarmService`** | Pemutaran nada alarm sistem, kontrol volume presisi, dan penjadwalan alarm bangun Hunter. | `audioplayers`, `flutter_local_notifications` |
| **`FaceRecognitionService`** | Ekstraksi fitur citra wajah (*feature extraction*), kalkulasi gradien normalisasi, dan pencocokan template Cosine + dHash. | `image`, `dart:math` |
| **`S3StorageService`** | Pengunggahan foto profil ke Supabase Storage via protokol S3 kompatibel dengan penandatanganan AWS Signature Version 4 (SigV4). | `crypto` (HMAC-SHA256), `dart:io` |

---

### 3.3 Presentation Layer - Screens & Tabs (`lib/screens/`)

Lapisan antarmuka pengguna yang terbagi ke dalam alur otentikasi, navigasi induk, dan tab fitur:

#### A. Entry & Otentikasi (`screens/` & `screens/auth/`)
* **`LevMaxApp`:** Root Application Widget yang menerapkan `AppTheme.darkTheme` dan mendaftarkan `SplashScreen` sebagai initial route.
* **`SplashScreen` & `_SplashScreenState`:** Memeriksa status sesi di Hive (`HiveService.getSession()`). Jika user aktif, langsung dialihkan ke `MainNavigation`; jika belum, dialihkan ke `LoginScreen`.
* **`LoginScreen` & `_LoginScreenState`:** Form autentikasi dengan validasi SHA-256 password ke Supabase, tombol sidik jari (`local_auth`), serta otentikasi pindai wajah (*Face Recognition*).
* **`RegisterScreen` & `_RegisterScreenState`:** Pendaftaran akun baru, hashing client-side, upload avatar profil ke S3, dan inisialisasi rank awal F.

#### B. Navigasi & Tab Utama (`screens/` & `screens/tabs/`)
* **`MainNavigation` & `_MainNavigationState`:** Mengatur 5 Tab utama menggunakan `IndexedStack` agar state tiap tab tidak ter-reload saat perpindahan tab.
* **`TabHome` & `_TabHomeState`:** Dashboard status Hunter (Rank F-S, EXP Bar, HP, Gold), konversi 4 zona waktu server (WIB, WITA, WIT, London GMT), pencarian & filter quest, serta tombol **"SCAN HIDDEN DUNGEON"** (LLM Hidden Quest Generator).
* **`TabMap` & `_TabMapState`:** Peta OpenStreetMap (`flutter_map`) dengan pelacakan GPS (`geolocator`), penanda portal dungeon kampus, dan verifikasi radius $\le 100$ meter untuk klaim reward.
* **`TabGame` & `_TabGameState`:** Mini game latihan mana menggunakan sensor Gyroscope (`sensors_plus`), mendeteksi kemiringan fisik HP dengan *throttling* 100ms untuk menahan bola mana di zona hijau selama 5 detik.
* **`TabShop` & `_TabShopState`:** Toko Title Hunter on-chain di **Ethereum Sepolia Testnet** (`web3dart`), valuasi kurs valas real-time (`open.er-api.com`), ledger riwayat transaksi, verifikasi live di Etherscan, dan tombol reset inventori.
* **`TabProfile` & `_TabProfileState`:** Visual avatar Hunter, ringkasan capaian, form multi-line pengiriman kesan pesan mata kuliah ke Supabase, penyesuaian personifikasi AI, dan tombol logout.

#### C. Fitur Khusus & Modal (`screens/features/`)
* **`ChatAIScreen`:** Halaman interaksi percakapan dengan AI Gemini yang karakternya dapat dipersonalisasi melalui `AIPersona`.
* **`QuestSensorScreen`:** Layar khusus quest kardio yang membaca sensor accelerometer (pengguna mengocok HP 50 kali).
* **`WorkoutHubScreen`:** Pusat latihan fisik komprehensif (Push-up, Sit-up, Pull-up, Squat) dengan panduan repetisi.
* **`AppearanceQuestScreen`:** Modal protokol perawatan penampilan harian 5 langkah (skincare pagi & malam).
* **`StudyFocusScreen`:** Timer fokus belajar 30 menit dengan countdown real-time.

---

### 3.4 Reusable Widgets & Dialogs (`lib/widgets/`)

* **`AvatarImage`:** Widget penampil avatar serbaguna yang otomatis menangani URL Supabase S3, path file lokal, dan placeholder inisial nama.
* **`AvatarAdjustDialog` & `_AvatarAdjustDialogState`:** Dialog penyesuaian skala (*zoom*), pergeseran (*pan*), dan *cropping* gambar profil sebelum diunggah.
* **`FaceScanDialog` & `_FaceScanDialogState`:** Dialog kamera live untuk pendaftaran (*enrollment*) atau verifikasi login wajah biometrik.

---

### 3.5 Utilities & Design System (`lib/utils/`)

* **`AppConstants`:** Nama aplikasi (`LevMax`), key box Hive (`sessionBox`, `blockchainBox`, `questBox`), dan konstanta border radius.
* **`AppColors`:** Warna bertema Solo Leveling (Black Deep Void, Shadow Monarch Purple `#8A2BE2`, Neon Violet `#B026FF`, Mana Cyan `#00E5FF`, Rank Colors F s/d S).
* **`AppTextStyles`:** Standar tipografi berbasis Google Fonts (`Orbitron`, `Space Grotesk`, `Plus Jakarta Sans`).
* **`AppTheme`:** Konfigurasi `ThemeData.dark()` lengkap dengan styling tombol, input field, dialog, dan snackbar.

---

## 4. Matriks Relasi & Dependensi Antar-Komponen

| Kelas Sumber | Kelas Tujuan | Jenis Relasi | Deskripsi Interaksi Teknis |
| :--- | :--- | :--- | :--- |
| `MainNavigation` | `TabHome`, `TabMap`, `TabGame`, `TabShop`, `TabProfile` | **Composition (`*--`)** | Menampung dan memelihara state kelima tab utama dalam `IndexedStack`. |
| `_TabHomeState` | `QuestModel` | **Aggregation (`o--`)** | Mengelola daftar quest aktif, pencarian keyword, filter kategori, dan status selesai. |
| `_TabHomeState` | `GeminiService` | **Dependency (`..>`)** | Memanggil fungsi `generateHiddenQuest(rank, exp)` untuk membuat narasi quest rahasia. |
| `_TabHomeState` | `NotifService` | **Dependency (`..>`)** | Memicu notifikasi lokal pengingat quest harian. |
| `_TabHomeState` | `AlarmService` | **Dependency (`..>`)** | Mengonfigurasi dan mengaktifkan nada sirene latihan Hunter. |
| `_TabShopState` | `HiveService` | **Dependency (`..>`)** | Membaca kepemilikan Title, mencatat blok baru, dan membaca log transaksi. |
| `_TabShopState` | `SupabaseService` | **Dependency (`..>`)** | Menyinkronkan pengurangan Gold user setelah transaksi on-chain berhasil. |
| `_TabShopState` | `web3dart` (External) | **Association (`-->`)** | Menghubungkan ke RPC Sepolia, menandatangani transaksi dengan Private Key, dan mengirim ke blockchain publik. |
| `_TabMapState` | `Geolocator` (External) | **Association (`-->`)** | Membaca posisi GPS real-time dan menghitung jarak radius ke marker portal kampus. |
| `_TabGameState` | `sensors_plus` (External) | **Association (`-->`)** | Membuka stream `gyroscopeEvents` untuk kalkulasi pergerakan bola di kanvas. |
| `_QuestSensorScreenState` | `sensors_plus` (External) | **Association (`-->`)** | Membuka stream `accelerometerEvents` untuk menghitung guncangan fisik perangkat (50x). |
| `_LoginScreenState` | `SupabaseService` | **Dependency (`..>`)** | Mengirimkan username dan password-hash untuk diverifikasi remote. |
| `_LoginScreenState` | `HashService` | **Dependency (`..>`)** | Mengenkripsi password inputan menjadi hash heksadesimal SHA-256. |
| `_LoginScreenState` | `HiveService` | **Dependency (`..>`)** | Menyimpan session token login dan memeriksa ketersediaan kredensial biometrik. |
| `_LoginScreenState` | `FaceScanDialog` | **Dependency (`..>`)** | Membuka modal kamera untuk verifikasi biometrik wajah. |
| `_RegisterScreenState` | `S3StorageService` | **Dependency (`..>`)** | Mengunggah foto profil yang dipilih langsung ke bucket Supabase S3 via SigV4. |
| `_TabProfileState` | `SupabaseService` | **Dependency (`..>`)** | Memperbarui avatar URL dan melakukan insert ke tabel `feedbacks`. |
| `_ChatAIScreenState` | `GeminiService` | **Dependency (`..>`)** | Mengirim prompt chat dan menerima respon streaming/text dari model Gemini. |
| `_ChatAIScreenState` | `AIPersona` | **Aggregation (`o--`)** | Membaca dan memutakhirkan model personifikasi asisten AI yang aktif. |
| `FaceScanDialog` | `FaceRecognitionService` | **Dependency (`..>`)** | Memproses frame citra kamera menjadi `FaceTemplate` dan melakukan pencocokan template. |

---

## 5. Pola Desain Perangkat Lunak (Design Patterns Applied)

1. **Facade Pattern (Services Layer):**
   * Kelas seperti `SupabaseService`, `HiveService`, dan `GeminiService` menyediakan antarmuka tingkat tinggi yang sederhana bagi UI tanpa mengekspos kompleksitas komunikasi protokol SQL, serialization binary Hive, maupun REST body formatting Gemini.
2. **State Pattern / Reactive UI (`StatefulWidget`):**
   * Perubahan status (misal EXP naik, Gold berkurang saat belanja on-chain, checklist quest selesai) segera memicu pembaruan antarmuka secara reaktif melalui pemanggilan `setState()`.
3. **Observer / Stream Pattern (Sensors & Location):**
   * Komponen sensor gerak pada `TabGame` (Gyroscope), `QuestSensorScreen` (Accelerometer), dan GPS pada `TabMap` mendengarkan aliran data (*stream subscription*) asinkron dan otomatis membatalkannya (`cancel()`) saat siklus hidup widget berakhir (`dispose()`) guna mencegah *memory leak*.
4. **Data Transfer Object (DTO) & Immutability:**
   * Model data (`UserModel`, `QuestModel`, `AlarmModel`, `AIPersona`) didefinisikan menggunakan *immutable fields* (`final`) dan dilengkapi metode `copyWith()` untuk mutasi state yang aman (*pure functional mutation*).
5. **Adapter / Driver Pattern (Web3 & S3 Protocol):**
   * Penanganan blockchain Ethereum Sepolia mengadaptasi library `web3dart` ke alur transaksi lokal LevMax, serta `S3StorageService` mengadaptasi protokol REST mentah ke standar AWS Signature Version 4.

---

## 6. Panduan Ekspor & Visualisasi Diagram

Untuk menyertakan diagram kelas ini ke dalam dokumen skripsi, laporan proyek akhir, atau presentasi:

1. **Mermaid Live Editor:**
   * Buka [https://mermaid.live/](https://mermaid.live/).
   * Salin kode diagram dari [Bagian 2](#2-diagram-kelas-uml-lengkap-mermaid-class-diagram).
   * Ekspor langsung dalam format **PNG**, **SVG**, atau **PDF** beresolusi tinggi.
2. **Render Otomatis di GitHub & VS Code:**
   * File markdown ini akan otomatis merender grafik kelas secara interaktif saat dibuka di repositori GitHub maupun ekstensi *Markdown Preview Mermaid Support* di VS Code / IDE Antigravity.
