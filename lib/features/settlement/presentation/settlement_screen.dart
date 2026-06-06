import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/presentations/widgets/core_blur_dialog.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/dashboard/draft_settlement_card_single.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/history_settlement_card.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/settlement_header.dart';

import 'bloc/settlement_bloc.dart';
import 'bloc/settlement_event.dart';

class SettlementScreen extends StatefulWidget {
  const SettlementScreen({super.key});

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<SettlementBloc>().add(PageDashboardLoad());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SettlementBloc, SettlementState>(
          builder: (context, state) {
            return Column(
              children: [
                const SettlementHeader(),

                SizedBox(height: 18),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      final bloc = context.read<SettlementBloc>();

                      bloc.add(PageDashboardLoad());

                      await bloc.stream.firstWhere(
                            (state) =>
                        state.status != SettlementStatus.loading,
                      );
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height -
                              MediaQuery.of(context).padding.top -
                              kToolbarHeight,
                        ),
                        child: Column(
                          children: [
                            DraftSettlementCardSingle(
                              datas: state.listTaskAuditTrail,
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 16,
                              ),
                              margin: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey[300]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Column(
                                spacing: 20,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.analytics,
                                          color: Colors.purple),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Statistik Bulan Ini',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            "10",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 20,
                                            ),
                                          ),
                                          Text(
                                            "Approved",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "3",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 20,
                                            ),
                                          ),
                                          Text(
                                            "Rejected",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "1",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 20,
                                            ),
                                          ),
                                          Text(
                                            "Pending",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 5,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Riwayat Terakhir',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      showCoreInfoDialog(
                                        context,
                                        "TEST",
                                        "TEST",
                                      );
                                    },
                                    child: const Row(
                                      children: [
                                        Text(
                                          'Lihat Semua',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics:
                                const NeverScrollableScrollPhysics(),
                                itemCount:
                                state.listTaskAuditTrail.length,
                                itemBuilder: (context, index) {
                                  final taskAuditTrail =
                                  state.listTaskAuditTrail[index];

                                  return HistorySettlementCard(
                                    data: taskAuditTrail,
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}