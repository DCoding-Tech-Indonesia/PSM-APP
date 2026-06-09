import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/core/presentations/widgets/core_button.dart';
import 'package:psm_mobile/core/presentations/widgets/core_snackbar.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';

import 'bloc/settlement_event.dart';

class SettlementSuccessSubmitDraftScreen extends StatefulWidget {
  const SettlementSuccessSubmitDraftScreen({
    super.key,
    required this.idAuditTrail,
    required this.totalCust,
    required this.totalPayment,
    required this.koridorName,
    required this.noPol,
    required this.ritase,
  });

  final int? idAuditTrail;
  final int? totalCust;
  final int? totalPayment;
  final String? koridorName;
  final String? noPol;
  final String? ritase;

  @override
  State<SettlementSuccessSubmitDraftScreen> createState() =>
      _SettlementSuccessSubmitDraftScreenState();
}

class _SettlementSuccessSubmitDraftScreenState
    extends State<SettlementSuccessSubmitDraftScreen> {
  Timer? _timer;
  int _remainingSeconds = 10;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();

        if (mounted) {
          context.pop();
        }
        return;
      }

      setState(() {
        _remainingSeconds--;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocConsumer<SettlementBloc, SettlementState>(
      listener: (context, state) {
        if (state.status == SettlementStatus.failedSave) {
          CoreSnackbar.show(
            context,
            message: state.message ?? 'Gagal melakukan approve data draft.',
            type: SnackbarType.failed,
          );
        }

        if (state.status == SettlementStatus.successSave) {
          CoreSnackbar.show(
            context,
            message: state.message ?? 'Berhasil approve data draft.',
            type: SnackbarType.success,
          );

          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              context.pop();
            }
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 200,
                            child: Lottie.asset(
                              'assets/lottie/bus.json',
                              animate: true,
                              repeat: true,
                              reverse: false,
                            ),
                          ),
                          Container(
                            width: size.width * .65,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.5,
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Ritase ke : ${widget.ritase!.toString()}",
                                ),
                                const Divider(),
                                Text(widget.koridorName!),
                                Text(widget.noPol!),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(widget.totalCust!.toString()),
                                        Text(" Total Penumpang"),
                                      ],
                                    ),
                                    Icon(Icons.people, size: 20),
                                  ],
                                ),
                                Text(StringFormatter().idrFormatter(132500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Column(
                        spacing: 8,
                        children: [
                          CoreButton(
                            width: double.infinity,
                            onPressed: () {
                              _stopTimer();
                              context.pop();
                            },
                            backgroundColor: Colors.white,
                            borderColor: Colors.blue,
                            child: Text(
                              "Kembali ($_remainingSeconds)",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          BlocBuilder<SettlementBloc, SettlementState>(
                            builder: (context, state) {
                              return CoreButton(
                                width: double.infinity,
                                onPressed: () {
                                  _stopTimer();

                                  context.read<SettlementBloc>().add(
                                    SubmitWorkflow('Done', widget.idAuditTrail!),
                                  );
                                },
                                child: const Text(
                                  "Submit Draft",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (state.status == SettlementStatus.loading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
