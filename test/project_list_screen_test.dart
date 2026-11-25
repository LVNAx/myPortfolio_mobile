import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

// Membuka layar daftar proyek lewat kartu "Lihat Proyek".
Future<void> openProjectList(WidgetTester tester) async {
  await tester.tap(find.text('Lihat Proyek'));
  await tester.pumpAndSettle();
}

void main() {
  group('Daftar proyek dari API', () {
    testWidgets('menampilkan indikator loading lalu daftar proyek', (
      WidgetTester tester,
    ) async {
      final response = Completer<http.Response>();
      await pumpApp(
        tester,
        apiClient: fakeApiClient(handler: (_) => response.future),
      );

      await tester.tap(find.text('Lihat Proyek'));
      // pumpAndSettle tidak bisa dipakai: indikator loading beranimasi tanpa
      // henti. Cukup majukan waktu sampai transisi halaman selesai.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      response.complete(jsonResponse([sampleProjectJson], 200));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Website Portofolio'), findsOneWidget);
      expect(find.textContaining('Django, HTML, CSS'), findsOneWidget);
      expect(
        find.textContaining('Website portofolio pribadi.'),
        findsOneWidget,
      );
    });

    testWidgets('daftar kosong menampilkan pesan No projects found.', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, apiClient: fakeApiClient());
      await openProjectList(tester);

      expect(find.text('No projects found.'), findsOneWidget);
    });

    testWidgets('galat server menampilkan pesan dan tombol Retry', (
      WidgetTester tester,
    ) async {
      var calls = 0;
      await pumpApp(
        tester,
        apiClient: fakeApiClient(
          handler: (_) async {
            calls++;
            return calls == 1
                ? jsonResponse({'detail': 'boom'}, 500)
                : jsonResponse([sampleProjectJson], 200);
          },
        ),
      );
      await openProjectList(tester);

      expect(find.textContaining('Failed to load projects'), findsOneWidget);
      expect(find.textContaining('Server sedang bermasalah'), findsOneWidget);
      // Body mentah dari server tidak boleh bocor ke layar.
      expect(find.textContaining('boom'), findsNothing);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Website Portofolio'), findsOneWidget);
      expect(calls, 2);
    });

    testWidgets('gagal terhubung menampilkan pesan umum', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        apiClient: fakeApiClient(
          handler: (_) async =>
              throw http.ClientException('tidak ada jaringan'),
        ),
      );
      await openProjectList(tester);

      expect(find.textContaining('Cannot reach the server'), findsOneWidget);
    });

    testWidgets('tarik ke bawah memuat ulang data', (
      WidgetTester tester,
    ) async {
      var calls = 0;
      await pumpApp(
        tester,
        apiClient: fakeApiClient(
          handler: (_) async {
            calls++;
            return jsonResponse([sampleProjectJson], 200);
          },
        ),
      );
      await openProjectList(tester);
      expect(calls, 1);

      await tester.fling(
        find.text('Website Portofolio'),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      expect(calls, 2);
    });

    testWidgets('pull-to-refresh juga bekerja saat daftar kosong', (
      WidgetTester tester,
    ) async {
      var calls = 0;
      await pumpApp(
        tester,
        apiClient: fakeApiClient(
          handler: (_) async {
            calls++;
            return jsonResponse([], 200);
          },
        ),
      );
      await openProjectList(tester);

      await tester.fling(
        find.text('No projects found.'),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      expect(calls, 2);
    });

    testWidgets('data tidak diambil ulang saat widget dibangun ulang', (
      WidgetTester tester,
    ) async {
      var calls = 0;
      await pumpApp(
        tester,
        apiClient: fakeApiClient(
          handler: (_) async {
            calls++;
            return jsonResponse([sampleProjectJson], 200);
          },
        ),
      );
      await openProjectList(tester);

      // Membuka dan menutup Drawer memicu rebuild, tetapi bukan request baru.
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(780, 300));
      await tester.pumpAndSettle();

      expect(calls, 1);
    });
  });

  group('Detail proyek', () {
    testWidgets('mengetuk proyek membuka detail lengkap', (
      WidgetTester tester,
    ) async {
      // Tanpa gambar supaya seluruh teks muat di layar test (600 px).
      await pumpApp(
        tester,
        apiClient: fakeApiClient(
          projects: [
            {...sampleProjectJson, 'thumbnail_url': ''},
          ],
        ),
      );
      await openProjectList(tester);

      await tester.tap(find.text('Website Portofolio'));
      await tester.pumpAndSettle();

      expect(
        find.text('Full-stack developer - Web Development'),
        findsOneWidget,
      );
      expect(find.text('2026-01-10 - Present'), findsOneWidget);
      expect(find.text('Website portofolio pribadi.'), findsOneWidget);
      expect(find.text('• Memakai Django'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'Django'), findsOneWidget);
      expect(find.text('https://example.com'), findsOneWidget);
      expect(find.text('https://github.com/example/repo'), findsOneWidget);
    });

    testWidgets('gambar ditampilkan bila URL tidak kosong', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        apiClient: fakeApiClient(projects: [sampleProjectJson]),
      );
      await openProjectList(tester);
      await tester.tap(find.text('Website Portofolio'));
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('gambar tidak ditampilkan bila URL kosong', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        apiClient: fakeApiClient(
          projects: [
            {...sampleProjectJson, 'thumbnail_url': ''},
          ],
        ),
      );
      await openProjectList(tester);
      await tester.tap(find.text('Website Portofolio'));
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsNothing);
    });

    testWidgets('proyek yang sudah selesai menampilkan tanggal selesai', (
      WidgetTester tester,
    ) async {
      await pumpApp(
        tester,
        apiClient: fakeApiClient(
          projects: [
            {...sampleProjectJson, 'ended_at': '2026-03-01'},
          ],
        ),
      );
      await openProjectList(tester);
      await tester.tap(find.text('Website Portofolio'));
      await tester.pumpAndSettle();

      expect(find.text('2026-01-10 - 2026-03-01'), findsOneWidget);
    });
  });
}
