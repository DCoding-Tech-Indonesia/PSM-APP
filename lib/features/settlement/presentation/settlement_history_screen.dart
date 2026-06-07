import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/core/presentations/widgets/core_button.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';

import 'bloc/settlement_bloc.dart';
import 'bloc/settlement_event.dart';

class SettlementHistoryScreen extends StatefulWidget {
  const SettlementHistoryScreen({super.key});

  @override
  State<SettlementHistoryScreen> createState() =>
      _SettlementHistoryScreenState();
}

class _SettlementHistoryScreenState extends State<SettlementHistoryScreen> {
  late String _activeTab = "Pending";

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<SettlementBloc>().add(PageDashboardLoad());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CoreHeader(
              title: 'History Settlement',
              customBgColor: Colors.white,
              withBorder: true,
            ),
            DefaultTextStyle(
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontSize: 16,
              ),
              child: Row(
                children: [
                  Expanded(
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
                  Expanded(
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
                ],
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "08 Juni 2026",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            border: Border.all(
                              width: 2,
                              color: Colors.blueAccent,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Icon(
                            Icons.calendar_month_outlined,
                            color: Colors.blueAccent,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        spacing: 16,
                        children: [
                          Row(
                            spacing: 12,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(8), border: Border.all(width: 1, color: Colors.yellowAccent)),
                                child: Text("RIT", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.redAccent),),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Koridor Haji Agus Salim (TESTING OVERFLOW UI)",
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    Text(
                                      "BA 1945 AG",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Row(
                                spacing: 10,
                                children: [
                                  const Icon(
                                    Icons.people,
                                    size: 15,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    "10",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              Row(
                                spacing: 10,
                                children: [
                                  const Icon(
                                    Icons.money,
                                    size: 15,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    StringFormatter().idrFormatter(123500),
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            spacing: 5,
                            children: [
                              Expanded(
                                child: CoreButton(
                                  borderRadius: 12,
                                  backgroundColor: Colors.white,
                                  borderColor: Colors.blue,
                                  onPressed: () {},
                                  child: Text(
                                    "Lihat Detail",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: CoreButton(
                                  borderRadius: 12,
                                  backgroundColor: Colors.blue,
                                  onPressed: () {},
                                  child: Text(
                                    "Selesaikan",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        spacing: 16,
                        children: [
                          Row(
                            spacing: 12,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(8), border: Border.all(width: 1, color: Colors.yellowAccent)),
                                child: Text("RIT", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.redAccent),),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Koridor Haji Agus Salim",
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    Text(
                                      "BA 1945 AG",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Row(
                                spacing: 10,
                                children: [
                                  const Icon(
                                    Icons.people,
                                    size: 15,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    "10",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              Row(
                                spacing: 10,
                                children: [
                                  const Icon(
                                    Icons.money,
                                    size: 15,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    StringFormatter().idrFormatter(123500),
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            spacing: 5,
                            children: [
                              Expanded(
                                child: CoreButton(
                                  borderRadius: 12,
                                  backgroundColor: Colors.white,
                                  borderColor: Colors.blue,
                                  onPressed: () {},
                                  child: Text(
                                    "Lihat Detail",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: CoreButton(
                                  borderRadius: 12,
                                  backgroundColor: Colors.blue,
                                  onPressed: () {},
                                  child: Text(
                                    "Selesaikan",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }
}
