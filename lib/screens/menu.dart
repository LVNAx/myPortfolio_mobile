import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

// Model data sederhana untuk merepresentasikan satu tombol menu.
// Warna dan halaman tujuan disimpan di model sehingga ItemCard tidak perlu
// percabangan if-else.
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  // Halaman tujuan (opsional). Kalau kosong, tombol hanya menampilkan SnackBar.
  final WidgetBuilder? page;

  ItemHomepage(this.name, this.icon, this.color, {this.page});

  // Menampilkan SnackBar, lalu membuka halaman tujuan bila ada.
  void open(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text("Kamu telah menekan tombol $name!")),
      );

    final destination = page;
    if (destination != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: destination));
    }
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final String npm = "2506541250";
  final String nama = "Nugraha Kautsarrizqi Caksana";
  final String kelas = "PBP-B";

  final List<ItemHomepage> items = [
    ItemHomepage(
      "Lihat Proyek",
      Icons.folder,
      Colors.blue,
      page: (context) => const ProjectListPage(),
    ),
    ItemHomepage(
      "Tambah Proyek",
      Icons.add_circle,
      Colors.green,
      page: (context) => const ProjectFormPage(),
    ),
    ItemHomepage(
      "Tambah Sertifikasi",
      Icons.workspace_premium,
      Colors.orange,
      page: (context) => const CertificationFormPage(),
    ),
    ItemHomepage("Logout", Icons.logout, Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Scaffold menyediakan struktur visual dasar halaman (AppBar, Body, SnackBar).
    return Scaffold(
      // AppBar menampilkan bar bagian atas halaman aplikasi.
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary,
        // foregroundColor juga mewarnai ikon menu (hamburger) pada AppBar.
        foregroundColor: Colors.white,
      ),
      // Drawer: menu samping untuk berpindah halaman (lihat widgets/left_drawer.dart).
      drawer: const LeftDrawer(),
      // SingleChildScrollView mencegah "BOTTOM OVERFLOWED" di layar pendek.
      body: SingleChildScrollView(
        // Center + ConstrainedBox membatasi lebar konten agar kartu tidak
        // melebar berlebihan di layar lebar (misalnya Chrome).
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // IntrinsicHeight membuat tinggi ketiga InfoCard sama,
                  // walaupun panjang teks (misalnya nama) berbeda-beda.
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: InfoCard(title: 'NPM', content: npm),
                        ),
                        Expanded(
                          child: InfoCard(title: 'Name', content: nama),
                        ),
                        Expanded(
                          child: InfoCard(title: 'Class', content: kelas),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // Bagian tengah: pesan sambutan dan kisi tombol menu portofolio.
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Selamat datang di MyPortfolio Mobile!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),

                  // GridView menampilkan kartu tombol dalam tata letak kisi 3 kolom.
                  GridView.count(
                    // Scroll ditangani SingleChildScrollView di atas, bukan grid.
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 3,
                    // Rasio < 1 membuat kartu sedikit lebih tinggi daripada
                    // lebarnya, memberi ruang bagi nama tombol yang panjang.
                    childAspectRatio: 0.9,
                    // shrinkWrap agar ukuran kisi menyesuaikan tinggi konten anak.
                    shrinkWrap: true,
                    children: items.map((ItemHomepage item) {
                      return ItemCard(item);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  // Kartu informasi yang menampilkan judul (title) dan isi (content).
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Memberikan efek bayangan kartu elevasi 2 unit.
      elevation: 2.0,
      // Lebar kartu ditentukan oleh Expanded di induknya (dibagi rata).
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // Menyusun teks title dan content secara vertikal.
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text(content, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
