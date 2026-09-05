import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/settings_provider.dart';
import '../providers/event_provider.dart';
import '../widgets/arrival_bottom_sheet.dart';

class ArrivalScreen extends StatelessWidget {
  const ArrivalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('School Arrival')),
      body: const Center(
        child: ArrivalBottomSheet(embedded: true),
      ),
    );
  }
}
