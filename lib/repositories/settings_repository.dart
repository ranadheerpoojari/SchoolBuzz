import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';

class SettingsRepository {
  static const _prefix = 'sg_';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings.fromMap({
      for (final key in prefs.getKeys().where((k) => k.startsWith(_prefix)))
        key.replaceFirst(_prefix, ''): prefs.get(key),
    });
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final map = settings.toMap();
    for (final entry in map.entries) {
      final key = '$_prefix${entry.key}';
      final value = entry.value;
      if (value is bool) await prefs.setBool(key, value);
      else if (value is int) await prefs.setInt(key, value);
      else if (value is double) await prefs.setDouble(key, value);
      else if (value is String) await prefs.setString(key, value);
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().where((k) => k.startsWith(_prefix))) {
      await prefs.remove(key);
    }
  }
}
