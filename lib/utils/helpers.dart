import 'package:intl/intl.dart';

String formatPrice(double price) {
  if (price == price.truncateToDouble()) {
    return '${price.toInt()} دراهم';
  }
  return '${price.toStringAsFixed(2)} دراهم';
}

String formatPriceShort(double price) {
  if (price == price.truncateToDouble()) {
    return price.toInt().toString();
  }
  return price.toStringAsFixed(2);
}

String formatDate(String dateStr) {
  try {
    final dt = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy', 'ar').format(dt);
  } catch (_) {
    return dateStr;
  }
}

String formatDateArabic(String dateStr) {
  try {
    final dt = DateTime.parse(dateStr);
    const months = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  } catch (_) {
    return dateStr;
  }
}

String todayDateString() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4,'0')}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
}

String formatQuantity(double qty) {
  if (qty == qty.truncateToDouble()) return qty.toInt().toString();
  return qty.toStringAsFixed(2);
}
