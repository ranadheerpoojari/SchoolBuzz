import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/settings.dart';

/// Handles optional Firestore sync for multi-device family coordination.
///
/// Data structure:
///   families/{familyId}/members/{memberId}     — caregiver devices
///   families/{familyId}/events/{eventId}       — shared events
///   families/{familyId}/settings               — shared school config
///
/// Free tier: 50K reads/day, 20K writes/day — more than enough.
class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // ─── Family Management ───────────────────────────────────────

  /// Create a new family and return its ID.
  static Future<String> createFamily(String familyName) async {
    final ref = await _db.collection('families').add({
      'name': familyName,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Join an existing family by ID.
  static Future<void> joinFamily(String familyId, String memberId, String memberName) async {
    await _db.collection('families').doc(familyId).collection('members').doc(memberId).set({
      'name': memberName,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Event Sync ─────────────────────────────────────────────

  /// Push a local event to Firestore for other devices to see.
  static Future<void> syncEvent(String familyId, SchoolEvent event) async {
    await _db
        .collection('families')
        .doc(familyId)
        .collection('events')
        .doc(event.eventId)
        .set({
      ...event.toMap(),
      'syncedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Listen to real-time event updates from other family members.
  static Stream<List<SchoolEvent>> listenEvents(String familyId) {
    return _db
        .collection('families')
        .doc(familyId)
        .collection('events')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SchoolEvent.fromMap(doc.data()))
            .toList());
  }

  /// Get recent events (one-time fetch).
  static Future<List<SchoolEvent>> getRecentEvents(String familyId) async {
    final snapshot = await _db
        .collection('families')
        .doc(familyId)
        .collection('events')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => SchoolEvent.fromMap(doc.data()))
        .toList();
  }

  // ─── Settings Sync ──────────────────────────────────────────

  /// Push settings to Firestore so new devices can pick them up.
  static Future<void> syncSettings(String familyId, AppSettings settings) async {
    await _db.collection('families').doc(familyId).set({
      'settings': settings.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Listen to settings changes (e.g., school name updated by another caregiver).
  static Stream<AppSettings?> listenSettings(String familyId) {
    return _db.collection('families').doc(familyId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null || data['settings'] == null) return null;
      return AppSettings.fromMap(Map<String, dynamic>.from(data['settings']));
    });
  }

  // ─── Analytics Helpers ──────────────────────────────────────

  /// Log a custom analytics event.
  static void logEvent(String name, {Map<String, dynamic>? params}) {
    _db.collection('analytics').add({
      'event': name,
      'params': params,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
