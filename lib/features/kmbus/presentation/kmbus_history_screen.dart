import 'package:flutter/material.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';

class KmbusHistoryScreen extends StatefulWidget {
  const KmbusHistoryScreen({super.key});

  @override
  State<KmbusHistoryScreen> createState() => _KmbusHistoryScreenState();
}

class _KmbusHistoryScreenState extends State<KmbusHistoryScreen> {
  String _activeTab = "Semua";

  static const List<String> _tabs = [
    "Semua",
    "Awal",
    "Akhir",
  ];

  late final PageController _pageController;

  final List<Map<String, String>> _dummyData = [
    {"title": "Perjalanan KM Bus 01", "type": "Awal", "time": "06:30 WIB", "route": "Terminal A -> Hub B"},
    {"title": "Perjalanan KM Bus 02", "type": "Akhir", "time": "09:15 WIB", "route": "Hub B -> Terminal C"},
    {"title": "Perjalanan KM Bus 03", "type": "Awal", "time": "13:00 WIB", "route": "Terminal C -> Hub A"},
    {"title": "Perjalanan KM Bus 01", "type": "Akhir", "time": "16:45 WIB", "route": "Hub A -> Terminal A"},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
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

  List<Map<String, String>> _filterData(String tab) {
    if (tab == "Semua") return _dummyData;
    return _dummyData.where((item) => item["type"] == tab).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CoreHeader(
              title: "History KM",
              customBgColor: Colors.white,
              withBorder: true,
            ),

            Row(
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
                            color: active ? Colors.blue : Colors.grey,
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

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _activeTab = _tabs[index];
                  });
                },
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final tab = _tabs[index];
                  final filtered = _filterData(tab);

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: filtered.isEmpty
                        ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text(
                            "Tidak ada data",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                        : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(26, 20, 26, 20),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final item = filtered[i];

                        return Card(
                          elevation: 1,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade100),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item["title"] ?? "",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item["route"] ?? "",
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item["time"] ?? "",
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item["type"] == "Awal"
                                        ? Colors.blue.withValues(alpha: 0.1)
                                        : Colors.purple.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item["type"] ?? "",
                                    style: TextStyle(
                                      color: item["type"] == "Awal"
                                          ? Colors.blue
                                          : Colors.purple,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}