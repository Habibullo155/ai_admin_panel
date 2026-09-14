import 'dart:convert';

import 'package:http/http.dart' as http;

class PronunciationException implements Exception {
  final String message;
  PronunciationException(this.message);
  @override
  String toString() => message;
}

class PronunciationService {
  final http.Client _client = http.Client();

  /// Если сервер недоступен — возвращаем пустой словарь, не блокируем
  /// озвучку целиком из-за временной проблемы с сетью.
  Future<Map<String, String>> getPublicDictionary(String baseUrl) async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/api/pronunciation/public'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return {};
      final list = jsonDecode(res.body) as List<dynamic>;
      return {
        for (final e in list.cast<Map<String, dynamic>>())
          e['word'] as String: e['pronunciation'] as String,
      };
    } catch (_) {
      return {};
    }
  }

  Future<List<Map<String, String>>> listAdmin({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/pronunciation/public'), headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 10));
    if (res.statusCode >= 400) {
      throw PronunciationException('Не удалось загрузить словарь (код ${res.statusCode}).');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .cast<Map<String, dynamic>>()
        .map((e) => {'word': e['word'] as String, 'pronunciation': e['pronunciation'] as String})
        .toList();
  }

  Future<void> upsert({
    required String baseUrl,
    required String token,
    required String word,
    required String pronunciation,
  }) async {
    final res = await _client
        .put(
          Uri.parse('$baseUrl/api/pronunciation'),
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          body: jsonEncode({'word': word, 'pronunciation': pronunciation}),
        )
        .timeout(const Duration(seconds: 10));
    if (res.statusCode >= 400) {
      throw PronunciationException('Не удалось сохранить слово (код ${res.statusCode}).');
    }
  }

  Future<void> delete({required String baseUrl, required String token, required String word}) async {
    final res = await _client
        .delete(Uri.parse('$baseUrl/api/pronunciation/${Uri.encodeComponent(word)}'),
            headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 10));
    if (res.statusCode >= 400) {
      throw PronunciationException('Не удалось удалить слово (код ${res.statusCode}).');
    }
  }

  void dispose() => _client.close();
}
