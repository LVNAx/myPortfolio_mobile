import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';

void main() {
  testWidgets('Halaman menu menampilkan info pemilik dan tombol aksi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // InfoCard identitas pemilik.
    expect(find.text('NPM'), findsOneWidget);
    expect(find.text('Burhan'), findsOneWidget);
    expect(find.text('PBP A'), findsOneWidget);

    // Tiga tombol menu aksi.
    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);

    // Menekan tombol memunculkan SnackBar.
    await tester.tap(find.text('Lihat Proyek'));
    await tester.pump();
    expect(
      find.text('Kamu telah menekan tombol Lihat Proyek!'),
      findsOneWidget,
    );
  });
}
