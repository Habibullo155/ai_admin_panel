import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/system_status.dart';

class AdminSystemException implements Exception {
  final String message;
  AdminSystemException(this.message);
  @override
  String toString() => message;
}

class AdminSystemService {
  final http.Client _client = http.Client();

  void dispose() => _client.close();

  String? _extractError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['detail'] is String) return decoded['detail'] as String;
    } catch (_) {
      // тело не JSON или без detail - вызывающий код подставит свой резервный текст
    }
    return null;
  }

  Future<SystemStatus> getStatus({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/admin/system/status'), headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw AdminSystemException(_extractError(res.body) ?? 'Не удалось загрузить состояние сервера.');
    }
    return SystemStatus.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<BackupInfo>> listBackups({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/admin/system/backups'), headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw AdminSystemException(_extractError(res.body) ?? 'Не удалось загрузить список бэкапов.');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => BackupInfo.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BackupInfo> createBackup({required String baseUrl, required String token}) async {
    // до 10 минут на сервере (см. routers_admin_system.py) - таймаут
    // клиента должен быть хотя бы таким же с запасом, иначе клиент решит,
    // что бэкап не удался, пока сервер всё ещё честно его делает
    final res = await _client
        .post(Uri.parse('$baseUrl/api/admin/system/backups'), headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(minutes: 11));
    if (res.statusCode >= 400) {
      throw AdminSystemException(_extractError(res.body) ?? 'Не удалось создать бэкап (код ${res.statusCode}).');
    }
    return BackupInfo.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteBackup({required String baseUrl, required String token, required String filename}) async {
    final res = await _client
        .delete(Uri.parse('$baseUrl/api/admin/system/backups/$filename'), headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw AdminSystemException(_extractError(res.body) ?? 'Не удалось удалить бэкап.');
    }
  }

  Future<Uint8List> downloadBackup({required String baseUrl, required String token, required String filename}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/admin/system/backups/$filename/download'), headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(minutes: 5));
    if (res.statusCode >= 400) {
      throw AdminSystemException(_extractError(res.body) ?? 'Не удалось скачать бэкап.');
    }
    return res.bodyBytes;
  }

  Future<void> restoreBackup({
    required String baseUrl,
    required String token,
    required String filename,
    // ОТДЕЛЬНО от filename и намеренно НЕ подставляется автоматически на
    // этом уровне - должно прийти из того, что админ реально напечатал
    // руками в диалоге подтверждения. Если бы сервис сам дублировал
    // filename сюда, проверка confirm_filename на бэкенде превратилась
    // бы в тавтологию (всегда совпадает с собой) и не защищала бы вообще
    // ни от чего - весь смысл этого поля именно в том, что человек
    // должен заново, вручную набрать имя файла, глядя на список бэкапов
    required String confirmFilename,
    required String adminPassword,
  }) async {
    final res = await _client
        .post(
          Uri.parse('$baseUrl/api/admin/system/backups/restore'),
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          body: jsonEncode({
            'filename': filename,
            'admin_password': adminPassword,
            'confirm_filename': confirmFilename,
          }),
        )
        .timeout(const Duration(minutes: 11));
    if (res.statusCode >= 400) {
      throw AdminSystemException(_extractError(res.body) ?? 'Не удалось восстановить базу (код ${res.statusCode}).');
    }
  }
}
