import 'package:shared_preferences/shared_preferences.dart';

import '../theme/background_variant.dart';

// оформление хранится только на устройстве, не синхронизируется и не
// уходит на сервер
class ThemeService {
  static const _variantKey = 'background_variant_v1';
  static const _modeKey = 'app_theme_mode_v1';
  static const _reducedContrastKey = 'reduced_contrast_v1';

  Future<BackgroundVariant> loadVariant() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_variantKey);
      return BackgroundVariant.values.firstWhere(
        (v) => v.name == raw,
        orElse: () => BackgroundVariant.violet,
      );
    } catch (_) {
      return BackgroundVariant.violet;
    }
  }

  Future<bool> saveVariant(BackgroundVariant variant) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_variantKey, variant.name);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<AppThemeMode> loadMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_modeKey);
      return AppThemeMode.values.firstWhere(
        (m) => m.name == raw,
        orElse: () => AppThemeMode.dark,
      );
    } catch (_) {
      return AppThemeMode.dark;
    }
  }

  Future<bool> saveMode(AppThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_modeKey, mode.name);
      return true;
    } catch (_) {
      return false;
    }
  }

  // "Сегодня мигрень/сильная усталость" в разделе Самочувствия -
  // приглушает цвета и снижает контрастность по всему приложению, пока
  // пользователь не отметит, что стало лучше. Хранится так же, как
  // остальное оформление - переживает перезапуск приложения в тот же день.
  Future<bool> loadReducedContrast() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_reducedContrastKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> saveReducedContrast(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reducedContrastKey, value);
      return true;
    } catch (_) {
      return false;
    }
  }
}
