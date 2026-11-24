import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/models/project_category.dart';

import 'test_helpers.dart';

// Membuka halaman form lewat tombol "Tambah Proyek" pada halaman utama.
Future<void> openProjectForm(WidgetTester tester) async {
  await pumpApp(tester);
  await tester.tap(find.text('Tambah Proyek'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Halaman menu menampilkan info pemilik dan tombol aksi', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

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
    await pumpApp(tester);

    // Kartu Logout ada di baris kedua grid, jadi scroll dulu seperti pengguna.
    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Lihat Proyek menampilkan SnackBar dan membuka daftar proyek', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      apiClient: fakeApiClient(projects: [sampleProjectJson]),
    );

    await tester.tap(find.text('Lihat Proyek'));
    await tester.pumpAndSettle();

    expect(
      find.text('Kamu telah menekan tombol Lihat Proyek!'),
      findsOneWidget,
    );
    expect(find.text('Website Portofolio'), findsOneWidget);

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
    // Judul, peran, deskripsi, teknologi, 2 URL, dan 2 tanggal.
    expect(find.byType(TextFormField), findsNWidgets(8));
    expect(
      find.byType(DropdownButtonFormField<ProjectCategory>),
      findsOneWidget,
    );
  });

  testWidgets('Drawer menampilkan menu dan bisa dipakai untuk navigasi', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      apiClient: fakeApiClient(projects: [sampleProjectJson]),
    );

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
    expect(find.text('Website Portofolio'), findsOneWidget);

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
