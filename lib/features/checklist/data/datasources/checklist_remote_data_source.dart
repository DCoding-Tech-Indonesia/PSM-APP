import 'package:dio/dio.dart';
import 'package:psm_mobile/features/checklist/data/models/checklist_item_model.dart';
import 'package:psm_mobile/features/checklist/data/models/checklist_question_model.dart';

class ChecklistRemoteDataSource {
  final Dio dio;

  ChecklistRemoteDataSource({required this.dio});

  Future<List<ChecklistItemModel>> fetchChecklistList({
    String keyword = '',
    int page = 1,
    int perPage = 1073741824,
  }) async {
    try {
      final response = await dio.get(
        '/daily-checklist/list',
        queryParameters: {"keyword": keyword, "page": page, "perPage": perPage},
      );

      final data = response.data['data'] as List?;
      if (data != null) {
        return data.map((e) => ChecklistItemModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ChecklistQuestionModel>> getChecklistQuestions({
    required String tipeForm,
    String keyword = '',
    int page = 1,
    int perPage = 999,
  }) async {
    try {
      final response = await dio.get(
        '/checklist-question/list',
        queryParameters: {
          "keyword": keyword,
          "tipeForm": tipeForm,
          "page": page,
          "perPage": perPage,
        },
      );

      final data = response.data['data'] as List?;
      if (data != null) {
        return data.map((e) => ChecklistQuestionModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createChecklist(Map<String, dynamic> payload) async {
    try {
      final response = await dio.post('/daily-checklist/create', data: payload);

      if (response.data != null && response.data['status'] == true) {
        return response.data['message'] ?? 'Berhasil menyimpan data checklist';
      }
      if (response.data != null && response.data['status'] == false) {
        throw Exception(
          response.data['message'] ?? 'Gagal menyimpan checklist',
        );
      }
      return 'Berhasil menyimpan data checklist';
    } catch (e) {
      rethrow;
    }
  }
}
