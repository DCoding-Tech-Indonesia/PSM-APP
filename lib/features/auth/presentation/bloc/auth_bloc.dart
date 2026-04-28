import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/core/storage/shared_preferences.dart';
import 'package:psm_mobile/features/auth/domain/entities/email.dart';
import 'package:psm_mobile/features/auth/domain/entities/password.dart';
import 'package:psm_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:psm_mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:psm_mobile/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SecureStorageService secureStorageService;
  final SharedPreferencesService sharedPreferencesService;
  final AuthRepository authRepository;

  AuthBloc(
    this.secureStorageService,
    this.sharedPreferencesService,
    this.authRepository,
  ) : super(const AuthState()) {
    on<LoadSavedCredentials>((event, emit) async {
      final savedUsername = await secureStorageService.readUsernameCred();
      final savedPassword = await secureStorageService.readPassCred();
      final accessToken = await secureStorageService.readAccessToken();
      final refreshToken = await secureStorageService.readRefreshToken();
      final allowBiometric = sharedPreferencesService.getBiometric();

      final hasSaved =
          (savedUsername?.isNotEmpty ?? false) &&
              (savedPassword?.isNotEmpty ?? false);

      final hasToken =
          (refreshToken?.isNotEmpty ?? false) ||
              (accessToken?.isNotEmpty ?? false);

      if (hasToken) {
        emit(state.copyWith(loginSuccess: true));
        DioClient().setAuthToken(accessToken.toString());
      }

      if (hasSaved) {
        emit(
          state.copyWith(
            username: savedUsername ?? '',
            password: Password.dirty(savedPassword!),
            rememberMe: true,
            allowBiometric: allowBiometric,
          ),
        );
      }

      emit(state.copyWith(pageLoaded: true));
    });

    on<ResetState>((event, emit) {
      emit(
        state.copyWith(
          popup: false,
        )
      );
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

      final isValid = username.isNotEmpty && password.isValid;

      if (!isValid) {
        emit(
          state.copyWith(
            username: username,
            password: password,
            isValid: false,
          ),
        );
        return;
      }

      if (state.rememberMe) {
        secureStorageService.saveUsernameCred(state.username);
        secureStorageService.savePassCred(state.password.value);
      }

      final result = await authRepository.login(
        state.username,
        state.password.value,
      );

      result.match(
        (failure) {
          emit(
            state.copyWith(
              loginSuccess: false,
              loginMessage: "Login failed, try again later.",
              popup: true,
            ),
          );
        },
        (response) async {
          emit(
            state.copyWith(
              loginSuccess: response.isSuccess,
              loginMessage: response.message,
              popup: true,
            ),
          );
        },
      );
    });

    // on<AuthLogout>((event, emit) async {
    //   await authRepository.logout();
    //   emit(state.copyWith(
    //     loginSuccess: false,
    //     token: null,
    //   ));
    // });
  }
}
