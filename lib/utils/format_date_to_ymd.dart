/// Convierte un [DateTime] al formato "YYYY-MM-DD"
String formatDateToYMD(DateTime date, {bool isThereSlashSpace = false}) {
  final year = date.year.toString();
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final isThereSlash = isThereSlashSpace ? "/" : "-";
  final space = isThereSlash;
  return "$year$space$month$space$day";
}
