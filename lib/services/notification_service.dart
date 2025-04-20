import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:typed_data';

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
    tz.setLocalLocation(
        tz.getLocation('Asia/Ho_Chi_Minh')); // Đặt múi giờ Việt Nam

    // Tạo kênh thông báo cho Android với âm thanh và độ ưu tiên cao
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
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const iOSInitialize = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
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

    _initialized = true;
    debugPrint('NotificationService initialized successfully');
  }

  Future<void> showWelcomeNotification() async {
    if (!_initialized) {
      debugPrint('NotificationService not initialized');
      return;
    }

    try {
      final androidDetails = AndroidNotificationDetails(
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
        icon: '@mipmap/launcher_icon',
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
      await initialize();
    }

    try {
      // Hủy thông báo cũ nếu có
      await _notifications.cancel(1);

      final androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'Thông báo ứng dụng',
        channelDescription: 'Kênh thông báo của ứng dụng',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
        icon: '@mipmap/launcher_icon',
      );

      final iOSDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = now.add(const Duration(minutes: 30));

      // Đảm bảo thời gian lên lịch trong tương lai
      final effectiveDate = scheduledDate.isBefore(now)
          ? now.add(const Duration(seconds: 5))
          : scheduledDate;

      await _notifications.zonedSchedule(
        1,
        'Đã đến giờ ôn tập rồi nè! 📚',
        'Hãy quay lại và tiếp tục hành trình của bạn',
        effectiveDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      debugPrint("Study reminder scheduled for: $effectiveDate");
    } catch (e) {
      debugPrint('Error scheduling study reminder: $e');
      // Thử lại với cấu hình đơn giản hơn nếu có lỗi
      await _scheduleBasicReminder();
    }
  }

  Future<void> _scheduleBasicReminder() async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'Thông báo ứng dụng',
        channelDescription: 'Kênh thông báo của ứng dụng',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(),
      );

      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = now.add(const Duration(minutes: 30));

      await _notifications.zonedSchedule(
        1,
        'Đã đến giờ ôn tập rồi nè! 📚',
        'Hãy quay lại và tiếp tục hành trình của bạn',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      debugPrint("Basic reminder scheduled for: $scheduledDate");
    } catch (e) {
      debugPrint('Error scheduling basic reminder: $e');
    }
  }
}
