import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

enum PermissionStatusState {
  granted,
  denied,
  permanentlyDenied,
  unknown,
}

class PermissionCubit extends Cubit<PermissionStatusState> {
  PermissionCubit() : super(PermissionStatusState.unknown);

  Future<void> checkAndRequestPermissions() async {
    // Tambahkan delay sedikit agar UI siap sebelum pop-up muncul
    await Future.delayed(const Duration(milliseconds: 500));

    final permissions = [
      Permission.notification,
      Permission.locationWhenInUse,
      Permission.camera,
    ];

    // Request permissions
    final results = await permissions.request();

    final hasDenied = results.values.any((status) => status.isDenied);
    final hasPermanentlyDenied = results.values.any((status) => status.isPermanentlyDenied);

    if (hasPermanentlyDenied) {
      emit(PermissionStatusState.permanentlyDenied);
    } else if (hasDenied) {
      emit(PermissionStatusState.denied);
    } else {
      emit(PermissionStatusState.granted);
    }
  }
}
