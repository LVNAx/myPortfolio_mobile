import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

import 'test_helpers.dart';

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
}

Future<void> tapDrawerItem(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(Drawer), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

// Login lewat opsi Login di Drawer. SnackBar "Login berhasil." di dasar layar
// bisa menutupi kartu menu, jadi secara bawaan ditunggu sampai hilang.
Future<void> loginViaDrawer(
  WidgetTester tester, {
  bool waitForSnackBar = true,
}) async {
  await openDrawer(tester);
  await tapDrawerItem(tester, 'Login');
  await submitLogin(tester);
  if (waitForSnackBar) {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }
}

List<http.Request> postsTo(List<http.Request> log, String path) {
  return log.where((r) => r.method == 'POST' && r.url.path == path).toList();
}

void main() {
  group('Kartu Tambah Proyek', () {
    testWidgets(
      'belum login: layar login muncul, dibatalkan tetap di beranda',
      (WidgetTester tester) async {
        await pumpApp(tester, apiClient: backendApiClient());

        await tester.tap(find.text('Tambah Proyek'));
        await tester.pumpAndSettle();
        expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.text('Add Project Form'), findsNothing);
        expect(
          find.text('Selamat datang di MyPortfolio Mobile!'),
          findsOneWidget,
        );
      },
    );

    testWidgets('sudah login: langsung ke form tanpa layar login', (
      WidgetTester tester,
    ) async {
      final log = <http.Request>[];
      await pumpApp(tester, apiClient: backendApiClient(log: log));

      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();
      await submitLogin(tester);
      expect(find.text('Add Project Form'), findsOneWidget);

      // Kembali ke beranda dengan tombol Back sistem, lalu buka lagi.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();

      expect(find.text('Add Project Form'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsNothing);
      expect(postsTo(log, '/api/v1/auth/token/'), hasLength(1));
    });

    testWidgets('kredensial salah: tetap di layar login', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, apiClient: backendApiClient(loginStatus: 400));

      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();
      await submitLogin(tester, password: 'salah');

      expect(find.textContaining('Login failed (400)'), findsOneWidget);
      expect(find.text('Add Project Form'), findsNothing);
    });
  });

  group('Halaman publik', () {
    testWidgets('daftar proyek dapat dibuka tanpa login', (
      WidgetTester tester,
    ) async {
      final log = <http.Request>[];
      await pumpApp(tester, apiClient: backendApiClient(log: log));

      await tester.tap(find.text('Lihat Proyek'));
      await tester.pumpAndSettle();

      expect(find.text('Website Portofolio'), findsOneWidget);
      expect(postsTo(log, '/api/v1/auth/token/'), isEmpty);
    });
  });

  group('Drawer', () {
    testWidgets('belum login: menampilkan Login, bukan Logout', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, apiClient: backendApiClient());
      await openDrawer(tester);

      expect(
        find.descendant(of: find.byType(Drawer), matching: find.text('Login')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(Drawer), matching: find.text('Logout')),
        findsNothing,
      );
    });

    testWidgets(
      'Login: berhasil menutup Drawer dan menukar opsi menjadi Logout',
      (WidgetTester tester) async {
        await pumpApp(tester, apiClient: backendApiClient());

        await loginViaDrawer(tester, waitForSnackBar: false);

        expect(find.byType(Drawer), findsNothing);
        expect(find.text('Login berhasil.'), findsOneWidget);

        await openDrawer(tester);
        expect(
          find.descendant(
            of: find.byType(Drawer),
            matching: find.text('Logout'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(Drawer),
            matching: find.text('Login'),
          ),
          findsNothing,
        );
      },
    );

    testWidgets('Login dibatalkan: tidak ada perubahan status', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, apiClient: backendApiClient());
      await openDrawer(tester);
      await tapDrawerItem(tester, 'Login');

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Login berhasil.'), findsNothing);
      expect(
        find.descendant(of: find.byType(Drawer), matching: find.text('Login')),
        findsOneWidget,
      );
    });

    testWidgets(
      'Logout: memanggil API dengan token lalu kembali menampilkan Login',
      (WidgetTester tester) async {
        final log = <http.Request>[];
        await pumpApp(tester, apiClient: backendApiClient(log: log));
        await loginViaDrawer(tester);

        await openDrawer(tester);
        await tapDrawerItem(tester, 'Logout');

        final logouts = postsTo(log, '/api/v1/auth/logout/');
        expect(logouts, hasLength(1));
        expect(logouts.single.headers['Authorization'], 'Token tok-1');
        expect(find.text('Berhasil logout.'), findsOneWidget);

        await openDrawer(tester);
        expect(
          find.descendant(
            of: find.byType(Drawer),
            matching: find.text('Login'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('Add Project dari Drawer: login dulu, lalu form', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, apiClient: backendApiClient());
      await openDrawer(tester);
      await tapDrawerItem(tester, 'Add Project');

      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      expect(find.text('Add Project Form'), findsNothing);

      await submitLogin(tester);

      expect(find.text('Add Project Form'), findsOneWidget);
    });
  });

  group('Kartu Logout', () {
    testWidgets('belum login: SnackBar "belum login" dan API tidak dipanggil', (
      WidgetTester tester,
    ) async {
      final log = <http.Request>[];
      await pumpApp(tester, apiClient: backendApiClient(log: log));

      await tester.ensureVisible(find.text('Logout'));
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Kamu belum login.'), findsOneWidget);
      expect(
        find.textContaining('Kamu telah menekan tombol Logout!'),
        findsOneWidget,
      );
      expect(postsTo(log, '/api/v1/auth/logout/'), isEmpty);
    });

    testWidgets('sudah login: memanggil API dan menampilkan SnackBar', (
      WidgetTester tester,
    ) async {
      final log = <http.Request>[];
      await pumpApp(tester, apiClient: backendApiClient(log: log));
      await loginViaDrawer(tester);

      await tester.ensureVisible(find.text('Logout'));
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(postsTo(log, '/api/v1/auth/logout/'), hasLength(1));
      expect(find.textContaining('Berhasil logout.'), findsOneWidget);
      expect(
        find.textContaining('Kamu telah menekan tombol Logout!'),
        findsOneWidget,
      );

      // Setelah logout, Tambah Proyek kembali meminta login.
      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('server menolak logout: sesi lokal tetap berakhir', (
      WidgetTester tester,
    ) async {
      final api = fakeApiClient(
        handler: (request) async {
          if (request.url.path == '/api/v1/auth/token/') {
            return jsonResponse({'token': 'tok-basi'}, 200);
          }
          return http.Response('', 401);
        },
      );
      await pumpApp(tester, apiClient: api);
      await loginViaDrawer(tester);

      await tester.ensureVisible(find.text('Logout'));
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Berhasil logout.'), findsOneWidget);
      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });
  });
}
