import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/event_provider.dart';
import 'share_dialog.dart';

class MessageBottomSheet extends StatefulWidget {
  const MessageBottomSheet({super.key});
  @override
  State<MessageBottomSheet> createState() => _MessageBottomSheetState();
}

class _MessageBottomSheetState extends State<MessageBottomSheet> {
  final _ctrl = TextEditingController();
  final _quickTexts = ['Running late', 'Waiting outside', 'At the front entrance', 'Please call me'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Send Message', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('Quick texts:', style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _quickTexts.map((qt) =>
              ActionChip(label: Text(qt), onPressed: () => _ctrl.text = qt)
            ).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              labelText: 'Your message',
              border: OutlineInputBorder(),
            ),
            minLines: 2,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _ctrl.text.trim().isEmpty ? null : () async {
              final ep = context.read<EventProvider>();
              final sp = context.read<SettingsProvider>();
              final event = await ep.createMessage(sp.settings, _ctrl.text.trim());
              if (context.mounted) {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => ShareDialog(event: event),
                );
              }
            },
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: const Text('Send via WhatsApp', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
