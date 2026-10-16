import 'package:flutter/foundation.dart';

/// Адрес бэкенда.
///
/// - Android/iOS: задаётся при сборке, иначе приложение не знает, куда
///   ходить: `--dart-define=BACKEND_URL=https://api.lomalu.ru`
///   (см. scripts/build_release.sh и RELEASE.md).
/// - Веб: если не задан - тот же домен, с которого открыт сайт (nginx
///   отдаёт веб-приложение и проксирует /api на бэкенд, см.
///   deploy/nginx/lomalu.conf) - одна сборка работает на любом домене.
/// - Разработка (debug без флага): http://localhost:8000.
class AppConfig {
  static const String _fromBuild = String.fromEnvironment('BACKEND_URL');

  /// Боевой сервер - для релизной сборки на телефон админа.
  static const String productionUrl = 'https://api.lomalu.ru';

  static String get backendUrl {
    if (_fromBuild.isNotEmpty) return _stripSlash(_fromBuild);
    if (kIsWeb && kReleaseMode) return _stripSlash(Uri.base.origin);
    if (kReleaseMode) return productionUrl;
    return 'http://localhost:8000';
  }

  static String _stripSlash(String url) =>
      url.endsWith('/') ? url.substring(0, url.length - 1) : url;
}
