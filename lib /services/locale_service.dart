import 'package:shared_preferences/shared_preferences.dart';

import '../state/locale_store.dart';

// выбор языка хранится только на устройстве, не синхронизируется и не
// уходит на сервер - тот же принцип, что у оформления (theme_service.dart)
class LocaleService {
  static const _modeKey = 'app_language_mode_v1';

  Future<AppLanguageMode> loadMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_modeKey);
      return AppLanguageMode.values.firstWhere(
        (m) => m.name == raw,
        orElse: () => AppLanguageMode.system,
      );
    } catch (_) {
      return AppLanguageMode.system;
    }
  }

  Future<bool> saveMode(AppLanguageMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_modeKey, mode.name);
      return true;
    } catch (_) {
      return false;
    }
  }
}
