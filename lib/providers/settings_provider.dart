import 'package:flutter/foundation.dart';
import '../models/settings.dart';
import '../repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final _repo = SettingsRepository();
  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;
  bool get isSetupComplete => _settings.isSetupComplete;

  Future<void> load() async {
    _settings = await _repo.load();
    notifyListeners();
  }

  Future<void> update(AppSettings Function(AppSettings) updater) async {
    _settings = updater(_settings);
    await _repo.save(_settings);
    notifyListeners();
  }

  Future<void> save(AppSettings settings) async {
    _settings = settings;
    await _repo.save(settings);
    notifyListeners();
  }

  Future<void> clear() async {
    _settings = const AppSettings();
    await _repo.clear();
    notifyListeners();
  }
}
