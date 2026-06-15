import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/presentations/widgets/core_bottom_modal_verification.dart';
import 'package:psm_mobile/core/presentations/widgets/core_snackbar.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';
import 'package:psm_mobile/features/settlement/domain/entities/successDraftScreen/settlement_success_args.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/form/wizard_detail_step.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/form/wizard_first_step.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/form/wizard_last_step.dart';

class SettlementFormScreen extends StatefulWidget {
  const SettlementFormScreen({super.key, required this.idAuditTrail});

  final int? idAuditTrail;

  @override
  State<SettlementFormScreen> createState() => _SettlementFormScreenState();
}

class _SettlementFormScreenState extends State<SettlementFormScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SettlementBloc>().add(PageInputLoad(widget.idAuditTrail));
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

          context.replace(
            '/settlement/success-draft',
            extra: SettlementSuccessArgs(
              idAuditTrail: state.auditTrailId,
              totalCust: totalCust,
              totalPayment: totalPayment,
              koridorName: state.namaKoridor,
              noPol: state.noUnit,
              ritase: state.ritase.toString(),
            ),
          );
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
                  customBgColor: Colors.white,
                  withBorder: true,
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
                                    spacing: 8,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Langkah ${state.steps} dari ${state.totalSteps}",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      if (state.steps == 1)
                                        Text(
                                          "Pilih Bus dan Koridor",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                          ),
                                        ),
                                      if (state.steps == 2)
                                        Text(
                                          "Detail Settlement",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                          ),
                                        ),
                                      if (state.steps == 3)
                                        Text(
                                          "Summary",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                          ),
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
                  padding: const EdgeInsets.fromLTRB(23, 16, 23, 25),
                  child: BlocBuilder<SettlementBloc, SettlementState>(
                    builder: (context, state) {
                      return Row(
                        spacing: 10,
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
                                borderRadius: 15,
                                borderColor: state.steps > 1
                                    ? const Color(0xFF1E3C72)
                                    : const Color.fromARGB(255, 143, 141, 141),
                                backgroundColor: state.steps > 1
                                    ? Colors.transparent
                                    : const Color.fromARGB(255, 143, 141, 141),
                                foregroundColor: state.steps > 1
                                    ? const Color(0xFF1E3C72)
                                    : Colors.white,
                                text: "Sebelumnya",
                              ),
                            ),
                          Expanded(
                            child: CoreButton(
                              onPressed: () async {
                                if (state.steps == 1 && state.ritase == 0) {
                                  return;
                                }

                                if (state.steps == 2) {
                                  if (!state.allowLastStep) {
                                    final nextIndex = state.activeTabIndex + 1;

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
                              backgroundColor:
                                  (state.steps == 1 && state.ritase == 0)
                                  ? const Color(0xFF5E5E5E)
                                  : const Color(0xFF1E3C72),
                              foregroundColor: Colors.white,
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
