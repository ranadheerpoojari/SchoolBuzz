import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../providers/settings_provider.dart';
import '../providers/event_provider.dart';
import 'share_dialog.dart';

class ConfirmBottomSheet extends StatelessWidget {
  final ActionType action;
  const ConfirmBottomSheet({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsProvider>().settings;
    final now = DateTime.now();
    final time = DateFormat('h:mm a').format(now);
    final date = DateFormat('EEEE, MMMM d').format(now);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Confirm ${action.name[0].toUpperCase()}${action.name.substring(1)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _info('Child', settings.childName),
          _info('By', settings.caregiverName),
          _info('School', settings.schoolName),
          _info('Date', date),
          _info('Time', time),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              final ep = context.read<EventProvider>();
              final sp = context.read<SettingsProvider>();
              final event = action == ActionType.dropoff
                  ? await ep.confirmDropoff(sp.settings)
                  : await ep.confirmPickup(sp.settings);
              if (context.mounted) {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => ShareDialog(event: event),
                );
              }
            },
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const Text('Confirm & Share', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
