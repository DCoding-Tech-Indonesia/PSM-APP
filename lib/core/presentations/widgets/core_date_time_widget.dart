import 'dart:async';

import 'package:flutter/material.dart';
import 'package:psm_mobile/core/helper/date_time_helper.dart';

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

    _now = DateTime.now().toUtc().add(const Duration(hours: 7));

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now().toUtc().add(const Duration(hours: 7));
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
    // final second = _now.second.toString().padLeft(2, '0');

    return '$hour:$minute WIB';
    // return '$hour:$minute:$second WIB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateTimeHelper.formatEEEDDMMYY(_now),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                _timeString,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
