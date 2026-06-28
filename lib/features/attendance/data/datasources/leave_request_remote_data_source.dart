import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/features/attendance/data/models/leave_request_model.dart';

abstract class LeaveRequestRemoteDataSource {
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

class LeaveRequestRemoteDataSourceImpl implements LeaveRequestRemoteDataSource {
  final DioClient _dioClient;

  LeaveRequestRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<LeaveRequestModel>> getLeaveRequestList({
    int page = 1,
    int perPage = 10,
    String status = '',
    String type = '',
    int? userId,
    String keyword = '',
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'perPage': perPage,
      };

      if (userId != null) queryParameters['userId'] = userId;

      if (status.isNotEmpty) queryParameters['status'] = int.parse(status);
      if (type.isNotEmpty) queryParameters['type'] = int.parse(type);
      if (keyword.isNotEmpty) queryParameters['keyword'] = int.parse(keyword);

      final response = await _dioClient.instance.get(
        '/pengajuan/list',
        queryParameters: queryParameters,
      );

      if (response.data != null && response.data['status'] == true) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => LeaveRequestModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> submitLeaveRequest({
    required int userId,
    required String typePengajuan,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String alasan,
  }) async {
    try {
      final data = {
        "userId": userId,
        "typePengajuan": typePengajuan,
        "tanggalMulai": tanggalMulai,
        "tanggalSelesai": tanggalSelesai,
        "alasan": alasan,
      };

      final response = await _dioClient.instance.post(
        '/pengajuan',
        data: data,
      );

      if (response.data != null) {
        if (response.data['status'] == true) {
          return true;
        } else if (response.data['message'] != null) {
          throw response.data['message'];
        }
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LeaveRequestModel?> getLeaveRequestDetail({required int id}) async {
    try {
      final response = await _dioClient.instance.get(
        '/pengajuan/detail',
        queryParameters: {'id': id},
      );
      if (response.data != null && response.data['status'] == true) {
        final List data = response.data['data'] ?? [];
        if (data.isNotEmpty) {
          return LeaveRequestModel.fromJson(data.first);
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> approveLeaveRequest({
    required int pengajuanRequestId,
    required int approvedByUserId,
    required bool approved,
    required String rejectReason,
  }) async {
    try {
      final data = {
        "pengajuanRequestId": pengajuanRequestId,
        "approvedByUserId": approvedByUserId,
        "approved": approved,
        "rejectReason": rejectReason,
      };

      final response = await _dioClient.instance.post(
        '/pengajuan/approve',
        data: data,
      );

      if (response.data != null && response.data['status'] == true) {
        return response.data['message'] ?? 'Berhasil memproses pengajuan';
      } else {
        throw response.data['message'] ?? 'Gagal memproses pengajuan';
      }
    } catch (e) {
      rethrow;
    }
  }
}
