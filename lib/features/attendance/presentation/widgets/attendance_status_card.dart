import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/attendance_state.dart';

class AttendanceStatusCard extends StatelessWidget {
  final AttendanceLoaded state;

  const AttendanceStatusCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final statusColor = state.checkOutTime.isNotEmpty
        ? Colors.blue
        : state.isCheckedIn
        ? Colors.green
        : Colors.orange;

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
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  state.isCheckedIn ? Icons.check_circle : Icons.login,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Absensi Hari Ini',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            state.checkOutTime.isNotEmpty
                                ? 'Selesai'
                                : state.isCheckedIn
                                ? 'Sudah Check-in'
                                : 'Belum Check-in',
                            style: TextStyle(
                              fontSize: 14,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (state.isCadangan ? Colors.amber : Colors.green)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              (state.isCadangan ? Colors.amber : Colors.green)
                                  .withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: state.isCadangan
                                    ? Colors.amber
                                    : Colors.green,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (state.isCadangan
                                                ? Colors.amber
                                                : Colors.green)
                                            .withValues(alpha: 0.5),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              state.isCadangan ? 'Cadangan' : 'Utama',
                              style: TextStyle(
                                fontSize: 12,
                                color: state.isCadangan
                                    ? Colors.amber[900]
                                    : Colors.green[900],
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: (state.isLoading || state.radiusInfo == '0m')
                      ? null
                      : state.isCheckedIn
                      ? null
                      : () {
                          if (state.isMocked) {
                            showCoreErrorDialog(
                              context,
                              'Fake GPS Terdeteksi',
                              'Sistem mendeteksi penggunaan aplikasi manipulasi lokasi. Harap gunakan lokasi asli perangkat Anda.',
                            );
                          } else if (!state.canCheckIn) {
                            showCoreErrorDialog(
                              context,
                              'Di Luar Lokasi',
                              'Anda berada di luar radius kantor (${state.distanceFromOffice}). Silakan mendekat ke area kantor untuk melakukan absensi.',
                            );
                          } else {
                            showCoreConfirmDialog(
                              context: context,
                              title: 'Konfirmasi Check-in',
                              message:
                                  'Apakah Anda yakin ingin melakukan Check-in sekarang?',
                              color: Colors.green,
                              onConfirm: () =>
                                  context.read<AttendanceBloc>().add(
                                    CheckInRequested(
                                      busId:
                                          int.tryParse(
                                            state.bus.first['id'].toString(),
                                          ) ??
                                          0,
                                    ),
                                  ),
                            );
                          }
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: _buildTimeInfo(
                    'Check-in',
                    state.checkInTime.isEmpty ? '--:--:--' : state.checkInTime,
                    Icons.login,
                    Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: (state.isLoading || state.radiusInfo == '0m')
                      ? null
                      : (state.checkOutTime.isNotEmpty || !state.isCheckedIn)
                      ? null
                      : () {
                          if (state.isMocked) {
                            showCoreErrorDialog(
                              context,
                              'Fake GPS Terdeteksi',
                              'Sistem mendeteksi penggunaan aplikasi manipulasi lokasi. Harap gunakan lokasi asli perangkat Anda.',
                            );
                          } else if (!state.canCheckIn) {
                            showCoreErrorDialog(
                              context,
                              'Di Luar Lokasi',
                              'Anda berada di luar radius kantor (${state.distanceFromOffice}). Silakan mendekat ke area kantor untuk melakukan absensi.',
                            );
                          } else {
                            showCoreConfirmDialog(
                              context: context,
                              title: 'Konfirmasi Check-out',
                              message:
                                  'Apakah Anda yakin ingin melakukan Check-out sekarang?',
                              color: Colors.red,
                              onConfirm: () => context
                                  .read<AttendanceBloc>()
                                  .add(CheckOutRequested()),
                            );
                          }
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: _buildTimeInfo(
                    'Check-out',
                    state.checkOutTime.isEmpty
                        ? '--:--:--'
                        : state.checkOutTime,
                    Icons.logout,
                    Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              time,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
