import 'package:flutter/material.dart';

import '../theme/app_text_color.dart';
import '../theme/background_variant.dart';

/// Кружок-образец одного варианта темы — раньше жил только в
/// settings_screen.dart как приватный виджет; вынесен сюда, потому что
/// теперь используется ещё и в message_bubble.dart (ИИ может предложить
/// выбрать тему прямо в разговоре, см. [[OFFER_THEME_PICKER]] в
/// chat_store.dart) - одно место для сопоставления цветов/подписей,
/// не два расходящихся.
class ThemeVariantSwatch extends StatelessWidget {
  final BackgroundVariant variant;
  final bool selected;
  final VoidCallback onTap;
  const ThemeVariantSwatch({super.key, required this.variant, required this.selected, required this.onTap});

  List<Color> get _colors {
    switch (variant) {
      case BackgroundVariant.violet:
        return const [Color(0xFF6C5CE7), Color(0xFF00D9C0)];
      case BackgroundVariant.ocean:
        return const [Color(0xFF00B4D8), Color(0xFF4DD0C4)];
      case BackgroundVariant.midnight:
        return const [Color(0xFF3A3A5C), Color(0xFF5B4B8A)];
      case BackgroundVariant.sunset:
        return const [Color(0xFFFF7E5F), Color(0xFFFEB47B)];
      case BackgroundVariant.forest:
        return const [Color(0xFF2E8B57), Color(0xFF6FCF97)];
      case BackgroundVariant.rose:
        return const [Color(0xFFE0568C), Color(0xFFFF9EBB)];
      case BackgroundVariant.amber:
        return const [Color(0xFFE8A33D), Color(0xFFFFD166)];
      case BackgroundVariant.slate:
        return const [Color(0xFF5C7A99), Color(0xFF8FA8BF)];
      case BackgroundVariant.mint:
        return const [Color(0xFF00D9C0), Color(0xFF6FE7D4)];
    }
  }

  String get _label {
    switch (variant) {
      case BackgroundVariant.violet:
        return 'Фиолетовый';
      case BackgroundVariant.ocean:
        return 'Океан';
      case BackgroundVariant.midnight:
        return 'Полночь';
      case BackgroundVariant.sunset:
        return 'Закат';
      case BackgroundVariant.forest:
        return 'Лес';
      case BackgroundVariant.rose:
        return 'Розовый';
      case BackgroundVariant.amber:
        return 'Янтарь';
      case BackgroundVariant.slate:
        return 'Графит';
      case BackgroundVariant.mint:
        return 'Мята';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: _colors),
              border: Border.all(
                color: selected ? context.onSurface : context.onSurfaceFaded(0.15),
                width: selected ? 2.5 : 1,
              ),
            ),
            child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
          ),
          const SizedBox(height: 6),
          Text(_label, style: TextStyle(color: context.onSurfaceFaded(0.6), fontSize: 10.5)),
        ],
      ),
    );
  }
}
