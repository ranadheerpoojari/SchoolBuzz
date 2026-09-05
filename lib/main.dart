import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'providers/settings_provider.dart';
import 'providers/event_provider.dart';
import 'services/geofence_service.dart';
import 'services/notification_service.dart';
import 'services/fcm_service.dart';
import 'screens/home_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/arrival_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Crashlytics: catch Flutter framework errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Crashlytics: catch async errors outside Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Initialize services
  await NotificationService.initialize();
  await FCMService.initialize();

  runApp(const SchoolBuzzApp());
}

class SchoolBuzzApp extends StatelessWidget {
  const SchoolBuzzApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => EventProvider()..load()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'SchoolBuzz',
            debugShowCheckedModeBanner: false,
            navigatorObservers: [observer],
            theme: ThemeData(
              colorSchemeSeed: const Color(0xFF2563EB),
              useMaterial3: true,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              colorSchemeSeed: const Color(0xFF2563EB),
              useMaterial3: true,
              brightness: Brightness.dark,
            ),
            themeMode: ThemeMode.system,
            home: settings.isSetupComplete
                ? const HomeScreen()
                : const SetupScreen(),
            routes: {
              '/home': (_) => const HomeScreen(),
              '/setup': (_) => const SetupScreen(),
              '/history': (_) => const HistoryScreen(),
              '/settings': (_) => const SettingsScreen(),
              '/arrival': (_) => const ArrivalScreen(),
            },
          );
        },
      ),
    );
  }
}
