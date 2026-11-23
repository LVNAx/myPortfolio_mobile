/// Memformat tanggal menjadi `yyyy-MM-dd`, sama dengan DateField pada Django.
String formatIsoDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
