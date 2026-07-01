import 'dart:ui' as ui;

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
    String typePegawai = '';
    if (portalState is PortalLoaded) {
      role = portalState.profile.role;
      typePegawai = portalState.profile.typePegawaiCode;
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<ApprovalBloc, ApprovalState>(
          listener: (context, state) {
            if (state is ApprovalDetailLoaded) {
              if (state.actionErrorMessage != null) {
                showCoreErrorDialog(
                  context,
                  'Kesalahan',
                  state.actionErrorMessage!,
                );
              } else if (state.isActionSuccess) {
                showCoreSuccessDialog(
                  context,
                  'Sukses',
                  state.actionSuccessMessage ??
                      'Berhasil menyetujui pergantian shift',
                ).then((_) {
                  ApprovalRefreshNotifier.instance.notifyRefresh();
                  if (context.mounted) {
                    context.pop(true);
                  }
                });
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
                  (role.toLowerCase().contains('korlap') ||
                      typePegawai.toLowerCase().contains('pgw_mngr_opr'));

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
    final alasanController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        bool isFilled = false;

        return StatefulBuilder(
          builder: (dialogContext, setState) {
            final borderColor = isFilled ? Colors.green : Colors.red;
            final labelColor = isFilled ? Colors.green : Colors.red;

            return Dialog(
              backgroundColor: Colors.transparent,
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color:
                        theme.cardTheme.color?.withValues(alpha: 0.8) ??
                        Colors.white.withValues(alpha: 0.8),
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
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red,
                                Colors.red.withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.help_outline,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'KONFIRMASI',
                                style: TextStyle(
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

                        // Title
                        Text(
                          'Konfirmasi Penolakan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // Message
                        Text(
                          'Apakah Anda yakin ingin menolak permohonan pergantian shift ini?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Alasan Input
                        TextFormField(
                          controller: alasanController,
                          maxLines: 3,
                          onChanged: (value) {
                            setState(() {
                              isFilled = value.trim().isNotEmpty;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Alasan Penolakan',
                            hintText: 'Tulis alasan penolakan...',
                            alignLabelWithHint: true,
                            labelStyle: TextStyle(color: labelColor),
                            floatingLabelStyle: TextStyle(color: labelColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: borderColor,
                                width: 1.5,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.grey,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: borderColor,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(14),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Alasan penolakan wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Divider
                        Container(
                          height: 1,
                          color: theme.dividerColor.withValues(alpha: 0.1),
                        ),
                        const SizedBox(height: 20),

                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(
                                    color: theme.dividerColor.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Batal',
                                  style: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red,
                                      Colors.red.withValues(alpha: 0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withValues(alpha: 0.3),
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
                                      if (formKey.currentState!.validate()) {
                                        Navigator.pop(dialogContext);
                                        context.read<ApprovalBloc>().add(
                                          ApproveShift(
                                            pergantianShiftId: shiftId,
                                            approved: false,
                                            rejectReason: alasanController.text
                                                .trim(),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Center(
                                      child: Text(
                                        'Ya, Tolak',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
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
          },
        );
      },
    );
  }
}
