import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import '../services/locale_service.dart';

// "system" - следовать языку устройства (как было всегда) - "ru"/"en" -
// явный выбор человека, игнорирует системный язык
enum AppLanguageMode { system, ru, en }

// синглтон - MaterialApp слушает изменения на верхнем уровне (см.
// app.dart), тот же приём, что у ThemeStore
class LocaleStore extends ChangeNotifier {
  LocaleStore._internal();
  static final LocaleStore instance = LocaleStore._internal();

  final LocaleService _service = LocaleService();
  AppLanguageMode mode = AppLanguageMode.system;

  // null - MaterialApp.locale тоже ожидает null для "определи сам по
  // системе" - явный Locale('ru')/Locale('en') только когда человек сам
  // выбрал конкретный язык
  Locale? get resolvedLocale => switch (mode) {
        AppLanguageMode.system => null,
        AppLanguageMode.ru => const Locale('ru'),
        AppLanguageMode.en => const Locale('en'),
      };

  Future<void> load() async {
    mode = await _service.loadMode();
    notifyListeners();
  }

  Future<void> setMode(AppLanguageMode newMode) async {
    mode = newMode;
    notifyListeners();
    await _service.saveMode(newMode);
  }
}
