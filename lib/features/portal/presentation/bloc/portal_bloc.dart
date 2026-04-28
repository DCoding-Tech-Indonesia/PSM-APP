import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:psm_mobile/features/portal/domain/repositories/portal_repository.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_event.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_state.dart';

class PortalBloc extends Bloc<PortalEvent, PortalState> {
  final AuthRepository authRepository;
  final SecureStorageService secureStorageService;
  final PortalRepository portalRepository;

  PortalBloc(this.authRepository, this.secureStorageService, this.portalRepository)
      : super(const PortalState()) {
    on<PageLoad>((event, emit) async {
      emit(PortalLoading());

      final userId = await secureStorageService.readUserId();
      final username = await secureStorageService.readUsername();
      final token = await secureStorageService.readAccessToken();

      if (token != null) {
        DioClient().setAuthToken(token.toString());
      }

      final result = await portalRepository.getProfile();

      result.match(
        (failure) {
          emit(PortalError(message: failure.message));
        },
        (profile) {
          emit(PortalLoaded(profile: profile));
        },
      );
    });

    on<Logout>((event, emit) async {
      print("INI");
      
      final userId = await secureStorageService.readUserId() ?? state.userId;
      final username = await secureStorageService.readUsername() ?? state.username;
      
      final result = await authRepository.logout(userId, username);

      result.match(
            (failure) {
          state.copyWith(logoutSuccess: false);
        },
            (response) {
          emit(state.copyWith(logoutSuccess: true));
        },
      );
    });
  }
}