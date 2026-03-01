import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:psm_mobile/features/auth/domain/entities/email.dart';
import 'package:psm_mobile/features/auth/domain/entities/password.dart';

class AuthState extends Equatable{
  final Email email;
  final Password password;
  final String? errorMessage;
  final String? token;
  final bool rememberMe;

  const AuthState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.errorMessage,
    this.token,
    this.rememberMe = false,
  });

  bool get isValid => Formz.validate([email, password]);

  AuthState copyWith({
    Email? email,
    Password? password,
    bool? isValid,
    String? errorMessage,
    String? token,
    bool? rememberMe,
  }) {
    return AuthState(
      email: email ?? this.email,
      password: password ?? this.password,
      errorMessage: errorMessage ?? this.errorMessage,
      token: token ?? this.token,
      rememberMe: rememberMe ?? this.rememberMe
    );
  }

  @override
  List<Object?> get props => [email, password, errorMessage, token, rememberMe];
}