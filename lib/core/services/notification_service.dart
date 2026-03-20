/*
* File: notification_service.dart
* Description: Provides a centralized service for initializing and displaying local push notifications on Android devices, including support for high-priority mood reminders in the MindCare app.
*
* Responsibilities:
* - Initialize local notification settings for Android devices
* - ขออนุญาตการแจ้งเตือนจากผู้ใช้
* - แสดงการแจ้งเตือนแบบ high-priority สำหรับ Mood Reminder
* - ใช้งาน NotificationService ได้แบบ static ทั่วทั้งแอป
*
* Authors: <Anajak Chuamuangphan/ zoozoo>
* Course: Mobile App Development
*/
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future init() async {

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _notifications.initialize(settings);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future show(String title, String body) async {

    const android = AndroidNotificationDetails(
      'mood_channel',
      'Mood Notification',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: android);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}