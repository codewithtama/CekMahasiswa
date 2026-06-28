# PDDikti Explorer (CekMahasiswa) 🎓

Aplikasi mobile Flutter modern yang dirancang untuk mencari dan melihat informasi detail dari data pendidikan tinggi di Indonesia, bersumber langsung dari **PDDIKTI (Pangkalan Data Pendidikan Tinggi) Kemdikbud API**.

---

## ✨ Fitur Utama

Aplikasi ini memiliki fitur lengkap untuk kebutuhan pencarian civitas akademika:

*   🔍 **Pencarian Multi-Kategori**: Cari data dengan mudah di kategori berikut:
    *   **Mahasiswa**: Status aktif, riwayat studi per semester, program studi, dan institusi tempat belajar.
    *   **Dosen**: Profil dosen, riwayat pendidikan, serta riwayat mengajar per semester.
    *   **Program Studi (Prodi)**: Informasi status, jenjang pendidikan, akreditasi, dan jumlah mahasiswa/dosen.
    *   **Perguruan Tinggi (PT)**: Informasi detail institusi, akreditasi, alamat, rasio dosen-mahasiswa, serta tautan ke situs web resmi.
*   📊 **Visualisasi Data Detail**: Informasi ditampilkan secara terstruktur dengan kartu (card) detail yang informatif.
*   📄 **Ekspor & Berbagi PDF**: Cetak atau bagikan rangkuman status civitas akademika dalam format PDF resmi dengan desain yang rapi dan profesional.
*   🌓 **Mode Gelap / Terang (Theme Toggle)**: Pilihan tema gelap dan terang demi kenyamanan visual pengguna.
*   🕒 **Riwayat Pencarian Lokal**: Menyimpan pencarian terakhir Anda di perangkat lokal untuk kemudahan akses kembali.
*   🛡️ **Persetujuan Pengguna (Consent)**: Menghormati privasi data dengan halaman persetujuan di awal penggunaan.

---

## 🛠️ Stack Teknologi

Aplikasi ini menggunakan pustaka dan standar pengembangan terbaik di ekosistem Flutter:

*   **Framework**: [Flutter SDK](https://flutter.dev) (Dart 3)
*   **State Management**: [Flutter Riverpod](https://pub.dev/packages/flutter_riverpod) dengan [Riverpod Generator](https://pub.dev/packages/riverpod_generator) untuk struktur state yang kuat dan *type-safe*.
*   **Navigation & Routing**: [GoRouter](https://pub.dev/packages/go_router) untuk navigasi berbasis deklaratif yang mulus.
*   **Network Client**: [Dio Client](https://pub.dev/packages/dio) untuk *HTTP request* yang dioptimalkan dengan konfigurasi *interceptor*.
*   **Penyimpanan Lokal**: [Shared Preferences](https://pub.dev/packages/shared_preferences) untuk menyimpan riwayat pencarian, pilihan tema, dan status *consent*.
*   **PDF Generation & Sharing**: [PDF](https://pub.dev/packages/pdf), [Printing](https://pub.dev/packages/printing), dan [Share Plus](https://pub.dev/packages/share_plus) untuk mengekspor serta membagikan file PDF.
*   **UI/UX Enhancements**: [Cached Network Image](https://pub.dev/packages/cached_network_image), [Shimmer Effect](https://pub.dev/packages/shimmer), dan [Google Fonts](https://pub.dev/packages/google_fonts).

---

## 📂 Struktur Proyek

Aplikasi dikembangkan menggunakan arsitektur **Feature-First / Clean Architecture** untuk menjaga modularitas dan kemudahan *maintenance*:

```
lib/
├── core/
│   ├── constants/       # Konstanta API dan endpoint
│   ├── network/         # Dio Client & penanganan error API
│   ├── router/          # Konfigurasi navigasi GoRouter
│   ├── theme/           # Pengaturan tema terang & gelap
│   └── utils/           # Helper utilitas (misal: share_helper.dart)
├── features/
│   ├── home/            # Halaman awal & persetujuan pengguna (consent)
│   ├── search/          # Modul pencarian (model, repo, provider, screen, & widgets)
│   ├── detail/          # Halaman profil detail (mahasiswa, dosen, prodi, PT)
│   └── settings/        # Pengaturan aplikasi (tema & preferensi)
└── main.dart            # Titik masuk utama aplikasi (main entry point)
```

---

## 🚀 Cara Menjalankan Proyek

### 1. Prasyarat (Prerequisites)
Pastikan Anda telah menginstal:
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi terbaru direkomendasikan)
*   Dart SDK (sudah terpaket bersama Flutter)

### 2. Kloning Proyek & Instal dependensi
```bash
flutter pub get
```

### 3. Generate Kode (Riverpod Annotations)
Karena proyek ini menggunakan generator otomatis untuk Riverpod, jalankan `build_runner` untuk menghasilkan file-file *.g.dart:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
*(Untuk pengembangan aktif, Anda dapat menjalankan `flutter pub run build_runner watch`)*

### 4. Jalankan Aplikasi
```bash
flutter run
```

---

## 🔒 Catatan Keamanan & Privasi
Aplikasi ini memanfaatkan data publik yang tersedia melalui API resmi PDDIKTI. Riwayat pencarian dan preferensi disimpan secara lokal di perangkat Anda melalui `shared_preferences` dan tidak dikirimkan ke server eksternal selain endpoint API PDDIKTI untuk pemrosesan pencarian.
