/// Kategori proyek, sama dengan pilihan `CATEGORY_CHOICES` pada model Django.
///
/// [name] adalah kode yang dikirim ke API (`web`, `data`, ...), sedangkan
/// [label] adalah teks yang ditampilkan kepada pengguna.
enum ProjectCategory {
  web('Web Development'),
  data('Data Science'),
  competition('Competition'),
  course('Course Project');

  const ProjectCategory(this.label);

  final String label;
}
