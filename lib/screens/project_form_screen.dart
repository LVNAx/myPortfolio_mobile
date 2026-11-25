import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/models/project_category.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/date_picker_field.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Formulir tambah proyek yang dikirim ke backend Django lewat `POST`.
///
/// Kolomnya mengikuti `ProjectSerializer`. Mengirim data membutuhkan login,
/// sehingga [ensureLoggedIn] dipanggil lebih dulu saat tombol Save ditekan.
class ProjectFormScreen extends StatefulWidget {
  const ProjectFormScreen({super.key});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  static const _defaultCategory = ProjectCategory.web;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _roleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _techStackController = TextEditingController();
  final _liveUrlController = TextEditingController();
  final _githubUrlController = TextEditingController();
  final _startedController = TextEditingController();
  final _endedController = TextEditingController();

  ProjectCategory _category = _defaultCategory;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _roleController.dispose();
    _descriptionController.dispose();
    _techStackController.dispose();
    _liveUrlController.dispose();
    _githubUrlController.dispose();
    _startedController.dispose();
    _endedController.dispose();
    super.dispose();
  }

  Project _buildProject() {
    final ended = _endedController.text.trim();
    return Project(
      title: _titleController.text.trim(),
      role: _roleController.text.trim(),
      category: _category.name,
      description: _descriptionController.text.trim(),
      techStack: _techStackController.text.trim(),
      liveUrl: _liveUrlController.text.trim(),
      githubUrl: _githubUrlController.text.trim(),
      startedAt: _startedController.text.trim(),
      endedAt: ended.isEmpty ? null : ended,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Objek yang dibutuhkan setelah await diambil sekarang, selagi context
    // masih valid.
    final auth = context.read<AuthState>();

    if (!await ensureLoggedIn(context)) return;
    if (!mounted) return;
    final token = auth.token;
    if (token == null) return;

    final created = await _createProject(token);
    if (created == null || !mounted) return;

    await _showCreatedDialog(created);
    if (!mounted) return;
    _resetForm();
  }

  // Mengirim proyek dan mengembalikan hasilnya, atau null bila gagal (galat
  // sudah ditampilkan). Status mengirim berakhir sebelum dialog sukses muncul,
  // sehingga spinner tidak ikut berputar di belakang dialog.
  Future<Project?> _createProject(String token) async {
    final apiClient = context.read<ApiClient>();
    final auth = context.read<AuthState>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isSubmitting = true;
    });

    try {
      return await apiClient.createProject(_buildProject(), token: token);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        // Token ditolak server: sesi lokal diakhiri lalu pengguna diminta
        // login ulang. Tekan Save lagi setelah berhasil masuk.
        await auth.logout();
        _showMessage(messenger, 'Session expired. Please log in again.');
        if (mounted) await ensureLoggedIn(context);
      } else {
        _showMessage(messenger, 'Failed (${e.statusCode}): ${e.userMessage}');
      }
    } on http.ClientException {
      _showMessage(
        messenger,
        'Cannot reach the server. Check your connection.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
    return null;
  }

  void _showMessage(ScaffoldMessengerState messenger, String message) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // Ringkasan memakai data dari respons server (201 Created), bukan isian
  // lokal, karena server dapat membersihkan teks (mis. membuang tag HTML).
  Future<void> _showCreatedDialog(Project created) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama Proyek: ${created.title}'),
                Text('Peran: ${created.role}'),
                Text('Kategori: ${_labelOf(created.category)}'),
                Text('Teknologi: ${created.techStack}'),
                Text('Mulai: ${created.startedAt}'),
                Text('Selesai: ${created.endedAt ?? 'Masih berjalan'}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  String _labelOf(String code) {
    return ProjectCategory.values
        .firstWhere(
          (category) => category.name == code,
          orElse: () => _defaultCategory,
        )
        .label;
  }

  // reset() hanya mengosongkan kolom teks; kategori disimpan di variabel state
  // sehingga dikembalikan secara manual.
  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _category = _defaultCategory;
    });
  }

  InputDecoration _decoration(String label, {String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String fieldName,
    required IconData icon,
    String? hint,
    int maxLength = 150,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: maxLines == 1
          ? TextInputAction.next
          : TextInputAction.newline,
      decoration: _decoration(label, hint: hint, icon: icon),
      validator: (value) => validateRequiredText(
        value,
        fieldName: fieldName,
        maxLength: maxLength,
      ),
    );
  }

  Widget _urlField({
    required TextEditingController controller,
    required String label,
    required String fieldName,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.next,
      decoration: _decoration(label, hint: hint, icon: Icons.link),
      validator: (value) => validateOptionalUrl(value, fieldName: fieldName),
    );
  }

  Widget _categoryField() {
    return DropdownButtonFormField<ProjectCategory>(
      isExpanded: true,
      initialValue: _defaultCategory,
      decoration: _decoration('Kategori Proyek', icon: Icons.category_outlined),
      items: [
        for (final category in ProjectCategory.values)
          DropdownMenuItem(value: category, child: Text(category.label)),
      ],
      onChanged: (value) {
        setState(() => _category = value ?? _defaultCategory);
      },
    );
  }

  Widget _saveButton(ColorScheme colorScheme) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      onPressed: _isSubmitting ? null : _submit,
      child: _isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Save'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Project Form',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    _textField(
                      controller: _titleController,
                      label: 'Nama Proyek',
                      fieldName: 'Nama proyek',
                      icon: Icons.title,
                      maxLength: 120,
                    ),
                    _textField(
                      controller: _roleController,
                      label: 'Peran',
                      fieldName: 'Peran',
                      icon: Icons.badge_outlined,
                      hint: 'Contoh: Full-stack developer',
                      maxLength: 120,
                    ),
                    _categoryField(),
                    _textField(
                      controller: _descriptionController,
                      label: 'Deskripsi Proyek',
                      fieldName: 'Deskripsi proyek',
                      icon: Icons.notes,
                      maxLength: 2000,
                      maxLines: 5,
                    ),
                    _textField(
                      controller: _techStackController,
                      label: 'Teknologi yang Digunakan',
                      fieldName: 'Teknologi',
                      icon: Icons.code,
                      hint: 'Contoh: Flutter, Django, Figma',
                      maxLength: 200,
                    ),
                    _urlField(
                      controller: _liveUrlController,
                      label: 'Tautan Live (opsional)',
                      fieldName: 'Tautan live',
                      hint: 'https://contoh.com',
                    ),
                    _urlField(
                      controller: _githubUrlController,
                      label: 'Tautan GitHub (opsional)',
                      fieldName: 'Tautan GitHub',
                      hint: 'https://github.com/username/repo',
                    ),
                    DatePickerField(
                      controller: _startedController,
                      label: 'Tanggal Mulai',
                      validator: (value) => validateRequiredDate(
                        value,
                        fieldName: 'Tanggal mulai',
                      ),
                    ),
                    DatePickerField(
                      controller: _endedController,
                      label: 'Tanggal Selesai (opsional)',
                      clearable: true,
                      validator: (value) =>
                          validateEndDate(value, _startedController.text),
                    ),
                    const SizedBox(height: 8),
                    _saveButton(colorScheme),
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
