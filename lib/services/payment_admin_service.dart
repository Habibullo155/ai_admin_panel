import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/payment_settings.dart';

class PaymentAdminException implements Exception {
  final String message;
  PaymentAdminException(this.message);
  @override
  String toString() => message;
}

class PaymentAdminService {
  final http.Client _client = http.Client();

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  Future<PaymentSettings> fetchPayment({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/settings/admin/payment'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw PaymentAdminException('Не удалось загрузить настройки оплаты (код ${res.statusCode}).');
    }
    return PaymentSettings.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<PaymentSettings> updatePayment({
    required String baseUrl,
    required String token,
    bool? stripeEnabled,
    bool? yoomoneyEnabled,
    String? yoomoneyWallet,
    String? yoomoneySecret,
  }) async {
    final body = <String, dynamic>{};
    if (stripeEnabled != null) body['stripe_enabled'] = stripeEnabled;
    if (yoomoneyEnabled != null) body['yoomoney_enabled'] = yoomoneyEnabled;
    if (yoomoneyWallet != null) body['yoomoney_wallet'] = yoomoneyWallet;
    // пустая строка = "не менять" - не затираем уже сохранённый секрет
    if (yoomoneySecret != null && yoomoneySecret.isNotEmpty) body['yoomoney_secret'] = yoomoneySecret;

    final res = await _client
        .patch(
          Uri.parse('$baseUrl/api/settings/admin/payment'),
          headers: _headers(token),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw PaymentAdminException('Не удалось сохранить (код ${res.statusCode}).');
    }
    return PaymentSettings.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<AdMobSettings> fetchAdMob({required String baseUrl, required String token}) async {
    // без токена - публичный эндпоинт (см. backend/routers_settings.py::get_admob_settings_public)
    final res = await _client
        .get(Uri.parse('$baseUrl/api/settings/admob'))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw PaymentAdminException('Не удалось загрузить настройки AdMob (код ${res.statusCode}).');
    }
    return AdMobSettings.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<AdMobSettings> updateAdMob({
    required String baseUrl,
    required String token,
    bool? enabled,
    String? rewardedAdUnitId,
  }) async {
    final body = <String, dynamic>{};
    if (enabled != null) body['admob_enabled'] = enabled;
    if (rewardedAdUnitId != null) body['admob_rewarded_ad_unit_id'] = rewardedAdUnitId;

    final res = await _client
        .patch(
          Uri.parse('$baseUrl/api/settings/admin/admob'),
          headers: _headers(token),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw PaymentAdminException('Не удалось сохранить (код ${res.statusCode}).');
    }
    return AdMobSettings.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  void dispose() => _client.close();
}
