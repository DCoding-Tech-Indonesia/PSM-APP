import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';

import 'bloc/settlement_bloc.dart';
import 'bloc/settlement_event.dart';

class SettlementScreen extends StatefulWidget {
  const SettlementScreen({super.key});

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: false,
        title: Text("Settlement"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BlocBuilder<SettlementBloc, SettlementState>(
              builder: (context, state) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 16,
                        ),
                        child: Column(
                          spacing: 18,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  spacing: 10,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.lightBlue[400],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.bus_alert_sharp,
                                        color: Colors.white,
                                      ),
                                    ),
                                    DefaultTextStyle(
                                      style: TextStyle(color: Colors.white),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            state.listTaskAuditTrail.isNotEmpty
                                                ? "Nama Halte"
                                                : "-",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            state.listTaskAuditTrail.isNotEmpty
                                                ? "No. Polisi Unit"
                                                : "-",
                                            style: TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (state.listTaskAuditTrail[0].id
                                            .toString() !=
                                        '') {
                                      context.push(
                                        '/settlement/form',
                                        extra: state.listTaskAuditTrail[0].id,
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.lightBlue[400],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DefaultTextStyle(
                                style: TextStyle(color: Colors.white),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Total Pendapatan",
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        Text(
                                          state.listTaskAuditTrail.isNotEmpty
                                              ? StringFormatter().idrFormatter(
                                                  450000,
                                                )
                                              : "-",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        state.listTaskAuditTrail.isNotEmpty
                                            ? Text("13.40")
                                            : Text("--:--"),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (state.listTaskAuditTrail.isEmpty)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  context.push('/settlement/form');
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
                                  child: Text("Input Settlement"),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 1, color: Color(0xFFBDBDBD)),
              ),
              child: Column(
                spacing: 20,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      Icon(Icons.analytics_outlined, size: 20),
                      Text(
                        "Statistik Bulan Ini",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            "10",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          Text("Approved"),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "3",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          Text("Rejected"),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "1",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          Text("Pending"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Riwayat Terakhir", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
                  Text("Lihat Semua >", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
