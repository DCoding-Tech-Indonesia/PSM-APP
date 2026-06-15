import 'package:flutter/material.dart';
import 'package:psm_mobile/core/presentations/entity/shift_period.dart';

class CoreShiftProgressWidget extends StatelessWidget {
  final DateTime now;

  const CoreShiftProgressWidget({super.key, required this.now});

  static final List<ShiftPeriod> _shifts = [
    ShiftPeriod(
      start: TimeOfDay(hour: 7, minute: 0),
      end: TimeOfDay(hour: 12, minute: 0),
    ),
    ShiftPeriod(
      start: TimeOfDay(hour: 14, minute: 0),
      end: TimeOfDay(hour: 18, minute: 0),
    ),
  ];

  ShiftPeriod? _getCurrentShift(DateTime now) {
    for (final shift in _shifts) {
      final start = DateTime(
        now.year,
        now.month,
        now.day,
        shift.start.hour,
        shift.start.minute,
      );

      final end = DateTime(
        now.year,
        now.month,
        now.day,
        shift.end.hour,
        shift.end.minute,
      );

      final isInShift = !now.isBefore(start) && now.isBefore(end);

      if (isInShift) {
        return shift;
      }
    }

    return null;
  }

  double _getShiftProgress(DateTime now, ShiftPeriod shift) {
    final start = DateTime(
      now.year,
      now.month,
      now.day,
      shift.start.hour,
      shift.start.minute,
    );

    final end = DateTime(
      now.year,
      now.month,
      now.day,
      shift.end.hour,
      shift.end.minute,
    );

    final totalSeconds = end.difference(start).inSeconds;

    final elapsedSeconds = now
        .difference(start)
        .inSeconds
        .clamp(0, totalSeconds);

    return elapsedSeconds / totalSeconds;
  }

  Duration _getRemainingTime(DateTime now, ShiftPeriod shift) {
    final end = DateTime(
      now.year,
      now.month,
      now.day,
      shift.end.hour,
      shift.end.minute,
    );

    return end.difference(now);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return '${hours}h ${minutes}m';
  }

  String _getCurrentShiftNumber(DateTime now) {
    for (int i = 0; i < _shifts.length; i++) {
      final shift = _shifts[i];

      final start = DateTime(
        now.year,
        now.month,
        now.day,
        shift.start.hour,
        shift.start.minute,
      );

      final end = DateTime(
        now.year,
        now.month,
        now.day,
        shift.end.hour,
        shift.end.minute,
      );

      final isInShift = !now.isBefore(start) && now.isBefore(end);

      if (isInShift) {
        return (i + 1).toString();
      }
    }

    return "0";
  }

  @override
  Widget build(BuildContext context) {
    final shift = _getCurrentShift(now);

    if (shift == null) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blueGrey.shade100, width: 3),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('0', style: TextStyle(fontSize: 22)),
            SizedBox(height: 2),
            Text(
              'NO SHIFT',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    final progress = _getShiftProgress(now, shift);
    final remaining = _getRemainingTime(now, shift);

    Color progressColor;

    if (progress < 0.5) {
      progressColor = Colors.green;
    } else if (progress < 0.8) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return SizedBox(
      width: 75,
      height: 75,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: Colors.grey.shade200,
              color: progressColor,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getCurrentShiftNumber(now),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.blueAccent,
                ),
              ),
              Text(
                _formatDuration(remaining),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
