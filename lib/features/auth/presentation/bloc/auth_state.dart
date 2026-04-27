import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:psm_mobile/features/auth/domain/entities/email.dart';
import 'package:psm_mobile/features/auth/domain/entities/password.dart';

class AuthState extends Equatable{
  final Email email;
  final String username;
  final Password password;
  final FormzSubmissionStatus submissionStatus;
  final String? errorMessage;
  final String? token;
  final bool rememberMe;
  final bool allowBiometric;

  const AuthState({
    this.email = const Email.pure(),
    this.username = '',
    this.password = const Password.pure(),
    this.submissionStatus = FormzSubmissionStatus.initial,
    this.errorMessage,
    this.token,
    this.rememberMe = false,
    this.allowBiometric = false,
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
    bool? allowBiometric
  }) {
    return AuthState(
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      token: token ?? this.token,
      rememberMe: rememberMe ?? this.rememberMe,
        allowBiometric: allowBiometric  ?? this.allowBiometric
    );
  }

  @override
  List<Object?> get props => [email, username, password, submissionStatus, errorMessage, token, rememberMe, allowBiometric];
}