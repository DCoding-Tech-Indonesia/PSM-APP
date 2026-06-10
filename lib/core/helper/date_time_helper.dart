class DateTimeHelper {
  static String formatEEEDDMMYY(DateTime dateTime) {
    final List<String> namaHari = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    String hari = namaHari[dateTime.weekday];

    String tanggal = dateTime.day.toString().padLeft(2, '0');
    String bulan = dateTime.month.toString().padLeft(2, '0');

    String tahunDuaDigit = dateTime.year.toString().substring(2);

    return "$hari, $tanggal/$bulan '$tahunDuaDigit";
  }
}