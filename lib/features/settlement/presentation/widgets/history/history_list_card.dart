import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travis/core/helper/string_formatter.dart';
import 'package:travis/core/presentations/widgets/core_bottom_modal_verification.dart';
import 'package:travis/core/presentations/widgets/core_button.dart';
import 'package:travis/features/settlement/domain/entities/auditTrail/settlement_task_audit_trail.dart';
import 'package:travis/features/settlement/domain/entities/detailSettlementScreen/detail_screen_args.dart';
import 'package:travis/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:travis/features/settlement/presentation/bloc/settlement_event.dart';

class HistoryListCard extends StatelessWidget {
  const HistoryListCard({super.key, required this.data});

  final SettlementTaskAuditTrail data;

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

  String _getStatusColor(String code) {
    switch (code) {
      case "APR":
        return "Selesai";
      case "DFT":
        return "Pending";
      case "CNC":
        return "Cancel";
      default:
        return code;
    }
  }

  Color _getStatusBgColor(String code) {
    switch (code) {
      case "APR":
        return const Color(0xFFE8F5E9);
      case "DFT":
        return const Color(0xFFFFF3E0);
      case "CNC":
        return const Color(0xFFFFEBEE);
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String code) {
    switch (code) {
      case "APR":
        return const Color(0xFF2E7D32);
      case "DFT":
        return const Color(0xFFE65100);
      case "CNC":
        return const Color(0xFFC62828);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Date + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Color(0xFF718096),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      StringFormatter().formatDateTime2(data.createdDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D3748),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusBgColor(data.status.code),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusTextColor(data.status.code)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _getStatusColor(data.status.code),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _getStatusTextColor(data.status.code),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFEDF2F7),
              ),
            ),

            // Ritase + Corridor Info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    "R${data.ritase}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1565C0),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.directions_bus_rounded,
                        size: 15,
                        color: Color(0xFF1565C0),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.namaKoridor ?? "-",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            Text(
                              data.noPolisi ?? "-",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                                color: Color(0xFF718096),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFEDF2F7),
              ),
            ),

            // Settlement Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.people_rounded,
                        size: 16,
                        color: Color(0xFF1565C0),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Penumpang",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF718096),
                            ),
                          ),
                          Text(
                            data.totalPenumpangKeseluruhan.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.attach_money_rounded,
                        size: 16,
                        color: Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Pendapatan",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF718096),
                              ),
                            ),
                            Text(
                              StringFormatter()
                                  .idrFormatter(
                                    data.totalPendapatanPertitase ?? 0,
                                  )
                                  .replaceAll("Rp ", ""),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: CoreButton(
                    borderRadius: 12,
                    backgroundColor: Colors.white,
                    borderColor: const Color(0xFF1565C0),
                    onPressed: () async {
                      await context.push(
                        '/settlement/detail',
                        extra: DetailScreenArgs(
                          idAuditTrail: data.id,
                          statusName: data.status.name,
                        ),
                      );

                      if (context.mounted) {
                        context.read<SettlementBloc>().add(PageDashboardLoad());
                      }
                    },
                    child: const Text(
                      "Detail",
                      style: TextStyle(
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                if (data.status.code == "DFT")
                  Expanded(
                    child: CoreButton(
                      borderRadius: 12,
                      backgroundColor: const Color(0xFF1565C0),
                      onPressed: () async {
                        await _showSubmitDraftVerification(context, data.id);
                      },
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

