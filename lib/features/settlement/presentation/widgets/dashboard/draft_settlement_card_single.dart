import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/task_audit_trail.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';

class DraftSettlementCardSingle extends StatelessWidget {
  const DraftSettlementCardSingle({super.key, required this.datas});

  final List<TaskAuditTrail> datas;

  @override
  Widget build(BuildContext context) {
    final draftDatas = datas
        .where((task) => task.status.code == 'DFT')
        .toList();

    final TaskAuditTrail? latestDraft = draftDatas.isNotEmpty
        ? draftDatas.last
        : null;

    return BlocBuilder<SettlementBloc, dynamic>(
      builder: (context, state) {
        final isEmpty = latestDraft == null;

        return Container(
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.lightBlue,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(width: 2, color: Colors.blue),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.lightBlue[400],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.bus_alert_sharp,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  !isEmpty ? "Nama Koridor" : "-",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  !isEmpty ? "No. Polisi Unit" : "-",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),

                        if (!isEmpty)
                          GestureDetector(
                            onTap: () async {
                              await context.push(
                                '/settlement/form',
                                extra: latestDraft.id,
                              );

                              if (context.mounted) {
                                context.read<SettlementBloc>().add(
                                  PageDashboardLoad(),
                                );
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Pendapatan",
                                style: TextStyle(color: Colors.white70),
                              ),
                              Text(
                                !isEmpty
                                    ? StringFormatter().idrFormatter(450000)
                                    : "-",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            !isEmpty ? "13.40" : "--:--",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (isEmpty)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: GestureDetector(
                        onTap: () async {
                          await context.push('/settlement/form');

                          if (context.mounted) {
                            context.read<SettlementBloc>().add(
                              PageDashboardLoad(),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text("Input Settlement"),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
