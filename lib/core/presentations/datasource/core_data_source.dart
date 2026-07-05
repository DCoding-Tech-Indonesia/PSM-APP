import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:psm_mobile/core/presentations/entity/core_data_source_response.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';

class CoreDataSource {
  final Dio dio;
  final SecureStorageService secureStorageService;

  CoreDataSource({required this.dio, required this.secureStorageService});

  Future<CoreDataSourceResponse> _check(
    String endpoint,
    int idKoridor,
    int idBus,
    double nextRit,
  ) async {
    try {
      final response = await dio.get(
        endpoint,
        queryParameters: {
          'idKoridor': idKoridor,
          'idBus': idBus,
          'ritaseKe': nextRit,
        },
      );

      return CoreDataSourceResponse.fromJson(response.data);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<CoreDataSourceResponse> checkAllowCheckIn(
    int idKoridor,
    int idBus,
    double nextRit,
  ) {
    return _check('/time-table/check/check-in', idKoridor, idBus, nextRit);
  }

  Future<CoreDataSourceResponse> checkAllowCheckOut(
    int idKoridor,
    int idBus,
    double nextRit,
  ) {
    return _check('/time-table/check/check-out', idKoridor, idBus, nextRit);
  }

  Future<CoreDataSourceResponse> checkAllowTitikAwal(
    int idKoridor,
    int idBus,
    double nextRit,
  ) {
    return _check('/km/check/titik-awal', idKoridor, idBus, nextRit);
  }

  Future<CoreDataSourceResponse> checkAllowTitikAkhir(
    int idKoridor,
    int idBus,
    double nextRit,
  ) {
    return _check('/km/check/titik-akhir', idKoridor, idBus, nextRit);
  }

  Future<CoreDataSourceResponse> checkAllowSettlement(
    int idKoridor,
    int idBus,
    double nextRit,
  ) {
    return _check('/settelment/check', idKoridor, idBus, nextRit);
  }
}
