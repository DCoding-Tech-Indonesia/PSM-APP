import 'dart:io';

import 'package:dio/dio.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';

import 'domain/entities/document_preview.dart';
import 'domain/entities/reference_billing.dart';
import 'domain/entities/reference_bus.dart';
import 'domain/entities/reference_detail.dart';

class ReferenceDataSource {
  final Dio dio;
  final SecureStorageService secureStorageService;

  ReferenceDataSource({required this.dio, required this.secureStorageService});

  Future<List<ReferenceBus>> fetchReferenceBus(String keyword, int idKoridor) async {
    final response = await dio.get(
      '/reference/bus',
      queryParameters: {'keyword': keyword, 'page': 1, 'perPage': 999, 'idKoridor': idKoridor},
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

  Future<List<ReferenceBilling>> fetchReferenceCustomerBilling(int idTypeNasabah) async {
    final response = await dio.get(
      '/reference/customer-billing',
      queryParameters: {
        'idTypeNasabah': idTypeNasabah,
        'page': 1,
        'perPage': 999,
      },
    );

    final data = response.data["data"] as List;

    return data.map((e) => ReferenceBilling.fromJson(e)).toList();
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
}