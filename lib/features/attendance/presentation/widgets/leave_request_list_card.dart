import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travis/features/attendance/data/models/leave_request_model.dart';
import 'package:intl/intl.dart';

class LeaveRequestListCard extends StatelessWidget {
  final LeaveRequestModel leaveRequest;
  final bool hideActions;

  const LeaveRequestListCard({
    super.key,
    required this.leaveRequest,
    this.hideActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusStyle = _resolveStatusStyle(leaveRequest.status);

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: size.width * 0.045,
          vertical: 8,
        ),
        child: InkWell(
          onTap: () {
            context.push(
              '/leave-request-detail',
              extra: {'id': leaveRequest.id, 'hideActions': hideActions},
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
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
                            leaveRequest.type.name.isNotEmpty
                                ? leaveRequest.type.name
                                : 'CUTI',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Karyawan: ${leaveRequest.user.fullName}',
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
                  label: 'Tanggal',
                  value:
                      (_formatDateStr(leaveRequest.tanggalMulai) ==
                          _formatDateStr(leaveRequest.tanggalSelesai))
                      ? _formatDateStr(leaveRequest.tanggalMulai)
                      : '${_formatDateStr(leaveRequest.tanggalMulai)} - ${_formatDateStr(leaveRequest.tanggalSelesai)}',
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.notes_outlined,
                  label: 'Alasan',
                  value: leaveRequest.alasan.isNotEmpty
                      ? leaveRequest.alasan
                      : '-',
                  color: Colors.blue,
                ),
                if (leaveRequest.rejectReason != null &&
                    leaveRequest.rejectReason!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    icon: Icons.error_outline,
                    label: 'Alasan Tolak',
                    value: leaveRequest.rejectReason!,
                    color: Colors.red,
                  ),
                ],
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
                        'Diajukan ${_formatDateTime(leaveRequest.createdAt)}',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  Widget _buildStatusBadge(_LeaveStatusStyle style) {
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDateStr(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDateTime(String raw) {
    if (raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }

  _LeaveStatusStyle _resolveStatusStyle(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return const _LeaveStatusStyle(
          'Disetujui',
          Colors.green,
          Icons.check_circle_outline_rounded,
        );
      case 'REJECTED':
        return const _LeaveStatusStyle(
          'Ditolak',
          Colors.red,
          Icons.cancel_outlined,
        );
      case 'PENDING':
        return const _LeaveStatusStyle(
          'Menunggu',
          Colors.orange,
          Icons.hourglass_top_rounded,
        );
      case 'CANCELLED':
        return const _LeaveStatusStyle(
          'Dibatalkan',
          Colors.grey,
          Icons.remove_circle_outline_rounded,
        );
      default:
        return _LeaveStatusStyle(
          status.isEmpty ? 'Pending' : status,
          Colors.blueGrey,
          Icons.help_outline_rounded,
        );
    }
  }
}

class _LeaveStatusStyle {
  final String label;
  final Color color;
  final IconData icon;

  const _LeaveStatusStyle(this.label, this.color, this.icon);
}
