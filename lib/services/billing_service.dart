import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/billing_plan.dart';

class BillingException implements Exception {
  final String message;
  BillingException(this.message);
  @override
  String toString() => message;
}

class BillingService {
  final http.Client _client = http.Client();

  Future<List<BillingPlan>> listPlans(String baseUrl) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/billing/plans'))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode >= 400) {
      throw BillingException('Не удалось загрузить тарифы (код ${res.statusCode}).');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => BillingPlan.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Возвращает ссылку на страницу оплаты Stripe (hosted checkout) —
  /// открывается во внешнем браузере, наш код не видит и не обрабатывает
  /// данные карты вообще (см. backend/billing.py).
  Future<String> createCheckoutUrl({
    required String baseUrl,
    required String token,
    required String tariff,
  }) async {
    final res = await _client
        .post(
          Uri.parse('$baseUrl/api/billing/checkout'),
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
          body: jsonEncode({'tariff': tariff}),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw BillingException(_extractError(res.body) ?? 'Не удалось начать оплату (код ${res.statusCode}).');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final url = data['checkout_url'] as String?;
    if (url == null || url.isEmpty) {
      throw BillingException('Сервер не вернул ссылку на оплату.');
    }
    return url;
  }

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
