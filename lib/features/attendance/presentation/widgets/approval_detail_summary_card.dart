import 'package:flutter/material.dart';
import 'package:psm_mobile/features/attendance/data/models/approval_detail_model.dart';

class ApprovalDetailSummaryCard extends StatelessWidget {
  final ApprovalDetailModel detail;

  const ApprovalDetailSummaryCard({super.key, required this.detail});

  // --- Status helpers ---

  /// Returns gradient colors based on status
  List<Color> _gradientColors(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return [Colors.green.shade600, Colors.teal.shade400];
      case 'REJECTED':
        return [Colors.red.shade600, Colors.red.shade400];
      case 'PENDING_REPL':
      case 'PENDING':
        return [Colors.amber.shade700, Colors.orange.shade400];
      case 'CANCELLED':
        return [Colors.grey.shade600, Colors.blueGrey.shade400];
      default:
        return [Colors.amber.shade700, Colors.orange.shade400];
    }
  }

  /// Returns shadow color based on status
  Color _shadowColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green.withValues(alpha: 0.35);
      case 'REJECTED':
        return Colors.red.withValues(alpha: 0.35);
      case 'CANCELLED':
        return Colors.grey.withValues(alpha: 0.35);
      default:
        return Colors.orange.withValues(alpha: 0.30);
    }
  }

  /// Returns a human-readable badge label
  String _badgeLabel(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return 'Disetujui';
      case 'REJECTED':
        return 'Ditolak';
      case 'PENDING_REPL':
      case 'PENDING':
        // return 'Menunggu Pengganti';
        return 'Menunggu';
      case 'CANCELLED':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  /// Returns subtitle text based on status
  String _subtitleText(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return 'Permohonan telah disetujui';
      case 'REJECTED':
        return 'Permohonan telah ditolak';
      case 'PENDING_REPL':
      case 'PENDING':
        // return 'Menunggu konfirmasi pengganti';
        return 'Menunggu persetujuan Anda';
      case 'CANCELLED':
        return 'Permohonan dibatalkan';
      default:
        return 'Menunggu persetujuan';
    }
  }

  /// Returns icon based on status
  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Icons.check_circle_outline_rounded;
      case 'REJECTED':
        return Icons.cancel_outlined;
      case 'PENDING_REPL':
      case 'PENDING':
        return Icons.swap_horiz_rounded;
      case 'CANCELLED':
        return Icons.remove_circle_outline_rounded;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // final jadwal = detail.jadwal;
    final status = detail.status;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.045),
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _gradientColors(status),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _shadowColor(status),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_statusIcon(status), color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Permohonan Pergantian Shift',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitleText(status),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white38),
                ),
                child: Text(
                  _badgeLabel(status),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildHighlight(
                  label: 'Tanggal',
                  value: detail.tanggal,
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHighlight(
                  label: 'Shift',
                  value: detail.shift.name,
                  icon: Icons.schedule_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildHighlight(
            label: 'Lokasi',
            value: detail.lokasi.namaLokasi,
            icon: Icons.location_on_outlined,
          ),
          // Show reject reason if rejected
          if (status.toUpperCase() == 'REJECTED' &&
              detail.rejectReason != null &&
              detail.rejectReason!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildHighlight(
              label: 'Alasan Penolakan',
              value: detail.rejectReason!,
              icon: Icons.info_outline_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHighlight({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
