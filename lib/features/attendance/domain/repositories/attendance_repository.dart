import 'package:psm_mobile/features/attendance/data/models/attendance_record.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_request.dart';
import 'package:psm_mobile/features/attendance/data/models/schedule_model.dart';

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
  Future<List<ScheduleModel>> getSchedules({
    required int userId,
    required String startDate,
    required String endDate,
  });
  Future<List<dynamic>> getBus();
  Future<List<dynamic>> getReplacementSchedules(int jadwalId);
  Future<bool> requestShiftReplacement({
    required int requesterId,
    required int replacementId,
    required int jadwalId,
    required String alasan,
  });
}
