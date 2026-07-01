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
  State<TimetableHistoryScreen> createState() =>
      _TimetableHistoryScreenState();
}

class _TimetableHistoryScreenState extends State<TimetableHistoryScreen> {
  String _activeTab = "All";

  static const List<String> _tabs = [
    "All",
    "Check-In",
    "Check-Out",
  ];

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
                              color: active
                                  ? Colors.blue
                                  : Colors.transparent,
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
              child: BlocBuilder<TimetableBloc, TimetableState>(
                builder: (context, state) {
                  if (state.status == TimetableStatus.loading &&
                      state.listTimetable.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
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

                      if (currentTab == "Check-In") {
                        dataList = state.listTimetable.where((e) {
                          return e.jamBerangkat.trim().isNotEmpty;
                        }).toList();

                        return RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: dataList.isEmpty
                              ? _buildEmptyState()
                              : _buildHistoryByType(dataList, true),
                        );
                      }

                      dataList = state.listTimetable.where((e) {
                        return e.jamDatang.trim().isNotEmpty;
                      }).toList();

                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: dataList.isEmpty
                            ? _buildEmptyState()
                            : _buildHistoryByType(dataList, false),
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
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimetableList(List<TimetableData> dataList) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: dataList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final data = dataList[index];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Header
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data.tanggal,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "${data.platNomor} (${data.nomorLambung})",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const Divider(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _buildTimeCard(
                        title: "Berangkat",
                        value: data.jamBerangkat,
                        color: Colors.green,
                        background: Colors.greenAccent.shade100,
                        iconColor: Colors.black,
                        textColor: Colors.black,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildTimeCard(
                        title: "Datang",
                        value: data.jamDatang,
                        color: Colors.red,
                        background: Colors.redAccent.shade100,
                        iconColor: Colors.white,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data.namaKoridor,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Ritase ${data.ritaseKe.toString()}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
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

  Widget _buildTimeCard({
    required String title,
    required String value,
    required Color color,
    required Color background,
    required Color iconColor,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 5),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: iconColor,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  value.trim().isEmpty
                      ? "--:--:--"
                      : StringFormatter()
                      .formatLongTimeToMedium(value),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryByType(
      List<TimetableData> dataList,
      bool isCheckIn,
      ) {
    final mainColor = isCheckIn ? Colors.green : Colors.red;

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: dataList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final data = dataList[index];

        final jam = isCheckIn
            ? data.jamBerangkat
            : data.jamDatang;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
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
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isCheckIn
                                      ? Icons.login_rounded
                                      : Icons.logout_rounded,
                                  color: mainColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isCheckIn
                                      ? "CHECK-IN"
                                      : "CHECK-OUT",
                                  style: TextStyle(
                                    color: mainColor,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              data.tanggal,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          data.namaKoridor,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "${data.platNomor} (${data.nomorLambung})",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const Divider(height: 22),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Ritase ${data.ritaseKe.toString()}",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: mainColor.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: Text(
                                jam.isEmpty
                                    ? "--:--:--"
                                    : StringFormatter()
                                    .formatLongTimeToMedium(
                                  jam,
                                ),
                                style: TextStyle(
                                  color: mainColor,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
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