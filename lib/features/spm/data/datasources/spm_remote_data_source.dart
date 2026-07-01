import 'package:dio/dio.dart';
import 'package:psm_mobile/features/spm/data/models/spm_detail_model.dart';
import 'package:psm_mobile/features/spm/data/models/spm_question_model.dart';
import 'package:psm_mobile/features/spm/data/models/spm_task_model.dart';

class SpmRemoteDataSource {
  final Dio dio;

  SpmRemoteDataSource({required this.dio});

  Future<List<SpmTaskModel>> fetchSpmList({
    String keyword = '',
    int page = 1,
    int perPage = 999,
  }) async {
    try {
      final response = await dio.get(
        '/audittrail/task/spm/list',
        queryParameters: {"keyword": keyword, "page": page, "perPage": perPage},
      );

      final data = response.data['data'] as List?;
      if (data != null) {
        return data.map((e) => SpmTaskModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SpmDetailModel>> fetchSpmDetail(int id) async {
    try {
      final response = await dio.get(
        '/audittrail/task/spm/detail',
        queryParameters: {'id': id},
      );

      if (response.data != null) {
        if (response.data['status'] == true) {
          final data = response.data['data'];
          if (data != null) {
            if (data is List) {
              return data.map((json) => SpmDetailModel.fromJson(json)).toList();
            }
          } else {
            return [SpmDetailModel.fromJson(data)];
          }
        } else {
          throw response.data['message'] ?? 'Gagal mendapatkan detail SPM';
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SpmQuestionModel>> fetchSpmQuestions(
    int idTypePemeriksaan,
  ) async {
    try {
      final response = await dio.get(
        '/indikatorspm/question/detail',
        queryParameters: {'idTypePemeriksaan': idTypePemeriksaan},
      );

      final data = response.data['data'] as List?;
      if (data != null) {
        return data.map((e) => SpmQuestionModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<int> createSpm(Map<String, dynamic> payload) async {
    try {
      final response = await dio.post('/pemeriksaan-spm/create', data: payload);
      if (response.data != null && response.data['status'] == true) {
        final data = response.data['data'] as List?;
        if (data != null && data.isNotEmpty) {
          final auditTrailId = data.first['auditTrailId'] as num?;
          if (auditTrailId != null) {
            return auditTrailId.toInt();
          }
        }
      }
      throw Exception(response.data?['message'] ?? 'Gagal menyimpan data');
    } catch (e) {
      rethrow;
    }
  }

  Future<String> submitSpmData({
    required List<int> idAuditTrail,
    required String reason,
  }) async {
    try {
      final response = await dio.post(
        '/workflow/submit',
        data: {"idAuditTrail": idAuditTrail, "reason": reason},
      );

      if (response.data != null && response.data['status'] == true) {
        return response.data['message'] ?? 'Berhasil menyimpan data SPM';
      }
      if (response.data != null && response.data['status'] == false) {
        throw Exception(response.data['message'] ?? 'Gagal menyimpan SPM');
      }
      return 'Berhasil menyimpan data SPM';
      // if (response.data['status'] != true) {
      //   throw Exception(response.data['message'] ?? 'Gagal submit data');
      // }
    } catch (e) {
      rethrow;
    }
  }
}
