import 'package:shared_preferences/shared_preferences.dart';

// хранится только на устройстве, тот же приём, что и у оформления
// (theme_service.dart) - не синхронизируется между устройствами
class NotificationPrefsService {
  static const _soundKey = 'notification_sound_enabled_v1';
  static const _vibrationKey = 'notification_vibration_enabled_v1';

  Future<bool> loadSoundEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_soundKey) ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<bool> saveSoundEnabled(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundKey, value);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> loadVibrationEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_vibrationKey) ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<bool> saveVibrationEnabled(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_vibrationKey, value);
      return true;
    } catch (_) {
      return false;
    }
  }
}
