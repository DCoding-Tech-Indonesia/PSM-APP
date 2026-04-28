import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:psm_mobile/features/auth/domain/entities/email.dart';
import 'package:psm_mobile/features/auth/domain/entities/password.dart';

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
  ];
}
