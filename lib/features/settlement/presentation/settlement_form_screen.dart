import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/presentations/widgets/widgets.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/form/wizard_detail_step.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/form/wizard_first_step.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/form/wizard_last_step.dart';
import 'package:step_progress/step_progress.dart';

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

  void _showSubmitDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("Konfirmasi Submit"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Apakah anda ingin melakukan submit untuk data yang sudah dimasukkan?",
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Reason",
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.pop();
              },
              child: const Text("Tidak"),
            ),

            ElevatedButton(
              onPressed: () async {
                final note = controller.text;

                Navigator.pop(dialogContext);

                context.read<SettlementBloc>().add(SubmitWorkflow(note));

                showModalBottomSheet(
                  context: context,
                  isDismissible: false,
                  enableDrag: false,
                  builder: (_) => const CoreBottomModalAlert(
                    success: true,
                    message: 'Berhasil submit data',
                  ),
                );

                await Future.delayed(const Duration(seconds: 1));

                if (context.mounted) {
                  Navigator.pop(context); // tutup bottom sheet
                  context.pop(); // kembali ke halaman sebelumnya
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showStep2Confirmation(BuildContext context) async {
    final isConfirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("Konfirmasi"),
          content: const Text(
            "Apakah anda sudah melengkapi input detail settlement dengan benar?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Belum"),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(dialogContext, true);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: BoxBorder.all(width: .6, color: Colors.grey),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text("Sudah"),
              ),
            ),
          ],
        );
      },
    );

    if (isConfirm == true) {
      context.read<SettlementBloc>().add(MoveStepWizard(3));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocListener<SettlementBloc, SettlementState>(
      listenWhen: (previous, current) => previous.status != current.status,

      listener: (context, state) {
        if (state.status == SettlementStatus.successSave) {
          _showSubmitDialog(context);
        }

        if (state.status == SettlementStatus.failedSave) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? "Gagal menyimpan"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<SettlementBloc, SettlementState>(
            builder: (context, state) {
              if (state.status == SettlementStatus.loading) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                  child: Center(child: CircularProgressIndicator()),
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
              return Container(
                decoration: BoxDecoration(color: Colors.grey.shade50),
                child: Column(
                  children: [
                    CoreHeader(
                      title: 'Submit Settlement',
                      subtitle: 'Settlement',
                      customBgColor: Colors.white,
                      withBorder: true,
                    ),
                    Expanded(
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
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Data belum lengkap, harap isi semua field",
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
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
                                        : const Color.fromARGB(
                                            255,
                                            143,
                                            141,
                                            141,
                                          ),
                                    backgroundColor: state.steps > 1
                                        ? Colors.transparent
                                        : const Color.fromARGB(
                                            255,
                                            143,
                                            141,
                                            141,
                                          ),
                                    foregroundColor: state.steps > 1
                                        ? const Color(0xFF1E3C72)
                                        : Colors.white,
                                    text: "Back",
                                  ),
                                ),
                              Expanded(
                                child: CoreButton(
                                  onPressed: () async {
                                    if (state.steps == 1 && state.ritase == 0) {
                                      return;
                                    }

                                    if (state.steps == 2) {
                                      final nextIndex =
                                          state.activeTabIndex + 1;

                                      final hasNextTab =
                                          nextIndex <
                                          state.referencePayment.length;

                                      context.read<SettlementBloc>().add(
                                        ChangeTabDetail(nextIndex),
                                      );

                                      if (hasNextTab) {
                                        return;
                                      }

                                      if (state.detailValid) {
                                        await _showStep2Confirmation(context);
                                      }
                                      return;
                                    }

                                    if (state.steps < state.totalSteps) {
                                      context.read<SettlementBloc>().add(
                                        MoveStepWizard(state.steps + 1),
                                      );
                                    } else {
                                      if (state.idBus != 0 ||
                                          state.idKoridor != 0) {
                                        context.read<SettlementBloc>().add(
                                          SubmitSettlement(),
                                        );
                                      }
                                    }
                                  },
                                  width: size.width * 0.24,
                                  borderRadius: 15,
                                  backgroundColor:
                                      (state.steps == 1 && state.ritase == 0)
                                      ? const Color(0xFF5E5E5E)
                                      : state.steps == state.totalSteps
                                      ? Colors.green
                                      : const Color(0xFF1E3C72),
                                  foregroundColor: Colors.white,
                                  text: state.steps < state.totalSteps
                                      ? "Next"
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
              );
            },
          ),
        ),
      ),
    );
  }
}
