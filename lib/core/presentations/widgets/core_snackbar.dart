import 'package:flutter/material.dart';

enum SnackbarType { success, failed, warning }

class CoreSnackbar {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required String message,
    required SnackbarType type,
  }) {
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = const Color(0xFF2E7D32); // Green
        icon = Icons.check_circle_outline_rounded;
        break;
      case SnackbarType.failed:
        backgroundColor = const Color(0xFFC62828); // Red
        icon = Icons.error_outline_rounded;
        break;
      case SnackbarType.warning:
        backgroundColor = const Color(0xFFEF6C00); // Orange
        icon = Icons.warning_amber_rounded;
        break;
    }

    // Dismiss existing snackbar immediately to prevent spam stacking
    if (_currentEntry != null) {
      try {
        _currentEntry!.remove();
      } catch (_) {}
      _currentEntry = null;
    }

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.horizontal,
              onDismissed: (_) {
                if (_currentEntry == overlayEntry) {
                  _currentEntry = null;
                }
                overlayEntry.remove();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: backgroundColor.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(30), // Bubble shape
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    _currentEntry = overlayEntry;
    overlay.insert(overlayEntry);

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (_currentEntry == overlayEntry) {
        try {
          overlayEntry.remove();
          _currentEntry = null;
        } catch (_) {}
      }
    });
  }
}