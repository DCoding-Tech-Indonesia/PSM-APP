import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Izin Kamera Diperlukan"),
          content: const Text(
            "Aplikasi memerlukan izin untuk mengakses kamera. Silakan beri izin untuk melanjutkan.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

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
              child: Text(
                "Izinkan",
                style: TextStyle(color: theme.primaryColor),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Tutup",
                style: TextStyle(color: theme.disabledColor),
              ),
            ),
          ],
        );
      },
    );
  }
}