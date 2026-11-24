import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

import 'test_helpers.dart';

// AuthState dengan ApiClient palsu; semua request dicatat di [requests].
AuthState authWith(
  MockClientHandler handler, {
  List<http.Request>? requests,
  String? initialToken,
}) {
  final api = fakeApiClient(
    handler: (request) {
      requests?.add(request);
      return handler(request);
    },
  );
  return AuthState(api, initialToken: initialToken);
}

void main() {
  group('login', () {
    test('menyimpan token dan memberi tahu pendengar', () async {
      final auth = authWith((_) async => jsonResponse({'token': 'tok-1'}, 200));
      var notified = 0;
      auth.addListener(() => notified++);
      expect(auth.isLoggedIn, isFalse);

      await auth.login('owner', 'rahasia');

      expect(auth.token, 'tok-1');
      expect(auth.isLoggedIn, isTrue);
      expect(notified, 1);
    });

    test(
      'gagal: token tetap kosong, tidak memberi tahu, galat diteruskan',
      () async {
        final auth = authWith((_) async {
          return jsonResponse({
            'non_field_errors': ['Unable to log in with provided credentials.'],
          }, 400);
        });
        var notified = 0;
        auth.addListener(() => notified++);

        await expectLater(
          auth.login('owner', 'salah'),
          throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'statusCode', 400),
          ),
        );

        expect(auth.token, isNull);
        expect(auth.isLoggedIn, isFalse);
        expect(notified, 0);
      },
    );
  });

  group('logout', () {
    test('memanggil API dengan token lalu mengosongkan sesi', () async {
      final requests = <http.Request>[];
      final auth = authWith(
        (_) async => http.Response('', 204),
        requests: requests,
        initialToken: 'tok-1',
      );
      var notified = 0;
      auth.addListener(() => notified++);

      await auth.logout();

      expect(requests, hasLength(1));
      expect(requests.single.url.path, '/api/v1/auth/logout/');
      expect(requests.single.headers['Authorization'], 'Token tok-1');
      expect(auth.token, isNull);
      expect(auth.isLoggedIn, isFalse);
      expect(notified, 1);
    });

    test('sesi lokal tetap berakhir walau server menolak (401)', () async {
      final auth = authWith(
        (_) async => http.Response('', 401),
        initialToken: 'basi',
      );

      await auth.logout();

      expect(auth.isLoggedIn, isFalse);
    });

    test('sesi lokal tetap berakhir walau server galat (500)', () async {
      final auth = authWith(
        (_) async => http.Response('', 500),
        initialToken: 'tok',
      );

      await auth.logout();

      expect(auth.isLoggedIn, isFalse);
    });

    test('sesi lokal tetap berakhir saat tidak ada koneksi', () async {
      final auth = authWith(
        (_) async => throw http.ClientException('offline'),
        initialToken: 'tok',
      );
      var notified = 0;
      auth.addListener(() => notified++);

      await auth.logout();

      expect(auth.isLoggedIn, isFalse);
      expect(notified, 1);
    });

    test('tanpa login: tidak memanggil API dan tidak memberi tahu', () async {
      final requests = <http.Request>[];
      final auth = authWith(
        (_) async => http.Response('', 204),
        requests: requests,
      );
      var notified = 0;
      auth.addListener(() => notified++);

      await auth.logout();

      expect(requests, isEmpty);
      expect(notified, 0);
    });
  });
}
