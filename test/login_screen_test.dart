import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';

import 'test_helpers.dart';

// Halaman uji dengan satu tombol yang memanggil ensureLoggedIn dan
// menampilkan hasilnya sebagai teks.
class _GuardHarness extends StatefulWidget {
  const _GuardHarness();

  @override
  State<_GuardHarness> createState() => _GuardHarnessState();
}

class _GuardHarnessState extends State<_GuardHarness> {
  String _result = 'belum dicoba';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('hasil: $_result'),
          ElevatedButton(
            onPressed: () async {
              final ok = await ensureLoggedIn(context);
              if (!mounted) return;
              setState(() => _result = '$ok');
            },
            child: const Text('Buka halaman terlindungi'),
          ),
        ],
      ),
    );
  }
}

Future<void> pumpHarness(
  WidgetTester tester,
  ApiClient api, {
  String? initialToken,
}) {
  return tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider.value(value: api),
        ChangeNotifierProvider(
          create: (_) => AuthState(api, initialToken: initialToken),
        ),
      ],
      child: const MaterialApp(home: _GuardHarness()),
    ),
  );
}

AuthState authOf(WidgetTester tester) {
  return tester.element(find.byType(MaterialApp)).read<AuthState>();
}

// Label dan hint sama-sama bertuliskan nama kolom, jadi dicari lewat urutan.
Finder get usernameField => find.byType(TextFormField).first;
Finder get passwordField => find.byType(TextFormField).last;

Future<void> openLogin(WidgetTester tester) async {
  await tester.tap(find.text('Buka halaman terlindungi'));
  await tester.pumpAndSettle();
}

void main() {
  group('ensureLoggedIn', () {
    testWidgets('sudah login: langsung true tanpa membuka layar login', (
      WidgetTester tester,
    ) async {
      await pumpHarness(tester, fakeApiClient(), initialToken: 'tok');

      await tester.tap(find.text('Buka halaman terlindungi'));
      await tester.pumpAndSettle();

      expect(find.text('hasil: true'), findsOneWidget);
      expect(find.text('Login'), findsNothing);
    });

    testWidgets('belum login: membuka layar login', (
      WidgetTester tester,
    ) async {
      await pumpHarness(tester, fakeApiClient());
      await openLogin(tester);

      expect(find.text('Login'), findsNWidgets(2)); // judul AppBar + tombol
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('layar login ditutup tanpa masuk: hasilnya false', (
      WidgetTester tester,
    ) async {
      await pumpHarness(tester, fakeApiClient());
      await openLogin(tester);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('hasil: false'), findsOneWidget);
      expect(authOf(tester).isLoggedIn, isFalse);
    });

    testWidgets('login berhasil: layar tertutup dan hasilnya true', (
      WidgetTester tester,
    ) async {
      await pumpHarness(
        tester,
        fakeApiClient(
          handler: (_) async => jsonResponse({'token': 'tok-1'}, 200),
        ),
      );
      await openLogin(tester);

      await tester.enterText(usernameField, 'owner');
      await tester.enterText(passwordField, 'rahasia');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('hasil: true'), findsOneWidget);
      expect(authOf(tester).token, 'tok-1');
    });
  });

  group('LoginScreen', () {
    testWidgets('kolom kosong ditolak dan API tidak dipanggil', (
      WidgetTester tester,
    ) async {
      var calls = 0;
      await pumpHarness(
        tester,
        fakeApiClient(
          handler: (_) async {
            calls++;
            return jsonResponse({'token': 'x'}, 200);
          },
        ),
      );
      await openLogin(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Username cannot be empty!'), findsOneWidget);
      expect(find.text('Password cannot be empty!'), findsOneWidget);
      expect(calls, 0);
    });

    testWidgets('password disamarkan', (WidgetTester tester) async {
      await pumpHarness(tester, fakeApiClient());
      await openLogin(tester);

      final password = tester.widget<TextField>(
        find.descendant(of: passwordField, matching: find.byType(TextField)),
      );
      expect(password.obscureText, isTrue);
    });

    testWidgets(
      'kredensial salah: SnackBar berisi kode status, tetap di layar',
      (WidgetTester tester) async {
        await pumpHarness(
          tester,
          fakeApiClient(
            handler: (_) async {
              return jsonResponse({
                'non_field_errors': [
                  'Unable to log in with provided credentials.',
                ],
              }, 400);
            },
          ),
        );
        await openLogin(tester);

        await tester.enterText(usernameField, 'owner');
        await tester.enterText(passwordField, 'salah');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Login failed (400): Unable to log in with provided credentials.',
          ),
          findsOneWidget,
        );
        expect(authOf(tester).isLoggedIn, isFalse);
        // Tombol aktif lagi supaya pengguna bisa mencoba ulang.
        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Login'),
        );
        expect(button.onPressed, isNotNull);
      },
    );

    testWidgets('tanpa koneksi: SnackBar pesan umum', (
      WidgetTester tester,
    ) async {
      await pumpHarness(
        tester,
        fakeApiClient(
          handler: (_) async => throw http.ClientException('offline'),
        ),
      );
      await openLogin(tester);

      await tester.enterText(usernameField, 'owner');
      await tester.enterText(passwordField, 'rahasia');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Cannot reach the server'), findsOneWidget);
    });

    testWidgets('saat mengirim: tombol nonaktif dan menampilkan spinner', (
      WidgetTester tester,
    ) async {
      final response = Completer<http.Response>();
      await pumpHarness(tester, fakeApiClient(handler: (_) => response.future));
      await openLogin(tester);

      await tester.enterText(usernameField, 'owner');
      await tester.enterText(passwordField, 'rahasia');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      response.complete(jsonResponse({'token': 'tok'}, 200));
      await tester.pumpAndSettle();
      expect(find.text('hasil: true'), findsOneWidget);
    });
  });
}
