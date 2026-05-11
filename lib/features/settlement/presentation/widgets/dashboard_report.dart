import 'package:flutter/material.dart';
import 'package:psm_mobile/features/settlement/presentation/widgets/dashboard_report_filter_button.dart';

class DashboardReport extends StatefulWidget {
  const DashboardReport({super.key});

  @override
  State<DashboardReport> createState() => _DashboardReportState();
}

class _DashboardReportState extends State<DashboardReport> {
  String _activeFilter = 'Today';

  void _changeFilter(String filter) {
    setState(() {
      _activeFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        decoration: BoxDecoration(
          color: Color(0x44000000),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Row(
              spacing: 8,
              children: [
                DashboardReportFilterButton(
                  label: "Today",
                  active: _activeFilter == "Today",
                  changeFilter: _changeFilter,
                ),
                DashboardReportFilterButton(
                  label: "Monthly",
                  active: _activeFilter == "Monthly",
                  changeFilter: _changeFilter,
                ),
                DashboardReportFilterButton(
                  label: "Yearly",
                  active: _activeFilter == "Yearly",
                  changeFilter: _changeFilter,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: BoxBorder.all(width: .8, color: Color(0xFFFFD600)),
                    color: Colors.yellowAccent.withValues(alpha: .65),
                  ),
                  child: Icon(
                    Icons.filter_alt_sharp,
                    color: Colors.yellowAccent[700],
                    size: 30,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
