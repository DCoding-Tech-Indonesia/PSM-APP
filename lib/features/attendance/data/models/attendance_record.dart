import 'package:intl/intl.dart';
import 'package:travis/features/attendance/data/models/general_model.dart';

class AttendanceRecord {
  final int id;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final double? latIn;
  final double? latOut;
  final double? longIn;
  final double? longOut;
  final GeneralModel? lokasi;
  final GeneralModel? shift;

  AttendanceRecord({
    required this.id,
    this.checkIn,
    this.checkOut,
    this.latIn,
    this.latOut,
    this.longIn,
    this.longOut,
    this.lokasi,
    this.shift,
  });

  String get formattedDate {
    if (checkIn == null) return '--';
    return DateFormat('dd MMMM yyyy').format(checkIn!);
  }

  String get checkInTime =>
      checkIn != null ? DateFormat('HH:mm:ss').format(checkIn!) : '--:--';
  String get checkOutTime =>
      checkOut != null ? DateFormat('HH:mm:ss').format(checkOut!) : '--:--';
  String get date =>
      checkIn != null ? DateFormat('EEEE, dd MMM yyyy').format(checkIn!) : '--';

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      checkIn: json['checkIn'] != null ? DateTime.parse(json['checkIn']) : null,
      checkOut: json['checkOut'] != null
          ? DateTime.parse(json['checkOut'])
          : null,
      latIn: (json['latIn'] as num?)?.toDouble(),
      latOut: (json['latOut'] as num?)?.toDouble(),
      longIn: (json['longIn'] as num?)?.toDouble(),
      longOut: (json['longOut'] as num?)?.toDouble(),
      lokasi: json['lokasi'] != null
          ? GeneralModel.fromJson(json['lokasi'])
          : null,
      shift: json['shift'] != null
          ? GeneralModel.fromJson(json['shift'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'latIn': latIn,
      'latOut': latOut,
      'longIn': longIn,
      'longOut': longOut,
      'lokasi': lokasi,
      'shift': shift,
    };
  }
}
