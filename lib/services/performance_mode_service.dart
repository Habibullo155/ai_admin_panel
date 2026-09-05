import 'package:shared_preferences/shared_preferences.dart';

// хранится только на устройстве, тот же приём, что и у остальных
// настроек оформления
class PerformanceModeService {
  static const _key = 'performance_mode_enabled_v1';

  Future<bool> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_key) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> save(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, value);
      return true;
    } catch (_) {
      return false;
    }
  }
}
