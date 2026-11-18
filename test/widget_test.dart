import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/main.dart';

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

    // Tombol kembali pada AppBar membawa pengguna ke halaman utama.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Tambah Proyek membuka halaman formulir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();

    expect(find.text('Nama Proyek'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
  });

  testWidgets('Drawer menampilkan menu dan bisa dipakai untuk navigasi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text('Beranda'), findsOneWidget);

    // Menu drawer "Tambah Proyek" menutup drawer lalu membuka halaman formulir.
    await tester.tap(
      find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Tambah Proyek'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nama Proyek'), findsOneWidget);
  });
}
