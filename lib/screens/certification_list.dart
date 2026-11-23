import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/certification.dart';
import 'package:myportofolio_mobile/models/certification_store.dart';
import 'package:myportofolio_mobile/screens/certification_form.dart';
import 'package:myportofolio_mobile/widgets/certification_scope.dart';
import 'package:myportofolio_mobile/widgets/certification_summary_dialog.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Daftar sertifikasi yang sudah disimpan. Ketuk untuk melihat detail dan
/// geser ke kiri untuk menghapus.
class CertificationListPage extends StatelessWidget {
  const CertificationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // of() membuat halaman ini dibangun ulang setiap isi store berubah.
    final store = CertificationScope.of(context);
    final items = store.items;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Certifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: items.isEmpty
          ? const _EmptyState()
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: items.length,
                  itemBuilder: (context, index) =>
                      _CertificationTile(items[index], store: store),
                ),
              ),
            ),
    );
  }
}

class _CertificationTile extends StatelessWidget {
  const _CertificationTile(this.certification, {required this.store});

  final Certification certification;
  final CertificationStore store;

  void _delete(BuildContext context) {
    store.remove(certification);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('"${certification.title}" dihapus.'),
          persist: false,
          action: SnackBarAction(
            label: 'Batalkan',
            onPressed: () => store.add(certification),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      // Kunci berdasarkan objek: dua sertifikasi berisi sama tetap berbeda.
      key: ObjectKey(certification),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _delete(context),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.workspace_premium)),
          title: Text(
            certification.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${certification.issuer} - ${certification.category.label}\n'
            '${certification.issuedAtText}',
          ),
          isThreeLine: true,
          onTap: () => showDialog<void>(
            context: context,
            builder: (_) => CertificationSummaryDialog(
              certification: certification,
              title: 'Detail Sertifikasi',
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            const Icon(Icons.workspace_premium_outlined, size: 64),
            const Text(
              'Belum ada sertifikasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Tambah Sertifikasi'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CertificationFormPage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
