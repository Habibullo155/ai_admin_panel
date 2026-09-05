import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class CloudTtsException implements Exception {
  final String message;
  CloudTtsException(this.message);
  @override
  String toString() => message;
}

class CloudTtsService {
  final http.Client _client = http.Client();

  /// Возвращает сырые байты MP3 — декодированные из base64, который
  /// присылает наш бэкенд (backend/routers_tts.py). Ключ Silero (если
  /// вообще настроен на самом сервере) приложение никогда не видит.
  Future<Uint8List> synthesize({
    required String baseUrl,
    required String token,
    required String text,
    required String voiceName,
  }) async {
    final res = await _client
        .post(
          Uri.parse('$baseUrl/api/tts/synthesize'),
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          body: jsonEncode({'text': text, 'voice_name': voiceName, 'language_code': 'ru-RU'}),
        )
        .timeout(const Duration(seconds: 25));

    if (res.statusCode >= 400) {
      throw CloudTtsException(_extractError(res.body) ?? 'Не удалось озвучить текст (код ${res.statusCode}).');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final audioBase64 = data['audio_base64'] as String?;
    if (audioBase64 == null || audioBase64.isEmpty) {
      throw CloudTtsException('Сервер не вернул аудио.');
    }
    return base64Decode(audioBase64);
  }

  String? _extractError(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final detail = data['detail'];
      if (detail is String) return detail;
      return null;
    } catch (_) {
      return null;
    }
  }

  void dispose() => _client.close();
}
