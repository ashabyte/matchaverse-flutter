import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (!kIsWeb) {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('FCM permission: ${settings.authorizationStatus}');
    }

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    if (!kIsWeb) {
      final token = await _fcm.getToken();
      debugPrint('FCM Token: $token');
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground FCM: ${message.notification?.title}');
    await showNotification(
      title: message.notification?.title ?? 'MatchaVerse',
      body: message.notification?.body ?? '',
      channelId: 'matchatea_general',
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Background FCM: ${message.notification?.title}');
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Notification opened app: ${message.data}');
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String channelId = 'matchatea_general',
    String channelName = 'MatchaVerse Notifications',
    String? payload,
  }) async {
    if (kIsWeb) return;

    // ✅ FIX: hapus parameter color (deprecated di versi terbaru)
    // ✅ FIX: hapus class Color buatan sendiri di bawah — bentrok dengan dart:ui
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future<void> showCaffeineAlert({
    required String title,
    required String body,
  }) async {
    await showNotification(
      title: title,
      body: body,
      channelId: 'caffeine_alert',
      channelName: 'Caffeine Alerts',
    );
  }

  static Future<void> showMissionReminder({required String missionTitle}) async {
    await showNotification(
      title: '🏆 Misi Belum Selesai!',
      body: 'Kamu belum menyelesaikan: "$missionTitle". Selesaikan sekarang untuk poin!',
      channelId: 'mission_reminder',
      channelName: 'Mission Reminders',
    );
  }

  static Future<void> scheduleDailyReminder() async {
    if (kIsWeb) return;
    await showNotification(
      title: '🍵 Waktu Matcha Pagi!',
      body: 'Mulai hari dengan secangkir matcha. Jangan lupa cek misi harianmu!',
      channelId: 'daily_reminder',
      channelName: 'Daily Reminders',
    );
  }

  static Future<String?> getFcmToken() async {
    if (kIsWeb) return null;
    return await _fcm.getToken();
  }
}