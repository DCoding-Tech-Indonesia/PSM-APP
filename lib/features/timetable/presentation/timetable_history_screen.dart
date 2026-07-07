import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_data.dart';
import 'package:psm_mobile/features/timetable/presentation/bloc/timetable_bloc.dart';
import 'package:psm_mobile/features/timetable/presentation/bloc/timetable_event.dart';
import 'package:psm_mobile/features/timetable/presentation/bloc/timetable_state.dart';

class TimetableHistoryScreen extends StatefulWidget {
  const TimetableHistoryScreen({super.key});

  @override
  State<TimetableHistoryScreen> createState() => _TimetableHistoryScreenState();
}

class _TimetableHistoryScreenState extends State<TimetableHistoryScreen> {
  String _activeTab = "All";

  static const List<String> _tabs = ["All", "Berangkat", "Datang"];

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    Future.microtask(() {
      if (mounted) {
        context.read<TimetableBloc>().add(PageHistoryLoad());
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<TimetableBloc>();

    bloc.add(PageHistoryLoad());

    await bloc.stream.firstWhere(
      (state) => state.status != TimetableStatus.loading,
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
              title: "History Timetable",
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
              child: BlocBuilder<TimetableBloc, TimetableState>(
                builder: (context, state) {
                  if (state.status == TimetableStatus.loading &&
                      state.listTimetable.isEmpty) {
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

                      List<TimetableData> dataList;

                      if (currentTab == "All") {
                        dataList = state.listTimetable;

                        return RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: dataList.isEmpty
                              ? _buildEmptyState()
                              : _buildTimetableList(dataList),
                        );
                      }

                      if (currentTab == "Berangkat") {
                        dataList = state.listTimetable.where((e) {
                          return e.jamBerangkat.trim().isNotEmpty;
                        }).toList();

                        return RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: dataList.isEmpty
                              ? _buildEmptyState()
                              : _buildTimetableList(dataList, filterType: "Berangkat"),
                        );
                      }

                      dataList = state.listTimetable.where((e) {
                        return e.jamDatang.trim().isNotEmpty;
                      }).toList();

                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: dataList.isEmpty
                            ? _buildEmptyState()
                            : _buildTimetableList(dataList, filterType: "Datang"),
                      );
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

   Widget _buildTimetableList(List<TimetableData> dataList, {String? filterType}) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: dataList.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final data = dataList[index];

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
                // Header: Calendar Icon + Date | Bus Unit Badge
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
                          data.tanggal,
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
                        "${data.platNomor} • ${data.nomorLambung}",
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

                // Timeline Route / Single Time Dashboard Callout
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: (filterType == "Berangkat" || filterType == "Datang")
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  filterType == "Berangkat"
                                      ? Icons.play_arrow_rounded
                                      : Icons.flag_rounded,
                                  color: filterType == "Berangkat"
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFC62828),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  filterType == "Berangkat"
                                      ? "Berangkat (Check-In)"
                                      : "Datang (Check-Out)",
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF4A5568),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              filterType == "Berangkat"
                                  ? (data.jamBerangkat.trim().isEmpty
                                      ? "--:--:--"
                                      : StringFormatter().formatLongTimeToMedium(data.jamBerangkat))
                                  : (data.jamDatang.trim().isEmpty
                                      ? "--:--:--"
                                      : StringFormatter().formatLongTimeToMedium(data.jamDatang)),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: filterType == "Berangkat"
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
                            // Time Info Texts
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Berangkat (Check-In)",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF718096),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        data.jamBerangkat.trim().isEmpty
                                            ? "--:--:--"
                                            : StringFormatter().formatLongTimeToMedium(data.jamBerangkat),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: data.jamBerangkat.trim().isEmpty
                                              ? const Color(0xFFA0AEC0)
                                              : const Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Datang (Check-Out)",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF718096),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        data.jamDatang.trim().isEmpty
                                            ? "--:--:--"
                                            : StringFormatter().formatLongTimeToMedium(data.jamDatang),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: data.jamDatang.trim().isEmpty
                                              ? const Color(0xFFA0AEC0)
                                              : const Color(0xFFC62828),
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

                // Footer: Corridor + Ritase
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
                              data.namaKoridor,
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
                        "Ritase ${data.ritaseKe.toString().replaceAll('.0', '')}",
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
