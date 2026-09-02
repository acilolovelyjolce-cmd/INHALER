import 'package:intl/intl.dart';

abstract final class Formatters {
  static final money = NumberFormat.currency(symbol: '₱', decimalDigits: 0);
  static final moneyExact = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
  static final day = DateFormat('MMM d');
  static final dayTime = DateFormat('MMM d · h:mm a');
  static final weekday = DateFormat('EEEE, MMM d');
  static final monthYear = DateFormat('MMMM y');

  static String php(double value) {
    if (value == value.roundToDouble()) return money.format(value);
    return moneyExact.format(value);
  }

  static String span(DateTime start, DateTime endExclusive) {
    final last = endExclusive.subtract(const Duration(milliseconds: 1));
    final a = DateTime(start.year, start.month, start.day);
    final b = DateTime(last.year, last.month, last.day);
    if (a == b) return weekday.format(a);
    if (a.year == b.year) {
      return '${day.format(a)} – ${day.format(b)}';
    }
    return '${DateFormat('MMM d, y').format(a)} – ${DateFormat('MMM d, y').format(b)}';
  }
}
