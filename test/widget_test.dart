import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/main.dart';

// Membuka halaman form lewat tombol "Tambah Proyek" pada halaman utama.
Future<void> openProjectForm(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.tap(find.text('Tambah Proyek'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Halaman menu menampilkan info pemilik dan tombol aksi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // InfoCard identitas pemilik.
    expect(find.text('NPM'), findsOneWidget);
    expect(find.text('2506541250'), findsOneWidget);
    expect(find.text('Nugraha Kautsarrizqi Caksana'), findsOneWidget);
    expect(find.text('PBP-B'), findsOneWidget);

    // Tiga tombol menu aksi.
    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('Logout menampilkan SnackBar dan tidak pindah halaman', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Lihat Proyek menampilkan SnackBar dan membuka daftar proyek', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Lihat Proyek'));
    await tester.pumpAndSettle();

    expect(
      find.text('Kamu telah menekan tombol Lihat Proyek!'),
      findsOneWidget,
    );
    expect(find.text('Website Portofolio (Django)'), findsOneWidget);

    // Tombol Back sistem (perangkat/browser) membawa pengguna ke halaman utama.
    // Halaman yang punya Drawer menampilkan ikon menu, bukan panah kembali.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Tambah Proyek menampilkan SnackBar dan membuka halaman form', (
    WidgetTester tester,
  ) async {
    await openProjectForm(tester);

    expect(
      find.text('Kamu telah menekan tombol Tambah Proyek!'),
      findsOneWidget,
    );
    expect(find.text('Add Project Form'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
  });

  testWidgets('Form menolak isian kosong dan menampilkan pesan error', (
    WidgetTester tester,
  ) async {
    await openProjectForm(tester);

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
    // Dialog tidak muncul karena validasi gagal.
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Form valid menampilkan dialog berisi data lalu direset', (
    WidgetTester tester,
  ) async {
    await openProjectForm(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Aplikasi Mobile');
    await tester.enterText(fields.at(1), 'Portofolio berbasis Flutter');
    await tester.enterText(fields.at(2), 'Flutter, Dart');
    await tester.enterText(fields.at(3), 'https://example.com');

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Nama Proyek: Aplikasi Mobile'), findsOneWidget);
    expect(find.text('Deskripsi: Portofolio berbasis Flutter'), findsOneWidget);
    expect(find.text('Kategori: Web Development'), findsOneWidget);
    expect(find.text('Teknologi: Flutter, Dart'), findsOneWidget);
    expect(find.text('Tautan: https://example.com'), findsOneWidget);

    // OK menutup dialog dan mengosongkan form.
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Aplikasi Mobile'), findsNothing);
  });

  testWidgets('Drawer menampilkan menu dan bisa dipakai untuk navigasi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('My Portfolio'), findsOneWidget);

    // Menu drawer "Add Project" membuka halaman form.
    await tester.tap(
      find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Add Project'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Add Project Form'), findsOneWidget);

    // Dari halaman form, drawer "View Projects" membuka daftar proyek.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(Drawer),
        matching: find.text('View Projects'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Website Portofolio (Django)'), findsOneWidget);

    // Dan "Home" membawa kembali ke halaman utama.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: find.byType(Drawer), matching: find.text('Home')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });
}
