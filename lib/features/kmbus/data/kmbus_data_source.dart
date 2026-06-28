import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/kmbus_data.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/titik_akhir_create.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/titik_awal_create.dart';
import 'package:psm_mobile/features/timetable/domain/entities/auditTrail/km_task_audit_trail.dart';

class KmbusDataSource {
  final Dio dio;
  final SecureStorageService secureStorageService;

  KmbusDataSource({required this.dio, required this.secureStorageService});

  Future<List<KmbusData>> fetchKmbusData(String keyword) async {
    try {
      final String todayStr = DateTime.now().toIso8601String().split('T')[0];

      final response = await dio.get(
          '/km/list',
          queryParameters: {
            'keyword': keyword,
            'page': 1,
            'perPage': 99,
            'startDate': todayStr,
            'endDate': todayStr,
          }
      );

      final List data = response.data['data'] ?? [];

      final result = data
          .map<KmbusData>((e) => KmbusData.fromJson(e))
          .toList();

      return result;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<List<KmTaskAuditTrail>> fetchKmbusDataListAuditTrail(String keyword) async {
    try {
      final response = await dio.get(
          '/audittrail/task/km/list',
          queryParameters: {
            'keyword': keyword,
            'page': 1,
            'perPage': 99,
          }
      );

      final List data = response.data['data'] ?? [];

      final result = data
          .map<KmTaskAuditTrail>((e) => KmTaskAuditTrail.fromJson(e))
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

  Future<String> createTitikAwal(TitikAwalCreate request) async {
    try {
      final response = await dio.post(
        '/km/titik-awal/create',
        data: request.toJson(),
      );

      if (kDebugMode) {
        print("========== RESPONSE ==========");

        print("PATH:");
        print(response.requestOptions.path);

        print("STATUS CODE:");
        print(response.statusCode);

        print("HEADERS:");
        print(
          const JsonEncoder.withIndent('  ')
              .convert(response.headers.map),
        );

        print("DATA:");
        print(
          const JsonEncoder.withIndent('  ')
              .convert(response.data),
        );

        print("================================");
      }

      final idAuditTrail = response.data["data"][0]["auditTrailId"];

      return idAuditTrail.toString();
    } catch (e) {
      print(e);
      return e.toString();
    }
  }

  Future<String> createTitikAkhir(TitikAkhirCreate request) async {
    try {
      final response = await dio.post(
        '/km/titik-akhir/create',
        data: request.toJson(),
      );

      if (kDebugMode) {
        print("========== RESPONSE ==========");

        print("PATH:");
        print(response.requestOptions.path);

        print("STATUS CODE:");
        print(response.statusCode);

        print("HEADERS:");
        print(
          const JsonEncoder.withIndent('  ')
              .convert(response.headers.map),
        );

        print("DATA:");
        print(
          const JsonEncoder.withIndent('  ')
              .convert(response.data),
        );

        print("================================");
      }

      final idAuditTrail = response.data["data"][0]["auditTrailId"];

      return idAuditTrail.toString();
    } catch (e) {
      print(e);
      return e.toString();
    }
  }

  Future<String> uploadOcr(File file) async {
    try {
      final fileName = file.path.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      const ocrHost = 'https://ocr.ilkeiapps.com';

      final response = await dio.post(
        '$ocrHost/ocr',
        data: formData,
      );

      final ocrValue = response.data["texts"][0]["text"];

      return ocrValue;
    } on DioException catch (e) {
      print(e.response?.data);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> submitWorkflow(int idAuditTrail, String reason) async {
    try {
      final result = await dio.post(
        '/workflow/submit',
        data: {
          "idAuditTrail": [idAuditTrail],
          "reason": reason,
        },
      );

      print("result");
      print(result);

      return "Berhasil";
    } catch (e) {
      print(e);
      return e.toString();
    }
  }

}