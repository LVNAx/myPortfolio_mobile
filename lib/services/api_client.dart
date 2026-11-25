import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Exception thrown when an API request returns a non-2xx status code.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  /// Pesan ramah pengguna; body mentah bisa berisi halaman error HTML atau
  /// stack trace server saat DEBUG=True sehingga tidak ditampilkan langsung.
  String get userMessage {
    switch (statusCode) {
      case 400:
        return _validationMessage() ?? 'Data yang dikirim tidak valid.';
      case 401:
        return 'Sesi login berakhir. Silakan login ulang.';
      case 403:
        return 'Kamu tidak memiliki izin untuk melakukan tindakan ini.';
      case 404:
        return 'Data tidak ditemukan.';
      default:
        return statusCode >= 500
            ? 'Server sedang bermasalah. Coba lagi nanti.'
            : 'Permintaan gagal.';
    }
  }

  // DRF mengembalikan galat validasi berupa {"field": ["pesan", ...]}.
  String? _validationMessage() {
    try {
      final decoded = jsonDecode(message);
      if (decoded is! Map<String, dynamic>) return null;
      final messages = <String>[];
      for (final entry in decoded.entries) {
        final value = entry.value;
        final text = value is List ? value.join(' ') : value.toString();
        messages.add(
          entry.key == 'non_field_errors' ? text : '${entry.key}: $text',
        );
      }
      return messages.isEmpty ? null : messages.join('\n');
    } on FormatException {
      return null;
    }
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// HTTP client for the MyPortfolio Django REST Framework backend.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  /// Mengubah path relatif dari server (mis. `/static/img/a.png`) menjadi
  /// URL lengkap; URL yang sudah absolut dikembalikan apa adanya.
  String resolveUrl(String pathOrUrl) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return pathOrUrl;
    }
    return '$baseUrl$pathOrUrl';
  }

  Future<List<Project>> getProjects() async {
    final response = await _client.get(
      _uri('/api/v1/projects/'),
      headers: const {'Accept': 'application/json'},
    );
    _ensureSuccess(response);

    final decoded = _decodeJson(response) as List<dynamic>;
    return decoded
        .map((item) => Project.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/projects/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(project.toJson()),
    );
    _ensureSuccess(response);

    return Project.fromJson(_decodeJson(response) as Map<String, dynamic>);
  }

  Future<String> obtainToken(String username, String password) async {
    final response = await _client.post(
      _uri('/api/v1/auth/token/'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );
    _ensureSuccess(response);

    final decoded = _decodeJson(response) as Map<String, dynamic>;
    return decoded['token'] as String;
  }

  Future<void> logout({required String token}) async {
    final response = await _client.post(
      _uri('/api/v1/auth/logout/'),
      headers: {'Authorization': 'Token $token'},
    );
    _ensureSuccess(response);
  }

  // DRF mengirim application/json tanpa charset, sehingga response.body akan
  // dibaca sebagai Latin-1. Byte dibaca langsung sebagai UTF-8.
  dynamic _decodeJson(http.Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw ApiException(
      response.statusCode,
      utf8.decode(response.bodyBytes, allowMalformed: true),
    );
  }
}
