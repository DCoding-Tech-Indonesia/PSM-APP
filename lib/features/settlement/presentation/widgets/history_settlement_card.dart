import 'package:flutter/material.dart';
import 'package:psm_mobile/core/helper/string_formatter.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/task_audit_trail.dart';

class HistorySettlementCard extends StatelessWidget {
  const HistorySettlementCard({super.key, required this.data});

  final TaskAuditTrail data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 10,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text("0.5", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      const Text(
                        'Koridor A',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        decoration: BoxDecoration(
                            color: data.status.code == "APR" ? Colors.greenAccent : Colors.yellowAccent,
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(width: 1, color: data.status.code == "APR" ? Colors.green : Colors.yellow)
                        ),
                        child: Text(data.status.name, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.blueGrey,
                    ),
                    child: Row(
                      spacing: 8,
                      children: const [
                        Text('BA 1945 AG'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            StringFormatter().formatHourMinute(data.createdDate),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}