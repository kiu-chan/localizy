import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:localizy/api/auth_api.dart';
import 'package:localizy/screens/main_page.dart';
import 'package:localizy/screens/validator/validator_main_page.dart';
import 'package:localizy/screens/business/business_main_page.dart';

// Channel dùng cho local notifications trên Android
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'citea_notifications',
  'Citea Notifications',
  description: 'Thông báo từ ứng dụng Citea',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

/// Background handler — phải là top-level function (không phải method)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] messageId=${message.messageId}');
}

/// GlobalKey dùng để navigate từ notification khi không có BuildContext.
/// Gán vào MaterialApp.navigatorKey trong main.dart.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  /// Khởi tạo toàn bộ FCM pipeline.
  /// Gọi trong main() sau Firebase.initializeApp().
  static Future<void> initialize() async {
    // 1. Đăng ký background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Cài đặt flutter_local_notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Tạo notification channel cho Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 3. Xin quyền notification (iOS + Android 13+)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 4. Foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 5. Tap vào notification khi app ở background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpen);

    // 6. Lắng nghe token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);

    // 7. Xử lý trường hợp app mở từ trạng thái đã tắt (terminated)
    final initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // Delay nhỏ để Navigator đã sẵn sàng
      await Future.delayed(const Duration(milliseconds: 500));
      _handleMessageOpen(initialMessage);
    }
  }

  /// Lấy FCM token và đăng ký lên server. Gọi ngay sau khi login thành công.
  static Future<void> getAndRegisterToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await AuthService.registerFcmToken(token);
        debugPrint('[FCM] Token registered with server.');
      }
    } catch (e) {
      // Non-critical — không throw, chỉ log
      debugPrint('[FCM] Failed to register token: $e');
    }
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['validationId'],
    );
  }

  static void _handleMessageOpen(RemoteMessage message) {
    final type = message.data['type'] as String?;
    final validationId = message.data['validationId'] as String?;
    debugPrint('[FCM] Notification opened: type=$type validationId=$validationId');
    _navigateToRelevantScreen();
  }

  static void _onLocalNotificationTap(NotificationResponse response) {
    debugPrint('[FCM] Local notification tapped: payload=${response.payload}');
    _navigateToRelevantScreen();
  }

  /// Điều hướng đến màn hình chính dựa theo role đã lưu.
  static Future<void> _navigateToRelevantScreen() async {
    try {
      final user = await AuthService.getStoredUser();
      if (user == null) return;

      final context = navigatorKey.currentContext;
      if (context == null || !context.mounted) return;

      final role = user.role.toLowerCase();
      Widget destination;
      if (role.contains('validator')) {
        destination = const ValidatorMainPage();
      } else if (role.contains('business') || role.contains('subaccount')) {
        destination = const BusinessMainPage();
      } else {
        destination = const MainPage();
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    } catch (e) {
      debugPrint('[FCM] Navigation error: $e');
    }
  }

  static Future<void> _onTokenRefresh(String newToken) async {
    try {
      final jwt = await AuthService.getToken();
      if (jwt != null) {
        await AuthService.registerFcmToken(newToken);
        debugPrint('[FCM] Token refreshed and re-registered.');
      }
    } catch (e) {
      debugPrint('[FCM] Failed to re-register refreshed token: $e');
    }
  }
}
