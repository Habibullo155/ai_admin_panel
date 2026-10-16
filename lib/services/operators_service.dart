import 'dart:convert';

import 'package:flutter/foundation.dart' show compute;
import 'package:http/http.dart' as http;

import 'pinned_http_client.dart';

import '../models/help_session.dart';
import '../models/operator_stats.dart';

class OperatorsException implements Exception {
  final String message;
  OperatorsException(this.message);
  @override
  String toString() => message;
}

class OperatorsService {
  final http.Client _client = createHttpClient();

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

  Future<List<OperatorStats>> listOperators({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/admin/operators'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw OperatorsException(_extractError(res.body) ?? 'Не удалось загрузить список операторов.');
    }
    // compute() - разбор JSON синхронно на главном потоке для большого
        // списка (без пагинации на бэкенде) заметно подвешивает интерфейс -
        // изолят убирает это из UI-потока
        return ((await compute(jsonDecode, res.body)) as List<dynamic>)
        .map((e) => OperatorStats.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<HelpSession>> operatorSessions({
    required String baseUrl,
    required String token,
    required int operatorId,
  }) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/admin/operators/$operatorId/sessions'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw OperatorsException(_extractError(res.body) ?? 'Не удалось загрузить историю обращений.');
    }
    // compute() - разбор JSON синхронно на главном потоке для большого
        // списка (без пагинации на бэкенде) заметно подвешивает интерфейс -
        // изолят убирает это из UI-потока
        return ((await compute(jsonDecode, res.body)) as List<dynamic>)
        .map((e) => HelpSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<OperatorWarning>> listWarnings({
    required String baseUrl,
    required String token,
    required int operatorId,
  }) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/admin/operators/$operatorId/warnings'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw OperatorsException(_extractError(res.body) ?? 'Не удалось загрузить выговоры.');
    }
    // compute() - разбор JSON синхронно на главном потоке для большого
        // списка (без пагинации на бэкенде) заметно подвешивает интерфейс -
        // изолят убирает это из UI-потока
        return ((await compute(jsonDecode, res.body)) as List<dynamic>)
        .map((e) => OperatorWarning.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OperatorWarning> issueWarning({
    required String baseUrl,
    required String token,
    required int operatorId,
    required String reason,
  }) async {
    final res = await _client
        .post(
          Uri.parse('$baseUrl/api/admin/operators/$operatorId/warnings'),
          headers: _headers(token),
          body: jsonEncode({'reason': reason}),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw OperatorsException(_extractError(res.body) ?? 'Не удалось выдать выговор.');
    }
    return OperatorWarning.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  void dispose() => _client.close();
}
