import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';

class EventTile extends StatelessWidget {
  final SchoolEvent event;
  const EventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('h:mm a').format(event.eventTime);
    final (icon, color) = switch (event.actionType) {
      ActionType.dropoff => (Icons.arrow_downward, Theme.of(context).colorScheme.primary),
      ActionType.pickup => (Icons.arrow_upward, Theme.of(context).colorScheme.tertiary),
      ActionType.message => (Icons.message, Theme.of(context).colorScheme.secondary),
    };

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(event.actionType.name[0].toUpperCase() + event.actionType.name.substring(1)),
      subtitle: Text('${event.caregiverNameSnapshot} → ${event.childNameSnapshot}'),
      trailing: Text(time, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
