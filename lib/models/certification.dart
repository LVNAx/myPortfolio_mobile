import 'package:myportofolio_mobile/utils/date_format.dart';

/// Kategori sertifikasi, sama dengan pilihan `CATEGORY` pada model Django.
enum CertificationCategory {
  swe('Software Engineering'),
  sde('Software Development'),
  dsai('Data Science and AI'),
  cybersec('Cyber Security');

  const CertificationCategory(this.label);

  final String label;
}

/// Satu sertifikasi yang sudah disimpan. Kolomnya mengikuti model `Certification`
/// pada website Django.
///
/// Objek ini tidak bisa diubah (immutable) dan dibandingkan berdasarkan
/// identitas, sehingga dua sertifikasi dengan isi sama tetap dianggap berbeda.
class Certification {
  const Certification({
    required this.title,
    required this.issuer,
    required this.category,
    required this.issuedAt,
    this.credentialUrl,
  });

  final String title;
  final String issuer;
  final CertificationCategory category;
  final DateTime issuedAt;
  final String? credentialUrl;

  String get issuedAtText => formatIsoDate(issuedAt);
}
