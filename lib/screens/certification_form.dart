import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

// Halaman formulir untuk menambah sertifikasi.
// Kolom-kolomnya mengikuti model Certification pada website Django:
// title, issuer, category, issued_at, dan credential_url.
//
// StatefulWidget dipakai karena halaman ini menyimpan data yang berubah
// (isian pengguna, kategori, dan tanggal terpilih).
class CertificationFormPage extends StatefulWidget {
  const CertificationFormPage({super.key});

  @override
  State<CertificationFormPage> createState() => _CertificationFormPageState();
}

class _CertificationFormPageState extends State<CertificationFormPage> {
  // Kunci untuk mengakses FormState (validate() dan reset()).
  final _formKey = GlobalKey<FormState>();

  // Controller membaca dan mengubah teks pada kolom.
  final _titleController = TextEditingController();
  final _issuerController = TextEditingController();
  final _dateController = TextEditingController();
  final _urlController = TextEditingController();

  // Pilihan kategori sama dengan model Certification (kode -> label).
  static const Map<String, String> _categories = {
    'swe': 'Software Engineering',
    'sde': 'Software Development',
    'dsai': 'Data Science and AI',
    'cybersec': 'Cyber Security',
  };
  static const String _defaultCategory = 'swe';

  String _category = _defaultCategory;
  DateTime? _issuedAt;

  @override
  void dispose() {
    // Controller harus dibuang agar tidak terjadi kebocoran memori.
    _titleController.dispose();
    _issuerController.dispose();
    _dateController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  // Format tanggal yyyy-MM-dd, sama dengan format DateField pada Django.
  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  // Membuka date picker. lastDate dibatasi hari ini karena sertifikat
  // tidak mungkin diterbitkan di masa depan.
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _issuedAt ?? now,
      firstDate: DateTime(1990),
      lastDate: now,
    );
    // Setelah await, widget mungkin sudah dibuang; cek mounted dulu.
    if (picked == null || !mounted) return;
    setState(() {
      _issuedAt = picked;
      _dateController.text = _formatDate(picked);
    });
  }

  // Dekorasi yang sama untuk semua kolom agar tampilan konsisten.
  InputDecoration _decoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  // Dipanggil saat tombol Simpan ditekan.
  void _save() {
    // validate() menjalankan semua validator; false bila ada yang menolak.
    if (!_formKey.currentState!.validate()) return;

    // Isian disalin dulu karena form akan dikosongkan setelah dialog ditutup.
    final title = _titleController.text.trim();
    final issuer = _issuerController.text.trim();
    final category = _categories[_category]!;
    final issuedAt = _dateController.text;
    final url = _urlController.text.trim();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sertifikasi berhasil ditambahkan!'),
          // Ringkasan seluruh isian formulir.
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama Sertifikasi: $title'),
                Text('Penerbit: $issuer'),
                Text('Kategori: $category'),
                Text('Tanggal Terbit: $issuedAt'),
                Text('Bukti Sertifikasi: ${url.isEmpty ? '-' : url}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Menutup dialog, lalu mengosongkan formulir.
                Navigator.pop(context);
                _resetForm();
              },
            ),
          ],
        );
      },
    );
  }

  // reset() mengosongkan kolom teks; kategori dan tanggal yang disimpan
  // di variabel state dikembalikan secara manual.
  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _category = _defaultCategory;
      _issuedAt = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Certification Form',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // Warna tema yang sama dengan halaman utama.
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      // Drawer yang sama dengan halaman lain agar navigasi tetap tersedia.
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        // Pesan error muncul setelah pengguna menyentuh kolom dan hilang
        // otomatis begitu isiannya diperbaiki.
        autovalidateMode: AutovalidateMode.onUserInteraction,
        // SingleChildScrollView menjaga semua kolom dan tombol Simpan tetap
        // terjangkau di layar sempit atau saat papan ketik tampil.
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            // Membatasi lebar form di layar lebar (misalnya Chrome).
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // === Nama Sertifikasi ===
                    TextFormField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        'Nama Sertifikasi',
                        'Meta Backend Developer',
                        Icons.workspace_premium_outlined,
                      ),
                      validator: (value) => validateRequiredText(
                        value,
                        fieldName: 'Nama sertifikasi',
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // === Penerbit ===
                    TextFormField(
                      controller: _issuerController,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        'Nama Penerbit',
                        'Coursera',
                        Icons.business_outlined,
                      ),
                      validator: (value) => validateRequiredText(
                        value,
                        fieldName: 'Nama penerbit',
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // === Kategori (pilihan tetap -> dropdown) ===
                    DropdownButtonFormField<String>(
                      // isExpanded mencegah overflow saat label kategori panjang.
                      isExpanded: true,
                      initialValue: _defaultCategory,
                      decoration: _decoration(
                        'Kategori',
                        '',
                        Icons.category_outlined,
                      ),
                      items: _categories.entries
                          .map(
                            (entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _category = newValue ?? _defaultCategory;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // === Tanggal Terbit (tanggal -> date picker) ===
                    TextFormField(
                      controller: _dateController,
                      // readOnly: teks tidak diketik, tanggal dipilih lewat picker.
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: _decoration(
                        'Tanggal Terbit',
                        'Pilih tanggal',
                        Icons.event_outlined,
                      ),
                      validator: (value) => validateRequiredDate(
                        value,
                        fieldName: 'Tanggal terbit',
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // === Bukti Sertifikasi (URL opsional) ===
                    TextFormField(
                      controller: _urlController,
                      // Papan ketik khusus URL.
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      decoration: _decoration(
                        'Bukti Sertifikasi (opsional)',
                        'https://coursera.org/verify/...',
                        Icons.link,
                      ),
                      validator: (value) => validateOptionalUrl(
                        value,
                        fieldName: 'Bukti sertifikasi',
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // === Tombol Simpan ===
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          colorScheme.primary,
                        ),
                      ),
                      onPressed: _save,
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
