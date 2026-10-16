import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Отпечатки (SHA-256 от целого DER-сертификата, не только публичного
/// ключа - Dart X509Certificate не даёт доступа к SubjectPublicKeyInfo
/// без ручного разбора ASN.1, а весь сертификат даёт то же практическое
/// свойство: сервер с любым другим сертификатом, даже честно подписанным
/// доверенным CA, будет отклонён - именно так выглядит защита от MitM
/// через скомпрометированный/поддельный CA или corporate-прокси).
///
/// ПУСТ ПО УМОЛЧАНИЮ - pinning выключен, обычная проверка через
/// системные корневые сертификаты. Это НАМЕРЕННОЕ решение, не
/// недоделанная часть: включать список нужно только тогда, когда
/// известны точные отпечатки текущего живого сертификата - до этого
/// момента заполнять его нечем, а неверный отпечаток означает, что
/// приложение не сможет обратиться к серверу вообще, ни при каких
/// условиях.
///
/// Перед включением pinning:
/// 1. получить сертификат сервера:
///    `openssl s_client -connect ХОСТ:443 </dev/null 2>/dev/null | openssl x509 -outform der | sha256sum`
/// 2. добавить сюда получившийся хеш И хотя бы один "запасной" (backup
///    pin) заранее - отпечаток отдельно сгенерированной резервной пары
///    ключей, сертификат для которой выпущен, но не используется
///    сейчас (стандартная практика pinning именно для того, чтобы
///    было чем заменить основной pin при экстренной ротации, не
///    трогая код).
///
/// БЕЗ backup pin: certbot/Let's Encrypt продлевает сертификат
/// автоматически примерно каждые 60-90 дней с НОВЫМ, отличным DER
/// (даже если открытый ключ переиспользован, отпечаток всего
/// сертификата - другой) - первое же продление оборвёт связь со ВСЕМИ
/// уже установленными копиями приложения одновременно, до выхода
/// обновления через App Store/Google Play (дни на ревью). Это не
/// гипотетический риск, а гарантированное следствие автопродления,
/// если приложение полагается на pinning без плана ротации.
const List<String> pinnedCertificateSha256Fingerprints = [];

http.Client createHttpClient() {
  if (pinnedCertificateSha256Fingerprints.isEmpty) {
    return http.Client();
  }
  // withTrustedRoots: false - НЕ доверяем системным CA вообще (пустой
  // trust store), поэтому badCertificateCallback ниже вызывается
  // ВСЕГДА (обычная валидация гарантированно "проваливается" при
  // пустом trust store) - здесь мы сами и только сами решаем, доверять
  // ли конкретному сертификату, на основе отпечатка
  final httpClient = HttpClient(context: SecurityContext(withTrustedRoots: false));
  httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
    final fingerprint = sha256.convert(cert.der).toString();
    return pinnedCertificateSha256Fingerprints.contains(fingerprint);
  };
  return IOClient(httpClient);
}
