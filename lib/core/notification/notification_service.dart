import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationServices {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotification(
    NotificationResponse notificationResponse,
  ) async {}

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    final String wibTimeZone = 'Asia/Jakarta';

    tz.setLocalLocation(tz.getLocation(wibTimeZone));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> showNotification(String title, String body) async {
    _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "0",
          "Notif",
          importance: Importance.max,
        ),
      ),
    );
  }
}
