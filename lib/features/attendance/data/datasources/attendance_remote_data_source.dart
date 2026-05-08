import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_record.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_request.dart';

abstract class AttendanceRemoteDataSource {
  Future<bool> postAttendance(AttendanceRequest request);
  Future<List<AttendanceRecord>> getHistory({
    required int userId,
    required int days,
    int page = 1,
    int perPage = 10,
  });
  Future<Map<String, dynamic>?> getAttendanceDetail({
    required int userId,
    required double lat,
    required double lon,
  });
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final DioClient _dioClient;

  AttendanceRemoteDataSourceImpl(this._dioClient);

  @override
  Future<bool> postAttendance(AttendanceRequest request) async {
    try {
      final response = await _dioClient.instance.post(
        '/absensi',
        data: request.toJson(),
      );
      
      if (response.data != null && response.data['status'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AttendanceRecord>> getHistory({
    required int userId,
    required int days,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _dioClient.instance.get(
        '/absensi/history',
        queryParameters: {
          'page': page,
          'perPage': perPage,
          'userId': userId,
          'days': days,
        },
      );

      if (response.data != null && response.data['status'] == true) {
        final List data = response.data['data'];
        return data.map((json) => AttendanceRecord.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getAttendanceDetail({
    required int userId,
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await _dioClient.instance.get(
        '/absensi/detail',
        queryParameters: {
          'userId': userId,
          'lat': lat,
          'lon': lon,
        },
      );

      if (response.data != null) {
        if (response.data['status'] == true) {
          return response.data;
        } else {
          throw response.data['message'] ?? 'Gagal mendapatkan detail lokasi';
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
