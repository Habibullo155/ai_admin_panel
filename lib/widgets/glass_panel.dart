import 'dart:ui';
import 'package:flutter/material.dart';

import '../state/performance_mode_store.dart';
import '../theme/app_text_color.dart';

// стеклянный контейнер: размытие + полупрозрачная заливка + обводка + тень
//
// tint: null = адаптивный тон (context.onSurface) - белое стекло в тёмной
// теме (та же полупрозрачная белая плёнка, что и раньше), тёмно-синее в
// светлой. Раньше здесь был жёстко Colors.white всегда, независимо от
// темы - на светлом фоне полупрозрачный белый почти сливался с и так
// светлым фоном приложения ("терялся"), это и было исправлено.
//
// blurred: false для списков (сообщения в чате) - BackdropFilter на
// каждый элемент прокручиваемого списка заметно бьёт по FPS, эффект
// стекла остаётся и без него (заливка + обводка), просто без блюра фона
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? tint;
  final Border? border;
  final bool blurred;

  const GlassPanel({
    super.key,
    required this.child,
    this.blur = 22,
    this.opacity = 0.10,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding,
    this.tint,
    this.border,
    this.blurred = true,
  });

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder на PerformanceModeStore - переключение экономного
    // режима в настройках сразу отражается на всех ~128 местах
    // использования этой панели, без необходимости лезть в каждый вызов
    return AnimatedBuilder(
      animation: PerformanceModeStore.instance,
      builder: (context, _) {
        // раньше дефолт (когда tint явно не задан) был жёстко Colors.white -
        // на тёмном фоне полупрозрачный белый даёт видимый контраст, но на
        // светлой теме полупрозрачный белый почти сливается с и так светлым
        // фоном приложения ("теряется"). context.onSurface даёт то же самое
        // белое стекло в тёмном режиме (поведение не меняется) и тёмно-синее
        // стекло в светлом - там, где явный tint не передан явно
        final effectiveTint = tint ?? context.onSurface;
        // раньше каждый вызов передавал свою фиксированную opacity (0.06-0.18
        // в разных местах), значение темы никак её не трогало - "сделать
        // светлую тему прозрачнее" точечно менять дефолт бесполезно, почти
        // никто его не использует. Вместо этого масштабируем РЕАЛЬНУЮ
        // непрозрачность здесь, в одном месте - тёмный режим не трогаем
        // вообще (множитель 1), светлый становится заметно прозрачнее
        final isLight = Theme.of(context).brightness == Brightness.light;
        final scaledOpacity = isLight ? opacity * 0.55 : opacity;
        final content = Container(
          padding: padding,
          decoration: BoxDecoration(
            color: effectiveTint.withOpacity(scaledOpacity),
            borderRadius: borderRadius,
            border: border ??
                Border.all(
                  color: context.onSurfaceFaded(isLight ? 0.12 : 0.18),
                  width: 1.2,
                ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isLight ? 0.12 : 0.25),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        );

        // эконом-режим принудительно отключает BackdropFilter везде,
        // независимо от того, что запросил вызывающий код - это самая
        // дорогая часть стеклянного эффекта: пересчитывает размытие
        // фона позади панели на каждый кадр, где фон меняется (а он
        // меняется постоянно, пока крутится анимация AppBackground)
        final effectiveBlurred = blurred && !PerformanceModeStore.instance.enabled;
        if (!effectiveBlurred) return content; // без ClipRRect/BackdropFilter, дешевле

        return ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: content,
          ),
        );
      },
    );
  }
}
