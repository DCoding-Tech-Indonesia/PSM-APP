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
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4F8),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFD3E2F2),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '0',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF718096),
              ),
            ),
            SizedBox(height: 1),
            Text(
              'NO SHIFT',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Color(0xFF718096),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    final progress = _getShiftProgress(now, shift);
    final remaining = _getRemainingTime(now, shift);

    Color progressColor;

    if (progress < 0.5) {
      progressColor = const Color(0xFF00E676);
    } else if (progress < 0.8) {
      progressColor = const Color(0xFFFFB300);
    } else {
      progressColor = const Color(0xFFFF1744);
    }

    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4.5,
              backgroundColor: Colors.grey.shade100,
              color: progressColor,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Shift ${_getCurrentShiftNumber(now)}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2D3748),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDuration(remaining),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: progressColor,
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
