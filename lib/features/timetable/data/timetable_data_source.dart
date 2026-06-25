import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:psm_mobile/features/timetable/domain/timetable_checkin.dart';
import 'package:psm_mobile/features/timetable/domain/timetable_data.dart';

class TimetableDataSource {
  final Dio dio;

  TimetableDataSource({required this.dio});

  Future<List<TimetableData>> fetchTimetableDataList(String keyword) async {
    try {
      final response = await dio.get(
        '/time-table/list',
        queryParameters: {
          'keyword': keyword,
          'page': 1,
          'perPage': 99,
        }
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

  Future<double> fetchNextRitase(int idKoridor, int idBus) async {
    final response = await dio.get(
      '/reference/next-ritase',
      queryParameters: {'idKoridor': idKoridor, 'idBus': idBus},
    );

    final data = response.data['data'][0]['ritaseKe'] as double;

    return data;
  }

  Future<String?> checkinTimeTable(TimetableCheckin request) async {
    try {
      final response = await dio.post(
        '/time-table/check-in',
        data: request.toJson(),
      );

      final data = response.data["data"];

      return data;
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }
}