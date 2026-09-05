import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventProvider>().events;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event History'),
        actions: [
          if (events.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear history',
              onPressed: () => _confirmClear(context),
            ),
        ],
      ),
      body: events.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No events yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  Text('Events will appear after drop-off or pickup',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (_, i) => _EventCard(event: events[i]),
            ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('This will permanently delete all local events. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<EventProvider>().clearHistory();
              Navigator.pop(context);
            },
            child: Text('Clear', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final SchoolEvent event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('MMM d, yyyy h:mm a').format(event.eventTime);
    final (icon, color) = switch (event.actionType) {
      ActionType.dropoff => (Icons.arrow_downward, Theme.of(context).colorScheme.primary),
      ActionType.pickup => (Icons.arrow_upward, Theme.of(context).colorScheme.tertiary),
      ActionType.message => (Icons.message, Theme.of(context).colorScheme.secondary),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(event.actionType.name[0].toUpperCase() + event.actionType.name.substring(1),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${event.caregiverNameSnapshot} → ${event.childNameSnapshot}'
            '${event.customMessage != null ? '\n${event.customMessage}' : ''}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(time, style: Theme.of(context).textTheme.bodySmall),
            Text(
              event.source == EventSource.geofence ? 'Auto' : 'Manual',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            Text(
              event.shareStatus.name.replaceAll('_', ' '),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: event.shareStatus == ShareStatus.notShared
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
        isThreeLine: event.customMessage != null,
      ),
    );
  }
}
