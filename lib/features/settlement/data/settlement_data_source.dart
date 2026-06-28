import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/settlement_task_audit_trail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_create.dart';

class SettlementDataSource {
  final Dio dio;
  final SecureStorageService secureStorageService;

  SettlementDataSource({required this.dio, required this.secureStorageService});

  Future<double> fetchNextRitase(int idKoridor, int idBus) async {
    final response = await dio.get(
      '/reference/next-ritase',
      queryParameters: {'idKoridor': idKoridor, 'idBus': idBus},
    );

    final data = response.data['data'][0]['ritaseKe'] as double;

    return data;
  }

  Future<String> createSettlement(SettlementCreate request) async {
    try {
      final response = await dio.post(
        '/settelment/create',
        data: request.toJson(),
      );

      if (kDebugMode) {
        print("========== RESPONSE ==========");

        print("PATH:");
        print(response.requestOptions.path);

        print("STATUS CODE:");
        print(response.statusCode);

        print("HEADERS:");
        print(const JsonEncoder.withIndent('  ').convert(response.headers.map));

        print("DATA:");
        print(const JsonEncoder.withIndent('  ').convert(response.data));

        print("================================");
      }

      final idAuditTrail = response.data["data"][0]["auditTrailId"].toString();

      return idAuditTrail;
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }

  Future<List<SettlementTaskAuditTrail>> fetchTaskAuditTrailList(String keyword) async {
    try {
      final idUser = await secureStorageService.readUserId();

      final response = await dio.get(
        '/audittrail/task/settelment/list',
        queryParameters: {
          'keyword': keyword,
          'page': 1,
          'perPage': 99,
          'createdBy': idUser,
        },
      );

      final List data = response.data['data'] ?? [];

      final result = data
          .map<SettlementTaskAuditTrail>((e) => SettlementTaskAuditTrail.fromJson(e))
          .toList();

      return result;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<SettlementCreate> fetchTaskAuditTrailDetail(int idAuditTrail) async {
    try {
      final response = await dio.get(
        '/audittrail/task/settelment/detail',
        queryParameters: {'id': idAuditTrail},
      );

      final detail = response.data["data"][0]["dataAfter"];

      return SettlementCreate.fromJson(detail);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<String> updateSettlement(SettlementCreate request) async {
    try {
      await dio.post(
        '/audittrail/task/approval/edit',
        data: {
          "idAuditTrail": request.auditTrailId,
          "payload": request,
          "reason": "UPDATE",
        },
      );

      return "Berhasil Update";
    } catch (e) {
      print(e);
      return e.toString();
    }
  }

  Future<String> submitWorkflow(int idAuditTrail, String reason) async {
    try {
      await dio.post(
        '/workflow/submit',
        data: {
          "idAuditTrail": [idAuditTrail],
          "reason": reason,
        },
      );

      return "Berhasil";
    } catch (e) {
      print(e);
      return e.toString();
    }
  }

  Future<String> cancelTaskDraft(int idAuditTrail) async {
    try {
      await dio.post(
        '/audittrail/task/draft/cancel',
        data: {
          "idAuditTrail": idAuditTrail,
        },
      );

      return "Berhasil";
    } catch (e) {
      print(e);
      return e.toString();
    }
  }
}
