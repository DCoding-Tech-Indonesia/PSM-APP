import 'package:psm_mobile/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_record.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_request.dart';
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
}
