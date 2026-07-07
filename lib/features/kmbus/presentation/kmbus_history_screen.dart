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
              child: BlocBuilder<KmbusBloc, KmbusState>(
                builder: (context, state) {
                  if (state.status == KmbusStatus.loading &&
                      state.listKmbus.isEmpty) {
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
                              : _buildSemuaListView(dataList, filterType: currentTab),
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

  Widget _buildSemuaListView(List<dynamic> dataList, {String? filterType}) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      itemCount: dataList.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = dataList[i];

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
                // Header: Date | Unit Badge
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
                          item.tanggalKm,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2D3748),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        "${item.bus?.platNomor ?? '-'} • ${item.bus?.nomorLambung ?? '-'}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4A5568),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 1, color: Color(0xFFEDF2F7)),
                ),
                 // Timeline KM Route / Single KM Dashboard Callout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: (filterType == "Awal" || filterType == "Akhir")
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  filterType == "Awal"
                                      ? Icons.play_arrow_rounded
                                      : Icons.flag_rounded,
                                  color: filterType == "Awal"
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFC62828),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  filterType == "Awal"
                                      ? "KM Keberangkatan (Awal)"
                                      : "KM Kedatangan (Akhir)",
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF4A5568),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              filterType == "Awal"
                                  ? "${item.titikAwal} KM"
                                  : (item.titikAkhir != null ? "${item.titikAkhir} KM" : "-"),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: filterType == "Awal"
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFC62828),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timeline indicator line
                            Column(
                              children: [
                                const Icon(Icons.circle, size: 8, color: Color(0xFF2E7D32)),
                                Container(
                                  width: 1.5,
                                  height: 28,
                                  color: const Color(0xFFE2E8F0),
                                ),
                                const Icon(Icons.circle, size: 8, color: Color(0xFFC62828)),
                              ],
                            ),
                            const SizedBox(width: 14),
                            // KM Info Texts
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "KM Awal (Mulai)",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF718096),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "${item.titikAwal} KM",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "KM Akhir (Selesai)",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF718096),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        item.titikAkhir != null ? '${item.titikAkhir} KM' : '-',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: item.titikAkhir != null
                                              ? const Color(0xFFC62828)
                                              : const Color(0xFFA0AEC0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 1, color: Color(0xFFEDF2F7)),
                ),

                // Footer: Corridor + Total Distance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                            child: Text(
                              item.koridor?.name ?? "Koridor N/A",
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF1565C0).withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        "Total: ${item.totalTempuh ?? 0} km",
                        style: const TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
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
}
