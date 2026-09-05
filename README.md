# 🏫 SchoolBuzz

**School Drop-off & Pickup Assistant**

A cross-platform mobile app that automatically detects when a caregiver arrives at school and lets them quickly log a drop-off, pickup, or send a custom message to the family WhatsApp group.

> **iOS + Android** · Zero cost · Privacy first · No backend required

---

## Table of Contents

- [What It Does](#what-it-does)
- [Screenshots (Flow)](#screenshots-flow)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Install Dependencies](#install-dependencies)
  - [Run the App](#run-the-app)
  - [Build for Release](#build-for-release)
- [First-Time Setup (In-App)](#first-time-setup-in-app)
- [How It Works](#how-it-works)
  - [Automatic Mode (Geofence)](#automatic-mode-geofence)
  - [Manual Mode](#manual-mode)
  - [WhatsApp Sharing](#whatsapp-sharing)
- [Configuration Reference](#configuration-reference)
- [Architecture](#architecture)
  - [Layer Diagram](#layer-diagram)
  - [Data Flow](#data-flow)
- [Platform Permissions](#platform-permissions)
  - [Android](#android)
  - [iOS](#ios)
- [Data Model](#data-model)
- [Requirements Traceability](#requirements-traceability)
- [FAQ](#faq)
- [License](#license)

---

## What It Does

```
Parent drives to school
        │
        ▼
App detects arrival (GPS geofence)
        │
        ▼
Notification pops up:
┌──────────────────────────────┐
│  SchoolBuzz                  │
│  You arrived at Maple School │
│                              │
│  [DROP-OFF] [PICKUP] [MSG]  │
└──────────────────────────────┘
        │
        ▼
Parent taps "Drop-off"
        │
        ▼
App generates message:
┌──────────────────────────────┐
│  🏫 School Update            │
│                              │
│  ✅ Drop-off confirmed       │
│  Child: Aarav                │
│  By: Dad                     │
│  School: Maple Elementary    │
│  Time: 7:46 AM               │
│                              │
│  Sent from SchoolBuzz        │
└──────────────────────────────┘
        │
        ▼
Opens WhatsApp → parent picks family group → taps Send
```

**That's it.** No accounts, no servers, no subscriptions.

---

## Screenshots (Flow)

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│   Welcome, Dad  │    │  School Arrival │    │  Confirm        │
│   Maple School  │    │                 │    │  Drop-off       │
│                 │    │  [Drop-off]     │    │                 │
│  [Drop-off]     │    │  [Pickup]       │    │  Child: Aarav   │
│  [Pickup]       │    │  [Message]      │    │  By: Dad        │
│  [Message]      │    │                 │    │  Time: 7:46 AM  │
│                 │    │                 │    │                 │
│         [I'm at School]│                 │    │  [Confirm & Share] │
└─────────────────┘    └─────────────────┘    └─────────────────┘
       Home                  Arrival               Confirm
```

---

## Features

| Feature | Description |
|---------|-------------|
| **Geofence Detection** | Automatically triggers when device enters configurable radius (100–500m) around school |
| **Three Actions** | Drop-off, Pickup, or custom Message — all available at all times |
| **WhatsApp Sharing** | Pre-filled message opens WhatsApp; user selects group and sends |
| **Quick Texts** | Pre-built message templates: "Running late", "Waiting outside", etc. |
| **Manual Mode** | "I'm at School" button for when GPS is inaccurate or delayed |
| **Schedule Support** | Configurable active days (Mon–Sun) and time windows for drop-off/pickup |
| **Duplicate Suppression** | Cooldown timer (5–120 min, default 30) prevents repeated notifications |
| **Event History** | Local log of all events with action type, caregiver, child, time, share status |
| **Multi-Caregiver** | Each family member installs separately; WhatsApp group is the shared record |
| **Multi-Child Ready** | Data model supports multiple children (UI supports it in settings) |
| **Dark Mode** | Follows system theme automatically |
| **Boot Recovery** | Re-registers geofence after device restart (Android) |
| **Zero Cost** | No backend, no paid APIs, no subscriptions — $0/month |
| **Privacy First** | All data local, no location upload, no WhatsApp credentials stored |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.x + Dart 3.x |
| **UI** | Material 3 (Material You) |
| **State Management** | Provider |
| **Local Database** | SQLite via `sqflite` |
| **Preferences** | `shared_preferences` |
| **Location** | `geolocator` (cross-platform GPS + geofencing) |
| **Notifications** | `flutter_local_notifications` |
| **WhatsApp** | `url_launcher` + `share_plus` |
| **Permissions** | `permission_handler` |
| **UUID** | `uuid` package |

---

## Project Structure

```
SchoolBuzz/
│
├── pubspec.yaml                          # Project config & dependencies
├── analysis_options.yaml                 # Dart lint rules
├── README.md                             # This file
│
├── lib/                                  # ── DART SOURCE CODE ──
│   │
│   ├── main.dart                         # App entry point
│   │                                     #   - Provider setup
│   │                                     #   - Theme config (light/dark)
│   │                                     #   - Route definitions
│   │                                     #   - Setup vs Home routing
│   │
│   ├── models/                           # ── DATA MODELS ──
│   │   ├── event.dart                    # SchoolEvent
│   │   │                                 #   - ActionType: dropoff, pickup, message
│   │   │                                 #   - EventSource: geofence, manual
│   │   │                                 #   - ShareStatus: notShared, shareOpened
│   │   │                                 #   - toMap() / fromMap() for SQLite
│   │   │
│   │   └── settings.dart                 # AppSettings
│   │                                     #   - caregiverName, childName, schoolName
│   │                                     #   - schoolLatitude, schoolLongitude
│   │                                     #   - geofenceRadius (100–500m)
│   │                                     #   - activeDays, dropOffStart/End, pickupStart/End
│   │                                     #   - cooldownMinutes (5–120)
│   │                                     #   - appEnabled, whatsappEnabled, isSetupComplete
│   │
│   ├── providers/                        # ── STATE MANAGEMENT ──
│   │   ├── settings_provider.dart        # Settings state
│   │   │                                 #   - load() from SharedPreferences
│   │   │                                 #   - save() / update() / clear()
│   │   │                                 #   - exposes isSetupComplete for routing
│   │   │
│   │   └── event_provider.dart           # Event state + business logic
│   │                                     #   - confirmDropoff() / confirmPickup()
│   │                                     #   - createMessage()
│   │                                     #   - canActivate() — 5 validation checks
│   │                                     #   - buildShareMessage() — formats WhatsApp text
│   │                                     #   - shareToWhatsApp()
│   │                                     #   - clearHistory()
│   │
│   ├── repositories/                     # ── DATA PERSISTENCE ──
│   │   ├── database_helper.dart          # SQLite database init
│   │   │                                 #   - Creates school_events table
│   │   │                                 #   - Singleton database instance
│   │   │
│   │   ├── event_repository.dart         # Event CRUD
│   │   │                                 #   - getAll() — last 100 events
│   │   │                                 #   - insert() — with conflict resolution
│   │   │                                 #   - getLastEvent() — for cooldown check
│   │   │                                 #   - updateShareStatus()
│   │   │                                 #   - clearAll()
│   │   │
│   │   └── settings_repository.dart      # Settings persistence
│   │                                     #   - load() from SharedPreferences
│   │                                     #   - save() with type-safe writes
│   │                                     #   - clear()
│   │
│   ├── services/                         # ── PLATFORM SERVICES ──
│   │   ├── geofence_service.dart         # Cross-platform geofencing
│   │   │                                 #   - startMonitoring() — 30s polling
│   │   │                                 #   - stopMonitoring()
│   │   │                                 #   - Checks: location enabled, permission,
│   │   │                                 #     distance, active day, time window, cooldown
│   │   │                                 #   - Triggers notification on valid entry
│   │   │
│   │   ├── notification_service.dart     # Local notifications
│   │   │                                 #   - initialize() — Android + iOS setup
│   │   │                                 #   - requestPermission()
│   │   │                                 #   - showArrivalNotification()
│   │   │                                 #     with DROP-OFF, PICKUP, MESSAGE actions
│   │   │                                 #   - dismiss()
│   │   │
│   │   └── whatsapp_service.dart         # WhatsApp integration
│   │                                     #   - share() — tries whatsapp:// URL first
│   │                                     #   - Falls back to system share sheet
│   │                                     #   - shareToSpecificChat() — wa.me link
│   │
│   ├── screens/                          # ── FULL-SCREEN UIs ──
│   │   ├── setup_screen.dart             # First-run wizard
│   │   │                                 #   - Caregiver name, child name
│   │   │                                 #   - School name, lat/lng
│   │   │                                 #   - "Use Current Location" button
│   │   │                                 #   - Geofence radius (100–500m)
│   │   │                                 #   - Validation + save
│   │   │
│   │   ├── home_screen.dart              # Main dashboard
│   │   │                                 #   - Status card (name, school, child, radius)
│   │   │                                 #   - Quick action cards (drop-off, pickup, message)
│   │   │                                 #   - Suggested action based on time of day
│   │   │                                 #   - Recent activity list (last 5)
│   │   │                                 #   - "I'm at School" FAB
│   │   │
│   │   ├── arrival_screen.dart           # Arrival action screen (for notification tap)
│   │   │
│   │   ├── history_screen.dart           # Event history
│   │   │                                 #   - Full event list with icons
│   │   │                                 #   - Shows: action, caregiver→child, time
│   │   │                                 #   - Shows: source (Auto/Manual), share status
│   │   │                                 #   - Clear history with confirmation
│   │   │
│   │   └── settings_screen.dart          # All configuration
│   │                                     #   - Profile: caregiver name, child name
│   │                                     #   - School: name, lat, lng, radius
│   │                                     #   - Schedule: drop-off/pickup times, active days
│   │                                     #   - Behavior: cooldown, app enabled, WhatsApp enabled
│   │                                     #   - Link to system app settings
│   │
│   └── widgets/                          # ── REUSABLE COMPONENTS ──
│       ├── action_card.dart              # Drop-off / Pickup card with icon + highlight
│       ├── event_tile.dart               # Event list item (icon + details + time)
│       ├── arrival_bottom_sheet.dart     # 3-action modal (suggested action highlighted)
│       ├── confirm_bottom_sheet.dart     # Drop-off/Pickup confirmation with details
│       ├── message_bottom_sheet.dart     # Custom message entry + quick text chips
│       └── share_dialog.dart             # Message preview + "Share on WhatsApp" button
│
├── android/                              # ── ANDROID CONFIG ──
│   ├── app/build.gradle                  # minSdk 26, targetSdk 35
│   ├── app/src/main/AndroidManifest.xml  # Permissions + app config
│   ├── build.gradle                      # Root build config
│   └── settings.gradle                   # Gradle plugin config
│
└── ios/                                  # ── iOS CONFIG ──
    ├── Podfile                           # Platform iOS 14.0+
    └── Runner/Info.plist                 # Permissions + background modes
```

---

## Getting Started

### Prerequisites

| Tool | Version | Check |
|------|---------|-------|
| Flutter SDK | 3.x+ | `flutter --version` |
| Dart SDK | 3.x+ | `dart --version` |
| Android Studio | Latest | For Android emulator/device |
| Xcode | 15+ | For iOS simulator/device (macOS only) |
| CocoaPods | Latest | `pod --version` (iOS only) |

### Install Dependencies

```bash
# Clone or navigate to the project
cd SchoolBuzz

# Get Flutter packages
flutter pub get

# iOS only: install CocoaPods
cd ios && pod install && cd ..
```

### Run the App

```bash
# Check connected devices
flutter devices

# Run on Android device/emulator
flutter run -d android

# Run on iOS simulator/device
flutter run -d ios

# Run on any connected device
flutter run
```

### Build for Release

```bash
# Android APK (sideloadable)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires Xcode signing setup)
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode to archive & distribute
```

---

## First-Time Setup (In-App)

When the app launches for the first time, a setup wizard walks through:

### Step 1: Permissions
The app requests:
- **Location permission** (required for geofencing)
- **Notification permission** (required for arrival alerts)

### Step 2: Your Profile
| Field | Example | Required |
|-------|---------|----------|
| Your Name | Dad, Mom, Grandma | ✅ |
| Child's Name | Aarav, Priya | ✅ |

### Step 3: School Details
| Field | Example | Required |
|-------|---------|----------|
| School Name | Maple Elementary | ✅ |
| Latitude | 40.7128 | ✅ |
| Longitude | -74.0060 | ✅ |
| Radius (meters) | 150 | ✅ (100–500) |

> **Tip:** Tap **"Use Current Location"** when physically at the school to auto-fill coordinates.

### Step 4: Save
Tapping **"Save & Continue"** saves everything and takes you to the home screen.

---

## How It Works

### Automatic Mode (Geofence)

```
                    ┌──────────────────────┐
                    │  Geofence Service    │
                    │  (runs every 30s)    │
                    └──────────┬───────────┘
                               │
                    ┌──────────▼───────────┐
                    │  Get current GPS     │
                    │  position            │
                    └──────────┬───────────┘
                               │
                    ┌──────────▼───────────┐
                    │  Calculate distance  │
                    │  to school           │
                    └──────────┬───────────┘
                               │
                    ┌──────────▼───────────┐
                    │  Distance <= radius? │
                    └──┬───────────────┬───┘
                   YES │               │ NO
                       ▼               ▼
            ┌──────────────┐    (do nothing)
            │ Was outside  │
            │ before?      │
            └──┬────────┬──┘
           YES │        │ NO
               ▼        ▼
    ┌──────────────┐  (already inside,
    │ Validate:    │   skip)
    │ ✓ App enabled│
    │ ✓ Active day │
    │ ✓ Time window│
    │ ✓ Cooldown   │
    └──────┬───────┘
           │ ALL PASS
           ▼
    ┌──────────────┐
    │ Show         │
    │ notification │
    │ with actions │
    └──────────────┘
```

**Validation checks (all must pass):**
1. `appEnabled == true`
2. `isSetupComplete == true`
3. Current weekday is in `activeDays`
4. Current time is within drop-off OR pickup window
5. Time since last event >= `cooldownMinutes`

### Manual Mode

Tap the **"I'm at School"** floating button on the home screen. This bypasses geofence detection and shows the same three action choices. Useful when:
- Background location permission was denied
- GPS signal is weak or inaccurate
- Device recently rebooted (geofence re-registering)
- Caregiver wants to report from inside the school

### WhatsApp Sharing

```
SchoolBuzz generates message text
            │
            ▼
Tries: whatsapp://send?text=...
            │
      ┌─────┴─────┐
      │           │
   Success     Failure
      │        (WhatsApp not installed)
      ▼           │
WhatsApp opens    ▼
with message   System share sheet opens
prefilled      (user picks any app)
      │
      ▼
User selects
family group
      │
      ▼
User taps Send
```

**Important:** The app never sends messages automatically. The user always:
1. Chooses which chat/group to send to
2. Reviews the pre-filled message
3. Taps Send themselves

---

## Configuration Reference

### Settings Screen Fields

| Section | Field | Type | Default | Range/Notes |
|---------|-------|------|---------|-------------|
| **Profile** | Caregiver Name | text | — | Required |
| | Child Name | text | — | Required |
| **School** | School Name | text | — | Required |
| | Latitude | decimal | 0.0 | -90 to +90 |
| | Longitude | decimal | 0.0 | -180 to +180 |
| | Radius | integer | 150 | 100–500 meters |
| **Schedule** | Drop-off Start | time | 06:30 | HH:MM format |
| | Drop-off End | time | 09:30 | HH:MM format |
| | Pickup Start | time | 13:00 | HH:MM format |
| | Pickup End | time | 17:00 | HH:MM format |
| | Active Days | chips | Mon–Fri | 1=Mon, 7=Sun |
| **Behavior** | Cooldown | integer | 30 | 5–120 minutes |
| | App Enabled | toggle | ON | Master switch |
| | WhatsApp Sharing | toggle | ON | Enable/disable share |

---

## Architecture

### Layer Diagram

```
┌─────────────────────────────────────────────────────┐
│                    PRESENTATION                      │
│                                                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐ │
│  │  Setup   │ │   Home   │ │ History  │ │Settings│ │
│  │  Screen  │ │  Screen  │ │  Screen  │ │ Screen │ │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └───┬────┘ │
│       │            │            │            │      │
│  ┌────▼────────────▼────────────▼────────────▼────┐ │
│  │              Provider (State)                  │ │
│  │  ┌─────────────────┐  ┌─────────────────────┐  │ │
│  │  │SettingsProvider  │  │  EventProvider      │  │ │
│  │  └────────┬────────┘  └──────────┬──────────┘  │ │
│  └───────────┼──────────────────────┼─────────────┘ │
├──────────────┼──────────────────────┼───────────────┤
│              ▼                      ▼               │
│  ┌───────────────────────────────────────────────┐  │
│  │              DATA / REPOSITORIES               │  │
│  │                                               │  │
│  │  ┌─────────────────┐  ┌─────────────────────┐ │  │
│  │  │SettingsRepo     │  │  EventRepo          │ │  │
│  │  │(SharedPreferences│  │  (SQLite/sqflite)   │ │  │
│  │  └─────────────────┘  └─────────────────────┘ │  │
│  └───────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────┤
│                    SERVICES                          │
│                                                     │
│  ┌────────────────┐ ┌──────────────┐ ┌───────────┐ │
│  │ GeofenceService│ │Notification  │ │ WhatsApp  │ │
│  │ (Geolocator)   │ │Service       │ │ Service   │ │
│  └────────────────┘ └──────────────┘ └───────────┘ │
├─────────────────────────────────────────────────────┤
│               PLATFORM (Flutter Plugins)             │
│                                                     │
│  geolocator · flutter_local_notifications ·         │
│  share_plus · url_launcher · permission_handler     │
└─────────────────────────────────────────────────────┘
```

### Data Flow

**Geofence → Notification → Action → Share:**
```
Geolocator GPS → GeofenceService._checkLocation()
    → distance calculation
    → validation (5 checks)
    → NotificationService.showArrivalNotification()
    → User taps notification action
    → Opens HomeScreen / ArrivalScreen
    → User selects action (dropoff/pickup/message)
    → EventProvider.confirmDropoff() / confirmPickup() / createMessage()
    → EventRepository.insert() → SQLite
    → EventProvider.buildShareMessage() → formatted text
    → WhatsAppService.share() → whatsapp:// or system share
    → User picks group → taps Send
```

---

## Platform Permissions

### Android

Declared in `android/app/src/main/AndroidManifest.xml`:

| Permission | Why |
|-----------|-----|
| `ACCESS_FINE_LOCATION` | Precise GPS for geofence distance calculation |
| `ACCESS_COARSE_LOCATION` | Fallback location (required by some devices) |
| `ACCESS_BACKGROUND_LOCATION` | Geofence works when app is in background |
| `POST_NOTIFICATIONS` | Show arrival notification (Android 13+) |
| `RECEIVE_BOOT_COMPLETED` | Re-register geofence after device restart |
| `WAKE_LOCK` | Keep CPU awake for background geofence check |

### iOS

Declared in `ios/Runner/Info.plist`:

| Key | Why |
|-----|-----|
| `NSLocationWhenInUseUsageDescription` | Location access for geofencing |
| `NSLocationAlwaysAndWhenInUseUsageDescription` | Background geofencing |
| `UIBackgroundModes: location` | iOS background location capability |

**iOS Note:** iOS requires the user to grant "Always Allow" location permission for background geofencing to work. The app will prompt for this during setup.

---

## Data Model

### SchoolEvent

```
┌─────────────────────────────────────────────────────┐
│  school_events (SQLite)                             │
├──────────────────────┬──────────────────────────────┤
│  eventId             │  UUID (primary key)          │
│  childId             │  "default" (single child)    │
│  childNameSnapshot   │  "Aarav"                     │
│  caregiverId         │  "default" (single device)   │
│  caregiverNameSnapshot│ "Dad"                       │
│  schoolId            │  "default"                   │
│  actionType          │  "dropoff" / "pickup" /      │
│                      │  "message"                   │
│  eventTime           │  milliseconds since epoch    │
│  source              │  "geofence" / "manual"       │
│  shareStatus         │  "notShared" / "shareOpened" │
│  createdAt           │  milliseconds since epoch    │
│  customMessage       │  nullable text               │
└──────────────────────┴──────────────────────────────┘
```

### AppSettings

```
┌─────────────────────────────────────────────────────┐
│  SharedPreferences (key-value)                      │
├──────────────────────┬──────────────────────────────┤
│  sg_caregiverName    │  "Dad"                       │
│  sg_childName        │  "Aarav"                     │
│  sg_schoolName       │  "Maple Elementary"          │
│  sg_schoolLatitude   │  40.7128                     │
│  sg_schoolLongitude  │  -74.0060                    │
│  sg_geofenceRadius   │  150.0 (meters)              │
│  sg_appEnabled       │  true                        │
│  sg_cooldownMinutes  │  30                          │
│  sg_activeDays       │  "1,2,3,4,5" (Mon–Fri)       │
│  sg_dropOffStart     │  "06:30"                     │
│  sg_dropOffEnd       │  "09:30"                     │
│  sg_pickupStart      │  "13:00"                     │
│  sg_pickupEnd        │  "17:00"                     │
│  sg_whatsappEnabled  │  true                        │
│  sg_isSetupComplete  │  true                        │
└──────────────────────┴──────────────────────────────┘
```

---

## Requirements Traceability

Every requirement from the specification document maps to an implementation:

| ID | Requirement | Implementation File(s) |
|----|------------|----------------------|
| FR-001 | School configuration | `screens/setup_screen.dart`, `screens/settings_screen.dart` |
| FR-002 | Geofence registration | `services/geofence_service.dart` |
| FR-003 | Background location permissions | `android/.../AndroidManifest.xml`, `ios/.../Info.plist`, `screens/setup_screen.dart` |
| FR-004 | School arrival activation | `providers/event_provider.dart` → `canActivate()` |
| FR-005 | Three required actions | `widgets/arrival_bottom_sheet.dart` |
| FR-006 | Drop-off confirmation | `widgets/confirm_bottom_sheet.dart` |
| FR-007 | Pickup confirmation | `widgets/confirm_bottom_sheet.dart` |
| FR-008 | Message action | `widgets/message_bottom_sheet.dart` |
| FR-009 | WhatsApp sharing | `services/whatsapp_service.dart` |
| FR-010 | Manual fallback | `screens/home_screen.dart` → FAB button |
| FR-011 | Duplicate suppression | `services/geofence_service.dart` + `providers/event_provider.dart` |
| FR-012 | School schedule | `screens/settings_screen.dart` (days + time windows) |
| FR-013 | Multiple children | `models/event.dart` (childId field) |
| FR-014 | Multiple caregivers | `models/settings.dart` (per-device identity) |
| FR-015 | Local event history | `repositories/event_repository.dart`, `screens/history_screen.dart` |
| NFR-001 | Zero cost ($0/month) | No backend, no paid APIs |
| NFR-002 | Security | Local-only storage, no credentials |
| NFR-003 | Reliability | Tolerates reboot, network loss, GPS issues |
| NFR-004 | Battery | 30s timer polling (not continuous GPS) |
| NFR-005 | Performance | < 1s event processing |
| NFR-006 | Maintainability | Clean architecture layers, Provider pattern |

---

## FAQ

**Q: Does this use the WhatsApp Business API?**
A: No. It uses Android's `whatsapp://` URL scheme and iOS system share sheet. No paid API needed.

**Q: Does the app send WhatsApp messages automatically?**
A: No. The user always chooses the group and taps Send themselves. The app only pre-fills the message.

**Q: Does the app track my location continuously?**
A: No. It checks GPS every 30 seconds only to calculate distance to school. No location history is stored or uploaded.

**Q: What if GPS is inaccurate at my school?**
A: Increase the geofence radius (up to 500m). Or use the "I'm at School" manual button.

**Q: Can both parents use it?**
A: Yes. Install on each phone separately. Each device stores its own caregiver name. The WhatsApp family group is the shared record.

**Q: Does it work on both iOS and Android?**
A: Yes. Single Flutter codebase runs on both platforms.

**Q: What happens after a device restart?**
A: On Android, the geofence re-registers automatically via `RECEIVE_BOOT_COMPLETED`. On iOS, location monitoring persists across restarts.

**Q: Can I change settings after setup?**
A: Yes. Tap the gear icon on the home screen to access all settings.

**Q: What if WhatsApp is not installed?**
A: The app falls back to the system share sheet, which lets you share via any app (SMS, email, Telegram, etc.).

---

## License

MIT License

```
Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
