import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
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
        DioClient().setAuthToken(accessToken.toString());
        emit(state.copyWith(allowBiometric: allowBiometric));
      }

      if (hasSaved) {
        emit(
          state.copyWith(
            username: savedUsername ?? '',
            rememberMe: true,
            allowBiometric: allowBiometric,
          ),
        );

        if (kDebugMode) {
          emit(state.copyWith(password: Password.dirty(savedPassword!)));
        }
      }

      emit(state.copyWith(pageLoaded: true));
    });

    on<ResetState>((event, emit) {
      emit(state.copyWith(popup: false));
    });

    on<EmailChanged>((event, emit) {
      final email = Email.dirty(event.value);
      emit(state.copyWith(email: email));
    });

    on<UsernameChanged>((event, emit) {
      final username = event.value;
      print("AuthBloc UsernameChanged: $username");
      emit(
        state.copyWith(
          username: username,
          usernameError: '',
          clearErrors: false,
        ),
      );
    });

    on<PasswordChanged>((event, emit) {
      final password = Password.dirty(event.value);
      print("AuthBloc PasswordChanged: ${password.value}");
      emit(
        state.copyWith(
          password: password,
          passwordError: '',
          clearErrors: false,
        ),
      );
    });

    on<RememberMeToggled>((event, emit) {
      emit(state.copyWith(rememberMe: event.value));
    });

    on<AuthSubmitted>((event, emit) async {
      final username = state.username;
      final password = Password.dirty(state.password.value);

      final usernameErr = username.isEmpty
          ? 'Username tidak boleh kosong'
          : null;
      final passwordErr = password.value.isEmpty
          ? 'Password tidak boleh kosong'
          : null;

      print(
        "AuthBloc AuthSubmitted: username='$username', password='${password.value}', usernameErr=$usernameErr, passwordErr=$passwordErr",
      );

      if (usernameErr != null || passwordErr != null) {
        emit(
          state.copyWith(
            username: username,
            password: password,
            usernameError: usernameErr,
            passwordError: passwordErr,
          ),
        );
        return;
      }

      if (state.rememberMe) {
        secureStorageService.saveUsernameCred(state.username);
        secureStorageService.savePassCred(state.password.value);
      }

      emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        print("Error getting FCM token: $e");
      }

      final result = await authRepository.login(
        state.username,
        state.password.value,
        fcmToken ?? '',
      );

      result.match(
        (failure) {
          emit(
            state.copyWith(
              submissionStatus: FormzSubmissionStatus.failure,
              loginSuccess: false,
              loginMessage: "Login failed, try again later.",
              popup: true,
            ),
          );
        },
        (response) async {
          emit(
            state.copyWith(
              submissionStatus: response.isSuccess
                  ? FormzSubmissionStatus.success
                  : FormzSubmissionStatus.failure,
              loginSuccess: response.isSuccess,
              loginMessage: response.message,
              popup: true,
            ),
          );
        },
      );
    });

    on<BiometricSubmitted>((event, emit) async {
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

      emit(state.copyWith(submissionStatus: FormzSubmissionStatus.inProgress));

      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        print("Error getting FCM token: $e");
      }

      final result = await authRepository.login(
        state.username,
        state.password.value,
        fcmToken ?? '',
      );

      result.match(
        (failure) {
          emit(
            state.copyWith(
              submissionStatus: FormzSubmissionStatus.failure,
              loginSuccess: false,
              loginMessage: "Login failed, try again later.",
              popup: true,
            ),
          );
        },
        (response) async {
          emit(
            state.copyWith(
              submissionStatus: response.isSuccess
                  ? FormzSubmissionStatus.success
                  : FormzSubmissionStatus.failure,
              loginSuccess: response.isSuccess,
              loginMessage: response.message.toLowerCase() == 'login berhasil'
                  ? 'Welcome Back!'
                  : response.message,
              popup: true,
            ),
          );
        },
      );
    });
  }
}
