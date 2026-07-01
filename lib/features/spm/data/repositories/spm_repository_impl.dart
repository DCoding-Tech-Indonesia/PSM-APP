import 'package:psm_mobile/features/spm/data/datasources/spm_remote_data_source.dart';
import 'package:psm_mobile/features/spm/data/models/spm_detail_model.dart';
import 'package:psm_mobile/features/spm/data/models/spm_question_model.dart';
import 'package:psm_mobile/features/spm/data/models/spm_task_model.dart';
import 'package:psm_mobile/features/spm/domain/repositories/spm_repository.dart';

class SpmRepositoryImpl implements SpmRepository {
  final SpmRemoteDataSource remoteDataSource;

  SpmRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SpmTaskModel>> getSpmList({
    String keyword = '',
    int page = 1,
    int perPage = 999,
  }) async {
    return await remoteDataSource.fetchSpmList(
      keyword: keyword,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<List<SpmQuestionModel>> getSpmQuestions(int idTypePemeriksaan) async {
    return await remoteDataSource.fetchSpmQuestions(idTypePemeriksaan);
  }

  @override
  Future<List<SpmDetailModel>> getSpmDetail(int id) async {
    return await remoteDataSource.fetchSpmDetail(id);
  }

  @override
  Future<int> createSpm(Map<String, dynamic> payload) async {
    return await remoteDataSource.createSpm(payload);
  }

  @override
  Future<String> submitSpmData(List<int> idAuditTrail, String reason) async {
    return await remoteDataSource.submitSpmData(
      idAuditTrail: idAuditTrail,
      reason: reason,
    );
  }
}
