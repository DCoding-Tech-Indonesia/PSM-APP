abstract class AuthEvent {}

class LoadSavedCredentials extends AuthEvent {}

class EmailChanged extends AuthEvent {
  final String value;
  EmailChanged(this.value);
}

class PasswordChanged extends AuthEvent {
  final String value;
  PasswordChanged(this.value);
}

class RememberMeToggled extends AuthEvent {
  final bool value;
  RememberMeToggled(this.value);
}

class AuthSubmitted extends AuthEvent {}