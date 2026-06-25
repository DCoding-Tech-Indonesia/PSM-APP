import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:psm_mobile/core/storage/secure_storage.dart';
import 'package:psm_mobile/features/kmbus/domain/entities/titik_awal_create.dart';

class KmbusDataSource {
  final Dio dio;
  final SecureStorageService secureStorageService;

  KmbusDataSource({required this.dio, required this.secureStorageService});

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

      return "Create Titik Awal";
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

      print("response");
      print(response.data["result"][0][1][0]);

      print("response.result");
      print(response.data["result"]);

      return response.data["odometer"];
    } on DioException catch (e) {
      print(e.response?.data);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}