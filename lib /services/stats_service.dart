import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/dashboard_stats.dart';

class StatsException implements Exception {
  final String message;
  StatsException(this.message);
  @override
  String toString() => message;
}

class StatsService {
  final http.Client _client = http.Client();

  Future<DashboardStats> getDashboardStats({
    required String baseUrl,
    required String token,
    int? year,
    int? month,
  }) async {
    final query = (year != null && month != null) ? '?year=$year&month=$month' : '';
    final res = await _client
        .get(
          Uri.parse('$baseUrl/api/admin/stats$query'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw StatsException('Не удалось загрузить статистику (код ${res.statusCode}).');
    }
    return DashboardStats.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<ActivityDay>> getActivity({required String baseUrl, required String token, int days = 30}) async {
    final res = await _client
        .get(
          Uri.parse('$baseUrl/api/admin/stats/activity?days=$days'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw StatsException('Не удалось загрузить активность (код ${res.statusCode}).');
    }
    return (jsonDecode(res.body) as List<dynamic>).map((e) => ActivityDay.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<AdminPurchase>> getPurchases({
    required String baseUrl,
    required String token,
    int limit = 50,
    int offset = 0,
  }) async {
    final res = await _client
        .get(
          Uri.parse('$baseUrl/api/admin/stats/purchases?limit=$limit&offset=$offset'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw StatsException('Не удалось загрузить покупки (код ${res.statusCode}).');
    }
    return (jsonDecode(res.body) as List<dynamic>).map((e) => AdminPurchase.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ComplaintsMonth>> getComplaintsByMonth({required String baseUrl, required String token, int months = 12}) async {
    final res = await _client
        .get(
          Uri.parse('$baseUrl/api/admin/stats/complaints-by-month?months=$months'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw StatsException('Не удалось загрузить жалобы по месяцам (код ${res.statusCode}).');
    }
    return (jsonDecode(res.body) as List<dynamic>).map((e) => ComplaintsMonth.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<HourlyActivity>> getActivityByHour({required String baseUrl, required String token, int days = 30}) async {
    final res = await _client
        .get(
          Uri.parse('$baseUrl/api/admin/stats/activity-by-hour?days=$days'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw StatsException('Не удалось загрузить активность по часам (код ${res.statusCode}).');
    }
    return (jsonDecode(res.body) as List<dynamic>).map((e) => HourlyActivity.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TokenUsageByUser>> getTokenUsageByUser({
    required String baseUrl,
    required String token,
    int days = 30,
    int limit = 50,
  }) async {
    final res = await _client
        .get(
          Uri.parse('$baseUrl/api/admin/stats/token-usage-by-user?days=$days&limit=$limit'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw StatsException('Не удалось загрузить расход токенов (код ${res.statusCode}).');
    }
    return (jsonDecode(res.body) as List<dynamic>).map((e) => TokenUsageByUser.fromJson(e as Map<String, dynamic>)).toList();
  }

  void dispose() => _client.close();
}
