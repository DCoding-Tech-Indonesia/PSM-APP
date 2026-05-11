import 'package:flutter/material.dart';

class DashboardReportFilterButton extends StatelessWidget {
  const DashboardReportFilterButton({
    super.key,
    required this.label,
    required this.active,
    required this.changeFilter,
  });

  final String label;
  final bool active;
  final Function(String) changeFilter;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => changeFilter(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: active ? Colors.yellow : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
