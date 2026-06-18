import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/core/presentations/widgets/core_bottom_modal_verification.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/task_audit_trail.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';

class DraftSettlementCardSingle extends StatelessWidget {
  const DraftSettlementCardSingle({super.key, required this.datas});

  final List<TaskAuditTrail> datas;

  Future<bool> _showDirectToEditVerification(BuildContext context) async {
    final isConfirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return CoreBottomModalVerification(
          title: 'Apakah ingin melakukan edit draft berikut?',
          onCancel: () => Navigator.pop(modalContext, false),
          onConfirm: () => Navigator.pop(modalContext, true),
        );
      },
    );

    return isConfirm!;
  }

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

        if (!isEmpty) {
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            spacing: 10,
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    draftDatas[0].namaKoridor!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    draftDatas[0].noPolisi!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () async {
                              final direct = _showDirectToEditVerification(
                                context,
                              );

                              if (await direct) {
                                await context.push(
                                  '/settlement/form',
                                  extra: draftDatas[0].id,
                                );

                                if (context.mounted) {
                                  context.read<SettlementBloc>().add(
                                    PageDashboardLoad(),
                                  );
                                }
                              }
                            },
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
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
                                  StringFormatter().idrFormatter(draftDatas[0].totalPendapatanPertitase!),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              StringFormatter().formatHourMinute(
                                draftDatas[0].createdDate,
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return GestureDetector(
            onTap: () async {
              await context.push('/settlement/form');

              if (context.mounted) {
                context.read<SettlementBloc>().add(PageDashboardLoad());
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 2, color: Colors.blueAccent),
              ),
              child: Row(
                children: [
                  Text(
                    "Input Settlement",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
