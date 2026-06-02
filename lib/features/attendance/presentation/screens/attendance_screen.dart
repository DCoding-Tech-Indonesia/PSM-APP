import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:psm_mobile/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:psm_mobile/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_bloc.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_state.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/core/helper/location_service.dart';
import 'package:psm_mobile/features/attendance/presentation/widgets/widgets.dart';

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
              showCoreErrorDialog(context, 'Kesalahan', state.errorMessage!);
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
                  const AttendanceHeader(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        final bloc = context.read<AttendanceBloc>();
                        bloc.add(RefreshAttendanceData());

                        // Menunggu hingga state kembali ke 'Loaded' dengan 'isLoading: false'
                        // agar animasi refresh indicator tetap berputar sampai data benar-benar siap.
                        await bloc.stream.firstWhere(
                          (state) =>
                              state is AttendanceLoaded && !state.isLoading,
                        );
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (state.isLoading) ...[
                              const Center(
                                child: Column(
                                  children: [
                                    SizedBox(height: 50),
                                    CircularProgressIndicator(),
                                    SizedBox(height: 10),
                                    Text('Memuat data...'),
                                  ],
                                ),
                              ),
                            ] else ...[
                              DateTimeCard(state: s),
                              LocationStatusCard(state: s),
                              const SizedBox(height: 16),
                              // const PortalScheduleRibbon(),
                              AttendanceStatusCard(state: s),
                              const SizedBox(height: 20),
                              AttendanceActionButtons(state: s),
                              // const SizedBox(height: 20),
                              // MonthlyStatsCard(state: s),
                              const SizedBox(height: 20),
                              RecentHistoryCard(state: s),
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
}
