import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/task_audit_trail.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_bloc.dart';
import 'package:psm_mobile/features/settlement/presentation/bloc/settlement_state.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/dashboard_report.dart';

class HomeScreenMenu extends StatelessWidget {
  const HomeScreenMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset("./assets/trans_padang_logo.png", height: 50),
                Icon(Icons.notifications_outlined),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Text("Salamaik Pagi, "),
                Text(
                  "Damaik King LOS!",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.orangeAccent, width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "10",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        Text("Approved", style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.orangeAccent, width: 1),
                        right: BorderSide(color: Colors.orangeAccent, width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "10",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                        Text("Declined", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.orangeAccent, width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "10",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text("Submitted"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<SettlementBloc, SettlementState>(
            builder: (context, state) {
              return state.listTaskAuditTrail.isEmpty
                  ? _emptyBuilder(context)
                  : _unEmptyBuilder(context, state.listTaskAuditTrail);
            },
          ),
          DashboardReport(),
        ],
      ),
    );
  }

  Widget _emptyBuilder(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 18.0),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.white70),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.add_circle_outline_sharp, color: Colors.white70),
            Text(
              "Pilih pasien kamu hari ini.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _unEmptyCard(BuildContext context, TaskAuditTrail task) {
    print(task.createdDate);
    return GestureDetector(
      onTap: () {
        context.push('/settlement/form', extra: task.id);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          spacing: 16,
          children: [
            Stack(
              children: [
                Positioned(
                  right: -20,
                  top: 20,
                  child: Image.asset("./assets/icon/bus-stop.png", height: 100),
                ),
                Container(
                  height: 120,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 18,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withValues(alpha: 0.9),
                    border: Border.all(width: .7, color: Colors.blue),
                  ),
                  child: DefaultTextStyle(
                    style: TextStyle(color: Colors.blueGrey),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "[DUMMY TOTAL]",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                task.updatedDate != null
                                    ? StringFormatter().formatDateTime(
                                        task.updatedDate!,
                                      )
                                    : StringFormatter().formatDateTime(
                                        task.createdDate,
                                      ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 3,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.yellow.withValues(alpha: .75),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  width: .8,
                                  color: Colors.lightGreen,
                                ),
                              ),
                              child: Text(
                                "Pending",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("[DUMMY NO.PLAT]"),
                                Text("[DUMMY NAMA HALTE]"),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _unEmptyBuilder(BuildContext context, List<TaskAuditTrail> listTask) {
    final items = [
      ...listTask.map((item) {
        return _unEmptyCard(context, item);
      }),
    ];
    return CarouselSlider(
      items: items,
      options: CarouselOptions(
        viewportFraction: 1,
        enlargeCenterPage: true,
        enableInfiniteScroll: false,
      ),
    );
  }
}
