import 'package:psm_mobile/features/spm/data/models/spm_detail_model.dart';
import 'package:psm_mobile/features/spm/data/models/spm_question_model.dart';
import 'package:psm_mobile/features/spm/data/models/spm_task_model.dart';

abstract class SpmRepository {
  Future<List<SpmTaskModel>> getSpmList({
    String keyword = '',
    int page = 1,
    int perPage = 999,
  });

  Future<List<SpmQuestionModel>> getSpmQuestions(int idTypePemeriksaan);

  Future<List<SpmDetailModel>> getSpmDetail(int id);

  Future<int> createSpm(Map<String, dynamic> payload);
  Future<void> submitSpmData(List<int> idAuditTrail, String reason);
}
