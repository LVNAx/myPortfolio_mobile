import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/utils/validators.dart';

void main() {
  group('validateRequiredText', () {
    test('menolak null, kosong, dan hanya spasi', () {
      expect(validateRequiredText(null, fieldName: 'Judul'), isNotNull);
      expect(validateRequiredText('', fieldName: 'Judul'), isNotNull);
      expect(validateRequiredText('    ', fieldName: 'Judul'), isNotNull);
    });

    test('pesan error menyebut nama field', () {
      expect(
        validateRequiredText('', fieldName: 'Nama Sertifikasi'),
        'Nama Sertifikasi tidak boleh kosong!',
      );
    });

    test('menolak tag HTML', () {
      expect(
        validateRequiredText('<script>alert(1)</script>', fieldName: 'Judul'),
        'Judul tidak boleh berisi tag HTML!',
      );
    });

    test('menolak teks lebih panjang dari batas', () {
      final tooLong = 'a' * 151;
      expect(
        validateRequiredText(tooLong, fieldName: 'Judul'),
        'Judul maksimal 150 karakter!',
      );
      expect(validateRequiredText('a' * 150, fieldName: 'Judul'), isNull);
    });

    test('menerima teks biasa', () {
      expect(
        validateRequiredText('Meta Backend Developer', fieldName: 'Judul'),
        isNull,
      );
    });
  });

  group('validateRequiredDate', () {
    test('menolak tanggal yang belum dipilih', () {
      expect(validateRequiredDate(null, fieldName: 'Tanggal'), isNotNull);
      expect(validateRequiredDate('  ', fieldName: 'Tanggal'), isNotNull);
    });

    test('menerima tanggal yang sudah dipilih', () {
      expect(validateRequiredDate('2026-11-23', fieldName: 'Tanggal'), isNull);
    });
  });

  group('validateOptionalUrl', () {
    test('kosong dianggap valid karena opsional', () {
      expect(validateOptionalUrl(null, fieldName: 'Tautan'), isNull);
      expect(validateOptionalUrl('   ', fieldName: 'Tautan'), isNull);
    });

    test('menerima URL http dan https', () {
      expect(
        validateOptionalUrl('https://coursera.org/verify/abc', fieldName: 'T'),
        isNull,
      );
      expect(validateOptionalUrl('http://example.com', fieldName: 'T'), isNull);
    });

    test('menolak URL tanpa skema, skema lain, atau mengandung spasi', () {
      expect(validateOptionalUrl('coursera.org', fieldName: 'T'), isNotNull);
      expect(
        validateOptionalUrl('ftp://example.com', fieldName: 'T'),
        isNotNull,
      );
      expect(validateOptionalUrl('https://', fieldName: 'T'), isNotNull);
      expect(
        validateOptionalUrl('https://exa mple.com', fieldName: 'T'),
        isNotNull,
      );
    });

    test('menolak URL lebih panjang dari 200 karakter', () {
      final longUrl = 'https://example.com/${'a' * 200}';
      expect(validateOptionalUrl(longUrl, fieldName: 'T'), isNotNull);
    });
  });
}
