import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/features/attendance/data/models/approval_detail_model.dart';
import 'package:psm_mobile/features/attendance/data/models/approval_model.dart';

abstract class ApprovalRemoteDataSource {
  Future<List<ApprovalModel>> getApprovalList(String type);
  Future<List<ApprovalDetailModel>> getApprovalDetail(int id);
  Future<String> approveShift({
    required int pergantianShiftId,
    required int userId,
    required bool approved,
    String? rejectReason,
  });
}

class ApprovalRemoteDataSourceImpl implements ApprovalRemoteDataSource {
  final DioClient _dioClient;

  ApprovalRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ApprovalModel>> getApprovalList(String type) async {
    try {
      final response = await _dioClient.instance.get(
        '/pergantian-shift/list',
        queryParameters: {'page': 1, 'perPage': 1000, 'type': type},
      );

      if (response.data != null && response.data['status'] == true) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => ApprovalModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ApprovalDetailModel>> getApprovalDetail(int id) async {
    try {
      final response = await _dioClient.instance.get(
        '/pergantian-shift/detail',
        queryParameters: {'id': id},
      );

      if (response.data != null) {
        if (response.data['status'] == true) {
          final data = response.data['data'];
          if (data != null) {
            // Handle both single object and list responses
            if (data is List) {
              return data
                  .map((json) => ApprovalDetailModel.fromJson(json))
                  .toList();
            } else {
              return [ApprovalDetailModel.fromJson(data)];
            }
          }
        } else {
          throw response.data['message'] ?? 'Gagal mendapatkan detail lokasi';
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> approveShift({
    required int pergantianShiftId,
    required int userId,
    required bool approved,
    String? rejectReason,
  }) async {
    try {
      final response = await _dioClient.instance.post(
        '/pergantian-shift/approve',
        data: {
          "pergantianShiftId": pergantianShiftId,
          "userId": userId,
          "approved": approved,
          "rejectReason": rejectReason,
        },
      );

      if (response.data != null && response.data['status'] == true) {
        return response.data['message'] ?? 'Berhasil menyetujui pergantian shift';
      } else {
        throw response.data['message'] ?? 'Gagal memproses persetujuan';
      }
    } catch (e) {
      rethrow;
    }
  }
}
