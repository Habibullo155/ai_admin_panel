import 'dart:ui';
import 'package:flutter/material.dart';

import '../state/performance_mode_store.dart';
import '../theme/app_text_color.dart';

// стеклянный контейнер: размытие + полупрозрачная заливка + обводка + тень
// tint: null = адаптивный тон (context.onSurface)
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
        final effectiveTint = tint ?? context.onSurface;
        final isLight = Theme.of(context).brightness == Brightness.light;
        final scaledOpacity = isLight ? opacity * 0.55 : opacity;
        final content = Container(
          padding: padding,
          decoration: BoxDecoration(
            color: effectiveTint.withValues(alpha: scaledOpacity),
            borderRadius: borderRadius,
            border: border ??
                Border.all(
                  color: context.onSurfaceFaded(isLight ? 0.12 : 0.18),
                  width: 1.2,
                ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isLight ? 0.12 : 0.25),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        );

        // эконом-режим принудительно отключает BackdropFilter везде, независимо
        // от того, что запросил вызывающий код
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
