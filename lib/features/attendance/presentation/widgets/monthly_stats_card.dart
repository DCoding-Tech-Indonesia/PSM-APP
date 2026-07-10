import 'package:flutter/material.dart';
import 'package:travis/features/attendance/presentation/bloc/attendance_state.dart';

class MonthlyStatsCard extends StatelessWidget {
  final AttendanceLoaded state;

  const MonthlyStatsCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.045),
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Colors.purple),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Statistik Bulan Ini',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total',
                  state.stats.totalDays.toString(),
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Hadir',
                  state.stats.presentDays.toString(),
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Late',
                  state.stats.lateDays.toString(),
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Alpha',
                  state.stats.absentDays.toString(),
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
