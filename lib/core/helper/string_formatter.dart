import 'package:intl/intl.dart';

class StringFormatter {
  String idrFormatter(int total) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return formatCurrency.format(total);
  }
}