import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/utils/date_format.dart';

/// Kolom tanggal yang dipilih lewat date picker (tidak bisa diketik).
///
/// Tanggal disimpan sebagai teks `yyyy-MM-dd` di [controller]. Bila
/// [clearable] true, muncul tombol untuk mengosongkan tanggal opsional.
class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.clearable = false,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final bool clearable;

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = formatIsoDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mendengarkan controller agar tombol hapus muncul dan hilang sesuai isi.
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _pick(context),
          decoration: InputDecoration(
            labelText: label,
            hintText: 'Pilih tanggal',
            prefixIcon: const Icon(Icons.event_outlined),
            suffixIcon: clearable && value.text.isNotEmpty
                ? IconButton(
                    tooltip: 'Hapus tanggal',
                    icon: const Icon(Icons.clear),
                    onPressed: controller.clear,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          validator: validator,
        );
      },
    );
  }
}
