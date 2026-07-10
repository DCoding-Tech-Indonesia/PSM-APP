import 'package:flutter/material.dart';
import 'package:travis/core/presentations/widgets/core_button.dart';

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
      child: Container(
        height: 220,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D3748),
                  ),
                ),
                if (desc != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    desc!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF718096),
                    ),
                  ),
                ],
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: CoreButton(
                    backgroundColor: Colors.white,
                    borderColor: const Color(0xFF1565C0),
                    borderRadius: 12,
                    onPressed: onCancel ?? () => Navigator.pop(context, false),
                    child: Text(
                      cancelText,
                      style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: CoreButton(
                    backgroundColor: const Color(0xFF1565C0),
                    borderRadius: 12,
                    onPressed: onConfirm ?? () => Navigator.pop(context, true),
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
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
