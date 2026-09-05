import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/support_ticket.dart';

class SupportException implements Exception {
  final String message;
  SupportException(this.message);
  @override
  String toString() => message;
}

class SupportService {
  final http.Client _client = http.Client();

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  Future<SupportTicket> createTicket({
    required String baseUrl,
    required String token,
    required String message,
  }) async {
    final res = await _client
        .post(
          Uri.parse('$baseUrl/api/support'),
          headers: _headers(token),
          body: jsonEncode({'message': message}),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw SupportException(_extractDetail(res.body) ?? 'Не удалось отправить обращение.');
    }
    return SupportTicket.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<SupportTicket>> myTickets({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/support/my'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw SupportException(_extractDetail(res.body) ?? 'Не удалось загрузить обращения.');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => SupportTicket.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<SupportTicket>> allTickets({required String baseUrl, required String token}) async {
    final res = await _client
        .get(Uri.parse('$baseUrl/api/support'), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw SupportException(_extractDetail(res.body) ?? 'Не удалось загрузить обращения.');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => SupportTicket.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SupportTicket> updateStatus({
    required String baseUrl,
    required String token,
    required int ticketId,
    required TicketStatus status,
  }) async {
    final res = await _client
        .patch(
          Uri.parse('$baseUrl/api/support/$ticketId'),
          headers: _headers(token),
          body: jsonEncode({'status': status == TicketStatus.closed ? 'closed' : 'open'}),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode >= 400) {
      throw SupportException(_extractDetail(res.body) ?? 'Не удалось обновить статус.');
    }
    return SupportTicket.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  String? _extractDetail(String body) {
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
