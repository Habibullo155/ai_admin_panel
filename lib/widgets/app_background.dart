import 'package:flutter/material.dart';

import '../state/theme_store.dart';

// Статичный фон-градиент под тему
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  _Palette _paletteFor(BackgroundVariant variant, bool isLight) {
    switch (variant) {
      case BackgroundVariant.violet:
        return isLight
            ? const _Palette(base: [Color(0xFFF3F0FF), Color(0xFFEAE4FF), Color(0xFFF3F0FF)])
            : const _Palette(base: [Color(0xFF0B0F1E), Color(0xFF141A2E), Color(0xFF0B0F1E)]);
      case BackgroundVariant.ocean:
        return isLight
            ? const _Palette(base: [Color(0xFFEAF7FB), Color(0xFFDDF1F6), Color(0xFFEAF7FB)])
            : const _Palette(base: [Color(0xFF071A24), Color(0xFF0C2836), Color(0xFF071A24)]);
      case BackgroundVariant.midnight:
        return isLight
            ? const _Palette(base: [Color(0xFFF0F0F5), Color(0xFFE6E6EF), Color(0xFFF0F0F5)])
            : const _Palette(base: [Color(0xFF08080F), Color(0xFF12121C), Color(0xFF08080F)]);
      case BackgroundVariant.sunset:
        return isLight
            ? const _Palette(base: [Color(0xFFFFF1E9), Color(0xFFFFE4D6), Color(0xFFFFF1E9)])
            : const _Palette(base: [Color(0xFF1F0F12), Color(0xFF2B1418), Color(0xFF1F0F12)]);
      case BackgroundVariant.forest:
        return isLight
            ? const _Palette(base: [Color(0xFFEDF7EE), Color(0xFFE0F1E3), Color(0xFFEDF7EE)])
            : const _Palette(base: [Color(0xFF0A1710), Color(0xFF102218), Color(0xFF0A1710)]);
      case BackgroundVariant.rose:
        return isLight
            ? const _Palette(base: [Color(0xFFFDF0F4), Color(0xFFFCE2EA), Color(0xFFFDF0F4)])
            : const _Palette(base: [Color(0xFF1A0A12), Color(0xFF25101B), Color(0xFF1A0A12)]);
      case BackgroundVariant.amber:
        return isLight
            ? const _Palette(base: [Color(0xFFFFF8E6), Color(0xFFFFEFC7), Color(0xFFFFF8E6)])
            : const _Palette(base: [Color(0xFF1C1608), Color(0xFF29200D), Color(0xFF1C1608)]);
      case BackgroundVariant.slate:
        return isLight
            ? const _Palette(base: [Color(0xFFF1F3F5), Color(0xFFE4E8EC), Color(0xFFF1F3F5)])
            : const _Palette(base: [Color(0xFF0D1114), Color(0xFF161C21), Color(0xFF0D1114)]);
      case BackgroundVariant.mint:
        return isLight
            ? const _Palette(base: [Color(0xFFEBFAF6), Color(0xFFD9F3EC), Color(0xFFEBFAF6)])
            : const _Palette(base: [Color(0xFF071815), Color(0xFF0C221E), Color(0xFF071815)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeStore.instance,
      builder: (context, _) {
        // Theme.of(context).brightness, не ThemeStore.instance.mode напрямую
        final isLight = Theme.of(context).brightness == Brightness.light;
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
            child,
          ],
        );
      },
    );
  }
}

class _Palette {
  final List<Color> base;
  const _Palette({required this.base});
}
