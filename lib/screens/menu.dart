import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/screens/certification_list.dart';
import 'package:myportofolio_mobile/screens/project_form_screen.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';
import 'package:provider/provider.dart';

/// Satu tombol menu: nama, ikon, warna, dan tujuannya.
///
/// Warna, tujuan, dan syarat login disimpan di model agar [ItemCard] bebas
/// dari if-else berdasarkan nama tombol.
class ItemHomepage {
  ItemHomepage(
    this.name,
    this.icon,
    this.color, {
    this.page,
    this.requiresLogin = false,
    this.action,
  });

  final String name;
  final IconData icon;
  final Color color;

  /// Halaman tujuan; bila kosong, tombol hanya menampilkan SnackBar.
  final WidgetBuilder? page;

  /// Bila true, pengguna harus login dulu sebelum [page] dibuka.
  final bool requiresLogin;

  /// Aksi pengganti navigasi (mis. logout). Hasilnya, bila ada, ditampilkan
  /// sebagai SnackBar.
  final Future<String?> Function(BuildContext context)? action;

  /// Menampilkan SnackBar, lalu menjalankan [action] atau membuka [page].
  Future<void> open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    void show(String message) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    final pressed = "Kamu telah menekan tombol $name!";
    show(pressed);

    final action = this.action;
    if (action != null) {
      final message = await action(context);
      // Hasil aksi digabung ke pesan yang sama, bukan menggantinya, agar pesan
      // "Kamu telah menekan tombol ..." tetap terbaca.
      if (message != null) show('$pressed\n$message');
      return;
    }

    if (requiresLogin && !await ensureLoggedIn(context)) return;
    // Setelah await, widget mungkin sudah dibuang; cek mounted dulu.
    if (!context.mounted) return;

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
      page: (context) => const ProjectListScreen(),
    ),
    ItemHomepage(
      "Tambah Proyek",
      Icons.add_circle,
      Colors.green,
      page: (context) => const ProjectFormScreen(),
      requiresLogin: true,
    ),
    ItemHomepage(
      "Lihat Sertifikasi",
      Icons.verified,
      Colors.purple,
      page: (context) => const CertificationListPage(),
    ),
    ItemHomepage(
      "Tambah Sertifikasi",
      Icons.workspace_premium,
      Colors.orange,
      page: (context) => const CertificationFormPage(),
    ),
    ItemHomepage(
      "Logout",
      Icons.logout,
      Colors.red,
      action: (context) async {
        final auth = context.read<AuthState>();
        if (!auth.isLoggedIn) return 'Kamu belum login.';
        await auth.logout();
        return 'Berhasil logout.';
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
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
  /// Kartu ringkas berisi judul dan isi.
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
