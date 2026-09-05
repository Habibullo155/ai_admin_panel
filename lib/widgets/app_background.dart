import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../state/performance_mode_store.dart';
import '../state/theme_store.dart';

// анимированный фон с плавающими цветными бликами - база глазморфизма.
// У каждого из 9 вариантов своя палитра для тёмного и светлого режима
class AppBackground extends StatefulWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground> {
  // Раньше здесь был AnimationController..repeat() - тикает на полной
  // частоте обновления экрана (обычно 60 раз/сек) БЕСКОНЕЧНО, пока хоть
  // один из ~20 экранов с этим фоном смонтирован (то есть почти всегда,
  // пока приложение открыто).
  //
  // Подтверждено реальным профилем в Chrome DevTools (Performance panel):
  // Interaction to Next Paint доходил до 2500-6250мс даже на самом
  // простом экране входа, где сама обработка клика (Processing duration)
  // занимала всего 30-370мс - то есть проблема была не в клике, а в том,
  // что основной поток был занят ДО и ПОСЛЕ него чем-то ещё. Отдельная
  // трассировка показала, что "Scripting" (4383мс из 5297мс общего
  // времени) почти целиком уходило на Google CDN - это CanvasKit
  // (WASM+Skia), то есть непрерывный рендеринг этой самой анимации во
  // Flutter Web, где рендеринг и обработка событий часто идут в одном
  // потоке (в отличие от нативных платформ с отдельным Raster-потоком).
  //
  // Timer с редким обновлением вместо тикера на полной частоте - при
  // 24-секундном цикле движение настолько медленное, что 12 обновлений в
  // секунду выглядят неотличимо от 60 для человеческого глаза, а нагрузка
  // на основной поток падает примерно в 5 раз.
  static const _cycleDuration = Duration(seconds: 24);
  static const _updateInterval = Duration(milliseconds: 80); // ~12.5 обновлений/сек

  Timer? _timer;
  late final DateTime _startedAt;
  final ValueNotifier<double> _progressNotifier = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    // эконом-режим - если уже включён, анимацию вообще не запускаем
    // (статичный фон, блики застывают в начальном положении). Слушаем
    // изменения, чтобы реагировать сразу, если человек переключит режим
    // прямо во время использования приложения, не только при старте
    PerformanceModeStore.instance.addListener(_onPerformanceModeChanged);
    _updateTimerState();
  }

  void _onPerformanceModeChanged() => _updateTimerState();

  void _updateTimerState() {
    final shouldAnimate = !PerformanceModeStore.instance.enabled;
    if (shouldAnimate && _timer == null) {
      _timer = Timer.periodic(_updateInterval, (_) {
        final elapsedMs = DateTime.now().difference(_startedAt).inMilliseconds;
        final newProgress = (elapsedMs % _cycleDuration.inMilliseconds) / _cycleDuration.inMilliseconds;
        // ValueNotifier уведомляет ТОЛЬКО свой собственный
        // ValueListenableBuilder (сами блики), не весь build() этого
        // виджета - настоящий контент экрана (widget.child) не
        // перестраивается 12 раз в секунду, только он и раньше не
        // перестраивался на все 60 раз/сек через AnimatedBuilder
        _progressNotifier.value = newProgress;
      });
    } else if (!shouldAnimate && _timer != null) {
      _timer?.cancel();
      _timer = null;
      _progressNotifier.value = 0.0; // фиксируем блики в одном положении
    }
  }

  @override
  void dispose() {
    PerformanceModeStore.instance.removeListener(_onPerformanceModeChanged);
    _timer?.cancel();
    _progressNotifier.dispose();
    super.dispose();
  }

  _Palette _paletteFor(BackgroundVariant variant, bool isLight) {
    switch (variant) {
      case BackgroundVariant.violet:
        return isLight
            ? const _Palette(
                base: [Color(0xFFF3F0FF), Color(0xFFEAE4FF), Color(0xFFF3F0FF)],
                blob1: Color(0xFF6C5CE7),
                blob2: Color(0xFF00D9C0),
                blob3: Color(0xFFFF7AC6),
              )
            : const _Palette(
                base: [Color(0xFF0B0F1E), Color(0xFF141A2E), Color(0xFF0B0F1E)],
                blob1: Color(0xFF6C5CE7),
                blob2: Color(0xFF00D9C0),
                blob3: Color(0xFFFF7AC6),
              );
      case BackgroundVariant.ocean:
        return isLight
            ? const _Palette(
                base: [Color(0xFFEAF7FB), Color(0xFFDDF1F6), Color(0xFFEAF7FB)],
                blob1: Color(0xFF00B4D8),
                blob2: Color(0xFF4DD0C4),
                blob3: Color(0xFF3A7CA5),
              )
            : const _Palette(
                base: [Color(0xFF071A24), Color(0xFF0C2836), Color(0xFF071A24)],
                blob1: Color(0xFF00B4D8),
                blob2: Color(0xFF4DD0C4),
                blob3: Color(0xFF3A7CA5),
              );
      case BackgroundVariant.midnight:
        return isLight
            ? const _Palette(
                base: [Color(0xFFF0F0F5), Color(0xFFE6E6EF), Color(0xFFF0F0F5)],
                blob1: Color(0xFF7B6EAE),
                blob2: Color(0xFF9B8ACB),
                blob3: Color(0xFF5B4B8A),
              )
            : const _Palette(
                base: [Color(0xFF08080F), Color(0xFF12121C), Color(0xFF08080F)],
                blob1: Color(0xFF3A3A5C),
                blob2: Color(0xFF5B4B8A),
                blob3: Color(0xFF2E2E48),
              );
      case BackgroundVariant.sunset:
        return isLight
            ? const _Palette(
                base: [Color(0xFFFFF1E9), Color(0xFFFFE4D6), Color(0xFFFFF1E9)],
                blob1: Color(0xFFFF7E5F),
                blob2: Color(0xFFFEB47B),
                blob3: Color(0xFFE8618C),
              )
            : const _Palette(
                base: [Color(0xFF1F0F12), Color(0xFF2B1418), Color(0xFF1F0F12)],
                blob1: Color(0xFFFF7E5F),
                blob2: Color(0xFFFEB47B),
                blob3: Color(0xFFE8618C),
              );
      case BackgroundVariant.forest:
        return isLight
            ? const _Palette(
                base: [Color(0xFFEDF7EE), Color(0xFFE0F1E3), Color(0xFFEDF7EE)],
                blob1: Color(0xFF2E8B57),
                blob2: Color(0xFF6FCF97),
                blob3: Color(0xFF1B5E4A),
              )
            : const _Palette(
                base: [Color(0xFF0A1710), Color(0xFF102218), Color(0xFF0A1710)],
                blob1: Color(0xFF2E8B57),
                blob2: Color(0xFF6FCF97),
                blob3: Color(0xFF1B5E4A),
              );
      case BackgroundVariant.rose:
        return isLight
            ? const _Palette(
                base: [Color(0xFFFDF0F4), Color(0xFFFCE2EA), Color(0xFFFDF0F4)],
                blob1: Color(0xFFE0568C),
                blob2: Color(0xFFFF9EBB),
                blob3: Color(0xFFB23A6B),
              )
            : const _Palette(
                base: [Color(0xFF1A0A12), Color(0xFF25101B), Color(0xFF1A0A12)],
                blob1: Color(0xFFE0568C),
                blob2: Color(0xFFFF9EBB),
                blob3: Color(0xFFB23A6B),
              );
      case BackgroundVariant.amber:
        return isLight
            ? const _Palette(
                base: [Color(0xFFFFF8E6), Color(0xFFFFEFC7), Color(0xFFFFF8E6)],
                blob1: Color(0xFFE8A33D),
                blob2: Color(0xFFFFD166),
                blob3: Color(0xFFC97B1F),
              )
            : const _Palette(
                base: [Color(0xFF1C1608), Color(0xFF29200D), Color(0xFF1C1608)],
                blob1: Color(0xFFE8A33D),
                blob2: Color(0xFFFFD166),
                blob3: Color(0xFFC97B1F),
              );
      case BackgroundVariant.slate:
        return isLight
            ? const _Palette(
                base: [Color(0xFFF1F3F5), Color(0xFFE4E8EC), Color(0xFFF1F3F5)],
                blob1: Color(0xFF5C7A99),
                blob2: Color(0xFF8FA8BF),
                blob3: Color(0xFF3D5266),
              )
            : const _Palette(
                base: [Color(0xFF0D1114), Color(0xFF161C21), Color(0xFF0D1114)],
                blob1: Color(0xFF5C7A99),
                blob2: Color(0xFF8FA8BF),
                blob3: Color(0xFF3D5266),
              );
      case BackgroundVariant.mint:
        return isLight
            ? const _Palette(
                base: [Color(0xFFEBFAF6), Color(0xFFD9F3EC), Color(0xFFEBFAF6)],
                blob1: Color(0xFF00D9C0),
                blob2: Color(0xFF6FE7D4),
                blob3: Color(0xFF00A891),
              )
            : const _Palette(
                base: [Color(0xFF071815), Color(0xFF0C221E), Color(0xFF071815)],
                blob1: Color(0xFF00D9C0),
                blob2: Color(0xFF6FE7D4),
                blob3: Color(0xFF00A891),
              );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeStore.instance,
      builder: (context, _) {
        // Theme.of(context).brightness, не ThemeStore.instance.mode
        // напрямую - при системном режиме (AppThemeMode.system) сырой
        // mode не равен ни light, ни dark, а разрешённая MaterialApp'ом
        // фактическая яркость всегда корректна независимо от того, как
        // она была выбрана (вручную или через системную тему устройства)
        final isLight = Theme.of(context).brightness == Brightness.light;
        final reducedContrast = ThemeStore.instance.reducedContrast;
        final palette = _paletteFor(ThemeStore.instance.variant, isLight);
        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: palette.base,
                ),
              ),
            ),
            // RepaintBoundary - эта анимация крутится непрерывно (24 сек
            // цикл, тикает на частоте обновления экрана) на фоне примерно
            // 20 экранов приложения ВСЁ время, пока приложение открыто, в
            // отличие от анимаций конкретных упражнений, которые идут
            // только пока человек на том самом экране. Без изоляции слоя
            // перерисовки её собственный повторный рендер на каждом кадре
            // мог бы заставлять GPU лишний раз обрабатывать соседние
            // слои композиции - стандартный, безопасный приём Flutter,
            // не меняющий ничего визуально.
            RepaintBoundary(
              child: ValueListenableBuilder<double>(
                valueListenable: _progressNotifier,
                builder: (context, progress, _) {
                  final t = progress * 2 * math.pi;
                  return Stack(
                    children: [
                      _blob(
                        color: palette.blob1,
                        alignment: Alignment(math.sin(t) * 0.8, -0.9 + math.cos(t) * 0.3),
                        size: 420,
                        // раньше 0.22 + плёнка 0.45 ниже почти полностью
                        // вымывали цвет - фон казался "пропавшим". Теперь
                        // блики заметно ярче, плёнка снята почти до нуля -
                        // мягкость обеспечивают уже сами пастельные базовые
                        // цвета палитры (см. _paletteFor выше), не плёнка.
                        // reducedContrast - "сегодня мигрень/усталость" в
                        // Самочувствии - снова притушивает, отдельно от темы
                        opacity: (isLight ? 0.4 : 0.55) * (reducedContrast ? 0.55 : 1.0),
                      ),
                      _blob(
                        color: palette.blob2,
                        alignment: Alignment(-0.9 + math.sin(t * 0.7) * 0.4, math.cos(t) * 0.9),
                        size: 380,
                        opacity: (isLight ? 0.4 : 0.55) * (reducedContrast ? 0.55 : 1.0),
                      ),
                      _blob(
                        color: palette.blob3,
                        alignment: Alignment(0.9 * math.cos(t * 0.5), 0.9 * math.sin(t * 0.9)),
                        size: 340,
                        opacity: (isLight ? 0.4 : 0.55) * (reducedContrast ? 0.55 : 1.0),
                      ),
                    ],
                  );
                },
              ),
            ),
            // тёмный режим: чёрная плёнка притушивает блики, чтобы они не
            // резали глаз на тёмном фоне. Светлый режим - лёгкая белая
            // плёнка, почти незаметная - только слегка смягчает края
            // бликов, не вымывает цвет целиком. При reducedContrast обе
            // плёнки усилены - именно это и означает "снизить контрастность"
            if (isLight) Container(color: Colors.white.withValues(alpha: reducedContrast ? 0.32 : 0.12)),
            if (!isLight) Container(color: Colors.black.withValues(alpha: reducedContrast ? 0.42 : 0.25)),
            widget.child,
          ],
        );
      },
    );
  }

  Widget _blob({
    required Color color,
    required Alignment alignment,
    required double size,
    required double opacity,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}

class _Palette {
  final List<Color> base;
  final Color blob1;
  final Color blob2;
  final Color blob3;
  const _Palette({required this.base, required this.blob1, required this.blob2, required this.blob3});
}
