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
      final savedUsername = await secureStorageService.readUsernameCred();
      final savedPassword = await secureStorageService.readPassCred();
      final refreshToken = await secureStorageService.readRefreshToken();
      final allowBiometric = sharedPreferencesService.getBiometric();

      final hasSaved =
          (savedUsername?.isNotEmpty ?? false) ||
              (savedPassword?.isNotEmpty ?? false);

      if (hasSaved) {
        emit(
          state.copyWith(
            username: savedUsername,
            password: savedPassword != null ? Password.dirty(savedPassword) : null,
            rememberMe: true,
          ),
        );
      }

      if (refreshToken!.isNotEmpty && allowBiometric) emit (state.copyWith(allowBiometric: true));
    });

    on<EmailChanged>((event, emit) {
      final email = Email.dirty(event.value);
      emit(state.copyWith(email: email));
    });

    on<UsernameChanged>((event, emit) {
      final username = event.value;
      emit(state.copyWith(username: username));
    });

    on<PasswordChanged>((event, emit) {
      final password = Password.dirty(event.value);
      emit(state.copyWith(password: password));
    });

    on<RememberMeToggled>((event, emit) {
      emit(state.copyWith(rememberMe: event.value));
    });

    on<AuthSubmitted>((event, emit) async {
      final username = state.username;
      final password = Password.dirty(state.password.value);

      final passwordValidation = password.validator(state.password.value);

      final isValid = passwordValidation == null;

      if (!isValid) {
        emit(state.copyWith(username: username, password: password, isValid: false));
        return;
      }

      // Auth logic below
      if(state.rememberMe) {
        secureStorageService.saveUsernameCred(state.username);
        secureStorageService.savePassCred(state.password.value);
      }


    });

  }
}