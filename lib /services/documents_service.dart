import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/rag_document.dart';

class DocumentsException implements Exception {
  final String message;
  DocumentsException(this.message);
  @override
  String toString() => message;
}

class DocumentsService {
  final http.Client _client = http.Client();

  Map<String, String> _authHeader(String token) => {'Authorization': 'Bearer $token'};

  Future<List<RagDocument>> list({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/admin/documents'), headers: _authHeader(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw DocumentsException(_extractDetail(res.body) ?? 'Не удалось загрузить список документов.');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => RagDocument.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Загружает PDF по байтам файла — работает одинаково на мобильных,
  /// десктопе и в вебе (там нет доступа к файловой системе напрямую).
  ///
  /// [onProgress] — доля от 0.0 до 1.0, сколько байт файла реально ушло
  /// по сети. Пакет `http` не даёт это "из коробки" (в отличие от dio) —
  /// перехватываем поток, который `MultipartRequest` сам готовит для
  /// отправки (`finalize()`), считаем прошедшие через него байты и
  /// пересылаем их дальше в `http.StreamedRequest`, который и правда
  /// уходит на сервер. Важная оговорка: это доля именно ЗАГРУЗКИ файла
  /// по сети — не включает время, которое сервер тратит потом на разбор
  /// PDF и построение эмбеддингов (тот шаг уже без пошагового прогресса,
  /// см. комментарий в admin_documents_screen.dart).
  Future<RagDocument> upload({
    required String baseUrl,
    required String token,
    required String filename,
    required Uint8List bytes,
    void Function(double progress)? onProgress,
  }) async {
    final uri = Uri.parse('$baseUrl/api/admin/documents');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_authHeader(token))
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

    http.StreamedResponse streamed;
    try {
      // 30 минут, не 5 — реальная книга (до 50 МБ) с построением
      // эмбеддингов по многим разделам на CPU-only Ollama может занять
      // заметно больше времени, чем сама передача файла по сети.
      const uploadTimeout = Duration(minutes: 30);
      if (onProgress == null) {
        streamed = await _client.send(request).timeout(uploadTimeout);
      } else {
        final total = request.contentLength;
        var sent = 0;
        final sourceStream = request.finalize();

        final streamedRequest = http.StreamedRequest(request.method, request.url)
          ..headers.addAll(request.headers)
          ..contentLength = total
          ..followRedirects = request.followRedirects
          ..persistentConnection = request.persistentConnection;

        sourceStream.listen(
          (chunk) {
            sent += chunk.length;
            if (total > 0) onProgress((sent / total).clamp(0.0, 1.0));
            streamedRequest.sink.add(chunk);
          },
          onDone: () => streamedRequest.sink.close(),
          onError: (Object e, StackTrace st) => streamedRequest.sink.addError(e, st),
          cancelOnError: true,
        );

        streamed = await _client.send(streamedRequest).timeout(uploadTimeout);
      }
    } catch (e) {
      throw DocumentsException('Не удалось связаться с сервером.\n$e');
    }
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode >= 400) {
      throw DocumentsException(_extractDetail(res.body) ?? 'Ошибка загрузки документа (код ${res.statusCode}).');
    }
    return RagDocument.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> delete({required String baseUrl, required String token, required int documentId}) async {
    final res = await _client
        .delete(Uri.parse('$baseUrl/api/admin/documents/$documentId'), headers: _authHeader(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw DocumentsException(_extractDetail(res.body) ?? 'Не удалось удалить документ.');
    }
  }

  String? _extractDetail(String body) {
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

  void dispose() => _client.close();
}
