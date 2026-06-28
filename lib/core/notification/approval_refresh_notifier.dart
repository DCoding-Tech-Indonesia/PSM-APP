import 'dart:async';

/// Broadcast event agar [ApprovalScreen] bisa refresh list
/// ketika notifikasi approval masuk (foreground / tap notif).
class ApprovalRefreshNotifier {
  ApprovalRefreshNotifier._();

  static final ApprovalRefreshNotifier instance = ApprovalRefreshNotifier._();

  final StreamController<void> _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  bool shouldRefreshFor(Map<String, dynamic> data) {
    final screen = data['screen']?.toString().toLowerCase() ?? '';
    final type = data['type']?.toString().toLowerCase() ?? '';

    return screen.contains('approval') ||
        type.contains('approval') ||
        screen == 'approval_pergantian_shift' ||
        screen == 'approval_pengajuan';
  }

  void notifyRefresh() {
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }

  void dispose() {
    _controller.close();
  }
}
