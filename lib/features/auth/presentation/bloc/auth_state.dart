import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:travis/features/auth/domain/entities/email.dart';
import 'package:travis/features/auth/domain/entities/password.dart';

class AuthState extends Equatable {
  final Email email;
  final String username;
  final Password password;
  final FormzSubmissionStatus submissionStatus;
  final String? token;
  final bool rememberMe;
  final bool allowBiometric;
  final bool loginSuccess;
  final String loginMessage;
  final bool popup;
  final bool pageLoaded;
  final String? usernameError;
  final String? passwordError;
  final bool firstLogin;

  const AuthState({
    this.email = const Email.pure(),
    this.username = '',
    this.password = const Password.pure(),
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.token,
    this.rememberMe = false,
    this.allowBiometric = false,
    this.loginSuccess = false,
    this.loginMessage = '',
    this.popup = false,
    this.pageLoaded = false,
    this.usernameError,
    this.passwordError,
    this.firstLogin = false,
  });

  bool get isValid => Formz.validate([email, password]);

  AuthState copyWith({
    Email? email,
    String? username,
    Password? password,
    FormzSubmissionStatus? submissionStatus,
    bool? isValid,
    String? errorMessage,
    String? token,
    bool? rememberMe,
    bool? allowBiometric,
    bool? loginSuccess,
    String? loginMessage,
    bool? popup,
    bool? pageLoaded,
    String? usernameError,
    String? passwordError,
    bool? firstLogin,
    bool clearErrors = false,
  }) {
    return AuthState(
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      token: token ?? this.token,
      rememberMe: rememberMe ?? this.rememberMe,
      allowBiometric: allowBiometric ?? this.allowBiometric,
      loginSuccess: loginSuccess ?? this.loginSuccess,
      loginMessage: loginMessage ?? this.loginMessage,
      popup: popup ?? this.popup,
      pageLoaded: pageLoaded ?? this.pageLoaded,
      usernameError: clearErrors ? null : (usernameError ?? this.usernameError),
      passwordError: clearErrors ? null : (passwordError ?? this.passwordError),
      firstLogin: firstLogin ?? this.firstLogin,
    );
  }

  @override
  List<Object?> get props => [
    email,
    username,
    password,
    submissionStatus,
    token,
    rememberMe,
    allowBiometric,
    loginSuccess,
    loginMessage,
    popup,
    pageLoaded,
    usernameError,
    passwordError,
    firstLogin,
  ];
}
