import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/settings_provider.dart';
import 'confirm_bottom_sheet.dart';
import 'message_bottom_sheet.dart';

class ArrivalBottomSheet extends StatelessWidget {
  final bool embedded;
  const ArrivalBottomSheet({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dropEnd = _parseTime(context.read<SettingsProvider>().settings.dropOffEnd);
    final current = now.hour * 60 + now.minute;
    final suggested = current < dropEnd ? ActionType.dropoff : ActionType.pickup;

    final content = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('School Arrival', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('What would you like to do?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          for (final action in ActionType.values) ...[
            FilledButton.tonal(
              onPressed: () {
                Navigator.pop(context); // close arrival sheet
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
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: action == suggested
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(switch (action) {
                    ActionType.dropoff => Icons.arrow_downward,
                    ActionType.pickup => Icons.arrow_upward,
                    ActionType.message => Icons.message,
                  }),
                  const SizedBox(width: 8),
                  Text(switch (action) {
                    ActionType.dropoff => 'Drop-off${action == suggested ? " (suggested)" : ""}',
                    ActionType.pickup => 'Pickup${action == suggested ? " (suggested)" : ""}',
                    ActionType.message => 'Message',
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );

    if (embedded) return content;
    return content;
  }

  int _parseTime(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
