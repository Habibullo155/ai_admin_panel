import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/smtp_settings.dart';

class SmtpAdminException implements Exception {
  final String message;
  SmtpAdminException(this.message);
  @override
  String toString() => message;
}

class SmtpAdminService {
  final http.Client _client = http.Client();

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  String? _extractDetail(http.Response res) {
    try {
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic> && data['detail'] is String) return data['detail'] as String;
    } catch (_) {
      // тело не JSON или не тот формат - используем общий текст ниже
    }
    return null;
  }

  Future<SmtpSettings> fetch({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/settings/admin/smtp'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw SmtpAdminException(_extractDetail(res) ?? 'Не удалось загрузить настройки почты (код ${res.statusCode}).');
    }
    return SmtpSettings.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<SmtpSettings> update({
    required String baseUrl,
    required String token,
    String? smtpHost,
    String? smtpPort,
    String? smtpUser,
    String? smtpPassword,
    String? smtpFrom,
    String? smtpFromName,
  }) async {
    final fields = <String, dynamic>{};
    if (smtpHost != null) fields['smtp_host'] = smtpHost;
    if (smtpPort != null) fields['smtp_port'] = smtpPort;
    if (smtpUser != null) fields['smtp_user'] = smtpUser;
    // пустое поле = "не менять" - не затираем уже сохранённый пароль
    // случайной пустой строкой при обычном сохранении остальных полей
    if (smtpPassword != null) fields['smtp_password'] = smtpPassword;
    if (smtpFrom != null) fields['smtp_from'] = smtpFrom;
    if (smtpFromName != null) fields['smtp_from_name'] = smtpFromName;

    final res = await _client
        .patch(
          Uri.parse('$baseUrl/api/settings/admin/smtp'),
          headers: _headers(token),
          body: jsonEncode(fields),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw SmtpAdminException(_extractDetail(res) ?? 'Не удалось сохранить (код ${res.statusCode}).');
    }
    return SmtpSettings.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<bool> sendTest({required String baseUrl, required String token, required String to}) async {
    final res = await _client
        .post(
          Uri.parse('$baseUrl/api/settings/admin/smtp/test'),
          headers: _headers(token),
          body: jsonEncode({'to': to}),
        )
        .timeout(const Duration(seconds: 20));
    if (res.statusCode >= 400) {
      throw SmtpAdminException(_extractDetail(res) ?? 'Не удалось отправить тестовое письмо (код ${res.statusCode}).');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['sent'] as bool? ?? false;
  }

  void dispose() => _client.close();
}
