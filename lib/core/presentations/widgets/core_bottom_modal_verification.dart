import 'package:flutter/material.dart';
import 'package:psm_mobile/core/presentations/widgets/core_button.dart';

class CoreBottomModalVerification extends StatelessWidget {
  const CoreBottomModalVerification({
    super.key,
    required this.title,
    this.desc,
    this.cancelText = 'Kembali',
    this.confirmText = 'Lanjutkan',
    this.onCancel,
    this.onConfirm,
  });

  final String title;
  final String? desc;

  final String cancelText;
  final String confirmText;

  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),

            if (desc != null) ...[
              const SizedBox(height: 8),
              Text(
                desc!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: CoreButton(
                    backgroundColor: Colors.white,
                    borderColor: Colors.blue,
                    onPressed: onCancel ?? () => Navigator.pop(context, false),
                    child: Text(
                      cancelText,
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: CoreButton(
                    onPressed: onConfirm ?? () => Navigator.pop(context, true),
                    child: Text(
                      confirmText,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
