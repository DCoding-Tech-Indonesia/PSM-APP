import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/core/notification/approval_refresh_notifier.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';
import 'package:psm_mobile/features/attendance/data/datasources/leave_request_remote_data_source.dart';
import 'package:psm_mobile/features/attendance/data/models/leave_request_model.dart';
import 'package:psm_mobile/features/attendance/data/repositories/leave_request_repository_impl.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/leave_request_bloc.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/leave_request_event.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/leave_request_state.dart';
import 'package:psm_mobile/features/attendance/presentation/widgets/approval_detail_action_buttons.dart';
import 'package:psm_mobile/features/attendance/presentation/widgets/approval_detail_info_card.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_bloc.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_state.dart';

class LeaveRequestDetailScreen extends StatelessWidget {
  final String? id;
  final bool hideActions;

  const LeaveRequestDetailScreen({
    super.key,
    this.id,
    this.hideActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final leaveRequestId = int.tryParse(id ?? '0') ?? 0;

    return BlocProvider(
      create: (context) => LeaveRequestBloc(
        repository: LeaveRequestRepositoryImpl(
          remoteDataSource: LeaveRequestRemoteDataSourceImpl(DioClient()),
        ),
      )..add(LoadLeaveRequestDetail(id: leaveRequestId)),
      child: LeaveRequestDetailView(leaveRequestId: leaveRequestId),
    );
  }
}

class LeaveRequestDetailView extends StatelessWidget {
  final int leaveRequestId;

  const LeaveRequestDetailView({super.key, required this.leaveRequestId});

  @override
  Widget build(BuildContext context) {
    final portalState = context.read<PortalBloc>().state;
    String typePegawai = '';
    int userId = 0;
    if (portalState is PortalLoaded) {
      typePegawai = portalState.profile.typePegawaiCode;
      userId = int.tryParse(portalState.profile.id) ?? 0;
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<LeaveRequestBloc, LeaveRequestState>(
          listener: (context, state) {
            if (state is LeaveRequestDetailLoaded) {
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
                  state.actionSuccessMessage ?? 'Berhasil memproses pengajuan',
                ).then((_) {
                  ApprovalRefreshNotifier.instance.notifyRefresh();
                  if (context.mounted) {
                    context.pop(true);
                  }
                });
              }
            }
          },
          child: BlocBuilder<LeaveRequestBloc, LeaveRequestState>(
            builder: (context, state) {
              final isDetailLoaded = state is LeaveRequestDetailLoaded;
              final detail = isDetailLoaded ? state.leaveRequest : null;
              final isLoadingAction = isDetailLoaded && state.isLoading;

              final showActions =
                  !isLoadingAction &&
                  detail != null &&
                  detail.status == 'PENDING' &&
                  typePegawai.toLowerCase().contains('pgw_mngr_opr');

              return Column(
                children: [
                  CoreHeader(
                    title: 'Detail Pengajuan',
                    subtitle: 'Informasi Lengkap Pengajuan',
                    onBackPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        final bloc = context.read<LeaveRequestBloc>();
                        bloc.add(LoadLeaveRequestDetail(id: leaveRequestId));
                        await bloc.stream.firstWhere(
                          (s) =>
                              (s is LeaveRequestDetailLoaded && !s.isLoading) ||
                              s is LeaveRequestError,
                        );
                      },
                      child: _buildBody(context, theme, state),
                    ),
                  ),
                  if (showActions)
                    ApprovalDetailActionButtons(
                      onApprove: () =>
                          _showConfirmDialog(context, detail.id, userId, true),
                      onReject: () =>
                          _showConfirmDialog(context, detail.id, userId, false),
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
    ThemeData theme,
    LeaveRequestState state,
  ) {
    if (state is LeaveRequestDetailLoading || state is LeaveRequestInitial) {
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

    if (state is LeaveRequestError) {
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
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<LeaveRequestBloc>().add(
                          LoadLeaveRequestDetail(id: leaveRequestId),
                        );
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (state is! LeaveRequestDetailLoaded) {
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

    final detail = state.leaveRequest;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _buildSummaryCard(context, detail),
          const SizedBox(height: 16),
          ApprovalDetailInfoCard(
            title: 'Karyawan',
            subtitle: 'Informasi Karyawan',
            icon: Icons.badge_outlined,
            accentColor: Colors.blue,
            rows: [
              ApprovalDetailInfoRow(
                label: 'Nama',
                value: detail.user.fullName,
                icon: Icons.person_outline,
              ),
              // ApprovalDetailInfoRow(
              //   label: 'Username',
              //   value: detail.user.userName,
              //   icon: Icons.fingerprint,
              // ),
            ],
          ),
          const SizedBox(height: 16),
          ApprovalDetailInfoCard(
            title: 'Pengajuan',
            subtitle: 'Informasi Pengajuan',
            icon: Icons.description_outlined,
            accentColor: Colors.deepPurple,
            rows: [
              ApprovalDetailInfoRow(
                label: 'Tipe',
                value: detail.type.name.isNotEmpty ? detail.type.name : 'CUTI',
                icon: Icons.category_outlined,
              ),
              ApprovalDetailInfoRow(
                label: 'Tanggal Mulai',
                value: _formatDateStr(detail.tanggalMulai),
                icon: Icons.calendar_today_outlined,
              ),
              ApprovalDetailInfoRow(
                label: 'Tanggal Selesai',
                value: _formatDateStr(detail.tanggalSelesai),
                icon: Icons.event_busy_outlined,
              ),
              ApprovalDetailInfoRow(
                label: 'Alasan',
                value: detail.alasan,
                icon: Icons.notes_outlined,
              ),
              ApprovalDetailInfoRow(
                label: 'Dibuat Pada',
                value: _formatDateTimeStr(detail.createdAt),
                icon: Icons.access_time,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- Summary Card Helpers ---

  List<Color> _gradientColors(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return [Colors.green.shade600, Colors.teal.shade400];
      case 'REJECTED':
        return [Colors.red.shade600, Colors.red.shade400];
      case 'CANCELLED':
        return [Colors.grey.shade600, Colors.blueGrey.shade400];
      default:
        return [Colors.amber.shade700, Colors.orange.shade400];
    }
  }

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

  String _badgeLabel(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return 'Disetujui';
      case 'REJECTED':
        return 'Ditolak';
      case 'PENDING':
        return 'Menunggu';
      case 'CANCELLED':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String _subtitleText(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return 'Pengajuan telah disetujui';
      case 'REJECTED':
        return 'Pengajuan telah ditolak';
      case 'CANCELLED':
        return 'Pengajuan dibatalkan';
      default:
        return 'Menunggu persetujuan';
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Icons.check_circle_outline_rounded;
      case 'REJECTED':
        return Icons.cancel_outlined;
      case 'CANCELLED':
        return Icons.remove_circle_outline_rounded;
      default:
        return Icons.pending_actions_rounded;
    }
  }

  Widget _buildSummaryCard(BuildContext context, LeaveRequestModel detail) {
    final size = MediaQuery.of(context).size;
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
                    Text(
                      detail.type.name.isNotEmpty
                          ? detail.type.name
                          : 'Pengajuan',
                      style: const TextStyle(
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
                  label: 'Mulai',
                  value: _formatDateStr(detail.tanggalMulai),
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHighlight(
                  label: 'Selesai',
                  value: _formatDateStr(detail.tanggalSelesai),
                  icon: Icons.event_busy_outlined,
                ),
              ),
            ],
          ),
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

  String _formatDateStr(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDateTimeStr(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _showConfirmDialog(
    BuildContext context,
    int pengajuanId,
    int userId,
    bool isApprove,
  ) {
    final alasanController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final title = isApprove ? 'Konfirmasi Persetujuan' : 'Konfirmasi Penolakan';
    final message = isApprove
        ? 'Apakah Anda yakin ingin menyetujui pengajuan cuti/izin ini?'
        : 'Apakah Anda yakin ingin menolak pengajuan cuti/izin ini?';
    final buttonText = isApprove ? 'Ya, Setujui' : 'Ya, Tolak';
    final gradientColors = isApprove
        ? [Colors.green, Colors.green.withValues(alpha: 0.7)]
        : [Colors.red, Colors.red.withValues(alpha: 0.7)];

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
                              colors: gradientColors,
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
                          title,
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
                          message,
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
                            labelText: isApprove
                                ? 'Catatan / Alasan'
                                : 'Alasan Penolakan',
                            hintText: isApprove
                                ? 'Tulis catatan (wajib)...'
                                : 'Tulis alasan penolakan (wajib)...',
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
                              return isApprove
                                  ? 'Catatan wajib diisi'
                                  : 'Alasan penolakan wajib diisi';
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
                                    colors: gradientColors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: gradientColors[0].withValues(
                                        alpha: 0.3,
                                      ),
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
                                        context.read<LeaveRequestBloc>().add(
                                          ApproveLeaveRequest(
                                            pengajuanRequestId: pengajuanId,
                                            approvedByUserId: userId,
                                            approved: isApprove,
                                            rejectReason: alasanController.text
                                                .trim(),
                                          ),
                                        );
                                      }
                                    },
                                    child: Center(
                                      child: Text(
                                        buttonText,
                                        style: const TextStyle(
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
