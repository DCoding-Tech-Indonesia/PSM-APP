import 'dart:async';
import 'package:flutter/material.dart';
import 'package:travis/core/helper/date_time_helper.dart';

class CoreDateTimeWidget extends StatefulWidget {
  const CoreDateTimeWidget({super.key});

  @override
  State<CoreDateTimeWidget> createState() => _CoreDateTimeWidgetState();
}

class _CoreDateTimeWidgetState extends State<CoreDateTimeWidget> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeString {
    final hour = _now.hour.toString().padLeft(2, '0');
    final minute = _now.minute.toString().padLeft(2, '0');
    final second = _now.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  int? _getCurrentShiftIndex(DateTime now) {
    final s1Start = DateTime(now.year, now.month, now.day, 7, 0);
    final s1End = DateTime(now.year, now.month, now.day, 12, 0);
    final s2Start = DateTime(now.year, now.month, now.day, 14, 0);
    final s2End = DateTime(now.year, now.month, now.day, 18, 0);

    if (!now.isBefore(s1Start) && now.isBefore(s1End)) return 1;
    if (!now.isBefore(s2Start) && now.isBefore(s2End)) return 2;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final shiftIndex = _getCurrentShiftIndex(_now);
    final hasShift = shiftIndex != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: Color(0xFF1565C0),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _timeString,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2D3748),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateTimeHelper.formatEEEDDMMYY(_now),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD3E2F2), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: hasShift
                        ? const Color(0xFF00E676)
                        : const Color(0xFFEF5350),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (hasShift
                                    ? const Color(0xFF00E676)
                                    : const Color(0xFFEF5350))
                                .withValues(alpha: 0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  hasShift ? 'SHIFT $shiftIndex' : 'NO SHIFT',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4A5568),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
