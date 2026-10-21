import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Отпечатки (SHA-256 от целого DER-сертификата, не только публичного ключа
const List<String> pinnedCertificateSha256Fingerprints = [];

http.Client createHttpClient() {
  if (pinnedCertificateSha256Fingerprints.isEmpty) {
    return http.Client();
  }
  // withTrustedRoots: false
  final httpClient = HttpClient(context: SecurityContext(withTrustedRoots: false));
  httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
    final fingerprint = sha256.convert(cert.der).toString();
    return pinnedCertificateSha256Fingerprints.contains(fingerprint);
  };
  return IOClient(httpClient);
}
