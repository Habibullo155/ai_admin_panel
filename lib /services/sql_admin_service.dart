import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sql_query_result.dart';

class SqlAdminException implements Exception {
  final String message;
  SqlAdminException(this.message);
  @override
  String toString() => message;
}

class SqlAdminService {
  final http.Client _client = http.Client();

  Future<SqlQueryResult> execute({
    required String baseUrl,
    required String token,
    required String query,
  }) async {
    http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse('$baseUrl/api/admin/sql/execute'),
            headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
            body: jsonEncode({'query': query}),
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw SqlAdminException('Не удалось связаться с сервером.\n$e');
    }

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw SqlAdminException('Сервер вернул неожиданный ответ (код ${res.statusCode}).');
    }

    if (res.statusCode >= 400) {
      final detail = data['detail'];
      throw SqlAdminException(detail is String ? detail : 'Ошибка выполнения запроса (код ${res.statusCode}).');
    }

    return SqlQueryResult.fromJson(data);
  }

  void dispose() => _client.close();
}
