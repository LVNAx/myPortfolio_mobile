import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/certification_store.dart';
import 'package:myportofolio_mobile/widgets/certification_scope.dart';

// Membuka formulir sertifikasi lewat kartu aksi di halaman utama.
Future<void> openFromCard(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  // Kartu ada di baris kedua grid; ensureVisible meniru pengguna men-scroll.
  await tester.ensureVisible(find.text('Tambah Sertifikasi'));
  await tester.tap(find.text('Tambah Sertifikasi'));
  await tester.pumpAndSettle();
}

// Membuka formulir sertifikasi lewat opsi di Drawer.
Future<void> openFromDrawer(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(Drawer),
      matching: find.text('Add Certification'),
    ),
  );
  await tester.pumpAndSettle();
}

// Finder kolom berdasarkan label-nya.
Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> tapSave(WidgetTester tester) async {
  // ensureVisible meniru pengguna men-scroll sampai tombol terlihat.
  await tester.ensureVisible(find.text('Save'));
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

// Memilih tanggal di date picker (tanggal awal = hari ini, lalu tekan OK).
Future<void> pickToday(WidgetTester tester) async {
  // Di layar sempit kolom ini bisa di bawah area terlihat; scroll dulu.
  await tester.ensureVisible(field('Tanggal Terbit'));
  await tester.tap(field('Tanggal Terbit'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

String todayText() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}

Future<void> fillValidForm(WidgetTester tester) async {
  await tester.enterText(field('Nama Sertifikasi'), 'Meta Backend Developer');
  await tester.enterText(field('Nama Penerbit'), 'Coursera');
  await pickToday(tester);
  await tester.enterText(
    field('Bukti Sertifikasi (opsional)'),
    'https://coursera.org/verify/abc',
  );
}

/// Store yang dipakai aplikasi pada [tester], untuk menyiapkan atau memeriksa data.
CertificationStore storeOf(WidgetTester tester) {
  return CertificationScope.read(tester.element(find.byType(MaterialApp)));
}

/// Membuka halaman daftar sertifikasi lewat kartu aksi di halaman utama.
Future<void> openListFromCard(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Lihat Sertifikasi'));
  await tester.tap(find.text('Lihat Sertifikasi'));
  await tester.pumpAndSettle();
}
