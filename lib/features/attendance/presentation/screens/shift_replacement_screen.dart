import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';
import 'package:psm_mobile/features/attendance/data/datasources/approval_remote_data_source.dart';
import 'package:psm_mobile/features/attendance/data/models/approval_model.dart';
import 'package:psm_mobile/features/attendance/data/models/schedule_model.dart';
import 'package:psm_mobile/features/attendance/data/repositories/approval_repository_impl.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/approval_bloc.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/approval_state.dart';
import 'package:psm_mobile/features/attendance/presentation/widgets/approval_list_card.dart';

class ShiftReplacementScreen extends StatelessWidget {
  final List<ScheduleModel> schedules;
  final int requesterId;
  final Future<List<dynamic>> Function(int jadwalId)
  onFetchReplacementSchedules;
  final Future<bool> Function({
    required int requesterId,
    required int replacementId,
    required int jadwalId,
    required String alasan,
  })
  onRequestShiftReplacement;

  const ShiftReplacementScreen({
    super.key,
    required this.schedules,
    required this.requesterId,
    required this.onFetchReplacementSchedules,
    required this.onRequestShiftReplacement,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ApprovalBloc(
        repository: ApprovalRepositoryImpl(
          remoteDataSource: ApprovalRemoteDataSourceImpl(DioClient()),
        ),
      )..add(LoadApprovalData(type: "REQUESTER")),
      child: _ShiftReplacementView(
        schedules: schedules,
        requesterId: requesterId,
        onFetchReplacementSchedules: onFetchReplacementSchedules,
        onRequestShiftReplacement: onRequestShiftReplacement,
      ),
    );
  }
}

class _ShiftReplacementView extends StatelessWidget {
  final List<ScheduleModel> schedules;
  final int requesterId;
  final Future<List<dynamic>> Function(int jadwalId)
  onFetchReplacementSchedules;
  final Future<bool> Function({
    required int requesterId,
    required int replacementId,
    required int jadwalId,
    required String alasan,
  })
  onRequestShiftReplacement;

  const _ShiftReplacementView({
    required this.schedules,
    required this.requesterId,
    required this.onFetchReplacementSchedules,
    required this.onRequestShiftReplacement,
  });

  void _openForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShiftReplacementFormSheet(
        schedules: schedules,
        requesterId: requesterId,
        onFetchReplacementSchedules: onFetchReplacementSchedules,
        onRequestShiftReplacement: onRequestShiftReplacement,
        onSuccess: () {
          context.read<ApprovalBloc>().add(LoadApprovalData(type: "REQUESTER"));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CoreHeader(
              title: 'Pergantian Jadwal',
              subtitle: 'Daftar pengajuan pergantian jadwal Anda',
              showBackButton: true,
              onBackPressed: () => context.pop(),
            ),
            Expanded(
              child: BlocBuilder<ApprovalBloc, ApprovalState>(
                builder: (context, state) {
                  if (state is ApprovalInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is! ApprovalLoaded) {
                    return const SizedBox.shrink();
                  }

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
                                CircularProgressIndicator(
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(height: 10),
                                const Text('Memuat data...'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      final bloc = context.read<ApprovalBloc>();
                      bloc.add(LoadApprovalData(type: "REQUESTER"));
                      await bloc.stream.firstWhere(
                        (s) => s is ApprovalLoaded && !s.isLoading,
                      );
                    },
                    child: state.approvals.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.08),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.swap_horiz_outlined,
                                            size: 56,
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Belum Ada Pengajuan',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Daftar pengajuan pergantian jadwal Anda akan muncul di sini.',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: theme
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.only(bottom: 80, top: 8),
                            itemCount: state.approvals.length,
                            itemBuilder: (context, index) {
                              final approval =
                                  state.approvals[index] as ApprovalModel;
                              return ApprovalListCard(
                                approval: approval,
                                hideActions: true,
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Bottom Sheet Form
// ──────────────────────────────────────────────
class _ShiftReplacementFormSheet extends StatefulWidget {
  final List<ScheduleModel> schedules;
  final int requesterId;
  final Future<List<dynamic>> Function(int jadwalId)
  onFetchReplacementSchedules;
  final Future<bool> Function({
    required int requesterId,
    required int replacementId,
    required int jadwalId,
    required String alasan,
  })
  onRequestShiftReplacement;
  final VoidCallback onSuccess;

  const _ShiftReplacementFormSheet({
    required this.schedules,
    required this.requesterId,
    required this.onFetchReplacementSchedules,
    required this.onRequestShiftReplacement,
    required this.onSuccess,
  });

  @override
  State<_ShiftReplacementFormSheet> createState() =>
      _ShiftReplacementFormSheetState();
}

class _ShiftReplacementFormSheetState
    extends State<_ShiftReplacementFormSheet> {
  int _jadwalId = 0;
  int _replacementId = 0;
  String _reason = '';
  bool _isLoadingPengganti = false;
  bool _isSubmitting = false;
  List<dynamic> _listPengganti = [];

  Future<void> _onJadwalSelected(ScheduleModel? selected) async {
    if (selected == null) return;
    final selectedId = int.tryParse(selected.id.toString()) ?? 0;

    setState(() {
      _jadwalId = selectedId;
      _isLoadingPengganti = true;
      _listPengganti = [];
      _replacementId = 0;
    });

    try {
      final result = await widget.onFetchReplacementSchedules(selectedId);
      setState(() {
        _listPengganti = result;
        _isLoadingPengganti = false;
      });
    } catch (e) {
      setState(() => _isLoadingPengganti = false);
      if (!mounted) return;
      showCoreErrorDialog(context, 'Gagal', 'Gagal memuat pengganti: $e');
    }
  }

  Future<void> _submit() async {
    if (_jadwalId == 0 || _replacementId == 0) {
      showCoreErrorDialog(
        context,
        'Validasi Gagal',
        'Pilih jadwal dan pengganti terlebih dahulu!',
      );
      return;
    }
    if (_reason.trim().isEmpty) {
      showCoreErrorDialog(
        context,
        'Validasi Gagal',
        'Alasan tidak boleh kosong!',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await widget.onRequestShiftReplacement(
        requesterId: widget.requesterId,
        replacementId: _replacementId,
        jadwalId: _jadwalId,
        alasan: _reason,
      );

      if (!mounted) return;

      if (success) {
        widget.onSuccess();
        context.pop();
        showCoreSuccessDialog(
          context,
          'Sukses',
          'Berhasil mengajukan pergantian jadwal',
        );
      } else {
        showCoreErrorDialog(
          context,
          'Gagal',
          'Gagal mengajukan pergantian jadwal.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      showCoreErrorDialog(
        context,
        'Gagal',
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ajukan Pergantian Jadwal',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CoreDropdownSearch<ScheduleModel>(
                label: 'Jadwal',
                hintText: 'Pilih jadwal yang ingin diganti',
                popupTitle: 'Pilih Jadwal',
                isRequired: true,
                isItemSelected: (s) => s.id == _jadwalId,
                items: widget.schedules,
                itemAsString: (s) =>
                    '${_formatDateStr(s.tanggal)} - ${s.shift.name} - ${s.lokasi.namaLokasi}',
                compareFn: (a, b) => a.id == b.id,
                onSelected: _onJadwalSelected,
              ),
              if (_jadwalId > 0) ...[
                const SizedBox(height: 20),
                if (_isLoadingPengganti)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else ...[
                  CoreDropdownSearch<dynamic>(
                    label: 'Pengganti',
                    hintText: 'Pilih karyawan pengganti',
                    popupTitle: 'Pilih Pengganti',
                    items: _listPengganti,
                    itemAsString: (s) => '${s['fullName']?.toString()}',
                    compareFn: (a, b) => a['userId'] == b['userId'],
                    onSelected: (selected) {
                      if (selected != null) {
                        setState(() {
                          _replacementId =
                              int.tryParse(selected['userId'].toString()) ?? 0;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  CoreInputFieldNew(
                    label: 'Alasan',
                    hintText: 'Masukkan alasan pergantian jadwal',
                    onChanged: (v) => _reason = v,
                  ),
                ],
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isSubmitting || _jadwalId == 0) ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    disabledBackgroundColor: theme.primaryColor.withValues(
                      alpha: 0.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Kirim Pengajuan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
