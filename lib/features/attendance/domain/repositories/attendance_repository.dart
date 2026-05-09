import 'package:psm_mobile/features/attendance/data/models/attendance_record.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_request.dart';

abstract class AttendanceRepository {
  Future<bool> submitAttendance(AttendanceRequest request);
  Future<List<AttendanceRecord>> getHistory(int userId, int days);
  Future<Map<String, dynamic>?> getAttendanceDetail({
    required int userId,
    required double lat,
    required double lon,
  });
  Future<Map<String, dynamic>?> getStats({
    required int userId,
    required int month,
    required int year,
  });
}
