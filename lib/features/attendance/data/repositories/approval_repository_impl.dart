import 'package:psm_mobile/features/attendance/data/datasources/approval_remote_data_source.dart';
import 'package:psm_mobile/features/attendance/data/models/approval_detail_model.dart';
import 'package:psm_mobile/features/attendance/data/models/approval_model.dart';
import 'package:psm_mobile/features/attendance/domain/repositories/approval_repository.dart';

class ApprovalRepositoryImpl implements ApprovalRepository {
  final ApprovalRemoteDataSource remoteDataSource;

  ApprovalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ApprovalModel>> getApprovalList(String type) async {
    return await remoteDataSource.getApprovalList(type);
  }

  @override
  Future<List<ApprovalDetailModel>> getApprovalDetail(int id) async {
    return await remoteDataSource.getApprovalDetail(id);
  }

  @override
  Future<String> approveShift({
    required int pergantianShiftId,
    required int userId,
    required bool approved,
    String? rejectReason,
  }) async {
    return await remoteDataSource.approveShift(
      pergantianShiftId: pergantianShiftId,
      userId: userId,
      approved: approved,
      rejectReason: rejectReason,
    );
  }
}
