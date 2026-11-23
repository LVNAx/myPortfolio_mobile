# Aplikasi Mobile Portofolio Pribadi
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)

`Nama: Nugraha Kautsarrizqi Caksana`
`Kelas: PBP-B`
`NPM: 2506541250`

Aplikasi mobile portofolio pribadi yang dibangun menggunakan **Flutter (Dart)**. Aplikasi ini adalah kelanjutan dari website portofolio Django ([myPortofolio](https://github.com/LVNAx/myPortofolio)) ke ranah mobile, dan dikerjakan di repositori terpisah.

## Fitur

- Halaman menu utama berupa `StatelessWidget` (`lib/screens/menu.dart`), terpisah dari `main.dart`
- 3 **InfoCard** yang menampilkan NPM, Name, dan Class
- 5 **ItemCard** (Lihat Proyek, Tambah Proyek, Lihat Sertifikasi, Tambah Sertifikasi, Logout) dengan warna latar berbeda yang disimpan di model `ItemHomepage` (tanpa if-else)
- **SnackBar** "Kamu telah menekan tombol [Nama Tombol]!" saat kartu ditekan
- **Navigasi** antar halaman dengan `Navigator.push`: *Lihat Proyek* membuka daftar proyek (`lib/screens/project_list.dart`) dan *Tambah Proyek* membuka formulir (`lib/screens/project_form.dart`). Halaman tujuan disimpan di model `ItemHomepage` (atribut `page`), jadi `ItemCard` tetap tanpa if-else
- **Drawer** (`LeftDrawer` di `lib/widgets/left_drawer.dart`) dengan menu Home, Add Project, Add Certification, View Certifications, dan View Projects, dipasang di semua halaman. Perpindahan lewat Drawer memakai `Navigator.pushReplacement`
- **Form tambah proyek** (`ProjectFormPage`, `StatefulWidget`): `Form` dengan `GlobalKey`, `TextFormField` (nama, deskripsi, teknologi, tautan), `DropdownButtonFormField` (kategori), validasi field wajib, dan `AlertDialog` yang menampilkan data yang diisi. Data belum disimpan ke database
- **Form tambah sertifikasi** (`CertificationFormPage`, `lib/screens/certification_form.dart`) dengan kolom yang mengikuti model `Certification` pada website Django: nama sertifikasi dan penerbit (`TextFormField`), kategori (`DropdownButtonFormField`), tanggal terbit (`showDatePicker`), dan bukti sertifikasi berupa URL opsional (papan ketik URL). Validasi menolak isian kosong atau hanya spasi, tag HTML, teks terlalu panjang, dan URL tanpa `http(s)://`. Setelah valid, tombol Save menampilkan ringkasan isian dalam `AlertDialog`
- **Daftar sertifikasi** (`CertificationListPage`): sertifikasi yang disimpan dari form tampil terurut dari tanggal terbit terbaru (seperti `ordering` pada Django). Ketuk untuk melihat detail, geser ke kiri untuk menghapus. Tersedia keadaan kosong dengan tombol menuju form
- **Batalkan (undo)**: SnackBar setelah menyimpan atau menghapus punya tombol Batalkan. Form juga punya tombol **Reset**
- **Data di memori**: `CertificationStore` (`ChangeNotifier`) dibagikan ke semua halaman lewat `CertificationScope` (`InheritedNotifier`), tanpa paket tambahan. Data hilang saat aplikasi ditutup karena belum memakai database
- **Logika dipisah dari tampilan**: model dan store di `lib/models/`, validator dan pemformat tanggal di `lib/utils/`, semuanya punya unit test
- **Layout lebih rapi**: `InfoCard` dibagi rata dengan `Expanded` dan `IntrinsicHeight` (tinggi sama walau nama panjang), serta lebar konten dibatasi 800 px agar kartu tidak melebar berlebihan di layar lebar

## Tech Stack

- Flutter & Dart
- Material 3 (`ColorScheme.fromSeed`) melalui paket `material_ui`

## Struktur Folder

```
lib/
├── main.dart                 # entry point + MaterialApp + tema
├── screens/                  # halaman (route)
│   ├── menu.dart             # MyHomePage, InfoCard, ItemHomepage
│   ├── project_form.dart     # ProjectFormPage (form tambah proyek)
│   ├── certification_form.dart # CertificationFormPage (form tambah sertifikasi)
│   ├── certification_list.dart # CertificationListPage (daftar sertifikasi)
│   └── project_list.dart     # ProjectListPage (daftar proyek)
├── models/
│   ├── certification.dart        # Certification, CertificationCategory
│   └── certification_store.dart  # CertificationStore (data di memori)
├── utils/
│   ├── date_format.dart      # formatIsoDate
│   └── validators.dart       # fungsi validator formulir
└── widgets/                  # komponen yang dipakai ulang
    ├── certification_scope.dart          # membagikan store ke semua halaman
    ├── certification_summary_dialog.dart # dialog ringkasan sertifikasi
    ├── left_drawer.dart      # LeftDrawer (menu samping)
    └── project_card.dart     # ItemCard (kartu tombol menu)
```

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


### Tugas 8

## Progress Mingguan
| Hari / Tanggal | Progress |
|---|---|
| Senin, 16 November | - |
| Selasa, 17 November | - |
| Rabu, 18 November | Menyelesaikan Tutorial 9: `LeftDrawer`, `ProjectFormPage`, dialog data, navigasi tombol, dan refactor ke `screens/` dan `widgets/` |
| Kamis, 19 November | - |
| Jumat, 20 November | - |
| Sabtu, 21 November | - |
| Minggu, 22 November | - |
| Senin, 23 November | Mengerjakan Tugas 8: memilih model `Certification` dari website Django, membuat validator, halaman `CertificationFormPage`, kartu aksi dan opsi Drawer, lalu menambah model, penyimpanan di memori, halaman daftar, Batalkan, Reset, test, dan README |

## AI Disclosure
- **[Chat 1-Model: Claude Sonnet-5 High](https://claude.ai/share/77eb76f7-aa6d-4c10-a73c-860898f3eee1)** Digunakan untuk memahami dan menguasai materi mengenai navigasi, layouts, forms, dan elemen input
- **[Chat 2-Model: Claude Sonnet-5 High](https://claude.ai/share/56881d70-3dfd-4b6c-820c-6c3fbcd467d2)** sama seperti yang sebelumnya, ia digunakan untuk memahami kode
- **[Chat 3-Model: Gemini Hydrogen High](https://share.gemini.google/o6mJXwZeD2On)** sama seperti yang sebelumnya, ia digunakan untuk memahami kode


1. Jelaskan perbedaan antara `Navigator.push()`, `Navigator.pushReplacement()`, dan `Navigator.pop()`. Metode apa yang digunakan untuk membuka formulir dari kartu aksi? Jelaskan juga bagaimana opsi Home di drawer membawa pengguna kembali ke halaman utama.

`Navigator` mengelola halaman sebagai **tumpukan (stack)**. `push()` **menambahkan** halaman baru di atas tumpukan, jadi halaman lama tetap ada di bawahnya dan pengguna bisa kembali. `pop()` **membuang** halaman paling atas sehingga pengguna kembali ke halaman di bawahnya. `pushReplacement()` **mengganti** halaman paling atas dengan halaman baru, jadi halaman lama hilang dari tumpukan dan ngga bisa dikembalikan dengan tombol Back.

Untuk membuka formulir dari kartu aksi, saya pakai `Navigator.push()` (di method `ItemHomepage.open`, `Navigator.of(context).push(MaterialPageRoute(builder: destination))`). Hasilnya halaman utama tetap di bawah formulir, sehingga tombol Back bawaan perangkat atau browser bisa kembali ke halaman utama.

Opsi Home di drawer memakai `Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()))`. Halaman formulir yang sedang tampil diganti dengan halaman utama yang baru. Satu hal yang saya perhatikan: kalau formulir dibuka dari kartu, di bawahnya sudah ada halaman utama, jadi setelah menekan Home akan ada dua halaman utama di tumpukan (tampilannya sama, dan tombol Back tetap kembali ke halaman utama). Sedangkan kalau formulir dibuka dari drawer, halaman utama sebelumnya yang tergantikan, jadi tumpukannya tetap rapi.

2. Bagaimana susunan `Scaffold`, `AppBar`, dan `Drawer` membantu menjaga struktur halaman tetap konsisten? Berikan satu contoh penggunaan warna tema portofolio di lebih dari satu halaman.

`Scaffold` itu kerangka standar halaman: ia menyediakan slot `appBar`, `drawer`, dan `body`, serta tempat SnackBar muncul. Karena semua halaman (utama, daftar proyek, form proyek, form sertifikasi) memakai kerangka yang sama, posisi judul, ikon menu, dan isi halaman selalu sama, dan pengguna langsung tahu cara memakainya. `Drawer` kita taruh sebagai widget terpisah, yaitu `LeftDrawer`, lalu dipasang dengan `drawer: const LeftDrawer()` di setiap halaman, jadi menu navigasinya selalu seragam dan kalau mau menambah menu cukup mengubah satu berkas.

Contoh warna tema: `Theme.of(context).colorScheme.primary` (turunan dari `Colors.indigo` di `ColorScheme.fromSeed`) dipakai sebagai warna `AppBar` di halaman utama (`screens/menu.dart`) dan di halaman form sertifikasi (`screens/certification_form.dart`), serta sebagai warna tombol Save di form tersebut. Jadi kalau seed warna di `main.dart` diganti, warna semua halaman ikut berubah.

3. Mengapa tata letak tersebut dipilih untuk formulir? Jelaskan peran widget pengatur jarak dan widget penggulir ketika ruang layar terbatas.

Formulirnya disusun dalam satu `Column` vertikal karena kolomnya diisi berurutan dari atas ke bawah (nama, penerbit, kategori, tanggal, URL, lalu tombol Reset dan Save), dan `crossAxisAlignment.stretch` membuat semua kolom selebar layar. Widget pengatur jarak memberi ruang bernapas supaya kolom ngga menempel satu sama lain dan mudah disentuh jari: `Padding` (16 di sekeliling form), `Column(spacing: 16)` untuk jarak antar kolom, dan `SizedBox` untuk jarak tambahan sebelum tombol.

Widget penggulir, yaitu `SingleChildScrollView`, penting ketika ruang layar terbatas. Saat papan ketik muncul, `Scaffold` mengecilkan area body, sehingga kolom di bawah bisa tertutup. Karena isinya bisa di-scroll, semua kolom dan tombol Save tetap terjangkau, dan `keyboardDismissBehavior.onDrag` menutup papan ketik saat form digeser. Untuk layar lebar (misalnya Chrome), `Center` + `ConstrainedBox(maxWidth: 800)` mencegah kolom melebar berlebihan. Saya juga menguji ini lewat test dengan layar 360x640 dan papan ketik setinggi 300 px.

4. Apa peran `GlobalKey<FormState>`, `validator`, dan `validate()` saat tombol Simpan ditekan? Berikan satu contoh nilai yang ditolak oleh validasi dan jelaskan mengapa memilih jenis input atau papan ketik saja belum cukup.

`GlobalKey<FormState>` (`_formKey`) adalah "pegangan" ke state `Form`, sehingga kode di luar form (seperti tombol Save) bisa memanggil `validate()` dan `reset()`. `validator` adalah fungsi pada tiap kolom yang mengembalikan pesan error (String) kalau isiannya ditolak, atau `null` kalau valid. Saat Save ditekan, `_formKey.currentState!.validate()` menjalankan semua `validator` sekaligus, menampilkan pesan error di kolom yang bermasalah, lalu mengembalikan `true` hanya kalau semuanya valid. Baru setelah itu dialog ringkasan ditampilkan.

Contoh nilai yang ditolak: nama sertifikasi berisi spasi saja (`"     "`) ditolak dengan pesan "Nama sertifikasi tidak boleh kosong!" karena `trim()`-nya kosong. Contoh lain, di kolom bukti sertifikasi, `coursera.org` ditolak karena ngga diawali `http://` atau `https://`.

Memilih jenis input atau papan ketik saja belum cukup karena itu cuma mengubah **tampilan** papan ketik, bukan isi yang boleh masuk. `TextInputType.url` hanya menampilkan papan ketik yang ada tombol `/` dan `.com`, tapi pengguna tetap bisa mengetik `coursera.org`, menempel teks apa pun, atau mengosongkan kolom wajib. Date picker pun hanya membatasi tanggal, tapi kolom tanggal tetap harus divalidasi supaya ngga kosong. Jadi validasi tetap harus dilakukan di `validator`, sama seperti aturan di model dan form Django yang dipakai sebagai acuan.
