import 'dart:io';

import 'package:dio/dio.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/module_audit_trail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/status_audit_trail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/task_audit_trail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/auditTrail/user_audit_trail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/document_preview.dart';
import 'package:psm_mobile/features/settlement/domain/entities/reference_bus.dart';
import 'package:psm_mobile/features/settlement/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/settlement/domain/entities/settlement_create.dart';

class SettlementDataSource {
  final Dio dio;
  final SecureStorageService secureStorageService;

  SettlementDataSource({required this.dio, required this.secureStorageService});

  Future<List<ReferenceBus>> fetchReferenceBus(String keyword) async {
    final response = await dio.get(
      '/reference/bus',
      queryParameters: {'keyword': keyword, 'page': 1, 'perPage': 999},
    );

    final data = response.data['data'] as List;

    return data.map((e) => ReferenceBus.fromJson(e)).toList();
  }

  Future<List<ReferenceDetail>> fetchReferenceKoridor(String keyword) async {
    final response = await dio.get(
      '/reference/koridor',
      queryParameters: {'keyword': keyword, 'page': 1, 'perPage': 999},
    );

    final data = response.data['data'] as List;

    return data.map((e) => ReferenceDetail.fromJson(e)).toList();
  }

  Future<List<ReferenceDetail>> fetchReferencePayment(String keyword) async {
    final response = await dio.get(
      '/reference/payment',
      queryParameters: {'keyword': keyword, 'page': 1, 'perPage': 999},
    );

    final data = response.data['data'] as List;

    return data.map((e) => ReferenceDetail.fromJson(e)).toList();
  }

  Future<List<ReferenceDetail>> fetchReferenceCustType(String keyword) async {
    final response = await dio.get(
      '/reference/customer-type',
      queryParameters: {'keyword': keyword, 'page': 1, 'perPage': 999},
    );

    final data = response.data['data'] as List;

    return data.map((e) => ReferenceDetail.fromJson(e)).toList();
  }

  Future<String> fetchReferenceCustomerBilling(int idTypeNasabah) async {
    final response = await dio.get(
      '/reference/customer-billing',
      queryParameters: {
        'idTypeNasabah': idTypeNasabah,
        'page': 1,
        'perPage': 999,
      },
    );

    final custBill = response.data["data"][0]["value"];

    return custBill;
  }

  Future<DocumentPreview> uploadDocument(File file) async {
    try {
      final fileName = file.path.split('/').last;

      final formData = FormData.fromMap({
        'doc': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await dio.post(
        '/reference/upload-document/additional',
        data: formData,
      );

      final imageId = response.data['data'][0]['id'];
      final host = response.data['data'][0]['server'];
      final url = response.data['data'][0]['url'];

      return DocumentPreview(idDocument: imageId, url: '$host/$url');
    } on DioException catch (e) {
      print(e.response?.data);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> createSettlement(SettlementCreate request) async {
    try {
      final response = await dio.post(
        '/settelment/create',
        data: request.toJson(),
      );

      final idAuditTrail = response.data["data"][0]["auditTrailId"].toString();

      return idAuditTrail;
    } catch (e) {
      print(e);
      return e.toString();
    }
  }

  Future<List<TaskAuditTrail>> fetchTaskAuditTrailList(String keyword) async {
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
      print(data[0]);

      return data.map((e) {
        return TaskAuditTrail(
          id: e['id'],
          createdDate: e['createdDate'],
          approvedDate: e['approvedDate'],

          createdBy: UserAuditTrail(
            id: e['createdBy']['id'],
            userName: e['createdBy']['userName'],
          ),

          approvedBy: e['approvedBy'] != null
              ? UserAuditTrail(
                  id: e['approvedBy']['id'],
                  userName: e['approvedBy']['userName'],
                )
              : null,

          module: ModuleAuditTrail(
            id: e['module']['id'],
            code: e['module']['code'],
            name: e['module']['name'],
          ),

          status: StatusAuditTrail(
            id: e['status']['id'],
            code: e['status']['code'],
            name: e['status']['name'],
          ),
        );
      }).toList();
    } catch (e) {
      print(e);
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
      final response = await dio.post(
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
      final response = await dio.post(
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
}