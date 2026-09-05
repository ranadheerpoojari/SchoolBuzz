class AppSettings {
  final String caregiverName;
  final String childName;
  final String schoolName;
  final double schoolLatitude;
  final double schoolLongitude;
  final double geofenceRadius;
  final bool appEnabled;
  final int cooldownMinutes;
  final List<int> activeDays; // 1=Mon..7=Sun
  final String dropOffStart;
  final String dropOffEnd;
  final String pickupStart;
  final String pickupEnd;
  final bool whatsappEnabled;
  final bool isSetupComplete;

  const AppSettings({
    this.caregiverName = '',
    this.childName = '',
    this.schoolName = '',
    this.schoolLatitude = 0.0,
    this.schoolLongitude = 0.0,
    this.geofenceRadius = 150.0,
    this.appEnabled = true,
    this.cooldownMinutes = 30,
    this.activeDays = const [1, 2, 3, 4, 5],
    this.dropOffStart = '06:30',
    this.dropOffEnd = '09:30',
    this.pickupStart = '13:00',
    this.pickupEnd = '17:00',
    this.whatsappEnabled = true,
    this.isSetupComplete = false,
  });

  AppSettings copyWith({
    String? caregiverName,
    String? childName,
    String? schoolName,
    double? schoolLatitude,
    double? schoolLongitude,
    double? geofenceRadius,
    bool? appEnabled,
    int? cooldownMinutes,
    List<int>? activeDays,
    String? dropOffStart,
    String? dropOffEnd,
    String? pickupStart,
    String? pickupEnd,
    bool? whatsappEnabled,
    bool? isSetupComplete,
  }) =>
      AppSettings(
        caregiverName: caregiverName ?? this.caregiverName,
        childName: childName ?? this.childName,
        schoolName: schoolName ?? this.schoolName,
        schoolLatitude: schoolLatitude ?? this.schoolLatitude,
        schoolLongitude: schoolLongitude ?? this.schoolLongitude,
        geofenceRadius: geofenceRadius ?? this.geofenceRadius,
        appEnabled: appEnabled ?? this.appEnabled,
        cooldownMinutes: cooldownMinutes ?? this.cooldownMinutes,
        activeDays: activeDays ?? this.activeDays,
        dropOffStart: dropOffStart ?? this.dropOffStart,
        dropOffEnd: dropOffEnd ?? this.dropOffEnd,
        pickupStart: pickupStart ?? this.pickupStart,
        pickupEnd: pickupEnd ?? this.pickupEnd,
        whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
        isSetupComplete: isSetupComplete ?? this.isSetupComplete,
      );

  Map<String, dynamic> toMap() => {
        'caregiverName': caregiverName,
        'childName': childName,
        'schoolName': schoolName,
        'schoolLatitude': schoolLatitude,
        'schoolLongitude': schoolLongitude,
        'geofenceRadius': geofenceRadius,
        'appEnabled': appEnabled,
        'cooldownMinutes': cooldownMinutes,
        'activeDays': activeDays.join(','),
        'dropOffStart': dropOffStart,
        'dropOffEnd': dropOffEnd,
        'pickupStart': pickupStart,
        'pickupEnd': pickupEnd,
        'whatsappEnabled': whatsappEnabled,
        'isSetupComplete': isSetupComplete,
      };

  factory AppSettings.fromMap(Map<String, dynamic> m) => AppSettings(
        caregiverName: m['caregiverName'] ?? '',
        childName: m['childName'] ?? '',
        schoolName: m['schoolName'] ?? '',
        schoolLatitude: (m['schoolLatitude'] ?? 0).toDouble(),
        schoolLongitude: (m['schoolLongitude'] ?? 0).toDouble(),
        geofenceRadius: (m['geofenceRadius'] ?? 150).toDouble(),
        appEnabled: m['appEnabled'] ?? true,
        cooldownMinutes: m['cooldownMinutes'] ?? 30,
        activeDays: (m['activeDays'] as String? ?? '1,2,3,4,5')
            .split(',')
            .where((s) => s.isNotEmpty)
            .map(int.parse)
            .toList(),
        dropOffStart: m['dropOffStart'] ?? '06:30',
        dropOffEnd: m['dropOffEnd'] ?? '09:30',
        pickupStart: m['pickupStart'] ?? '13:00',
        pickupEnd: m['pickupEnd'] ?? '17:00',
        whatsappEnabled: m['whatsappEnabled'] ?? true,
        isSetupComplete: m['isSetupComplete'] ?? false,
      );
}
