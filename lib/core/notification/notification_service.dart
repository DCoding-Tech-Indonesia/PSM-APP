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

    // FlutterLocalNotificationsPlugin is initialized in lib/notification_service.dart
    // Initialization here was causing a conflict and removing the onDidReceiveNotificationResponse listener.
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
