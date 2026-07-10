import 'package:flutter/material.dart';
import 'package:travis/core/presentations/widgets/widgets.dart';

class ApprovalDetailActionButtons extends StatelessWidget {
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const ApprovalDetailActionButtons({super.key, this.onApprove, this.onReject});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(size.width * 0.045),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CoreButton(
              text: 'Setujui',
              onPressed: onApprove,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              borderRadius: 16,
              elevation: 4,
              height: 56,
              size: CoreButtonSize.medium,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: CoreButton(
              text: 'Tolak',
              onPressed: onReject,
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
              borderRadius: 16,
              elevation: 4,
              height: 56,
              size: CoreButtonSize.medium,
            ),
          ),
        ],
      ),
    );
  }
}
