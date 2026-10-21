import 'package:http/http.dart' as http;

/// На вебе dart:io недоступен вообще (не просто "не работает", компилятор не
/// находит эти типы при сборке под веб)
const List<String> pinnedCertificateSha256Fingerprints = [];

http.Client createHttpClient() => http.Client();
