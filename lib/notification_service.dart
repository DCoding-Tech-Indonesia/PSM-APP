import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:psm_mobile/core/notification/approval_refresh_notifier.dart';
import 'package:psm_mobile/core/router/app_router.dart';

// Fungsi global untuk handle notifikasi saat aplikasi mati (terminated) atau di background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("=== NOTIF BACKGROUND / TERMINATED MASUK ===");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
    print("Data: ${message.data}");
    print("===========================================");
  }
}

class NotificationService {
  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';
  static const String _androidSound = 'notification';
  static const String _iosSound = 'notification.caf';
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        _channelId,
        _channelName,
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(_androidSound),
      );

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      sound: RawResourceAndroidNotificationSound(_androidSound),
    ),

    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: _iosSound,
    ),
  );

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    // 1. Minta izin ke user (Wajib untuk iOS & Android 13+)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('Izin diberikan oleh user!');
      }

      // 2. Ambil Token FCM (Kunci untuk kirim notifikasi ke hp ini)
      String? token = await _messaging.getToken();

      if (kDebugMode) {
        print("=== FCM TOKEN ANDA ===");
        print(token); // Copy token ini nanti di console untuk test
        print("======================");
      }

      // 3. Setup local notification + channel dengan custom sound
      await _initLocalNotification();

      // Handle klik dari background (app ada di recents tapi tertutup)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _notifyApprovalRefreshIfNeeded(message.data);
        _handleNotificationClick(message.data);
      });

      // Handle klik dari completely terminated
      RemoteMessage? initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();

      if (initialMessage != null) {
        Future.delayed(const Duration(seconds: 2), () {
          _handleNotificationClick(initialMessage.data);
        });
      }

      // 4. Handle Notifikasi Background / Terminated
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // 5. Handle Notifikasi saat aplikasi sedang TERBUKA (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print("=== NOTIF FOREGROUND MASUK ===");
          print("Title: ${message.notification?.title}");
          print("Body: ${message.notification?.body}");
          print("Data: ${message.data}");
          print("==============================");
        }

        final RemoteNotification? notification = message.notification;

        // Jika notif ada isi nilainya, munculkan lewat local notification
        if (notification != null) {
          _localNotif.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: _notificationDetails,
            payload: jsonEncode(message.data),
          );
        }

        _notifyApprovalRefreshIfNeeded(message.data);
      });
    }
  }

  Future<void> _initLocalNotification() async {
    const AndroidInitializationSettings initAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: initAndroid,
      iOS: initIOS,
    );

    await _localNotif.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('--- LOCAL NOTIF TAPPED ---');
        debugPrint('Payload: ${response.payload}');

        if (response.payload != null) {
          try {
            final Map<String, dynamic> data = jsonDecode(response.payload!);
            _handleNotificationClick(data);
          } catch (e) {
            debugPrint('Failed to parse payload: $e');
          }
        }
      },
    );

    await _localNotif
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);
  }

  void _notifyApprovalRefreshIfNeeded(Map<String, dynamic> data) {
    if (ApprovalRefreshNotifier.instance.shouldRefreshFor(data)) {
      if (kDebugMode) {
        debugPrint('[NOTIF] Trigger refresh approval list');
      }
      ApprovalRefreshNotifier.instance.notifyRefresh();
    }
  }

  void _handleNotificationClick(Map<String, dynamic> data) {
    debugPrint('--- HANDLING NOTIF CLICK ---');
    debugPrint('Data: $data');
    _notifyApprovalRefreshIfNeeded(data);

    final screen = data['screen'];
    final idStr = data['id']?.toString();

    debugPrint('Screen targeted: $screen, ID: $idStr');

    if (screen == 'approval_pergantian_shift') {
      debugPrint('Pushing route /approval-detail');
      appRouter.push('/approval-detail', extra: idStr);
    } else if (screen == 'detail_pergantian_shift') {
      try {
        final idVal = data['id'];
        Map<String, dynamic> detail = {};
        if (idVal is Map) {
          detail = Map<String, dynamic>.from(idVal);
        } else if (idVal is String) {
          detail = jsonDecode(idVal) as Map<String, dynamic>;
        }
        _showPergantianShiftBottomSheet(detail);
      } catch (e) {
        debugPrint('Error parsing detail_pergantian_shift: $e');
      }
    } else if (screen == 'approval_pengajuan' || screen == 'detail_pengajuan') {
      debugPrint('Pushing route /leave-request-detail');
      appRouter.push('/leave-request-detail', extra: idStr);
    }
  }

  void _showPergantianShiftBottomSheet(Map<String, dynamic> detail) {
    final context = appRouter.routerDelegate.navigatorKey.currentContext;
    if (context == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible:
          false, // User must tap button, tapping outside will not close
      enableDrag: false, // User cannot swipe down to close
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) {
        return _ShiftReplacementBottomSheet(detail: detail);
      },
    );
  }
}

class _ShiftReplacementBottomSheet extends StatefulWidget {
  final Map<String, dynamic> detail;

  const _ShiftReplacementBottomSheet({required this.detail});

  @override
  State<_ShiftReplacementBottomSheet> createState() =>
      _ShiftReplacementBottomSheetState();
}

class _ShiftReplacementBottomSheetState
    extends State<_ShiftReplacementBottomSheet> {
  int _secondsRemaining = 20;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        _timer?.cancel();
        ApprovalRefreshNotifier.instance.notifyRefresh();
        if (mounted) {
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final requester = widget.detail['requester']?.toString() ?? '-';
    final replacement = widget.detail['replacement']?.toString() ?? '-';
    final dateRaw = widget.detail['tanggal']?.toString() ?? '-';
    final dateFormatted = _formatDate(dateRaw);
    final shift = widget.detail['shift']?.toString() ?? '-';
    final status = (widget.detail['status']?.toString() ?? '').toUpperCase();
    final approvedBy = widget.detail['approvedBy']?.toString() ?? '';
    final alasanReject = widget.detail['alasanReject']?.toString() ?? '';

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (status == 'APPROVED') {
      statusColor = const Color(0xFF10B981); // Emerald Green
      statusIcon = Icons.check_circle_outline;
      statusText = 'DISETUJUI';
    } else if (status == 'REJECTED' || status == 'REJECT') {
      statusColor = const Color(0xFFEF4444); // Rose Red
      statusIcon = Icons.cancel_outlined;
      statusText = 'DITOLAK';
    } else {
      statusColor = const Color(0xFFF59E0B); // Amber Orange
      statusIcon = Icons.hourglass_empty_rounded;
      statusText = 'MENUNGGU';
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 10,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Detail Pergantian Shift',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Visual Swap Card (Requester to Replacement)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Requester Profile
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: theme.primaryColor.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          requester.isNotEmpty
                              ? requester[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Pemohon',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        requester,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Swap Arrow / Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.swap_horiz_rounded,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                ),

                // Replacement Profile
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.orange.withValues(alpha: 0.1),
                        child: Text(
                          replacement.isNotEmpty
                              ? replacement[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Pengganti',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        replacement,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Date & Shift Info Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color ?? theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanggal',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              dateFormatted,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color ?? theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shift',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              shift,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (approvedBy.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardTheme.color ?? theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    status == 'APPROVED'
                        ? Icons.verified_user_outlined
                        : Icons.cancel_outlined,
                    color: status == 'APPROVED'
                        ? Color(0xFF10B981)
                        : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${status == 'APPROVED' ? 'Disetujui' : 'Ditolak'} Oleh',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          approvedBy,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (alasanReject.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Alasan Penolakan',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    alasanReject,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: isDark ? Colors.red.shade200 : Colors.red.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Tutup Button with countdown
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: Text(
              'Tutup (${_secondsRemaining}s)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
