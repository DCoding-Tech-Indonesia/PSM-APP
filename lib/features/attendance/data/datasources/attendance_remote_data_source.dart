import 'package:dio/dio.dart';
import 'package:travis/core/network/dio_client.dart';
import 'package:travis/features/attendance/data/models/attendance_record.dart';
import 'package:travis/features/attendance/data/models/attendance_request.dart';
import 'package:travis/features/attendance/data/models/schedule_model.dart';

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
  Future<List<dynamic>> getReplacementSchedules(int jadwalId, int userId);
  Future<bool> requestShiftReplacement({
    required int requesterId,
    required int replacementId,
    required int jadwalId,
    required String alasan,
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
        '/absensi/list',
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
          'perPage': 100,
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
  Future<List<dynamic>> getReplacementSchedules(
    int jadwalId,
    int userId,
  ) async {
    try {
      final response = await _dioClient.instance.get(
        '/jadwal/list-jadwal-pengganti',
        queryParameters: {
          'jadwalId': jadwalId,
          'userId': userId,
          'page': 1,
          'perPage': 1000,
        },
      );

      if (response.data != null) {
        if (response.data['status'] == true) {
          // data adalah List<List<dynamic>>, perlu di-flatten
          final raw = response.data['data'] as List? ?? [];
          return raw.expand((e) => e as List).toList();
        } else {
          throw response.data['message'] ??
              'Gagal mendapatkan list jadwal pengganti';
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> requestShiftReplacement({
    required int requesterId,
    required int replacementId,
    required int jadwalId,
    required String alasan,
  }) async {
    try {
      final response = await _dioClient.instance.post(
        '/pergantian-shift',
        data: {
          'requesterId': requesterId,
          'replacementId': replacementId,
          'jadwalId': jadwalId,
          'alasan': alasan,
        },
      );

      if (response.data != null) {
        if (response.data['status'] == true) {
          return true;
        } else {
          throw response.data['message'] ?? 'Gagal mengajukan pergantian shift';
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
}
