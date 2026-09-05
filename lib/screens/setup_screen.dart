import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/settings_provider.dart';
import '../models/settings.dart';
import '../services/geofence_service.dart';
import '../services/notification_service.dart';
import '../services/analytics_service.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});
  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caregiverCtrl = TextEditingController();
  final _childCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _radiusCtrl = TextEditingController(text: '150');
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Geolocator.requestPermission();
    await NotificationService.requestPermission();
  }

  Future<void> _useCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _latCtrl.text = pos.latitude.toStringAsFixed(6);
        _lngCtrl.text = pos.longitude.toStringAsFixed(6);
      });
    } catch (e) {
      setState(() => _error = 'Could not get location: $e');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    final lat = double.tryParse(_latCtrl.text);
    final lng = double.tryParse(_lngCtrl.text);
    final radius = double.tryParse(_radiusCtrl.text);

    if (lat == null || lat < -90 || lat > 90) {
      setState(() { _error = 'Latitude must be between -90 and 90'; _loading = false; });
      return;
    }
    if (lng == null || lng < -180 || lng > 180) {
      setState(() { _error = 'Longitude must be between -180 and 180'; _loading = false; });
      return;
    }
    if (radius == null || radius < 100 || radius > 500) {
      setState(() { _error = 'Radius must be between 100 and 500 meters'; _loading = false; });
      return;
    }

    final settings = AppSettings(
      caregiverName: _caregiverCtrl.text.trim(),
      childName: _childCtrl.text.trim(),
      schoolName: _schoolCtrl.text.trim(),
      schoolLatitude: lat,
      schoolLongitude: lng,
      geofenceRadius: radius,
      isSetupComplete: true,
    );

    final provider = context.read<SettingsProvider>();
    await provider.save(settings);
    GeofenceService.startMonitoring(settings);

    // Analytics
    AnalyticsService.logSetupComplete();
    AnalyticsService.setUser(
      caregiverName: settings.caregiverName,
      familyId: 'local_${settings.caregiverName}',
    );
    AnalyticsService.setCrashKey('school', settings.schoolName);

    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SchoolBuzz Setup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Configure your profile and school',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _caregiverCtrl,
                decoration: const InputDecoration(
                  labelText: 'Your Name (e.g. Dad, Mom)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _childCtrl,
                decoration: const InputDecoration(
                  labelText: "Child's Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.child_care),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _schoolCtrl,
                decoration: const InputDecoration(
                  labelText: 'School Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              const Divider(),
              Text('School Location', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.\-]'))],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.\-]'))],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _useCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Use Current Location'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _radiusCtrl,
                decoration: const InputDecoration(
                  labelText: 'Geofence Radius (meters, 100–500)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.radio_button_unchecked),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 8),
              Text('Default: 150m. Increase if GPS is inaccurate.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _save,
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                child: _loading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save & Continue', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _caregiverCtrl.dispose();
    _childCtrl.dispose();
    _schoolCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _radiusCtrl.dispose();
    super.dispose();
  }
}
