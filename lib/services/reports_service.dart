import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/response_report.dart';

class ReportsException implements Exception {
  final String message;
  ReportsException(this.message);
  @override
  String toString() => message;
}

class ReportsService {
  final http.Client _client = http.Client();

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  Future<ResponseReport> createReport({
    required String baseUrl,
    required String token,
    required String userMessage,
    required String aiResponse,
    String? reason,
  }) async {
    final res = await _client
        .post(
          Uri.parse('$baseUrl/api/reports'),
          headers: _headers(token),
          body: jsonEncode({
            'user_message': userMessage,
            'ai_response': aiResponse,
            if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
          }),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw ReportsException(_extractError(res.body) ?? 'Не удалось отправить жалобу.');
    }
    return ResponseReport.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<ResponseReport>> myReports({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/reports/my'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw ReportsException(_extractError(res.body) ?? 'Не удалось загрузить жалобы.');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => ResponseReport.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ResponseReport>> allReports({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/reports'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw ReportsException(_extractError(res.body) ?? 'Не удалось загрузить жалобы.');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => ResponseReport.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ResponseReport> updateStatus({
    required String baseUrl,
    required String token,
    required int reportId,
    required ReportStatus status,
  }) async {
    final res = await _client
        .patch(
          Uri.parse('$baseUrl/api/reports/$reportId'),
          headers: _headers(token),
          body: jsonEncode({'status': status == ReportStatus.resolved ? 'resolved' : 'open'}),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw ReportsException(_extractError(res.body) ?? 'Не удалось обновить статус.');
    }
    return ResponseReport.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// Прямой текстовый ответ пользователю по существу жалобы — виден ему
  /// в его собственном списке (myReports), не то же самое, что причина
  /// исправления для датасета обучения.
  Future<ResponseReport> setReply({
    required String baseUrl,
    required String token,
    required int reportId,
    required String reply,
  }) async {
    final res = await _client
        .put(
          Uri.parse('$baseUrl/api/reports/$reportId/reply'),
          headers: _headers(token),
          body: jsonEncode({'admin_reply': reply}),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw ReportsException(_extractError(res.body) ?? 'Не удалось отправить ответ.');
    }
    return ResponseReport.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// FastAPI отдаёт ошибки как {"detail": "текст"} ИЛИ
  /// {"detail": [{"msg": "...", ...}, ...]} при автоматической валидации.
  String? _extractError(String body) {
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
