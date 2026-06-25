import 'package:flutter/material.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';

class TimetableHistoryScreen extends StatelessWidget {
  const TimetableHistoryScreen({super.key});

  static const List<String> _tabs = [
    "All",
    "Check-In",
    "Check-Out",
  ];

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<String> activeTabNotifier = ValueNotifier<String>("All");
    final PageController pageController = PageController();

    final List<Map<String, String>> dummyData = [
      {"title": "Absensi Pagi - Kantor A", "type": "Check-In", "time": "08:00 AM"},
      {"title": "Selesai Tugas - Kantor A", "type": "Check-Out", "time": "05:00 PM"},
      {"title": "Absensi Pagi - Wilayah B", "type": "Check-In", "time": "07:45 AM"},
    ];

    List<Map<String, String>> getFilteredData(String tab) {
      if (tab == "All") return dummyData;
      return dummyData.where((item) => item["type"] == tab).toList();
    }

    void changeTab(String tab) {
      final index = _tabs.indexOf(tab);
      if (activeTabNotifier.value == tab) return;

      activeTabNotifier.value = tab;
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CoreHeader(
              title: "History Timetable",
              customBgColor: Colors.white,
              withBorder: true,
            ),

            ValueListenableBuilder<String>(
              valueListenable: activeTabNotifier,
              builder: (context, activeTab, child) {
                return Row(
                  children: _tabs.map((tab) {
                    final bool isActive = activeTab == tab;

                    return Expanded(
                      child: InkWell(
                        onTap: () => changeTab(tab),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 3,
                                color: isActive ? Colors.blue : Colors.transparent,
                              ),
                            ),
                          ),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: TextStyle(
                                color: isActive ? Colors.blue : Colors.grey,
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
                );
              },
            ),

            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (index) {
                  activeTabNotifier.value = _tabs[index];
                },
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final currentTab = _tabs[index];
                  final filteredList = getFilteredData(currentTab);

                  if (filteredList.isEmpty) {
                    return ListView(
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
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final item = filteredList[i];

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["title"] ?? "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item["time"] ?? "",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: item["type"] == "Check-In"
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item["type"] ?? "",
                                  style: TextStyle(
                                    color: item["type"] == "Check-In"
                                        ? Colors.green
                                        : Colors.orange,
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