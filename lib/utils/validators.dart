// Fungsi validator untuk formulir. Dipisahkan dari widget agar logikanya
// mudah dipahami dan bisa diuji sendiri tanpa menampilkan layar.
//
// Setiap validator mengikuti kontrak `FormFieldValidator<String>`:
// mengembalikan pesan error (String) bila input ditolak, atau null bila valid.

// Pola tag HTML sederhana, mis. <script> atau <b>.
final RegExp _htmlTag = RegExp(r'<[^>]*>');

/// Validator untuk teks wajib.
///
/// Menolak isian kosong atau hanya berisi spasi, isian yang mengandung tag
/// HTML (sama seperti `clean_title` pada website Django), dan isian yang
/// melebihi [maxLength] karakter.
String? validateRequiredText(
  String? value, {
  required String fieldName,
  int maxLength = 150,
}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return '$fieldName tidak boleh kosong!';
  }
  if (_htmlTag.hasMatch(text)) {
    return '$fieldName tidak boleh berisi tag HTML!';
  }
  if (text.length > maxLength) {
    return '$fieldName maksimal $maxLength karakter!';
  }
  return null;
}

/// Validator untuk tanggal wajib. Nilai yang diperiksa adalah teks tanggal
/// yang ditampilkan pada kolom setelah pengguna memilihnya lewat date picker.
String? validateRequiredDate(String? value, {required String fieldName}) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName wajib dipilih!';
  }
  return null;
}

/// Validator untuk URL opsional.
///
/// Kolom boleh kosong. Jika diisi, harus berupa URL http/https yang valid
/// dan tidak lebih dari [maxLength] karakter (batas bawaan URLField Django).
String? validateOptionalUrl(
  String? value, {
  required String fieldName,
  int maxLength = 200,
}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return null;
  }
  if (text.length > maxLength) {
    return '$fieldName maksimal $maxLength karakter!';
  }
  final uri = Uri.tryParse(text);
  final isHttp = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  if (!isHttp || uri.host.isEmpty || text.contains(RegExp(r'\s'))) {
    return '$fieldName harus berupa URL yang valid (diawali http:// atau https://)!';
  }
  return null;
}
