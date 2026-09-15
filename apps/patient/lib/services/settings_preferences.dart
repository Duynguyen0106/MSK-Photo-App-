import 'package:shared_preferences/shared_preferences.dart';

/// Patient app settings stored on device.
class SettingsPreferences {
  static const _anonymousStatsKey = 'anonymous_stats_enabled';

  Future<bool> get anonymousStatsEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_anonymousStatsKey) ?? false;
  }

  Future<void> setAnonymousStatsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_anonymousStatsKey, value);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
