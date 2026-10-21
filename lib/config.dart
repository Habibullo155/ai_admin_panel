import 'package:flutter/foundation.dart';

/// Адрес бэкенда.
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
