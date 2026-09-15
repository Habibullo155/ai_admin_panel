import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/app_user.dart';

class AuthResult {
  final String token;
  final AppUser user;
  AuthResult({required this.token, required this.user});
}

/// Бросается при ожидаемых ошибках сервера (неверный пароль, email занят,
/// и т.п.) — содержит понятное сообщение из ответа бэкенда.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  final http.Client _client = http.Client();
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  Future<String?> readStoredToken() => _storage.read(key: _tokenKey);

  Future<void> _storeToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  Future<AuthResult> register({
    required String baseUrl,
    required String email,
    required String password,
  }) => _authRequest('$baseUrl/api/auth/register', email, password);

  Future<AuthResult> login({
    required String baseUrl,
    required String email,
    required String password,
  }) => _authRequest('$baseUrl/api/auth/login', email, password);

  Future<AuthResult> _authRequest(String url, String email, String password) async {
    http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw AuthException('Не удалось связаться с сервером.\n$e');
    }

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw AuthException('Сервер вернул неожиданный ответ (код ${res.statusCode}).');
    }

    if (res.statusCode >= 400) {
      throw AuthException(_extractErrorMessage(data));
    }

    final token = data['access_token'] as String;
    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    await _storeToken(token);
    return AuthResult(token: token, user: user);
  }

  /// Проверяет токен и возвращает свежие данные пользователя.
  /// Возвращает null, если токен недействителен/истёк — вызывающий код
  /// должен в этом случае разлогинить пользователя.
  Future<AppUser?> fetchMe({required String baseUrl, required String token}) async {
    try {
      final res = await _client.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      return AppUser.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Необратимое удаление своего аккаунта — требует подтверждения паролем
  /// на сервере (см. backend/routers_auth.py). Бросает AuthException с
  /// понятным сообщением, если пароль неверный или сервер недоступен.
  Future<void> deleteAccount({
    required String baseUrl,
    required String token,
    required String password,
  }) async {
    http.Response res;
    try {
      res = await _client
          .delete(
            Uri.parse('$baseUrl/api/auth/me'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'password': password}),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw AuthException('Не удалось связаться с сервером.\n$e');
    }

    if (res.statusCode >= 400) {
      Map<String, dynamic> data;
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        throw AuthException('Не удалось удалить аккаунт (код ${res.statusCode}).');
      }
      throw AuthException(_extractErrorMessage(data));
    }

    await clearToken();
  }

  /// Обновляет только СВОИ поля профиля (ФИО, возраст, хобби) — не все
  /// три обязательны разом, можно прислать одно. Передавай явный `null`
  /// в соответствующем параметре, чтобы очистить поле, а не просто
  /// пропускай его — пропущенный параметр здесь и так не попадёт в тело
  /// запроса (см. ниже), так что это разделение делает сам вызывающий код.
  Future<AppUser> updateProfile({
    required String baseUrl,
    required String token,
    Map<String, dynamic>? fields,
  }) async {
    http.Response res;
    try {
      res = await _client
          .patch(
            Uri.parse('$baseUrl/api/auth/me/profile'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(fields ?? {}),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw AuthException('Не удалось связаться с сервером.\n$e');
    }

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw AuthException('Сервер вернул неожиданный ответ (код ${res.statusCode}).');
    }

    if (res.statusCode >= 400) {
      throw AuthException(_extractErrorMessage(data));
    }

    return AppUser.fromJson(data);
  }

  /// Backend отвечает 204 без тела при успехе - в отличие от остальных
  /// методов здесь нечего декодировать в успешном случае, только на
  /// ошибке приходит JSON с detail.
  Future<void> changePassword({
    required String baseUrl,
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    http.Response res;
    try {
      res = await _client
          .patch(
            Uri.parse('$baseUrl/api/auth/me/password'),
            headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
            body: jsonEncode({'current_password': currentPassword, 'new_password': newPassword}),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw AuthException('Не удалось связаться с сервером.\n$e');
    }

    if (res.statusCode >= 400) {
      Map<String, dynamic> data;
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        throw AuthException('Сервер вернул неожиданный ответ (код ${res.statusCode}).');
      }
      throw AuthException(_extractErrorMessage(data));
    }
  }

  /// Первый шаг смены почты - код уходит на НОВЫЙ адрес, сама почта
  /// пока не меняется (см. подтверждение ниже).
  Future<void> requestEmailChange({
    required String baseUrl,
    required String token,
    required String newEmail,
    required String currentPassword,
  }) async {
    http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse('$baseUrl/api/auth/me/email/request-change'),
            headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
            body: jsonEncode({'new_email': newEmail, 'current_password': currentPassword}),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw AuthException('Не удалось связаться с сервером.\n$e');
    }

    if (res.statusCode >= 400) {
      Map<String, dynamic> data;
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        throw AuthException('Сервер вернул неожиданный ответ (код ${res.statusCode}).');
      }
      throw AuthException(_extractErrorMessage(data));
    }
  }

  /// Второй шаг - код, присланный на новый адрес, применяет смену.
  Future<AppUser> confirmEmailChange({
    required String baseUrl,
    required String token,
    required String changeToken,
  }) async {
    http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse('$baseUrl/api/auth/me/email/confirm-change'),
            headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
            body: jsonEncode({'token': changeToken}),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw AuthException('Не удалось связаться с сервером.\n$e');
    }

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw AuthException('Сервер вернул неожиданный ответ (код ${res.statusCode}).');
    }

    if (res.statusCode >= 400) {
      throw AuthException(_extractErrorMessage(data));
    }

    return AppUser.fromJson(data);
  }

  /// Всегда завершается успешно (сервер намеренно отвечает одинаково, есть
  /// такой email или нет - см. комментарий в routers_auth.py), кроме
  /// реальных сетевых сбоев или превышения лимита запросов (429).
  Future<void> forgotPassword({required String baseUrl, required String email}) async {
    http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse('$baseUrl/api/auth/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw AuthException('Не удалось связаться с сервером.\n$e');
    }

    if (res.statusCode >= 400) {
      Map<String, dynamic> data;
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        throw AuthException('Не удалось отправить запрос (код ${res.statusCode}).');
      }
      throw AuthException(_extractErrorMessage(data));
    }
  }

  Future<void> resetPassword({
    required String baseUrl,
    required String token,
    required String newPassword,
  }) async {
    http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse('$baseUrl/api/auth/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': token, 'new_password': newPassword}),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw AuthException('Не удалось связаться с сервером.\n$e');
    }

    if (res.statusCode >= 400) {
      Map<String, dynamic> data;
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        throw AuthException('Не удалось сменить пароль (код ${res.statusCode}).');
      }
      throw AuthException(_extractErrorMessage(data));
    }
  }

  /// Возвращает свежие данные пользователя (is_email_verified теперь true) -
  /// вызывающий код (AuthStore) должен обновить своё поле user этим
  /// результатом, иначе баннер "подтвердите почту" не пропадёт до
  /// следующего перезапуска приложения.
  Future<AppUser> verifyEmail({required String baseUrl, required String token}) async {
    http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse('$baseUrl/api/auth/verify-email'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': token}),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw AuthException('Не удалось связаться с сервером.\n$e');
    }

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw AuthException('Сервер вернул неожиданный ответ (код ${res.statusCode}).');
    }

    if (res.statusCode >= 400) {
      throw AuthException(_extractErrorMessage(data));
    }

    return AppUser.fromJson(data);
  }

  Future<void> resendVerification({required String baseUrl, required String token}) async {
    http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse('$baseUrl/api/auth/resend-verification'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw AuthException('Не удалось связаться с сервером.\n$e');
    }

    if (res.statusCode >= 400) {
      Map<String, dynamic> data;
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        throw AuthException('Не удалось отправить код повторно (код ${res.statusCode}).');
      }
      throw AuthException(_extractErrorMessage(data));
    }
  }

  /// FastAPI отдаёт ошибки в двух разных формах:
  /// - {"detail": "текст"} — наши собственные HTTPException;
  /// - {"detail": [{"msg": "...", "loc": [...]}, ...]} — автоматическая
  ///   валидация pydantic (например, слишком короткий пароль). Без этой
  ///   проверки код упал бы на приведении List к String.
  String _extractErrorMessage(Map<String, dynamic> data) {
    final detail = data['detail'];
    if (detail is String) return detail;
    if (detail is List && detail.isNotEmpty) {
      final messages = detail
          .map((e) => e is Map ? e['msg']?.toString() : e.toString())
          .whereType<String>()
          .toList();
      if (messages.isNotEmpty) return messages.join('\n');
    }
    return 'Ошибка авторизации.';
  }

  void dispose() => _client.close();
}
