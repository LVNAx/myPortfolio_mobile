import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

import 'project_model_test.dart' show apiPayload;

const _baseUrl = 'http://api.test';

http.Response jsonResponse(Object body, int status) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    status,
    // Sama seperti DRF: application/json tanpa charset.
    headers: {'content-type': 'application/json'},
  );
}

ApiClient clientFor(MockClientHandler handler) {
  return ApiClient(client: MockClient(handler), baseUrl: _baseUrl);
}

const _newProject = Project(
  title: 'Dari Flutter',
  role: 'Mobile',
  category: 'web',
  description: 'Deskripsi',
  techStack: 'Flutter',
  startedAt: '2026-11-01',
);

void main() {
  group('getProjects', () {
    test(
      'memanggil GET /api/v1/projects/ dan mengurai daftar proyek',
      () async {
        late http.Request captured;
        final api = clientFor((request) async {
          captured = request;
          return jsonResponse([apiPayload], 200);
        });

        final projects = await api.getProjects();

        expect(captured.method, 'GET');
        expect(captured.url.toString(), '$_baseUrl/api/v1/projects/');
        expect(captured.headers['Accept'], 'application/json');
        expect(captured.headers.containsKey('Authorization'), isFalse);
        expect(projects, hasLength(1));
        expect(projects.single.title, 'Website Portofolio');
      },
    );

    test('membaca huruf non-ASCII sebagai UTF-8', () async {
      final api = clientFor((_) async {
        return jsonResponse([
          {...apiPayload, 'title': 'Pengembangan Aplikasi – Café'},
        ], 200);
      });

      final projects = await api.getProjects();

      expect(projects.single.title, 'Pengembangan Aplikasi – Café');
    });

    test('daftar kosong menghasilkan list kosong', () async {
      final api = clientFor((_) async => jsonResponse([], 200));
      expect(await api.getProjects(), isEmpty);
    });

    test('status non-2xx melempar ApiException', () async {
      final api = clientFor((_) async => jsonResponse({'detail': 'x'}, 500));

      await expectLater(
        api.getProjects(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });
  });

  group('createProject', () {
    test(
      'mengirim POST dengan token, header JSON, dan body snake_case',
      () async {
        late http.Request captured;
        final api = clientFor((request) async {
          captured = request;
          return jsonResponse({...apiPayload, 'title': 'Dari Flutter'}, 201);
        });

        final created = await api.createProject(_newProject, token: 'abc123');

        expect(captured.method, 'POST');
        expect(captured.url.toString(), '$_baseUrl/api/v1/projects/');
        expect(captured.headers['Authorization'], 'Token abc123');
        expect(
          captured.headers['Content-Type'],
          'application/json; charset=UTF-8',
        );
        final body = jsonDecode(captured.body) as Map<String, dynamic>;
        expect(body['tech_stack'], 'Flutter');
        expect(body['started_at'], '2026-11-01');
        expect(body.containsKey('id'), isFalse);
        expect(created.id, isNotNull);
      },
    );

    test('400 membawa pesan validasi dari server', () async {
      final api = clientFor((_) async {
        return jsonResponse({
          'title': ['Nama proyek tidak boleh kosong.'],
        }, 400);
      });

      await expectLater(
        api.createProject(_newProject, token: 't'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having(
                (e) => e.userMessage,
                'userMessage',
                'title: Nama proyek tidak boleh kosong.',
              ),
        ),
      );
    });
  });

  group('obtainToken', () {
    test('mengirim kredensial dan mengembalikan token', () async {
      late http.Request captured;
      final api = clientFor((request) async {
        captured = request;
        return jsonResponse({'token': 'tok-1'}, 200);
      });

      final token = await api.obtainToken('owner', 'rahasia');

      expect(token, 'tok-1');
      expect(captured.url.toString(), '$_baseUrl/api/v1/auth/token/');
      expect(jsonDecode(captured.body), {
        'username': 'owner',
        'password': 'rahasia',
      });
    });

    test(
      'kredensial salah menghasilkan pesan ramah, bukan body mentah',
      () async {
        final api = clientFor((_) async {
          return jsonResponse({
            'non_field_errors': ['Unable to log in with provided credentials.'],
          }, 400);
        });

        await expectLater(
          api.obtainToken('x', 'y'),
          throwsA(
            isA<ApiException>().having(
              (e) => e.userMessage,
              'userMessage',
              'Unable to log in with provided credentials.',
            ),
          ),
        );
      },
    );
  });

  group('logout', () {
    test('mengirim POST ke auth/logout/ dengan token', () async {
      late http.Request captured;
      final api = clientFor((request) async {
        captured = request;
        return http.Response('', 204);
      });

      await api.logout(token: 'tok-1');

      expect(captured.method, 'POST');
      expect(captured.url.toString(), '$_baseUrl/api/v1/auth/logout/');
      expect(captured.headers['Authorization'], 'Token tok-1');
    });

    test('gagal melempar ApiException', () async {
      final api = clientFor((_) async => http.Response('', 401));
      await expectLater(
        api.logout(token: 'basi'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('resolveUrl', () {
    final api = clientFor((_) async => http.Response('', 200));

    test('path relatif digabung dengan base URL', () {
      expect(api.resolveUrl('/static/a.png'), '$_baseUrl/static/a.png');
    });

    test('URL absolut dibiarkan', () {
      expect(
        api.resolveUrl('https://cdn.test/a.png'),
        'https://cdn.test/a.png',
      );
    });
  });

  group('ApiException.userMessage', () {
    test('memetakan status ke pesan ramah', () {
      expect(const ApiException(401, '').userMessage, contains('login ulang'));
      expect(const ApiException(403, '').userMessage, contains('izin'));
      expect(
        const ApiException(404, '').userMessage,
        contains('tidak ditemukan'),
      );
      expect(const ApiException(503, '<html>').userMessage, contains('Server'));
    });

    test('400 dengan body bukan JSON memakai pesan umum', () {
      expect(
        const ApiException(400, '<html>error</html>').userMessage,
        'Data yang dikirim tidak valid.',
      );
    });
  });
}
