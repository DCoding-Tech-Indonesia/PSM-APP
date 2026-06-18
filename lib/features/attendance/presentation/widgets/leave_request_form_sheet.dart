import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/leave_request_bloc.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/leave_request_event.dart';
import 'package:psm_mobile/features/attendance/presentation/bloc/leave_request_state.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';
import 'package:psm_mobile/features/portal/presentation/bloc/portal_state.dart';

class LeaveRequestFormSheet extends StatefulWidget {
  const LeaveRequestFormSheet({super.key});

  @override
  State<LeaveRequestFormSheet> createState() => _LeaveRequestFormSheetState();
}

class _LeaveRequestFormSheetState extends State<LeaveRequestFormSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_startDate != null && _startDate!.isAfter(_endDate!)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        showCoreErrorDialog(
          context,
          'Validasi Gagal',
          'Pilih tanggal mulai dan selesai cuti',
        );
        return;
      }

      final portalState = context.read<PortalBloc>().state;
      String userId = '';
      if (portalState is PortalLoaded) {
        userId = portalState.profile.id;
      }

      final format = DateFormat('yyyy-MM-dd');

      context.read<LeaveRequestBloc>().add(
        SubmitLeaveRequest(
          userId: int.tryParse(userId) ?? 0,
          typePengajuan: 'CUTI',
          tanggalMulai: format.format(_startDate!),
          tanggalSelesai: format.format(_endDate!),
          alasan: _reasonController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<LeaveRequestBloc, LeaveRequestState>(
      listenWhen: (previous, current) {
        if (previous is LeaveRequestLoaded && current is LeaveRequestLoaded) {
          return previous.isSubmitting != current.isSubmitting;
        }
        return false;
      },
      listener: (context, state) {
        if (state is LeaveRequestLoaded) {
          if (!state.isSubmitting && state.submitSuccess) {
            context.pop(); // Close sheet
            showCoreSuccessDialog(
              context,
              'Pengajuan Cuti',
              'Pengajuan cuti berhasil!',
            );
          } else if (!state.isSubmitting && state.submitError != null) {
            showCoreErrorDialog(
              context,
              'Gagal',
              state.submitError!.replaceAll('Exception: ', ''),
            );
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Buat Pengajuan Cuti',
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
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker(
                          label: 'Tanggal Mulai',
                          date: _startDate,
                          onTap: () => _selectDate(context, true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDatePicker(
                          label: 'Tanggal Selesai',
                          date: _endDate,
                          onTap: () => _selectDate(context, false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Alasan Cuti', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Tuliskan alasan pengajuan cuti Anda',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.cardColor,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Alasan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: BlocBuilder<LeaveRequestBloc, LeaveRequestState>(
                      builder: (context, state) {
                        bool isSubmitting = false;
                        if (state is LeaveRequestLoaded) {
                          isSubmitting = state.isSubmitting;
                        }

                        return ElevatedButton(
                          onPressed: isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSubmitting
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
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? DateFormat('dd MMM yyyy').format(date)
                      : 'Pilih Tanggal',
                  style: TextStyle(
                    color: date != null
                        ? theme.textTheme.bodyLarge?.color
                        : Colors.grey,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
