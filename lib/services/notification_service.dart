import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    // Tạo kênh thông báo cho Android
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'Thông báo ứng dụng',
      description: 'Kênh thông báo của ứng dụng',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    // Yêu cầu quyền thông báo trên Android
    final platform = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (platform != null) {
      await platform.createNotificationChannel(androidChannel);
    }

    const androidInitialize =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInitialize = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        debugPrint("Notification clicked: ${details.payload}");
      },
    );

    // Kiểm tra quyền thông báo
    final notificationSettings = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.getNotificationAppLaunchDetails();

    if (notificationSettings?.didNotificationLaunchApp ?? false) {
      debugPrint('App launched from notification');
    }

    _initialized = true;
    debugPrint('NotificationService initialized successfully');
  }

  Future<void> showWelcomeNotification() async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized');
      return;
    }

    try {
      final androidDetails = const AndroidNotificationDetails(
        'high_importance_channel',
        'Thông báo ứng dụng',
        channelDescription: 'Kênh thông báo của ứng dụng',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.message,
        visibility: NotificationVisibility.public,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notifications.show(
        0,
        'Chào mừng bạn đến với MasterQuiz! 👋',
        'Đăng nhập để bắt đầu hành trình học tập ngay hôm nay!',
        notificationDetails,
      );
      debugPrint("Welcome notification sent successfully");
    } catch (e) {
      debugPrint('Error showing welcome notification: $e');
    }
  }

  Future<void> scheduleStudyReminder() async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized');
      return;
    }

    try {
      final androidDetails = const AndroidNotificationDetails(
        'high_importance_channel',
        'Thông báo ứng dụng',
        channelDescription: 'Kênh thông báo của ứng dụng',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      final scheduledTime =
          tz.TZDateTime.now(tz.local).add(const Duration(minutes: 30));
      await _notifications.zonedSchedule(
        1,
        'Đã đến giờ ôn tập rồi nè! 📚',
        'Hãy quay lại và tiếp tục hành trình của bạn',
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint("Study reminder scheduled for: $scheduledTime");
    } catch (e) {
      debugPrint('Error scheduling study reminder: $e');
    }
  }
}
