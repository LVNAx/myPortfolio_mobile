import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/certification.dart';
import 'package:myportofolio_mobile/utils/date_format.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/certification_scope.dart';
import 'package:myportofolio_mobile/widgets/certification_summary_dialog.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Formulir tambah sertifikasi; kolomnya mengikuti model `Certification` pada
/// website Django. Data yang valid disimpan ke [CertificationStore].
///
/// Berupa StatefulWidget karena menyimpan isian, kategori, dan tanggal terpilih.
class CertificationFormPage extends StatefulWidget {
  const CertificationFormPage({super.key});

  @override
  State<CertificationFormPage> createState() => _CertificationFormPageState();
}

class _CertificationFormPageState extends State<CertificationFormPage> {
  static const _defaultCategory = CertificationCategory.swe;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _issuerController = TextEditingController();
  final _dateController = TextEditingController();
  final _urlController = TextEditingController();

  CertificationCategory _category = _defaultCategory;
  DateTime? _issuedAt;

  @override
  void dispose() {
    _titleController.dispose();
    _issuerController.dispose();
    _dateController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    // lastDate hari ini: sertifikat tidak mungkin terbit di masa depan.
    final picked = await showDatePicker(
      context: context,
      initialDate: _issuedAt ?? now,
      firstDate: DateTime(1990),
      lastDate: now,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _issuedAt = picked;
      _dateController.text = formatIsoDate(picked);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final url = _urlController.text.trim();
    final certification = Certification(
      title: _titleController.text.trim(),
      issuer: _issuerController.text.trim(),
      category: _category,
      issuedAt: _issuedAt!,
      credentialUrl: url.isEmpty ? null : url,
    );
    final store = CertificationScope.read(context);
    store.add(certification);

    await showDialog<void>(
      context: context,
      builder: (_) => CertificationSummaryDialog(certification: certification),
    );
    if (!mounted) return;

    _resetForm();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Sertifikasi disimpan.'),
          // Tanpa persist: false, SnackBar ber-action tidak hilang sendiri
          // dan akan menutupi tombol di bawah layar.
          persist: false,
          action: SnackBarAction(
            label: 'Batalkan',
            onPressed: () => store.remove(certification),
          ),
        ),
      );
  }

  // reset() hanya mengosongkan kolom teks; kategori dan tanggal disimpan di
  // variabel state sehingga dikembalikan secara manual.
  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _category = _defaultCategory;
      _issuedAt = null;
    });
  }

  InputDecoration _decoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  Widget _requiredTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String fieldName,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: _decoration(label, hint, icon),
      validator: (value) => validateRequiredText(value, fieldName: fieldName),
    );
  }

  Widget _categoryField() {
    return DropdownButtonFormField<CertificationCategory>(
      // isExpanded mencegah overflow saat label kategori panjang.
      isExpanded: true,
      initialValue: _defaultCategory,
      decoration: _decoration('Kategori', '', Icons.category_outlined),
      items: [
        for (final category in CertificationCategory.values)
          DropdownMenuItem(value: category, child: Text(category.label)),
      ],
      onChanged: (value) {
        setState(() => _category = value ?? _defaultCategory);
      },
    );
  }

  Widget _dateField() {
    return TextFormField(
      controller: _dateController,
      // Tanggal dipilih lewat date picker, bukan diketik.
      readOnly: true,
      onTap: _pickDate,
      decoration: _decoration(
        'Tanggal Terbit',
        'Pilih tanggal',
        Icons.event_outlined,
      ),
      validator: (value) =>
          validateRequiredDate(value, fieldName: 'Tanggal terbit'),
    );
  }

  Widget _urlField() {
    return TextFormField(
      controller: _urlController,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.done,
      decoration: _decoration(
        'Bukti Sertifikasi (opsional)',
        'https://coursera.org/verify/...',
        Icons.link,
      ),
      validator: (value) =>
          validateOptionalUrl(value, fieldName: 'Bukti sertifikasi'),
    );
  }

  Widget _buttons(ColorScheme colorScheme) {
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _resetForm,
            child: const Text('Reset'),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(colorScheme.primary),
            ),
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
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
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        // Error muncul setelah kolom disentuh dan hilang saat isian diperbaiki.
        autovalidateMode: AutovalidateMode.onUserInteraction,
        // Scroll menjaga semua kolom dan tombol terjangkau di layar sempit
        // atau saat papan ketik tampil.
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    _requiredTextField(
                      controller: _titleController,
                      label: 'Nama Sertifikasi',
                      hint: 'Meta Backend Developer',
                      icon: Icons.workspace_premium_outlined,
                      fieldName: 'Nama sertifikasi',
                    ),
                    _requiredTextField(
                      controller: _issuerController,
                      label: 'Nama Penerbit',
                      hint: 'Coursera',
                      icon: Icons.business_outlined,
                      fieldName: 'Nama penerbit',
                    ),
                    _categoryField(),
                    _dateField(),
                    _urlField(),
                    const SizedBox(height: 8),
                    _buttons(colorScheme),
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
