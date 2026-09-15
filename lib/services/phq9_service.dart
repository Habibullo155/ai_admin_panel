import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/phq9_checkin.dart';

/// Результаты PHQ-9 хранятся ТОЛЬКО на устройстве — тот же принцип, что
/// и у чек-инов ВОЗ-5 (wellbeing_service.dart): это чувствительные данные
/// о психологическом состоянии, на сервер они никогда не отправляются.
class Phq9Service {
  String _keyFor(String userId) => 'phq9_checkins_v1_$userId';

  Future<List<Phq9Checkin>> loadCheckins(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyFor(userId));
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Phq9Checkin.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveCheckins(String userId, List<Phq9Checkin> checkins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(checkins.map((c) => c.toJson()).toList());
      await prefs.setString(_keyFor(userId), raw);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Phq9Checkin?> addCheckin(String userId, Phq9Checkin checkin) async {
    final existing = await loadCheckins(userId);
    final updated = [checkin, ...existing];
    final ok = await saveCheckins(userId, updated);
    return ok ? checkin : null;
  }
}
