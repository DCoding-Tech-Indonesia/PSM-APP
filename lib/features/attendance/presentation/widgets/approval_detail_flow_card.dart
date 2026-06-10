import 'package:flutter/material.dart';
import 'package:psm_mobile/features/attendance/data/models/approval_detail_model.dart';

class ApprovalDetailFlowCard extends StatelessWidget {
  final ApprovalDetailModel detail;

  const ApprovalDetailFlowCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.045),
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black26
                : Colors.grey.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.transparent
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alur Pergantian',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFlowNode(
                  label: 'Pemohon',
                  value: detail.requester.userName,
                  icon: Icons.person_outline,
                  color: Colors.blue,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              Expanded(
                child: _buildFlowNode(
                  label: 'Pengganti',
                  value: detail.replacement.userName,
                  icon: Icons.person_add_alt_1_outlined,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlowNode({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
