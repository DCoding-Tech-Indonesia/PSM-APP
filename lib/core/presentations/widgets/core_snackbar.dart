import 'package:flutter/material.dart';

enum SnackbarType { success, failed, warning }

class CoreSnackbar {
  static void show(
      BuildContext context, {
        required String message,
        required SnackbarType type,
      }) {
    Color backgroundColor;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = Colors.green;
        break;
      case SnackbarType.failed:
        backgroundColor = Colors.red;
        break;
      case SnackbarType.warning:
        backgroundColor = Colors.orange;
        break;
    }

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        showCloseIcon: true,
        closeIconColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        content: Text(message),
      ),
    );
  }
}