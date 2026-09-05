enum ActionType { dropoff, pickup, message }

enum EventSource { geofence, manual }

enum ShareStatus { notShared, shareOpened }

class SchoolEvent {
  final String eventId;
  final String childId;
  final String childNameSnapshot;
  final String caregiverId;
  final String caregiverNameSnapshot;
  final String schoolId;
  final ActionType actionType;
  final DateTime eventTime;
  final EventSource source;
  final ShareStatus shareStatus;
  final DateTime createdAt;
  final String? customMessage;

  SchoolEvent({
    required this.eventId,
    required this.childId,
    required this.childNameSnapshot,
    required this.caregiverId,
    required this.caregiverNameSnapshot,
    required this.schoolId,
    required this.actionType,
    DateTime? eventTime,
    required this.source,
    this.shareStatus = ShareStatus.notShared,
    DateTime? createdAt,
    this.customMessage,
  })  : eventTime = eventTime ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'eventId': eventId,
        'childId': childId,
        'childNameSnapshot': childNameSnapshot,
        'caregiverId': caregiverId,
        'caregiverNameSnapshot': caregiverNameSnapshot,
        'schoolId': schoolId,
        'actionType': actionType.name,
        'eventTime': eventTime.millisecondsSinceEpoch,
        'source': source.name,
        'shareStatus': shareStatus.name,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'customMessage': customMessage,
      };

  factory SchoolEvent.fromMap(Map<String, dynamic> m) => SchoolEvent(
        eventId: m['eventId'],
        childId: m['childId'],
        childNameSnapshot: m['childNameSnapshot'],
        caregiverId: m['caregiverId'],
        caregiverNameSnapshot: m['caregiverNameSnapshot'],
        schoolId: m['schoolId'],
        actionType: ActionType.values.firstWhere((e) => e.name == m['actionType']),
        eventTime: DateTime.fromMillisecondsSinceEpoch(m['eventTime']),
        source: EventSource.values.firstWhere((e) => e.name == m['source']),
        shareStatus: ShareStatus.values.firstWhere((e) => e.name == m['shareStatus']),
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt']),
        customMessage: m['customMessage'],
      );

  SchoolEvent copyWith({ShareStatus? shareStatus}) => SchoolEvent(
        eventId: eventId,
        childId: childId,
        childNameSnapshot: childNameSnapshot,
        caregiverId: caregiverId,
        caregiverNameSnapshot: caregiverNameSnapshot,
        schoolId: schoolId,
        actionType: actionType,
        eventTime: eventTime,
        source: source,
        shareStatus: shareStatus ?? this.shareStatus,
        createdAt: createdAt,
        customMessage: customMessage,
      );
}
