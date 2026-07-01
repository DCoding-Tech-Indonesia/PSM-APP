import 'package:psm_mobile/features/checklist/data/datasources/checklist_remote_data_source.dart';
import 'package:psm_mobile/features/checklist/data/models/checklist_item_model.dart';
import 'package:psm_mobile/features/checklist/data/models/checklist_question_model.dart';
import 'package:psm_mobile/features/checklist/domain/repositories/checklist_repository.dart';

class ChecklistRepositoryImpl implements ChecklistRepository {
  final ChecklistRemoteDataSource remoteDataSource;

  ChecklistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ChecklistItemModel>> getChecklistList({
    String keyword = '',
    int page = 1,
    int perPage = 1073741824,
  }) async {
    return await remoteDataSource.fetchChecklistList(
      keyword: keyword,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<List<ChecklistQuestionModel>> getChecklistQuestions({
    required String tipeForm,
    String keyword = '',
    int page = 1,
    int perPage = 999,
  }) async {
    return await remoteDataSource.getChecklistQuestions(
      tipeForm: tipeForm,
      keyword: keyword,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<String> createChecklist(Map<String, dynamic> payload) async {
    return remoteDataSource.createChecklist(payload);
  }
}
