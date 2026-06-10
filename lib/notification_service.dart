import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
            notification.hashCode,
            notification.title,
            notification.body,
            _notificationDetails,
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
      initSettings,
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
    }
  }
}
