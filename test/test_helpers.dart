import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/certification_store.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/certification_scope.dart';

// Membuka formulir sertifikasi lewat kartu aksi di halaman utama.
Future<void> openFromCard(WidgetTester tester) async {
  await pumpApp(tester);
  // Kartu ada di baris kedua grid; ensureVisible meniru pengguna men-scroll.
  await tester.ensureVisible(find.text('Tambah Sertifikasi'));
  await tester.tap(find.text('Tambah Sertifikasi'));
  await tester.pumpAndSettle();
}

// Membuka formulir sertifikasi lewat opsi di Drawer.
Future<void> openFromDrawer(WidgetTester tester) async {
  await pumpApp(tester);
  await tester.tap(find.byIcon(Icons.menu));
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(Drawer),
      matching: find.text('Add Certification'),
    ),
  );
  await tester.pumpAndSettle();
}

// Finder kolom berdasarkan label-nya.
Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> tapSave(WidgetTester tester) async {
  // ensureVisible meniru pengguna men-scroll sampai tombol terlihat.
  await tester.ensureVisible(find.text('Save'));
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

// Memilih tanggal di date picker (tanggal awal = hari ini, lalu tekan OK).
Future<void> pickToday(WidgetTester tester) async {
  // Di layar sempit kolom ini bisa di bawah area terlihat; scroll dulu.
  await tester.ensureVisible(field('Tanggal Terbit'));
  await tester.tap(field('Tanggal Terbit'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

String todayText() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}

Future<void> fillValidForm(WidgetTester tester) async {
  await tester.enterText(field('Nama Sertifikasi'), 'Meta Backend Developer');
  await tester.enterText(field('Nama Penerbit'), 'Coursera');
  await pickToday(tester);
  await tester.enterText(
    field('Bukti Sertifikasi (opsional)'),
    'https://coursera.org/verify/abc',
  );
}

/// Store yang dipakai aplikasi pada [tester], untuk menyiapkan atau memeriksa data.
CertificationStore storeOf(WidgetTester tester) {
  return CertificationScope.read(tester.element(find.byType(MaterialApp)));
}

/// Membuka halaman daftar sertifikasi lewat kartu aksi di halaman utama.
Future<void> openListFromCard(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Lihat Sertifikasi'));
  await tester.tap(find.text('Lihat Sertifikasi'));
  await tester.pumpAndSettle();
}

/// Contoh respons nyata dari ProjectSerializer pada backend Django.
const Map<String, dynamic> sampleProjectJson = {
  'id': '7f0c1d3e-1111-4222-8333-444455556666',
  'title': 'Website Portofolio',
  'role': 'Full-stack developer',
  'category': 'web',
  'category_display': 'Web Development',
  'description': 'Website portofolio pribadi.',
  'highlights': 'Memakai Django\nMemakai DRF',
  'highlight_list': ['Memakai Django', 'Memakai DRF'],
  'tech_stack': 'Django, HTML, CSS',
  'thumbnail_url': '/static/img/portfolio.png',
  'live_url': 'https://example.com',
  'github_url': 'https://github.com/example/repo',
  'started_at': '2026-01-10',
  'ended_at': null,
  'is_ongoing': true,
  'star_count': 3,
  'is_starred': false,
  'starred_by_names': ['a', 'b', 'c'],
};

/// Respons JSON dengan content-type tanpa charset, seperti yang dikirim DRF.
http.Response jsonResponse(Object body, int status) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    status,
    headers: {'content-type': 'application/json'},
  );
}

/// ApiClient yang tidak menyentuh jaringan. GET daftar proyek mengembalikan
/// [projects]; permintaan lain ditangani [handler] atau dijawab 404.
ApiClient fakeApiClient({
  List<Map<String, dynamic>> projects = const [],
  MockClientHandler? handler,
}) {
  return ApiClient(
    baseUrl: 'http://api.test',
    client: MockClient((request) async {
      if (handler != null) return handler(request);
      if (request.method == 'GET' && request.url.path == '/api/v1/projects/') {
        return jsonResponse(projects, 200);
      }
      return jsonResponse({'detail': 'Not found.'}, 404);
    }),
  );
}

/// Menjalankan aplikasi dengan ApiClient palsu.
Future<void> pumpApp(WidgetTester tester, {ApiClient? apiClient}) {
  return tester.pumpWidget(MyApp(apiClient: apiClient ?? fakeApiClient()));
}

/// ApiClient palsu yang meniru backend Django: login, logout, daftar proyek,
/// dan POST proyek. Semua request dicatat di [log].
///
/// [loginStatus] dan [createStatus] mengatur status respons; selain 200/201
/// respons berisi galat. [createBody] menimpa respons sukses POST proyek.
ApiClient backendApiClient({
  List<http.Request>? log,
  int loginStatus = 200,
  int createStatus = 201,
  Map<String, dynamic>? createBody,
  Map<String, dynamic>? createError,
  String token = 'tok-1',
}) {
  return fakeApiClient(
    handler: (request) async {
      log?.add(request);
      switch ('${request.method} ${request.url.path}') {
        case 'POST /api/v1/auth/token/':
          return loginStatus == 200
              ? jsonResponse({'token': token}, 200)
              : jsonResponse({
                  'non_field_errors': [
                    'Unable to log in with provided credentials.',
                  ],
                }, loginStatus);
        case 'POST /api/v1/auth/logout/':
          return http.Response('', 204);
        case 'POST /api/v1/projects/':
          if (createStatus != 201) {
            return jsonResponse(
              createError ?? {'detail': 'galat'},
              createStatus,
            );
          }
          final sent = jsonDecode(request.body) as Map<String, dynamic>;
          return jsonResponse(
            createBody ?? {...sampleProjectJson, ...sent, 'id': 'id-baru'},
            201,
          );
        case 'GET /api/v1/projects/':
          return jsonResponse([sampleProjectJson], 200);
      }
      return jsonResponse({'detail': 'Not found.'}, 404);
    },
  );
}

/// Urutan kolom teks pada formulir proyek.
class ProjectField {
  static const title = 0;
  static const role = 1;
  static const description = 2;
  static const techStack = 3;
  static const liveUrl = 4;
  static const githubUrl = 5;
  static const startDate = 6;
  static const endDate = 7;
}

Finder projectField(int index) => find.byType(TextFormField).at(index);

/// Mengisi kolom ke-[index]; di-scroll dulu karena formulir lebih tinggi
/// daripada layar test.
Future<void> enterField(WidgetTester tester, int index, String text) async {
  await tester.ensureVisible(projectField(index));
  await tester.enterText(projectField(index), text);
}

/// Kolom tanggal bersifat read-only, jadi nilainya ditulis lewat controller
/// (sama seperti hasil date picker).
Future<void> setDateField(WidgetTester tester, int index, String iso) async {
  tester.widget<TextFormField>(projectField(index)).controller!.text = iso;
  await tester.pump();
}

String projectFieldText(WidgetTester tester, int index) {
  return tester.widget<TextFormField>(projectField(index)).controller!.text;
}

/// Mengisi formulir proyek dengan data valid.
Future<void> fillProjectForm(WidgetTester tester) async {
  await enterField(tester, ProjectField.title, 'Aplikasi Mobile');
  await enterField(tester, ProjectField.role, 'Mobile developer');
  await enterField(tester, ProjectField.description, 'Portofolio Flutter');
  await enterField(tester, ProjectField.techStack, 'Flutter, Dart');
  await setDateField(tester, ProjectField.startDate, '2026-11-01');
}

Future<void> tapSaveProject(WidgetTester tester) async {
  // Pengguna menutup papan ketik dulu. Selama kolom teks masih fokus, Flutter
  // menggulirnya kembali ke tampilan sehingga tombol Save bisa terdorong keluar.
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Save'));
  await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
  await tester.pumpAndSettle();
}

/// Mengisi dan mengirim layar login yang sedang terbuka.
Future<void> submitLogin(
  WidgetTester tester, {
  String username = 'owner',
  String password = 'rahasia',
}) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.first, username);
  await tester.enterText(fields.last, password);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}

/// Membuka formulir proyek lewat kartu "Tambah Proyek". Menambah proyek butuh
/// login, jadi layar login muncul lebih dulu dan diisi di sini.
Future<void> openProjectFormWith(WidgetTester tester, ApiClient api) async {
  await pumpApp(tester, apiClient: api);
  await tester.tap(find.text('Tambah Proyek'));
  await tester.pumpAndSettle();
  await submitLogin(tester);
  // SnackBar dari kartu tampil 4 detik di dasar layar dan dapat menutupi tombol
  // Save. Pengguna sungguhan butuh lebih lama untuk mengisi form, jadi di sini
  // kita menunggu SnackBar hilang.
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}
