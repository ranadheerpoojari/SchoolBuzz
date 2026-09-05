# Firebase Setup Guide for SchoolBuzz

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Project name: `SchoolBuzz`
4. Enable Google Analytics (free)
5. Select or create Analytics account
6. Click **"Create project"**

## Step 2: Register Android App

1. In Firebase Console → Click **"Add app"** → Select **Android**
2. Android package name: `com.schoolbuzz`
3. App nickname: `SchoolBuzz Android`
4. Download `google-services.json`
5. Place it at: `android/app/google-services.json`

## Step 3: Register iOS App

1. In Firebase Console → Click **"Add app"** → Select **iOS**
2. iOS bundle ID: `com.schoolbuzz`
3. App nickname: `SchoolBuzz iOS`
4. Download `GoogleService-Info.plist`
5. Place it at: `ios/Runner/GoogleService-Info.plist`

## Step 4: Generate firebase_options.dart

Install FlutterFire CLI and run:

```bash
# Install CLI
dart pub global activate flutterfire_cli

# Configure (auto-generates firebase_options.dart)
flutterfire configure --project=schoolbuzz-xxxxx
```

This replaces the placeholder `lib/firebase_options.dart` with real values.

## Step 5: Enable Firebase Services

### Crashlytics
1. Firebase Console → **Crashlytics** → Get started
2. Follow the setup wizard
3. No code changes needed — already integrated

### Analytics
1. Firebase Console → **Analytics** → Enabled by default
2. Events will appear within 24 hours

### Cloud Firestore (Optional - for multi-device sync)
1. Firebase Console → **Firestore Database** → Create database
2. Start in **test mode** (for development)
3. Security rules: update before production

### Firebase Auth (Optional - for family pairing)
1. Firebase Console → **Authentication** → Get started
2. Enable **Anonymous** sign-in method

### Cloud Messaging (FCM)
1. Firebase Console → **Cloud Messaging** → Enabled by default
2. No additional setup needed

### Remote Config (Optional)
1. Firebase Console → **Remote Config** → Get started
2. Add parameters as needed

## Step 6: Update Android Build Files

### android/build.gradle (root)
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

### android/app/build.gradle
```gradle
plugins {
    id 'com.google.gms.google-services'
}
```

## Step 7: Update iOS Configuration

### ios/Runner/AppDelegate.swift
```swift
import Firebase

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

## Step 8: Test

```bash
flutter run
```

Check Firebase Console:
- **Crashlytics** → Force a test crash
- **Analytics** → Events should appear within 24 hours
- **Firestore** → Check for synced data

## Free Tier Limits

| Service | Free Limit | SchoolBuzz Usage |
|---------|------------|-----------------|
| Crashlytics | Unlimited | Crash reports |
| Analytics | Unlimited | Event tracking |
| Firestore | 50K reads, 20K writes/day | Event sync |
| Auth | Unlimited | Anonymous auth |
| FCM | Unlimited | Push notifications |
| Remote Config | Unlimited | Feature flags |

**Estimated monthly cost: $0**

## Security Checklist (Before Production)

- [ ] Update Firestore security rules
- [ ] Enable App Check
- [ ] Set up Crashlytics alerts
- [ ] Configure Analytics audiences
- [ ] Test on multiple devices
- [ ] Verify push notifications work
