import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../models/event.dart';

/// Centralized analytics and crash reporting.
///
/// Tracks:
///   - Drop-off / Pickup / Message events
///   - WhatsApp share actions
///   - Setup completion
///   - Geofence triggers
///   - Errors and crashes
class AnalyticsService {
  static final _analytics = FirebaseAnalytics.instance;
  static final _crashlytics = FirebaseCrashlytics.instance;

  // ─── Event Tracking ─────────────────────────────────────────

  /// Log when a caregiver confirms drop-off.
  static Future<void> logDropoff({required String childName, required String source}) async {
    await _analytics.logEvent(
      name: 'school_event',
      parameters: {'action': 'dropoff', 'child': childName, 'source': source},
    );
  }

  /// Log when a caregiver confirms pickup.
  static Future<void> logPickup({required String childName, required String source}) async {
    await _analytics.logEvent(
      name: 'school_event',
      parameters: {'action': 'pickup', 'child': childName, 'source': source},
    );
  }

  /// Log when a caregiver sends a message.
  static Future<void> logMessage({required String childName}) async {
    await _analytics.logEvent(
      name: 'school_event',
      parameters: {'action': 'message', 'child': childName, 'source': 'manual'},
    );
  }

  /// Log when WhatsApp share is opened.
  static Future<void> logShare({required String actionType}) async {
    await _analytics.logEvent(
      name: 'whatsapp_share',
      parameters: {'action': actionType},
    );
  }

  /// Log geofence entry.
  static Future<void> logGeofenceEntry({required String schoolName}) async {
    await _analytics.logEvent(
      name: 'geofence_entry',
      parameters: {'school': schoolName},
    );
  }

  /// Log setup completion.
  static Future<void> logSetupComplete() async {
    await _analytics.logEvent(name: 'setup_complete');
  }

  /// Log screen view.
  static Future<void> logScreen(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // ─── User Identity ──────────────────────────────────────────

  /// Set the caregiver name for analytics segmentation.
  static Future<void> setUser({required String caregiverName, required String familyId}) async {
    await _analytics.setUserId(id: familyId);
    await _analytics.setUserProperty(name: 'caregiver', value: caregiverName);
    await _crashlytics.setUserIdentifier(familyId);
    await _crashlytics.setCustomKey('caregiver', caregiverName);
  }

  // ─── Crash Reporting ────────────────────────────────────────

  /// Log a non-fatal error with context.
  static Future<void> logError(dynamic error, StackTrace stack, {String? context}) async {
    await _crashlytics.recordError(
      error,
      stack,
      reason: context,
      fatal: false,
    );
  }

  /// Log a custom breadcrumb for crash investigation.
  static void log(String message) {
    _crashlytics.log(message);
  }

  /// Set a custom key for crash context.
  static void setCrashKey(String key, String value) {
    _crashlytics.setCustomKey(key, value);
  }
}
