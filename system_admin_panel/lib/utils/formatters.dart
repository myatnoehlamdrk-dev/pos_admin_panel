import 'package:intl/intl.dart';

class Formatters {
  static String currency(int amount) {
    if (amount < 0) return '-${currency(-amount)}';
    final digits = amount.toString().length;
    if (digits > 5) {
      final truncated = amount.toString().substring(0, 5);
      return '$truncated...';
    }
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(amount);
  }

  static String number(int number) {
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(number);
  }

  static String date(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '-';
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return isoString;
    }
  }

  static String dateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '-';
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('MMM d, yyyy HH:mm').format(date);
    } catch (_) {
      return isoString;
    }
  }
}
