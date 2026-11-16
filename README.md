# Aplikasi Mobile Portofolio Pribadi
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)

`Nama: Nugraha Kautsarrizqi Caksana`
`Kelas: PBP-B`
`NPM: 2506541250`

Aplikasi mobile portofolio pribadi yang dibangun menggunakan **Flutter (Dart)**. Aplikasi ini adalah kelanjutan dari website portofolio Django ([myPortofolio](https://github.com/LVNAx/myPortofolio)) ke ranah mobile, dan dikerjakan di repositori terpisah.

## Fitur

- Halaman menu utama berupa `StatelessWidget` (`lib/menu.dart`), terpisah dari `main.dart`
- 3 **InfoCard** yang menampilkan NPM, Name, dan Class
- 3 **ItemCard** (Lihat Proyek, Tambah Proyek, Logout) dengan warna latar berbeda yang disimpan di model `ItemHomepage` (tanpa if-else)
- **SnackBar** "Kamu telah menekan tombol [Nama Tombol]!" saat kartu ditekan

## Tech Stack

- Flutter & Dart
- Material 3 (`ColorScheme.fromSeed`)

## Instruksi Setup

1. Clone repository ini
   ```bash
   git clone https://github.com/LVNAx/myPortfolio_mobile.git
   cd myPortfolio_mobile
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Cek kualitas kode (harus `No issues found!`)
   ```bash
   flutter analyze
   ```

4. Jalankan test
   ```bash
   flutter test
   ```

5. Jalankan aplikasi (Chrome paling ringan, atau Android emulator / HP dengan `flutter run`)
   ```bash
   flutter run -d chrome
   ```

> Kalau dibuka di Chrome dengan jendela lebar, kartu menu terlihat besar karena grid 3 kolom berbentuk persegi. Kecilkan jendelanya atau pakai mode perangkat di DevTools (F12 lalu Ctrl+Shift+M) untuk tampilan ala HP.


### Tugas 7

## Progress Mingguan
| Hari / Tanggal | Progress |
|---|---|
| Senin, 9 November | - |
| Selasa, 10 November | - |
| Rabu, 11 November | Menyelesaikan Tutorial 8 |
| Kamis, 12 November | - |
| Jumat, 13 November | - |
| Sabtu, 14 November | - |
| Minggu, 15 November | Mengerjakan Tugas 7: mengganti data `InfoCard` dengan identitas sendiri, menambah atribut `color` pada `ItemHomepage`, dan menulis README |

## AI Disclosure
https://claude.ai/share/9a99b95f-d395-4eb3-b0e8-c896206c9a2b --> Digunakan untuk memahami kode

1. Jelaskan apa yang dimaksud dengan widget tree pada Flutter dan bagaimana hubungan induk-anak (parent-child) bekerja antar-widget!

Widget tree itu struktur pohon dari semua widget yang menyusun tampilan aplikasi. Di Flutter hampir semuanya adalah widget, mulai dari tata letak (`Column`, `Row`), elemen visual (`Text`, `Icon`), sampai aplikasinya sendiri (`MaterialApp`). Satu widget bisa punya satu anak (`child`, seperti `Padding`, `Center`, `Card`) atau banyak anak (`children`, seperti `Column`, `Row`, `GridView`).

Nah, hubungan parent-child ini bekerja dua arah. Parent memberi **constraints** (batas ukuran) ke anaknya, anak menentukan ukurannya sendiri di dalam batas itu, lalu parent yang menentukan posisinya. Selain itu, data seperti tema juga mengalir ke bawah, misalnya `Theme.of(context)` membaca tema dari `MaterialApp` di atasnya. Pada proyek ini pohonnya kira-kira: `MaterialApp` → `MyHomePage` → `Scaffold` → `AppBar` dan `SingleChildScrollView` → `Padding` → `Column` → `Row` (tiga `InfoCard`) dan `GridView` (tiga `ItemCard`).

2. Sebutkan semua widget yang kamu gunakan dalam proyek ini dan jelaskan fungsinya masing-masing!

- `MaterialApp`: root aplikasi yang menyediakan tema Material, judul, dan halaman awal (`home`).
- `MyApp`, `MyHomePage`, `InfoCard`, `ItemCard`: widget buatan sendiri (semuanya `StatelessWidget`) yang menyusun tampilan sesuai tugasnya masing-masing.
- `Scaffold`: kerangka dasar halaman (AppBar, body, dan tempat SnackBar muncul).
- `AppBar`: bar judul di bagian atas halaman.
- `SingleChildScrollView`: membuat isi halaman bisa di-scroll supaya tidak overflow.
- `Padding`: memberi jarak di sekeliling anaknya.
- `Column` dan `Row`: menyusun anak secara vertikal dan horizontal.
- `Center`: menengahkan anaknya.
- `SizedBox`: memberi jarak kosong dengan tinggi atau lebar tertentu.
- `GridView.count`: menyusun anak dalam kisi dengan jumlah kolom tetap (3 kolom).
- `Card`: kartu dengan bayangan, dasar dari `InfoCard`.
- `Container`: kotak serbaguna untuk mengatur padding dan lebar.
- `Material`: permukaan dengan warna dan sudut membulat, tempat efek riak `InkWell` muncul.
- `InkWell`: area yang peka sentuhan, lengkap dengan efek riak dan `onTap`.
- `Text` dan `Icon`: menampilkan teks dan ikon.
- `SnackBar`: pesan singkat di bawah layar, ditampilkan lewat `ScaffoldMessenger`.

Selain itu ada `MediaQuery` yang bukan widget tampilan, tapi dipakai untuk membaca lebar layar agar lebar `InfoCard` menyesuaikan.

3. Apa fungsi dari widget `MaterialApp`? Jelaskan mengapa widget ini umumnya digunakan sebagai root widget pada aplikasi Flutter!

`MaterialApp` itu pembungkus yang menyiapkan fondasi **Material Design** untuk seluruh aplikasi: tema (`ThemeData` dan `ColorScheme`), judul aplikasi, `Navigator` untuk pindah halaman, `ScaffoldMessenger` untuk SnackBar, pengaturan lokalisasi, dan halaman awal lewat `home`. Semua widget di bawahnya bisa memakai hal-hal itu lewat `BuildContext`, contohnya `Theme.of(context)`.

Makanya `MaterialApp` umumnya jadi root. Kalo ngga pakai ini, tiap halaman harus mengurus tema, navigasi, dan SnackBar sendiri-sendiri.

4. Jelaskan perbedaan antara `StatelessWidget` dan `StatefulWidget`! Kapan kita sebaiknya memilih `StatelessWidget` dan kapan harus menggunakan `StatefulWidget`?

`StatelessWidget` itu ngga menyimpan state yang berubah. Tampilannya cuma bergantung pada properti dari konstruktor, jadi dengan masukan yang sama, `build` selalu menghasilkan tampilan yang sama. Sedangkan `StatefulWidget` punya objek `State` terpisah yang menyimpan data yang bisa berubah, dan kalo datanya diubah lewat `setState()`, Flutter akan memanggil `build` lagi untuk menggambar ulang.

Di proyek ini saya pakai `StatelessWidget` karena tampilannya statis: nama, NPM, kelas, dan tombol menu ngga berubah, dan SnackBar sudah diurus oleh `ScaffoldMessenger`. Sebaliknya, `StatefulWidget` dipilih kalo tampilan harus berubah karena interaksi atau waktu, seperti counter bawaan Flutter, isian form, checkbox, atau animasi.

5. Apa itu `BuildContext` dan mengapa penting di Flutter? Bagaimana penggunaannya di dalam metode `build`?

`BuildContext` itu penanda **posisi sebuah widget di dalam widget tree**. Dengan posisi itu, widget bisa mencari informasi dari leluhurnya (parent ke atas), seperti `Theme.of(context)` untuk tema, `MediaQuery.of(context)` untuk ukuran layar, `ScaffoldMessenger.of(context)` untuk SnackBar, dan `Navigator.of(context)` untuk pindah halaman.

Di dalam `build(BuildContext context)`, `context` adalah posisi widget itu sendiri. Pada proyek ini, `Theme.of(context).colorScheme.primary` dipakai untuk warna `AppBar` dan `MediaQuery.of(context).size.width / 3.5` untuk lebar `InfoCard`. Karena pencariannya dimulai dari `context` ke atas, yang dicari harus berada di atas posisi tersebut.

6. Jelaskan konsep hot reload di Flutter dan apa perbedaannya dengan hot restart! Kapan kita tidak bisa hanya mengandalkan hot reload dan harus melakukan hot restart atau full restart?

**Hot reload** menyuntikkan kode Dart yang baru ke Dart VM yang sedang berjalan lalu membangun ulang widget tree, jadi perubahan tampilan langsung kelihatan dan **state tetap dipertahankan**. **Hot restart** memuat ulang seluruh kode dan menjalankan `main()` dari awal, sehingga semua state kembali ke nilai awal, tapi tetap lebih cepat daripada menjalankan ulang aplikasi dari nol.

Hot reload ngga cukup, dan harus hot restart, kalo kita mengubah `main()`, nilai awal variabel global atau field `static`, `initState`, mengubah enum, atau mengubah jenis class (misalnya `StatelessWidget` jadi `StatefulWidget`). **Full restart** (stop lalu `flutter run` lagi) diperlukan kalo kita mengubah kode native (folder `android/`, `ios/`, `web/`), menambah dependensi di `pubspec.yaml`, atau mengubah aset, izin (permission), dan konfigurasi Gradle.
