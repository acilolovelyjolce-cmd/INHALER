import 'package:intl/intl.dart';

abstract final class Formatters {
  static final money = NumberFormat.currency(symbol: '₱', decimalDigits: 0);
  static final moneyExact = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
  static final day = DateFormat('MMM d');
  static final dayTime = DateFormat('MMM d · h:mm a');

  static String php(double value) {
    if (value == value.roundToDouble()) return money.format(value);
    return moneyExact.format(value);
  }
}
