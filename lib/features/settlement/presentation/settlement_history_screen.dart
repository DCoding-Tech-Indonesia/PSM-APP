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

  static const List<String> _tabs = ["Pending", "Cancel", "Selesai"];

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    Future.microtask(() {
      if (mounted) {
        context.read<SettlementBloc>().add(PageDashboardLoad());
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<SettlementBloc>();
    bloc.add(PageDashboardLoad());

    await bloc.stream.firstWhere(
      (state) => state.status != SettlementStatus.loading,
    );
  }

  void _changeTab(String tab) {
    if (_activeTab == tab) return;

    final index = _tabs.indexOf(tab);
    setState(() {
      _activeTab = tab;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  List<dynamic> _filterData(List<dynamic> data, String tab) {
    if (data.isEmpty) return const [];

    return data.where((item) {
      final code = item.status.code;
      switch (tab) {
        case "Pending":
          return code == "DFT";
        case "Cancel":
          return code == "CNC";
        case "Selesai":
          return code == "APR";
        default:
          return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettlementBloc, SettlementState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == SettlementStatus.failedSave) {
          CoreSnackbar.show(
            context,
            message: "Gagal melakukan submit draft",
            type: SnackbarType.warning,
          );
        }

        if (state.status == SettlementStatus.successSave) {
          CoreSnackbar.show(
            context,
            message: "Draft berhasil di submit",
            type: SnackbarType.success,
          );
          context.read<SettlementBloc>().add(PageDashboardLoad());
        }
      },
        child: Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                const CoreHeader(
                  title: "History Settlement",
                  customBgColor: Colors.white,
                  withBorder: true,
                ),

                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFEDF2F7),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: _tabs.map((tab) {
                      final active = _activeTab == tab;

                      return Expanded(
                        child: InkWell(
                          onTap: () => _changeTab(tab),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tab,
                                  style: TextStyle(
                                    color: active
                                        ? const Color(0xFF1565C0)
                                        : const Color(0xFF718096),
                                    fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: active ? 28 : 0,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1565C0),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                Expanded(
                  child: BlocBuilder<SettlementBloc, SettlementState>(
                    buildWhen: (prev, curr) =>
                        prev.listTaskAuditTrail != curr.listTaskAuditTrail ||
                        prev.status != curr.status,
                    builder: (context, state) {
                      return Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _activeTab = _tabs[index];
                              });
                            },
                            itemCount: _tabs.length,
                            itemBuilder: (context, index) {
                              final tab = _tabs[index];
                              final filtered = _filterData(
                                state.listTaskAuditTrail,
                                tab,
                              );

                              return NotificationListener<ScrollNotification>(
                                onNotification: (ScrollNotification scrollInfo) {
                                  if (scrollInfo.metrics.pixels >=
                                          scrollInfo.metrics.maxScrollExtent - 200 &&
                                      state.status != SettlementStatus.fetching &&
                                      !state.hasReachedMax) {
                                    context.read<SettlementBloc>().add(PageDashboardLoadNextPage());
                                  }
                                  return true;
                                },
                                child: RefreshIndicator(
                                  onRefresh: _onRefresh,
                                  child: filtered.isEmpty
                                      ? ListView(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          children: const [
                                            SizedBox(height: 200),
                                            Center(
                                              child: Text(
                                                "Tidak ada data",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : ListView.separated(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          padding: const EdgeInsets.fromLTRB(
                                            26,
                                            20,
                                            26,
                                            20,
                                          ),
                                          itemCount: filtered.length + (state.status == SettlementStatus.fetching ? 1 : 0),
                                          separatorBuilder: (_, _) =>
                                              const SizedBox(height: 12),
                                          itemBuilder: (context, i) {
                                            if (i == filtered.length) {
                                              return const Padding(
                                                padding: EdgeInsets.symmetric(vertical: 16),
                                                child: Center(
                                                  child: SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: CircularProgressIndicator(strokeWidth: 2.5),
                                                  ),
                                                ),
                                              );
                                            }
                                            return HistoryListCard(
                                              data: filtered[i],
                                            );
                                          },
                                        ),
                                ),
                              );
                            },
                          ),

                          if (state.status == SettlementStatus.loading)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withValues(alpha: .15),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
