abstract class AuthEvent {}

class LoadSavedCredentials extends AuthEvent {}

class ResetState extends AuthEvent {}

class EmailChanged extends AuthEvent {
  final String value;
  EmailChanged(this.value);
}

class UsernameChanged extends AuthEvent {
  final String value;
  UsernameChanged(this.value);
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

class AuthLogout extends AuthEvent {}