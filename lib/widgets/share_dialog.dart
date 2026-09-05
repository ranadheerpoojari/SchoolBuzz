import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/settings_provider.dart';
import '../providers/event_provider.dart';

class ShareDialog extends StatelessWidget {
  final SchoolEvent event;
  const ShareDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsProvider>().settings;
    final ep = context.read<EventProvider>();
    final message = ep.buildShareMessage(event, settings);

    return AlertDialog(
      title: const Text('Share Update'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Message preview:', style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () async {
            await ep.shareToWhatsApp(event, settings);
            if (context.mounted) Navigator.pop(context);
          },
          icon: const Icon(Icons.share),
          label: const Text('Share on WhatsApp'),
        ),
      ],
    );
  }
}
