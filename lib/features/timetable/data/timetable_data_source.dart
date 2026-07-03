import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/kmbus_data.dart';
import 'package:psm_mobile/features/timetable/domain/entities/response/timetable_checkin_response.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_checkin.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_checkout.dart';
import 'package:psm_mobile/features/timetable/domain/entities/timetable_data.dart';

class TimetableDataSource {
  final Dio dio;
  final SecureStorageService secureStorageService;

  TimetableDataSource({required this.dio, required this.secureStorageService});

  Future<List<TimetableData>> fetchTimetableDataList(String keyword) async {
    try {
      final idUser = await secureStorageService.readUserId();

      final response = await dio.get(
        '/time-table/detail/list',
        queryParameters: {
          'keyword': keyword,
          'page': 1,
          'perPage': 99,
          'idUser': idUser,
        },
      );

      final List data = response.data['data'] ?? [];

      final result = data
          .map<TimetableData>((e) => TimetableData.fromJson(e))
          .toList();

      return result;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<String> checkAllowCheckIn(
    int idKoridor,
    int idBus,
    double nextRit,
  ) async {
    try {
      final response = await dio.get(
        '/time-table/check/check-in',
        queryParameters: {
          'idKoridor': idKoridor,
          'idBus': idBus,
          'ritaseKe': nextRit,
        },
      );

      bool allow = response.data["data"][0];

      return !allow ? "Access Granted" : "Access Denied";
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<String> checkAllowCheckOut(
    int idKoridor,
    int idBus,
    double nextRit,
  ) async {
    try {
      final response = await dio.get(
        '/time-table/check/check-out',
        queryParameters: {
          'idKoridor': idKoridor,
          'idBus': idBus,
          'ritaseKe': nextRit,
        },
      );

      bool allow = response.data["data"][0];

      return !allow ? "Access Granted" : "Access Denied";
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<TimetableCheckinResponse?> checkinTimeTable(
    TimetableCheckin request,
  ) async {
    try {
      final result = await dio.post(
        '/time-table/check-in',
        data: request.toJson(),
      );

      return TimetableCheckinResponse.fromJson(result.data);
    } on DioException catch (e) {
      debugPrint("=== DIO ERROR ===");
      debugPrint("Status Code: ${e.response?.statusCode}");
      debugPrint("Message: ${e.message}");
      debugPrint("Data Server: ${e.response?.data}");

      return TimetableCheckinResponse(
        status: false,
        message: e.response?.data?['message'] ?? e.message ?? 'Unknown error',
      );
    } catch (e) {
      debugPrint("=== GENERAL ERROR ===");
      debugPrint(e.toString());

      return TimetableCheckinResponse(status: false, message: e.toString());
    }
  }

  Future<TimetableCheckinResponse?> checkoutTimeTable(TimetableCheckout request) async {
    try {
      final result = await dio.post(
        '/time-table/check-out',
        data: request.toJson(),
      );

      return TimetableCheckinResponse.fromJson(result.data);
    } on DioException catch (e) {
      debugPrint("=== DIO ERROR ===");
      debugPrint("Status Code: ${e.response?.statusCode}");
      debugPrint("Message: ${e.message}");
      debugPrint("Data Server: ${e.response?.data}");

      return TimetableCheckinResponse(
        status: false,
        message: e.response?.data?['message'] ?? e.message ?? 'Unknown error',
      );
    } catch (e) {
      debugPrint("=== GENERAL ERROR ===");
      debugPrint(e.toString());

      return TimetableCheckinResponse(status: false, message: e.toString());
    }
  }

  Future<List<KmbusData>> fetchKmbusDataToday(String keyword) async {
    try {
      final idUserRole = await secureStorageService.readUserRoleId();

      final String todayStr = DateTime.now().toIso8601String().split('T')[0];

      final response = await dio.get(
        '/km/list',
        queryParameters: {
          'keyword': keyword,
          'page': 1,
          'perPage': 99,
          'idPramugara': idUserRole,
          'startDate': todayStr,
          'endDate': todayStr,
        },
      );

      final List data = response.data['data'] ?? [];

      final result = data.map<KmbusData>((e) => KmbusData.fromJson(e)).toList();

      return result;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<String> checkAllowTitikAwal(
      int idKoridor,
      int idBus,
      double nextRit,
      ) async {
    try {
      final response = await dio.get(
        '/km/check/titik-awal',
        queryParameters: {
          'idKoridor': idKoridor,
          'idBus': idBus,
          'ritaseKe': nextRit,
        },
      );

      bool allow = response.data["data"][0];

      return !allow ? "Access Granted" : "Access Denied";
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
