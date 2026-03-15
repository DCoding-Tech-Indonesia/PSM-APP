import 'package:flutter/material.dart';

class CoreDialogPopUp extends StatelessWidget {
  const CoreDialogPopUp({
    super.key,
    required this.title,
    required this.description,
    this.confirmText = "OK",
    this.cancelText = "Batal",
    this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String description;
  final String confirmText;
  final String cancelText;

  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(title),
      content: Text(description),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
          child: Text(
            cancelText,
            style: TextStyle(color: theme.disabledColor),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          child: Text(
            confirmText,
            style: TextStyle(color: theme.primaryColor),
          ),
        ),
      ],
    );
  }
}