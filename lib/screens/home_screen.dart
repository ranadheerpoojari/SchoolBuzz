import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/settings.dart';
import '../providers/settings_provider.dart';
import '../providers/event_provider.dart';
import '../services/geofence_service.dart';
import '../services/analytics_service.dart';
import '../widgets/action_card.dart';
import '../widgets/event_tile.dart';
import '../widgets/arrival_bottom_sheet.dart';
import '../widgets/confirm_bottom_sheet.dart';
import '../widgets/message_bottom_sheet.dart';
import '../widgets/share_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreen('home');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsProvider>().settings;
      GeofenceService.startMonitoring(settings);
    });
  }

  void _showArrival() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ArrivalBottomSheet(),
    );
  }

  void _quickAction(ActionType action) {
    if (action == ActionType.message) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => const MessageBottomSheet(),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => ConfirmBottomSheet(action: action),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final events = context.watch<EventProvider>().events;
    final now = DateTime.now();
    final suggested = _suggestedAction(settings);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SchoolBuzz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showArrival,
        icon: const Icon(Icons.school),
        label: const Text("I'm at School"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome, ${settings.caregiverName.isEmpty ? "Caregiver" : settings.caregiverName}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(settings.schoolName.isEmpty ? 'No school configured' : settings.schoolName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  Text('Child: ${settings.childName.isEmpty ? "Not set" : settings.childName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  Text('Geofence: ${settings.geofenceRadius.toInt()}m radius',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          // Action cards
          Row(
            children: [
              Expanded(
                child: ActionCard(
                  title: 'Drop-off',
                  icon: Icons.arrow_downward,
                  subtitle: 'Morning',
                  highlighted: suggested == ActionType.dropoff,
                  onTap: () => _quickAction(ActionType.dropoff),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionCard(
                  title: 'Pickup',
                  icon: Icons.arrow_upward,
                  subtitle: 'Afternoon',
                  highlighted: suggested == ActionType.pickup,
                  onTap: () => _quickAction(ActionType.pickup),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _quickAction(ActionType.message),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.message, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Message', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('Send a custom update',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Recent events
          if (events.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Recent Activity', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...events.take(5).map((e) => EventTile(event: e)),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  ActionType _suggestedAction(AppSettings settings) {
    final now = DateTime.now();
    final dropEnd = _parseTime(settings.dropOffEnd);
    final current = now.hour * 60 + now.minute;
    return current < dropEnd ? ActionType.dropoff : ActionType.pickup;
  }

  int _parseTime(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
