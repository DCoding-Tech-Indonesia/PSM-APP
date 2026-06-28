import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/settlement_task_audit_trail.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_event.dart';

class DraftSettlementCard extends StatefulWidget {
  const DraftSettlementCard({super.key, required this.datas});

  final List<SettlementTaskAuditTrail> datas;

  @override
  State<DraftSettlementCard> createState() => _DraftSettlementCardState();
}

class _DraftSettlementCardState extends State<DraftSettlementCard> {
  final PageController _pageController = PageController();

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final draftDatas = widget.datas
        .where((task) => task.status.code == 'DFT')
        .toList();

    final totalItems = draftDatas.isEmpty ? 1 : draftDatas.length + 1;

    return SizedBox(
      height: 180,
      child: Row(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: totalItems,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final bool isInputSettlementCard =
                    draftDatas.isEmpty || index == draftDatas.length;

                return _buildCard(
                  context,
                  data: isInputSettlementCard ? null : draftDatas[index],
                );
              },
            ),
          ),

          if (draftDatas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  totalItems,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentIndex == index
                          ? Colors.lightBlue
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {SettlementTaskAuditTrail? data}) {
    final isInputSettlement = data == null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.lightBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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

                        DefaultTextStyle(
                          style: const TextStyle(color: Colors.white),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                !isInputSettlement ? "Nama Koridor" : "-",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                !isInputSettlement ? "No. Polisi Unit" : "-",
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (!isInputSettlement)
                      GestureDetector(
                        onTap: () async {
                          await context.push(
                            '/settlement/form',
                            extra: data.id,
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
                  child: DefaultTextStyle(
                    style: const TextStyle(color: Colors.white),
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
                              !isInputSettlement
                                  ? StringFormatter().idrFormatter(450000)
                                  : "-",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(!isInputSettlement ? "13.40" : "--:--"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (isInputSettlement)
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
                        context.read<SettlementBloc>().add(PageDashboardLoad());
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
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
  }
}
