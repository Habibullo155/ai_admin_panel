import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/gad7_checkin.dart';

/// Результаты GAD-7 хранятся ТОЛЬКО на устройстве — тот же принцип, что
/// и у чек-инов ВОЗ-5 (wellbeing_service.dart).
class Gad7Service {
  String _keyFor(String userId) => 'gad7_checkins_v1_$userId';

  Future<List<Gad7Checkin>> loadCheckins(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyFor(userId));
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Gad7Checkin.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveCheckins(String userId, List<Gad7Checkin> checkins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(checkins.map((c) => c.toJson()).toList());
      await prefs.setString(_keyFor(userId), raw);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Gad7Checkin?> addCheckin(String userId, Gad7Checkin checkin) async {
    final existing = await loadCheckins(userId);
    final updated = [checkin, ...existing];
    final ok = await saveCheckins(userId, updated);
    return ok ? checkin : null;
  }
}
