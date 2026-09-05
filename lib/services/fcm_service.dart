import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../providers/settings_provider.dart';

/// Handles Firebase Cloud Messaging for push notifications.
/// When a caregiver confirms an action, other family devices get notified.
class FCMService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Request permission (iOS)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token for this device
    final token = await _messaging.getToken();
    print('FCM Token: $token'); // TODO: save to Firestore for family pairing

    // Subscribe to personal topic (will be family-specific later)
    await _messaging.subscribeToTopic('schoolbuzz_updates');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // Check if app was opened from a notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'schoolbuzz_push',
          'Family Updates',
          channelDescription: 'Notifications when family members log school events',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  static void _handleMessageTap(RemoteMessage message) {
    // Navigate to home or specific event
    // Handled by the app's navigation system
  }

  /// Subscribe to a family-specific topic for multi-device sync.
  static Future<void> subscribeToFamily(String familyId) async {
    await _messaging.subscribeToTopic('family_$familyId');
  }

  /// Unsubscribe from a family topic.
  static Future<void> unsubscribeFromFamily(String familyId) async {
    await _messaging.unsubscribeFromTopic('family_$familyId');
  }
}
