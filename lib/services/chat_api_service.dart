import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';
import '../models/chat_source.dart';

class ChatStreamEvent {
  final String token;
  final bool done;
  final String? error;
  final bool isAuthError;
  final List<ChatSource>? sources;

  ChatStreamEvent({
    required this.token,
    required this.done,
    this.error,
    this.isAuthError = false,
    this.sources,
  });
}

/// Клиент к FastAPI-бэкенду. Отправляет всю историю сообщений и читает
/// потоковый ответ (Server-Sent Events), эмулируя "печатает..." эффект.
class ChatApiService {
  final http.Client _client = http.Client();

  Stream<ChatStreamEvent> sendMessage({
    required String baseUrl,
    required List<ChatMessage> history,
    required String? authToken,
  }) async* {
    final uri = Uri.parse('$baseUrl/api/chat');
    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'messages': history
            .map((m) => {
                  'role': m.roleKey,
                  'content': m.content,
                  if (m.images != null && m.images!.isNotEmpty) 'images': m.images,
                })
            .toList(),
      });
    if (authToken != null) {
      request.headers['Authorization'] = 'Bearer $authToken';
    }

    late http.StreamedResponse response;
    try {
      response = await _client.send(request).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException(
              'Сервер не отвечает. Проверь, что бэкенд запущен на $baseUrl',
            ),
          );
    } catch (e) {
      yield ChatStreamEvent(
        token: '',
        done: true,
        error: 'Не удалось подключиться к $baseUrl.\n$e',
      );
      return;
    }

    if (response.statusCode == 401) {
      yield ChatStreamEvent(
        token: '',
        done: true,
        error: 'Сессия истекла. Выйди и войди заново.',
        isAuthError: true,
      );
      return;
    }

    if (response.statusCode != 200) {
      // /api/chat может вернуть обычную JSON-ошибку FastAPI (не SSE) до
      // старта стрима — например 402 при исчерпанном лимите токенов, или
      // 400 на пустое сообщение. Достаём человекочитаемый detail, а не
      // просто показываем голый код ответа.
      final body = await response.stream.bytesToString();
      yield ChatStreamEvent(
        token: '',
        done: true,
        error: _extractErrorMessage(body) ?? 'Сервер вернул ошибку ${response.statusCode}',
      );
      return;
    }

    final stream = response.stream.transform(utf8.decoder);
    String buffer = '';
    bool sawDone = false;

    try {
      await for (final chunk in stream) {
        buffer += chunk;
        final lines = buffer.split('\n');
        buffer = lines.removeLast(); // возможно неполная строка

        for (final line in lines) {
          if (!line.startsWith('data: ')) continue;
          final jsonStr = line.substring(6).trim();
          if (jsonStr.isEmpty) continue;
          try {
            final data = jsonDecode(jsonStr) as Map<String, dynamic>;
            if (data.containsKey('error')) {
              yield ChatStreamEvent(
                token: '',
                done: true,
                error: data['error'] as String,
              );
              return;
            }
            final isDone = data['done'] as bool? ?? false;
            if (isDone) sawDone = true;
            final rawSources = data['sources'] as List<dynamic>?;
            yield ChatStreamEvent(
              token: data['token'] as String? ?? '',
              done: isDone,
              sources: rawSources?.map((e) => ChatSource.fromJson(e as Map<String, dynamic>)).toList(),
            );
          } catch (_) {
            // пропускаем битую строку
          }
        }
      }
    } catch (e) {
      // Соединение оборвалось прямо во время стрима (например, отвалился
      // туннель Cloudflare/ngrok) — сообщаем об этом явно, а не роняем
      // приложение необработанным исключением.
      yield ChatStreamEvent(
        token: '',
        done: true,
        error:
            '\n\n⚠️ Соединение оборвалось во время ответа (например, отвалился '
            'туннель). Попробуй отправить сообщение ещё раз.\n$e',
      );
      return;
    }

    if (!sawDone) {
      // Поток завершился без финального "done" — вероятно, тоже обрыв связи.
      yield ChatStreamEvent(
        token: '',
        done: true,
        error:
            '\n\n⚠️ Ответ обрезался — соединение закрылось раньше, чем модель '
            'закончила. Попробуй ещё раз.',
      );
    }
  }

  Future<bool> checkHealth(String baseUrl) async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/api/health'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return false;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  String? _extractErrorMessage(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        final messages = detail
            .map((e) => e is Map ? e['msg']?.toString() : e.toString())
            .whereType<String>()
            .toList();
        if (messages.isNotEmpty) return messages.join('\n');
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Раньше врачу при подключении показывалась сырая переписка (до 15
  // последних сообщений) целиком. Теперь вместо этого - короткая сводка
  // от третьего лица: тот же /api/chat, тот же стриминг, только с
  // отдельным одноразовым запросом на резюме вместо обычной реплики.
  // Отдельного бэкенд-эндпоинта под это не заводили - незачем дублировать
  // всю системную обвязку (безопасность, тон, персону), которая тут не
  // мешает, просто не запускать это как обычный разговор.
  Future<String> generateDoctorSummary({
    required String baseUrl,
    required List<ChatMessage> recentMessages,
    required String? authToken,
  }) async {
    final request = ChatMessage(
      id: 'doctor-summary-request',
      role: MessageRole.user,
      content: 'Кратко, в 2-3 предложениях, от третьего лица опиши врачу '
          'состояние человека на основе этого разговора — что беспокоит, '
          'как давно, что уже обсуждалось. Пиши для врача как для коллеги, '
          'не для самого человека, и не используй обращение "ты"/"вы".',
    );
    final buffer = StringBuffer();
    await for (final event in sendMessage(
      baseUrl: baseUrl,
      history: [...recentMessages, request],
      authToken: authToken,
    )) {
      if (event.error != null) {
        throw Exception(event.error);
      }
      buffer.write(event.token);
      if (event.done) break;
    }
    return buffer.toString().trim();
  }

  void dispose() => _client.close();
}
