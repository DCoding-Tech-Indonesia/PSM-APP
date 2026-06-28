class ErrorParserHelper {
  static final RegExp _connectionRegex = RegExp(
    r'(connection error|connection refused|socketexception|network_error|timeout)',
    caseSensitive: false,
  );

  static final RegExp _serverRegex = RegExp(
    r'(500|internal server error|bad gateway|502|503|504)',
    caseSensitive: false,
  );

  static final RegExp _dioTechnicalRegex = RegExp(
    r'(dioexception|unexpected character|formatexception|type_error|is not a subtype of)',
    caseSensitive: false,
  );

  static String parse(String? errorMessage) {
    if (errorMessage == null || errorMessage.trim().isEmpty) {
      return "Terjadi kesalahan yang tidak diketahui. Silakan coba lagi.";
    }

    final lowerMessage = errorMessage.toLowerCase();

    if (_connectionRegex.hasMatch(lowerMessage)) {
      return "Koneksi internet terputus atau server tidak merespon. Pastikan internet Anda stabil dan coba lagi.";
    }

    if (_serverRegex.hasMatch(lowerMessage)) {
      return "Server kami sedang mengalami gangguan internal. Mohon tunggu beberapa saat.";
    }

    if (_dioTechnicalRegex.hasMatch(lowerMessage)) {
      return "Terjadi kegagalan sistem saat memproses data. Silakan hubungi admin jika kendala berlanjut.";
    }

    if (errorMessage.contains("Terjadi kesalahan:") && errorMessage.length > 30) {
      return "Terjadi kendala pada sistem. Silakan coba beberapa saat lagi.";
    }

    return errorMessage;
  }
}