# 🏎️ PitTalk: The F1 Community Site

[![Build Status](https://app.bitrise.io/app/5ccc1374-7338-4440-bebe-8fe2b2e828e5/status.svg?token=Oegv-MqkoekFkt4gShlM2w&branch=master)](https://app.bitrise.io/app/5ccc1374-7338-4440-bebe-8fe2b2e828e5)

## Download
Download aplikasi versi terbaru: [Download APK](https://app.bitrise.io/app/5ccc1374-7338-4440-bebe-8fe2b2e828e5/installable-artifacts/d579c4103a9f980b/public-install-page/36c3549120d1807f4d6acaba5c1f2bea)

---

## 👥 Kelompok C05
| Nama Anggota | NPM |
|--------------|------|
| Amar Hakim | 2406429563 |
| Arya Putra Parikesit | 2406406300 |
| Ahmad Faiq Fawwaz Abdussalam | 2406397706 |
| Erik Wilbert | 2406495376 |
| Ammar Muhammad Rafif | 2406495602 |

---

## 📖 Deskripsi Aplikasi
**PitTalk** merupakan sebuah platform komunitas berbasis web dan aplikasi yang berfokus pada Formula 1 (F1). **PitTalk** dirancang untuk menjadi wadah bagi para penggemar F1 agar dapat berdiskusi, mengikuti berita, serta berinteraksi satu sama lain.

| Kebermanfaatan | Penjelasan |
|-------------------|------------|
| Platform Komunitas | Menjadi wadah terpusat untuk komunitas F1 |
| Diskusi & Interaksi | Tempat berbagi opini, analisis, dan komentar |
| Informasi Terkini | Menyediakan berita, jadwal, klasemen, dan hasil balapan terbaru |

---

## 📂 Daftar Modul
| Modul | Deskripsi | DIkerjakan Oleh |
|-------|-----------|-------|
| **Authentication** | Registrasi, login, logout, dan manajemen sesi | Ammar Muhammad Rafif
| **Admin Dashboard** | Admin dapat mengelola user, drivers, team, race results (CRUD, ban/unban user) | Ammar Muhammad Rafif
| **Forums** | Ruang diskusi pengguna: membuat thread, membaca, dan reply thread, admin dapat menghapus thread dan reply serta mark "HOT" untuk thread | Erik Wilbert
| **History** | Informasi riwayat driver & Grand Prix, admin dapat membuat, menghapus, dan meng-edit data yang ada di dalam history driver dan winner | Amar Hakim
| **Information** | Informasi lengkap driver & tim F1, Klasemen driver & konstruktor, dan Jadwal balapan F1 2025 | Ahmad Faiq Fawwaz Abdussalam
| **News** | Menyediakan berita terkini seputar F1, admin dapat membuat news baru serta CRUD lainnya | Arya Putra Parikesit
| **Prediction (Voting)** | Fitur voting untuk memprediksi pemenang balapan | Arya Putra Parikesit
| **Profile & Settings** | User dapat mengedit profil (nama, foto, bio, dan lainnya)| Ammar Muhammad Rafif
| **User Dashboard** | Menampilkan ringkasan aktivitas user seperti thread yang dibuat, voting yang dilakukan, dan statistik profil | Ammar Muhammad Rafif

---

## 📊 Dataset
| Sumber Dataset | Link |
|----------------|------|
| Formula1 Datasets (GitHub) | [Link Datasets F1](https://github.com/toUpperCase78/formula1-datasets) |
| Race Result (1950 - 2024) | [Link Datasets Race Result](https://www.kaggle.com/datasets/lakshayjain611/f1-races-results-dataset-1950-to-2024) |
| Sumber Berita | [Formula 1 Official Website](https://www.formula1.com/en/latest) <br /> [BBC Sport](https://www.bbc.com/sport/formula1) <br /> [Planet F1](https://www.planetf1.com/) |
| Lainnya | Sumber data relevan (berita, standings, jadwal, dll) |

---

## 👤 Jenis Pengguna
| Jenis Pengguna | Hak Akses |
|----------------|-----------|
| **Guest** | Melihat berita dan informasi F1, membaca thread di forum |
| **User (Login)** | Membuat thread & reply di forum, komentar berita, ikut voting, melihat profil user lain |
| **Admin** | Mengelola akun (CRUD & ban user), membuat berita resmi, mengedit data *driver* dan *team*, membuat dan menghapus data *race result*, mengedit data *history* (*driver* dan *winner*) |

---

## 🔄️ Alur Pengintegrasian dengan Web Service

Melanjutkan dari project PitTalk sebelumnya kami mengembangkan aplikasi berbasis mobile. dalam alur pengintegrasiannya kami menggunakan data yang sama dengan yang ada di situs web kami. Alur dalam pengintegrasian dengan web kami adalah sebagai berikut

**1. Membuat model dalam bahasa dart untuk data-data yang digunakan dalam aplikasi ini.**

Kami memanfaatkan Quicktype (https://app.quicktype.io/) untuk mengkonversi data JSON yang dikembalikan oleh server Django yang merubahnya menjadi class model pada bahasa dart di flutter.

**2. Membuat django-app baru untuk mengurus logic autentikasi khusus untuk pengguna mobile, yaitu untuk autentikasi login, logout maupun registrasi akun baru.**

**3. Mengatur aplikasi PitTalk untuk melakukan autentikasi dan menerima cookies pada server django.**

Kami menggunakan bantuan package pbp-django-auth yang telah dibuat oleh tim asdos dan package provider yang menyimpan cookies untuk nantinya dipakai di setiap request yang akan dilakukan dari dalam aplikasi kami. 

**4. Membuat endpoints baru khusus untuk implementasi mobile dalam mengambil, mengubah, maupun menghapus (proses CRUD) dari data yang dimiliki oleh PitTalk di server DJANGO**


---

## 🌐 Link Figma
👉[Figma](https://www.figma.com/files/team/1432936860516350017/project/465437465/C05?fuid=1432936857614076377)
