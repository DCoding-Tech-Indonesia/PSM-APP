import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class CoreBlurDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Color badgeColor;
  final String badgeText;
  final IconData badgeIcon;
  final Color buttonColor;
  final String? confirmText;
  final VoidCallback? onConfirm;
  final Widget? contentWidget;

  const CoreBlurDialog({
    super.key,
    required this.title,
    this.message,
    required this.badgeColor,
    required this.badgeText,
    required this.badgeIcon,
    required this.buttonColor,
    this.confirmText,
    this.onConfirm,
    this.contentWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardTheme.color?.withValues(alpha: 0.8) ?? Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [badgeColor, badgeColor.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      badgeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Title Section
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message Section
              if (message != null && message!.isNotEmpty) ...[
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Content Widget
              if (contentWidget != null) ...[
                contentWidget!,
                const SizedBox(height: 24),
              ],

              // Divider
              Container(
                height: 1,
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              if (onConfirm != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
                        ),
                        child: Text('Batal', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [buttonColor, buttonColor.withValues(alpha: 0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: buttonColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.pop(context);
                              onConfirm!();
                            },
                            child: Center(
                              child: Text(
                                confirmText ?? 'Ya',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Single Button (Info/Error/Success)
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[600]!, Colors.blue[400]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.pop(context),
                      child: const Center(
                        child: Text(
                          'Mengerti',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

void showCoreErrorDialog(BuildContext context, String title, String message, {Widget? contentWidget}) {
  showDialog(
    context: context,
    builder: (context) => CoreBlurDialog(
      title: title,
      message: message,
      badgeColor: Colors.red,
      badgeText: 'ERROR',
      badgeIcon: Icons.error_outline,
      buttonColor: Colors.red[600]!,
      contentWidget: contentWidget,
    ),
  );
}

void showCoreInfoDialog(BuildContext context, String title, String message, {Widget? contentWidget}) {
  showDialog(
    context: context,
    builder: (context) => CoreBlurDialog(
      title: title,
      message: message,
      badgeColor: Colors.blue,
      badgeText: 'INFO',
      badgeIcon: Icons.info,
      buttonColor: Colors.blue[600]!,
      contentWidget: contentWidget,
    ),
  );
}

void showCoreConfirmDialog({
  required BuildContext context,
  required String title,
  String? message,
  Widget? contentWidget,
  required VoidCallback onConfirm,
  Color color = Colors.blue,
}) {
  showDialog(
    context: context,
    builder: (context) => CoreBlurDialog(
      title: title,
      message: message,
      badgeColor: color,
      badgeText: 'KONFIRMASI',
      badgeIcon: Icons.help_outline,
      buttonColor: color,
      confirmText: 'Ya, Lanjutkan',
      onConfirm: onConfirm,
      contentWidget: contentWidget,
    ),
  );
}
