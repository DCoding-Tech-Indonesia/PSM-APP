import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/wizard_first_step.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/wizard_detail_step.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/wizard_last_step.dart';

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
              onPressed: () {
                final note = controller.text;

                Navigator.pop(dialogContext);

                context.read<SettlementBloc>().add(
                  SubmitWorkflow(note),
                );
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          centerTitle: false,
          title: const Text("Submit Settlement"),
        ),
        body: BlocBuilder<SettlementBloc, SettlementState>(
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
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BlocBuilder<SettlementBloc, SettlementState>(
                              buildWhen: (previous, current) =>
                                  previous.steps != current.steps,
                              builder: (context, state) {
                                return Text(
                                  "Step ${state.steps} of ${state.totalSteps}",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                );
                              },
                            ),
                            SizedBox(height: 20),
                            BlocBuilder<SettlementBloc, SettlementState>(
                              buildWhen: (prev, curr) =>
                                  prev.steps != curr.steps,
                              builder: (context, state) {
                                if (state.steps == 1) {
                                  return Expanded(child: WizardFirstStep());
                                } else if (state.steps >= 2 &&
                                    state.steps <= state.totalSteps - 1) {
                                  return Expanded(
                                    child: WizardDetailStep(
                                      currStep: state.steps,
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
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(23, 0, 23, 25),
                    child: BlocBuilder<SettlementBloc, SettlementState>(
                      builder: (context, state) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () => {
                                if (state.steps > 1)
                                  {
                                    context.read<SettlementBloc>().add(
                                      MoveStepWizard(state.steps - 1),
                                    ),
                                  },
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: state.steps > 1
                                    ? const Color(0xFF1E3C72)
                                    : const Color(0xFF5E5E5E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                shadowColor: const Color(
                                  0xFF1E3C72,
                                ).withValues(alpha: 0.4),
                              ),
                              child: Text("Back"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (state.steps == 1 &&
                                    (state.idBus == 0 ||
                                        state.idKoridor == 0)) {
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                ((state.steps == 1 && (state.idBus == 0 || state.idKoridor == 0)))
                                    ? const Color(0xFF5E5E5E)
                                    : const Color(0xFF1E3C72),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                shadowColor: const Color(
                                  0xFF1E3C72,
                                ).withValues(alpha: 0.4),
                              ),
                              child: Text(
                                state.steps < state.totalSteps
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
    );
  }
}
