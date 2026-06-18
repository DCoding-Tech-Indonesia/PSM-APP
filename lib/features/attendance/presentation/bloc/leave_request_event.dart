abstract class LeaveRequestEvent {}

class LoadLeaveRequestList extends LeaveRequestEvent {
  final int page;
  final int perPage;
  final String status;
  final String type;
  final int userId;
  final String keyword;

  LoadLeaveRequestList({
    this.page = 1,
    this.perPage = 10,
    this.status = '',
    this.type = '',
    required this.userId,
    this.keyword = '',
  });
}

class SubmitLeaveRequest extends LeaveRequestEvent {
  final int userId;
  final String typePengajuan;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String alasan;

  SubmitLeaveRequest({
    required this.userId,
    required this.typePengajuan,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.alasan,
  });
}
