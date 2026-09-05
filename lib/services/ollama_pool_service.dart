import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ollama_server.dart';

class OllamaPoolException implements Exception {
  final String message;
  OllamaPoolException(this.message);
  @override
  String toString() => message;
}

class OllamaPoolService {
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

  Future<List<OllamaServer>> list({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/ollama-pool/admin/servers'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw OllamaPoolException(_extractDetail(res) ?? 'Не удалось загрузить список серверов (код ${res.statusCode}).');
    }
    return (jsonDecode(res.body) as List<dynamic>).map((e) => OllamaServer.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OllamaServer> getOne({required String baseUrl, required String token, required int id}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/ollama-pool/admin/servers/$id'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw OllamaPoolException(_extractDetail(res) ?? 'Не удалось загрузить сервер (код ${res.statusCode}).');
    }
    return OllamaServer.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<OllamaServer> add({required String baseUrl, required String token, required String name, required String url}) async {
    final res = await _client
        .post(
          Uri.parse('$baseUrl/api/ollama-pool/admin/servers'),
          headers: _headers(token),
          body: jsonEncode({'name': name, 'base_url': url}),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw OllamaPoolException(_extractDetail(res) ?? 'Не удалось добавить сервер (код ${res.statusCode}).');
    }
    return OllamaServer.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<OllamaServer> setEnabled({required String baseUrl, required String token, required int id, required bool enabled}) async {
    final res = await _client
        .patch(
          Uri.parse('$baseUrl/api/ollama-pool/admin/servers/$id'),
          headers: _headers(token),
          body: jsonEncode({'enabled': enabled}),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw OllamaPoolException(_extractDetail(res) ?? 'Не удалось изменить сервер (код ${res.statusCode}).');
    }
    return OllamaServer.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<OllamaServer> recheck({required String baseUrl, required String token, required int id}) async {
    final res = await _client
        .post(Uri.parse('$baseUrl/api/ollama-pool/admin/servers/$id/recheck'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw OllamaPoolException(_extractDetail(res) ?? 'Не удалось перепроверить сервер (код ${res.statusCode}).');
    }
    return OllamaServer.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> remove({required String baseUrl, required String token, required int id}) async {
    final res = await _client
        .delete(Uri.parse('$baseUrl/api/ollama-pool/admin/servers/$id'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw OllamaPoolException(_extractDetail(res) ?? 'Не удалось удалить сервер (код ${res.statusCode}).');
    }
  }

  void dispose() => _client.close();
}
