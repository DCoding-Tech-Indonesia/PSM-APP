import 'package:psm_mobile/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_record.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_request.dart';
import 'package:psm_mobile/features/attendance/data/models/schedule_model.dart';
import 'package:psm_mobile/features/attendance/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<bool> submitAttendance(AttendanceRequest request) async {
    return await remoteDataSource.postAttendance(request);
  }

  @override
  Future<List<AttendanceRecord>> getHistory(int userId, int days) async {
    return await remoteDataSource.getHistory(userId: userId, days: days);
  }

  @override
  Future<Map<String, dynamic>?> getAttendanceDetail({
    required int userId,
    required double lat,
    required double lon,
  }) async {
    return await remoteDataSource.getAttendanceDetail(
      userId: userId,
      lat: lat,
      lon: lon,
    );
  }

  @override
  Future<Map<String, dynamic>?> getStats({
    required int userId,
    required int month,
    required int year,
  }) async {
    return await remoteDataSource.getStats(
      userId: userId,
      month: month,
      year: year,
    );
  }

  @override
  Future<List<ScheduleModel>> getSchedules({
    required int userId,
    required String startDate,
    required String endDate,
  }) async {
    return await remoteDataSource.getSchedules(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<List<dynamic>> getBus() async {
    return await remoteDataSource.getBus();
  }

  @override
  Future<List<dynamic>> getReplacementSchedules(int jadwalId) async {
    return await remoteDataSource.getReplacementSchedules(jadwalId);
  }

  @override
  Future<bool> requestShiftReplacement({
    required int requesterId,
    required int replacementId,
    required int jadwalId,
    required String alasan,
  }) async {
    return await remoteDataSource.requestShiftReplacement(
      requesterId: requesterId,
      replacementId: replacementId,
      jadwalId: jadwalId,
      alasan: alasan,
    );
  }
}
