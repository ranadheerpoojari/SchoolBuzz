import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/settings.dart';
import 'notification_service.dart';

class GeofenceService {
  static Timer? _timer;
  static bool _insideGeofence = false;
  static DateTime? _lastTrigger;

  static Future<void> startMonitoring(AppSettings settings) async {
    _timer?.cancel();
    if (!settings.isSetupComplete || !settings.appEnabled) return;

    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _checkLocation(settings);
    });
  }

  static void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
    _insideGeofence = false;
  }

  static Future<void> _checkLocation(AppSettings settings) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        settings.schoolLatitude,
        settings.schoolLongitude,
      );

      final isInside = distance <= settings.geofenceRadius;

      if (isInside && !_insideGeofence) {
        _insideGeofence = true;
        final now = DateTime.now();

        // Cooldown check
        if (_lastTrigger != null) {
          final elapsed = now.difference(_lastTrigger!).inMinutes;
          if (elapsed < settings.cooldownMinutes) return;
        }

        // Schedule check
        if (!settings.activeDays.contains(now.weekday)) return;

        final dropEnd = _parseTime(settings.dropOffEnd);
        final pickupEnd = _parseTime(settings.pickupEnd);
        final currentTime = now.hour * 60 + now.minute;
        final dropStart = _parseTime(settings.dropOffStart);
        final pickupStart = _parseTime(settings.pickupStart);

        final inDropWindow = currentTime >= dropStart && currentTime <= dropEnd;
        final inPickupWindow = currentTime >= pickupStart && currentTime <= pickupEnd;

        if (inDropWindow || inPickupWindow) {
          _lastTrigger = now;
          await NotificationService.showArrivalNotification(settings);
        }
      } else if (!isInside) {
        _insideGeofence = false;
      }
    } catch (_) {}
  }

  static int _parseTime(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
