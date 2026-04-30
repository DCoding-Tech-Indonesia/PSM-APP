import 'package:intl/intl.dart';

class AttendanceRecord {
  final DateTime timestamp;
  final String checkIn;
  final String? checkOut;
  final String date;

  AttendanceRecord({
    required this.timestamp,
    required this.checkIn,
    this.checkOut,
    required this.date,
  });

  String get formattedDate {
    return DateFormat('dd MMMM yyyy').format(timestamp);
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      timestamp: DateTime.parse(json['timestamp']),
      checkIn: json['checkIn'],
      checkOut: json['checkOut'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'checkIn': checkIn,
      'checkOut': checkOut,
      'date': date,
    };
  }
}

class AttendanceStats {
  final int totalDays;
  final int presentDays;
  final int lateDays;
  final int absentDays;

  AttendanceStats({
    this.totalDays = 0,
    this.presentDays = 0,
    this.lateDays = 0,
    this.absentDays = 0,
  });
}
