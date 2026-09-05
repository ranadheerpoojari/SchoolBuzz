import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/event.dart';
import '../models/settings.dart';
import '../repositories/event_repository.dart';
import '../services/whatsapp_service.dart';

class EventProvider extends ChangeNotifier {
  final _repo = EventRepository();
  final _uuid = const Uuid();
  List<SchoolEvent> _events = [];

  List<SchoolEvent> get events => _events;

  Future<void> load() async {
    _events = await _repo.getAll();
    notifyListeners();
  }

  Future<SchoolEvent> confirmDropoff(AppSettings settings, {EventSource source = EventSource.manual}) async {
    final event = SchoolEvent(
      eventId: _uuid.v4(),
      childId: 'default',
      childNameSnapshot: settings.childName,
      caregiverId: 'default',
      caregiverNameSnapshot: settings.caregiverName,
      schoolId: 'default',
      actionType: ActionType.dropoff,
      source: source,
    );
    await _repo.insert(event);
    _events.insert(0, event);
    notifyListeners();
    return event;
  }

  Future<SchoolEvent> confirmPickup(AppSettings settings, {EventSource source = EventSource.manual}) async {
    final event = SchoolEvent(
      eventId: _uuid.v4(),
      childId: 'default',
      childNameSnapshot: settings.childName,
      caregiverId: 'default',
      caregiverNameSnapshot: settings.caregiverName,
      schoolId: 'default',
      actionType: ActionType.pickup,
      source: source,
    );
    await _repo.insert(event);
    _events.insert(0, event);
    notifyListeners();
    return event;
  }

  Future<SchoolEvent> createMessage(AppSettings settings, String message) async {
    final event = SchoolEvent(
      eventId: _uuid.v4(),
      childId: 'default',
      childNameSnapshot: settings.childName,
      caregiverId: 'default',
      caregiverNameSnapshot: settings.caregiverName,
      schoolId: 'default',
      actionType: ActionType.message,
      customMessage: message,
    );
    await _repo.insert(event);
    _events.insert(0, event);
    notifyListeners();
    return event;
  }

  Future<SchoolEvent?> getLastEvent() => _repo.getLastEvent();

  Future<bool> canActivate(AppSettings settings) async {
    if (!settings.appEnabled || !settings.isSetupComplete) return false;
    if (settings.schoolLatitude == 0 && settings.schoolLongitude == 0) return false;
    final now = DateTime.now();
    if (!settings.activeDays.contains(now.weekday)) return false;
    final last = await _repo.getLastEvent();
    if (last != null) {
      final elapsed = now.difference(last.eventTime).inMinutes;
      if (elapsed < settings.cooldownMinutes) return false;
    }
    return true;
  }

  String buildShareMessage(SchoolEvent event, AppSettings settings) {
    final time = _formatTime(event.eventTime);
    switch (event.actionType) {
      case ActionType.dropoff:
        return '''🏫 School Update

✅ Drop-off confirmed
Child: ${event.childNameSnapshot}
By: ${event.caregiverNameSnapshot}
School: ${settings.schoolName}
Time: $time

Sent from SchoolBuzz''';
      case ActionType.pickup:
        return '''🏫 School Update

✅ Pickup confirmed
Child: ${event.childNameSnapshot}
By: ${event.caregiverNameSnapshot}
School: ${settings.schoolName}
Time: $time

Sent from SchoolBuzz''';
      case ActionType.message:
        return '''🏫 School Message

Child: ${event.childNameSnapshot}
From: ${event.caregiverNameSnapshot}

${event.customMessage ?? ''}

Time: $time

Sent from SchoolBuzz''';
    }
  }

  Future<void> shareToWhatsApp(SchoolEvent event, AppSettings settings) async {
    final message = buildShareMessage(event, settings);
    await WhatsAppService.share(message);
    await _repo.updateShareStatus(event.eventId, ShareStatus.shareOpened);
    final idx = _events.indexWhere((e) => e.eventId == event.eventId);
    if (idx >= 0) {
      _events[idx] = event.copyWith(shareStatus: ShareStatus.shareOpened);
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    await _repo.clearAll();
    _events.clear();
    notifyListeners();
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}
