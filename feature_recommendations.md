# Rekomendasi Fitur Premium (PDDikti Explorer)

Berikut adalah beberapa fitur kelas tinggi (premium) yang direkomendasikan untuk ditambahkan ke aplikasi **PDDikti Explorer** guna memberikan pengalaman pengguna yang luar biasa (wow factor) dan fungsionalitas yang lebih mendalam:

---

## 1. 📊 Visualisasi & Dashboard Statistik Nasional
Aplikasi saat ini memfokuskan pencarian individu. Padahal, API resmi PDDikti menyediakan visualisasi agregat. Kita dapat menambahkan tab **"Statistik"** dengan grafik interaktif menggunakan package `fl_chart`:
* **Grafik Dosen**: Rasio keaktifan, bidang ilmu terpopuler (`/visualisasi/dosen-bidang`), dan distribusi kualifikasi jenjang pendidikan (`/visualisasi/dosen-jenjang`).
* **Grafik Mahasiswa**: Statistik status aktif/tidak aktif (`/visualisasi/mahasiswa-status`) dan tren gender secara nasional.
* **Grafik Perguruan Tinggi**: Distribusi akreditasi PT (`/visualisasi/pt-akreditasi`) dan jenis lembaga (Universitas, Politeknik, Institut).

---

## 2. 📑 Perbandingan Side-by-Side (Compare Feature)
Fitur untuk membantu calon mahasiswa menentukan pilihan kuliah dengan membandingkan dua PT atau Program Studi secara berdampingan:
* **Perbandingan Universitas**: Membandingkan status akreditasi, biaya kuliah rerata (`cost-range`), jumlah dosen tetap, total mahasiswa, serta rasio dosen-ke-mahasiswa.
* **Perbandingan Prodi**: Membandingkan akreditasi prodi, daya tampung kuota, dan masa rata-rata studi kelulusan.

---

## 3. 🔖 Bookmark / Favorit Lokal
Menyimpan profil yang sering dicari agar pengguna tidak perlu mengetik ulang kata kunci pencarian:
* Disimpan secara aman di penyimpanan lokal menggunakan `shared_preferences` atau database terenkripsi `hive`/`isar`.
* Pengelompokan folder favorit berdasarkan kategori (misalnya: "Dosen Favorit", "Target Kampus", "Data Teman").

---

## 4. 🔍 Riwayat Pencarian Pintar (Search History)
Meningkatkan fungsionalitas bilah pencarian dengan menyimpan riwayat kata kunci terakhir:
* Menampilkan *recent searches* dengan tombol hapus satu per satu atau sekaligus.
* Fitur auto-complete berdasarkan riwayat pencarian sebelumnya.

---

## 5. 📄 Ekspor PDF / Shareable Card
Membuat data profil mahasiswa, dosen, atau perguruan tinggi menjadi mudah dibagikan:
* **Eksport PDF Resmi**: Menghasilkan dokumen PDF terformat rapi dari riwayat mengajar dosen atau status mahasiswa untuk keperluan verifikasi cepat.
* **Shareable Card**: Membuat gambar rangkuman profil berdesain elegan (bisa langsung dibagikan ke WhatsApp, Telegram, atau Media Sosial).

---

## 6. 🔔 Notifikasi Perubahan Status Data
Guna membantu mahasiswa tingkat akhir memantau kelulusan mereka:
* Notifikasi lokal (atau push notification menggunakan Firebase) ketika status mahasiswa berubah di sistem PDDikti dari **"Aktif"** menjadi **"Lulus"**.
* Notifikasi jika nilai akreditasi institusi/prodi terupdate.
