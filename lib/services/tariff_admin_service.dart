import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/subscription_tier.dart';

class TariffAdminException implements Exception {
  final String message;
  TariffAdminException(this.message);
  @override
  String toString() => message;
}

class TariffAdminService {
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

  Future<List<SubscriptionTier>> list({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/tariffs/admin'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw TariffAdminException(_extractDetail(res) ?? 'Не удалось загрузить тарифы (код ${res.statusCode}).');
    }
    return (jsonDecode(res.body) as List<dynamic>)
        .map((e) => SubscriptionTier.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SubscriptionTier> update({
    required String baseUrl,
    required String token,
    required String key,
    String? nameRu,
    String? nameEn,
    int? priceRubCents,
    int? priceUsdCents,
    int? monthlyTokenLimit,
    bool clearMonthlyTokenLimit = false,
    int? dailyFreeRequests,
    bool clearDailyFreeRequests = false,
    bool? isActive,
    int? sortOrder,
    int? durationDays,
  }) async {
    final body = <String, dynamic>{};
    if (nameRu != null) body['name_ru'] = nameRu;
    if (nameEn != null) body['name_en'] = nameEn;
    if (priceRubCents != null) body['price_rub_cents'] = priceRubCents;
    if (priceUsdCents != null) body['price_usd_cents'] = priceUsdCents;
    if (clearMonthlyTokenLimit) {
      body['clear_monthly_token_limit'] = true;
    } else if (monthlyTokenLimit != null) {
      body['monthly_token_limit'] = monthlyTokenLimit;
    }
    if (clearDailyFreeRequests) {
      body['clear_daily_free_requests'] = true;
    } else if (dailyFreeRequests != null) {
      body['daily_free_requests'] = dailyFreeRequests;
    }
    if (isActive != null) body['is_active'] = isActive;
    if (sortOrder != null) body['sort_order'] = sortOrder;
    if (durationDays != null) body['duration_days'] = durationDays;

    final res = await _client
        .patch(
          Uri.parse('$baseUrl/api/tariffs/admin/$key'),
          headers: _headers(token),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw TariffAdminException(_extractDetail(res) ?? 'Не удалось сохранить (код ${res.statusCode}).');
    }
    return SubscriptionTier.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  void dispose() => _client.close();
}
