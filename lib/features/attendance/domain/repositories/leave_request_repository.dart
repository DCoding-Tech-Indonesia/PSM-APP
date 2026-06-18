import 'package:psm_mobile/features/attendance/data/models/leave_request_model.dart';

abstract class LeaveRequestRepository {
  Future<List<LeaveRequestModel>> getLeaveRequestList({
    int page = 1,
    int perPage = 10,
    String status = '',
    String type = '',
    required int userId,
    String keyword = '',
  });

  Future<bool> submitLeaveRequest({
    required int userId,
    required String typePengajuan,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String alasan,
  });
}
