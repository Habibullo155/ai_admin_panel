import 'dart:convert';

import 'package:http/http.dart' as http;

import 'pinned_http_client.dart';

import '../models/payment_settings.dart';

class PaymentAdminException implements Exception {
  final String message;
  PaymentAdminException(this.message);
  @override
  String toString() => message;
}

/// Статус одного способа оплаты (GET /api/admin/payments/status). Ключи
/// задаются в .env на сервере - здесь только состояние.
class PaymentProviderStatus {
  final String key;
  final String title;
  final bool enabled;
  final bool configured;
  final bool ready;
  final String source; // env | admin | none
  final String? mode; // test | live
  final String? account;
  final List<String> missing;
  final Map<String, String> setupUrls;
  final Map<String, String?> events;
  final List<String> notes;

  PaymentProviderStatus.fromJson(Map<String, dynamic> j)
      : key = j['key'] as String,
        title = j['title'] as String,
        enabled = j['enabled'] as bool? ?? false,
        configured = j['configured'] as bool? ?? false,
        ready = j['ready'] as bool? ?? false,
        source = j['source'] as String? ?? 'none',
        mode = j['mode'] as String?,
        account = j['account'] as String?,
        missing = [for (final m in (j['missing'] as List? ?? const [])) m as String],
        setupUrls = {
          for (final e in ((j['setup_urls'] as Map?) ?? const {}).entries) e.key as String: e.value as String,
        },
        events = {
          for (final e in ((j['events'] as Map?) ?? const {}).entries) e.key as String: e.value as String?,
        },
        notes = [for (final n in (j['notes'] as List? ?? const [])) n as String];
}

class PaymentsStatus {
  final String? publicBaseUrl;
  final String inAppPaymentsNote;
  final List<PaymentProviderStatus> providers;

  PaymentsStatus.fromJson(Map<String, dynamic> j)
      : publicBaseUrl = j['public_base_url'] as String?,
        inAppPaymentsNote = j['in_app_payments_note'] as String? ?? '',
        providers = [
          for (final p in (j['providers'] as List? ?? const []))
            PaymentProviderStatus.fromJson(p as Map<String, dynamic>),
        ];
}

class PaymentAdminService {
  final http.Client _client = createHttpClient();

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
    bool? alfabankEnabled,
    String? alfabankBaseUrl,
    String? alfabankLogin,
    String? alfabankPassword,
    String? alfabankToken,
  }) async {
    final body = <String, dynamic>{};
    if (stripeEnabled != null) body['stripe_enabled'] = stripeEnabled;
    if (yoomoneyEnabled != null) body['yoomoney_enabled'] = yoomoneyEnabled;
    if (yoomoneyWallet != null) body['yoomoney_wallet'] = yoomoneyWallet;
    // пустая строка = "не менять" - не затираем уже сохранённый секрет
    if (yoomoneySecret != null && yoomoneySecret.isNotEmpty) body['yoomoney_secret'] = yoomoneySecret;
    if (alfabankEnabled != null) body['alfabank_enabled'] = alfabankEnabled;
    if (alfabankBaseUrl != null) body['alfabank_base_url'] = alfabankBaseUrl;
    if (alfabankLogin != null) body['alfabank_login'] = alfabankLogin;
    if (alfabankPassword != null && alfabankPassword.isNotEmpty) body['alfabank_password'] = alfabankPassword;
    if (alfabankToken != null && alfabankToken.isNotEmpty) body['alfabank_token'] = alfabankToken;

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

  String _errorText(http.Response res, String fallback) {
    try {
      final detail = (jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>)['detail'];
      if (detail is String) return detail;
    } catch (_) {}
    return '$fallback (код ${res.statusCode}).';
  }

  Future<PaymentsStatus> fetchStatus({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/admin/payments/status'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw PaymentAdminException(_errorText(res, 'Не удалось загрузить статус оплаты'));
    }
    return PaymentsStatus.fromJson(jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>);
  }

  /// Ссылка на настоящий небольшой платёж ЮMoney для проверки цепочки.
  Future<String> createYoomoneyTestLink({required String baseUrl, required String token, int amountRub = 10}) async {
    final res = await _client
        .post(
          Uri.parse('$baseUrl/api/admin/payments/yoomoney/test-link'),
          headers: _headers(token),
          body: jsonEncode({'amount_rub': amountRub}),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw PaymentAdminException(_errorText(res, 'Не удалось создать проверочную ссылку'));
    }
    return (jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>)['url'] as String;
  }

  /// (ok, сообщение) - проверка логина/пароля Альфа-Банка.
  Future<(bool, String)> checkAlfabank({required String baseUrl, required String token}) async {
    final res = await _client
        .post(Uri.parse('$baseUrl/api/admin/payments/alfabank/check'), headers: _headers(token))
        .timeout(const Duration(seconds: 30));
    if (res.statusCode >= 400) {
      throw PaymentAdminException(_errorText(res, 'Не удалось проверить банк'));
    }
    final j = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return (j['ok'] as bool? ?? false, j['message'] as String? ?? '');
  }
}
