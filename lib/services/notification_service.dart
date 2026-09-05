import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/settings.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(settings);
  }

  static Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showArrivalNotification(AppSettings settings) async {
    const androidDetails = AndroidNotificationDetails(
      'schoolbuzz_arrival',
      'School Arrival',
      channelDescription: 'Notifications when you arrive at school',
      importance: Importance.high,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction('dropoff', 'DROP-OFF'),
        AndroidNotificationAction('pickup', 'PICKUP'),
        AndroidNotificationAction('message', 'MESSAGE'),
      ],
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      1001,
      'SchoolBuzz',
      'You have arrived at ${settings.schoolName}',
      details,
    );
  }

  static Future<void> dismiss() async {
    await _plugin.cancel(1001);
  }
}
