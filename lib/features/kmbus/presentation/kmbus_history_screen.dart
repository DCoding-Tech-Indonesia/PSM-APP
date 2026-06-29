import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';
import 'package:psm_mobile/features/kmbus/presentation/bloc/kmbus_event.dart';

import 'bloc/kmbus_bloc.dart';
import 'bloc/kmbus_state.dart';

class KmbusHistoryScreen extends StatefulWidget {
  const KmbusHistoryScreen({super.key});

  @override
  State<KmbusHistoryScreen> createState() => _KmbusHistoryScreenState();
}

class _KmbusHistoryScreenState extends State<KmbusHistoryScreen> {
  String _activeTab = "Semua";

  static const List<String> _tabs = ["Semua", "Awal", "Akhir"];

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    Future.microtask(() {
      if (mounted) {
        context.read<KmbusBloc>().add(PageHistoryLoad());
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<KmbusBloc>();
    bloc.add(PageHistoryLoad());

    await bloc.stream.firstWhere(
      (state) => state.status != KmbusStatus.loading,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            const CoreHeader(
              title: "History KM",
              customBgColor: Colors.white,
              withBorder: true,
            ),

            Container(
              color: Colors.white,
              child: Row(
                children: _tabs.map((tab) {
                  final active = _activeTab == tab;

                  return Expanded(
                    child: InkWell(
                      onTap: () => _changeTab(tab),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 3,
                              color: active ? Colors.blue : Colors.transparent,
                            ),
                          ),
                        ),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              color: active
                                  ? Colors.blue
                                  : Colors.grey.shade500,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            child: Text(tab),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            Expanded(
              child: BlocBuilder<KmbusBloc, KmbusState>(
                builder: (context, state) {
                  if (state.status == KmbusStatus.loading &&
                      state.listKmbus.isEmpty &&
                      state.listKmbusAuditTrail.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _activeTab = _tabs[index];
                      });
                    },
                    itemCount: _tabs.length,
                    itemBuilder: (context, index) {
                      final currentTab = _tabs[index];

                      if (currentTab == "Semua") {
                        final dataList = state.listKmbus;

                        return RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: dataList.isEmpty
                              ? _buildEmptyState()
                              : _buildSemuaListView(dataList),
                        );
                      } else {
                        final dataList = state.listKmbus.where((item) {
                          if (currentTab == "Awal") {
                            return item.titikAwal != null;
                          } else {
                            return item.titikAkhir != null;
                          }
                        }).toList();

                        return RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: dataList.isEmpty
                              ? _buildEmptyState()
                              : _buildKmListView(dataList, currentTab),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 200),
        Center(
          child: Text(
            "Tidak ada data riwayat",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSemuaListView(List<dynamic> dataList) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      itemCount: dataList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = dataList[i];
        print("item");
        print(item);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.code ?? "NO CODE",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.bus?.nomorLambung,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.koridor?.name ?? "Koridor N/A",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Bus: (${item.bus?.platNomor ?? '-'})",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.shade200,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(width: 1, color: Colors.green),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.start, size: 20),
                            Text(item.titikAwal.toString(), style: TextStyle(fontWeight: FontWeight.w700),),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.shade200,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(width: 1, color: Colors.green),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.start, size: 20),
                            Text(item.titikAkhir != null ? item.titikAkhir.toString() : "-", style: TextStyle(fontWeight: FontWeight.w700),),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 0.8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Ritase Ke-${item.ritaseKe.toString()}",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      "${item.totalTempuh ?? 0} km",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKmListView(List<dynamic> dataList, String type) {
    final isAwal = type == "Awal";
    final mainColor = isAwal ? Colors.teal : Colors.deepOrange;

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      itemCount: dataList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = dataList[i];

        final targetKm = isAwal
            ? (item.titikAwal ?? 0)
            : (item.titikAkhir ?? 0);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isAwal
                                      ? Icons.login_rounded
                                      : Icons.logout_rounded,
                                  size: 16,
                                  color: mainColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "KM ${type.toUpperCase()}",
                                  style: TextStyle(
                                    color: mainColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "Ritase ${item.ritaseKe}",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.koridor?.name ?? "-",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Bus: ${item.bus?.nomorLambung ?? '-'} (${item.bus?.platNomor ?? '-'})",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.code ?? "-",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              "$targetKm KM",
                              style: TextStyle(
                                color: mainColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
