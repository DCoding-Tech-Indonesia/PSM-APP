import 'package:psm_mobile/features/checklist/data/models/checklist_item_model.dart';
import 'package:psm_mobile/features/checklist/data/models/checklist_question_model.dart';

abstract class ChecklistRepository {
  Future<List<ChecklistItemModel>> getChecklistList({
    String keyword = '',
    int page = 1,
    int perPage = 1073741824,
  });

  Future<List<ChecklistQuestionModel>> getChecklistQuestions({
    required String tipeForm,
    String keyword = '',
    int page = 1,
    int perPage = 999,
  });

  Future<String> createChecklist(Map<String, dynamic> payload);
}
