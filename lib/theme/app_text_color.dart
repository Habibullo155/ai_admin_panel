import 'package:flutter/material.dart';

extension AppTextColor on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Полностью непрозрачный основной цвет текста/иконок.
  Color get onSurface => isDarkMode ? Colors.white : const Color(0xFF1A1A2E);

  /// Приглушённый текст/иконки — тот же принцип, что и
  /// `Colors.white.withValues(alpha: x)`, но теперь адаптируется под тему.
  Color onSurfaceFaded(double opacity) {
    if (isDarkMode) return Colors.white.withValues(alpha: opacity);
    return const Color(0xFF1A1A2E).withValues(alpha: (opacity * 1.15).clamp(0.0, 1.0));
  }

  /// Граница/обводка стеклянных панелей.
  Color get borderSubtle => isDarkMode ? Colors.white.withValues(alpha: 0.14) : Colors.black.withValues(alpha: 0.10);
}
