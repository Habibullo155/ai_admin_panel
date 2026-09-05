import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  // Без этого необработанное исключение в асинхронном коде (Future,
  // например ошибка внутри callback'а, который никто не await'ит) просто
  // тихо теряется — runZonedGuarded гарантирует, что она хотя бы попадёт
  // в лог, а не исчезнет незаметно.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Дефолтный "красный экран смерти" Flutter при ошибке рендеринга —
      // не то, что должен увидеть админ. Показываем свой стилизованный
      // экран вместо него.
      ErrorWidget.builder = (FlutterErrorDetails details) => _FriendlyErrorScreen(details: details);

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
      };

      // без этого DateFormat с названиями месяцев (используется в панелях
      // с датами) бросает исключение при первом обращении к любой локали,
      // кроме встроенной en_US - тот же фикс, что и в основном приложении
      await initializeDateFormatting('ru');

      runApp(const AdminApp());
    },
    (error, stack) {
      debugPrint('Необработанная ошибка: $error\n$stack');
    },
  );
}

class _FriendlyErrorScreen extends StatelessWidget {
  final FlutterErrorDetails details;
  const _FriendlyErrorScreen({required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B0F1E),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.white38, size: 40),
          SizedBox(height: 12),
          Text(
            'Что-то пошло не так',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            'Попробуй вернуться назад или перезапустить приложение.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
