import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/certification_store.dart';

/// Menyediakan [CertificationStore] ke semua halaman di bawahnya, sehingga
/// halaman form dan halaman daftar memakai data yang sama.
class CertificationScope extends InheritedNotifier<CertificationStore> {
  const CertificationScope({
    super.key,
    required CertificationStore store,
    required super.child,
  }) : super(notifier: store);

  /// Mengambil store dan ikut membangun ulang widget saat datanya berubah.
  static CertificationStore of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<CertificationScope>();
    assert(scope != null, 'CertificationScope tidak ada di atas widget ini.');
    return scope!.notifier!;
  }

  /// Mengambil store tanpa ikut membangun ulang; untuk aksi seperti menyimpan.
  static CertificationStore read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<CertificationScope>();
    assert(scope != null, 'CertificationScope tidak ada di atas widget ini.');
    return scope!.notifier!;
  }
}
