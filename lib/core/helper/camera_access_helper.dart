import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travis/core/presentations/widgets/core_dialog_pop_up.dart';

class CameraAccessHelper {

  static Future<void> checkPermissions(
      BuildContext context, {
        VoidCallback? onGranted,
      }) async {
    PermissionStatus cameraStatus = await Permission.camera.status;

    if (cameraStatus.isGranted) {
      onGranted?.call();
    } else if (cameraStatus.isDenied || cameraStatus.isRestricted) {
      _showPermissionDialog(context, onGranted);
    } else if (cameraStatus.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  static void _showPermissionDialog(
      BuildContext context,
      VoidCallback? onGranted,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return CoreDialogPopUp(
          title: "Izin Kamera Diperlukan",
          description:
          "Aplikasi memerlukan izin untuk mengakses kamera. Silakan beri izin untuk melanjutkan.",
          confirmText: "Izinkan",
          cancelText: "Tutup",
          onConfirm: () async {
            PermissionStatus status = await Permission.camera.request();

            if (status.isGranted) {
              onGranted?.call();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Izin kamera ditolak."),
                ),
              );
            }
          },
        );
      },
    );
  }
}