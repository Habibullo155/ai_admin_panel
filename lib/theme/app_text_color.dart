import 'package:flutter/material.dart';

/// Раньше цвет текста/иконок был захардкожен как `Colors.white` буквально
/// в 25 файлах (317 мест) — это работало только для тёмной темы. Этот
/// extension даёт единую точку, откуда берётся "основной цвет текста" —
/// белый в тёмной теме, тёмно-синий в светлой — так что при переключении
/// темы весь текст читается правильно, а не остаётся белым на белом фоне.
extension AppTextColor on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Полностью непрозрачный основной цвет текста/иконок.
  Color get onSurface => isDarkMode ? Colors.white : const Color(0xFF1A1A2E);

  /// Приглушённый текст/иконки — тот же принцип, что и
  /// `Colors.white.withOpacity(x)`, но теперь адаптируется под тему. В
  /// светлой теме берём чуть больший множитель непрозрачности — тёмный
  /// текст с той же числовой прозрачностью, что и белый, на светлом фоне
  /// читается хуже.
  Color onSurfaceFaded(double opacity) {
    if (isDarkMode) return Colors.white.withOpacity(opacity);
    return const Color(0xFF1A1A2E).withOpacity((opacity * 1.15).clamp(0.0, 1.0));
  }

  /// Граница/обводка стеклянных панелей.
  Color get borderSubtle => isDarkMode ? Colors.white.withOpacity(0.14) : Colors.black.withOpacity(0.10);
}
