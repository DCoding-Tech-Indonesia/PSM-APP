import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/features/auth/domain/entities/email.dart';
import 'package:psm_mobile/features/auth/domain/entities/password.dart';
import 'package:psm_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:psm_mobile/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {

    on<EmailChanged>((event, emit) {
      final email = Email.dirty(event.value);
      emit(state.copyWith(email: email));
    });

    on<PasswordChanged>((event, emit) {
      final password = Password.dirty(event.value);
      emit(state.copyWith(password: password));
    });

    on<RememberMeToggled>((event, emit) {
      emit(state.copyWith(rememberMe: event.value));
    });

    on<AuthSubmitted>((event, emit) async {
      final email = Email.dirty(state.email.value);
      final password = Password.dirty(state.password.value);

      final emailValidation = email.validator(state.email.value);
      final passwordValidation = password.validator(state.password.value);

      final isValid = emailValidation == null && passwordValidation == null;

      if (!isValid) {
        emit(state.copyWith(email: email, password: password, isValid: false));
        return;
      }

      // Auth logic below
    });

  }
}