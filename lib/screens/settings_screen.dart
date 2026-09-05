import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/settings.dart';
import '../providers/settings_provider.dart';
import '../services/geofence_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _s;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _s = context.read<SettingsProvider>().settings;
  }

  Future<void> _save() async {
    await context.read<SettingsProvider>().save(_s);
    GeofenceService.stopMonitoring();
    GeofenceService.startMonitoring(_s);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Profile', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _field('Caregiver Name', _s.caregiverName, (v) => _s = _s.copyWith(caregiverName: v)),
            _field("Child's Name", _s.childName, (v) => _s = _s.copyWith(childName: v)),
            const Divider(height: 32),

            Text('School', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _field('School Name', _s.schoolName, (v) => _s = _s.copyWith(schoolName: v)),
            Row(children: [
              Expanded(child: _numField('Latitude', _s.schoolLatitude.toString(),
                  (v) => _s = _s.copyWith(schoolLatitude: double.tryParse(v) ?? _s.schoolLatitude))),
              const SizedBox(width: 12),
              Expanded(child: _numField('Longitude', _s.schoolLongitude.toString(),
                  (v) => _s = _s.copyWith(schoolLongitude: double.tryParse(v) ?? _s.schoolLongitude))),
            ]),
            _numField('Radius (meters)', _s.geofenceRadius.toInt().toString(),
                (v) => _s = _s.copyWith(geofenceRadius: (double.tryParse(v) ?? _s.geofenceRadius).toDouble())),
            const Divider(height: 32),

            Text('Schedule', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _field('Drop-off Start', _s.dropOffStart, (v) => _s = _s.copyWith(dropOffStart: v))),
              const SizedBox(width: 12),
              Expanded(child: _field('Drop-off End', _s.dropOffEnd, (v) => _s = _s.copyWith(dropOffEnd: v))),
            ]),
            Row(children: [
              Expanded(child: _field('Pickup Start', _s.pickupStart, (v) => _s = _s.copyWith(pickupStart: v))),
              const SizedBox(width: 12),
              Expanded(child: _field('Pickup End', _s.pickupEnd, (v) => _s = _s.copyWith(pickupEnd: v))),
            ]),
            const SizedBox(height: 8),
            Text('Active Days', style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: 4,
              children: [
                for (int d = 1; d <= 7; d++)
                  FilterChip(
                    label: Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1]),
                    selected: _s.activeDays.contains(d),
                    onSelected: (sel) {
                      setState(() {
                        final days = List<int>.from(_s.activeDays);
                        sel ? days.add(d) : days.remove(d);
                        _s = _s.copyWith(activeDays: days);
                      });
                    },
                  ),
              ],
            ),
            const Divider(height: 32),

            Text('Behavior', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _numField('Cooldown (minutes, 5–120)', _s.cooldownMinutes.toString(),
                (v) => _s = _s.copyWith(cooldownMinutes: int.tryParse(v) ?? _s.cooldownMinutes)),
            SwitchListTile(
              title: const Text('App Enabled'),
              value: _s.appEnabled,
              onChanged: (v) => setState(() => _s = _s.copyWith(appEnabled: v)),
            ),
            SwitchListTile(
              title: const Text('WhatsApp Sharing'),
              value: _s.whatsappEnabled,
              onChanged: (v) => setState(() => _s = _s.copyWith(whatsappEnabled: v)),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('App Permissions'),
              subtitle: const Text('Open system settings to manage location & notification permissions'),
              onTap: () => openAppSettings(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: const Text('Save Settings', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, String value, void Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        onChanged: onChanged,
      ),
    );
  }

  Widget _numField(String label, String value, void Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.\-]'))],
        onChanged: onChanged,
      ),
    );
  }
}
