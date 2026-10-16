/// Общий вход - conditional import подставляет реальную реализацию
/// (dart:io, HttpClient с проверкой отпечатка сертификата) на mobile/
/// desktop, и заглушку (обычный http.Client(), pinning невозможен
/// этим механизмом) на вебе - там TLS полностью управляется браузером,
/// у Dart-кода нет доступа к сертификату сервера на таком низком уровне.
library;
export 'pinned_http_client_stub.dart' if (dart.library.io) 'pinned_http_client_io.dart';
