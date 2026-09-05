// ============================================================
// AUTO-GENERATED FILE — DO NOT EDIT BY HAND
// ============================================================
// After running `flutterfire configure`, this file will be
// replaced with real values from your Firebase project.
//
// Steps:
//   1. Install FlutterFire CLI:  dart pub global activate flutterfire_cli
//   2. Run:  flutterfire configure --project=schoolbuzz-xxxxx
//   3. This file will be auto-populated with your config
//
// For now, this placeholder lets the project compile.
// Firebase will NOT connect until real values are added.
// ============================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Unsupported platform: $defaultTargetPlatform');
    }
  }

  // PLACEHOLDER — replace with `flutterfire configure` output
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  // PLACEHOLDER — replace with `flutterfire configure` output
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.schoolbuzz',
  );
}
