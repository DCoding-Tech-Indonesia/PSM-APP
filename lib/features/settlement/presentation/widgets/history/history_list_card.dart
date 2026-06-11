import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/core/presentations/widgets/core_bottom_modal_verification.dart';
import 'package:psm_mobile/core/presentations/widgets/core_button.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/task_audit_trail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/detailSettlementScreen/detail_screen_args.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';

class HistoryListCard extends StatelessWidget {
  const HistoryListCard({super.key, required this.data});

  final TaskAuditTrail data;

  Future<void> _showSubmitDraftVerification(
    BuildContext context,
    int id,
  ) async {
    final isConfirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return CoreBottomModalVerification(
          title: 'Apakah ingin melakukan submit draft?',
          desc: 'Pastikan data yang dimasukkan sudah benar',
          onCancel: () => Navigator.pop(modalContext, false),
          onConfirm: () => Navigator.pop(modalContext, true),
        );
      },
    );

    if (isConfirm == true) {
      context.read<SettlementBloc>().add(SubmitWorkflow("Done", id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        spacing: 16,
        children: [
          Row(
            spacing: 12,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(width: 1, color: Colors.blueAccent),
                ),
                child: Text(
                  "RIT",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Koridor Haji Agus Salim (TESTING OVERFLOW UI)",
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.blueAccent,
                      ),
                    ),
                    Text(
                      "BA 1945 AG",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            children: [
              Row(
                spacing: 10,
                children: [
                  const Icon(Icons.people, size: 15, color: Colors.grey),
                  Text("10", style: TextStyle(color: Colors.grey)),
                ],
              ),
              Row(
                spacing: 10,
                children: [
                  const Icon(Icons.money, size: 15, color: Colors.grey),
                  Text(
                    StringFormatter().idrFormatter(123500),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          Row(
            spacing: 5,
            children: [
              Expanded(
                child: CoreButton(
                  borderRadius: 12,
                  backgroundColor: Colors.white,
                  borderColor: Colors.blue,
                  onPressed: () async {
                    await context.push(
                      '/settlement/detail',
                      extra: DetailScreenArgs(
                        idAuditTrail: data.id,
                        isDraft: data.status.code != "APR",
                      ),
                    );

                    if (context.mounted) {
                      context.read<SettlementBloc>().add(PageDashboardLoad());
                    }
                  },
                  child: Text(
                    "Lihat Detail",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              if (data.status.code != "APR")
                Expanded(
                  child: CoreButton(
                    borderRadius: 12,
                    backgroundColor: Colors.blue,
                    onPressed: () async {
                      await _showSubmitDraftVerification(context, data.id);
                    },
                    child: Text(
                      "Selesaikan",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
