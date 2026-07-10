class LoginResponse {
  final bool isSuccess;
  final String message;
  final bool firstLogin;
  // final String refreshToken;

  const LoginResponse({
    required this.isSuccess,
    required this.message,
    this.firstLogin = false,
    // required this.refreshToken,
  });
}