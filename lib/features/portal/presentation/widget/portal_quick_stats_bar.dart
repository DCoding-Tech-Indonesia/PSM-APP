import 'package:flutter/material.dart';

class PortalQuickStatsBar extends StatelessWidget {
  const PortalQuickStatsBar({super.key});

  Widget _buildQuickStat(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickStat(
            'Hari Ini',
            '0',
            Icons.calendar_today,
            Colors.blue,
            theme,
          ),
          _buildQuickStat(
            'Hadir',
            '0',
            Icons.check_circle,
            Colors.green,
            theme,
          ),
          _buildQuickStat(
            'Terlambat',
            '0',
            Icons.access_time,
            Colors.orange,
            theme,
          ),
          _buildQuickStat(
            'Selesai',
            '0',
            Icons.task_alt,
            Colors.purple,
            theme,
          ),
        ],
      ),
    );
  }
}
