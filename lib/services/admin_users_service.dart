import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/admin_user.dart';

class AdminUsersException implements Exception {
  final String message;
  AdminUsersException(this.message);
  @override
  String toString() => message;
}

class AdminUsersService {
  final http.Client _client = http.Client();

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  Future<List<AdminUser>> listUsers({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/admin/users'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw AdminUsersException(_extractError(res.body) ?? 'Не удалось загрузить список пользователей.');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => AdminUser.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AdminUser> createUser({
    required String baseUrl,
    required String token,
    required String email,
    required String password,
    String role = 'user',
    String tariff = 'free',
    bool isOperator = false,
  }) async {
    final res = await _client
        .post(
          Uri.parse('$baseUrl/api/admin/users'),
          headers: _headers(token),
          body: jsonEncode({
            'email': email,
            'password': password,
            'role': role,
            'tariff': tariff,
            'is_operator': isOperator,
          }),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw AdminUsersException(_extractError(res.body) ?? 'Не удалось создать пользователя.');
    }
    return AdminUser.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteUser({required String baseUrl, required String token, required int userId}) async {
    final res = await _client
        .delete(Uri.parse('$baseUrl/api/admin/users/$userId'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw AdminUsersException(_extractError(res.body) ?? 'Не удалось удалить пользователя.');
    }
  }

  /// Один общий метод обновления — конкретные поля передаются опционально,
  /// сервер сам разберётся, что менять (соответствует UserAdminUpdate на бэкенде).
  Future<AdminUser> updateUser({
    required String baseUrl,
    required String token,
    required int userId,
    String? tariff,
    String? role,
    bool? isActive,
    int? tariffDays,
    bool? clearTariffExpiry,
    bool? isOperator,
  }) async {
    final body = <String, dynamic>{};
    if (tariff != null) body['tariff'] = tariff;
    if (role != null) body['role'] = role;
    if (isActive != null) body['is_active'] = isActive;
    if (tariffDays != null) body['tariff_days'] = tariffDays;
    if (clearTariffExpiry != null) body['clear_tariff_expiry'] = clearTariffExpiry;
    if (isOperator != null) body['is_operator'] = isOperator;

    final res = await _client
        .patch(
          Uri.parse('$baseUrl/api/admin/users/$userId'),
          headers: _headers(token),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw AdminUsersException(_extractError(res.body) ?? 'Не удалось обновить пользователя.');
    }
    return AdminUser.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  /// FastAPI отдаёт ошибки как {"detail": "текст"} ИЛИ
  /// {"detail": [{"msg": "...", ...}, ...]} при автоматической валидации —
  /// нужно уметь разобрать оба варианта, иначе на втором случае упадём.
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
