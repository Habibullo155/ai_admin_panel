import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/telegram_settings.dart';

class TelegramAdminException implements Exception {
  final String message;
  TelegramAdminException(this.message);
  @override
  String toString() => message;
}

class TelegramAdminService {
  final http.Client _client = http.Client();

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  Future<TelegramSettings> fetch({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/settings/admin/telegram'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw TelegramAdminException('Не удалось загрузить настройки Telegram (код ${res.statusCode}).');
    }
    return TelegramSettings.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<TelegramSettings> update({
    required String baseUrl,
    required String token,
    String? channelLink,
    String? channelChatId,
    String? botUsername,
    String? botToken,
    int? bonusRequests,
  }) async {
    final body = <String, dynamic>{};
    if (channelLink != null) body['telegram_channel_link'] = channelLink;
    if (channelChatId != null) body['telegram_channel_chat_id'] = channelChatId;
    if (botUsername != null) body['telegram_bot_username'] = botUsername;
    // пустая строка = "не менять" - не затираем уже сохранённый токен
    // случайной пустой строкой при обычном сохранении остальных полей
    if (botToken != null && botToken.isNotEmpty) body['telegram_bot_token'] = botToken;
    if (bonusRequests != null) body['telegram_bonus_requests'] = bonusRequests;

    final res = await _client
        .patch(
          Uri.parse('$baseUrl/api/settings/admin/telegram'),
          headers: _headers(token),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw TelegramAdminException('Не удалось сохранить (код ${res.statusCode}).');
    }
    return TelegramSettings.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  void dispose() => _client.close();
}
