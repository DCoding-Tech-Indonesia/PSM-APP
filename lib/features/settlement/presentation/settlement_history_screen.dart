import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';
import 'package:psm_mobile/core/presentations/widgets/core_snackbar.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/history/history_list_card.dart';

import 'bloc/settlement_bloc.dart';
import 'bloc/settlement_event.dart';

class SettlementHistoryScreen extends StatefulWidget {
  const SettlementHistoryScreen({super.key});

  @override
  State<SettlementHistoryScreen> createState() =>
      _SettlementHistoryScreenState();
}

class _SettlementHistoryScreenState extends State<SettlementHistoryScreen> {
  String _activeTab = "Pending";

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<SettlementBloc>().add(PageDashboardLoad());
    });
  }

  void _changeTab(String tab) {
    if (_activeTab == tab) return;

    setState(() {
      _activeTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettlementBloc, SettlementState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == SettlementStatus.failedSave) {
          CoreSnackbar.show(
            context,
            message:
            "Gagal melakukan submit draft",
            type: SnackbarType.warning,
          );
        }
        if (state.status == SettlementStatus.successSave) {
          CoreSnackbar.show(
            context,
            message:
            "Draft berhasil di submit",
            type: SnackbarType.success,
          );
          context.read<SettlementBloc>().add(PageDashboardLoad());
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<SettlementBloc, SettlementState>(
            buildWhen: (prev, curr) => prev.status != curr.status,
            builder: (context, state) {
              return Stack(
                children: [
                  Column(
                    children: [
                      CoreHeader(
                        title: 'History Settlement',
                        customBgColor: Colors.white,
                        withBorder: true,
                      ),

                      DefaultTextStyle(
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _changeTab("Pending"),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 2,
                                        color: _activeTab == "Pending"
                                            ? Colors.blue
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Pending",
                                      style: TextStyle(
                                        color: _activeTab == "Pending"
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => _changeTab("Selesai"),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 2,
                                        color: _activeTab == "Selesai"
                                            ? Colors.blue
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Selesai",
                                      style: TextStyle(
                                        color: _activeTab == "Selesai"
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: GestureDetector(
                          onHorizontalDragEnd: (details) {
                            final velocity = details.primaryVelocity ?? 0;

                            if (velocity < -100) {
                              _changeTab("Selesai");
                            } else if (velocity > 100) {
                              _changeTab("Pending");
                            }
                          },
                          child: BlocBuilder<SettlementBloc, SettlementState>(
                            builder: (context, state) {
                              final filteredList = state.listTaskAuditTrail.where((item) {
                                final statusCode = item.status.code;

                                if (_activeTab == "Pending") {
                                  return statusCode != "APR";
                                }

                                return statusCode == "APR";
                              }).toList();

                              if (filteredList.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "Tidak ada data",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                );
                              }

                              return SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: 26),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),

                                    ...filteredList.map(
                                          (item) => Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: HistoryListCard(
                                          data: item,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (state.status == SettlementStatus.loading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: .15),
                        child: const Center(
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),

                ],
              );
            }
          ),
        ),
      ),
    );
  }
}