import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/models/certification.dart';
import 'package:myportofolio_mobile/models/certification_store.dart';
import 'package:myportofolio_mobile/utils/date_format.dart';

Certification certification(String title, DateTime issuedAt) {
  return Certification(
    title: title,
    issuer: 'Coursera',
    category: CertificationCategory.swe,
    issuedAt: issuedAt,
  );
}

void main() {
  group('formatIsoDate', () {
    test('memberi nol di depan bulan dan hari satu digit', () {
      expect(formatIsoDate(DateTime(2026, 3, 5)), '2026-03-05');
    });

    test('tidak mengubah bulan dan hari dua digit', () {
      expect(formatIsoDate(DateTime(2026, 11, 23)), '2026-11-23');
    });
  });

  group('Certification', () {
    test('issuedAtText memakai format yyyy-MM-dd', () {
      expect(
        certification('A', DateTime(2026, 1, 9)).issuedAtText,
        '2026-01-09',
      );
    });

    test('kategori membawa label yang sama dengan model Django', () {
      expect(CertificationCategory.swe.label, 'Software Engineering');
      expect(CertificationCategory.cybersec.label, 'Cyber Security');
      expect(CertificationCategory.values, hasLength(4));
    });
  });

  group('CertificationStore', () {
    test('awalnya kosong', () {
      final store = CertificationStore();
      expect(store.isEmpty, isTrue);
      expect(store.items, isEmpty);
    });

    test('add mengurutkan dari tanggal terbit terbaru', () {
      final store = CertificationStore();
      final old = certification('Lama', DateTime(2024, 1, 1));
      final recent = certification('Baru', DateTime(2026, 1, 1));
      final middle = certification('Tengah', DateTime(2025, 1, 1));

      store
        ..add(old)
        ..add(recent)
        ..add(middle);

      expect(store.items, [recent, middle, old]);
    });

    test('tanggal sama: yang ditambahkan lebih dulu tetap di atas', () {
      final store = CertificationStore();
      final first = certification('Pertama', DateTime(2026, 5, 5));
      final second = certification('Kedua', DateTime(2026, 5, 5));

      store
        ..add(first)
        ..add(second);

      expect(store.items, [first, second]);
    });

    test('remove menghapus item dan add mengembalikannya ke posisi semula', () {
      final store = CertificationStore();
      final a = certification('A', DateTime(2026, 3, 1));
      final b = certification('B', DateTime(2026, 2, 1));
      final c = certification('C', DateTime(2026, 1, 1));
      store
        ..add(a)
        ..add(b)
        ..add(c);

      store.remove(b);
      expect(store.items, [a, c]);

      store.add(b);
      expect(store.items, [a, b, c]);
    });

    test('item dengan isi sama tetap dua objek berbeda', () {
      final store = CertificationStore();
      final one = certification('Sama', DateTime(2026, 1, 1));
      final two = certification('Sama', DateTime(2026, 1, 1));
      store
        ..add(one)
        ..add(two);

      store.remove(one);

      expect(store.items, hasLength(1));
      expect(identical(store.items.single, two), isTrue);
    });

    test('memberi tahu pendengar saat add dan remove, bukan saat sia-sia', () {
      final store = CertificationStore();
      var notified = 0;
      store.addListener(() => notified++);
      final item = certification('A', DateTime(2026, 1, 1));

      store.add(item);
      expect(notified, 1);

      store.remove(item);
      expect(notified, 2);

      store.remove(item);
      expect(notified, 2);
    });

    test('items tidak bisa diubah dari luar', () {
      final store = CertificationStore();
      store.add(certification('A', DateTime(2026, 1, 1)));

      expect(
        () => store.items.add(certification('B', DateTime(2026, 1, 2))),
        throwsUnsupportedError,
      );
    });
  });
}
