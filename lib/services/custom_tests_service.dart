import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/custom_test.dart';

class CustomTestsException implements Exception {
  final String message;
  CustomTestsException(this.message);
  @override
  String toString() => message;
}

class CustomTestsService {
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

  // --- Публичная сторона ---

  Future<List<CustomTestSummary>> list({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/custom-tests'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw CustomTestsException(_extractError(res.body) ?? 'Не удалось загрузить список тестов.');
    }
    return (jsonDecode(res.body) as List<dynamic>).map((e) => CustomTestSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CustomTest> get({required String baseUrl, required String token, required int testId}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/custom-tests/$testId'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw CustomTestsException(_extractError(res.body) ?? 'Не удалось загрузить тест.');
    }
    return CustomTest.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<CustomTestResult> submit({
    required String baseUrl,
    required String token,
    required int testId,
    required List<Map<String, int>> answers,
  }) async {
    final res = await _client
        .post(
          Uri.parse('$baseUrl/api/custom-tests/$testId/submit'),
          headers: _headers(token),
          body: jsonEncode({'answers': answers}),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw CustomTestsException(_extractError(res.body) ?? 'Не удалось отправить ответы.');
    }
    return CustomTestResult.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<CustomTestResultHistory>> myResults({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/custom-tests/my-results'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw CustomTestsException(_extractError(res.body) ?? 'Не удалось загрузить историю тестов.');
    }
    return (jsonDecode(res.body) as List<dynamic>)
        .map((e) => CustomTestResultHistory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // --- Admin-only ---

  Future<List<CustomTestSummary>> adminList({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/custom-tests/admin'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw CustomTestsException(_extractError(res.body) ?? 'Не удалось загрузить список тестов.');
    }
    return (jsonDecode(res.body) as List<dynamic>).map((e) => CustomTestSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CustomTest> adminGet({required String baseUrl, required String token, required int testId}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/custom-tests/admin/$testId'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw CustomTestsException(_extractError(res.body) ?? 'Не удалось загрузить тест.');
    }
    return CustomTest.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<CustomTest> adminCreate({
    required String baseUrl,
    required String token,
    required String title,
    String? description,
    required List<CustomTestQuestion> questions,
    required List<CustomTestScoreRange> scoreRanges,
    String? aiUsageHint,
    bool isPublished = false,
  }) async {
    final res = await _client
        .post(
          Uri.parse('$baseUrl/api/custom-tests/admin'),
          headers: _headers(token),
          body: jsonEncode({
            'title': title,
            if (description != null && description.isNotEmpty) 'description': description,
            if (aiUsageHint != null && aiUsageHint.isNotEmpty) 'ai_usage_hint': aiUsageHint,
            'questions': questions.map((q) => q.toJson()).toList(),
            'score_ranges': scoreRanges.map((r) => r.toJson()).toList(),
            'is_published': isPublished,
          }),
        )
        .timeout(const Duration(seconds: 20));
    if (res.statusCode >= 400) {
      throw CustomTestsException(_extractError(res.body) ?? 'Не удалось создать тест.');
    }
    return CustomTest.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<CustomTest> adminUpdate({
    required String baseUrl,
    required String token,
    required int testId,
    String? title,
    String? description,
    List<CustomTestQuestion>? questions,
    List<CustomTestScoreRange>? scoreRanges,
    String? aiUsageHint,
    bool? isPublished,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (questions != null) body['questions'] = questions.map((q) => q.toJson()).toList();
    if (scoreRanges != null) body['score_ranges'] = scoreRanges.map((r) => r.toJson()).toList();
    if (aiUsageHint != null) body['ai_usage_hint'] = aiUsageHint;
    if (isPublished != null) body['is_published'] = isPublished;

    final res = await _client
        .patch(
          Uri.parse('$baseUrl/api/custom-tests/admin/$testId'),
          headers: _headers(token),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
    if (res.statusCode >= 400) {
      throw CustomTestsException(_extractError(res.body) ?? 'Не удалось сохранить тест.');
    }
    return CustomTest.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> adminDelete({required String baseUrl, required String token, required int testId}) async {
    final res = await _client
        .delete(Uri.parse('$baseUrl/api/custom-tests/admin/$testId'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw CustomTestsException(_extractError(res.body) ?? 'Не удалось удалить тест.');
    }
  }

  void dispose() => _client.close();
}
