import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/presentations/widgets/core_date_time_widget.dart';
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

  Future<void> _onRefresh() async {
    final bloc = context.read<SettlementBloc>();

    bloc.add(PageDashboardLoad());

    await bloc.stream.firstWhere(
          (state) => state.status != SettlementStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocBuilder<SettlementBloc, SettlementState>(
      builder: (context, state) {
        final isLoading = state.status == SettlementStatus.loading ||
            state.status == SettlementStatus.initial;

        return Stack(
          children: [
            Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    const SettlementHeader(),
                    const CoreDateTimeWidget(),

                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          children: [
                            const SizedBox(height: 10),

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
                                      Icon(Icons.analytics, color: Colors.purple),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Riwayat Terakhir',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      await context.push('/settlement/history');

                                      if (context.mounted) {
                                        context.read<SettlementBloc>().add(
                                          PageDashboardLoad(),
                                        );
                                      }
                                    },
                                    child: const Row(
                                      children: [
                                        Text(
                                          'Lihat Semua',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 12,
                                          color: Colors.blue,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(
                              height: size.height * 0.4,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    ...state.listTaskAuditTrail
                                        .take(10)
                                        .map(
                                          (item) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: HistorySettlementCard(data: item),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withAlpha(120),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}