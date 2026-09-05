import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/help_session.dart';

class HelpException implements Exception {
  final String message;
  HelpException(this.message);
  @override
  String toString() => message;
}

class HelpService {
  final http.Client _client = http.Client();

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  String? _extractError(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final detail = data['detail'];
      return detail is String ? detail : null;
    } catch (_) {
      return null;
    }
  }

  // --- Пользовательская сторона ---

  Future<HelpSession> createSession({
    required String baseUrl,
    required String token,
    String? reason,
    String? chatContext,
  }) async {
    final res = await _client
        .post(
          Uri.parse('$baseUrl/api/help/sessions'),
          headers: _headers(token),
          body: jsonEncode({'reason': reason, 'chat_context': chatContext}),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw HelpException(_extractError(res.body) ?? 'Не удалось создать обращение.');
    }
    return HelpSession.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<HelpSession>> mySessions({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/help/sessions/my'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw HelpException(_extractError(res.body) ?? 'Не удалось загрузить обращения.');
    }
    return (jsonDecode(res.body) as List<dynamic>)
        .map((e) => HelpSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // --- Общее (участник сессии) ---

  Future<List<HelpMessage>> getMessages({
    required String baseUrl,
    required String token,
    required int sessionId,
  }) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/help/sessions/$sessionId/messages'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw HelpException(_extractError(res.body) ?? 'Не удалось загрузить сообщения.');
    }
    return (jsonDecode(res.body) as List<dynamic>)
        .map((e) => HelpMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<HelpMessage> sendMessage({
    required String baseUrl,
    required String token,
    required int sessionId,
    required String content,
    List<String>? images,
  }) async {
    final res = await _client
        .post(
          Uri.parse('$baseUrl/api/help/sessions/$sessionId/messages'),
          headers: _headers(token),
          body: jsonEncode({
            'content': content,
            if (images != null && images.isNotEmpty) 'images': images,
          }),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw HelpException(_extractError(res.body) ?? 'Не удалось отправить сообщение.');
    }
    return HelpMessage.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<HelpSession> closeSession({
    required String baseUrl,
    required String token,
    required int sessionId,
  }) async {
    final res = await _client
        .post(Uri.parse('$baseUrl/api/help/sessions/$sessionId/close'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw HelpException(_extractError(res.body) ?? 'Не удалось закрыть обращение.');
    }
    return HelpSession.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// Оценивает подключившегося оператора — только тот, кто запросил
  /// помощь, может это сделать (проверка на сервере).
  Future<HelpSession> rateSession({
    required String baseUrl,
    required String token,
    required int sessionId,
    required int rating,
    String? comment,
  }) async {
    final res = await _client
        .post(
          Uri.parse('$baseUrl/api/help/sessions/$sessionId/rate'),
          headers: _headers(token),
          body: jsonEncode({'rating': rating, 'comment': comment}),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw HelpException(_extractError(res.body) ?? 'Не удалось отправить оценку.');
    }
    return HelpSession.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // --- Операторская сторона ---

  Future<List<HelpSession>> pendingSessions({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/help/sessions/pending'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw HelpException(_extractError(res.body) ?? 'Не удалось загрузить заявки.');
    }
    return (jsonDecode(res.body) as List<dynamic>)
        .map((e) => HelpSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<HelpSession>> activeSessions({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/help/sessions/active'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw HelpException(_extractError(res.body) ?? 'Не удалось загрузить активные обращения.');
    }
    return (jsonDecode(res.body) as List<dynamic>)
        .map((e) => HelpSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<HelpSession> claimSession({
    required String baseUrl,
    required String token,
    required int sessionId,
  }) async {
    final res = await _client
        .post(Uri.parse('$baseUrl/api/help/sessions/$sessionId/claim'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 409) {
      throw HelpException('Эту заявку уже забрал другой оператор.');
    }
    if (res.statusCode >= 400) {
      throw HelpException(_extractError(res.body) ?? 'Не удалось принять заявку.');
    }
    return HelpSession.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  void dispose() => _client.close();
}
