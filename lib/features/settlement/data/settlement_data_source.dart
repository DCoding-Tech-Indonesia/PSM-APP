import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:travis/core/presentations/entity/core_status_and_message_response.dart';
import 'package:travis/core/storage/secure_storage.dart';
import 'package:travis/features/settlement/domain/entities/auditTrail/settlement_task_audit_trail.dart';
import 'package:travis/features/settlement/domain/entities/settlement_create.dart';

class SettlementDataSource {
  final Dio dio;
  final SecureStorageService secureStorageService;

  SettlementDataSource({required this.dio, required this.secureStorageService});

  Future<String> createSettlement(SettlementCreate request) async {
    try {
      final requestJson = request.toJson();

      if (kDebugMode) {
        print("========== CREATE SETTLEMENT REQUEST ==========");
        print("ENDPOINT: POST /settelment/create");
        print("PAYLOAD:");
        print(const JsonEncoder.withIndent('  ').convert(requestJson));
        print("RITASE KE VALUE: ${requestJson['ritaseKe']}");
        print("==============================================");
      }

      final response = await dio.post('/settelment/create', data: requestJson);

      if (kDebugMode) {
        print("========== CREATE SETTLEMENT RESPONSE ==========");

        print("PATH:");
        print(response.requestOptions.path);

        print("STATUS CODE:");
        print(response.statusCode);

        print("HEADERS:");
        print(const JsonEncoder.withIndent('  ').convert(response.headers.map));

        print("DATA:");
        print(const JsonEncoder.withIndent('  ').convert(response.data));

        print("================================================");
      }

      final idAuditTrail = response.data["data"][0]["auditTrailId"].toString();

      return idAuditTrail;
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }

  Future<List<SettlementTaskAuditTrail>> fetchTaskAuditTrailList(
    String keyword, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final idPramugara = await secureStorageService.readPramugaraId();

      final response = await dio.get(
        '/audittrail/task/settelment/list',
        queryParameters: {
          'keyword': keyword,
          'page': page,
          'perPage': perPage,
          'createdBy': idPramugara,
        },
      );

      final List data = response.data['data'] ?? [];

      final result = data
          .map<SettlementTaskAuditTrail>(
            (e) => SettlementTaskAuditTrail.fromJson(e),
          )
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

  Future<CoreStatusAndMessageResponse> updateSettlement(
    SettlementCreate request,
  ) async {
    try {
      final requestPayload = request.toJson();

      // Log detail items
      if (kDebugMode) {
        print("========== UPDATE SETTLEMENT REQUEST ==========");
        print("ENDPOINT: POST /audittrail/task/approval/edit");
        print("Audit Trail ID: ${request.auditTrailId}");
        print("Ritase Ke (Top Level): ${requestPayload['ritaseKe']}");
        print(
          "Detail Items Count: ${(requestPayload['detail'] as List?)?.length ?? 0}",
        );

        final details = requestPayload['detail'] as List?;
        if (details != null) {
          for (int i = 0; i < details.length; i++) {
            final detail = details[i] as Map<String, dynamic>;
            print("  Detail[$i] ritaseKe: ${detail['ritaseKe']}");
          }
        }

        print("FULL REQUEST BODY:");
        print(
          const JsonEncoder.withIndent('  ').convert({
            "idAuditTrail": request.auditTrailId,
            "payload": requestPayload,
            "reason": "UPDATE",
          }),
        );
        print("==============================================");
      }

      final response = await dio.post(
        '/audittrail/task/approval/edit',
        data: {
          "idAuditTrail": request.auditTrailId,
          "payload": request,
          "reason": "UPDATE",
        },
      );

      return CoreStatusAndMessageResponse.fromJson(response.data);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<CoreStatusAndMessageResponse> submitWorkflow(
    int idAuditTrail,
    String reason,
  ) async {
    try {
      final response = await dio.post(
        '/workflow/submit',
        data: {
          "idAuditTrail": [idAuditTrail],
          "reason": reason,
        },
      );

      return CoreStatusAndMessageResponse.fromJson(response.data);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<CoreStatusAndMessageResponse> cancelTaskDraft(int idAuditTrail) async {
    try {
      final response = await dio.post(
        '/audittrail/task/draft/cancel',
        data: {"idAuditTrail": idAuditTrail},
      );

      return CoreStatusAndMessageResponse.fromJson(response.data);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
