import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/oauth_provider.dart';

class OAuthAdminException implements Exception {
  final String message;
  OAuthAdminException(this.message);
  @override
  String toString() => message;
}

class OAuthAdminService {
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

  Future<List<OAuthProvider>> list({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/oauth/admin/providers'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw OAuthAdminException(_extractDetail(res) ?? 'Не удалось загрузить провайдеров (код ${res.statusCode}).');
    }
    return (jsonDecode(res.body) as List<dynamic>).map((e) => OAuthProvider.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OAuthProvider> update({
    required String baseUrl,
    required String token,
    required String provider,
    String? clientId,
    String? clientSecret,
    bool? enabled,
  }) async {
    final fields = <String, dynamic>{};
    if (clientId != null) fields['client_id'] = clientId;
    if (clientSecret != null) fields['client_secret'] = clientSecret;
    if (enabled != null) fields['enabled'] = enabled;

    final res = await _client
        .patch(
          Uri.parse('$baseUrl/api/oauth/admin/providers/$provider'),
          headers: _headers(token),
          body: jsonEncode(fields),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw OAuthAdminException(_extractDetail(res) ?? 'Не удалось сохранить (код ${res.statusCode}).');
    }
    return OAuthProvider.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  void dispose() => _client.close();
}
