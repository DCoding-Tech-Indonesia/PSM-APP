import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/core/notification/approval_refresh_notifier.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';
import 'package:psm_mobile/features/attendance/data/datasources/approval_remote_data_source.dart';
import 'package:psm_mobile/features/attendance/data/models/approval_detail_model.dart';
import 'package:psm_mobile/features/attendance/data/repositories/approval_repository_impl.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/approval_bloc.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/approval_state.dart';
import 'package:psm_mobile/features/attendance/presentation/widgets/widgets.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_bloc.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_state.dart';

class ApprovalDetailScreen extends StatelessWidget {
  final String? id;

  const ApprovalDetailScreen({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    final approvalId = int.tryParse(id ?? '0') ?? 0;

    return BlocProvider(
      create: (context) => ApprovalBloc(
        repository: ApprovalRepositoryImpl(
          remoteDataSource: ApprovalRemoteDataSourceImpl(DioClient()),
        ),
      )..add(LoadApprovalDetail(id: approvalId)),
      child: ApprovalDetailView(approvalId: approvalId),
    );
  }
}

class ApprovalDetailView extends StatelessWidget {
  final int approvalId;

  const ApprovalDetailView({super.key, required this.approvalId});

  @override
  Widget build(BuildContext context) {
    final portalState = context.read<PortalBloc>().state;
    String role = '';
    if (portalState is PortalLoaded) {
      role = portalState.profile.role;
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<ApprovalBloc, ApprovalState>(
          listener: (context, state) {
            if (state is ApprovalDetailLoaded) {
              if (state.errorMessage != null) {
                showCoreErrorDialog(context, 'Kesalahan', state.errorMessage!);
              } else if (state.isActionSuccess) {
                showCoreSuccessDialog(
                  context,
                  'Sukses',
                  'Berhasil menyetujui pergantian shift',
                );
                ApprovalRefreshNotifier.instance.notifyRefresh();
                context.pop(true);
              }
            }
          },
          child: BlocBuilder<ApprovalBloc, ApprovalState>(
            builder: (context, state) {
              if (state is ApprovalInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is! ApprovalDetailLoaded) {
                return const SizedBox.shrink();
              }

              final s = state;

              final detail = s.detail as ApprovalDetailModel?;
              final showActions =
                  !s.isLoading &&
                  detail != null &&
                  (detail.status == 'PENDING_REPL' ||
                      detail.status == 'PENDING') &&
                  role.toLowerCase().contains('korlap');

              return Column(
                children: [
                  ApprovalDetailHeader(approvalId: approvalId),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        final bloc = context.read<ApprovalBloc>();
                        bloc.add(LoadApprovalDetail(id: approvalId));
                        await bloc.stream.firstWhere(
                          (state) =>
                              state is ApprovalDetailLoaded && !state.isLoading,
                        );
                      },
                      child: _buildBody(context, s, theme),
                    ),
                  ),
                  if (showActions)
                    ApprovalDetailActionButtons(
                      onApprove: () =>
                          _showApproveConfirmDialog(context, detail.id),
                      onReject: () =>
                          _showRejectConfirmDialog(context, detail.id),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ApprovalDetailLoaded state,
    ThemeData theme,
  ) {
    if (state.isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.primary),
                  const SizedBox(height: 10),
                  const Text('Memuat data...'),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (state.errorMessage != null && state.detail == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 72,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi Kesalahan',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    final detail = state.detail as ApprovalDetailModel?;
    if (detail == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: const Center(child: Text('Data tidak ditemukan')),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          ApprovalDetailSummaryCard(detail: detail),
          const SizedBox(height: 16),
          ApprovalDetailFlowCard(detail: detail),
          const SizedBox(height: 16),
          ApprovalDetailInfoCard(
            title: 'Pemohon',
            subtitle: 'Karyawan yang mengajukan',
            icon: Icons.badge_outlined,
            accentColor: Colors.blue,
            rows: [
              ApprovalDetailInfoRow(
                label: 'Nama',
                value: detail.requester.fullName,
                icon: Icons.person_outline,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ApprovalDetailInfoCard(
            title: 'Jadwal Saat Ini',
            subtitle: detail.jadwal.shift.name,
            icon: Icons.event_note_outlined,
            accentColor: Colors.deepPurple,
            rows: [
              ApprovalDetailInfoRow(
                label: 'Lokasi',
                value: detail.jadwal.lokasi.namaLokasi,
                icon: Icons.location_on_outlined,
              ),
              ApprovalDetailInfoRow(
                label: 'Shift',
                value: detail.jadwal.shift.name,
                icon: Icons.schedule_outlined,
              ),
              ApprovalDetailInfoRow(
                label: 'Tanggal',
                value: detail.jadwal.tanggal,
                icon: Icons.calendar_today_outlined,
              ),
              if (detail.jadwal.isCadangan)
                const ApprovalDetailInfoRow(
                  label: 'Tipe',
                  value: 'Cadangan',
                  icon: Icons.star_outline,
                ),
            ],
          ),
          const SizedBox(height: 16),
          ApprovalDetailInfoCard(
            title: 'Pengganti',
            subtitle: 'Karyawan pengganti shift',
            icon: Icons.how_to_reg_outlined,
            accentColor: Colors.green,
            rows: [
              ApprovalDetailInfoRow(
                label: 'Nama',
                value: detail.replacement.fullName,
                icon: Icons.person_add_alt_1_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showApproveConfirmDialog(BuildContext context, int shiftId) {
    showCoreConfirmDialog(
      context: context,
      title: 'Konfirmasi Persetujuan',
      message:
          'Apakah Anda yakin ingin menyetujui permohonan pergantian shift ini?',
      color: Colors.green,
      onConfirm: () {
        context.read<ApprovalBloc>().add(
          ApproveShift(pergantianShiftId: shiftId, approved: true),
        );
      },
    );
  }

  void _showRejectConfirmDialog(BuildContext context, int shiftId) {
    showCoreConfirmDialog(
      context: context,
      title: 'Konfirmasi Penolakan',
      message:
          'Apakah Anda yakin ingin menolak permohonan pergantian shift ini?',
      color: Colors.red,
      onConfirm: () {
        context.read<ApprovalBloc>().add(
          ApproveShift(pergantianShiftId: shiftId, approved: false),
        );
      },
    );
  }
}
