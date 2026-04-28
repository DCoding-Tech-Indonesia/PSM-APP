class LoginResponse {
  final bool isSuccess;
  final String message;
  // final String refreshToken;

  const LoginResponse({
    required this.isSuccess,
    required this.message,
    // required this.refreshToken,
  });
}