import 'package:flutter/foundation.dart';

import '../services/theme_service.dart';
import '../theme/background_variant.dart';

export '../theme/background_variant.dart';

// синглтон - AppBackground используется примерно в 20 экранах, пробрасывать
// через конструктор каждого ради выбора фона было бы избыточно
class ThemeStore extends ChangeNotifier {
  ThemeStore._internal();
  static final ThemeStore instance = ThemeStore._internal();

  final ThemeService _service = ThemeService();
  BackgroundVariant variant = BackgroundVariant.violet;
  AppThemeMode mode = AppThemeMode.dark;
  bool reducedContrast = false;

  Future<void> load() async {
    variant = await _service.loadVariant();
    mode = await _service.loadMode();
    reducedContrast = await _service.loadReducedContrast();
    notifyListeners();
  }

  Future<void> setVariant(BackgroundVariant newVariant) async {
    variant = newVariant;
    notifyListeners();
    await _service.saveVariant(newVariant);
  }

  Future<void> setMode(AppThemeMode newMode) async {
    mode = newMode;
    notifyListeners();
    await _service.saveMode(newMode);
  }

  Future<void> setReducedContrast(bool value) async {
    reducedContrast = value;
    notifyListeners();
    await _service.saveReducedContrast(value);
  }
}
