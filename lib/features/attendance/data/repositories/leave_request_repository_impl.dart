import 'package:travis/features/attendance/data/datasources/leave_request_remote_data_source.dart';
import 'package:travis/features/attendance/data/models/leave_request_model.dart';
import 'package:travis/features/attendance/domain/repositories/leave_request_repository.dart';

class LeaveRequestRepositoryImpl implements LeaveRequestRepository {
  final LeaveRequestRemoteDataSource remoteDataSource;

  LeaveRequestRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<LeaveRequestModel>> getLeaveRequestList({
    int page = 1,
    int perPage = 10,
    String status = '',
    String type = '',
    int? userId,
    String keyword = '',
  }) async {
    return await remoteDataSource.getLeaveRequestList(
      page: page,
      perPage: perPage,
      status: status,
      type: type,
      userId: userId,
      keyword: keyword,
    );
  }

  @override
  Future<bool> submitLeaveRequest({
    required int userId,
    required String typePengajuan,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String alasan,
  }) async {
    return await remoteDataSource.submitLeaveRequest(
      userId: userId,
      typePengajuan: typePengajuan,
      tanggalMulai: tanggalMulai,
      tanggalSelesai: tanggalSelesai,
      alasan: alasan,
    );
  }

  @override
  Future<LeaveRequestModel?> getLeaveRequestDetail({required int id}) async {
    return await remoteDataSource.getLeaveRequestDetail(id: id);
  }

  @override
  Future<String> approveLeaveRequest({
    required int pengajuanRequestId,
    required int approvedByUserId,
    required bool approved,
    required String rejectReason,
  }) async {
    return await remoteDataSource.approveLeaveRequest(
      pengajuanRequestId: pengajuanRequestId,
      approvedByUserId: approvedByUserId,
      approved: approved,
      rejectReason: rejectReason,
    );
  }
}
