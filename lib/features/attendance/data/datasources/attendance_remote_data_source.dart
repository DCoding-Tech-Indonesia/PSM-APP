import 'package:dio/dio.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_record.dart';
import 'package:psm_mobile/features/attendance/data/models/attendance_request.dart';
import 'package:psm_mobile/features/attendance/data/models/schedule_model.dart';

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
  Future<List<dynamic>> getShifts();
  Future<List<dynamic>> getBus();
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

      if (response.data != null) {
        if (response.data['status'] == true) {
          return true;
        } else {
          throw response.data['message'] ?? 'Gagal melakukan check-in.';
        }
      }
      return false;
    } on DioException catch (e) {
      if (e.response?.data != null &&
          e.response!.data is Map &&
          e.response!.data['message'] != null) {
        throw e.response!.data['message'];
      }
      throw 'Terjadi kesalahan pada jaringan atau server.';
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
        final List<AttendanceRecord> records = [];
        
        for (var dayData in data) {
          final int parentId = dayData['id'] ?? 0;
          final List logs = dayData['logs'] ?? [];
          
          for (var log in logs) {
            final Map<String, dynamic> logData = Map<String, dynamic>.from(log);
            logData['id'] = parentId;
            records.add(AttendanceRecord.fromJson(logData));
          }
        }
        
        records.sort((a, b) {
          if (a.checkIn == null) return 1;
          if (b.checkIn == null) return -1;
          return b.checkIn!.compareTo(a.checkIn!);
        });

        return records;
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
        queryParameters: {'userId': userId, 'lat': lat, 'lon': lon},
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

  @override
  Future<Map<String, dynamic>?> getStats({
    required int userId,
    required int month,
    required int year,
  }) async {
    try {
      final response = await _dioClient.instance.get(
        '/absensi/statistik',
        queryParameters: {'userId': userId, 'month': month, 'year': year},
      );

      if (response.data != null && response.data['status'] == true) {
        return response.data;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ScheduleModel>> getSchedules({
    required int userId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _dioClient.instance.get(
        '/jadwal/list',
        queryParameters: {
          'userId': userId,
          'startDate': startDate,
          'endDate': endDate,
          'page': 1,
          'perPage': 10,
        },
      );

      if (response.data != null && response.data['status'] == true) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => ScheduleModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<dynamic>> getShifts() async {
    try {
      final response = await _dioClient.instance.get(
        '/reference/shift-karyawan',
        queryParameters: {'page': 1, 'perPage': 1000},
      );

      if (response.data != null && response.data['status'] == true) {
        return response.data['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<dynamic>> getBus() async {
    try {
      final response = await _dioClient.instance.get(
        '/reference/bus',
        queryParameters: {'page': 1, 'perPage': 1000},
      );

      if (response.data != null && response.data['status'] == true) {
        return response.data['data'] ?? [];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
