import 'package:flutter/material.dart';

import 'glass_panel.dart';

/// Тот же текст и номера, что уже использовались в чек-ине ВОЗ-5 —
/// вынесено в общий виджет, чтобы использовать один и тот же текст
/// везде, где это уместно (PHQ-9, GAD-7), а не дублировать и рисковать
/// расхождением.
class CrisisResourcesPanel extends StatelessWidget {
  final String? title;
  const CrisisResourcesPanel({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      opacity: 0.08,
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? 'Если хочется поговорить с кем-то',
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w600, fontSize: 13.5),
          ),
          const SizedBox(height: 8),
          Text(
            '• Экстренная психологическая помощь для взрослых и детей, '
            'круглосуточно и бесплатно: 8-800-100-49-94\n'
            '• Детский и подростковый телефон доверия: 8-800-2000-122 '
            '(короткий номер — 124)',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12.5, height: 1.6),
          ),
        ],
      ),
    );
  }
}
