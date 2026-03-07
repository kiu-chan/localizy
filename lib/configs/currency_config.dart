import 'package:intl/intl.dart';

class CurrencyConfig {
  static const String fcfaSymbol = 'FCFA';

  static String format(double amount) {
    return NumberFormat.currency(
      locale: 'fr_FR',
      symbol: fcfaSymbol,
      decimalDigits: 0,
    ).format(amount);
  }
}
