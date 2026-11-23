import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/certification.dart';

/// Dialog yang merangkum seluruh isian sebuah [Certification].
class CertificationSummaryDialog extends StatelessWidget {
  const CertificationSummaryDialog({
    super.key,
    required this.certification,
    this.title = 'Sertifikasi berhasil ditambahkan!',
  });

  final Certification certification;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama Sertifikasi: ${certification.title}'),
            Text('Penerbit: ${certification.issuer}'),
            Text('Kategori: ${certification.category.label}'),
            Text('Tanggal Terbit: ${certification.issuedAtText}'),
            Text('Bukti Sertifikasi: ${certification.credentialUrl ?? '-'}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
