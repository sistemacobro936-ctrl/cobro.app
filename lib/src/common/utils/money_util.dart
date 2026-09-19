import 'package:intl/intl.dart';

class MoneyUtil {
  MoneyUtil._();

  /// 120000 → $120.000
  static String format(num value) =>
      '\$${NumberFormat('#,##0', 'es_CO').format(value)}';
}
