import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/models/certification.dart';

import 'test_helpers.dart';

Certification sample(String title, DateTime issuedAt) {
  return Certification(
    title: title,
    issuer: 'Coursera',
    category: CertificationCategory.swe,
    issuedAt: issuedAt,
  );
}

// Menyiapkan aplikasi dengan tiga sertifikasi lalu membuka halaman daftarnya.
Future<void> openListWithSamples(WidgetTester tester) async {
  await pumpApp(tester);
  storeOf(tester)
    ..add(sample('Lama', DateTime(2024, 1, 1)))
    ..add(sample('Baru', DateTime(2026, 1, 1)))
    ..add(sample('Tengah', DateTime(2025, 1, 1)));
  await openListFromCard(tester);
}

Future<void> openListFromDrawer(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(Drawer),
      matching: find.text('View Certifications'),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Daftar kosong', () {
    testWidgets('menampilkan keadaan kosong dan tombol menuju form', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);
      await openListFromCard(tester);

      expect(find.text('View Certifications'), findsOneWidget);
      expect(find.text('Belum ada sertifikasi'), findsOneWidget);

      await tester.tap(find.text('Tambah Sertifikasi'));
      await tester.pumpAndSettle();
      expect(find.text('Add Certification Form'), findsOneWidget);
    });
  });

  group('Menyimpan dari form', () {
    testWidgets('data valid masuk ke store dan tampil di daftar', (
      WidgetTester tester,
    ) async {
      await openFromCard(tester);
      await fillValidForm(tester);
      await tapSave(tester);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Sertifikasi disimpan.'), findsOneWidget);
      expect(storeOf(tester).items, hasLength(1));

      await openListFromDrawer(tester);
      expect(find.text('Meta Backend Developer'), findsOneWidget);
      expect(
        find.textContaining('Coursera - Software Engineering'),
        findsOneWidget,
      );
      expect(find.textContaining(todayText()), findsOneWidget);
    });

    testWidgets('input tidak valid tidak menyimpan apa pun', (
      WidgetTester tester,
    ) async {
      await openFromCard(tester);
      await tapSave(tester);

      expect(storeOf(tester).isEmpty, isTrue);
    });

    testWidgets('Batalkan pada SnackBar menghapus data yang baru disimpan', (
      WidgetTester tester,
    ) async {
      await openFromCard(tester);
      await fillValidForm(tester);
      await tapSave(tester);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(storeOf(tester).items, hasLength(1));

      await tester.tap(find.text('Batalkan'));
      await tester.pumpAndSettle();

      expect(storeOf(tester).isEmpty, isTrue);
    });

    testWidgets('data tetap ada setelah pindah halaman', (
      WidgetTester tester,
    ) async {
      await openFromCard(tester);
      await fillValidForm(tester);
      await tapSave(tester);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: find.byType(Drawer), matching: find.text('Home')),
      );
      await tester.pumpAndSettle();
      await openListFromCard(tester);

      expect(find.text('Meta Backend Developer'), findsOneWidget);
    });

    testWidgets('Reset mengosongkan semua isian form', (
      WidgetTester tester,
    ) async {
      await openFromCard(tester);
      await fillValidForm(tester);

      await tester.ensureVisible(find.text('Reset'));
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      for (final label in [
        'Nama Sertifikasi',
        'Nama Penerbit',
        'Tanggal Terbit',
        'Bukti Sertifikasi (opsional)',
      ]) {
        final input = tester.widget<TextFormField>(field(label));
        expect(input.controller!.text, isEmpty, reason: label);
      }
      expect(storeOf(tester).isEmpty, isTrue);
    });
  });

  group('Halaman daftar', () {
    testWidgets('mengurutkan dari tanggal terbit terbaru', (
      WidgetTester tester,
    ) async {
      await openListWithSamples(tester);

      final baru = tester.getTopLeft(find.text('Baru')).dy;
      final tengah = tester.getTopLeft(find.text('Tengah')).dy;
      final lama = tester.getTopLeft(find.text('Lama')).dy;

      expect(baru, lessThan(tengah));
      expect(tengah, lessThan(lama));
    });

    testWidgets('mengetuk item menampilkan dialog detail', (
      WidgetTester tester,
    ) async {
      await openListWithSamples(tester);

      await tester.tap(find.text('Tengah'));
      await tester.pumpAndSettle();

      expect(find.text('Detail Sertifikasi'), findsOneWidget);
      expect(find.text('Nama Sertifikasi: Tengah'), findsOneWidget);
      expect(find.text('Bukti Sertifikasi: -'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Detail Sertifikasi'), findsNothing);
    });

    testWidgets('geser menghapus item dan Batalkan mengembalikannya', (
      WidgetTester tester,
    ) async {
      await openListWithSamples(tester);

      await tester.drag(find.text('Baru'), const Offset(-600, 0));
      await tester.pumpAndSettle();

      expect(find.text('Baru'), findsNothing);
      expect(find.text('"Baru" dihapus.'), findsOneWidget);
      expect(storeOf(tester).items, hasLength(2));

      await tester.tap(find.text('Batalkan'));
      await tester.pumpAndSettle();

      expect(find.text('Baru'), findsOneWidget);
      expect(storeOf(tester).items, hasLength(3));
      // Setelah dikembalikan, item kembali ke posisi paling atas.
      expect(
        tester.getTopLeft(find.text('Baru')).dy,
        lessThan(tester.getTopLeft(find.text('Tengah')).dy),
      );
    });
  });

  group('Akses halaman daftar', () {
    testWidgets('dari kartu aksi dan dari Drawer', (WidgetTester tester) async {
      await pumpApp(tester);
      await openListFromCard(tester);
      expect(find.text('View Certifications'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        find.text('Selamat datang di MyPortfolio Mobile!'),
        findsOneWidget,
      );

      await openListFromDrawer(tester);
      expect(find.text('Belum ada sertifikasi'), findsOneWidget);
    });
  });
}
