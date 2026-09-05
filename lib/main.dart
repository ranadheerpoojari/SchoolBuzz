import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/event_provider.dart';
import 'services/geofence_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/arrival_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  runApp(const SchoolBuzzApp());
}

class SchoolBuzzApp extends StatelessWidget {
  const SchoolBuzzApp({super.key});

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
