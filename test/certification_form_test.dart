import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/models/certification.dart';

import 'test_helpers.dart';

void main() {
  group('Akses formulir', () {
    testWidgets('dari kartu aksi: SnackBar tampil dan form terbuka', (
      WidgetTester tester,
    ) async {
      await openFromCard(tester);

      expect(
        find.text('Kamu telah menekan tombol Tambah Sertifikasi!'),
        findsOneWidget,
      );
      expect(find.text('Add Certification Form'), findsOneWidget);
      // 4 kolom teks (nama, penerbit, tanggal, URL) + 1 dropdown kategori.
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(
        find.byType(DropdownButtonFormField<CertificationCategory>),
        findsOneWidget,
      );
    });

    testWidgets('dari Drawer: form terbuka', (WidgetTester tester) async {
      await openFromDrawer(tester);

      expect(find.text('Add Certification Form'), findsOneWidget);
    });

    testWidgets('Drawer di halaman form tetap berisi Home dan Add Project', (
      WidgetTester tester,
    ) async {
      await openFromCard(tester);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Add Project'), findsOneWidget);
      expect(find.text('Add Certification'), findsOneWidget);
    });
  });

  group('Validasi', () {
    testWidgets('isian kosong ditolak dan pesan error tampil per kolom', (
      WidgetTester tester,
    ) async {
      await openFromCard(tester);
      await tapSave(tester);

      expect(find.text('Nama sertifikasi tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Nama penerbit tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Tanggal terbit wajib dipilih!'), findsOneWidget);
      // Dialog tidak muncul selama masih ada input yang tidak valid.
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('spasi saja, tag HTML, dan URL tanpa skema ditolak', (
      WidgetTester tester,
    ) async {
      await openFromCard(tester);

      await tester.enterText(field('Nama Sertifikasi'), '     ');
      await tester.enterText(field('Nama Penerbit'), '<b>Coursera</b>');
      await pickToday(tester);
      await tester.enterText(
        field('Bukti Sertifikasi (opsional)'),
        'coursera.org',
      );
      await tapSave(tester);

      expect(find.text('Nama sertifikasi tidak boleh kosong!'), findsOneWidget);
      expect(
        find.text('Nama penerbit tidak boleh berisi tag HTML!'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Bukti sertifikasi harus berupa URL yang valid'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('pesan error hilang setelah isian diperbaiki', (
      WidgetTester tester,
    ) async {
      await openFromCard(tester);
      await tapSave(tester);
      expect(find.text('Nama sertifikasi tidak boleh kosong!'), findsOneWidget);

      await tester.enterText(
        field('Nama Sertifikasi'),
        'AWS Cloud Practitioner',
      );
      await tester.pumpAndSettle();
      expect(find.text('Nama sertifikasi tidak boleh kosong!'), findsNothing);
    });
  });

  group('Simpan dan dialog ringkasan', () {
    testWidgets('input valid menampilkan dialog berisi semua isian', (
      WidgetTester tester,
    ) async {
      await openFromCard(tester);
      await fillValidForm(tester);

      // Ganti kategori lewat dropdown.
      await tester.tap(
        find.byType(DropdownButtonFormField<CertificationCategory>),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cyber Security').last);
      await tester.pumpAndSettle();

      await tapSave(tester);

      expect(find.text('Sertifikasi berhasil ditambahkan!'), findsOneWidget);
      expect(
        find.text('Nama Sertifikasi: Meta Backend Developer'),
        findsOneWidget,
      );
      expect(find.text('Penerbit: Coursera'), findsOneWidget);
      expect(find.text('Kategori: Cyber Security'), findsOneWidget);
      expect(find.text('Tanggal Terbit: ${todayText()}'), findsOneWidget);
      expect(
        find.text('Bukti Sertifikasi: https://coursera.org/verify/abc'),
        findsOneWidget,
      );
    });

    testWidgets('URL opsional boleh kosong dan ditampilkan sebagai tanda -', (
      WidgetTester tester,
    ) async {
      await openFromCard(tester);
      await tester.enterText(
        field('Nama Sertifikasi'),
        'Google Data Analytics',
      );
      await tester.enterText(field('Nama Penerbit'), 'Google');
      await pickToday(tester);
      await tapSave(tester);

      expect(find.text('Bukti Sertifikasi: -'), findsOneWidget);
    });

    testWidgets('OK menutup dialog dan kembali ke form yang sudah kosong', (
      WidgetTester tester,
    ) async {
      await openFromCard(tester);
      await fillValidForm(tester);
      await tapSave(tester);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Add Certification Form'), findsOneWidget);
      // Yang diperiksa isi controller; teks hint abu-abu tetap tampil pada
      // kolom kosong sehingga tidak bisa dipakai sebagai patokan.
      final title = tester.widget<TextFormField>(field('Nama Sertifikasi'));
      final date = tester.widget<TextFormField>(field('Tanggal Terbit'));
      expect(title.controller!.text, isEmpty);
      expect(date.controller!.text, isEmpty);
    });
  });

  group('Navigasi', () {
    testWidgets('opsi Home di Drawer membawa kembali ke halaman utama', (
      WidgetTester tester,
    ) async {
      await openFromCard(tester);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: find.byType(Drawer), matching: find.text('Home')),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Selamat datang di MyPortfolio Mobile!'),
        findsOneWidget,
      );
      expect(find.text('Add Certification Form'), findsNothing);
    });

    testWidgets('tombol Back sistem dari form kartu kembali ke halaman utama', (
      WidgetTester tester,
    ) async {
      await openFromCard(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(
        find.text('Selamat datang di MyPortfolio Mobile!'),
        findsOneWidget,
      );
    });
  });

  group('Layar sempit', () {
    testWidgets('tombol Simpan tetap terjangkau saat papan ketik tampil', (
      WidgetTester tester,
    ) async {
      // Ukuran layar ponsel kecil + papan ketik setinggi 300 px.
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.reset);

      await openFromCard(tester);
      // SnackBar dari kartu aksi tampil 4 detik di dasar layar dan bisa menutupi
      // tombol Simpan. Pengguna sungguhan butuh lebih dari 4 detik untuk mengisi
      // form, jadi di sini kita menunggu SnackBar hilang dulu.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await fillValidForm(tester);
      await tapSave(tester);

      expect(find.text('Sertifikasi berhasil ditambahkan!'), findsOneWidget);
    });
  });
}
