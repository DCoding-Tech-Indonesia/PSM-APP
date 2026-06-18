import 'package:psm_mobile/features/attendance/data/models/approval_detail_model.dart';
import 'package:psm_mobile/features/attendance/data/models/approval_model.dart';

abstract class ApprovalRepository {
  Future<List<ApprovalModel>> getApprovalList(String type);
  Future<List<ApprovalDetailModel>> getApprovalDetail(int id);
  Future<bool> approveShift({
    required int pergantianShiftId,
    required int userId,
    required bool approved,
    String? rejectReason,
  });
}
