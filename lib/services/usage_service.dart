import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/usage_info.dart';

class UsageException implements Exception {
  final String message;
  UsageException(this.message);
  @override
  String toString() => message;
}

class UsageService {
  final http.Client _client = http.Client();

  Future<UsageInfo> getMyUsage({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/usage/me'), headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 10));
    if (res.statusCode >= 400) {
      throw UsageException('Не удалось загрузить расход токенов (код ${res.statusCode}).');
    }
    return UsageInfo.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  void dispose() => _client.close();
}
