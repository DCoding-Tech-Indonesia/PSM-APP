import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_record.dart';
import 'package:psm_mobile/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:psm_mobile/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_bloc.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_state.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/core/helper/location_service.dart';
import 'package:psm_mobile/features/portal/presentation/widget/portal_schedule_ribbon.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get userId from PortalBloc
    final portalState = context.read<PortalBloc>().state;
    String userId = '';
    if (portalState is PortalLoaded) {
      userId = portalState.profile.id;
    }

    return BlocProvider(
      create: (context) => AttendanceBloc(
        repository: AttendanceRepositoryImpl(
          remoteDataSource: AttendanceRemoteDataSourceImpl(DioClient()),
        ),
        locationService: LocationService(),
      )..add(LoadAttendanceData(userId: userId)),
      child: const AttendanceViewContent(),
    );
  }
}

class AttendanceViewContent extends StatelessWidget {
  const AttendanceViewContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<AttendanceBloc, AttendanceState>(
          listener: (context, state) {
            if (state is AttendanceLoaded && state.errorMessage != null) {
              _showErrorDialog(context, 'Kesalahan', state.errorMessage!);
            }
          },
          child: BlocBuilder<AttendanceBloc, AttendanceState>(
            builder: (context, state) {
              if (state is AttendanceInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              final s = state as AttendanceLoaded;

              return Column(
                children: [
                  _buildCustomHeader(context, theme),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        final bloc = context.read<AttendanceBloc>();
                        bloc.add(RefreshAttendanceData());
                        
                        // Menunggu hingga state kembali ke 'Loaded' dengan 'isLoading: false'
                        // agar animasi refresh indicator tetap berputar sampai data benar-benar siap.
                        await bloc.stream.firstWhere(
                          (state) => state is AttendanceLoaded && !state.isLoading
                        );
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        // padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLocationStatusCard(context, s),
                            const SizedBox(height: 16),
                            if (state.isLoading) ...[
                              // const Center(
                              //   child: Column(
                              //     children: [
                              //       SizedBox(height: 50),
                              //       CircularProgressIndicator(strokeWidth: 2.0),
                              //       SizedBox(height: 10),
                              //       Text('Memuat data...'),
                              //     ],
                              //   ),
                              // ),
                            ] else ...[
                              const PortalScheduleRibbon(),
                              // const SizedBox(height: 16),
                              // _buildDateTimeCard(s),
                              // const SizedBox(height: 20),
                              _buildAttendanceStatusCard(s),
                              const SizedBox(height: 20),
                              _buildActionButtons(context, s),
                              const SizedBox(height: 20),
                              _buildMonthlyStatsCard(s),
                              const SizedBox(height: 20),
                              _buildRecentHistoryCard(s),
                              const SizedBox(height: 40),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Absensi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Check-in & Check-out',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Row(
          //   children: [
          //     if (kDebugMode)
          //       IconButton(
          //         icon: const Icon(Icons.bug_report),
          //         onPressed: () {
          //           _showInfoDialog(
          //             context,
          //             'Debug Mode',
          //             'Menampilkan data debug di console',
          //           );
          //         },
          //       ),
          //     IconButton(
          //       icon: const Icon(Icons.refresh),
          //       onPressed: () {
          //         context.read<AttendanceBloc>().add(RefreshLocation());
          //         _showSuccessDialog(
          //           context,
          //           'Data Diperbarui',
          //           'Data absensi berhasil diperbarui.',
          //         );
          //       },
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard(AttendanceLoaded state) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.grey.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.transparent : Colors.grey.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_today_outlined, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    state.currentDate,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      state.currentTime,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationStatusCard(BuildContext context, AttendanceLoaded state) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: state.canCheckIn
                  ? [Colors.green[600]!, Colors.green[400]!]
                  : [Colors.red[600]!, Colors.red[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (state.canCheckIn ? Colors.green : Colors.red).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.location_on, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Status Lokasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          state.locationStatus,
                          style: const TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.read<AttendanceBloc>().add(RefreshLocation()),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ],
              ),
              if (state.radiusInfo != '0m') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jarak dari ${state.locationStatus}', style: const TextStyle(fontSize: 14, color: Colors.white70)),
                          Text(
                            state.distanceFromOffice,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: state.canCheckIn ? Colors.white24 : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Radius: ${state.radiusInfo}', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (state.isLoading)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                    SizedBox(height: 12),
                    Text('Mendapatkan lokasi...', style: TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAttendanceStatusCard(AttendanceLoaded state) {
    final statusColor = state.checkOutTime.isNotEmpty
        ? Colors.blue
        : state.isCheckedIn
          ? Colors.green
          : Colors.orange;

    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.grey.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.transparent : Colors.grey.withValues(alpha: 0.2),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Status Absensi Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                              state.checkOutTime.isNotEmpty
                                  ? 'Selesai'
                                  : state.isCheckedIn
                                    ? 'Sudah Check-in'
                                    : 'Belum Check-in',
                              style: TextStyle(fontSize: 14, color: statusColor, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (state.isCadangan ? Colors.amber : Colors.green).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: (state.isCadangan ? Colors.amber : Colors.green).withValues(alpha: 0.3), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: state.isCadangan ? Colors.amber : Colors.green,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (state.isCadangan ? Colors.amber : Colors.green).withValues(alpha: 0.5),
                                      blurRadius: 4,
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                state.isCadangan ? 'Cadangan' : 'Utama',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: state.isCadangan ? Colors.amber[900] : Colors.green[900],
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
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
                                _showErrorDialog(context, 'Fake GPS Terdeteksi', 'Sistem mendeteksi penggunaan aplikasi manipulasi lokasi. Harap gunakan lokasi asli perangkat Anda.');
                              } else if (!state.canCheckIn) {
                                _showErrorDialog(context, 'Di Luar Lokasi', 'Anda berada di luar radius kantor (${state.distanceFromOffice}). Silakan mendekat ke area kantor untuk melakukan absensi.');
                              } else {
                                _showConfirmDialog(
                                  context: context,
                                  title: 'Konfirmasi Check-in',
                                  message: 'Apakah Anda yakin ingin melakukan Check-in sekarang?',
                                  color: Colors.green,
                                  onConfirm: () => context.read<AttendanceBloc>().add(CheckInRequested()),
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
                                _showErrorDialog(context, 'Fake GPS Terdeteksi', 'Sistem mendeteksi penggunaan aplikasi manipulasi lokasi. Harap gunakan lokasi asli perangkat Anda.');
                              } else if (!state.canCheckIn) {
                                _showErrorDialog(context, 'Di Luar Lokasi', 'Anda berada di luar radius kantor (${state.distanceFromOffice}). Silakan mendekat ke area kantor untuk melakukan absensi.');
                              } else {
                                _showConfirmDialog(
                                  context: context,
                                  title: 'Konfirmasi Check-out',
                                  message: 'Apakah Anda yakin ingin melakukan Check-out sekarang?',
                                  color: Colors.red,
                                  onConfirm: () => context.read<AttendanceBloc>().add(CheckOutRequested()),
                                );
                              }
                            },
                      borderRadius: BorderRadius.circular(12),
                      child: _buildTimeInfo(
                        'Check-out',
                        state.checkOutTime.isEmpty ? '--:--:--' : state.checkOutTime,
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
      },
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
              Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AttendanceLoaded state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: (state.isLoading || state.radiusInfo == '0m')
                  ? null 
                  : state.isCheckedIn
                    ? null
                    : () {
                        if (state.isMocked) {
                          _showErrorDialog(context, 'Fake GPS Terdeteksi', 'Sistem mendeteksi penggunaan aplikasi manipulasi lokasi. Harap gunakan lokasi asli perangkat Anda.');
                        } else if (!state.canCheckIn) {
                          _showErrorDialog(context, 'Di Luar Lokasi', 'Anda berada di luar radius kantor (${state.distanceFromOffice}). Silakan mendekat ke area kantor untuk melakukan absensi.');
                        } else {
                          _showConfirmDialog(
                            context: context,
                            title: 'Konfirmasi Check-in',
                            message: 'Apakah Anda yakin ingin melakukan Check-in sekarang?',
                            color: Colors.green,
                            onConfirm: () => context.read<AttendanceBloc>().add(CheckInRequested()),
                          );
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: state.isCheckedIn ? Colors.grey : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(state.isCheckedIn ? Icons.check_circle : Icons.login),
                  const SizedBox(width: 8),
                  Text(state.isCheckedIn ? 'Check-in OK' : 'Check-in', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: (state.isLoading || state.radiusInfo == '0m')
                  ? null
                  : (state.checkOutTime.isNotEmpty || !state.isCheckedIn)
                    ? null
                    : () {
                        if (state.isMocked) {
                          _showErrorDialog(context, 'Fake GPS Terdeteksi', 'Sistem mendeteksi penggunaan aplikasi manipulasi lokasi. Harap gunakan lokasi asli perangkat Anda.');
                        } else if (!state.canCheckIn) {
                          _showErrorDialog(context, 'Di Luar Lokasi', 'Anda berada di luar radius kantor (${state.distanceFromOffice}). Silakan mendekat ke area kantor untuk melakukan absensi.');
                        } else {
                          _showConfirmDialog(
                            context: context,
                            title: 'Konfirmasi Check-out',
                            message: 'Apakah Anda yakin ingin melakukan Check-out sekarang?',
                            color: Colors.red,
                            onConfirm: () => context.read<AttendanceBloc>().add(CheckOutRequested()),
                          );
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: state.checkOutTime.isNotEmpty ? Colors.grey : Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(state.checkOutTime.isNotEmpty ? Icons.check_circle : Icons.logout),
                  const SizedBox(width: 8),
                  Text(state.checkOutTime.isNotEmpty ? 'Check-out OK' : 'Check-out', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStatsCard(AttendanceLoaded state) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics, color: Colors.purple),
                  SizedBox(width: 12),
                  Text('Statistik Bulan Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              // if (state.isLoading) 
              //   const Center(
              //     child: Column(
              //       children: [
              //         CircularProgressIndicator(),
              //         SizedBox(height: 10),
              //         Text("Loading..."),
              //       ],
              //     ),)
              // else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total', state.stats.totalDays.toString(), Colors.blue),
                    _buildStatItem('Hadir', state.stats.presentDays.toString(), Colors.green),
                    _buildStatItem('Late', state.stats.lateDays.toString(), Colors.orange),
                    _buildStatItem('Alpha', state.stats.absentDays.toString(), Colors.red),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRecentHistoryCard(AttendanceLoaded state) {
    return Builder(
      builder: (context) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Riwayat Terakhir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      _showInfoDialog(context, "TEST", "TEST"); // TESTING
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Row(
                      children: [
                        Text('Lihat Semua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 12),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // if (state.isLoading)
              //   const Center(
              //     child: Padding(
              //       padding: EdgeInsets.all(40.0),
              //       child: Column(
              //         children: [
              //           CircularProgressIndicator(),
              //           SizedBox(height: 10),
              //           Text("Loading..."),
              //         ],
              //       ),
              //     ),
              //   )
              // else 
              if (state.history.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('Belum ada riwayat', style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ...state.history.map((record) => _buildHistoryItem(record)),
            ],
          )
        );
      }
    );
  }

  Widget _buildHistoryItem(AttendanceRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.date, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildMiniBadge('In: ${record.checkInTime}', Colors.green),
                    const SizedBox(width: 8),
                    _buildMiniBadge('Out: ${record.checkOutTime}', Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }
}

class _BaseBlurDialog extends StatelessWidget {
  final String title;
  final String message;
  final Color badgeColor;
  final String badgeText;
  final IconData badgeIcon;
  final Color buttonColor;
  final String? confirmText;
  final VoidCallback? onConfirm;

  const _BaseBlurDialog({
    required this.title,
    required this.message,
    required this.badgeColor,
    required this.badgeText,
    required this.badgeIcon,
    required this.buttonColor,
    this.confirmText,
    this.onConfirm,
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
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

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

void _showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (context) => _BaseBlurDialog(
      title: title,
      message: message,
      badgeColor: Colors.red,
      badgeText: 'ERROR',
      badgeIcon: Icons.error_outline,
      buttonColor: Colors.red[600]!,
    ),
  );
}

void _showInfoDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (context) => _BaseBlurDialog(
      title: title,
      message: message,
      badgeColor: Colors.blue,
      badgeText: 'INFO',
      badgeIcon: Icons.info,
      buttonColor: Colors.blue[600]!,
    ),
  );
}

// void _showSuccessDialog(BuildContext context, String title, String message) {
//   showDialog(
//     context: context,
//     builder: (context) => _BaseBlurDialog(
//       title: title,
//       message: message,
//       badgeColor: Colors.green,
//       badgeText: 'SUCCESS',
//       badgeIcon: Icons.check_circle,
//       buttonColor: Colors.green[600]!,
//     ),
//   );
// }

void _showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onConfirm,
  Color color = Colors.blue,
}) {
  showDialog(
    context: context,
    builder: (context) => _BaseBlurDialog(
      title: title,
      message: message,
      badgeColor: color,
      badgeText: 'KONFIRMASI',
      badgeIcon: Icons.help_outline,
      buttonColor: color,
      confirmText: 'Ya, Lanjutkan',
      onConfirm: onConfirm,
    ),
  );
}
