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
* Authors: <Anajak Chuamuangphan 650510692/ zoozoo>
* Course: Mobile App Development
*/

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Provides a wrapper for managing local notifications in the app.
///
/// This service initializes the notification plugin and exposes
/// methods to display notifications on the device.
///
/// Responsibilities:
/// - Initialize the local notification system
/// - Request notification permissions (Android)
/// - Display high-priority notifications
///
/// Notes:
/// - All methods are static and the class is not meant to be instantiated
/// - Must call [init] before showing notifications
/// - Uses Flutter Local Notifications plugin
class NotificationService {

  /// The underlying plugin instance used to interact with
  /// the device's notification system.
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Initializes the local notification system.
  ///
  /// This method sets up platform-specific initialization settings
  /// and requests notification permission on supported platforms.
  ///
  /// Async behavior:
  /// - Performs platform initialization
  /// - May prompt the user for permission
  ///
  /// Side effects:
  /// - Enables the app to send notifications
  /// - Displays a permission dialog on Android (if required)
  ///
  /// This method should be called once during app startup.
  static Future init() async {

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _notifications.initialize(settings);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Displays a local notification with the given title and message.
  ///
  /// The notification is configured with high importance and
  /// priority to ensure visibility to the user.
  ///
  /// Parameters:
  /// - [title]: The notification title text
  /// - [body]: The notification body message
  ///
  /// Async behavior:
  /// - Communicates with the platform notification system
  ///
  /// Side effects:
  /// - Shows a notification on the user's device
  ///
  /// A unique notification ID is generated based on the current time
  /// to prevent collisions with existing notifications.
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