import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rattel/app/data/services/user_data_service.dart';
import 'package:rattel/app/data/services/auth_service.dart';

/// Notification service for daily reminders
class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isSupported = false;

  Future<NotificationService> init() async {
    // Only initialize on mobile platforms
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      debugPrint('📢 Notifications not supported on this platform');
      _isSupported = false;
      return this;
    }

    _isSupported = true;
    tz.initializeTimeZones();

    // Initialize Firebase Messaging
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    // Retrieval of token
    await _saveFcmToken();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    return this;
  }

  // Firebase Messaging instance
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Save FCM token to Firestore
  Future<void> _saveFcmToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        final user = AuthService.instance.currentUser;
        if (user != null && user.userId != null) {
          // Note: using user.userId.toString() as document ID for Firebase if needed,
          // or just link it to the email.
          await UserDataService().setUserData(user.userId.toString(), {
            'fcmToken': token,
          });
        }
      }
    } catch (e) {
      debugPrint('⚠️ Failed to save FCM token: $e');
    }
  }

  /// Schedule daily reminder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (!_isSupported) return;

    await _notifications.zonedSchedule(
      0,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Daily Quran memorization reminder',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel daily reminder
  Future<void> cancelDailyReminder() async {
    if (!_isSupported) return;
    await _notifications.cancel(0);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
