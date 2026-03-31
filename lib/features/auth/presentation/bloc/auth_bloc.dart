import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/core/storage/shared_preferences.dart';
import 'package:psm_mobile/features/auth/domain/entities/email.dart';
import 'package:psm_mobile/features/auth/domain/entities/password.dart';
import 'package:psm_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:psm_mobile/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SecureStorageService secureStorageService;
  final SharedPreferencesService sharedPreferencesService;

  AuthBloc(this.secureStorageService, this.sharedPreferencesService) : super(const AuthState()) {

    on<LoadSavedCredentials>((event, emit) async {
      final savedEmail = await secureStorageService.readEmailCred();
      final savedPassword = await secureStorageService.readPassCred();
      final allowBiometric = sharedPreferencesService.getBiometric();

      final hasSaved =
          (savedEmail?.isNotEmpty ?? false) ||
              (savedPassword?.isNotEmpty ?? false);

      if (hasSaved) {
        emit(
          state.copyWith(
            email: savedEmail != null ? Email.dirty(savedEmail) : null,
            password: savedPassword != null ? Password.dirty(savedPassword) : null,
            rememberMe: true,
          ),
        );

        if(allowBiometric) emit(state.copyWith(allowBiometric: true));
      }
    });

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
      if(state.rememberMe) {
        secureStorageService.saveEmailCred(state.email.value);
        secureStorageService.savePassCred(state.password.value);
      }


    });

  }
}