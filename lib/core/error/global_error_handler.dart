import 'package:flutter/foundation.dart';

class GlobalErrorHandler {
  static final GlobalErrorHandler _instance = GlobalErrorHandler._internal();

  factory GlobalErrorHandler() {
    return _instance;
  }

  GlobalErrorHandler._internal();

  final ValueNotifier<ServerError?> serverErrorNotifier =
      ValueNotifier<ServerError?>(null);

  void handleServerError(int statusCode, String? message) {
    final error = ServerError(
      statusCode: statusCode,
      message: message ?? 'Server error occurred',
    );
    serverErrorNotifier.value = error;
    if (kDebugMode) {
      debugPrint('[GLOBAL ERROR HANDLER] Server error: $statusCode - $message');
    }
  }

  void clearError() {
    serverErrorNotifier.value = null;
  }
}

class ServerError {
  final int statusCode;
  final String message;

  ServerError({
    required this.statusCode,
    required this.message,
  });
}
