import 'package:flutter/foundation.dart';

import 'package:myportofolio_mobile/models/certification.dart';

/// Penyimpan sertifikasi di memori; data hilang saat aplikasi ditutup.
///
/// Memakai [ChangeNotifier] agar halaman yang menampilkannya otomatis
/// diperbarui setiap data berubah.
class CertificationStore extends ChangeNotifier {
  final List<Certification> _items = [];

  /// Terbaru lebih dulu, sama dengan `ordering = ["-issued_at"]` pada Django.
  List<Certification> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  /// Menyisipkan [certification] pada posisi yang menjaga urutan terbaru dulu.
  ///
  /// Tanggal yang sama ditaruh setelah yang sudah ada, dan mengembalikan objek
  /// yang pernah dihapus (undo) membuatnya kembali ke posisi semula.
  void add(Certification certification) {
    final index = _items.indexWhere(
      (item) => item.issuedAt.isBefore(certification.issuedAt),
    );
    _items.insert(index == -1 ? _items.length : index, certification);
    notifyListeners();
  }

  void remove(Certification certification) {
    if (_items.remove(certification)) {
      notifyListeners();
    }
  }
}
