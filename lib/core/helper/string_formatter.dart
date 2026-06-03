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

  String formatDateTime(String value) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final dateTime = DateTime.parse(value);

    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month ($hour:$minute)';
  }

  String formatHourMinute(String value) {
    return DateFormat('HH:mm').format(DateTime.parse(value));
  }

}