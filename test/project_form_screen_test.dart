import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/models/project_category.dart';

import 'test_helpers.dart';

List<http.Request> postsTo(List<http.Request> log, String path) {
  return log.where((r) => r.method == 'POST' && r.url.path == path).toList();
}

void main() {
  group('Tampilan formulir', () {
    testWidgets('berisi kolom sesuai skema backend', (
      WidgetTester tester,
    ) async {
      await openProjectFormWith(tester, backendApiClient());

      expect(find.text('Add Project Form'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(8));
      expect(
        find.byType(DropdownButtonFormField<ProjectCategory>),
        findsOneWidget,
      );
      expect(find.text('Tanggal Mulai'), findsOneWidget);
      expect(find.text('Tanggal Selesai (opsional)'), findsOneWidget);
    });
  });

  group('Validasi', () {
    testWidgets('isian kosong ditolak tanpa meminta login atau memanggil API', (
      WidgetTester tester,
    ) async {
      final log = <http.Request>[];
      await openProjectFormWith(tester, backendApiClient(log: log));
      log.clear();

      await tapSaveProject(tester);

      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Peran tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Teknologi tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Tanggal mulai wajib dipilih!'), findsOneWidget);
      expect(find.text('Login'), findsNothing);
      expect(log, isEmpty);
    });

    testWidgets('spasi saja, tag HTML, dan URL tanpa skema ditolak', (
      WidgetTester tester,
    ) async {
      await openProjectFormWith(tester, backendApiClient());

      await enterField(tester, ProjectField.title, '     ');
      await enterField(tester, ProjectField.role, '<b>Dev</b>');
      await enterField(tester, ProjectField.description, 'ok');
      await enterField(tester, ProjectField.techStack, 'Flutter');
      await enterField(tester, ProjectField.liveUrl, 'contoh.com');
      await enterField(tester, ProjectField.githubUrl, 'ftp://x.com');
      await setDateField(tester, ProjectField.startDate, '2026-11-01');
      await tapSaveProject(tester);

      expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Peran tidak boleh berisi tag HTML!'), findsOneWidget);
      expect(
        find.textContaining('Tautan live harus berupa URL yang valid'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Tautan GitHub harus berupa URL yang valid'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('tanggal selesai sebelum tanggal mulai ditolak', (
      WidgetTester tester,
    ) async {
      await openProjectFormWith(tester, backendApiClient());
      await fillProjectForm(tester);

      await setDateField(tester, ProjectField.endDate, '2026-01-01');
      await tapSaveProject(tester);

      expect(
        find.text('Tanggal selesai tidak boleh sebelum tanggal mulai.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('tanggal selesai yang sama atau sesudah mulai diterima', (
      WidgetTester tester,
    ) async {
      await openProjectFormWith(tester, backendApiClient());
      await fillProjectForm(tester);

      await setDateField(tester, ProjectField.endDate, '2026-11-01');
      await tapSaveProject(tester);
      expect(
        find.text('Tanggal selesai tidak boleh sebelum tanggal mulai.'),
        findsNothing,
      );
    });
  });

  group('Mengirim ke backend', () {
    testWidgets('login saat membuka form, lalu proyek dikirim dengan token', (
      WidgetTester tester,
    ) async {
      final log = <http.Request>[];
      await openProjectFormWith(tester, backendApiClient(log: log));
      // Login terjadi saat form dibuka lewat kartu, bukan saat Save.
      expect(postsTo(log, '/api/v1/auth/token/'), hasLength(1));
      expect(postsTo(log, '/api/v1/projects/'), isEmpty);

      await fillProjectForm(tester);
      await tapSaveProject(tester);

      final posts = postsTo(log, '/api/v1/projects/');
      expect(posts, hasLength(1));
      expect(posts.single.headers['Authorization'], 'Token tok-1');
      final body = jsonDecode(posts.single.body) as Map<String, dynamic>;
      expect(body['title'], 'Aplikasi Mobile');
      expect(body['role'], 'Mobile developer');
      expect(body['category'], 'web');
      expect(body['tech_stack'], 'Flutter, Dart');
      expect(body['started_at'], '2026-11-01');
      expect(body.containsKey('ended_at'), isFalse);
      expect(body.containsKey('id'), isFalse);

      // Dialog 201 Created memakai data dari respons server.
      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      expect(find.text('Nama Proyek: Aplikasi Mobile'), findsOneWidget);
      expect(find.text('Kategori: Web Development'), findsOneWidget);
      expect(find.text('Selesai: Masih berjalan'), findsOneWidget);
    });

    testWidgets('kategori dan tanggal selesai ikut terkirim', (
      WidgetTester tester,
    ) async {
      final log = <http.Request>[];
      await openProjectFormWith(tester, backendApiClient(log: log));
      await fillProjectForm(tester);

      await tester.ensureVisible(
        find.byType(DropdownButtonFormField<ProjectCategory>),
      );
      await tester.tap(find.byType(DropdownButtonFormField<ProjectCategory>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Competition').last);
      await tester.pumpAndSettle();
      await setDateField(tester, ProjectField.endDate, '2026-12-31');
      await enterField(
        tester,
        ProjectField.liveUrl,
        'https://demo.example.com',
      );

      await tapSaveProject(tester);

      final body =
          jsonDecode(postsTo(log, '/api/v1/projects/').single.body)
              as Map<String, dynamic>;
      expect(body['category'], 'competition');
      expect(body['ended_at'], '2026-12-31');
      expect(body['live_url'], 'https://demo.example.com');
    });

    testWidgets('pengiriman berikutnya tidak meminta login lagi', (
      WidgetTester tester,
    ) async {
      final log = <http.Request>[];
      await openProjectFormWith(tester, backendApiClient(log: log));
      await fillProjectForm(tester);
      await tapSaveProject(tester);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await fillProjectForm(tester);
      await tapSaveProject(tester);

      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      expect(postsTo(log, '/api/v1/auth/token/'), hasLength(1));
      expect(postsTo(log, '/api/v1/projects/'), hasLength(2));
    });

    testWidgets('setelah logout dari Drawer, Save meminta login lagi', (
      WidgetTester tester,
    ) async {
      final log = <http.Request>[];
      await openProjectFormWith(tester, backendApiClient(log: log));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      // Tunggu SnackBar "Berhasil logout." hilang agar tidak menutupi tombol Save.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await fillProjectForm(tester);
      await tapSaveProject(tester);

      // Layar login terbuka dan belum ada proyek yang dikirim.
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      expect(postsTo(log, '/api/v1/projects/'), isEmpty);

      await submitLogin(tester);

      // Login berhasil melanjutkan pengiriman tanpa perlu menekan Save lagi.
      expect(postsTo(log, '/api/v1/auth/token/'), hasLength(2));
      expect(postsTo(log, '/api/v1/projects/'), hasLength(1));
      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    });

    testWidgets('login dibatalkan saat Save: tidak ada proyek yang dikirim', (
      WidgetTester tester,
    ) async {
      final log = <http.Request>[];
      await openProjectFormWith(tester, backendApiClient(log: log));
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      // Tunggu SnackBar "Berhasil logout." hilang agar tidak menutupi tombol Save.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await fillProjectForm(tester);
      await tapSaveProject(tester);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(postsTo(log, '/api/v1/projects/'), isEmpty);
      expect(find.text('Add Project Form'), findsOneWidget);
    });

    testWidgets('OK menutup dialog dan mengosongkan form', (
      WidgetTester tester,
    ) async {
      await openProjectFormWith(tester, backendApiClient());
      await fillProjectForm(tester);
      await tapSaveProject(tester);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(projectFieldText(tester, ProjectField.title), isEmpty);
      expect(projectFieldText(tester, ProjectField.startDate), isEmpty);
    });

    testWidgets('saat mengirim: tombol nonaktif dan menampilkan spinner', (
      WidgetTester tester,
    ) async {
      final response = Completer<http.Response>();
      final api = fakeApiClient(
        handler: (request) {
          if (request.url.path == '/api/v1/auth/token/') {
            return Future.value(jsonResponse({'token': 'tok-1'}, 200));
          }
          return response.future;
        },
      );
      await openProjectFormWith(tester, api);
      await fillProjectForm(tester);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      response.complete(jsonResponse({...sampleProjectJson}, 201));
      await tester.pumpAndSettle();
      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      // Spinner berhenti sebelum dialog muncul, bukan menunggu dialog ditutup.
      final after = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(after.onPressed, isNotNull);
    });
  });

  group('Galat dari server', () {
    testWidgets(
      '401: sesi diakhiri, SnackBar tampil, dan login diminta ulang',
      (WidgetTester tester) async {
        final log = <http.Request>[];
        await openProjectFormWith(
          tester,
          backendApiClient(log: log, createStatus: 401),
        );
        await fillProjectForm(tester);
        await tapSaveProject(tester);

        expect(
          find.text('Session expired. Please log in again.'),
          findsOneWidget,
        );
        // Token lama dicabut di server, lalu layar login terbuka lagi.
        final logouts = postsTo(log, '/api/v1/auth/logout/');
        expect(logouts, hasLength(1));
        expect(logouts.single.headers['Authorization'], 'Token tok-1');
        expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      },
    );

    testWidgets('403: SnackBar berisi kode dan pesan izin', (
      WidgetTester tester,
    ) async {
      await openProjectFormWith(tester, backendApiClient(createStatus: 403));
      await fillProjectForm(tester);
      await tapSaveProject(tester);

      expect(
        find.text(
          'Failed (403): Kamu tidak memiliki izin untuk melakukan tindakan ini.',
        ),
        findsOneWidget,
      );
      // Bukan 401, jadi pengguna tetap login dan tidak diminta login ulang.
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsNothing);
    });

    testWidgets('400: pesan validasi dari server ditampilkan', (
      WidgetTester tester,
    ) async {
      await openProjectFormWith(
        tester,
        backendApiClient(
          createStatus: 400,
          createError: {
            'tech_stack': ['Kolom ini wajib diisi.'],
          },
        ),
      );
      await fillProjectForm(tester);
      await tapSaveProject(tester);

      expect(
        find.text('Failed (400): tech_stack: Kolom ini wajib diisi.'),
        findsOneWidget,
      );
    });

    testWidgets('tanpa koneksi: SnackBar pesan umum dan tombol aktif lagi', (
      WidgetTester tester,
    ) async {
      final api = fakeApiClient(
        handler: (request) async {
          if (request.url.path == '/api/v1/auth/token/') {
            return jsonResponse({'token': 'tok-1'}, 200);
          }
          throw http.ClientException('offline');
        },
      );
      await openProjectFormWith(tester, api);
      await fillProjectForm(tester);
      await tapSaveProject(tester);

      expect(find.textContaining('Cannot reach the server'), findsOneWidget);
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });
  });
}
