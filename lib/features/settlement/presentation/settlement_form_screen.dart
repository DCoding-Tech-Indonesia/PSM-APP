import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/presentations/widgets/core_bottom_modal_verification.dart';
import 'package:psm_mobile/core/presentations/widgets/core_snackbar.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/form/wizard_detail_step.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/form/wizard_first_step.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/form/wizard_last_step.dart';

class SettlementFormScreen extends StatefulWidget {
  const SettlementFormScreen({
    super.key,
    this.idAuditTrail,
    this.idShift,
    this.idKoridor,
    this.idBus,
    this.ritaseKe,
  });

  final int? idAuditTrail;
  final int? idShift;
  final int? idKoridor;
  final int? idBus;
  final double? ritaseKe;

  @override
  State<SettlementFormScreen> createState() => _SettlementFormScreenState();
}

class _SettlementFormScreenState extends State<SettlementFormScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SettlementBloc>().add(
        PageInputLoad(
          widget.idAuditTrail,
          widget.idShift,
          widget.idKoridor,
          widget.idBus,
          widget.ritaseKe,
        ),
      );
    });
  }

  Future<void> _showStep2Confirmation(BuildContext context) async {
    final isConfirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return CoreBottomModalVerification(
          title: 'Lanjut tahap berikutnya?',
          desc: 'Pastikan data yang dimasukkan sudah benar',
          onCancel: () => Navigator.pop(modalContext, false),
          onConfirm: () => Navigator.pop(modalContext, true),
        );
      },
    );

    if (isConfirm == true) {
      context.read<SettlementBloc>().add(MoveStepWizard(3));
    }
  }

  Future<void> _showStep3Confirmation(BuildContext context) async {
    final isConfirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return CoreBottomModalVerification(
          title: 'Simpan data settlement?',
          desc: 'Pastikan data yang dimasukkan sudah benar',
          cancelText: 'Cek Kembali',
          confirmText: 'Simpan',
          onCancel: () => Navigator.pop(modalContext, false),
          onConfirm: () => Navigator.pop(modalContext, true),
        );
      },
    );

    if (isConfirm == true) {
      context.read<SettlementBloc>().add(SubmitSettlement());
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocListener<SettlementBloc, SettlementState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.allowLastStep != current.allowLastStep,

      listener: (context, state) async {
        if (state.status == SettlementStatus.successSave) {
          final totalCust = state.detail.fold<int>(
            0,
            (sum, item) => sum + (item.total ?? 0),
          );

          final totalPayment = state.detail.fold<int>(
            0,
            (sum, item) => sum + (item.value ?? 0),
          );

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return CoreBlurDialog(
                title: "Draft Settlement Disimpan",
                message:
                    "Draft settlement untuk Ritase ${state.ritase.toString().replaceAll('.0', '')} berhasil disimpan.\n\nTotal Penumpang: $totalCust orang\nTotal Setoran: ${StringFormatter().idrFormatter(totalPayment)}\n\nApakah Anda ingin langsung mengirimkan (submit) data ini?",
                badgeColor: Colors.green,
                badgeText: 'SUCCESS',
                badgeIcon: Icons.check_circle_outline,
                buttonColor: const Color(0xFF1565C0),
                confirmText: "Ya, Submit",
                onConfirm: () {
                  context.read<SettlementBloc>().add(
                    SubmitWorkflow('Done', state.auditTrailId),
                  );
                  context.go('/portal');
                },
              );
            },
          ).then((value) {
            if (context.mounted) {
              context.go('/portal');
            }
          });
        }

        if (state.status == SettlementStatus.failedSave) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? "Gagal menyimpan"),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state.allowLastStep && state.steps == 2) {
          await _showStep2Confirmation(context);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(color: Colors.grey.shade50),
            child: Column(
              children: [
                CoreHeader(
                  title: 'Submit Settlement',
                  subtitle: 'Isian submit data settlement',
                ),
                BlocBuilder<SettlementBloc, SettlementState>(
                  builder: (context, state) {
                    if (state.status == SettlementStatus.loading) {
                      return Expanded(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.white,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }

                    if (state.status == SettlementStatus.error) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.white,
                        child: Center(
                          child: Text(state.message ?? "Terjadi kesalahan"),
                        ),
                      );
                    }
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.005,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.05,
                                vertical: size.height * 0.01,
                              ),
                              child: BlocBuilder<SettlementBloc, SettlementState>(
                                buildWhen: (previous, current) =>
                                    previous.steps != current.steps ||
                                    previous.totalSteps != current.totalSteps,
                                builder: (context, state) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              state.steps == 1
                                                  ? "Pilih Bus dan Koridor"
                                                  : (state.steps == 2
                                                      ? "Detail Settlement"
                                                      : "Ringkasan"),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                                color: Color(0xFF2D3748),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1565C0).withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              "${state.steps}/${state.totalSteps}",
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF1565C0),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: List.generate(state.totalSteps, (index) {
                                          final isCurrent = index + 1 == state.steps;
                                          final isPassed = index + 1 < state.steps;
                                          return Expanded(
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                left: index == 0 ? 0 : 4,
                                                right: index == state.totalSteps - 1 ? 0 : 4,
                                              ),
                                              height: 3,
                                              decoration: BoxDecoration(
                                                color: isCurrent
                                                    ? const Color(0xFF1565C0)
                                                    : (isPassed
                                                        ? const Color(0xFF1565C0).withValues(alpha: 0.4)
                                                        : Colors.grey.shade200),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            BlocBuilder<SettlementBloc, SettlementState>(
                              buildWhen: (prev, curr) =>
                                  prev.steps != curr.steps,
                              builder: (context, state) {
                                if (state.steps == 1) {
                                  return Expanded(child: WizardFirstStep());
                                } else if (state.steps >= 2 &&
                                    state.steps <= state.totalSteps - 1) {
                                  return Expanded(
                                    child:
                                        BlocListener<
                                          SettlementBloc,
                                          SettlementState
                                        >(
                                          listenWhen: (prev, curr) =>
                                              prev.detailValid !=
                                              curr.detailValid,
                                          listener: (context, state) {
                                            if (state.detailValid == false) {
                                              CoreSnackbar.show(
                                                context,
                                                message:
                                                    "Data belum lengkap, harap isi semua field",
                                                type: SnackbarType.warning,
                                              );
                                            }
                                          },
                                          child: WizardDetailStep(),
                                        ),
                                  );
                                } else {
                                  return Expanded(child: WizardLastStep());
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: BlocBuilder<SettlementBloc, SettlementState>(
                    builder: (context, state) {
                      final isDisabled =
                          (state.steps == 1 &&
                              state.ritase == 0 &&
                              state.status == SettlementStatus.loading) ||
                          (state.steps == 3 && state.document.isEmpty);
 
                      return Row(
                        spacing: 12,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (state.steps != 1)
                            Expanded(
                              child: CoreButton(
                                width: size.width * 0.24,
                                onPressed: () {
                                  if (state.steps > 1) {
                                    if (state.steps == 2 &&
                                        state.activeTabIndex > 0) {
                                      context.read<SettlementBloc>().add(
                                        ChangeTabDetail(
                                          state.activeTabIndex - 1,
                                        ),
                                      );
                                      return;
                                    }
 
                                    context.read<SettlementBloc>().add(
                                      MoveStepWizard(state.steps - 1),
                                    );
                                  }
                                },
                                borderRadius: 12,
                                borderColor: state.steps > 1
                                    ? const Color(0xFF1565C0)
                                    : Colors.grey.shade300,
                                backgroundColor: Colors.transparent,
                                foregroundColor: state.steps > 1
                                    ? const Color(0xFF1565C0)
                                    : Colors.grey.shade400,
                                text: "Sebelumnya",
                              ),
                            ),
 
                          Expanded(
                            child: CoreButton(
                              onPressed: isDisabled
                                  ? null
                                  : () async {
                                      if (state.steps == 2) {
                                        if (!state.allowLastStep) {
                                          final nextIndex =
                                              state.activeTabIndex + 1;
 
                                          context.read<SettlementBloc>().add(
                                            ChangeTabDetail(nextIndex),
                                          );
 
                                          return;
                                        } else {
                                          await _showStep2Confirmation(context);
                                          return;
                                        }
                                      }
 
                                      if (state.steps < state.totalSteps) {
                                        context.read<SettlementBloc>().add(
                                          MoveStepWizard(state.steps + 1),
                                        );
                                      } else {
                                        if (state.idBus != 0 ||
                                            state.idKoridor != 0) {
                                          _showStep3Confirmation(context);
                                        }
                                      }
                                    },
                              width: size.width * 0.24,
                              borderRadius: 12,
                              backgroundColor: isDisabled
                                  ? Colors.grey.shade300
                                  : const Color(0xFF1565C0),
                              foregroundColor: isDisabled
                                  ? Colors.grey.shade500
                                  : Colors.white,
                              text: state.totalSteps == 1
                                  ? "..."
                                  : state.steps < state.totalSteps
                                  ? "Selanjutnya"
                                  : "Save",
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
