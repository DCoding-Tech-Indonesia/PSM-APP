import 'package:travis/features/attendance/data/models/leave_request_model.dart';

abstract class LeaveRequestRepository {
  Future<List<LeaveRequestModel>> getLeaveRequestList({
    int page = 1,
    int perPage = 10,
    String status = '',
    String type = '',
    int? userId,
    String keyword = '',
  });

  Future<bool> submitLeaveRequest({
    required int userId,
    required String typePengajuan,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String alasan,
  });

  Future<LeaveRequestModel?> getLeaveRequestDetail({required int id});

  Future<String> approveLeaveRequest({
    required int pengajuanRequestId,
    required int approvedByUserId,
    required bool approved,
    required String rejectReason,
  });
}
