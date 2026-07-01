import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:psm_mobile/features/attendance/data/models/approval_model.dart';

class ApprovalListCard extends StatelessWidget {
  final ApprovalModel approval;

  const ApprovalListCard({super.key, required this.approval});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusStyle = _resolveStatusStyle(approval.status);

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: size.width * 0.045,
          vertical: 8,
        ),
        // padding: EdgeInsets.all(size.width * 0.045),
        child: InkWell(
          onTap: () => context.push('/approval-detail', extra: approval.id),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            // padding: EdgeInsets.symmetric(
            //   horizontal: size.width * 0.045,
            //   vertical: 6,
            // ),
            padding: EdgeInsets.all(size.width * 0.045),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black26
                      : Colors.grey.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: isDark
                    ? Colors.transparent
                    : Colors.grey.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusStyle.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        statusStyle.icon,
                        color: statusStyle.color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            approval.requester.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pengganti: ${approval.replacement.fullName}',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(statusStyle),
                  ],
                ),
                const SizedBox(height: 14),
                _buildInfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Tanggal Shift',
                  value: _formatDate(approval.tanggal),
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.schedule_outlined,
                  label: 'Shift',
                  value: approval.shift.name,
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Lokasi',
                  value: approval.lokasi.namaLokasi,
                  color: Colors.green,
                ),
                // if (approval.alasan.isNotEmpty) ...[
                //   const SizedBox(height: 12),
                //   Container(
                //     width: double.infinity,
                //     padding: const EdgeInsets.all(12),
                //     decoration: BoxDecoration(
                //       color: theme.colorScheme.surfaceContainerHighest.withValues(
                //         alpha: isDark ? 0.35 : 0.5,
                //       ),
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Text(
                //           'Alasan',
                //           style: TextStyle(
                //             fontSize: 12,
                //             fontWeight: FontWeight.bold,
                //             color: theme.colorScheme.primary,
                //           ),
                //         ),
                //         const SizedBox(height: 4),
                //         Text(
                //           approval.alasan,
                //           style: theme.textTheme.bodyMedium,
                //           maxLines: 2,
                //           overflow: TextOverflow.ellipsis,
                //         ),
                //       ],
                //     ),
                //   ),
                // ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Diajukan ${_formatDateWithHour(approval.createdAt)}',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(_ApprovalStatusStyle style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.color.withValues(alpha: 0.3)),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: style.color,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  String _formatDateWithHour(String raw) {
    if (raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }

  _ApprovalStatusStyle _resolveStatusStyle(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return const _ApprovalStatusStyle(
          'Disetujui',
          Colors.green,
          Icons.check_circle_outline_rounded,
        );
      case 'REJECTED':
        return const _ApprovalStatusStyle(
          'Ditolak',
          Colors.red,
          Icons.cancel_outlined,
        );
      case 'PENDING_REPL':
      case 'PENDING':
        return const _ApprovalStatusStyle(
          'Menunggu Pengganti',
          Colors.orange,
          Icons.hourglass_top_rounded,
        );
      // case 'PENDING':
      //   return const _ApprovalStatusStyle(
      //     'Menunggu',
      //     Colors.amber,
      //     Icons.swap_horiz_rounded,
      //   );
      case 'CANCELLED':
        return const _ApprovalStatusStyle(
          'Dibatalkan',
          Colors.grey,
          Icons.remove_circle_outline_rounded,
        );
      default:
        return _ApprovalStatusStyle(
          status.isEmpty ? 'Pending' : status,
          Colors.blueGrey,
          Icons.help_outline_rounded,
        );
    }
  }
}

class _ApprovalStatusStyle {
  final String label;
  final Color color;
  final IconData icon;

  const _ApprovalStatusStyle(this.label, this.color, this.icon);
}
