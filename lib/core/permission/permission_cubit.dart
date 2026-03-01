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
    final notificationStatus = await Permission.notification.status;

    if (notificationStatus.isDenied) {
      final results = await [
        Permission.notification,
      ].request();

      final hasDenied = results.values.any((status) => status.isDenied);
      final hasPermanentlyDenied = results.values.any((status) => status.isPermanentlyDenied);

      if (hasPermanentlyDenied) {
        emit(PermissionStatusState.permanentlyDenied);
      } else if (hasDenied) {
        emit(PermissionStatusState.denied);
      } else {
        emit(PermissionStatusState.granted);
      }
    } else if (notificationStatus.isPermanentlyDenied) {
      emit(PermissionStatusState.permanentlyDenied);
    } else {
      emit(PermissionStatusState.granted);
    }
  }
}
